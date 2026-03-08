import 'package:flutter/material.dart';
import 'package:flutter_autofill_service/flutter_autofill_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guarden/i18n/strings.g.dart';
import 'package:guarden/models/web_password.dart';
import 'package:guarden/providers/web_password_provider.dart';
import 'package:guarden/screens/autofill_screen.dart';
import 'package:guarden/theme/app_colors.dart';

class FakeWebPasswordNotifier extends WebPasswordNotifier {
  FakeWebPasswordNotifier(this.items);

  final List<WebPassword> items;

  @override
  Future<List<WebPassword>> build() async => items;
}

Widget _buildHarness({
  required Widget child,
  required List<Override> overrides,
}) {
  return ProviderScope(
    overrides: overrides,
    child: TranslationProvider(
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true, extensions: [AppColors.light]),
        home: child,
      ),
    ),
  );
}

void main() {
  testWidgets('autofill shows matching accounts first and reveals all on demand', (
    tester,
  ) async {
    final notifier = FakeWebPasswordNotifier([
      WebPassword(
        id: 'web-1',
        title: 'GitHub',
        url: 'github.com',
        username: 'octocat',
        encryptedPassword: 'enc',
        createdAt: DateTime(2026, 3, 8),
        updatedAt: DateTime(2026, 3, 8),
      ),
      WebPassword(
        id: 'web-2',
        title: 'Google',
        url: 'google.com',
        username: 'searcher',
        encryptedPassword: 'enc',
        createdAt: DateTime(2026, 3, 8),
        updatedAt: DateTime(2026, 3, 8),
      ),
    ]);

    await tester.pumpWidget(
      _buildHarness(
        child: AutofillScreen(
          metadataLoader: () async => AutofillMetadata(
            packageNames: {'com.github.android'},
            webDomains: {AutofillWebDomain(domain: 'github.com')},
            saveInfo: null,
          ),
          datasetSubmitter: (_) async => true,
        ),
        overrides: [webPasswordProvider.overrideWith(() => notifier)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Google'), findsNothing);
    expect(find.text(t.autofill.matching_accounts), findsOneWidget);

    await tester.tap(find.text(t.autofill.show_all_accounts));
    await tester.pumpAndSettle();

    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
  });

  testWidgets('autofill falls back to full vault list when metadata has no match', (
    tester,
  ) async {
    final notifier = FakeWebPasswordNotifier([
      WebPassword(
        id: 'web-1',
        title: 'GitHub',
        url: 'github.com',
        username: 'octocat',
        encryptedPassword: 'enc',
        createdAt: DateTime(2026, 3, 8),
        updatedAt: DateTime(2026, 3, 8),
      ),
      WebPassword(
        id: 'web-2',
        title: 'Google',
        url: 'google.com',
        username: 'searcher',
        encryptedPassword: 'enc',
        createdAt: DateTime(2026, 3, 8),
        updatedAt: DateTime(2026, 3, 8),
      ),
    ]);

    await tester.pumpWidget(
      _buildHarness(
        child: AutofillScreen(
          metadataLoader: () async => AutofillMetadata(
            packageNames: {'com.netflix.mediaclient'},
            webDomains: {AutofillWebDomain(domain: 'netflix.com')},
            saveInfo: null,
          ),
          datasetSubmitter: (_) async => true,
        ),
        overrides: [webPasswordProvider.overrideWith(() => notifier)],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GitHub'), findsOneWidget);
    expect(find.text('Google'), findsOneWidget);
    expect(find.text(t.autofill.no_matching_accounts), findsOneWidget);
  });
}
