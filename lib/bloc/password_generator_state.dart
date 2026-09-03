import 'dart:ui';

import 'entropy_helper.dart';
import 'password_generator.dart';

class PasswordGeneratorState {
  const PasswordGeneratorState({
    required this.length,
    required this.useUppercase,
    required this.useLowercase,
    required this.useDigits,
    required this.useSymbols,
    required this.passwordResult,
    required this.isCopied,
    required this.poolSize,
    required this.entropy,
    required this.strength,
    required this.crackTime,
  });

  factory PasswordGeneratorState.create({
    required int length,
    required bool useUppercase,
    required bool useLowercase,
    required bool useDigits,
    required bool useSymbols,
    required PasswordResult passwordResult,
    bool isCopied = false,
  }) {
    final int poolSize = EntropyHelper.getPoolSize(
      useUppercase: useUppercase,
      useLowercase: useLowercase,
      useDigits: useDigits,
      useSymbols: useSymbols,
    );
    final double entropy = EntropyHelper.calculateEntropy(length, poolSize);
    final PasswordStrength strength = EntropyHelper.getStrength(entropy);
    final String crackTime = EntropyHelper.getCrackTimeEstimate(entropy);

    return PasswordGeneratorState(
      length: length,
      useUppercase: useUppercase,
      useLowercase: useLowercase,
      useDigits: useDigits,
      useSymbols: useSymbols,
      passwordResult: passwordResult,
      isCopied: isCopied,
      poolSize: poolSize,
      entropy: entropy,
      strength: strength,
      crackTime: crackTime,
    );
  }

  factory PasswordGeneratorState.initial() {
    const initialLength = 12;
    const initialUppercase = true;
    const initialLowercase = true;
    const initialDigits = true;
    const initialSymbols = true;

    final PasswordResult initialResult = PasswordGenerator.generate(
      length: initialLength,
      useUppercase: initialUppercase,
      useLowercase: initialLowercase,
      useDigits: initialDigits,
      useSymbols: initialSymbols,
    );

    return PasswordGeneratorState.create(
      length: initialLength,
      useUppercase: initialUppercase,
      useLowercase: initialLowercase,
      useDigits: initialDigits,
      useSymbols: initialSymbols,
      passwordResult: initialResult,
    );
  }

  final int length;
  final bool useUppercase;
  final bool useLowercase;
  final bool useDigits;
  final bool useSymbols;
  final PasswordResult passwordResult;
  final bool isCopied;
  final int poolSize;
  final double entropy;
  final PasswordStrength strength;
  final String crackTime;

  PasswordGeneratorState copyWith({
    int? length,
    bool? useUppercase,
    bool? useLowercase,
    bool? useDigits,
    bool? useSymbols,
    PasswordResult? passwordResult,
    bool? isCopied,
  }) {
    return PasswordGeneratorState.create(
      length: length ?? this.length,
      useUppercase: useUppercase ?? this.useUppercase,
      useLowercase: useLowercase ?? this.useLowercase,
      useDigits: useDigits ?? this.useDigits,
      useSymbols: useSymbols ?? this.useSymbols,
      passwordResult: passwordResult ?? this.passwordResult,
      isCopied: isCopied ?? this.isCopied,
    );
  }

  Color strengthColor() {
    return EntropyHelper.getStrengthColor(strength);
  }
}
