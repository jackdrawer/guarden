import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../constants/brand_database.dart';
import '../../i18n/strings.g.dart';
import '../../models/bank_account.dart';
import '../../providers/bank_account_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/crypto_service.dart';
import '../../services/secure_storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';
import '../../widgets/neumorphic/neumorphic_input.dart';
import '../../widgets/neumorphic/neumorphic_typeahead.dart';
import '../../widgets/password_generator_dialog.dart';
import '../../widgets/category/category_widgets.dart';

class BankAccountFormScreen extends ConsumerStatefulWidget {
  final String? accountId;

  const BankAccountFormScreen({super.key, this.accountId});

  @override
  ConsumerState<BankAccountFormScreen> createState() =>
      _BankAccountFormScreenState();
}

class _BankAccountFormScreenState extends ConsumerState<BankAccountFormScreen> {
  final _bankNameController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notesController = TextEditingController();

  int _selectedPeriod = 6;
  final List<int> _periods = [1, 3, 6, 9, 12];
  bool _obscurePassword = true;
  bool _travelProtected = false;
  String _selectedLogoUrl = '';
  bool _isLoadingExisting = false;
  bool _isSaving = false;
  String? _selectedCategory;

  bool get _isEditMode => widget.accountId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      Future.microtask(_loadExistingValues);
    }
  }

  @override
  void dispose() {
    _bankNameController.dispose();
    _accountNameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  BankAccount? _findAccountById(String id) {
    final accounts = ref.read(bankAccountProvider).valueOrNull ?? [];
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  Future<void> _loadExistingValues() async {
    final accountId = widget.accountId;
    if (accountId == null) return;

    setState(() => _isLoadingExisting = true);

    final account = _findAccountById(accountId);
    if (account == null) {
      if (mounted) {
        setState(() => _isLoadingExisting = false);
      }
      return;
    }

    _bankNameController.text = account.bankName;
    _accountNameController.text = account.accountName;
    _selectedLogoUrl = account.url;
    _selectedPeriod = account.periodMonths;
    _selectedCategory = account.category;
    final settings = ref.read(settingsProvider).valueOrNull;
    _travelProtected =
        settings?.travelProtectedIds.contains(account.id) ?? false;

    try {
      final base64Key = await ref
          .read(secureStorageProvider)
          .getEncryptionKey();
      if (base64Key != null) {
        if (account.encryptedPassword.isNotEmpty) {
          _passwordController.text = await ref
              .read(cryptoProvider)
              .decryptWithBase64Key(account.encryptedPassword, base64Key);
        }
        if (account.encryptedNotes.isNotEmpty) {
          _notesController.text = await ref
              .read(cryptoProvider)
              .decryptWithBase64Key(account.encryptedNotes, base64Key);
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoadingExisting = false);
    }
  }

  Future<void> _saveFast() async {
    if (_isSaving) {
      return;
    }

    final cryptoService = ref.read(cryptoProvider);
    final secureStorage = ref.read(secureStorageProvider);
    final bankName = _bankNameController.text.trim();
    final password = _passwordController.text;

    if (bankName.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.bank_form.required_fields)));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final base64Key = await secureStorage.getEncryptionKey();
      if (base64Key == null) {
        throw Exception(t.settings.errors.storage_access_failed);
      }

      final encPassword = await cryptoService.encryptWithBase64Key(
        password,
        base64Key,
      );
      final encNotes = _notesController.text.isNotEmpty
          ? await cryptoService.encryptWithBase64Key(
              _notesController.text,
              base64Key,
            )
          : '';

      final existing = _isEditMode ? _findAccountById(widget.accountId!) : null;
      if (_isEditMode && existing == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.general.record_to_edit_not_found)),
          );
        }
        return;
      }

      final itemId = existing?.id ?? const Uuid().v4();
      final updatedAccount = BankAccount(
        id: itemId,
        bankName: bankName,
        url: _selectedLogoUrl.isNotEmpty ? _selectedLogoUrl : bankName,
        accountName: _accountNameController.text.trim(),
        encryptedPassword: encPassword,
        encryptedNotes: encNotes,
        periodMonths: _selectedPeriod,
        lastChangedAt: DateTime.now(),
        createdAt: existing?.createdAt ?? DateTime.now(),
        category: _selectedCategory ?? '',
      );

      if (_isEditMode) {
        ref
            .read(bankAccountProvider.notifier)
            .updateBankAccount(updatedAccount);
      } else {
        ref.read(bankAccountProvider.notifier).addBankAccount(updatedAccount);
      }

      await ref
          .read(settingsProvider.notifier)
          .toggleTravelProtection(itemId, _travelProtected);

      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.bank_form.save_failed)));
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
          _isEditMode ? t.bank_form.title_edit : t.bank_form.title_add,
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
                          label: t.bank_form.bank_name_label,
                          controller: _bankNameController,
                          hintText: t.bank_form.bank_name_hint,
                          suggestionsCallback: BrandDatabase.getBankSuggestions,
                          onSuggestionSelected: (BrandData suggestion) {
                            _bankNameController.text = suggestion.name;
                            _selectedLogoUrl = suggestion.logoUrl;
                          },
                        ),
                        const SizedBox(height: 16),
                        NeumorphicInput(
                          label: t.bank_form.username_national_id_label,
                          controller: _accountNameController,
                          hintText: t.bank_form.username_national_id_hint,
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
                        Text(
                          t.bank_form.password_rotation_period,
                          style: TextStyle(
                            color: AppColors.of(context).textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _periods.map((p) {
                            final isSelected = _selectedPeriod == p;
                            return InkWell(
                              onTap: () => setState(() => _selectedPeriod = p),
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.of(context).background,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isSelected
                                      ? Border.all(
                                          color: AppColors.of(
                                            context,
                                          ).primaryAccent,
                                          width: 2,
                                        )
                                      : Border.all(
                                          color: AppColors.of(
                                            context,
                                          ).background,
                                          width: 2,
                                        ),
                                  boxShadow: isSelected
                                      ? null
                                      : AppColors.of(context).neumorphicShadows,
                                ),
                                child: Text(
                                  t.bank_form.period_months(count: p),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? AppColors.of(context).primaryAccent
                                        : AppColors.of(context).textSecondary,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        NeumorphicInput(
                          label: t.general.notes,
                          controller: _notesController,
                          hintText: t.bank_form.notes_hint,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          t.general.category,
                          style: TextStyle(
                            color: AppColors.of(context).textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CategorySelector(
                          selected: _selectedCategory,
                          onChanged: (category) {
                            setState(() => _selectedCategory = category);
                          },
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
