import 'dart:async';

import 'package:cross_cache/cross_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart'
    hide InMemoryChatController;
import 'package:flyer_chat_text_stream_message/flyer_chat_text_stream_message.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'gemini_stream_manager.dart';
import 'in_memory_chat_controller.dart';
import 'locked_scroll_controller.dart';

const Duration kChunkAnimationDuration = Duration(milliseconds: 350);
const double kScrollThreshold = 80.0;

class ChatViewModel extends ChangeNotifier {
  bool get isStreaming => _isStreaming;

  bool get userScrolledUp => _userScrolledUp;

  final scrollController = LockedScrollController();
  final chatController = InMemoryChatController();
  final crossCache = CrossCache();
  late final GeminiStreamManager streamManager;

  final _uuid = const Uuid();
  final _currentUser = const User(id: 'me');
  final _agent = const User(id: 'agent');

  late final GenerativeModel _model;
  late ChatSession _chatSession;

  bool _isStreaming = false;
  bool _userScrolledUp = false;

  StreamSubscription? _currentStreamSubscription;
  String? _currentStreamId;

  ChatViewModel(String geminiApiKey) {
    streamManager = GeminiStreamManager(
      chatController: chatController,
      chunkAnimationDuration: kChunkAnimationDuration,
    );

    _model = GenerativeModel(
      model: 'gemini-2.5-flash-lite',
      apiKey: geminiApiKey,
      safetySettings: [
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.none),
      ],
    );

    _chatSession = _model.startChat();
    scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController.removeListener(_onScroll);
    _currentStreamSubscription?.cancel();
    streamManager.dispose();
    chatController.dispose();
    scrollController.dispose();
    crossCache.dispose();
    super.dispose();
  }

  Future<User?> resolveUser(String id) => Future.value(switch (id) {
    'me' => _currentUser,
    'agent' => _agent,
    _ => null,
  });

  bool isAgentMessage(String authorId) => authorId == _agent.id;

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    final isAbove = (pos.maxScrollExtent - pos.pixels) >= kScrollThreshold;

    if (isAbove == _userScrolledUp) return;

    _userScrolledUp = isAbove;
    notifyListeners();

    if (isAbove) {
      scrollController.lock();
    } else {
      scrollController.unlock();
      _doScrollToBottom();
    }
  }

  void _doScrollToBottom() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    if (pos.maxScrollExtent <= pos.pixels) return;

    scrollController
        .forceAnimateTo(
          pos.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        )
        .then((_) => scrollController.lock());
  }

  void onChunkRendered() {
    if (_userScrolledUp) return;
    _doScrollToBottom();
  }

  void stopStream() {
    if (_currentStreamSubscription == null || _currentStreamId == null) return;
    _currentStreamSubscription!.cancel();
    _currentStreamSubscription = null;
    _isStreaming = false;
    notifyListeners();
    streamManager.errorStream(_currentStreamId!, 'Stream stopped by user');
    _currentStreamId = null;
  }

  Future<void> sendMessage(String text) async {
    await chatController.insertMessage(
      TextMessage(
        id: _uuid.v4(),
        authorId: _currentUser.id,
        createdAt: DateTime.now().toUtc(),
        text: text,
        metadata: isOnlyEmoji(text) ? {'isOnlyEmoji': true} : null,
      ),
    );

    if (!_userScrolledUp) _doScrollToBottom();

    _sendContent(Content.text(text));
  }

  Future<void> pickAndSendImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    await crossCache.downloadAndSave(image.path);

    await chatController.insertMessage(
      ImageMessage(
        id: _uuid.v4(),
        authorId: _currentUser.id,
        createdAt: DateTime.now().toUtc(),
        source: image.path,
      ),
    );

    final bytes = await crossCache.get(image.path);
    _sendContent(Content.data('image/jpeg', bytes));
  }

  void _sendContent(Content content) async {
    final streamId = _uuid.v4();
    _currentStreamId = streamId;
    TextStreamMessage? streamMessage;
    var messageInserted = false;

    _isStreaming = true;
    notifyListeners();

    Future<void> insertAgentMessage() async {
      if (messageInserted) return;
      messageInserted = true;
      streamMessage = TextStreamMessage(
        id: streamId,
        authorId: _agent.id,
        createdAt: DateTime.now().toUtc(),
        streamId: streamId,
      );
      await chatController.insertMessage(streamMessage!);
      streamManager.startStream(streamId, streamMessage!);
    }

    Future<void> onError(dynamic error) async {
      debugPrint('Generation error for $streamId: $error');
      if (streamMessage != null) {
        await streamManager.errorStream(streamId, error);
      }
      _isStreaming = false;
      notifyListeners();
      _currentStreamSubscription = null;
      _currentStreamId = null;
    }

    try {
      _currentStreamSubscription = _chatSession
          .sendMessageStream(content)
          .listen(
            (chunk) async {
              final text = chunk.text;
              if (text == null || text.isEmpty) return;

              if (!messageInserted) await insertAgentMessage();
              if (streamMessage == null) return;

              streamManager.addChunk(streamId, text);
              if (!_userScrolledUp) _doScrollToBottom();
            },
            onDone: () async {
              if (streamMessage != null)
                await streamManager.completeStream(streamId);
              _isStreaming = false;
              notifyListeners();
              if (!_userScrolledUp) _doScrollToBottom();
              _currentStreamSubscription = null;
              _currentStreamId = null;
            },
            onError: onError,
          );
    } catch (error) {
      await onError(error);
    }
  }
}
