import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../i18n/strings.g.dart';
import '../../models/web_password.dart';
import '../../providers/settings_provider.dart';
import '../../providers/web_password_provider.dart';
import '../../services/crypto_service.dart';
import '../../services/secure_storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/neumorphic/neumorphic_button.dart';
import '../../widgets/neumorphic/neumorphic_input.dart';
import '../../widgets/password_generator_dialog.dart';
import '../../widgets/category/category_widgets.dart';

class WebPasswordFormScreen extends ConsumerStatefulWidget {
  final String? webPasswordId;

  const WebPasswordFormScreen({super.key, this.webPasswordId});

  @override
  ConsumerState<WebPasswordFormScreen> createState() =>
      _WebPasswordFormScreenState();
}

class _WebPasswordFormScreenState extends ConsumerState<WebPasswordFormScreen> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _notesController = TextEditingController();

  bool _obscurePassword = true;
  bool _travelProtected = false;
  bool _isLoadingExisting = false;
  String? _selectedCategory;

  bool get _isEditMode => widget.webPasswordId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      Future.microtask(_loadExistingValues);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  WebPassword? _findWebPasswordById(String id) {
    final passwords = ref.read(webPasswordProvider).valueOrNull ?? [];
    for (final item in passwords) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> _loadExistingValues() async {
    final webPasswordId = widget.webPasswordId;
    if (webPasswordId == null) return;

    setState(() => _isLoadingExisting = true);

    final existing = _findWebPasswordById(webPasswordId);
    if (existing == null) {
      if (mounted) {
        setState(() => _isLoadingExisting = false);
      }
      return;
    }

    _titleController.text = existing.title;
    _urlController.text = existing.url;
    _usernameController.text = existing.username;
    _selectedCategory = existing.category;
    final settings = ref.read(settingsProvider).valueOrNull;
    _travelProtected =
        settings?.travelProtectedIds.contains(existing.id) ?? false;

    try {
      final base64Key = await ref
          .read(secureStorageProvider)
          .getEncryptionKey();
      if (base64Key != null) {
        if (existing.encryptedPassword.isNotEmpty) {
          _passwordController.text = await ref
              .read(cryptoProvider)
              .decryptWithBase64Key(existing.encryptedPassword, base64Key);
        }
        if (existing.encryptedNotes.isNotEmpty) {
          _notesController.text = await ref
              .read(cryptoProvider)
              .decryptWithBase64Key(existing.encryptedNotes, base64Key);
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoadingExisting = false);
    }
  }

  Future<void> _saveFast() async {
    final cryptoService = ref.read(cryptoProvider);
    final secureStorage = ref.read(secureStorageProvider);
    final title = _titleController.text.trim();
    final password = _passwordController.text;

    if (title.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.web_form.required_fields)));
      return;
    }

    try {
      final base64Key = await secureStorage.getEncryptionKey();
      if (base64Key == null) throw Exception('Encryption key not found.');

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

      final existing = _isEditMode
          ? _findWebPasswordById(widget.webPasswordId!)
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
      final updatedWebPassword = WebPassword(
        id: itemId,
        title: title,
        url: _urlController.text.trim(),
        username: _usernameController.text.trim(),
        encryptedPassword: encPassword,
        encryptedNotes: encNotes,
        createdAt: existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        category: _selectedCategory ?? '',
      );

      if (_isEditMode) {
        ref
            .read(webPasswordProvider.notifier)
            .updateWebPassword(updatedWebPassword);
      } else {
        ref
            .read(webPasswordProvider.notifier)
            .addWebPassword(updatedWebPassword);
      }

      await ref
          .read(settingsProvider.notifier)
          .toggleTravelProtection(itemId, _travelProtected);

      if (mounted) context.pop();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.web_form.save_failed)));
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
          _isEditMode ? t.web_form.title_edit : t.web_form.title_add,
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
                        NeumorphicInput(
                          label: t.web_form.app_site_title_label,
                          controller: _titleController,
                          hintText: t.web_form.app_site_title_hint,
                        ),
                        const SizedBox(height: 16),
                        NeumorphicInput(
                          label: t.web_form.website_url_label,
                          controller: _urlController,
                          hintText: t.web_form.website_url_hint,
                          keyboardType: TextInputType.url,
                        ),
                        const SizedBox(height: 16),
                        NeumorphicInput(
                          label: t.general.username_email,
                          controller: _usernameController,
                          hintText: t.web_form.username_hint,
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
                        NeumorphicInput(
                          label: t.general.notes,
                          controller: _notesController,
                          hintText: t.web_form.notes_hint,
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
                          onChanged: (cat) =>
                              setState(() => _selectedCategory = cat),
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
                          onPressed: _saveFast,
                          child: Text(
                            _isEditMode ? t.general.update : t.general.save,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.of(context).primaryAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
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
