import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/strings.g.dart';
import '../models/web_password.dart';
import '../providers/web_password_provider.dart';
import '../services/crypto_service.dart';
import '../services/logo_service.dart';
import '../services/secure_storage_service.dart';
import '../theme/app_colors.dart';

typedef AutofillMetadataLoader = Future<AutofillMetadata?> Function();
typedef AutofillDatasetSubmitter = Future<bool> Function(List<PwDataset> data);

class AutofillCandidateGroup {
  const AutofillCandidateGroup({
    required this.matching,
    required this.others,
    required this.hasMetadata,
  });

  final List<WebPassword> matching;
  final List<WebPassword> others;
  final bool hasMetadata;

  List<WebPassword> get ordered => [...matching, ...others];
}

class AutofillScreen extends ConsumerStatefulWidget {
  const AutofillScreen({
    super.key,
    this.metadataLoader,
    this.datasetSubmitter,
  });

  final AutofillMetadataLoader? metadataLoader;
  final AutofillDatasetSubmitter? datasetSubmitter;

  @override
  ConsumerState<AutofillScreen> createState() => _AutofillScreenState();
}

class _AutofillScreenState extends ConsumerState<AutofillScreen> {
  AutofillMetadata? _metadata;
  bool _isLoading = true;
  bool _showAllAccounts = false;

  @override
  void initState() {
    super.initState();
    _loadMetadata();
  }

  Future<void> _loadMetadata() async {
    try {
      final metadata =
          await widget.metadataLoader?.call() ??
          await AutofillService().autofillMetadata;
      if (!mounted) {
        return;
      }
      setState(() {
        _metadata = metadata;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
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

      if (key == null || key.isEmpty) {
        throw Exception(t.settings.errors.encryption_key_missing);
      }

      final decryptedPassword = await cryptoService.decryptWithBase64Key(
        pwd.encryptedPassword,
        key,
      );

      final datasets = [
        PwDataset(
          label: pwd.title,
          username: pwd.username,
          password: decryptedPassword,
        ),
      ];

      await widget.datasetSubmitter?.call(datasets) ??
          AutofillService().resultWithDatasets(datasets);
    } catch (_) {
      // Fall through to exit the autofill surface gracefully.
    } finally {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: CircularProgressIndicator(color: colors.primaryAccent),
        ),
      );
    }

    final webPasswords = ref.watch(webPasswordProvider).valueOrNull ?? [];
    final groups = groupAutofillCandidates(
      passwords: webPasswords,
      metadata: _metadata,
      logoService: ref.read(logoServiceProvider),
    );
    final visiblePasswords =
        groups.matching.isNotEmpty && !_showAllAccounts
        ? groups.matching
        : groups.ordered;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          t.autofill.title,
          style: TextStyle(color: colors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: colors.textPrimary),
            onPressed: SystemNavigator.pop,
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (webPasswords.isEmpty) {
            return Center(
              child: Text(
                t.autofill.no_saved_password_found,
                style: TextStyle(color: colors.textSecondary),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (groups.matching.isNotEmpty && !_showAllAccounts)
                _AutofillBanner(
                  title: t.autofill.matching_accounts,
                  subtitle: t.autofill.matching_accounts_hint,
                  actionLabel: t.autofill.show_all_accounts,
                  onPressed: () => setState(() => _showAllAccounts = true),
                ),
              if (groups.matching.isEmpty && groups.hasMetadata)
                _AutofillBanner(
                  title: t.autofill.all_accounts,
                  subtitle: t.autofill.no_matching_accounts,
                ),
              Expanded(
                child: ListView.builder(
                  itemCount: visiblePasswords.length,
                  itemBuilder: (context, index) {
                    final pwd = visiblePasswords[index];
                    return ListTile(
                      title: Text(
                        pwd.title,
                        style: TextStyle(color: colors.textPrimary),
                      ),
                      subtitle: Text(
                        pwd.username,
                        style: TextStyle(color: colors.textSecondary),
                      ),
                      onTap: () => _selectPassword(pwd),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AutofillBanner extends StatelessWidget {
  const _AutofillBanner({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onPressed,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: colors.neumorphicShadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: colors.textSecondary),
          ),
          if (actionLabel != null && onPressed != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onPressed, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

AutofillCandidateGroup groupAutofillCandidates({
  required List<WebPassword> passwords,
  required AutofillMetadata? metadata,
  required LogoService logoService,
}) {
  final scored = passwords
      .map(
        (password) => (
          password: password,
          score: _scoreAutofillCandidate(password, metadata, logoService),
        ),
      )
      .toList()
    ..sort((a, b) => b.score.compareTo(a.score));

  final matching = <WebPassword>[];
  final others = <WebPassword>[];

  for (final entry in scored) {
    if (entry.score > 0) {
      matching.add(entry.password);
    } else {
      others.add(entry.password);
    }
  }

  return AutofillCandidateGroup(
    matching: matching,
    others: others,
    hasMetadata:
        metadata != null &&
        (metadata.packageNames.isNotEmpty || metadata.webDomains.isNotEmpty),
  );
}

int _scoreAutofillCandidate(
  WebPassword password,
  AutofillMetadata? metadata,
  LogoService logoService,
) {
  if (metadata == null) {
    return 0;
  }

  final domains = metadata.webDomains
      .map((item) => _normalizeToken(item.domain))
      .where((item) => item.isNotEmpty)
      .toSet();
  final packageTokens = metadata.packageNames
      .expand(_splitPackageTokens)
      .where((item) => item.isNotEmpty)
      .toSet();

  final resolvedDomain = _normalizeToken(
    logoService.resolveDomain(
      password.url.isNotEmpty ? password.url : password.title,
    ),
  );
  final candidateTokens = <String>{
    ..._splitPackageTokens(password.title),
    ..._splitPackageTokens(password.url),
    if (resolvedDomain.isNotEmpty) resolvedDomain,
    if (resolvedDomain.contains('.')) resolvedDomain.split('.').first,
  };

  var score = 0;
  if (resolvedDomain.isNotEmpty && domains.contains(resolvedDomain)) {
    score += 100;
  }

  for (final domain in domains) {
    final root = domain.split('.').first;
    if (root.isNotEmpty && candidateTokens.contains(root)) {
      score += 40;
    }
  }

  for (final token in packageTokens) {
    if (candidateTokens.contains(token)) {
      score += 25;
    }
  }

  return score;
}

Iterable<String> _splitPackageTokens(String value) {
  return value
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((token) => token.length >= 3)
      .where((token) => !const {'com', 'www', 'app', 'android', 'ios'}.contains(token));
}

String _normalizeToken(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceFirst(RegExp(r'^www\.'), '');
}
