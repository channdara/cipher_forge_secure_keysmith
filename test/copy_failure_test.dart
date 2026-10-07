import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:password_generator/bloc/copy_failure.dart';

void main() {
  group('pageIsSecureContext', () {
    test('https and loopback http are secure', () {
      expect(
        pageIsSecureContext(
          Uri.parse(
            'https://channdara.github.io/cipher_forge_secure_keysmith/',
          ),
        ),
        isTrue,
      );
      expect(pageIsSecureContext(Uri.parse('http://localhost:8080/')), isTrue);
      expect(pageIsSecureContext(Uri.parse('http://127.0.0.1/')), isTrue);
      expect(pageIsSecureContext(Uri.parse('http://[::1]/')), isTrue);
      expect(
        pageIsSecureContext(Uri.parse('http://preview.localhost/')),
        isTrue,
      );
    });

    test('plain http and file urls are not secure', () {
      expect(pageIsSecureContext(Uri.parse('http://192.168.1.20/')), isFalse);
      expect(pageIsSecureContext(Uri.parse('http://example.com/')), isFalse);
      expect(pageIsSecureContext(Uri.parse('file:///tmp/index.html')), isFalse);
    });
  });

  group('copyFailureExplanation', () {
    final unavailable = PlatformException(
      code: 'copy_fail',
      message: 'Clipboard is not available in the context.',
    );
    final writeFailed = PlatformException(
      code: 'copy_fail',
      message: 'Clipboard.setData failed.',
    );

    test('a missing clipboard on an insecure page says so', () {
      expect(
        copyFailureExplanation(unavailable, secureContext: false),
        copyFailureInsecureContext,
      );
      expect(
        copyFailureExplanation(writeFailed, secureContext: false),
        copyFailureInsecureContext,
      );
    });

    test('a missing clipboard on a secure page is an unsupported browser', () {
      expect(
        copyFailureExplanation(unavailable, secureContext: true),
        copyFailureUnsupported,
      );
      expect(
        copyFailureExplanation(
          MissingPluginException('clipboard'),
          secureContext: true,
        ),
        copyFailureUnsupported,
      );
      expect(
        copyFailureExplanation(
          MissingPluginException('clipboard'),
          secureContext: false,
        ),
        copyFailureUnsupported,
      );
    });

    test('a rejected write on a secure page is denied permission', () {
      expect(
        copyFailureExplanation(writeFailed, secureContext: true),
        copyFailureDenied,
      );
    });

    test('an unrecognized error says the clipboard is unavailable', () {
      expect(
        copyFailureExplanation(Exception('socket closed'), secureContext: true),
        copyFailureUnavailable,
      );
    });
  });
}
