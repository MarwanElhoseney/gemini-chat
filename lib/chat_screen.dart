import 'package:gemini_chat/composer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' hide Composer;
import 'package:flyer_chat_image_message/flyer_chat_image_message.dart';
import 'package:flyer_chat_text_message/flyer_chat_text_message.dart';
import 'package:flyer_chat_text_stream_message/flyer_chat_text_stream_message.dart';
import 'package:provider/provider.dart';

import 'chat_view_model.dart';
import 'gemini_stream_manager.dart';

class ChatScreen extends StatelessWidget {
  final String geminiApiKey;

  const ChatScreen({super.key, required this.geminiApiKey});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(geminiApiKey),
      child: const _ChatScreenBody(),
    );
  }
}

class _ChatScreenBody extends StatelessWidget {
  const _ChatScreenBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.read<ChatViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Gemini Chat')),
      body: ChangeNotifierProvider.value(
        value: vm.streamManager,
        child: Chat(
          builders: Builders(
            chatAnimatedListBuilder: (context, itemBuilder) => ChatAnimatedList(
              scrollController: vm.scrollController,
              itemBuilder: itemBuilder,
            ),
            composerBuilder: (_) => _ComposerBridge(),
            imageMessageBuilder:
                (context, message, index, {required isSentByMe, groupStatus}) =>
                    FlyerChatImageMessage(
                      message: message,
                      index: index,
                      showTime: false,
                      showStatus: false,
                    ),
            textMessageBuilder:
                (context, message, index, {required isSentByMe, groupStatus}) =>
                    FlyerChatTextMessage(
                      message: message,
                      index: index,
                      showTime: false,
                      showStatus: false,
                      receivedBackgroundColor: Colors.transparent,
                      padding: vm.isAgentMessage(message.authorId)
                          ? EdgeInsets.zero
                          : const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                    ),
            textStreamMessageBuilder:
                (context, message, index, {required isSentByMe, groupStatus}) {
                  final streamState = context
                      .watch<GeminiStreamManager>()
                      .getState(message.streamId);

                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => vm.onChunkRendered(),
                  );

                  return FlyerChatTextStreamMessage(
                    message: message,
                    index: index,
                    streamState: streamState,
                    chunkAnimationDuration: kChunkAnimationDuration,
                    showTime: false,
                    showStatus: false,
                    receivedBackgroundColor: Colors.transparent,
                    padding: vm.isAgentMessage(message.authorId)
                        ? EdgeInsets.zero
                        : const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                  );
                },
          ),
          chatController: vm.chatController,
          crossCache: vm.crossCache,
          currentUserId: 'me',
          onAttachmentTap: vm.pickAndSendImage,
          onMessageSend: vm.sendMessage,
          resolveUser: vm.resolveUser,
          theme: ChatTheme.fromThemeData(theme),
        ),
      ),
    );
  }
}

class _ComposerBridge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isStreaming = context.select<ChatViewModel, bool>(
      (vm) => vm.isStreaming,
    );
    final vm = context.read<ChatViewModel>();

    return Composer(isStreaming: isStreaming, onStop: vm.stopStream);
  }
}
