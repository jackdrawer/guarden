import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../../i18n/strings.g.dart';
import '../../theme/app_colors.dart';
import '../../constants/brand_database.dart';
import '../../services/logo_service.dart';

class NeumorphicTypeAhead extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final List<BrandData> Function(String) suggestionsCallback;
  final void Function(BrandData) onSuggestionSelected;

  const NeumorphicTypeAhead({
    super.key,
    required this.label,
    required this.controller,
    required this.suggestionsCallback,
    required this.onSuggestionSelected,
    this.hintText,
    this.focusNode,
    this.suffixIcon,
    this.validator,
  });

  @override
  State<NeumorphicTypeAhead> createState() => _NeumorphicTypeAheadState();
}

class _NeumorphicTypeAheadState extends State<NeumorphicTypeAhead> {
  final LogoService _logoService = LogoService();
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(NeumorphicTypeAhead oldWidget) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: AppColors.of(context).textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.of(context).background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.of(context).shadowDark.withValues(alpha: 0.2),
                offset: Offset(2, 2),
                blurRadius: 5,
              ),
              BoxShadow(
                color: AppColors.of(context).shadowLight,
                offset: Offset(-2, -2),
                blurRadius: 5,
              ),
            ],
            border: Border.all(
              color: _isFocused
                  ? AppColors.of(context).primaryAccent.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: TypeAheadField<BrandData>(
            controller: widget.controller,
            focusNode: _focusNode,
            builder: (context, controller, focusNode) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                validator: widget.validator,
                style: TextStyle(color: AppColors.of(context).textPrimary),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: AppColors.of(
                      context,
                    ).textSecondary.withValues(alpha: 0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  suffixIcon: widget.suffixIcon,
                ),
              );
            },
            suggestionsCallback: widget.suggestionsCallback,
            itemBuilder: (context, BrandData suggestion) {
              return ListTile(
                leading: SizedBox(
                  width: 36,
                  height: 36,
                  child: _logoService.getLogoWidget(
                    suggestion.logoUrl,
                    size: 36,
                  ),
                ),
                title: Text(
                  suggestion.name,
                  style: TextStyle(
                    color: AppColors.of(context).textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                tileColor: AppColors.of(context).background,
              );
            },
            onSelected: widget.onSuggestionSelected,
            decorationBuilder: (context, child) {
              return Material(
                type: MaterialType.card,
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: AppColors.of(context).background,
                child: child,
              );
            },
            emptyBuilder: (context) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  t.general.manual_entry_fallback,
                  style: TextStyle(
                    color: AppColors.of(
                      context,
                    ).textSecondary.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
