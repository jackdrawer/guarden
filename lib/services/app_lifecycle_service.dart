import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLifecycleProvider = Provider<AppLifecycleService>((ref) {
  final service = AppLifecycleService(ref);
  ref.onDispose(service.dispose);
  return service;
});

final isLockedProvider = StateProvider<bool>((ref) => false);

/// Provider to track if user is authenticated (used to only lock when authenticated)
final isUserAuthenticatedProvider = StateProvider<bool>((ref) => false);

class AppLifecycleService extends WidgetsBindingObserver {
  final Ref _ref;
  Timer? _lockTimer;
  Timer? _idleTimer;
  Timer? _lockGraceTimer;
  DateTime? _lastInteraction;
  static const int lockTimeoutSeconds = 60;
  static const int idleCheckIntervalMs = 1000; // Check every second
  static const int _lockGraceSeconds = 10; // Grace period before locking

  AppLifecycleService(this._ref) {
    WidgetsBinding.instance.addObserver(this);
    _startIdleDetection();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lockTimer?.cancel();
    _idleTimer?.cancel();
    _lockGraceTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.inactive:
        // Transient state: triggered by dialogs, account pickers,
        // biometric prompts, etc. Do NOT lock here.
        break;
      case AppLifecycleState.paused:
        // App truly went to background - start grace period then lock
        _startGracefulLock();
        break;
      case AppLifecycleState.resumed:
        // App back in foreground - cancel all lock/grace timers
        _cancelLockTimer();
        _cancelGraceTimer();
        _resetIdleTimer();
        break;
      case AppLifecycleState.hidden:
        // App switcher or picture-in-picture - start grace period
        _startGracefulLock();
        break;
      case AppLifecycleState.detached:
        // App detached - clean up
        _lockTimer?.cancel();
        _idleTimer?.cancel();
        _lockGraceTimer?.cancel();
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

  /// Starts a graceful lock with a grace period.
  /// If the user returns within [_lockGraceSeconds], the lock is cancelled.
  void _startGracefulLock() {
    // Only lock if user is authenticated
    final isAuthenticated = _ref.read(isUserAuthenticatedProvider);
    if (!isAuthenticated) return;

    // Don't start if already locked
    if (_ref.read(isLockedProvider)) return;

    // Don't start duplicate grace timers
    if (_lockGraceTimer?.isActive == true) return;

    _lockGraceTimer = Timer(const Duration(seconds: _lockGraceSeconds), () {
      _lockApp();
    });
  }

  /// Cancels the grace period timer
  void _cancelGraceTimer() {
    _lockGraceTimer?.cancel();
    _lockGraceTimer = null;
  }

  /// Locks the app
  void _lockApp() {
    try {
      _ref.read(isLockedProvider.notifier).state = true;
      _cancelLockTimer();
      _cancelGraceTimer();
    } catch (e) {
      debugPrint('Error locking app: $e');
    }
  }

  /// Unlocks the app - call this after successful authentication
  void unlockApp() {
    _ref.read(isLockedProvider.notifier).state = false;
    _resetIdleTimer();
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
