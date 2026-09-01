part of 'password_generator_bloc.dart';

abstract class PasswordGeneratorEvent {
  const PasswordGeneratorEvent();
}

class GeneratePassword extends PasswordGeneratorEvent {
  const GeneratePassword();
}

class UpdateLength extends PasswordGeneratorEvent {
  const UpdateLength(this.length);

  final int length;
}

class ToggleUppercase extends PasswordGeneratorEvent {
  const ToggleUppercase(this.useUppercase);

  final bool useUppercase;
}

class ToggleLowercase extends PasswordGeneratorEvent {
  const ToggleLowercase(this.useLowercase);

  final bool useLowercase;
}

class ToggleDigits extends PasswordGeneratorEvent {
  const ToggleDigits(this.useDigits);

  final bool useDigits;
}

class ToggleSymbols extends PasswordGeneratorEvent {
  const ToggleSymbols(this.useSymbols);

  final bool useSymbols;
}

class CopyPassword extends PasswordGeneratorEvent {
  const CopyPassword();
}

class ResetCopiedStatus extends PasswordGeneratorEvent {
  const ResetCopiedStatus();
}
