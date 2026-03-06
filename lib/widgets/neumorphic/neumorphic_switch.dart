import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class NeumorphicSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final Color? activeColor;

  const NeumorphicSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.width = 56.0,
    this.height = 30.0,
    this.activeColor,
  });

  @override
  State<NeumorphicSwitch> createState() => _NeumorphicSwitchState();
}

class _NeumorphicSwitchState extends State<NeumorphicSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _toggleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _toggleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    if (widget.value) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(NeumorphicSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final trackColor = widget.value
        ? (widget.activeColor ?? colors.primaryAccent).withValues(alpha: 0.2)
        : colors.background;

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.height / 2),
              color: trackColor,
              boxShadow: widget.value
                  ? [
                      BoxShadow(
                        color: (widget.activeColor ?? colors.primaryAccent)
                            .withValues(alpha: 0.15),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : colors.neumorphicShadows,
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.lerp(
                    Alignment.centerLeft,
                    Alignment.centerRight,
                    _toggleAnimation.value,
                  )!,
                  child: Container(
                    width: widget.height - 8,
                    height: widget.height - 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.value
                          ? (widget.activeColor ?? colors.primaryAccent)
                          : colors.textSecondary.withValues(alpha: 0.3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
