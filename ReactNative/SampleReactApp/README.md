# React Native Minkasu2FA WebView Integration Guide
This document walks you through the steps to integrate Minkasu 2FA Mobile SDK with React Native using Minkasu2FA WebView.
## Contents

- [`Minimum Requirements`](README.md#minimum-requirements)
- [`Supported Platforms`](README.md#supported-platforms)
- [`Setup`](README.md#setup)
- [`Integration`](README.md#integration)

### Minimum Requirements

The minimum requirement for the library is

- React (16.13.1)
- React Native (0.62.2)
- React Native Webview (9.4.0)
 
### Supported Platforms

- [x] iOS (10.0 and higher)
- [x] Android (API Level 17 and higher)

### Setup

#### 1. Add react-native-webview to your dependencies

Since the library is built based on [@react-native-community/react-native-webview](https://github.com/react-native-community/react-native-webview). Please ensure the `react-native-webview` is installed prior adding Minkasu2FA WebView dependency. If not installed, add react-native-webview to your dependencies by running:
```
$ npm install --save react-native-webview
```

Note: The properties and methods of `react-native-webview` can be used in your application if required.

#### 2. Add react-native-minkasu2fa-webview to your dependencies
```
$ npm install --save react-native-minkasu2fa-webview
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
      maven {
          url 'https://dl.bintray.com/mk-it-admin/minkasu-2fa'
      }
      ...
   }
}
```

Add the following lines to your `AndroidManifest.xml` file at the path **android/app/src/main**:

```java
<activity
   android:name="com.minkasu.android.twofa.sdk.MinkasuSDKActivity"
   android:configChanges="orientation|screenSize|screenLayout|keyboardHidden"
   android:theme="@style/Mk2FASDKtheme" />
```
If you are using Proguard, add the following lines in its configuration

```
-keep class minkasu2fa.** { *; }
-keep class com.minkasu.android.twofa.** { *; }
```

The Minkasu2FA SDK screens can be customized to fit your application’s look and feel by specifying the Minkasu2FATheme as a parent style of your own theme. The following screen elements can be customized
- Action Bar: title color and action bar background
- Button: button text and button background

Add the following lines to your `styles.xml` file at the path **android/app/src/main/res/values**:

```xml
<!--START Minkasu2FA  -->
<style name="Mk2FASDKtheme" parent="Minkasu2FATheme">
 <!--Customize your theme here. -->
 <item name="colorPrimary">@color/mkActionBarColor</item>
</style>
<!--END Minkasu2FA  -->
```
Add the following lines to your `colors.xml` file at the path **android/app/src/main/res/values**:

```xml
<!--START Minkasu2FA  -->
<color name="mkActionBarColor">#3F51B5</color>
<color name="mkActionBarTextColor">#ffffff</color>
<color name="mkButtonBackground">#3F51B5</color>
<color name="mkButtonTextColor">#ffffff</color>
<!--END Minkasu2FA  -->
```

### Integration

Minkasu2FA WebView supports two options to integrate Minkasu 2FA Mobile SDK which are explained below.

Note: Check that the device is not jailbroken/rooted before creating the config object.

#### Minkasu2FA Config Object

To initialize the Minkasu 2FA Mobile SDK, the config object is mandatory. The below list show the available properties in the config object

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
import { Minkasu2FAUIConstants } from 'react-native-minkasu2fa-webview';

class MyComponent extends Component {
    ...
    getiOSThemeObj = () => {
        return {
            //Use the following properties to set custom color theme
            [Minkasu2FAUIConstants.NAVIGATION_BAR_COLOR]: "#0433FF",
            [Minkasu2FAUIConstants.NAVIGATION_BAR_TEXT_COLOR]: "#FFFFFF",
            [Minkasu2FAUIConstants.BUTTON_BACKGROUND_COLOR]: "0433FF",
            [Minkasu2FAUIConstants.BUTTON_TEXT_COLOR]: "#FFFFFF",
            //Set supportDarkMode to true if the app supports Dark Mode
            [Minkasu2FAUIConstants.SUPPORT_DARK_MODE]: true, 
            //Use the following properties to set a separate color theme for Dark Mode
            [Minkasu2FAUIConstants.DARK_MODE_NAVIGATION_BAR_COLOR]: "#942192",
            [Minkasu2FAUIConstants.DARK_MODE_NAVIGATION_BAR_TEXT_COLOR]: "#FFFFFF",
            [Minkasu2FAUIConstants.DARK_MODE_BUTTON_BACKGROUND_COLOR]: "#942192",
            [Minkasu2FAUIConstants.DARK_MODE_BUTTON_TEXT_COLOR]: "#FFFFFF"
        }
    }

    createMinkasu2FAConfigObj = () => {
        let customerInfo = {
            [Minkasu2FAUIConstants.CUSTOMER_FIRST_NAME]: "TestFirstName",
            [Minkasu2FAUIConstants.CUSTOMER_LAST_NAME]: "TestLastName",
            [Minkasu2FAUIConstants.CUSTOMER_EMAIL]: "test@xyz.com",
            [Minkasu2FAUIConstants.CUSTOMER_PHONE]: "+919876543210" // Format: +91XXXXXXXXXX (no spaces)
        };
        let addressInfo = {
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_LINE_1]: "123 Test Way",
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_LINE_2]: "Test Apartments",
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_CITY]: "Mumbai",
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_STATE]: "Maharastra", // Unabbreviated e.g. Maharashtra (not MH)
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_COUNTRY]: "India",
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_ZIP_CODE]: "400068" // Format: XXXXXX (no spaces)
        };
        let orderInfo = {
            [Minkasu2FAUIConstants.CUSTOMER_ORDER_ID]: <order_id> // The order id is used to later identify the transaction
        };
        let configObj = {
            [Minkasu2FAUIConstants.MERCHANT_ID]: <merchant_id>,
            [Minkasu2FAUIConstants.MERCHANT_TOKEN]: <merchant_token>,
            //merchant_customer_id is a unique id associated with the currently logged in user.
            [Minkasu2FAUIConstants.CUSTOMER_ID]: <merchant_customer_id>, 
            [Minkasu2FAUIConstants.CUSTOMER_INFO]: customerInfo,
            [Minkasu2FAUIConstants.CUSTOMER_ADDRESS_INFO]: addressInfo,
            [Minkasu2FAUIConstants.CUSTOMER_ORDER_INFO]: orderInfo,
            [Minkasu2FAUIConstants.SDK_MODE_SANDBOX]: true, // pass false for production
            [Minkasu2FAUIConstants.SKIP_INIT]:false //pass true to skip the Minkasu 2FA Flow
        };
        if (Platform.OS === 'ios') {
            configObj[Minkasu2FAUIConstants.IOS_THEME_OBJ] = this.getiOSThemeObj();
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

For sample code, please refer the below integration options.

#### Option 1: Using minkasu2FAConfig Props

This is the first option to intialize the Minkasu 2FA Mobile SDK. Pass the config object to the `minkasu2FAConfig` props. Here's sample code to do that.

```jsx
import React, { Component } from 'react';
import { View, Alert } from 'react-native';
import Minkasu2FAWebView, { Minkasu2FAUIConstants } from 'react-native-minkasu2fa-webview';

class Minkasu2FAAttributeFlowComponent extends Component {

    state = {
        sourceUrl: undefined
    }

    configObj = null;
    webview = null;
    isCardEnabled = false;

    constructor(props) {
        super(props);
        const { route } = this.props;
        if (route && route.params) {
            this.configObj = route.params.configObj;
            this.isCardEnabled = route.params.isCardEnabled;
        }
    }

    componentDidMount() {
        if (this.configObj == null) {
            this.setSourceUrl();
        }
    }

    setSourceUrl = () => {
        let url;
        if (this.isCardEnabled) {
            url = { uri: "https://sandbox.minkasupay.com/demo/Welcome_to_Net.html?bankPhone=%2B919876543210" };
        } else {
            url = { uri: "https://sandbox.minkasupay.com/demo/Bank_Internet_Banking_login.htm?bankPhone=%2B919876543210" }
        }
        this.setState({ sourceUrl: url });
    }

    onMinkasu2FAInit = (event) => {
        const data = event.nativeEvent;
        let errorMessage;
        if (data) {
            const status = data[Minkasu2FAUIConstants.STATUS];
            if (!status || (status && status == Minkasu2FAUIConstants.STATUS_FAILURE)) {
                errorMessage = "";
                if (data[Minkasu2FAUIConstants.ERROR_CODE]) {
                    errorMessage = data[Minkasu2FAUIConstants.ERROR_CODE] + " : ";
                }
                errorMessage += data[Minkasu2FAUIConstants.ERROR_MESSAGE];
            }
        } else {
            errorMessage = "Minkasu 2FA is not initialized";
        }
        if (errorMessage)
            Alert.alert("Error", errorMessage);
        this.setSourceUrl();
    };

    render() {
        return (
            <>
                <View style={{ flex: 1, justifyContent: "flex-start", backgroundColor: '#444' }}>
                    <Minkasu2FAWebView
                        ref={ref => (this.webview = ref)}
                        source={this.state.sourceUrl}
                        javaScriptEnabled={true}
                        minkasu2FAConfig={this.configObj}
                        onMinkasu2FAInit={this.onMinkasu2FAInit}
                    />
                </View>
            </>
        );
    };
}
```

#### Option 2: Using initMinkasu2FA Method

This is another option to intialize the Minkasu 2FA Mobile SDK. Pass the config object to the `initMinkasu2FA` method. Here's sample code to do that.

```jsx
import React, { Component } from 'react';
import { View, Alert } from 'react-native';
import Minkasu2FAWebView, { Minkasu2FAUIConstants } from 'react-native-minkasu2fa-webview';

class Minkasu2FAMethodFlowComponent extends Component {

    state = {
        sourceUrl: undefined
    }

    webview = null;
    isCardEnabled = false;

    componentDidMount() {
        try {
            const { route } = this.props;
            let isConfigObj = false;
            if (route && route.params) {
                let configObj = route.params.configObj;
                this.isCardEnabled = route.params.isCardEnabled;
                if (configObj && this.webview) {
                    isConfigObj = true;
                    this.webview.initMinkasu2FA(configObj);
                }
            }
            if (!isConfigObj) {
                this.setSourceUrl();
            }
        }
        catch (e) {
            console.log(e.getMessage());
        }
    }

    setSourceUrl = () => {
        let url;
        if (this.isCardEnabled) {
            url = { uri: "https://sandbox.minkasupay.com/demo/Welcome_to_Net.html?bankPhone=%2B919876543210" };
        } else {
            url = { uri: "https://sandbox.minkasupay.com/demo/Bank_Internet_Banking_login.htm?bankPhone=%2B919876543210" }
        }
        this.setState({ sourceUrl: url });
    }

    onMinkasu2FAInit = (event) => {
        const data = event.nativeEvent;
        let errorMessage;
        if (data) {
            const status = data[Minkasu2FAUIConstants.STATUS];
            if (!status || (status && status == Minkasu2FAUIConstants.STATUS_FAILURE)) {
                errorMessage = "";
                if (data[Minkasu2FAUIConstants.ERROR_CODE]) {
                    errorMessage = data[Minkasu2FAUIConstants.ERROR_CODE] + " : ";
                }
                errorMessage += data[Minkasu2FAUIConstants.ERROR_MESSAGE];
            }
        } else {
            errorMessage = "Minkasu 2FA is not initialized";
        }
        if (errorMessage)
            Alert.alert("Error", errorMessage);
        this.setSourceUrl();
    };
    
    render() {
        return (
            <>
                <View style={{ flex: 1, justifyContent: "flex-start", backgroundColor: '#444' }}>
                    <Minkasu2FAWebView
                        ref={ref => (this.webview = ref)}
                        source={this.state.sourceUrl}
                        javaScriptEnabled={true}
                        onMinkasu2FAInit={this.onMinkasu2FAInit}
                    />
                </View>
            </>
        );
    };
}
```

Note: 
- In both options, load the source url in the `onMinkasu2FAInit` method. 
- To check with different phone number, change the value of `CUSTOMER_PHONE` key in the config object and also change the `bankPhone` query param value of the source url in both flow.

#### Minkasu2FA Operations

**Retrieving Minkasu2FA Operations**

To retrieve the list of operations, use the following code to get the current list of operations available depending on the state of the Minkasu2FA SDK

```jsx
import React, { Component } from 'react';
import { Platform } from 'react-native';
import { Minkasu2FAWebViewModule } from 'react-native-minkasu2fa-webview';

class MyComponent extends Component {
    state = {
        availableMinkasu2FAOperationTypes: {}
    };
    
    getAvailableMinkasu2FAOperationTypes() {
        Minkasu2FAWebViewModule.getMinkasu2FAOperationTypes()
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
import { Minkasu2FAWebViewModule } from 'react-native-minkasu2fa-webview';

class MyComponent extends Component {
    ...

    // opType could be anyone of the values retrieved from the getAvailableMinkasu2FAOperationTypes() method
    async performMinkasu2FAOperation(opType) {  
        try {
            if (Platform.OS == 'ios') {
                await Minkasu2FAWebViewModule.performMinkasu2FAOperation(<merchant_customer_id>, opType, this.getiOSThemeObj());
            } else {
                await Minkasu2FAWebViewModule.performMinkasu2FAOperation(<merchant_customer_id>, opType);
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

