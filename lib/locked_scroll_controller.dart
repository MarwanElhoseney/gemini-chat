import 'package:flutter/material.dart';

class LockedScrollController extends ScrollController {
  bool _locked = false;

  bool get isLocked => _locked;

  void lock() => _locked = true;

  void unlock() => _locked = false;

  Future<void> forceAnimateTo(
    double offset, {
    required Duration duration,
    required Curve curve,
  }) {
    _locked = false;
    final future = animateTo(offset, duration: duration, curve: curve);
    return future;
  }

  void forceJumpTo(double offset) {
    _locked = false;
    jumpTo(offset);
  }

  @override
  Future<void> animateTo(
    double offset, {
    required Duration duration,
    required Curve curve,
  }) {
    if (_locked) return Future.value();
    return super.animateTo(offset, duration: duration, curve: curve);
  }

  @override
  void jumpTo(double value) {
    if (_locked) return;
    super.jumpTo(value);
  }
}
