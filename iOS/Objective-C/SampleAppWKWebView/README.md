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

## Initializing the SDK for WKWebView Based integration

- Import ```<Minkasu2FA/Minkasu2FAHeader.h>``` in the ViewController that holds the WKWebView.
- Initialize the WKWebView object.
- Add the following code to customize the look and feel of Minkasu2FA SDK as part of Minkasu2FAConfig initialization.

```Objective-C
//Use this to set custom color theme
Minkasu2FACustomTheme *mkcolorTheme = [Minkasu2FACustomTheme new];
mkcolorTheme.navigationBarColor = UIColor.blueColor;
mkcolorTheme.navigationBarTextColor = UIColor.whiteColor;
mkcolorTheme.buttonBackgroundColor = UIColor.blueColor;
mkcolorTheme.buttonTextColor = UIColor.whiteColor;

//Set supportDarkMode to true if the Merchant App supports Dark Mode
mkcolorTheme.supportDarkMode = true;

//Use this to set a separate color theme for Dark mode
mkcolorTheme.darkModeNavigationBarColor = UIColor.purpleColor;
mkcolorTheme.darkModeNavigationBarTextColor = UIColor.whiteColor;
mkcolorTheme.darkModeButtonBackgroundColor = UIColor.purpleColor;
mkcolorTheme.darkModeButtonTextColor = UIColor.whiteColor;
```

- Add following code to your ViewController to initialize Minkasu2FA SDK. You can initialize Minkasu2FA SDK with the WKWebView object and merchant's ViewController. The following code must be executed before making a payment to enable Minkasu 2FA.

```Objective-C
- (void) initMinkasu2FA{
    //initialize Minkasu2FA Customer object
    Minkasu2FACustomerInfo *customer = [Minkasu2FACustomerInfo new];
    customer.firstName = @"TestFirstName";
    customer.lastName = @"TestLastName";
    customer.email = @"test@xyz.com";
    customer.phone = @"+919876543210";  // Format: +91XXXXXXXXXX (no spaces)

    Minkasu2FAAddress *address = [Minkasu2FAAddress new];
    address.line1 = @"123 Test Way";
    address.line2 = @"Test Apartments";
    address.city = @"Mumbai";
    address.state = @"Maharashtra";     // Unabbreviated e.g. Maharashtra (not MH)
    address.country= @"India";
    address.zipCode = @"400068";        // Format: XXXXXX (no spaces)
    customer.address = address;

    //Create the Config object with merchant_id, merchant_access_token, merchant_customer_id and customer object.
    //merchant_customer_id is a unique id associated with the currently logged in user.
    Minkasu2FAConfig *config = [Minkasu2FAConfig new];
    config.delegate = self;            // Minkasu2FACallbackDelegate
    config._id = <merchant_id>;
    config.token = <merchant_access_token>;
    config.merchantCustomerId =<merchant_customer_id>;
    //add customer to the Config object
    config.customerInfo = customer;

    Minkasu2FAOrderInfo *orderInfo = [Minkasu2FAOrderInfo new];
    orderInfo.orderId = <order_id>;
    orderInfo.billingCategory = <billing_category>; // e.g. “FLIGHTS”
    NSDictionary *orderDetails=[[NSDictionary alloc] init]; // e.g. Order Details Dictionary
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:orderDetails
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    orderInfo.orderDetails = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    config.orderInfo = orderInfo;

    //Use this to set custom color theme
    Minkasu2FACustomTheme *mkcolorTheme = [Minkasu2FACustomTheme new];
    mkcolorTheme.navigationBarColor = UIColor.blueColor;
    mkcolorTheme.navigationBarTextColor = UIColor.whiteColor;
    mkcolorTheme.buttonBackgroundColor = UIColor.blueColor;
    mkcolorTheme.buttonTextColor = UIColor.whiteColor;

    //Set supportDarkMode to true if the Merchant App supports Dark Mode
    mkcolorTheme.supportDarkMode = true;
     
    //Use this to set a separate color theme for Dark mode
    mkcolorTheme.darkModeNavigationBarColor = UIColor.purpleColor;
    mkcolorTheme.darkModeNavigationBarTextColor = UIColor.whiteColor;
    mkcolorTheme.darkModeButtonBackgroundColor = UIColor.purpleColor;
    mkcolorTheme.darkModeButtonTextColor = UIColor.whiteColor;
    
    config.customTheme = mkcolorTheme;

    //set sdkMode to MINKASU2FA_SANDBOX_MODE if testing on sandbox
    config.sdkMode = MINKASU2FA_SANDBOX_MODE;

    NSError *error = nil;
    //Initializing Minkasu2FA SDK with WKWebView object
    BOOL result = [Minkasu2FA initWithWKWebView:_wkWebView andConfiguration:config error:&error];
    if (result) {
        //Minkasu init success
    } else {
        //Minkasu init failed - handle error
    }
}
```

- Make sure that your merchant_access_token and merchant_id are correct.
- merchant_customer_id is a unique id associated with the currently logged in user
- Initialize the SDK by calling ```[self initMinkasu2FA];``` before the Payment is initiated.

## Implementing Minkasu2FA Callback Delegate

1.Conforming to Minkasu2FACallbackDelegate Protocol on your ViewController class which initialize Minkasu2FA iOS SDK. ```<Minkasu2FACallbackDelegate>```
2.Setting the delegate in Minkasu2FA config. ``` config.delegate = self;```
3.Implementing Minkasu2FACallback delegate method.

```Objective-C
- (void)minkasu2FACallback:(Minkasu2FACallbackInfo *)minkasu2FACallbackInfo{
    
    if (minkasu2FACallbackInfo.infoType == 1) { // INFO_TYPE_RESULT
        // Refer data format in table below
    } else if (minkasu2FACallbackInfo.infoType == 2) { // INFO_TYPE_EVENT
        // Refer data format in table below
    }
}
```
Class Minkasu2faCallbackInfo
|    <br>Parameter        |    <br>Type            |    <br>Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|-------------------------|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| infoType<br>   <br>     |    <br>int             |    <br>INFO_TYPE_RESULT or INFO_TYPE_EVENT                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| data<br>   <br>         |    <br>NSDictionary    |    <br>If infoType is RESULT, the following Dictionary is returned:{<br>  "reference_id"    : <minkasu_transaction_ref>, <br>  "status"          : <SUCCESS\|FAILED\| TIMEOUT\|CANCELLE DISABLED>",<br>  "source"          : <PayPin\|Fingerprint\|Face>", <br>  "source"          : <SDK\|SERVER\|BANK>", <br>  "code"            : <result/error_code>, <br>                           0    – Success<br>                           5001 - Phone number mismatch<br>                           5500 - Screen   close<br>                           5501 - Forgot PayPIN;<br>                           6508 - PayPIN   attempts exceed<br>                           6514 - Setup   code timeout<br>                           6515 - OTP   attempts exceeded<br>                           6518 - Insufficient   balance     <br>  "message"         : <result/error_message> // See above messages<br>}<br>   <br> <br>If infoType is EVENT, the following Dictionary will be returned:{<br>   "reference_id"   : <minkasu_transaction_ref>,<br>   "screen"         : <FTU_SETUP_CODE_SCREEN\|FTU_AUTH_SCREEN\|REPEAT_AUTH_SCREEN>,<br>   "event"          : <ENTRY><br>} |
|                         |    <br>                |    <br> 

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

//Set supportDarkMode to true if the Merchant App supports Dark Mode
mkcolorTheme.supportDarkMode = true;

//Use this to set a separate color theme for Dark mode
mkcolorTheme.darkModeNavigationBarColor = UIColor.purpleColor;
mkcolorTheme.darkModeNavigationBarTextColor = UIColor.whiteColor;
mkcolorTheme.darkModeButtonBackgroundColor = UIColor.purpleColor;
mkcolorTheme.darkModeButtonTextColor = UIColor.whiteColor;

[Minkasu2FA performMinkasu2FAOperation:<Minkasu2faOperationType> merchantCustomerId:<merchant_customer_id> customTheme:mkcolorTheme];
```

Please make sure the merchant_customer_id is a unique id associated with the currently logged in user, and is the same id used in the payment flow.
