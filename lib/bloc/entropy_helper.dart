import 'dart:math';

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'password_generator.dart';

enum PasswordStrength { none, veryWeak, weak, medium, strong, veryStrong }

class EntropyHelper {
  EntropyHelper._();

  static int getPoolSize({
    required bool useUppercase,
    required bool useLowercase,
    required bool useDigits,
    required bool useSymbols,
  }) {
    var size = 0;
    for (final int pool in _activePoolSizes(
      useUppercase: useUppercase,
      useLowercase: useLowercase,
      useDigits: useDigits,
      useSymbols: useSymbols,
    )) {
      size += pool;
    }
    return size;
  }

  /// Shannon entropy, in bits, of a password from [PasswordGenerator.generate].
  ///
  /// One active class is `length` independent draws from that class. Two or
  /// more classes, with room for every class, follow the generator's coverage
  /// mixture: a random set of positions is reserved, one per class, and the
  /// other positions come from a random spot in an intermediate key. Strings
  /// that miss a class have probability zero, so this is below
  /// `length * log2(combined pool size)`.
  ///
  /// Returns 0 when [length] is not positive or every class is off. Throws
  /// [ArgumentError] when [length] is shorter than the number of active
  /// classes, because that generator path uses a different construction.
  static double calculateEntropy({
    required int length,
    required bool useUppercase,
    required bool useLowercase,
    required bool useDigits,
    required bool useSymbols,
  }) {
    if (length <= 0) {
      return 0.0;
    }
    final List<int> poolSizes = _activePoolSizes(
      useUppercase: useUppercase,
      useLowercase: useLowercase,
      useDigits: useDigits,
      useSymbols: useSymbols,
    );
    if (poolSizes.isEmpty) {
      return 0.0;
    }
    if (length < poolSizes.length) {
      throw ArgumentError(
        'Length must be at least the number of active classes.',
      );
    }
    return _coverageEntropyBits(length, poolSizes);
  }

  static List<int> _activePoolSizes({
    required bool useUppercase,
    required bool useLowercase,
    required bool useDigits,
    required bool useSymbols,
  }) {
    return [
      if (useUppercase) PasswordGenerator.uppercaseChars.length,
      if (useLowercase) PasswordGenerator.lowercaseChars.length,
      if (useDigits) PasswordGenerator.digitChars.length,
      if (useSymbols) PasswordGenerator.symbolChars.length,
    ];
  }

  /// Entropy of the coverage mixture used when the length can hold every pool.
  ///
  /// A uniform random injection assigns each pool to its own position.
  /// Assigned positions are uniform in that pool. The other positions are
  /// independent draws from a random character of an intermediate key. Given
  /// the pool of each position, the character is uniform inside that pool, so
  /// the total is the entropy of the pool sequence plus the expected
  /// within-pool bits.
  static double _coverageEntropyBits(int length, List<int> poolSizes) {
    final int classes = poolSizes.length;
    var total = 0;
    for (final size in poolSizes) {
      total += size;
    }

    final double logFactLength = _logFactorial(length);
    final double logFactSpare = _logFactorial(length - classes);
    final double spareShare = (length - classes) / length;
    // Pool distribution of one random character in an intermediate key.
    final List<double> unassignedPool = [
      for (final int size in poolSizes)
        (1 / length) + spareShare * (size / total),
    ];

    var sequenceNats = 0.0;
    var mass = 0.0;
    _eachCountVector(length, classes, (List<int> counts) {
      double logProbability = logFactSpare - logFactLength;
      var logMultiplicity = logFactLength;
      for (var i = 0; i < classes; i++) {
        final int count = counts[i];
        logProbability += log(count) + (count - 1) * log(unassignedPool[i]);
        logMultiplicity -= _logFactorial(count);
      }
      final double vectorMass = exp(logMultiplicity + logProbability);
      sequenceNats += -vectorMass * logProbability;
      mass += vectorMass;
    });
    assert((mass - 1).abs() < 1e-8);

    var positionNats = 0.0;
    for (var i = 0; i < classes; i++) {
      final double poolProbability =
          (1 / length) + spareShare * unassignedPool[i];
      positionNats += poolProbability * log(poolSizes[i]);
    }

    return (sequenceNats + length * positionNats) / ln2;
  }

  static double _logFactorial(int n) {
    var sum = 0.0;
    for (var i = 2; i <= n; i++) {
      sum += log(i);
    }
    return sum;
  }

  /// Visits every positive integer solution of `c1 + ... + ck = length`.
  static void _eachCountVector(
    int length,
    int classes,
    void Function(List<int> counts) visit,
  ) {
    final counts = List<int>.filled(classes, 1);

    void walk(int index, int remaining) {
      if (index == classes - 1) {
        counts[index] = remaining;
        visit(counts);
        return;
      }
      final int reserved = classes - index - 1;
      for (var count = 1; count <= remaining - reserved; count++) {
        counts[index] = count;
        walk(index + 1, remaining - count);
      }
    }

    walk(0, length);
  }

  static PasswordStrength getStrength(double entropy) {
    if (entropy == 0) {
      return PasswordStrength.none;
    }
    if (entropy < 28) {
      return PasswordStrength.veryWeak;
    }
    if (entropy < 50) {
      return PasswordStrength.weak;
    }
    if (entropy < 75) {
      return PasswordStrength.medium;
    }
    if (entropy < 100) {
      return PasswordStrength.strong;
    }
    return PasswordStrength.veryStrong;
  }

  static Color getStrengthColor(PasswordStrength strength) {
    return switch (strength) {
      PasswordStrength.none => Colors.grey,
      PasswordStrength.veryWeak => Colors.red,
      PasswordStrength.weak => Colors.orange,
      PasswordStrength.medium => Colors.amber,
      PasswordStrength.strong => Colors.green,
      PasswordStrength.veryStrong => Colors.cyan,
    };
  }

  static String getStrengthLabel(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.none:
        return 'No Password';
      case PasswordStrength.veryWeak:
        return 'Very Weak';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.veryStrong:
        return 'Extremely Secure';
    }
  }

  /// Duration for one offline guessing model, not a property of the password.
  ///
  /// The attacker knows the length and the active character classes, tries
  /// 10 billion guesses per second, and stops halfway through a keyspace of
  /// this entropy: `2^(E - 1) / 10^10` seconds. A rate-limited login is much
  /// slower. A fast hash on a large cluster can be faster.
  static String getCrackTimeEstimate(double entropy) {
    if (entropy <= 0) {
      return 'N/A';
    }

    final double log2Seconds = entropy - 1 - (10 * log(10) / ln2);
    if (log2Seconds < 0) {
      return 'Instantly';
    }
    return _formatLog10Seconds(log2Seconds * ln2 / ln10);
  }

  static const double _daysPerMonth = 30.437;
  static const double _daysPerYear = 365.25;

  static String _formatLog10Seconds(double log10Seconds) {
    final double log10Minute = _log10(60);
    if (log10Seconds < log10Minute) {
      return '${_fixed(log10Seconds, 1)} seconds';
    }

    final double log10Minutes = log10Seconds - log10Minute;
    if (log10Minutes < log10Minute) {
      return '${_fixed(log10Minutes, 0)} minutes';
    }

    final double log10Hours = log10Minutes - log10Minute;
    if (log10Hours < _log10(24)) {
      return '${_fixed(log10Hours, 0)} hours';
    }

    final double log10Days = log10Hours - _log10(24);
    if (log10Days < _log10(30)) {
      return '${_fixed(log10Days, 0)} days';
    }

    final double log10Months = log10Days - _log10(_daysPerMonth);
    if (log10Months < _log10(12)) {
      return '${_fixed(log10Months, 0)} months';
    }

    return _formatYears(log10Days - _log10(_daysPerYear));
  }

  static const List<String> _yearUnits = [
    'years',
    'k years',
    'million years',
    'billion years',
    'trillion years',
    'quadrillion years',
    'quintillion years',
  ];

  static String _formatYears(double log10Years) {
    var band = 0;
    if (log10Years >= 0) {
      band = (log10Years / 3).floor();
    }
    if (band >= _yearUnits.length) {
      return _yearsAsPowerOfTen(log10Years);
    }

    int count = _roundInt(log10Years - band * 3);
    if (count >= 1000) {
      band += 1;
      count = 1;
    }
    if (band >= _yearUnits.length) {
      return _yearsAsPowerOfTen(log10Years);
    }
    if (band == 1) {
      return '${count}k years';
    }
    return '$count ${_yearUnits[band]}';
  }

  /// `2 × 10^30 years` rather than Dart's `2e+21 billion years`.
  static String _yearsAsPowerOfTen(double log10Years) {
    int exponent = log10Years.floor();
    final double mantissa = pow(10, log10Years - exponent).toDouble();
    int digit = mantissa.round();
    if (digit >= 10) {
      digit = 1;
      exponent += 1;
    }
    if (digit <= 1) {
      return '10^$exponent years';
    }
    return '$digit × 10^$exponent years';
  }

  static double _log10(num value) => log(value) / ln10;

  static int _roundInt(double log10Value) => pow(10, log10Value).round();

  static String _fixed(double log10Value, int digits) {
    return pow(10, log10Value).toDouble().toStringAsFixed(digits);
  }

  static final Set<int> _symbolCodeUnits = PasswordGenerator
      .symbolChars
      .codeUnits
      .toSet();

  static bool isSymbolCode(int code) => _symbolCodeUnits.contains(code);

  static Color characterColor(String char) {
    if (char.isEmpty) {
      return AppColors.charDefault;
    }
    final int code = char.codeUnitAt(0);

    // Check for digit (2-9): '2' is 50, '9' is 57
    if (code >= 50 && code <= 57) {
      return AppColors.charDigit;
    }

    // Check for uppercase letter (A-Z): 'A' is 65, 'Z' is 90
    if (code >= 65 && code <= 90) {
      return AppColors.charUppercase;
    }

    // Check for symbol: !@#$%^&*()-_=+[]{};:',.<>?/~
    if (_symbolCodeUnits.contains(code)) {
      return AppColors.charSymbol;
    }

    // Default to lowercase (and others if any)
    return AppColors.charDefault;
  }
}
