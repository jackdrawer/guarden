import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guarden/theme/app_colors.dart';
import 'package:guarden/widgets/lottie_animation_widget.dart';

void main() {
  Widget buildHarness(Widget child) {
    return MaterialApp(
      theme: ThemeData(extensions: [AppColors.light]),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('renders native vault illustration for empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        const LottieAnimationWidget(
          animation: GuardenAnimation.emptyStateVault,
          size: 140,
        ),
      ),
    );

    expect(find.byKey(const ValueKey<String>('native-vault')), findsOneWidget);
  });

  testWidgets('renders native lock illustration instead of broken lottie', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        const LottieAnimationWidget(
          animation: GuardenAnimation.lockUnlock,
          size: 120,
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('native-lockUnlock')),
      findsOneWidget,
    );
  });

  testWidgets('renders native delete illustration for confirm dialogs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildHarness(
        const LottieAnimationWidget(
          animation: GuardenAnimation.deleteItem,
          size: 100,
        ),
      ),
    );

    expect(
      find.byKey(const ValueKey<String>('native-deleteItem')),
      findsOneWidget,
    );
  });
}
