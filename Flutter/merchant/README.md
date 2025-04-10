
# Minkasu2FA_Flutter_Plugin integration guide

This document walks you through the steps to integrate `minkasu2fa_flutter_plugin` in to your flutter project.

|             | Android | iOS   |
|-------------|---------|-------|
| **Support** | SDK 21+ | 13.0+ |


---
## Contents

- [`Requirements`](README.md#requirements)
- [`Dependencies`](README.md#dependencies)
- [`Getting Started`](README.md#getting-started)
- [`Minkasu2FA Models`](README.md#minkasu2fa-models)
- [`Integration`](README.md#integration)

### Requirements

- Flutter SDK: `v3.24.0` and above
- `webview_flutter`: `v4.0.0` and above

### Dependencies

- `webview_flutter`

### Getting Started

1. **iOS Configurations**
   Add support to use biometric authentication by adding the `Face ID Usage Description` in the `info.plist`
   ```swift
   <key>NSFaceIDUsageDescription</key>
   <string>Please allow AppName to use Face ID.</string>
   ```

   Update the `Podfile` located at **ios/Podfile** to ensure the project supports iOS 13.0+. Add or modify the following line:
   ```ruby
   platform :ios, '13.0'
   ```

2. **Android Configurations**
    The `Minkasu2FA SDK` screens can be customized to fit your application’s look and feel. The following screen elements can be customized

   - Action Bar Title Color
   - Action Bar Background Color

   Add the following lines to your `colors.xml` file at the path **android/app/src/main/res/values**:

   ```xml
   <!--START Minkasu2FA  -->
   <color name="mkActionBarColor">#3F51B5</color>
   <color name="mkActionBarTextColor">#ffffff</color>
   <!--END Minkasu2FA  -->
   ```
3. **Installation**
   Add the following to your project's `pubspec.yaml` file:

   ```yaml
   dependencies:
     minkasu2fa_flutter_plugin: ^1.0.0
   ```
   Then run:
   ```bash
   flutter pub get
   ```

### Minkasu2FA Models

1. **Minkasu2FAAddress**
   | Properties | Type | Required |
   | ------------- |:-------------:| -----:|
   | line1 | String | :white_large_square: |
   | line2 | String | :white_large_square: |
   | line3 | String | :white_large_square: |
   | city | String | :white_large_square: |
   | state | String | :white_large_square: |
   | zipCode | String | :white_large_square: |
   | country | String | :white_large_square: |
2. **Minkasu2FACustomerInfo**
   | Properties | Type | Required |
   | ------------- |:-------------:| -----:|
   | firstName | String | :white_check_mark: |
   | lastName | String | :white_check_mark: |
   | middleName | String | :white_large_square: |
   | email | String | :white_check_mark: |
   | phone | String | :white_check_mark: |
   | address | Minkasu2FAAddress | :white_large_square: |

3. **Minkasu2FAOrderInfo**
   | Properties | Type | Required |
   | ------------- |:-------------:| -----:|
   | orderId | String | :white_check_mark: |
   | billingCategory | String | :white_large_square: |
   | orderDetails | String | :white_large_square: |

4. **Minkasu2FACustomTheme**
   | Properties | Type | Required |
   | ------------- |:-------------:| -----:|
   | navigationBarColor | Color | :white_check_mark: |
   | navigationBarTextColor | Color | :white_check_mark: |
   | darkModeNavigationBarColor | Color | :white_large_square: |
   | darkModeNavigationBarTextColor | Color | :white_large_square: |
   | supportDarkMode | bool | :white_large_square: |

5. **Minkasu2FAOperationType**
   | Operations |
   | ----------------|
   | changePayPin |
   | enableBiometry |
   | disableBiometry |

6. **Minkasu2FAConfig**
   | Properties | Type | Required |
   | ------------- |:-------------:| -----:|
   | id | String | :white_check_mark: |
   | token | String | :white_check_mark: |
   | merchantCustomerId | String | :white_check_mark: |
   | customerInfo | Minkasu2FACustomerInfo | :white_check_mark: |
   | orderInfo | Minkasu2FAOrderInfo | :white_check_mark: |
   | sdkMode | Integer | :white_large_square: |
   | customTheme | Minkasu2FACustomTheme | :white_large_square: |

### Integration

`minkasu2fa_flutter_plugin` depends on the `webview_flutter` package and when initialising the `Minkasu2FA SDK` it expects a `WebViewController` created using the `webview_flutter` package.

1. **Creating the Config Object**

   ```dart
   import 'package:minkasu2fa_flutter_plugin/minkasu2fa_models.dart';

   const address = Minkasu2FAAddress(
    line1: "123 Test Way",
    line2: "Test Apartments",
    city: "Mumbai",
    state: "Maharashtra",
    country: "India",
    zipCode: "400068",
   );

   final customer = Minkasu2FACustomerInfo(
    firstName: "TestFirstName",
    lastName: "TestLastName",
    email: "test@minkasupay.com",
    phone: customerPhoneNumber,
    address: address,
   );

   final order = Minkasu2FAOrderInfo(
    orderId: "<order_id>",
    // Optionally specify billing category and order details
    billingCategory: "<billing_category>", // e.g. “FLIGHTS”
    orderDetails: jsonEncode(
      {
        "<key_1>": "<data_1>",
        "<key_2>": "<data_2>",
      },
    ),
   );

   const customTheme = Minkasu2FACustomTheme(
    navigationBarColor: Colors.blue,
    navigationBarTextColor: Colors.yellow,
    //Use this to set a separate color theme for Dark mode
    darkModeNavigationBarColor: Colors.yellow,
    darkModeNavigationBarTextColor: Colors.green,
    supportDarkMode:
        true, // Set supportDarkMode to true if the Merchant App supports Dark Mode
   );

   final config = Minkasu2FAConfig(
    id: "<merchant_id>",
    merchantCustomerId: "<merchant_customer_id>",
    customerInfo: customer,
    orderInfo: order,
    token: "<merchant_access_token>",
    sdkMode: Minkasu2FAConfig.SANDBOX_MODE, //set sdkMode to SANDBOX_MODE if testing on sandbox
    customTheme: customTheme,
   );
   ```

2. **Initialising the `Minkasu2FA SDK`**

   ```dart
   import 'package:minkasu2fa_flutter_plugin/minkasu2fa_flutter_plugin.dart';
   import 'package:minkasu2fa_flutter_plugin/minkasu2fa_models/minkasu2fa_callback_data.dart';

   void minkasu2FACallBack(Minkasu2FACallBackData minkasuCallBackData) {
       if (minkasuCallBackData.infoType == 1) {
         // INFO_TYPE_RESULT
       } else if (minkasuCallBackData.infoType == 2) {
         // INFO_TYPE_EVENT
       } else if (minkasuCallBackData.infoType == 3) {
         // INFO_TYPE_PROGRESS
       }
     }

   void initialiseSDK() async {
       final _minkasu2fa = Minkasu2faFlutterPlugin();
       try {
          await _minkasu2fa.init(
              _controller, // WebViewController instance
              config,      // Minkasu2FAConfig instance
              minkasu2FACallBack,    // Callback function to handle SDK events
          );
       } catch (_) {}
   }

   ```

3. **Retrieving and Performing `Minkasu2FA` Operations**

   ```dart
   import 'package:minkasu2fa_flutter_plugin/minkasu2fa_flutter_plugin.dart';
   import 'package:minkasu2fa_flutter_plugin/minkasu2fa_models.dart';

   final _minkasu2fa = Minkasu2faFlutterPlugin();

   void fetchOperations() async {
       final ops = await _minkasu2fa.getAvailableMinkasu2FAOperations();
   }

   void performOperation() async {
       final merchantCustomerId = "<merchant-customer-id>";
       const operation = Minkasu2FAOperationType.changePayPin;

       await _minkasu2fa.performMinkasu2FAOperation(
           operation,
           merchantCustomerId,
           const Minkasu2FACustomTheme(
               navigationBarColor: Colors.red,
               navigationBarTextColor: Colors.green,
           ),
       );
   }
   ```

   Please make sure the `merchantCustomerId` is a unique id associated with the currently logged in user, and is the same id used in the payment flow.

---
