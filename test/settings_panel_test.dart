import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_generator/widgets/settings_panel.dart';

void main() {
  testWidgets('the stepper cancels a pending typed length', (tester) async {
    final int Function() length = await _pumpHost(tester, 12);

    await tester.enterText(find.byType(TextField), '16');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.remove_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(length(), 15);
    expect(_fieldText(tester), '15');
  });

  testWidgets('an out-of-range edit cancels the pending length', (
    tester,
  ) async {
    final int Function() length = await _pumpHost(tester, 12);

    await tester.enterText(find.byType(TextField), '16');
    await tester.pump();
    await tester.enterText(find.byType(TextField), '99');
    await tester.pump(const Duration(milliseconds: 600));

    expect(length(), 12);
    expect(_fieldText(tester), '99');

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(length(), 32);
    expect(_fieldText(tester), '32');
  });

  testWidgets('clearing the field restores the current length', (tester) async {
    final int Function() length = await _pumpHost(tester, 12);

    await tester.enterText(find.byType(TextField), '16');
    await tester.pump();
    await tester.enterText(find.byType(TextField), '');
    await tester.pump(const Duration(milliseconds: 600));

    expect(length(), 12);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(length(), 12);
    expect(_fieldText(tester), '12');
  });

  testWidgets('a length from outside replaces the field', (tester) async {
    late void Function(VoidCallback) rebuild;
    var length = 12;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return SettingsPanel(
              length: length,
              useUppercase: true,
              useLowercase: true,
              useDigits: true,
              useSymbols: true,
              poolSize: 85,
              isDesktop: true,
              onLengthChanged: (value) {
                setState(() => length = value);
              },
              onUppercaseChanged: (_) {},
              onLowercaseChanged: (_) {},
              onDigitsChanged: (_) {},
              onSymbolsChanged: (_) {},
            );
          },
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '16');
    await tester.pump();
    rebuild(() => length = 20);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(length, 20);
    expect(_fieldText(tester), '20');
  });
}

Future<int Function()> _pumpHost(WidgetTester tester, int initial) async {
  var length = initial;
  await tester.pumpWidget(
    MaterialApp(
      home: StatefulBuilder(
        builder: (context, setState) {
          return SettingsPanel(
            length: length,
            useUppercase: true,
            useLowercase: true,
            useDigits: true,
            useSymbols: true,
            poolSize: 85,
            isDesktop: true,
            onLengthChanged: (value) {
              setState(() => length = value);
            },
            onUppercaseChanged: (_) {},
            onLowercaseChanged: (_) {},
            onDigitsChanged: (_) {},
            onSymbolsChanged: (_) {},
          );
        },
      ),
    ),
  );
  return () => length;
}

String _fieldText(WidgetTester tester) {
  return tester.widget<TextField>(find.byType(TextField)).controller!.text;
}
