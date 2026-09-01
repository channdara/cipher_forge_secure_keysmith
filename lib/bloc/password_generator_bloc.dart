import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'password_generator.dart';
import 'password_generator_state.dart';

part 'password_generator_event.dart';

class PasswordGeneratorBloc
    extends Bloc<PasswordGeneratorEvent, PasswordGeneratorState> {
  PasswordGeneratorBloc() : super(PasswordGeneratorState.initial()) {
    on<GeneratePassword>(_onGeneratePassword);
    on<UpdateLength>(_onUpdateLength);
    on<ToggleUppercase>(_onToggleUppercase);
    on<ToggleLowercase>(_onToggleLowercase);
    on<ToggleDigits>(_onToggleDigits);
    on<ToggleSymbols>(_onToggleSymbols);
    on<CopyPassword>(_onCopyPassword);
    on<ResetCopiedStatus>(_onResetCopiedStatus);
  }

  Timer? _copiedResetTimer;

  void _onGeneratePassword(
    GeneratePassword event,
    Emitter<PasswordGeneratorState> emit,
  ) {
    final PasswordResult result = PasswordGenerator.generate(
      length: state.length,
      useUppercase: state.useUppercase,
      useLowercase: state.useLowercase,
      useDigits: state.useDigits,
      useSymbols: state.useSymbols,
    );
    emit(state.copyWith(passwordResult: result, isCopied: false));
  }

  void _onUpdateLength(
    UpdateLength event,
    Emitter<PasswordGeneratorState> emit,
  ) {
    final int clampedLength = event.length.clamp(6, 32);
    final PasswordResult result = PasswordGenerator.generate(
      length: clampedLength,
      useUppercase: state.useUppercase,
      useLowercase: state.useLowercase,
      useDigits: state.useDigits,
      useSymbols: state.useSymbols,
    );
    emit(
      state.copyWith(
        length: clampedLength,
        passwordResult: result,
        isCopied: false,
      ),
    );
  }

  void _onToggleUppercase(
    ToggleUppercase event,
    Emitter<PasswordGeneratorState> emit,
  ) {
    final PasswordResult result = PasswordGenerator.generate(
      length: state.length,
      useUppercase: event.useUppercase,
      useLowercase: state.useLowercase,
      useDigits: state.useDigits,
      useSymbols: state.useSymbols,
    );
    emit(
      state.copyWith(
        useUppercase: event.useUppercase,
        passwordResult: result,
        isCopied: false,
      ),
    );
  }

  void _onToggleLowercase(
    ToggleLowercase event,
    Emitter<PasswordGeneratorState> emit,
  ) {
    final PasswordResult result = PasswordGenerator.generate(
      length: state.length,
      useUppercase: state.useUppercase,
      useLowercase: event.useLowercase,
      useDigits: state.useDigits,
      useSymbols: state.useSymbols,
    );
    emit(
      state.copyWith(
        useLowercase: event.useLowercase,
        passwordResult: result,
        isCopied: false,
      ),
    );
  }

  void _onToggleDigits(
    ToggleDigits event,
    Emitter<PasswordGeneratorState> emit,
  ) {
    final PasswordResult result = PasswordGenerator.generate(
      length: state.length,
      useUppercase: state.useUppercase,
      useLowercase: state.useLowercase,
      useDigits: event.useDigits,
      useSymbols: state.useSymbols,
    );
    emit(
      state.copyWith(
        useDigits: event.useDigits,
        passwordResult: result,
        isCopied: false,
      ),
    );
  }

  void _onToggleSymbols(
    ToggleSymbols event,
    Emitter<PasswordGeneratorState> emit,
  ) {
    final PasswordResult result = PasswordGenerator.generate(
      length: state.length,
      useUppercase: state.useUppercase,
      useLowercase: state.useLowercase,
      useDigits: state.useDigits,
      useSymbols: event.useSymbols,
    );
    emit(
      state.copyWith(
        useSymbols: event.useSymbols,
        passwordResult: result,
        isCopied: false,
      ),
    );
  }

  Future<void> _onCopyPassword(
    CopyPassword event,
    Emitter<PasswordGeneratorState> emit,
  ) async {
    if (state.passwordResult.masterPassword.isEmpty) {
      return;
    }

    await Clipboard.setData(
      ClipboardData(text: state.passwordResult.masterPassword),
    );

    emit(state.copyWith(isCopied: true));

    _copiedResetTimer?.cancel();
    _copiedResetTimer = Timer(const Duration(seconds: 2), () {
      add(const ResetCopiedStatus());
    });
  }

  void _onResetCopiedStatus(
    ResetCopiedStatus event,
    Emitter<PasswordGeneratorState> emit,
  ) {
    emit(state.copyWith(isCopied: false));
  }

  @override
  Future<void> close() {
    _copiedResetTimer?.cancel();
    return super.close();
  }
}
