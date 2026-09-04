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
    if (useUppercase) {
      size += PasswordGenerator.uppercaseChars.length;
    }
    if (useLowercase) {
      size += PasswordGenerator.lowercaseChars.length;
    }
    if (useDigits) {
      size += PasswordGenerator.digitChars.length;
    }
    if (useSymbols) {
      size += PasswordGenerator.symbolChars.length;
    }
    return size;
  }

  static double calculateEntropy(int length, int poolSize) {
    if (length <= 0 || poolSize <= 0) {
      return 0.0;
    }
    return length * (log(poolSize) / ln2);
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

  static String getCrackTimeEstimate(double entropy) {
    if (entropy <= 0) {
      return 'N/A';
    }

    final double log2Seconds = entropy - 34.21928;

    if (log2Seconds < 0) {
      return 'Instantly';
    }

    final double seconds = pow(2.0, log2Seconds).toDouble();

    if (seconds < 60) {
      return '${seconds.toStringAsFixed(1)} seconds';
    }

    final double minutes = seconds / 60;
    if (minutes < 60) {
      return '${minutes.toStringAsFixed(0)} minutes';
    }

    final double hours = minutes / 60;
    if (hours < 24) {
      return '${hours.toStringAsFixed(0)} hours';
    }

    final double days = hours / 24;
    if (days < 30) {
      return '${days.toStringAsFixed(0)} days';
    }

    final double months = days / 30.437;
    if (months < 12) {
      return '${months.toStringAsFixed(0)} months';
    }

    final double years = days / 365.25;
    if (years < 1000) {
      return '${years.toStringAsFixed(0)} years';
    } else if (years < 1000000) {
      final double millennia = years / 1000;
      return '${millennia.toStringAsFixed(0)}k years';
    } else if (years < 1000000000) {
      final double millions = years / 1000000;
      return '${millions.toStringAsFixed(0)} million years';
    } else {
      final double billions = years / 1000000000;
      return '${billions.toStringAsFixed(0)} billion years';
    }
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
