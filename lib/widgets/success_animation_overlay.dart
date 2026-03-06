import 'package:flutter/material.dart';
import 'lottie_animation_widget.dart';
import '../theme/app_colors.dart';

/// Shows a brief animated success overlay with the shield animation.
/// Use after completing important actions like saving credentials or syncing.
Future<void> showSuccessAnimation(BuildContext context) async {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => _SuccessOverlay(onDismiss: () => entry.remove()),
  );

  overlay.insert(entry);
}

class _SuccessOverlay extends StatefulWidget {
  final VoidCallback onDismiss;

  const _SuccessOverlay({required this.onDismiss});

  @override
  State<_SuccessOverlay> createState() => _SuccessOverlayState();
}

class _SuccessOverlayState extends State<_SuccessOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.2, curve: Curves.easeIn),
      ),
    );
    _fadeOut = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) => widget.onDismiss());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = _controller.value < 0.7
            ? _fadeIn.value
            : _fadeOut.value;
        return IgnorePointer(
          child: Opacity(
            opacity: opacity,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.of(
                    context,
                  ).background.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: AppColors.of(context).neumorphicShadows,
                ),
                child: const LottieAnimationWidget(
                  animation: GuardenAnimation.successCelebration,
                  size: 160,
                  repeat: false,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
