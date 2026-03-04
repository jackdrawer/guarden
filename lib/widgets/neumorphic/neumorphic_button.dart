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
            padding: widget.padding,
            decoration: BoxDecoration(
              color: AppColors.of(context).background,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: _isPressed || widget.isFlat
                  ? null
                  : AppColors.of(context).neumorphicShadows,
              border: Border.all(
                color: _isFocused || _isHovered
                    ? AppColors.of(context).primaryAccent.withValues(alpha: 0.5)
                    : (_isPressed
                          ? AppColors.of(
                              context,
                            ).shadowDark.withValues(alpha: 0.2)
                          : Colors.transparent),
                width: 1.5,
              ),
            ),
            child: Center(child: widget.child),
          ),
        ),
      ),
    );
  }
}
