import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../constants/brand_database.dart';
import '../../i18n/strings.g.dart';
import '../../models/subscription.dart';
import '../../providers/settings_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../services/crypto_service.dart';
import '../../services/secure_storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';
import '../../widgets/neumorphic/neumorphic_input.dart';
import '../../widgets/neumorphic/neumorphic_typeahead.dart';
import '../../widgets/password_generator_dialog.dart';
import '../../utils/currency_utils.dart';
import '../../widgets/category/category_widgets.dart';

class SubscriptionFormScreen extends ConsumerStatefulWidget {
  final String? subscriptionId;

  const SubscriptionFormScreen({super.key, this.subscriptionId});

  @override
  ConsumerState<SubscriptionFormScreen> createState() =>
      _SubscriptionFormScreenState();
}

class _SubscriptionFormScreenState
    extends ConsumerState<SubscriptionFormScreen> {
  final _serviceNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _costController = TextEditingController();

  bool _obscurePassword = true;
  bool _travelProtected = false;
  bool _isLoadingExisting = false;
  bool _isSaving = false;
  String _selectedLogoUrl = '';
  String? _selectedCurrency;
  String _billingCycle = 'monthly'; // 'monthly' or 'yearly'
  String? _selectedCategory;
  DateTime _nextBillingDate = DateTime.now().add(const Duration(days: 30));

  bool get _isEditMode => widget.subscriptionId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      Future.microtask(_loadExistingValues);
    } else {
      _selectedCurrency = CurrencyUtils.getDefaultCurrency();
    }
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Subscription? _findSubscriptionById(String id) {
    final subscriptions = ref.read(subscriptionProvider).valueOrNull ?? [];
    for (final item in subscriptions) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> _loadExistingValues() async {
    final subscriptionId = widget.subscriptionId;
    if (subscriptionId == null) return;

    setState(() => _isLoadingExisting = true);

    final existing = _findSubscriptionById(subscriptionId);
    if (existing == null) {
      if (mounted) {
        setState(() => _isLoadingExisting = false);
      }
      return;
    }

    _serviceNameController.text = existing.serviceName;
    _emailController.text = existing.emailOrUsername;
    _costController.text = existing.monthlyCost.toStringAsFixed(2);
    _selectedLogoUrl = existing.url;
    _selectedCurrency = existing.currency;
    _billingCycle = existing.billingCycle;
    _selectedCategory = existing.category;
    _nextBillingDate = existing.nextBillingDate;
    final settings = ref.read(settingsProvider).valueOrNull;
    _travelProtected =
        settings?.travelProtectedIds.contains(existing.id) ?? false;

    try {
      final base64Key = await ref
          .read(secureStorageProvider)
          .getEncryptionKey();
      if (base64Key != null && existing.encryptedPassword.isNotEmpty) {
        _passwordController.text = await ref
            .read(cryptoProvider)
            .decryptWithBase64Key(existing.encryptedPassword, base64Key);
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoadingExisting = false);
    }
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final initialDate = _nextBillingDate.isBefore(now) ? now : _nextBillingDate;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.of(context).primaryAccent,
              surface: AppColors.of(context).background,
              onSurface: AppColors.of(context).textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _nextBillingDate) {
      setState(() {
        _nextBillingDate = pickedDate;
      });
    }
  }

  Future<void> _saveFast() async {
    if (_isSaving) {
      return;
    }

    final cryptoService = ref.read(cryptoProvider);
    final secureStorage = ref.read(secureStorageProvider);
    final serviceName = _serviceNameController.text.trim();
    final password = _passwordController.text;
    final costText = _costController.text.trim();

    if (serviceName.isEmpty || costText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.subscription_form.required_fields)),
      );
      return;
    }

    final cost = double.tryParse(costText.replaceAll(',', '.')) ?? 0.0;

    if (cost > 10000000) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.subscription_form.save_failed)));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final base64Key = await secureStorage.getEncryptionKey();
      if (base64Key == null) {
        throw Exception(t.settings.errors.storage_access_failed);
      }

      final encPassword = password.isNotEmpty
          ? await cryptoService.encryptWithBase64Key(password, base64Key)
          : '';

      final existing = _isEditMode
          ? _findSubscriptionById(widget.subscriptionId!)
          : null;
      if (_isEditMode && existing == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.general.record_to_edit_not_found)),
          );
        }
        return;
      }

      final itemId = existing?.id ?? const Uuid().v4();
      final updatedSub = Subscription(
        id: itemId,
        serviceName: serviceName,
        url: _selectedLogoUrl.isNotEmpty ? _selectedLogoUrl : serviceName,
        emailOrUsername: _emailController.text.trim(),
        encryptedPassword: encPassword,
        monthlyCost: cost,
        currency: _selectedCurrency ?? 'TRY',
        nextBillingDate: _nextBillingDate,
        createdAt: existing?.createdAt ?? DateTime.now(),
        billingCycle: _billingCycle,
        category: _selectedCategory ?? '',
      );

      if (_isEditMode) {
        ref.read(subscriptionProvider.notifier).updateSubscription(updatedSub);
      } else {
        ref.read(subscriptionProvider.notifier).addSubscription(updatedSub);
      }

      await ref
          .read(settingsProvider.notifier)
          .toggleTravelProtection(itemId, _travelProtected);

      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.subscription_form.save_failed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: AppColors.of(context).textPrimary),
        title: Text(
          _isEditMode
              ? t.subscription_form.title_edit
              : t.subscription_form.title_add,
          style: TextStyle(
            color: AppColors.of(context).textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoadingExisting
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.of(context).primaryAccent,
              ),
            )
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        NeumorphicTypeAhead(
                          label: t.subscription_form.service_name_label,
                          controller: _serviceNameController,
                          hintText: t.subscription_form.service_name_hint,
                          suggestionsCallback:
                              BrandDatabase.getSubscriptionSuggestions,
                          onSuggestionSelected: (BrandData suggestion) {
                            _serviceNameController.text = suggestion.name;
                            _selectedLogoUrl = suggestion.logoUrl;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.subscription_form.currency_label,
                                    style: TextStyle(
                                      color: AppColors.of(context).textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.of(context).background,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: AppColors.of(
                                        context,
                                      ).neumorphicShadows,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedCurrency,
                                        isExpanded: true,
                                        dropdownColor: AppColors.of(
                                          context,
                                        ).background,
                                        items:
                                            CurrencyUtils.getCommonCurrencies()
                                                .map(
                                                  (c) => DropdownMenuItem(
                                                    value: c,
                                                    child: Text(
                                                      c,
                                                      style: TextStyle(
                                                        color: AppColors.of(
                                                          context,
                                                        ).textPrimary,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                        onChanged: (val) {
                                          if (val != null) {
                                            setState(
                                              () => _selectedCurrency = val,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: NeumorphicInput(
                                label: t.subscription_form.monthly_cost_label,
                                controller: _costController,
                                hintText: t.subscription_form.monthly_cost_hint,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*[.,]?\d{0,2}'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.subscription_form.billing_cycle_label,
                          style: TextStyle(
                            color: AppColors.of(context).textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _billingCycle = 'monthly'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _billingCycle == 'monthly'
                                        ? AppColors.of(
                                            context,
                                          ).primaryAccent.withValues(alpha: 0.1)
                                        : AppColors.of(context).background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _billingCycle == 'monthly'
                                          ? AppColors.of(context).primaryAccent
                                          : AppColors.of(
                                              context,
                                            ).shadowDark.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      t.subscription_form.monthly,
                                      style: TextStyle(
                                        color: _billingCycle == 'monthly'
                                            ? AppColors.of(
                                                context,
                                              ).primaryAccent
                                            : AppColors.of(
                                                context,
                                              ).textSecondary,
                                        fontWeight: _billingCycle == 'monthly'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _billingCycle = 'yearly'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _billingCycle == 'yearly'
                                        ? AppColors.of(
                                            context,
                                          ).primaryAccent.withValues(alpha: 0.1)
                                        : AppColors.of(context).background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _billingCycle == 'yearly'
                                          ? AppColors.of(context).primaryAccent
                                          : AppColors.of(
                                              context,
                                            ).shadowDark.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      t.subscription_form.yearly,
                                      style: TextStyle(
                                        color: _billingCycle == 'yearly'
                                            ? AppColors.of(
                                                context,
                                              ).primaryAccent
                                            : AppColors.of(
                                                context,
                                              ).textSecondary,
                                        fontWeight: _billingCycle == 'yearly'
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.general.category,
                          style: TextStyle(
                            color: AppColors.of(context).textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CategorySelector(
                          selected: _selectedCategory,
                          onChanged: (cat) =>
                              setState(() => _selectedCategory = cat),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.subscription_form.next_billing_date,
                          style: TextStyle(
                            color: AppColors.of(context).textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.of(context).background,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppColors.of(
                                context,
                              ).neumorphicShadows,
                              border: Border.all(
                                color: AppColors.of(
                                  context,
                                ).shadowDark.withValues(alpha: 0.1),
                                width: 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${_nextBillingDate.day}/${_nextBillingDate.month}/${_nextBillingDate.year}',
                                  style: TextStyle(
                                    color: AppColors.of(context).textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_month,
                                  color: AppColors.of(context).primaryAccent,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Divider(color: AppColors.of(context).shadowDark),
                        const SizedBox(height: 16),
                        NeumorphicInput(
                          label: t.general.username_email,
                          controller: _emailController,
                          hintText: t.subscription_form.email_hint,
                        ),
                        const SizedBox(height: 16),
                        NeumorphicInput(
                          label: t.general.password,
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: t.general.generate_password,
                                icon: Icon(
                                  Icons.generating_tokens,
                                  color: AppColors.of(context).primaryAccent,
                                ),
                                onPressed: () async {
                                  final generated = await showPasswordGenerator(
                                    context,
                                  );
                                  if (generated != null) {
                                    setState(() {
                                      _passwordController.text = generated;
                                      _obscurePassword = false;
                                    });
                                  }
                                },
                              ),
                              IconButton(
                                tooltip: _obscurePassword
                                    ? t.general.show_password
                                    : t.general.hide_password,
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppColors.of(context).textSecondary,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.of(context).background,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.of(context).neumorphicShadows,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.flight_takeoff,
                                color: AppColors.of(context).textSecondary,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  t.general.hide_in_travel_mode,
                                  style: TextStyle(
                                    color: AppColors.of(context).textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _travelProtected,
                                activeColor: AppColors.of(
                                  context,
                                ).primaryAccent,
                                onChanged: (val) =>
                                    setState(() => _travelProtected = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        NeumorphicButton(
                          onPressed: _isSaving ? null : _saveFast,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (_isSaving) ...[
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.of(context).primaryAccent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Text(
                                _isEditMode ? t.general.update : t.general.save,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.of(context).primaryAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
