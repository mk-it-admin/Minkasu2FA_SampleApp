# Minkasu2FA

This documentation provides step-by-step instructions for integrating the `Minkasu2FA` native SDKs (Android and iOS) into a Flutter project that uses the `webview_flutter` plugin.

## Requirements

1. [`webview_flutter`](https://pub.dev/packages/webview_flutter) version **4.0.0** or higher

## Integration

To initialize the native SDKs, two things are required: Config details and a reference to the native WebView.

Since the native WebView reference is only accessible from the platform-specific (native) layer, you will send the configuration details from Flutter to the native side via a MethodChannel. The native layer will then use those details to initialize the SDKs.

For more details on the native integration process, refer to the [Android SDK](https://docs.minkasupay.com/Minkasu_2FA_SDK_Merchant_Integration_Android_v5.1.0.pdf) and [iOS SDK](https://github.com/mk-it-admin/Minkasu2FA_SampleApp/tree/iOS_v5.1.0/iOS/Merchant) documentation.

1.  **Flutter Configurations**

    1. Add the `minkasu2fa_models.dart` and `minkasu2fa_utils.dart` files to your project.
    2. Create a `Minkasu2FAConfig` object 
        ```dart
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
          phone: "+91XXXXXXXXXX",
          address: address,
        );
        final order = Minkasu2FAOrderInfo(
          orderId: 'order_12345',
          // Optionally specify billing category and order details
          billingCategory: "<billing_category>", // e.g. “FLIGHTS”
          orderDetails: jsonEncode({"<key_1>": "<data_1>", "<key_2>": "<data_2>"}),
        );
        // This theme is only applicable for iOS. To set the theme for android please refer the android configurations
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
          id: "merchant_id",
          merchantCustomerId: "merchant_customer_id",
          customerInfo: customer,
          orderInfo: order,
          token: "merchant_token",
          sdkMode: Minkasu2FASDKMode.sandbox,
          customTheme: customTheme,
        );
        ```
    3. Create a callback function to receive updates from `Minkasu2FA`. Refer to the [Android](https://docs.minkasupay.com/Minkasu_2FA_SDK_Merchant_Integration_Android_v5.1.0.pdf) and [iOS](https://github.com/mk-it-admin/Minkasu2FA_SampleApp/tree/iOS_v5.1.0/iOS/Merchant) documentation for more details about the payload.
        ```dart
        void minkasu2FACallback(dynamic minkasu2FACallbackInfo) {
            // infoType 1 indicates RESULT
            // infoType 2 indicates an EVENT
            // infoType 3 indicates PROGRESS
        
            final infoType = minkasu2FACallbackInfo['infoType'] as int;
            if (infoType == 1) {
              final data = minkasu2FACallbackInfo['data'];
              final status = data['status'] as String;
              if (status == "SUCCESS") {
                // Successful Transaction
              }
            }
        }
        ```

    4. Initialize `Minkasu2FA` using the `initializeMinkasu2FA` method from the `minkasu2fa_utils` file before loading the payment URL.
        ```dart
        try {
            final result = await initializeMinkasu2FA(
            config, // Minkasu2FAConfig object
            _controller, // WebViewController object
            minkasu2FACallback, // optional
            );
        } catch (_) {}
        ```
2. **Android Configurations**

    1. Add the `Minkasu2FA` dependency to the `build.gradle.kts` file located at `android/app`:
        ```kt
        defaultConfig {
            // other configurations
        }
    
        dependencies {
            // other dependencies
            implementation("com.minkasu:minkasu-2fa:5.1.0") // Add the Minkasu2FA dependency here
        }
        ```
    2.  Add an activity declaration to your `AndroidManifest.xml` file located at `android/app/src/main`:
        ```xml
        <activity
            android:name="com.minkasu.android.twofa.sdk.MinkasuSDKActivity"
            android:configChanges="keyboard|orientation|screenSize|screenLayout|
            keyboardHidden|uiMode|layoutDirection|smallestScreenSize"
            android:theme="@style/Mk2FASDKtheme">
        </activity>
        ```
    3. The `Minkasu2FA SDK` screens can be customized to fit your application’s look and feel by specifying the `Minkasu2FATheme` as a parent style of your own theme.The following screen elements can be customized:

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
    4. Depending on whether your project uses Java or Kotlin, proceed as follows:
    
        **Kotlin**
    
        1. Add the `Minkasu2FAUtils.kt` file to the following directory: `android/app/src/main/kotlin/com/.../yourappname`
        2. Update the `MainActivity.kt` file to include the following changes:
            ```kts
            import androidx.annotation.NonNull
            import io.flutter.embedding.android.FlutterActivity
            import io.flutter.embedding.engine.FlutterEngine
        
            // Import your Minkasu utility class
            import com.example.yourappname.Minkasu2FAUtils
        
            class MainActivity : FlutterActivity() {
        
                override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
                    super.configureFlutterEngine(flutterEngine)
                    Minkasu2FAUtils.setUpMinkasu2FA(flutterEngine, this); // Minkasu2FA
                }
            }
            ```
        **Java**
    
        1. Add the `Minkasu2FAUtils.java` file to the following directory: `android/app/src/main/java/com/.../yourappname`
        2.  Update the `MainActivity.java` file to include the following changes:
            ```java
            import androidx.annotation.NonNull;
            
            import io.flutter.embedding.android.FlutterActivity;
            import io.flutter.embedding.engine.FlutterEngine;
            
            public class MainActivity extends FlutterActivity {
                @Override
                public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
                    super.configureFlutterEngine(flutterEngine);
                    Minkasu2FAUtils.getInstance().setUpMinkasu2FAUtils(flutterEngine, this); // Minkasu2FA
                }
            }
            ```

3. **iOS Configurations**
    1. Add `NSFaceIDUsageDescription` to `Info.plist`

        ```swift
        <key>NSFaceIDUsageDescription</key>
        <string>Please allow AppName to use Face ID.</string>
        ```
    2. Add the `Minkasu2FA` dependency
        1. Using SPM - Swift Package Manager (recommended)
        Add dependency to Package.swift into dependencies section

            ```swift
            .package(url: "https://github.com/mk-it-admin/Minkasu2FA_Pod.git", .upToNextMajor(from: "5.1.0")),
            ```
        1. Using Cocoapods (will be deprecated on 2 Dec, 2026)
        Update the Podfile located at ios/Podfile

            ```ruby
            # Uncomment this line to define a global platform for your project
            platform :ios, '13.0'
            target 'Runner' do
                use_frameworks!
                pod 'Minkasu2FA', '5.1.0'  # Add Minkasu2FA dependency here
                flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
                target 'RunnerTests' do
                    inherit! :search_paths
                end
            end
            ```

    3. Depending on whether your project uses Swift or Objective-C, proceed as follows:
    
        **Swift**
        
        1. Add the `Minkasu2FAUtils.swift` file to the following directory: `ios/Runner`
        2. Update your `AppDelegate.swift` file to include the following changes for initializing `Minkasu2FAUtils`
            ```swift
            import Flutter
            import UIKit
        
            @main
            @objc class AppDelegate: FlutterAppDelegate {
        
                override func application(
                    _ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
                ) -> Bool {
                    GeneratedPluginRegistrant.register(with: self)
                    
                    let controller = window.rootViewController as! FlutterViewController
                    Minkasu2FAUtils.shared.setUpMinkasu2FAWithEngine(engine: controller.engine) // Minkasu2FA
                    
                    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
                }
            }
            ```
    
        **Objective-C**
        
        1. Add the `Minkasu2FAUtils.h` and `Minkasu2FAUtils.m` files to the following directory: `ios/Runner`
        2. Update your `AppDelegate.m` file to include the following changes for initializing `Minkasu2FAUtils`
            ```objc
            #import "AppDelegate.h"
            #import "GeneratedPluginRegistrant.h"
            #import <Flutter/Flutter.h>
            #import "Minkasu2FAUtils.h"
            
            @implementation AppDelegate
            
            - (BOOL)application:(UIApplication *)application
                didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
                [GeneratedPluginRegistrant registerWithRegistry:self];
                
                FlutterViewController *controller = (FlutterViewController*)self.window.rootViewController;
                [[Minkasu2FAUtils sharedInstance] setUpMinkasu2FAWithEngine:controller.engine]); // Minkasu2FA
                
                return [super application:application didFinishLaunchingWithOptions:launchOptions];
            }
            
            @end
            ```

## Sample Apps
You can refer to the sample apps in the **Sample Apps** folder to see the integration in action.

There are two sample apps:
- One uses **Swift** and **Kotlin** in the native layers.
- The other uses **Objective-C** and **Java** in the native layers.
