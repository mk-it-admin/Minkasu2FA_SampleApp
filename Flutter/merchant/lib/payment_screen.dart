import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:minkasu2fa_flutter_plugin/minkasu2fa_flutter_plugin.dart';
import 'package:minkasu2fa_flutter_plugin/minkasu2fa_models.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final String type;
  const PaymentScreen({
    super.key,
    required this.type,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final String customerPhoneNumber =
      <customer_phone_number>; // Format: +91XXXXXXXXXX (no spaces)

  /// initializing the WebViewController instance
  final WebViewController _controller = WebViewController();

  /// Initializing the Minkasu2FAFlutterPlugin instance
  final _minkasu2fa = Minkasu2FAFlutterPlugin();

  /// This method will be invoked by Minkasu2FAFlutterPlugin for every update
  ///
  /// This method will take a `Minkasu2FACallBackData` as an argument
  void minkasuCallback(Minkasu2FACallbackInfo minkasuCallbackInfo) {
    if (minkasuCallbackInfo.infoType == 1) {
      // INFO_TYPE_RESULT
    } else if (minkasuCallbackInfo.infoType == 2) {
      // INFO_TYPE_EVENT
    } else if (minkasuCallbackInfo.infoType == 3) {
      // INFO_TYPE_PROGRESS
    }
  }

  @override
  void initState() {
    super.initState();

    /// Settings up WebView, Minkasu2FASDK and then loading the URL on the webview
    setUpWebView();
    createConfig();
    loadURL();
  }

  Future<void> setUpWebView() async {
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  /// This method will create [Minkasu2FAConfig] and initalize the Minkasu2FA SDK
  Future<void> createConfig() async {
    /// Creating a Minkasu2FAAddress instance
    ///
    /// Not all the fields are required. Please take a look at `Minkasu2FAAddress` for more details
    const address = Minkasu2FAAddress(
      line1: "123 Test Way",
      line2: "Test Apartments",
      city: "Mumbai",
      state: "Maharashtra",
      country: "India",
      zipCode: "400068",
    );

    /// Creating a Minkasu2FACustomerInfo instance
    ///
    /// Not all the fields are required. Please take a look at `Minkasu2FACustomerInfo` for more details
    final customer = Minkasu2FACustomerInfo(
      firstName: "TestFirstName",
      lastName: "TestLastName",
      email: "test@minkasupay.com",
      phone: customerPhoneNumber,
      address: address,
    );

    /// Creating a Minkasu2FAOrderInfo instance
    ///
    /// Not all the fields are required. Please take a look at `Minkasu2FAOrderInfo` for more details
    /// `orderDetails` is expecting a JSON String
    final order = Minkasu2FAOrderInfo(
      orderId: <order_id>,
      // Optionally specify billing category and order details
      billingCategory: "<billing_category>", // e.g. “FLIGHTS”
      orderDetails: jsonEncode(
        {
          "<key_1>": "<data_1>",
          "<key_2>": "<data_2>",
        },
      ),
    );

    /// Creating a Minkasu2FACustomTheme instance
    ///
    /// Not all the fields are required. Please take a look at `Minkasu2FACustomTheme` for more details
    /// This theme settings is for iOS only. For android please update the `colors.xml`
    const customTheme = Minkasu2FACustomTheme(
      navigationBarColor: Colors.blue,
      navigationBarTextColor: Colors.yellow,
      //Use this to set a separate color theme for Dark mode
      darkModeNavigationBarColor: Colors.yellow,
      darkModeNavigationBarTextColor: Colors.green,
      supportDarkMode:
          true, // Set supportDarkMode to true if the Merchant App supports Dark Mode
    );

    /// Creating a Minkasu2FAConfig instance
    ///
    /// Not all the fields are required. Please take a look at `Minkasu2FAConfig` for more details
    final config = Minkasu2FAConfig(
      id: <merchant_id>,
      merchantCustomerId: <merchant_customer_id>,
      customerInfo: customer,
      orderInfo: order,
      token: <merchant_access_token>,
      sdkMode: Minkasu2FAConfig
          .SANDBOX_MODE, //set sdkMode to MINKASU2FA_SANDBOX_MODE if testing on sandbox
      customTheme: customTheme,
    );

    //Initializing Minkasu2FA SDK with WebViewController object, the config object and the callback method
    try {
      final result = await _minkasu2fa.init(
        _controller,
        config,
        minkasuCallback,
      );
    } catch (_) {}
  }

  /// This method will load an url on to the WebView
  Future<void> loadURL() async {
    _controller.loadRequest(
      Uri.parse(paymentURL()),
    );
  }

  String paymentURL() {
    String encodedPhoneNumber =
        encodeWithAllowedAlphanumeric(customerPhoneNumber);
    String paymentURL = widget.type == "NETBANKING"
        ? "https://sandbox.minkasupay.com/demo/nb_login.html?bankPhone=$encodedPhoneNumber"
        : "https://sandbox.minkasupay.com/demo/card.html?bankPhone=$encodedPhoneNumber";
    return paymentURL;
  }

  String encodeWithAllowedAlphanumeric(String input) {
    final buffer = StringBuffer();

    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      if (RegExp(r'[a-zA-Z0-9]').hasMatch(char)) {
        buffer.write(char);
      } else {
        buffer.write(Uri.encodeComponent(char));
      }
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Screen'),
        backgroundColor: const Color.fromRGBO(78, 164, 109, 1),
        iconTheme: const IconThemeData(color: Color.fromRGBO(255, 255, 255, 1)),
        titleTextStyle: const TextStyle(
          color: Color.fromRGBO(255, 255, 255, 1),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
