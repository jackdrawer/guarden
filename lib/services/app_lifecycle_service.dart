import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLifecycleProvider = Provider<AppLifecycleService>((ref) {
  return AppLifecycleService(ref);
});

final isLockedProvider = StateProvider<bool>((ref) => false);

class AppLifecycleService extends WidgetsBindingObserver {
  final Ref _ref;
  Timer? _lockTimer;
  static const int lockTimeoutSeconds = 60;

  AppLifecycleService(this._ref) {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lockTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _startLockTimer();
    } else if (state == AppLifecycleState.resumed) {
      _cancelLockTimer();
    }
  }

  void _startLockTimer() {
    try {
      _lockTimer?.cancel();
      _lockTimer = Timer(const Duration(seconds: lockTimeoutSeconds), () {
        _ref.read(isLockedProvider.notifier).state = true;
      });
    } catch (e) {
      debugPrint('Lifecycle lock timer error: $e');
    }
  }

  void _cancelLockTimer() {
    try {
      _lockTimer?.cancel();
    } catch (e) {
      debugPrint('Lifecycle timer cancel error: $e');
    }
  }
}
