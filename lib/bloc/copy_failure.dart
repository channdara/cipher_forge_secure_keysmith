import 'package:flutter/services.dart';

const String copyFailureInsecureContext =
    'This page is not a secure context, so the browser blocked the clipboard.';

const String copyFailureUnsupported =
    'This browser does not support copying to the clipboard.';

const String copyFailureDenied = 'The browser denied clipboard permission.';

const String copyFailureUnavailable = 'The clipboard is unavailable.';

/// True when [page] is a browser secure context.
///
/// HTTPS is secure. HTTP is secure only for localhost, loopback, and
/// `*.localhost`. `file://` and other schemes are not.
bool pageIsSecureContext([Uri? page]) {
  final Uri uri = page ?? Uri.base;
  final String scheme = uri.scheme;
  if (scheme == 'https' || scheme == 'wss') {
    return true;
  }
  if (scheme == 'http' || scheme == 'ws') {
    final String host = uri.host;
    return host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '::1' ||
        host.endsWith('.localhost');
  }
  return false;
}

/// Maps a [Clipboard.setData] failure to a sentence the copy button can show.
///
/// Flutter web reports a missing `navigator.clipboard` as "not available in
/// the context" (an insecure page, or a browser without the API) and any
/// rejected write as "Clipboard.setData failed" (permission denied).
String copyFailureExplanation(Object error, {required bool secureContext}) {
  final String details = _errorDetails(error);
  final bool clipboardMissing = details.contains(
    'clipboard is not available in the context',
  );

  if (clipboardMissing) {
    if (!secureContext) {
      return copyFailureInsecureContext;
    }
    return copyFailureUnsupported;
  }
  if (error is MissingPluginException) {
    return copyFailureUnsupported;
  }
  if (!secureContext) {
    return copyFailureInsecureContext;
  }
  if (details.contains('copy_fail') ||
      details.contains('clipboard.setdata failed') ||
      details.contains('notallowed') ||
      details.contains('permission') ||
      details.contains('denied')) {
    return copyFailureDenied;
  }
  return copyFailureUnavailable;
}

String _errorDetails(Object error) {
  if (error is PlatformException) {
    return '${error.code} ${error.message ?? ''}'.toLowerCase();
  }
  return error.toString().toLowerCase();
}
