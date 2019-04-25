# Minkasu2FA iOS SDK

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
3. Add ```pod 'Minkasu2FA'``` to your Podfile.
4. Run ```pod install``` in Terminal.
5. Close the Xcode project window if open, and open the Project Workspace.

#### Manual way

Please ask Minkasu for Minkasu2FA SDK

1. Open the iOS project in Xcode.
2. Drop Minkasu2FA.framework bundle under Embedded Binaries of the Project Settings
3. Make sure 'Copy items if needed' is checked.

### Project Setup

Add NSFaceIDUsageDescription to Info.plist

```xml
<key>NSFaceIDUsageDescription</key>
<string>Please allow AppName to use Face ID.</string>
```

## Initializing the SDK for UIWebView Based integration

- Import ```<Minkasu2FA/Minkasu2FAHeader.h>``` in the ViewController that holds the UIWebView and AppDelegate.m of the project.
- Add ```[Minkasu2FA registerMinkasu2FACustomUserAgent];``` to the following method in AppDelegate.m to add Minkas2FA Custom UserAgent to the WebView
```Objective-C
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [Minkasu2FA registerMinkasu2FACustomUserAgent];

    return YES;
}
```
- Initialize the UIWebView object.
- Add the following code to customize the look and feel of Minkasu2FA SDK as part of Minkasu2FAConfig initialization.

```Objective-C
//Use this to set custom color theme
Minkasu2FACustomTheme *mkcolorTheme = [Minkasu2FACustomTheme new];
mkcolorTheme.navigationBarColor = UIColor.blueColor;
mkcolorTheme.navigationBarTextColor = UIColor.whiteColor;
mkcolorTheme.buttonBackgroundColor = UIColor.blueColor;
mkcolorTheme.buttonTextColor = UIColor.whiteColor;
```
- Add following code to your ViewController to initialize Minkasu2FA SDK. You can initialize Minkasu2FA SDK with the UIWebView object and merchant's ViewController or just the UIWebView object. The following code must be executed before making a payment to enable Minkasu 2FA.

```Objective-C
- (void) initMinkasu2FA{
    //initialize Minkasu2FA Customer object
    Minkasu2FACustomerInfo *customer = [Minkasu2FACustomerInfo new];
    customer.firstName = @"TestFirstName";
    customer.lastName = @"TestLastName";
    customer.email = @"test@xyz.com";
    customer.phone = @"+919876543210";          // Format: +91XXXXXXXXXX (no spaces)

    Minkasu2FAAddress *address = [Minkasu2FAAddress new];
    address.line1 = @"123 Test Way";
    address.line2 = @"Test Apartments";
    address.city = @"Mumbai";
    address.state = @"Maharashtra";             // Unabbreviated e.g. Maharashtra (not MH)
    address.country= @"India";
    address.zipCode = @"400068";                // Format: XXXXXX (no spaces)
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

    //Initializing Minkasu2FA SDK with UIWebView object and the ViewController containing the UIWebView
    [Minkasu2FA initWithUIWebView:_uiWebView andConfiguration:config inViewController:self];
}
```

- Make sure that your merchant_access_token and merchant_id are correct.
- merchant_customer_id is a unique id associated with the currently logged in user
- Make the ViewController the delegate for the UIWebView object

```Objective-C
_uiWebView.delegate = self;
```

- Implement UIWebViewDelegate method shown below and add the following code.

```Objective-C
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //Return YES or NO based on wether the request is a Minkasu 2FA Bridge Function
    return ![Minkasu2FA request:request shouldHandleByMinkasu2FAInWebView:webView navigationType:navigationType];
}
```

- Initialize the SDK by calling ```[self initMinkasu2FA];``` before the Payment is initiated.

## Retrieving Operations

Following is the list of Minkasu 2FA Operations available.

Typedef ```Minkasu2FAOperationType```

| OPERATION TYPE  | Type | Description |
| ------------- | ------------- | ------------- |
| CHANGE_PIN  | Minkasu2FAOperationType  | Change pin operation to change the existing pin to a new one |
| ENABLE_BIOMETRY  | Minkasu2FAOperationType  | Enable biometry operation |
| DISABLE_BIOMETRY  | Minkasu2FAOperationType  | Disable biometry operation |

To retrieve the list of operations, execute the following code to get the current list of operations available depending on the state of the Minkasu2FA SDK.

```Objective-C
NSMutableArray *minkasu2FAOperations = [Minkasu2FA getAvailableMinkasu2FAOperations];
```

## Implementing Operations

Implement the following code to execute an operation.

```Objective-C
//Use this to set custom color theme
Minkasu2FACustomTheme *mkcolorTheme = [Minkasu2FACustomTheme new];
mkcolorTheme.navigationBarColor = UIColor.blueColor;
mkcolorTheme.navigationBarTextColor = UIColor.whiteColor;
mkcolorTheme.buttonBackgroundColor = UIColor.blueColor;
mkcolorTheme.buttonTextColor = UIColor.whiteColor;

[Minkasu2FA performMinkasu2FAOperation:<Minkasu2faOperationType> merchantCustomerId:<merchant_customer_id> customTheme:mkcolorTheme];
```

Please make sure the merchant_customer_id is a unique id associated with the currently logged in user, and is the same id used in the payment flow.
