import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_generator/bloc/copy_failure.dart';
import 'package:password_generator/bloc/entropy_helper.dart';
import 'package:password_generator/widgets/password_panel.dart';

void main() {
  Future<void> pumpPanel(
    WidgetTester tester, {
    required String? copyError,
    bool copied = false,
    String password = 'Abcdef2!',
  }) async {
    final generate = AnimationController(
      vsync: tester,
      duration: const Duration(milliseconds: 1),
    );
    final fade = AnimationController(
      vsync: tester,
      duration: const Duration(milliseconds: 1),
    )..value = 1;
    addTearDown(generate.dispose);
    addTearDown(fade.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PasswordPanel(
            password: password,
            strength: PasswordStrength.strong,
            strengthColor: const Color(0xFF10B981),
            crackTime: '1 year',
            entropy: 52,
            copied: copied,
            copyError: copyError,
            onCopy: () {},
            onGenerate: () {},
            generateIconController: generate,
            fadeInController: fade,
            isDesktop: true,
          ),
        ),
      ),
    );
  }

  testWidgets('the copy button explains a clipboard failure', (tester) async {
    await pumpPanel(tester, copyError: copyFailureDenied, copied: true);

    expect(find.text('Copy failed'), findsOneWidget);
    expect(find.text(copyFailureDenied), findsOneWidget);
    expect(find.text('Copied!'), findsNothing);
    expect(find.text('Copy to Clipboard'), findsNothing);
  });

  testWidgets('a successful copy shows Copied', (tester) async {
    await pumpPanel(tester, copyError: null, copied: true);

    expect(find.text('Copied!'), findsOneWidget);
    expect(find.text(copyFailureDenied), findsNothing);
  });

  testWidgets('the idle button offers to copy', (tester) async {
    await pumpPanel(tester, copyError: null);

    expect(find.text('Copy to Clipboard'), findsOneWidget);
    expect(find.text('Copy failed'), findsNothing);
  });
}
