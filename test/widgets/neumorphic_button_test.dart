import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guarden/theme/app_colors.dart';
import 'package:guarden/widgets/neumorphic/neumorphic_button.dart';

void main() {
  testWidgets('NeumorphicButton ignores rapid repeated taps inside debounce window', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true, extensions: [AppColors.light]),
        home: Scaffold(
          body: Center(
            child: NeumorphicButton(
              onPressed: () {
                tapCount++;
              },
              child: const Text('Press'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Press'));
    await tester.tap(find.text('Press'));
    await tester.pump();

    expect(tapCount, 1);

    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.text('Press'));
    await tester.pump();

    expect(tapCount, 2);
  });
}
