import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/motion_tokens.dart';

class TabFabConfig {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const TabFabConfig({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
}

class AnimatedTabFab extends StatefulWidget {
  final bool visible;
  final TabFabConfig? config;

  const AnimatedTabFab({
    super.key,
    required this.visible,
    required this.config,
  });

  @override
  State<AnimatedTabFab> createState() => _AnimatedTabFabState();
}

class _AnimatedTabFabState extends State<AnimatedTabFab> {
  double _pressScale = 1.0;
  bool _isPressed = false;

  Duration _duration(BuildContext context, Duration base) {
    final disable = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return disable ? Duration.zero : base;
  }

  void _setPressed(bool pressed) {
    if (!mounted) return;
    setState(() {
      _isPressed = pressed;
      _pressScale = pressed ? 0.96 : 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final visible = widget.visible && config != null;

    return IgnorePointer(
      ignoring: !visible,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 16),
          child: AnimatedOpacity(
            duration: _duration(context, MotionDurations.fabVisibility),
            curve: MotionCurves.standard,
            opacity: visible ? 1.0 : 0.0,
            child: AnimatedSlide(
              duration: _duration(context, MotionDurations.fabVisibility),
              curve: MotionCurves.emphasis,
              offset: visible ? Offset.zero : const Offset(0, 0.25),
              child: AnimatedScale(
                duration: _duration(
                  context,
                  _isPressed
                      ? MotionDurations.fabPressDown
                      : MotionDurations.fabPressUp,
                ),
                curve: MotionCurves.standard,
                scale: visible ? _pressScale : 0.8,
                child: AnimatedSwitcher(
                  duration: _duration(context, MotionDurations.fabSwitch),
                  switchInCurve: MotionCurves.emphasis,
                  switchOutCurve: MotionCurves.standard,
                  transitionBuilder: (child, animation) {
                    final slide = Tween<Offset>(
                      begin: const Offset(0, 0.12),
                      end: Offset.zero,
                    ).animate(animation);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(position: slide, child: child),
                    );
                  },
                  child: config == null
                      ? const SizedBox.shrink()
                      : Listener(
                          key: ValueKey<String>(
                            '${config.icon.codePoint}:${config.tooltip}',
                          ),
                          onPointerDown: (_) => _setPressed(true),
                          onPointerUp: (_) => _setPressed(false),
                          onPointerCancel: (_) => _setPressed(false),
                          child: FloatingActionButton(
                            heroTag: 'shared_tab_fab',
                            tooltip: config.tooltip,
                            backgroundColor: AppColors.of(
                              context,
                            ).primaryAccent,
                            onPressed: () {
                              HapticFeedback.heavyImpact();
                              config.onPressed();
                            },
                            child: Icon(
                              config.icon,
                              color: AppColors.of(context).background,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
