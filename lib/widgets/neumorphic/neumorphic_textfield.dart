import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class NeumorphicTextField extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final String? semanticLabel;
  final FormFieldValidator<String>? validator;

  const NeumorphicTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.focusNode,
    this.semanticLabel,
    this.validator,
  });

  @override
  State<NeumorphicTextField> createState() => _NeumorphicTextFieldState();
}

class _NeumorphicTextFieldState extends State<NeumorphicTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(NeumorphicTextField oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: widget.semanticLabel ?? widget.hintText,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.of(context).background,
          borderRadius: BorderRadius.circular(16),
          // İçe çökük (Inset) hissi vermek için gölge ve bordür kombinasyonu
          boxShadow: [
            BoxShadow(
              color: AppColors.of(context).shadowDark.withValues(alpha: 0.5),
              offset: Offset(2, 2),
              blurRadius: 4,
            ),
            BoxShadow(
              color: AppColors.of(context).shadowLight,
              offset: Offset(-2, -2),
              blurRadius: 4,
            ),
          ],
          border: Border.all(
            color: _isFocused
                ? AppColors.of(context).primaryAccent.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          onChanged: widget.onChanged,
          validator: widget.validator,
          style: TextStyle(
            color: AppColors.of(context).textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: AppColors.of(context).textSecondary),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: AppColors.of(context).primaryAccent,
                  )
                : null,
            suffixIcon: widget.suffixIcon,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ),
    );
  }
}
