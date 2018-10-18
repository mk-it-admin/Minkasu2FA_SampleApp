# Minkasu2FA_iOS_SDK

## Setup

- The minimum requirements for the SDK are:
   - iOS 10.0 and higher
   - Internet connection
- The following architectures are supported in the SDK:
   - armv7 and arm64 for devices
   - i386 and x86_64 for iOS simulator

## Integrations

### Getting the SDK

#### Using Cocoapods (recommended)

1. Navigate to iOS Xcode project directory in Terminal
2. Run ```pod init``` to  create a Podfile.
3. Add ```pod 'Minkasu2FA'``` to your Podfile. Please specify a particular pod version.
4. Run ```pod install``` in Terminal.
5. Close the Xcode project window if open, and open the Project Workspace.

#### Manual way

Please ask Minkasu for Minkasu2FA SDK

1. Open the iOS project in Xcode.
2. Drop Minkasu2FA.framework bundle under Embedded Binaries of the Project Settings
4. Make sure 'Copy items if needed' is checked.

### Project Setup

Add NSFaceIDUsageDescription to Info.plist

```xml
<key>NSFaceIDUsageDescription</key>
<string>Please allow AppName to use Face ID.</string>
```

## Initializing the SDK for WKWebView Based integration

- Import ```<Minkasu2FA/Minkasu2FAHeader.h>``` in the ViewController that holds the WKWebView.
- Initialize the WKWebView object.
- Add following code to your ViewController to inialize Minkasu2FA SDK with the WKWebView object. The following code must be executed before making a payment to enable Minkasu 2FA.

```Objective-C
- (void) initMinkasu2FA{
    //initialize Minkasu2FA Customer object
    Minkasu2FACustomerInfo *customer = [Minkasu2FACustomerInfo new];
    customer.firstName = @"TestFirstName";
    customer.lastName = @"TestLastName";
    customer.email = @"test@asd.com";
    customer.phone = @"+919876543210";

    Minkasu2FAAddress *address = [Minkasu2FAAddress new];
    address.line1 = @"123 Test way";
    address.line2 = @"Test Apartments";
    address.city = @"Mumbai";
    address.state = @"Maharashtra";
    address.country= @"India";
    address.zipCode = @"400068";
    customer.address = address;

    //Create the Config object with merchant_id, merchant_access_token, merchant_customer_id and customer object.
    //merchant_customer_id is a unique id associated with the currently logged in user.
    Minkasu2FAConfig *config = [Minkasu2FAConfig new];
    config.merchantId = <merchant_id>;
    config.merchantToken = <merchant_access_token>;
    config.merchantCustomerId =<merchant_customer_id>;
    //add customer to the Config object
    config.customerInfo = customer;

    Minkasu2FAOrderInfo *orderInfo = [Minkasu2FAOrderInfo new];
    orderInfo.orderId = <order_id>;
    config.orderInfo = orderInfo;

    //Use this to set custom color theme
    Minkasu2FACustomTheme *mkcolorTheme = [Minkasu2FACustomTheme new];
    mkcolorTheme.navigationBarColor = UIColor.blueColor;
    mkcolorTheme.navigationBarTextColor = UIColor.whiteColor;
    mkcolorTheme.buttonBackgroundColor = UIColor.blueColor;
    mkcolorTheme.buttonTextColor = UIColor.whiteColor;
    config.customTheme = mkcolorTheme;

    //set sdkMode to MINKASU2FA_SANDBOX_MODE if testing on sandbox
    config.sdkMode = MINKASU2FA_SANDBOX_MODE;

    //Initializing Minkasu2FA SDK with WKWebView object
    [Minkasu2FA initWithWKWebView:_wkWebView andConfiguration:config];
}
```

- Make sure that your merchant_access_token and merchant_id are correct.
- merchant_customer_id is a unique id associated with the currently logged in user
- Initialize the SDK by calling ```[self initMinkasu2FA];``` before the Payment is initiated.
