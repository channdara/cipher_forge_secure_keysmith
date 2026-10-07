import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:password_generator/bloc/entropy_helper.dart';
import 'package:password_generator/bloc/password_generator_state.dart';

void main() {
  double bits({
    required int length,
    bool useUppercase = false,
    bool useLowercase = false,
    bool useDigits = false,
    bool useSymbols = false,
  }) {
    return EntropyHelper.calculateEntropy(
      length: length,
      useUppercase: useUppercase,
      useLowercase: useLowercase,
      useDigits: useDigits,
      useSymbols: useSymbols,
    );
  }

  double allClasses(int length) {
    return bits(
      length: length,
      useUppercase: true,
      useLowercase: true,
      useDigits: true,
      useSymbols: true,
    );
  }

  test('empty length or no classes has no entropy', () {
    expect(bits(length: 0, useUppercase: true), 0);
    expect(bits(length: 12), 0);
  });

  test('one class is independent uniform draws', () {
    expect(
      bits(length: 12, useUppercase: true),
      closeTo(55.019550008654, 1e-9),
    );
    expect(bits(length: 10, useDigits: true), closeTo(30, 1e-9));
  });

  test(
    'coverage mixture matches the closed form and sits below a uniform draw',
    () {
      expect(allClasses(12), closeTo(75.970777786120, 1e-9));
      expect(allClasses(6), closeTo(36.307057552241, 1e-9));
      expect(allClasses(8), closeTo(49.796230428518, 1e-9));
      expect(allClasses(32), closeTo(204.727200584437, 1e-6));
      expect(
        bits(length: 6, useUppercase: true, useLowercase: true),
        closeTo(33.615569932641, 1e-9),
      );

      final double uniform12 = 12 * (log(85) / ln2);
      final double uniform6 = 6 * (log(85) / ln2);
      expect(uniform12 - allClasses(12), lessThan(uniform6 - allClasses(6)));
    },
  );

  test('length equal to the class count is a random assignment of classes', () {
    var logAssignments = 0.0;
    for (var i = 2; i <= 4; i++) {
      logAssignments += log(i);
    }
    final double withinPool = log(24) + log(25) + log(8) + log(28);
    expect(allClasses(4), closeTo((logAssignments + withinPool) / ln2, 1e-9));
  });

  test('a shorter length than the class count is rejected', () {
    expect(() => allClasses(3), throwsArgumentError);
  });

  test('strength follows the coverage entropy', () {
    expect(EntropyHelper.getStrength(allClasses(12)), PasswordStrength.strong);
    expect(EntropyHelper.getStrength(allClasses(8)), PasswordStrength.weak);
    expect(
      EntropyHelper.getStrength(8 * (log(85) / ln2)),
      PasswordStrength.medium,
    );
  });

  test('the initial password state uses the coverage entropy', () {
    final state = PasswordGeneratorState.initial();
    expect(state.entropy, closeTo(75.970777786120, 1e-9));
    expect(state.strength, PasswordStrength.strong);
    expect(state.crackTime, '117k years');
    expect(state.activePoolCount, 4);
  });

  test('crack time is one offline model and stays in words when huge', () {
    expect(EntropyHelper.getCrackTimeEstimate(0), 'N/A');
    expect(EntropyHelper.getCrackTimeEstimate(-5), 'N/A');
    expect(EntropyHelper.getCrackTimeEstimate(28), 'Instantly');
    expect(EntropyHelper.getCrackTimeEstimate(40), '55.0 seconds');
    expect(EntropyHelper.getCrackTimeEstimate(50), '16 hours');
    expect(EntropyHelper.getCrackTimeEstimate(allClasses(12)), '117k years');
    expect(EntropyHelper.getCrackTimeEstimate(100), '2 trillion years');

    final String at25 = EntropyHelper.getCrackTimeEstimate(allClasses(25));
    final String at32 = EntropyHelper.getCrackTimeEstimate(allClasses(32));
    expect(at25, '2 × 10^30 years');
    expect(at32, '7 × 10^43 years');
    expect(at25.contains('e+'), isFalse);
    expect(at32.contains('e+'), isFalse);
  });
}
