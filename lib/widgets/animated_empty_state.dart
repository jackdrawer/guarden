import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import 'lottie_animation_widget.dart';
import 'neumorphic/neumorphic_button.dart';

class AnimatedEmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AnimatedEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _fadeAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            child: const LottieAnimationWidget(
              animation: GuardenAnimation.emptyStateVault,
              size: 140,
            ),
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.of(
                        context,
                      ).primaryAccent.withValues(alpha: 0.1),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.of(
                            context,
                          ).primaryAccent.withValues(alpha: 0.2),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              widget.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.of(context).textSecondary,
                height: 1.4,
              ),
            ),
          ),
          if (widget.actionLabel != null && widget.onAction != null) ...[
            const SizedBox(height: 26),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 220, maxWidth: 260),
              child: NeumorphicButton(
                onPressed: widget.onAction!,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.icon,
                      size: 18,
                      color: AppColors.of(context).primaryAccent,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        widget.actionLabel!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.of(context).primaryAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
