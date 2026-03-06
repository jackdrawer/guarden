import 'package:flutter/material.dart';
import '../../i18n/strings.g.dart';
import '../../theme/app_colors.dart';

/// Predefined category constants. Add new strings here to extend globally.
class AppCategories {
  static const String work = 'Work';
  static const String personal = 'Personal';
  static const String finance = 'Finance';
  static const String social = 'Social';
  static const String entertainment = 'Entertainment';

  /// All built-in categories. Dynamically driven — adding a string here
  /// automatically populates UI selectors across the app.
  static const List<String> all = [
    work,
    personal,
    finance,
    social,
    entertainment,
  ];

  static String localizedLabel(String category) {
    switch (category) {
      case work:
        return t.general.categories.work;
      case personal:
        return t.general.categories.personal;
      case finance:
        return t.general.categories.finance;
      case social:
        return t.general.categories.social;
      case entertainment:
        return t.general.categories.entertainment;
      default:
        return category;
    }
  }
}

/// A chip-row selector for category assignment.
/// Works for Subscription, BankAccount, and WebPassword.
class CategorySelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const CategorySelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        // "None" chip to clear
        ChoiceChip(
          label: const Text('—'),
          selected: selected == null || selected!.isEmpty,
          onSelected: (_) => onChanged(null),
          selectedColor: colors.primaryAccent.withAlpha(50),
          labelStyle: TextStyle(
            color: selected == null || selected!.isEmpty
                ? colors.primaryAccent
                : colors.textSecondary,
            fontSize: 13,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: selected == null || selected!.isEmpty
                  ? colors.primaryAccent
                  : colors.textSecondary.withAlpha(80),
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
        ...AppCategories.all.map(
          (cat) => ChoiceChip(
            label: Text(AppCategories.localizedLabel(cat)),
            selected: selected == cat,
            onSelected: (picked) => onChanged(picked ? cat : null),
            selectedColor: colors.primaryAccent.withAlpha(50),
            labelStyle: TextStyle(
              color: selected == cat
                  ? colors.primaryAccent
                  : colors.textSecondary,
              fontSize: 13,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: selected == cat
                    ? colors.primaryAccent
                    : colors.textSecondary.withAlpha(80),
              ),
            ),
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}

/// Filter chips for list screens — uses same category list.
class CategoryFilterChips extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const CategoryFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(t.general.categories.all),
              selected: selected == null || selected!.isEmpty,
              onSelected: (_) => onChanged(null),
              selectedColor: colors.primaryAccent.withAlpha(50),
              labelStyle: TextStyle(
                color: selected == null || selected!.isEmpty
                    ? colors.primaryAccent
                    : colors.textSecondary,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected == null || selected!.isEmpty
                      ? colors.primaryAccent
                      : colors.textSecondary.withAlpha(80),
                ),
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
          ...AppCategories.all.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(AppCategories.localizedLabel(cat)),
                selected: selected == cat,
                onSelected: (picked) => onChanged(picked ? cat : null),
                selectedColor: colors.primaryAccent.withAlpha(50),
                labelStyle: TextStyle(
                  color: selected == cat
                      ? colors.primaryAccent
                      : colors.textSecondary,
                  fontSize: 13,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: selected == cat
                        ? colors.primaryAccent
                        : colors.textSecondary.withAlpha(80),
                  ),
                ),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
