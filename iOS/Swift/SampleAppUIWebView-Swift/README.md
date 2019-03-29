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

### Working with Swift

- You can easily use the SDK with Swift using Objective-C Bridging Header. Apple has some nice documentation on subject. 
- To begin, create a new file (File > New > File > iOS > Source > Header File) and name it YourProjectName-Bridging-Header.h.
- Open the file and insert following line to it:

[YourProjectName-Bridging-Header.h]()
```Objective-C
#import <Minkasu2FA/Minkasu2FAHeader.h>
```

- Next, go to your project's build settings, and type "bridging" to filter options. Look for an option named Objective-C Bridging Header and set its value to path of your file. 

## Initializing the SDK for UIWebView Based integration

- Import ```import Minkasu2FA``` in the ViewController that holds the UIWebView and AppDelegate.m of the project.
- Add ```Minkasu2FA.registerCustomUserAgent()``` to the following method in AppDelegate.m to add Minkas2FA Custom UserAgent to the WebView
```Swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.

    Minkasu2FA.registerCustomUserAgent()

    return true
}
```
- Initialize the UIWebView object.
- Add following code to your ViewController to inialize Minkasu2FA SDK with the UIWebView object. The following code must be executed before making a payment to enable Minkasu 2FA.

```Swift
func initMinkasu2FA(){
    //Initialize Customer object
    let customer = Minkasu2FACustomerInfo()
    customer.firstName = "TestFirstName"
    customer.lastName = "TestLastName"
    customer.email = "test@xyz.com"
    customer.phone = "+919876543210"        // Format: +91XXXXXXXXXX (no spaces)

    let address = Minkasu2FAAddress()
    address.line1 = "123 Test Way"
    address.line2 = "Test Apartments"
    address.city = "Mumbai"
    address.state = "Maharashtra"           // Unabbreviated e.g. Maharashtra (not MH)
    address.country = "India"
    address.zipCode = "400068"              // Format: XXXXXX (no spaces)
    customer.address = address

    //Create the Config object with merchant_id, merchant_access_token, merchant_customer_id and customer object.
    //merchant_customer_id is a unique id associated with the currently logged in user.
    let config = Minkasu2FAConfig()
    config.merchantId = <merchant_id>
    config.merchantToken = <merchant_access_token>
    config.merchantCustomerId = <merchant_customer_id>
    //add customer to the Config object
    config.customerInfo = customer

    let orderInfo = Minkasu2FAOrderInfo()
    orderInfo.orderId = <order_id>
    config.orderInfo = orderInfo

    let mkColorTheme = Minkasu2FACustomTheme()
    mkColorTheme.navigationBarColor = UIColor.blue
    mkColorTheme.navigationBarTextColor = UIColor.white
    mkColorTheme.buttonBackgroundColor = UIColor.blue
    mkColorTheme.buttonTextColor = UIColor.white
    config.customTheme = mkColorTheme;

    //set sdkMode to MINKASU2FA_SANDBOX_MODE if testing on sandbox
    config.sdkMode = Minkasu2FASDKMode.MINKASU2FA_SANDBOX_MODE

    Minkasu2FA.initWith(uiWebView, andConfiguration: config)
}
```

- Make sure that your merchant_access_token and merchant_id are correct.
- merchant_customer_id is a unique id associated with the currently logged in user
- Make the ViewController the delegate for the UIWebView object

```Swift
uiWebView.delegate = self
```

- Implement UIWebViewDelegate method shown below and add the following code.

```Swift
func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
    //Return YES or NO based on wether the request is a Minkasu 2FA Bridge Function
    return !Minkasu2FA.request(request, shouldHandleByMinkasu2FAIn: webView, navigationType: navigationType)
}
```

- Initialize the SDK by calling ```initMinkasu2FA()``` before the Payment is initiated.

## Retrieving Operations

Following is the list of Minkasu 2FA Operations available.

Typedef ```Minkasu2FAOperationType```

| OPERATION TYPE  | Type | Description |
| ------------- | ------------- | ------------- |
| CHANGE_PIN  | Minkasu2FAOperationType  | Change pin operation to change the existing pin to a new one |
| ENABLE_BIOMETRY  | Minkasu2FAOperationType  | Enable biometry operation |
| DISABLE_BIOMETRY  | Minkasu2FAOperationType  | Disable biometry operation |

To retrieve the list of operations, execute the following code to get the current list of operations available depending on the state of the Minkasu2FA SDK.

```Swift
let minkasu2FAOperations = Minkasu2FA.getAvailableMinkasu2FAOperations()
```

## Implementing Operations

Implement the following code to execute an operation.

```Swift
//Use this to set custom color theme
let mkColorTheme = Minkasu2FACustomTheme();
mkColorTheme.navigationBarColor = UIColor.blue
mkColorTheme.navigationBarTextColor = UIColor.white
mkColorTheme.buttonBackgroundColor = UIColor.blue
mkColorTheme.buttonTextColor = UIColor.white

Minkasu2FA.perform(Minkasu2FAOperationType.<OPERATION TYPE>, merchantCustomerId: <merchant_customer_id>, customTheme: mkColorTheme)
```

Please make sure the merchant_customer_id is a unique id associated with the currently logged in user, and is the same id used in the payment flow.
