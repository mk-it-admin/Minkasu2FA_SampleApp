# React Native WebView With Minkasu2FA SDK Integration Guide
This document walks you through the steps to integrate Minkasu2FA Mobile SDK with React Native WebView.
## Contents
- [`Supported Platforms`](README.md#supported-platforms)
- [`Setup`](README.md#setup)
- [`Integration`](README.md#integration)

### Supported Platforms

- [x] iOS (12.0 and higher)
- [x] Android (API Level 21 and higher)

### Setup

#### 1. Add react-native-webview to your dependencies

The library [@mk-it-admin/react-native-webview](https://github.com/mk-it-admin/react-native-webview) is customized to support Minkasu2FA SDK by forking the [@react-native-webview/react-native-webview](https://github.com/react-native-webview/react-native-webview) library. Please ensure the previously installed `react-native-webview` is removed prior adding the forked library as dependency. 
If installed, remove react-native-webview to your dependencies by running:
```
$ npm uninstall --save react-native-webview
```
or 
```
$ yarn remove react-native-webview
```

Note: The existing properties and methods of `@react-native-webview/react-native-webview` can be used in your application.

#### 2. Add this @mk-it-admin/react-native-webview to your dependencies
```
$ npm install --save mk-it-admin/react-native-webview.git#Minkasu2FAv2.0.0
```

#### 3. Native Dependenices

Since the library is built based on react-native >0.60, autolinking will take care of the link step, but don't forget to run `pod install`

**iOS**

In the ios/ directory run:
```
$ pod install
```
**Android**

Please make sure AndroidX is enabled in your project by editting `android/gradle.properties` and adding 2 lines:
```
android.useAndroidX=true
android.enableJetifier=true
```

Add the following lines to your project `build.gradle` file at the path **android/**:

```xml
allprojects {
    repositories {
      ...
      mavenCentral()
      ...
   }
}
```

Add the following lines to your `AndroidManifest.xml` file at the path **android/app/src/main**:

```java
<activity
   android:name="com.minkasu.android.twofa.sdk.MinkasuSDKActivity"
   android:configChanges="keyboard|orientation|screenSize|screenLayout|keyboardHidden|uiMode|layoutDirection|smallestScreenSize"
   android:theme="@style/Mk2FASDKtheme" />
```
If you are using Proguard, add the following lines in its configuration

```
-keep class minkasu2fa.** { *; }
-keep class com.minkasu.android.twofa.** { *; }
```

The Minkasu2FA SDK screens can be customized to fit your application’s look and feel by specifying the Minkasu2FATheme as a parent style of your own theme. The following screen elements can be customized
- Action Bar: title color and action bar background

Add the following lines to your `styles.xml` file at the path **android/app/src/main/res/values**:

```xml
<!--START Minkasu2FA  -->
<style name="Mk2FASDKtheme" parent="Minkasu2FATheme">
 <!--Customize your theme here. -->
 <item name="colorPrimary">@color/mkActionBarColor</item>
</style>
<!--END Minkasu2FA  -->
```
Add the following lines to your `colors.xml` file for the light mode at the path **android/app/src/main/res/values**:

```xml
<!--START Minkasu2FA  -->
<color name="mkActionBarColor">#3F51B5</color>
<color name="mkActionBarTextColor">#ffffff</color>
<!--END Minkasu2FA  -->
```

Add the following lines to your `colors.xml(night)` file for the night mode at the path **android/app/src/main/res/values**:

```xml
<!--START Minkasu2FA  -->
<color name="mkActionBarColor">#3F51B5</color>
<color name="mkActionBarTextColor">#ffffff</color>
<!--END Minkasu2FA  -->
```

### Integration

There are two ways to integrate Minkasu2FA Mobile SDK with the WebView which are explained below.

Note: Check that the device is not jailbroken/rooted before creating the config object.

#### Minkasu2FA Config Object

To initialize the Minkasu2FA Mobile SDK, the config object is mandatory. The below list show the available properties in the config object

| Property Name                         | Type   | Required | Platform     |
| ------------------------------------- | ------ | -------- | ------------ |
| MERCHANT_ID                           | string | Yes      | Android, iOS |
| MERCHANT_TOKEN                        | string | Yes      | Android, iOS |
| CUSTOMER_ID                           | string | Yes      | Android, iOS |
| CUSTOMER_INFO                         | object | Yes      | Android, iOS |
| CUSTOMER_FIRST_NAME                   | string | Yes      | Android, iOS |
| CUSTOMER_LAST_NAME                    | string | Yes      | Android, iOS |
| CUSTOMER_EMAIL                        | string | Yes      | Android, iOS |
| CUSTOMER_PHONE                        | string | Yes      | Android, iOS |
| CUSTOMER_ADDRESS_INFO                 | object | No       | Android, iOS |
| CUSTOMER_ADDRESS_LINE_1               | string | No       | Android, iOS |
| CUSTOMER_ADDRESS_LINE_2               | string | No       | Android, iOS |
| CUSTOMER_ADDRESS_CITY                 | string | No       | Android, iOS |
| CUSTOMER_ADDRESS_STATE                | string | No       | Android, iOS |
| CUSTOMER_ADDRESS_COUNTRY              | string | No       | Android, iOS |
| CUSTOMER_ADDRESS_ZIP_CODE             | string | No       | Android, iOS |
| CUSTOMER_ORDER_INFO                   | object | Yes      | Android, iOS |
| CUSTOMER_ORDER_ID                     | string | Yes      | Android, iOS |
| CUSTOMER_BILLING_CATEGORY             | string | No       | Android, iOS |
| CUSTOMER_CUSTOM_DATA                  | string | No       | Android, iOS |
| SDK_MODE_SANDBOX                      | bool   | No       | Android, iOS |      
| SKIP_INIT                             | bool   | No       | Android, iOS |
| IOS_THEME_OBJ                         | object | No       | iOS          |
| NAVIGATION_BAR_COLOR                  | string | No       | iOS          |
| NAVIGATION_BAR_TEXT_COLOR             | string | No       | iOS          | 
| BUTTON_BACKGROUND_COLOR               | string | No       | iOS          |
| BUTTON_TEXT_COLOR                     | string | No       | iOS          |
| SUPPORT_DARK_MODE                     | bool   | No       | iOS          |
| DARK_MODE_NAVIGATION_BAR_COLOR        | string | No       | iOS          |
| DARK_MODE_NAVIGATION_BAR_TEXT_COLOR   | string | No       | iOS          |
| DARK_MODE_BUTTON_BACKGROUND_COLOR     | string | No       | iOS          |
| DARK_MODE_BUTTON_TEXT_COLOR           | string | No       | iOS          |

Here's the sample code to create the config object:

```jsx
import React, { Component } from 'react';
import { View, Button, Platform } from 'react-native';
import { WebView } from 'react-native-webview';

const Minkasu2FA = WebView.Minkasu2FA;
let Minkasu2FAConstants = Minkasu2FA.Constants;

class MyComponent extends Component {
    ...
    getiOSThemeObj = () => {
        return {
            //Use the following properties to set custom color theme
            [Minkasu2FAConstants.NAVIGATION_BAR_COLOR]: "#0433FF",
            [Minkasu2FAConstants.NAVIGATION_BAR_TEXT_COLOR]: "#FFFFFF",
            [Minkasu2FAConstants.BUTTON_BACKGROUND_COLOR]: "0433FF",
            [Minkasu2FAConstants.BUTTON_TEXT_COLOR]: "#FFFFFF",
            //Use the following properties to set a separate color theme for Dark Mode
            [Minkasu2FAConstants.DARK_MODE_NAVIGATION_BAR_COLOR]: "#942192",
            [Minkasu2FAConstants.DARK_MODE_NAVIGATION_BAR_TEXT_COLOR]: "#FFFFFF",
            [Minkasu2FAConstants.DARK_MODE_BUTTON_BACKGROUND_COLOR]: "#942192",
            [Minkasu2FAConstants.DARK_MODE_BUTTON_TEXT_COLOR]: "#FFFFFF",
            //Set supportDarkMode to true if the app supports Dark Mode
            [Minkasu2FAConstants.SUPPORT_DARK_MODE]: true
        }
    }

    createMinkasuConfigObj = () => {
        let customerInfo = {
            [Minkasu2FAConstants.CUSTOMER_FIRST_NAME]: "TestFirstName",
            [Minkasu2FAConstants.CUSTOMER_LAST_NAME]: "TestLastName",
            [Minkasu2FAConstants.CUSTOMER_EMAIL]: "test@xyz.com",
            [Minkasu2FAConstants.CUSTOMER_PHONE]: "<mobile_no>" // Format: +91XXXXXXXXXX (no spaces)
        };
        let addressInfo = {
            [Minkasu2FAConstants.CUSTOMER_ADDRESS_LINE_1]: "123 Test Way",
            [Minkasu2FAConstants.CUSTOMER_ADDRESS_LINE_2]: "Test Apartments",
            [Minkasu2FAConstants.CUSTOMER_ADDRESS_CITY]: "Mumbai",
            [Minkasu2FAConstants.CUSTOMER_ADDRESS_STATE]: "Maharastra",// Unabbreviated e.g. Maharashtra (not MH)
            [Minkasu2FAConstants.CUSTOMER_ADDRESS_COUNTRY]: "India",
            [Minkasu2FAConstants.CUSTOMER_ADDRESS_ZIP_CODE]: "400068"// Format: XXXXXX (no spaces)
        };
        /* let orderDetails = {
            "key1": "val1",
            "key2": "val2",
            "key3": "val3"
        }; */
        let orderInfo = {
            [Minkasu2FAConstants.CUSTOMER_ORDER_ID]: "<order_id>" // The order id is used to later identify
            //[MK2FAConstants.CUSTOMER_BILLING_CATEGORY]: "FLIGHT",
            //[MK2FAConstants.CUSTOMER_CUSTOM_DATA]: JSON.stringify(orderDetails),

        };
        let configObj = {
            [Minkasu2FAConstants.MERCHANT_ID]: "<merchant_id>",
            [Minkasu2FAConstants.MERCHANT_TOKEN]: "<merchant_token>",
            //merchant_customer_id is a unique id associated with the currently logged in user.
            [Minkasu2FAConstants.CUSTOMER_ID]: "<merchant_customer_id>",
            [Minkasu2FAConstants.CUSTOMER_INFO]: customerInfo,
            [Minkasu2FAConstants.CUSTOMER_ADDRESS_INFO]: addressInfo,
            [Minkasu2FAConstants.CUSTOMER_ORDER_INFO]: orderInfo,
            [Minkasu2FAConstants.SDK_MODE_SANDBOX]: true
        };
        if (Platform.OS === 'ios') {
            configObj[Minkasu2FAConstants.IOS_THEME_OBJ] = this.getiOSThemeObj();
        }
        return configObj;
    }
    ...
}
```

#### Handle Minkasu2FA Initialization Event

The initialization event of Minkasu2FA Mobile SDK will be captured by specifying the `onMinkasu2FAInit` props function.

**onMinkasu2FAInit**

Function that is invoked when the Webview completes the initialization of Minkasu2FA Mobile SDK.

| Type      |  Required |
| --------  |  -------- |
| function  |  Yes      |

Function passed to onMinkasu2FAInit is called with a SyntheticEvent wrapping a nativeEvent with these properties:

```
STATUS   
ERROR_MESSAGE      
ERROR_CODE         
INIT_TYPE
```

#### Handle Minkasu2FA Result Event

The result event of Minkasu2FA Mobile SDK will be captured by specifying the `onMinkasu2FAResult` props function.

**onMinkasu2FAResult**

Function that is invoked during the various points such as RESULT or EVENT or PROGRESS information of Minkasu2FA flow

| Type      |  Required |
| --------  |  -------- |
| function  |  Yes      |

Function passed to onMinkasu2FAResult is called with a SyntheticEvent wrapping a nativeEvent with these properties:

```
RESULT_INFO_TYPE   
RESULT_DATA
```

For sample code, please refer the below integration options.

#### Option 1: Using minkasu2FAConfig Props

This is the first option to intialize the Minkasu2FA Mobile SDK. Pass the config object to the `minkasu2FAConfig` props. Here's sample code to do that.

```jsx
import React, { Component } from 'react';
import { View, Alert } from 'react-native';
import WebView from 'react-native-webview';

const Minkasu2FA = WebView.Minkasu2FA;
let Minkasu2FAConstants = Minkasu2FA.Constants;

class Minkasu2FAAttributeFlowComponent extends Component {

    constructor(props) {
        super(props);
        this.webView = React.createRef();
        this.state = {
            sourceUrl: undefined,
            configObj: null,
            isCardEnabled: false
        }
    }

    componentDidMount() {
        try {
            const { route } = this.props;
            if (route && route.params) {
                this.setState({ configObj: route.params.configObj, isCardEnabled: route.params.isCardEnabled }, () => {
                    if (!this.state.configObj || this.state.configObj == null) {
                        this.setSourceUrl();
                    }
                })
            }
        }
        catch (e) {
            console.log(e.getMessage());
        }
    }

    setSourceUrl = () => {
        let url;
        let bankPhoneNumber = "";
        if (this.configObj != null) {
            bankPhoneNumber = this.configObj[Minkasu2FAConstants.CUSTOMER_INFO][Minkasu2FAConstants.CUSTOMER_PHONE];
            if (bankPhoneNumber != null && bankPhoneNumber.length > 0) {
                bankPhoneNumber = encodeURIComponent(bankPhoneNumber);
            }
        }
        if (this.isCardEnabled) {
            url = { uri: "https://sandbox.minkasupay.com/demo/Welcome_to_Net.html?bankPhone=" + bankPhoneNumber };
        } else {
            url = { uri: "https://sandbox.minkasupay.com/demo/Bank_Internet_Banking_login.htm?bankPhone=" + bankPhoneNumber }
        }
        this.setState({ sourceUrl: url });
    }

    onMinkasu2FAInit = (event) => {
        const data = event.nativeEvent;
        let errorMessage;
        if (data) {
            const status = data[Minkasu2FAConstants.STATUS];
            if (!status || (status && status == Minkasu2FAConstants.STATUS_FAILURE)) {
                errorMessage = "";
                if (data[Minkasu2FAConstants.ERROR_CODE]) {
                    errorMessage = data[Minkasu2FAConstants.ERROR_CODE] + " : ";
                }
                errorMessage += data[Minkasu2FAConstants.ERROR_MESSAGE];
            }
        } else {
            errorMessage = "Minkasu 2FA is not initialized";
        }
        if (errorMessage)
            Alert.alert("Error", errorMessage);
        this.setSourceUrl();
    };

    onMinkasu2FAResult = (event) => {
        const data = event.nativeEvent;
        let infoType = data[Minkasu2FAConstants.RESULT_INFO_TYPE];
        let resultData = data[Minkasu2FAConstants.RESULT_DATA];
        let result = resultData ? JSON.parse(resultData) : null;
        if (infoType && result) {
            if (infoType == Minkasu2FAConstants.INFO_TYPE_EVENT) {
                /*
                {
                    "reference_id": "<minkasu_transaction_ref>",  // UUID string
                    "screen": "<FTU_SETUP_CODE_SCREEN|FTU_AUTH_SCREEN|REPEAT_AUTH_SCREEN>", // Refer Native Doc For
                    "event": "<ENTRY>"
                }
                */
                console.log("Minkasu Info Event", result);
            } else if (infoType == Minkasu2FAConstants.INFO_TYPE_PROGRESS) {
                /*
                {
                    "reference_id": "<minkasu_transaction_ref>",  // UUID string
                    "visibility": "<true/false>",
                    "start_timer": "<true/false>",
                    "redirect_url_loading":"<true/false>"
                }
                */
                console.log("Minkasu Info Progress", result);

            } else if (infoType == Minkasu2FAConstants.INFO_TYPE_RESULT) {
                /*
                {
                    "reference_id": "<minkasu_transaction_ref>",  // UUID string
                    "status": "<SUCCESS|FAILED|TIMEOUT|CANCELLED|DISABLED>", 
                    "source": "<SDK|SERVER|BANK>", 
                    "code": <result/error code>, // 0 => Status SUCCESS, Non-zero values => Other status
                    "message": "<result/error message>"
                }
                */
                console.log("Minkasu Info Result", result);
            }
        }
    }
    
    render() {
        return (
            <>
                <View style={{ flex: 1, justifyContent: "flex-start", backgroundColor: '#444' }}>
                    <WebView
                        ref={this.webView}
                        source={this.state.sourceUrl}
                        javaScriptEnabled={true}
                        minkasu2FAConfig={this.state.configObj}
                        onMinkasu2FAInit={this.onMinkasu2FAInit}
                        onMinkasu2FAResult={this.onMinkasu2FAResult}
                    />
                </View>
            </>
        );
    };
}
```

#### Option 2: Using initMinkasu2FA Method

This is another option to intialize the Minkasu2FA Mobile SDK. Pass the config object to the `initMinkasu2FA` method. Here's sample code to do that.

```jsx
import React, { Component } from 'react';
import { View, Alert } from 'react-native';
import WebView from 'react-native-webview';

const Minkasu2FA = WebView.Minkasu2FA;
let Minkasu2FAConstants = Minkasu2FA.Constants;

class Minkasu2FAMethodFlowComponent extends Component {

    constructor(props) {
        super(props);
        this.webView = React.createRef();
        this.state = {
            sourceUrl: undefined,
            configObj: null,
            isCardEnabled: false
        }
    }

    componentDidMount() {
        try {
            const { route } = this.props;
            if (route && route.params) {
                this.setState({ configObj: route.params.configObj, isCardEnabled: route.params.isCardEnabled }, () => {
                    if (!this.state.configObj || this.state.configObj == null) {
                        this.setSourceUrl();
                    } else if (this.webView) {
                        this.webView.current.initMinkasu2FA(this.state.configObj);
                    }
                })
            }
        }
        catch (e) {
            console.log(e.getMessage());
        }
    }

    setSourceUrl = () => {
        let url;
        let bankPhoneNumber = "";
        if (this.configObj != null) {
            bankPhoneNumber = this.configObj[Minkasu2FAConstants.CUSTOMER_INFO][Minkasu2FAConstants.CUSTOMER_PHONE];
            if (bankPhoneNumber != null && bankPhoneNumber.length > 0) {
                bankPhoneNumber = encodeURIComponent(bankPhoneNumber);
            }
        }
        if (this.isCardEnabled) {
            url = { uri: "https://sandbox.minkasupay.com/demo/Welcome_to_Net.html?bankPhone=" + bankPhoneNumber };
        } else {
            url = { uri: "https://sandbox.minkasupay.com/demo/Bank_Internet_Banking_login.htm?bankPhone=" + bankPhoneNumber }
        }
        this.setState({ sourceUrl: url });
    }

    onMinkasu2FAInit = (event) => {
        const data = event.nativeEvent;
        let errorMessage;
        if (data) {
            const status = data[Minkasu2FAConstants.STATUS];
            if (!status || (status && status == Minkasu2FAConstants.STATUS_FAILURE)) {
                errorMessage = "";
                if (data[Minkasu2FAConstants.ERROR_CODE]) {
                    errorMessage = data[Minkasu2FAConstants.ERROR_CODE] + " : ";
                }
                errorMessage += data[Minkasu2FAConstants.ERROR_MESSAGE];
            }
        } else {
            errorMessage = "Minkasu 2FA is not initialized";
        }
        if (errorMessage)
            Alert.alert("Error", errorMessage);
        this.setSourceUrl();
    };

    onMinkasu2FAResult = (event) => {
        const data = event.nativeEvent;
        let infoType = data[Minkasu2FAConstants.RESULT_INFO_TYPE];
        let resultData = data[Minkasu2FAConstants.RESULT_DATA];
        let result = resultData ? JSON.parse(resultData) : null;
        if (infoType && result) {
            if (infoType == Minkasu2FAConstants.INFO_TYPE_EVENT) {
                /*
                {
                    "reference_id": "<minkasu_transaction_ref>",  // UUID string
                    "screen": "<FTU_SETUP_CODE_SCREEN|FTU_AUTH_SCREEN|REPEAT_AUTH_SCREEN>", // Refer Native Doc For
                    "event": "<ENTRY>"
                }
                */
                console.log("Minkasu Info Event", result);
            } else if (infoType == Minkasu2FAConstants.INFO_TYPE_PROGRESS) {
                /*
                {
                    "reference_id": "<minkasu_transaction_ref>",  // UUID string
                    "visibility": "<true/false>",
                    "start_timer": "<true/false>",
                    "redirect_url_loading":"<true/false>"
                }
                */
                console.log("Minkasu Info Progress", result);

            } else if (infoType == Minkasu2FAConstants.INFO_TYPE_RESULT) {
                /*
                {
                    "reference_id": "<minkasu_transaction_ref>",  // UUID string
                    "status": "<SUCCESS|FAILED|TIMEOUT|CANCELLED|DISABLED>", 
                    "source": "<SDK|SERVER|BANK>", 
                    "code": <result/error code>, // 0 => Status SUCCESS, Non-zero values => Other status
                    "message": "<result/error message>"
                }
                */
                console.log("Minkasu Info Result", result);
            }
        }
    }
    
    render() {
        return (
            <>
                <View style={{ flex: 1, justifyContent: "flex-start", backgroundColor: '#444' }}>
                    <WebView
                        ref={this.webView}
                        source={this.state.sourceUrl}
                        javaScriptEnabled={true}
                        onMinkasu2FAInit={this.onMinkasu2FAInit}
                        onMinkasu2FAResult={this.onMinkasu2FAResult}
                    />
                </View>
            </>
        );
    };
}
```

Note: In both options, load the source url in the `onMinkasu2FAInit` method. 

#### Minkasu2FA Operations

**List of Minkasu2FA Operations**

The Minkasu2FA SDK operations type constants:

```
Minkasu2FAConstants.CHANGE_PIN   
Minkasu2FAConstants.ENABLE_BIOMETRICS      
Minkasu2FAConstants.DISABLE_BIOMETRICS
```

**Retrieving Minkasu2FA Operations**

To retrieve the list of operations, use the following code to get the current list of operations available depending on the state of the Minkasu2FA SDK

```jsx
import React, { Component } from 'react';
import { Platform } from 'react-native';
import { WebView } from 'react-native-webview';

const Minkasu2FA = WebView.Minkasu2FA;
let Minkasu2FAConstants = Minkasu2FA.Constants;

class MyComponent extends Component {
    state = {
        availableMinkasu2FAOperationTypes: {}
    };
    
    getAvailableMinkasu2FAOperationTypes() {
        Minkasu2FA.getAvailableMinkasu2FAOperations()
            .then((data) => {
                this.setState({ availableMinkasu2FAOperationTypes: data });
            })
            .catch((err) => {
                console.log(err.getMessage());
            });
    }

}
```

**Performing Minkasu2FA Operations**

Use the following code to perform an available operation.

```jsx
import React, { Component } from 'react';
import { View, Platform } from 'react-native';
import { WebView } from 'react-native-webview';

const Minkasu2FA = WebView.Minkasu2FA;
let Minkasu2FAConstants = Minkasu2FA.Constants;

class MyComponent extends Component {
    ...

    // opType could be anyone of the values retrieved from the getAvailableMinkasu2FAOperationTypes() method
    async performMinkasu2FAOperation(opType) {  
        try {
            if (Platform.OS == 'ios') {
                await Minkasu2FA.performMinkasu2FAOperation("<merchant_customer_id>", opType, this.getiOSThemeObj());
            } else {
                await Minkasu2FA.performMinkasu2FAOperation("<merchant_customer_id>", opType);
            }
        }
        catch (e) {
            console.log(e.getMessage());
        }
    }
    ...
}
```

Please make sure the merchant_customer_id is a unique id associated with the currently logged in user, and is the same id used in the payment flow.

