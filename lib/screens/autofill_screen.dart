import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:flutter/services.dart';
import '../providers/web_password_provider.dart';
import '../services/crypto_service.dart';
import '../services/secure_storage_service.dart';
import '../models/web_password.dart';
import '../theme/app_colors.dart';

class AutofillScreen extends ConsumerStatefulWidget {
  const AutofillScreen({super.key});

  @override
  ConsumerState<AutofillScreen> createState() => _AutofillScreenState();
}

class _AutofillScreenState extends ConsumerState<AutofillScreen> {
  // ignore: unused_field
  AutofillMetadata? _metadata;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final metadata = await AutofillService().autofillMetadata;
      setState(() {
        _metadata = metadata;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectPassword(WebPassword pwd) async {
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final cryptoService = ref.read(cryptoProvider);
      final key = await secureStorage.getEncryptionKey();

      String decryptedPassword = '';
      if (key != null) {
        decryptedPassword = await cryptoService.decryptWithBase64Key(
          pwd.encryptedPassword,
          key,
        );
      } else {
        throw Exception('Encryption key not found');
      }

      await AutofillService().resultWithDatasets([
        PwDataset(
          label: pwd.title,
          username: pwd.username,
          password: decryptedPassword,
        ),
      ]);
      SystemNavigator.pop();
    } catch (e) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.of(context).background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final webPasswords = ref.watch(webPasswordProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        title: Text(
          'Select Account',
          style: TextStyle(color: AppColors.of(context).textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: AppColors.of(context).textPrimary),
            onPressed: () => SystemNavigator.pop(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (webPasswords.isEmpty) {
            return Center(
              child: Text(
                'No saved password found.',
                style: TextStyle(color: AppColors.of(context).textSecondary),
              ),
            );
          }

          // Optional: filter by _metadata?.webDomains or packageNames
          // For now, list all to ensure functionality.

          return ListView.builder(
            itemCount: webPasswords.length,
            itemBuilder: (context, index) {
              final pwd = webPasswords[index];
              return ListTile(
                title: Text(
                  pwd.title,
                  style: TextStyle(color: AppColors.of(context).textPrimary),
                ),
                subtitle: Text(
                  pwd.username,
                  style: TextStyle(color: AppColors.of(context).textSecondary),
                ),
                onTap: () => _selectPassword(pwd),
              );
            },
          );
        },
      ),
    );
  }
}
