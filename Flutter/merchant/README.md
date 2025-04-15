


  
# Minkasu2FA_Flutter_Plugin integration guide
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
- Android: `SDK 21+`
- iOS: `13.0+`
  

### Dependencies

-  `webview_flutter`: `v4.0.0` and above

### Getting Started

  
1.  **Flutter Configurations**

	Add the following to your project's `pubspec.yaml` file:

	```yaml
	dependencies:
	   minkasu2fa_flutter_plugin: ^0.0.1
	```

	Then run:

	```bash
 
	flutter pub get
 
 	```

2.  **Android Configurations**
   
	Using the plugin requires an activity declaration in your `AndroidManifest.xml`.
	```xml
	<activity
		android:name="com.minkasu.android.twofa.sdk.MinkasuSDKActivity"
		android:configChanges="keyboard|orientation|screenSize|screenLayout|
		keyboardHidden|uiMode|layoutDirection|smallestScreenSize"
		android:theme="@style/Mk2FASDKtheme">
	</activity>
 	```
 	
	The `Minkasu2FA SDK` screens can be customized to fit your application’s look and feel by specifying the Minkasu2FATheme as a parent 		style of your own theme.The following screen elements can be customized:

	- Action Bar Title Color
	- Action Bar Background Color

   	Add the following lines to your `styles.xml` file at the path **android/app/src/main/res/values**: and **android/app/src/main/res/values-night** for light theme and dark theme respectively.

    ```xml
    <!--START Minkasu2FA -->
	<style name="Mk2FASDKtheme" parent="Minkasu2FATheme">
		<item name="colorPrimary">@color/mkActionBarColor</item>
		<item name="colorPrimaryDark">@color/mkActionBarColor</item>
	</style>
	<!--END Minkasu2FA -->
    ```
    
	Add the following lines to your `colors.xml` file at the path **android/app/src/main/res/values**:

	```xml
	<!--START Minkasu2FA -->
	<color  name="mkActionBarColor">#3F51B5</color>
	<color  name="mkActionBarTextColor">#ffffff</color>
	<!--END Minkasu2FA -->
	```

	For dark theme add the following line to your `colors.xml` file at the path **android/app/src/main/res/values-night**

	```xml
	<!--START Minkasu2FA -->
	<color  name="mkActionBarColor">#3F51B5</color>
	<color  name="mkActionBarTextColor">#ffffff</color>
	<!--END Minkasu2FA -->
	```

 	If you are using ProGuard, add the following lines in its configuration.

	```
 	-keep class minkasu2fa.** { *; }
	-keep class com.minkasu.android.twofa.** { *; }
 	```
 
4.  **iOS Configurations**

	Add `NSFaceIDUsageDescription` to `Info.plist`

	```swift
	<key>NSFaceIDUsageDescription</key>
	<string>Please allow AppName to use Face ID.</string>
	```

	Update the `Podfile` located at **ios/Podfile** to ensure the project supports iOS 13.0+. Add or modify the following line:

	```ruby
	platform :ios, '13.0'
	```

### Minkasu2FA Models

1.  **Minkasu2FAConfig**

| Properties | Type | Required | Description |
| ------------- |:-------------:| -----:|:------------- |
| id | String | :white_check_mark: | Merchant’s Id (Contact Minkasu, Inc.) |
| token | String | :white_check_mark: | Merchant’s Access Token (Contact Minkasu, Inc.) |
| merchantCustomerId | String | :white_check_mark: | Merchant’s Customer Id is a Unique Id assigned by the Merchant to every customer |
| customerInfo | Minkasu2FACustomerInfo | :white_check_mark: | Customer’s info |
| orderInfo | Minkasu2FAOrderInfo | :white_check_mark: | Order info |
| sdkMode | Integer | :white_large_square: | Set PRODUCTION_MODE or SANDBOX_MODE. Default is PRODUCTION_MODE. |
| customTheme | Minkasu2FACustomTheme | :white_large_square: | Custom theme applied to iOS. For android update the `colors.xml` file

2.  **Minkasu2FACustomerInfo**

| Properties | Type | Required | Description |
| ------------- |:-------------:| -----:|:------------- |
| firstName | String | :white_check_mark: | Customer’s First Name |
| lastName | String | :white_check_mark: | Customer’s Last Name |
| middleName | String | :white_large_square: | Customer’s Middle Name |
| email | String | :white_check_mark: | Customer’s Email |
| phone | String | :white_check_mark: | Customer’s Phone Number Format: +91XXXXXXXXXX |
| address | Minkasu2FAAddress | :white_large_square: | Customer’s Address |

3.  **Minkasu2FAAddress**

| Properties | Type | Required | Description |
| ------------- |:-------------:| -----:|:------------- |
| line1 | String | :white_large_square: | Address Line 1 |
| line2 | String | :white_large_square: | Address Line 2 |
| line3 | String | :white_large_square: | Address Line 3 |
| city | String | :white_large_square: | City |
| state | String | :white_large_square: | State Format: Unabbreviated |
| zipCode | String | :white_large_square: | Zip Code Format: XXXXXX |
| country | String | :white_large_square: | Country |

  

4.  **Minkasu2FAOrderInfo**

| Properties | Type | Required | Description |
| ------------- |:-------------:| -----:|:------------- |
| orderId | String | :white_check_mark: | Merchant’s Order Id (or other unique Id) to identify the transaction |
| billingCategory | String | :white_large_square: | Merchant’s Billing Category to identify the type of transaction for billing purposes, if applicable |
| orderDetails | String | :white_large_square: | Any custom order data to be attributed to the transaction |

  

5.  **Minkasu2FACustomTheme**

| Properties | Type | Required | Description |
| ------------- |:-------------:| -----:|:------------- |
| navigationBarColor | Color | :white_check_mark: | Background colour of the navigation bar |
| navigationBarTextColor | Color | :white_check_mark: | Text colour of the navigation bar text |
| darkModeNavigationBarColor | Color | :white_large_square: | Background colour of the navigation bar in dark theme |
| darkModeNavigationBarTextColor | Color | :white_large_square: | Text colour of the navigation bar text in dark theme |
| supportDarkMode | bool | :white_large_square: | Set `true` to enable dark theme support |
  

6.  **Minkasu2FAOperationType Enum**

| Operations |
| ----------------|
| changePayPin |
| enableBiometry |
| disableBiometry |

  

### Integration

`minkasu2fa_flutter_plugin` depends on the `webview_flutter` package and when initialising the `Minkasu2FA SDK` it expects a `WebViewController` created using the `webview_flutter` package.

  

1.  **Creating the Config Object**

  

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
	phone: "+919876543210",
	address: address,
);

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

const customTheme = Minkasu2FACustomTheme(
	navigationBarColor: Colors.blue,
	navigationBarTextColor: Colors.yellow,
	//Use this to set a separate color theme for Dark mode
	darkModeNavigationBarColor: Colors.yellow,
	darkModeNavigationBarTextColor: Colors.green,
	supportDarkMode: true, // Set supportDarkMode to true if the Merchant App supports Dark Mode
);

final config = Minkasu2FAConfig(
	id: <merchant_id>,
	merchantCustomerId: <merchant_customer_id>,
	customerInfo: customer,
	orderInfo: order,
	token: <merchant_access_token>,
	sdkMode: Minkasu2FAConfig.SANDBOX_MODE, //set sdkMode to SANDBOX_MODE if testing on sandbox
	customTheme: customTheme,
);

```


2.  **Initialising the `Minkasu2FA SDK`**

```dart
import 'package:minkasu2fa_flutter_plugin/minkasu2fa_flutter_plugin.dart';
import 'package:minkasu2fa_flutter_plugin/minkasu2fa_models.dart';

void  minkasu2FACallback(Minkasu2FACallbackInfo minkasuCallbackInfo) {
	if (minkasuCallbackInfo.infoType == 1) {
		// INFO_TYPE_RESULT
	} else  if (minkasuCallbackInfo.infoType == 2) {
		// INFO_TYPE_EVENT
	} else  if (minkasuCallbackInfo.infoType == 3) {
		// INFO_TYPE_PROGRESS
	}
}

void  initialiseSDK() async {
	final _minkasu2FA = Minkasu2FAFlutterPlugin();
	try {
		final result = await _minkasu2FA.init(
			_controller, // WebViewController instance
			config, // Minkasu2FAConfig instance
			minkasu2FACallback, // Callback function to handle SDK events
		);
	} catch (_) {}
}
```

3.  **[OPTIONAL] Retrieving and Performing `Minkasu2FA` Operations**

```dart
import 'package:minkasu2fa_flutter_plugin/minkasu2fa_flutter_plugin.dart';
import 'package:minkasu2fa_flutter_plugin/minkasu2fa_models.dart';

final _minkasu2FA = Minkasu2FAFlutterPlugin();

void  fetchOperations() async {
	try {
		final ops = await _minkasu2FA.getAvailableMinkasu2FAOperations();
	} catch (_) {}
}

void  performOperation() async {
	final merchantCustomerId = "<merchant-customer-id>";
	const operation = Minkasu2FAOperationType.changePayPin;
	try {
		final result = await _minkasu2FA.performMinkasu2FAOperation(
			operation,
			merchantCustomerId,
			const  Minkasu2FACustomTheme(
				navigationBarColor: Colors.red,
				navigationBarTextColor: Colors.green,
				//Use this to set a separate color theme for Dark mode
				darkModeNavigationBarColor: Colors.yellow,
				darkModeNavigationBarTextColor: Colors.green,
				supportDarkMode: true, // Set supportDarkMode to true if the Merchant App supports Dark Mode
			),
		);
	} catch (_) {}
}
```

Please make sure the `merchantCustomerId` is a unique id associated with the currently logged in user, and is the same id used in the payment flow.

---
