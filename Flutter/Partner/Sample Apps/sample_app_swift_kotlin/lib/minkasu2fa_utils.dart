import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'minkasu2fa_models.dart';

import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

final methodChannel = const MethodChannel('minkasu2fa_method_channel');

int fetchWebViewId(WebViewController webViewController) {
  late int webViewIdentifier;
  if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    final WebKitWebViewController webKitController =
        webViewController.platform as WebKitWebViewController;
    webViewIdentifier = webKitController.webViewIdentifier;
  } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
    final AndroidWebViewController androidController =
        webViewController.platform as AndroidWebViewController;
    webViewIdentifier = androidController.webViewIdentifier;
  }
  return webViewIdentifier;
}

Future<dynamic> initializeMinkasu2FA(
  Minkasu2FAConfig minkasu2FAConfig,
  WebViewController webViewController, [
  void Function(dynamic)? minkasu2FACallback,
]) async {
  try {
    if (minkasu2FACallback != null) {
      _mk2FASetUpCallback(minkasu2FACallback);
    }
    final int webViewId = fetchWebViewId(webViewController);
    final output = await methodChannel.invokeMethod('initMinkasu2FASDK', {
      'webViewId': webViewId,
      'config': minkasu2FAConfig.toMap(),
    });
    return output;
  } catch (e) {
    rethrow;
  }
}

void _mk2FASetUpCallback(void Function(dynamic) callback) {
  try {
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == "receiveMinkasu2FACallbackInfo") {
        final minkasu2FACallbackInfo = call.arguments;
        callback(minkasu2FACallbackInfo);
      }
    });
  } catch (e) {
    return;
  }
}
