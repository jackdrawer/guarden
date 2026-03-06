import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../i18n/strings.g.dart';
import '../../theme/app_colors.dart';
import '../../theme/motion_tokens.dart';

class NeumorphicBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const NeumorphicBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<NeumorphicBottomNav> createState() => _NeumorphicBottomNavState();
}

class _NeumorphicBottomNavState extends State<NeumorphicBottomNav>
    with TickerProviderStateMixin {
  late List<AnimationController> _bounceControllers;
  late List<Animation<double>> _bounceAnimations;

  static const List<IconData> _itemIcons = <IconData>[
    Icons.dashboard_rounded,
    Icons.account_balance_rounded,
    Icons.subscriptions_rounded,
    Icons.language_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _bounceControllers = List.generate(4, (i) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      );
    });
    _bounceAnimations = _bounceControllers.map((c) {
      return TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 1.25, end: 0.9), weight: 30),
        TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.08), weight: 25),
        TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 15),
      ]).animate(CurvedAnimation(parent: c, curve: Curves.easeOut));
    }).toList();
  }

  @override
  void didUpdateWidget(covariant NeumorphicBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _bounceControllers[widget.currentIndex].forward(from: 0);
    }
  }

  @override
  void dispose() {
    for (final c in _bounceControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Duration _duration(BuildContext context, Duration base) {
    final disable = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return disable ? Duration.zero : base;
  }

  @override
  Widget build(BuildContext context) {
    final indicatorDuration = _duration(context, MotionDurations.navIndicator);
    final itemDuration = _duration(context, MotionDurations.navItem);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.of(context).background,
        boxShadow: [
          BoxShadow(
            color: AppColors.of(context).shadowDark.withValues(alpha: 0.1),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SizedBox(
            height: 64,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final labels = <String>[
                  t.nav.dashboard,
                  t.nav.banks,
                  t.nav.subscriptions,
                  t.nav.web,
                ];
                final segmentWidth = constraints.maxWidth / labels.length;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: indicatorDuration,
                      curve: MotionCurves.standard,
                      left: segmentWidth * widget.currentIndex + 4,
                      top: 4,
                      width: segmentWidth - 8,
                      height: constraints.maxHeight - 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.of(context).background,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.of(
                                context,
                              ).shadowDark.withValues(alpha: 0.2),
                              offset: const Offset(2, 2),
                              blurRadius: 5,
                            ),
                            BoxShadow(
                              color: AppColors.of(context).shadowLight,
                              offset: const Offset(-2, -2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(labels.length, (index) {
                        return Expanded(
                          child: _buildNavItem(
                            context: context,
                            icon: _itemIcons[index],
                            label: labels[index],
                            index: index,
                            isSelected: widget.currentIndex == index,
                            duration: itemDuration,
                            bounceAnimation: _bounceAnimations[index],
                            bounceController: _bounceControllers[index],
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required Duration duration,
    required Animation<double> bounceAnimation,
    required AnimationController bounceController,
  }) {
    final activeColor = AppColors.of(context).primaryAccent;
    final idleColor = AppColors.of(context).textSecondary;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onTap(index);
        },
        child: Center(
          child: AnimatedSlide(
            duration: duration,
            curve: MotionCurves.standard,
            offset: isSelected ? const Offset(0, -0.03) : const Offset(0, 0.03),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: bounceAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected ? bounceAnimation.value : 1.0,
                      child: child,
                    );
                  },
                  child: Icon(
                    icon,
                    size: 24,
                    color: isSelected ? activeColor : idleColor,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: duration,
                  curve: MotionCurves.standard,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? activeColor : idleColor,
                  ),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
