# Minkasu2FA iOS SDK

## Setup

- The minimum requirements for the SDK are:
   - iOS 13.0 and higher
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

//Set supportDarkMode to true if the Merchant App supports Dark Mode
mkcolorTheme.supportDarkMode = true;

//Use this to set a separate color theme for Dark mode
mkcolorTheme.darkModeNavigationBarColor = UIColor.purpleColor;
mkcolorTheme.darkModeNavigationBarTextColor = UIColor.whiteColor;
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
    config._id = <merchant_id>;
    config.token = <merchant_access_token>;
    config.merchantCustomerId =<merchant_customer_id>;
    //add customer to the Config object
    config.customerInfo = customer;

    Minkasu2FAOrderInfo *orderInfo = [Minkasu2FAOrderInfo new];
    orderInfo.orderId = <order_id>;
    // Optionally specify billing category and order details
    orderInfo.billingCategory = <billing_category>; // e.g. “FLIGHTS”
    NSDictionary *orderDetails=[[NSDictionary alloc] init]; // e.g. @{<custom_key_1> : <custom_value_1>, <custom_key_2> : <custom_value_2>, <custom_key_3> : <custom_value_3>};
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

    //Set supportDarkMode to true if the Merchant App supports Dark Mode
    mkcolorTheme.supportDarkMode = true;
     
    //Use this to set a separate color theme for Dark mode
    mkcolorTheme.darkModeNavigationBarColor = UIColor.purpleColor;
    mkcolorTheme.darkModeNavigationBarTextColor = UIColor.whiteColor;
    
    config.customTheme = mkcolorTheme;

    //set sdkMode to MINKASU2FA_SANDBOX_MODE if testing on sandbox
    config.sdkMode = MINKASU2FA_SANDBOX_MODE;

    //Initializing Minkasu2FA SDK with WKWebView object
    if (@available(iOS 13, *)){
        NSError *error = nil;
        BOOL result = [Minkasu2FA initWithWKWebView:_wkWebView andConfiguration:config error:&error];
        if (result) {
            //Minkasu init success
        } else {
            //Minkasu init failed - handle error
            NSLog(@"Minkasu init failed with error domain: %@ and description: %@",error.domain,error.localizedDescription);
        }
    }

}
```

- Make sure that your merchant_access_token and merchant_id are correct.
- merchant_customer_id is a unique id associated with the currently logged in user
- Initialize the SDK by calling ```[self initMinkasu2FA];``` before the Payment is initiated.

## Implementing Minkasu2FACallback Delegate Method

1.&emsp;Conforming to Minkasu2FACallbackDelegate Protocol ```<Minkasu2FACallbackDelegate>``` on your ViewController class which initializes Minkasu2FA iOS SDK.<br>
2.&emsp;Setting the delegate in Minkasu2FAConfig. ``` config.delegate = self;```<br>
3.&emsp;Implementing Minkasu2FACallback delegate method.

```Objective-C
- (void)minkasu2FACallback:(Minkasu2FACallbackInfo *)minkasu2FACallbackInfo {
    
    if (minkasu2FACallbackInfo.infoType == 1) { // INFO_TYPE_RESULT
        // Refer data format in table below
    } else if (minkasu2FACallbackInfo.infoType == 2) { // INFO_TYPE_EVENT
        // Refer data format in table below
    } else if (minkasu2FACallbackInfo.infoType == 3) { // INFO_TYPE_PROGRESS
        // Refer data format in table below
    } 
}
```
Class Minkasu2faCallbackInfo

| <br>Parameter    |    <br>Type     |    <br>Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   |
|------------------|-----------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| infoType         | int             | INFO_TYPE_RESULT(1) or INFO_TYPE_EVENT(2)   or INFO_TYPE_PROGRESS(3)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
| data             | NSDictionary    | If infoType is RESULT, the following Dictionary will be returned:<br>{<br>  &emsp;&emsp;"reference_id"&emsp;:(NSString *) <minkasu_transaction_ref>, <br>  &emsp;&emsp;"status”&emsp;&emsp;&emsp;&emsp;:(NSString *) [  SUCCESS<br>                                   &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;\| FAILED<br>                                   &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;\| TIMEOUT<br>                                   &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;\| CANCELLED<br>                                   &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;\| DISABLED ],<br>  &emsp;&emsp;"auth_type"&emsp;&emsp;  :(NSString *) [  PayPin<br>&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;\| Fingerprint<br>&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;\| Face ], <br>  &emsp;&emsp;"source"&emsp;&emsp;&emsp;&emsp;:(NSString *) [ SDK<br>&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;\| SERVER<br>&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;\| BANK ], <br>  &emsp;&emsp;"code"&emsp;&emsp;&emsp;&emsp;&emsp;:(NSInteger) <result/error_code>,<br>&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;0 – Success<br>&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;5001 - Phone number mismatch<br>&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;5500 - Screen   close<br>&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;5501 - Forgot PayPIN<br>                &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;6508 - PayPIN   attempts exceed<br>                 &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;6514 - Setup   code timeout<br>                     &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;6515 - OTP   attempts exceeded<br>                   &emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;6518 - Insufficient   balance     <br>  &emsp;&emsp;"message"&emsp;&emsp;&emsp;:(NSString *) <result/error_message> // See above messages<br>}<br>   <br>If infoType is EVENT, the following Dictionary will be returned:<br>{<br>&emsp;&emsp;"reference_id"&emsp;:(NSString *) <minkasu_transaction_ref>, <br>&emsp;&emsp;"screen"&emsp;&emsp;&emsp;&emsp;:(NSString *) [ FTU_SETUP_CODE_SCREEN<br>&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;\| FTU_AUTH_SCREEN<br>&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;\| REPEAT_AUTH_SCREEN ],<br>  &emsp;&emsp;"event"&emsp;&emsp;&emsp;&emsp;:(NSString *) ENTRY <br>}<br> <br>If infoType is PROGRESS, the following Dictionary will be returned:<br>{<br>&emsp;&emsp;"reference_id" &emsp;&emsp;&emsp;&emsp; :(NSString *) <minkasu_transaction_ref>, <br>&emsp;&emsp;"visibility" &emsp;&emsp;&emsp;&emsp;&emsp; &emsp; :(BOOL) <true/false>,<br>  &emsp;&emsp;"start_timer" &emsp;&emsp;&emsp;&emsp;&emsp; :(BOOL) <true/false>, <br>  &emsp;&emsp;"redirect_url_loading" &emsp;:(BOOL) <true/false> <br>} |

## [OPTIONAL] Retrieving Operations

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

## [OPTIONAL] Implementing Operations

Implement the following code to execute an operation.

```Objective-C
//Use this to set custom color theme
Minkasu2FACustomTheme *mkcolorTheme = [Minkasu2FACustomTheme new];
mkcolorTheme.navigationBarColor = UIColor.blueColor;
mkcolorTheme.navigationBarTextColor = UIColor.whiteColor;

//Set supportDarkMode to true if the Merchant App supports Dark Mode
mkcolorTheme.supportDarkMode = true;

//Use this to set a separate color theme for Dark mode
mkcolorTheme.darkModeNavigationBarColor = UIColor.purpleColor;
mkcolorTheme.darkModeNavigationBarTextColor = UIColor.whiteColor;

[Minkasu2FA performMinkasu2FAOperation:<Minkasu2faOperationType> merchantCustomerId:<merchant_customer_id> customTheme:mkcolorTheme];
```

Please make sure the merchant_customer_id is a unique id associated with the currently logged in user, and is the same id used in the payment flow.

## Revision History
| **Version**     | **Date**            | **Summary of Change**                                                                                                                                                                                                                                                                                                                               | **Prepared By**                            | **Approved By**                       |
|:-----------:    |-----------------    |-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    |----------------------------------------    |-----------------------------------    |
|  <br>4.0.0      |  <br>27 Sept 2024    | <br>• Updated color theme to remove button color customization                                   | <br>Habibur <br>Rahuman<br>[Tech Lead]     | <br>Naveen<br>Doraiswamy<br>[CTO]     |
|  <br>3.2.1      |  <br>30 Apr 2024     | <br>• No Changes                                   | <br>Habibur <br>Rahuman<br>[Tech Lead]     | <br>Naveen<br>Doraiswamy<br>[CTO]     |
|  <br>3.2.0      |  <br>26 Feb 2024     | <br>• Enhanced Minkasu2FACallbackInfo to support INFO_TYPE_PROGRESS to indicate whether Merchant's iOS App should show/dismiss progress indicator before/after the Minkasu 2FA flow.                                                                                                                                                                                                                                                                         | <br>Habibur <br>Rahuman<br>[Tech Lead]     | <br>Naveen<br>Doraiswamy<br>[CTO]     |
|  <br>3.1.0      |  <br>4 Jun 2023     | <br>• The minimum requirement for the SDK changed to<br>iOS 13.0 and higher.                                                                                                                                                                                                                                                                         | <br>Habibur <br>Rahuman<br>[Tech Lead]     | <br>Naveen<br>Doraiswamy<br>[CTO]     |
|  <br>3.0.0      | <br>13 Dec 2022     | • Minkasu Config Object merchantId changed<br>to _id and merchantToken changed to token.<br><br>• Enhanced OrderInfo object to accept <br>order details and billing category.<br><br>• Handle NSError when initializing Minkasu SDK.<br>[Minkasu initWithWKWebView]<br><br>• Optional method to initialize the SDK <br>with Minkasu2FACallback.     | <br>Habibur <br>Rahuman<br>[Tech Lead]     | <br>Naveen<br>Doraiswamy<br>[CTO]     |


