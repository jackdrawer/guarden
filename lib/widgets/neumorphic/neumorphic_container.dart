import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final String? semanticLabel;
  final bool isGlass;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(20.0),
    this.margin = EdgeInsets.zero,
    this.semanticLabel,
    this.isGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget container = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: isGlass
            ? AppColors.of(context).background.withValues(alpha: 0.4)
            : AppColors.of(context).background,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isGlass ? [] : AppColors.of(context).neumorphicShadows,
        border: isGlass
            ? Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5)
            : null,
      ),
      child: child,
    );

    if (isGlass) {
      container = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
          child: container,
        ),
      );
    }

    return RepaintBoundary(
      child: Semantics(container: true, label: semanticLabel, child: container),
    );
  }
}
