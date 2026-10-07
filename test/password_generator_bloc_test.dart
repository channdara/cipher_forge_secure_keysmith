import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_generator/bloc/copy_failure.dart';
import 'package:password_generator/bloc/password_generator_bloc.dart';
import 'package:password_generator/bloc/password_generator_state.dart';

void main() {
  Future<void> dispatch(
    PasswordGeneratorBloc bloc,
    PasswordGeneratorEvent event,
  ) async {
    final Future<PasswordGeneratorState> next = bloc.stream.first;
    bloc.add(event);
    await next;
  }

  test(
    'a successful copy shows Copied and clears a previous failure',
    () async {
      var fail = true;
      final bloc = PasswordGeneratorBloc(
        writeClipboard: (_) async {
          if (fail) {
            throw PlatformException(
              code: 'copy_fail',
              message: 'Clipboard.setData failed.',
            );
          }
        },
        secureContext: true,
      );
      addTearDown(bloc.close);

      await dispatch(bloc, const CopyPassword());

      expect(bloc.state.isCopied, isFalse);
      expect(bloc.state.copyError, copyFailureDenied);

      fail = false;
      await dispatch(bloc, const CopyPassword());

      expect(bloc.state.isCopied, isTrue);
      expect(bloc.state.copyError, isNull);
    },
  );

  test('an insecure page explains why the copy failed', () async {
    final bloc = PasswordGeneratorBloc(
      writeClipboard: (_) async {
        throw PlatformException(
          code: 'copy_fail',
          message: 'Clipboard is not available in the context.',
        );
      },
      secureContext: false,
    );
    addTearDown(bloc.close);

    await dispatch(bloc, const CopyPassword());

    expect(bloc.state.copyError, copyFailureInsecureContext);
    expect(bloc.state.isCopied, isFalse);
  });

  test('refresh clears a copy failure', () async {
    final bloc = PasswordGeneratorBloc(
      writeClipboard: (_) async {
        throw PlatformException(
          code: 'copy_fail',
          message: 'Clipboard.setData failed.',
        );
      },
      secureContext: true,
    );
    addTearDown(bloc.close);

    await dispatch(bloc, const CopyPassword());
    expect(bloc.state.copyError, copyFailureDenied);

    await dispatch(bloc, const GeneratePassword());

    expect(bloc.state.copyError, isNull);
    expect(bloc.state.isCopied, isFalse);
  });

  testWidgets('the success timer does not clear a later failure', (
    tester,
  ) async {
    var fail = false;
    final bloc = PasswordGeneratorBloc(
      writeClipboard: (_) async {
        if (fail) {
          throw PlatformException(
            code: 'copy_fail',
            message: 'Clipboard.setData failed.',
          );
        }
      },
      secureContext: true,
    );
    addTearDown(bloc.close);

    bloc.add(const CopyPassword());
    await tester.pump();
    expect(bloc.state.isCopied, isTrue);

    fail = true;
    bloc.add(const CopyPassword());
    await tester.pump();
    expect(bloc.state.copyError, copyFailureDenied);
    expect(bloc.state.isCopied, isFalse);

    await tester.pump(const Duration(seconds: 2));

    expect(bloc.state.copyError, copyFailureDenied);
    expect(bloc.state.isCopied, isFalse);
  });

  test('an empty password is not copied', () async {
    var writes = 0;
    final bloc = PasswordGeneratorBloc(
      writeClipboard: (_) async {
        writes++;
      },
      secureContext: true,
    );
    addTearDown(bloc.close);

    await dispatch(bloc, const ToggleUppercase(false));
    await dispatch(bloc, const ToggleLowercase(false));
    await dispatch(bloc, const ToggleDigits(false));
    await dispatch(bloc, const ToggleSymbols(false));
    expect(bloc.state.passwordResult.masterPassword, isEmpty);

    bloc.add(const CopyPassword());
    await Future<void>.delayed(Duration.zero);

    expect(writes, 0);
    expect(bloc.state.copyError, isNull);
  });
}
