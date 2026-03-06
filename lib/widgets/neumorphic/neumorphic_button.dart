import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double borderRadius;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final bool isFlat;
  final String? semanticLabel;
  final FocusNode? focusNode;

  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
    this.margin = EdgeInsets.zero,
    this.isFlat = false,
    this.semanticLabel,
    this.focusNode,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;
  bool _isHovered = false;
  bool _isFocused = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(NeumorphicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChange);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChange);
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _handleTapDown() {
    HapticFeedback.lightImpact();
    setState(() => _isPressed = true);
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    widget.onPressed();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Semantics(
      button: true,
      label: widget.semanticLabel,
      enabled: true,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        onShowHoverHighlight: (v) => setState(() => _isHovered = v),
        onShowFocusHighlight: (v) => setState(() => _isFocused = v),
        actions: {
          ActivateIntent: CallbackAction<Intent>(
            onInvoke: (_) {
              widget.onPressed();
              return null;
            },
          ),
        },
        child: GestureDetector(
          onTapDown: (_) => _handleTapDown(),
          onTapUp: (_) => _handleTapUp(),
          onTapCancel: _handleTapCancel,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: widget.margin,
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: _isPressed || widget.isFlat
                  ? null
                  : colors.neumorphicShadows,
              border: Border.all(
                color: _isFocused || _isHovered
                    ? colors.primaryAccent.withValues(alpha: 0.5)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Stack(
                children: [
                  if (_isPressed)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            widget.borderRadius,
                          ),
                        ),
                        child: CustomPaint(
                          painter: _InnerShadowPainter(
                            shadowColor: colors.shadowDark.withValues(
                              alpha: 0.5,
                            ),
                            lightShadowColor: colors.shadowLight.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: widget.borderRadius,
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: widget.padding,
                    child: Center(child: widget.child),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InnerShadowPainter extends CustomPainter {
  final Color shadowColor;
  final Color lightShadowColor;
  final double borderRadius;

  _InnerShadowPainter({
    required this.shadowColor,
    required this.lightShadowColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Dark Inner Shadow (Top-Left)
    final darkPaint = Paint()
      ..color = shadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final darkPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(rRect)
      ..addRect(Rect.fromLTWH(-20, -20, size.width + 40, size.height + 40));

    canvas.save();
    canvas.clipRRect(rRect);
    canvas.translate(4, 4);
    canvas.drawPath(darkPath, darkPaint);
    canvas.restore();

    // Light Inner Shadow (Bottom-Right)
    final lightPaint = Paint()
      ..color = lightShadowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final lightPath = Path()
      ..fillType = PathFillType.evenOdd
      ..addRRect(rRect)
      ..addRect(Rect.fromLTWH(-20, -20, size.width + 40, size.height + 40));

    canvas.save();
    canvas.clipRRect(rRect);
    canvas.translate(-4, -4);
    canvas.drawPath(lightPath, lightPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
