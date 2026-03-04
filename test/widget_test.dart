import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guarden/i18n/strings.g.dart';
import 'package:guarden/main.dart';

void main() {
  testWidgets('App boots and renders initial shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(child: TranslationProvider(child: const GuardenApp())),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(GuardenApp), findsOneWidget);
  });
}
