import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLifecycleProvider = Provider<AppLifecycleService>((ref) {
  return AppLifecycleService(ref);
});

final isLockedProvider = StateProvider<bool>((ref) => false);

/// Provider to track if user is authenticated (used to only lock when authenticated)
final isUserAuthenticatedProvider = StateProvider<bool>((ref) => false);

class AppLifecycleService extends WidgetsBindingObserver {
  final Ref _ref;
  Timer? _lockTimer;
  Timer? _idleTimer;
  DateTime? _lastInteraction;
  static const int lockTimeoutSeconds = 60;
  static const int idleCheckIntervalMs = 1000; // Check every second

  AppLifecycleService(this._ref) {
    WidgetsBinding.instance.addObserver(this);
    _startIdleDetection();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lockTimer?.cancel();
    _idleTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        // Phone screen locked or app going to background - lock immediately
        _lockImmediately();
        break;
      case AppLifecycleState.paused:
        // App in background - start timer for safety
        _startLockTimer();
        break;
      case AppLifecycleState.resumed:
        // App back in foreground - cancel all lock timers
        _cancelLockTimer();
        _resetIdleTimer();
        break;
      case AppLifecycleState.hidden:
        // App hidden (e.g., app switcher) - lock immediately
        _lockImmediately();
        break;
      case AppLifecycleState.detached:
        // App detached - clean up
        _lockTimer?.cancel();
        _idleTimer?.cancel();
        break;
    }
  }

  /// Called when user interacts with the app - resets idle timer
  void onUserInteraction() {
    _lastInteraction = DateTime.now();
    // If locked, don't reset (user needs to unlock first)
    if (_ref.read(isLockedProvider)) {
      return;
    }
  }

  /// Starts the in-app idle detection timer
  void _startIdleDetection() {
    _lastInteraction = DateTime.now();
    _idleTimer?.cancel();
    _idleTimer = Timer.periodic(
      const Duration(milliseconds: idleCheckIntervalMs),
      (_) => _checkIdleTimeout(),
    );
  }

  /// Checks if user has been idle for too long
  void _checkIdleTimeout() {
    if (_lastInteraction == null) return;

    // Only lock if user is authenticated
    final isAuthenticated = _ref.read(isUserAuthenticatedProvider);
    if (!isAuthenticated) return;

    // Don't re-lock if already locked
    if (_ref.read(isLockedProvider)) return;

    final idleDuration = DateTime.now().difference(_lastInteraction!);
    if (idleDuration.inSeconds >= lockTimeoutSeconds) {
      _lockApp();
    }
  }

  /// Resets the idle timer on user interaction
  void _resetIdleTimer() {
    _lastInteraction = DateTime.now();
  }

  /// Locks the app immediately
  void _lockImmediately() {
    // Only lock if user is authenticated
    final isAuthenticated = _ref.read(isUserAuthenticatedProvider);
    if (!isAuthenticated) return;

    _lockApp();
  }

  /// Locks the app
  void _lockApp() {
    try {
      _ref.read(isLockedProvider.notifier).state = true;
      _cancelLockTimer();
    } catch (e) {
      debugPrint('Error locking app: $e');
    }
  }

  /// Unlocks the app - call this after successful authentication
  void unlockApp() {
    _ref.read(isLockedProvider.notifier).state = false;
    _resetIdleTimer();
  }

  void _startLockTimer() {
    try {
      // Only start timer if user is authenticated
      final isAuthenticated = _ref.read(isUserAuthenticatedProvider);
      if (!isAuthenticated) return;

      // Don't start if already locked
      if (_ref.read(isLockedProvider)) return;

      _lockTimer?.cancel();
      _lockTimer = Timer(const Duration(seconds: lockTimeoutSeconds), () {
        _lockApp();
      });
    } catch (e) {
      debugPrint('Lifecycle lock timer error: $e');
    }
  }

  void _cancelLockTimer() {
    try {
      _lockTimer?.cancel();
      _lockTimer = null;
    } catch (e) {
      debugPrint('Lifecycle timer cancel error: $e');
    }
  }
}

/// Widget that wraps the entire app to track user interactions
class AppLockWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AppLockWrapper({super.key, required this.child});

  @override
  ConsumerState<AppLockWrapper> createState() => _AppLockWrapperState();
}

class _AppLockWrapperState extends ConsumerState<AppLockWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize the lifecycle service
    ref.read(appLifecycleProvider);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _onInteraction,
      onTapDown: (_) => _onInteraction(),
      // onScale is a superset of pan - don't use both together (Flutter assertion)
      onScaleStart: (_) => _onInteraction(),
      onScaleUpdate: (_) => _onInteraction(),
      onLongPressStart: (_) => _onInteraction(),
      onLongPressMoveUpdate: (_) => _onInteraction(),
      child: widget.child,
    );
  }

  void _onInteraction() {
    ref.read(appLifecycleProvider).onUserInteraction();
  }
}
