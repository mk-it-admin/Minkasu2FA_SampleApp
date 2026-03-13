import Flutter
import Minkasu2FA
import webview_flutter_wkwebview
import WebKit

class Minkasu2FAUtils:NSObject, Minkasu2FACallbackDelegate {
    static let channelName = "minkasu2fa_method_channel"
    static let shared = Minkasu2FAUtils()
    
    var channel: FlutterMethodChannel?
    
    override private init() {
        super.init()
    }
    
    func setUpMinkasu2FAWithEngine(engine: FlutterEngine) {
        self.channel = FlutterMethodChannel(name: Minkasu2FAUtils.channelName, binaryMessenger: engine.binaryMessenger)
        handleMethodCalls(flutterEngine: engine)
    }
    
    func setUpMinkasu2FAWithController(controller: FlutterViewController) {
        self.channel = FlutterMethodChannel(name: Minkasu2FAUtils.channelName, binaryMessenger: controller.binaryMessenger)
        handleMethodCalls()
    }
    
    private func handleMethodCalls(flutterEngine: FlutterEngine? = nil) {
        self.channel?.setMethodCallHandler { (call, result) in
            if call.method == "initMinkasu2FASDK" {
                guard let arguments = call.arguments as? [String: Any],
                      let configDictionary = arguments["config"] as? [String: Any],
                      let webViewIdNum = arguments["webViewId"] as? NSNumber
                else {
                    result([
                        "status": "failed",
                        "code": "MK2FA_F101",
                        "message": "Invalid arguments"
                    ])
                    return
                }
                let webViewId = Int64(truncating: webViewIdNum)
                let webView: WKWebView?
                
                if let engine = flutterEngine {
                    webView = Minkasu2FAUtils.shared.fetchWebViewWithId(webViewId: webViewId, engine: engine)
                } else {
                    webView = Minkasu2FAUtils.shared.fetchWebViewWithId(webViewId: webViewId)
                }
                
                guard let unwrappedWebView = webView else {
                    result([
                        "status": "failed",
                        "code": "MK2FA_F101",
                        "message": "Error in accessing webview"
                    ])
                    return
                }
                
                let config = Minkasu2FAUtils.shared.constructConfig(from: configDictionary)
                Minkasu2FAUtils.shared.initializeMinkasu2FASDK(webView: unwrappedWebView, config: config, result: result)
                
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    private func fetchWebViewWithId(webViewId: Int64) -> WKWebView? {
        let flutterAppDelegate2 = UIApplication.shared.delegate as? FlutterPluginRegistry
        guard let flutterAppDelegate = UIApplication.shared.delegate as? FlutterPluginRegistry,
              let webView = FWFWebViewFlutterWKWebViewExternalAPI.webView(forIdentifier: webViewId, withPluginRegistry: flutterAppDelegate) else {
            return nil
        }
        return webView
    }
    
    private func fetchWebViewWithId(webViewId: Int64, engine: FlutterEngine) -> WKWebView? {
        let webView = FWFWebViewFlutterWKWebViewExternalAPI.webView(forIdentifier: webViewId, withPluginRegistry: engine)
        return webView
    }
    
    private func initializeMinkasu2FASDK(webView: WKWebView, config: Minkasu2FAConfig, result: FlutterResult) {
        do {
            try try Minkasu2FA.initWith(webView, andConfiguration: config)
            result([
                "status": "success"
            ])
        } catch let error as NSError {
            result([
                "status": "failed",
                "code": error.domain,
                "message": error.localizedDescription
            ])
        }
    }
    
    private func constructConfig(from configDict: [String: Any]) -> Minkasu2FAConfig {
        let configId = configDict["id"] as? String
        let merchantCustomerId = configDict["merchantCustomerId"] as? String
        let token = configDict["token"] as? String
        
        let customerDict = configDict["customerInfo"] as? [String: Any]
        let customerInfo = constructCustomerInfo(from: customerDict)
        
        let orderDict = configDict["orderInfo"] as? [String: Any]
        let orderInfo = constructOrderInfo(from: orderDict)
        
        let partnerInfoDict = configDict["partnerInfo"] as? [String: Any]
        let partnerInfo = constructPartnerInfo(from: partnerInfoDict)
        
        let sdkModeValue = configDict["sdkMode"] as? Int
        let sdkMode = constructSDKMode(from: sdkModeValue)
        
        let customThemeDict = configDict["customTheme"] as? [String: Any]
        let customTheme = customThemeDict != nil ? constructCustomTheme(from: customThemeDict!) : nil
        
        let config = Minkasu2FAConfig()
        config._id = configId
        config.token = token
        config.merchantCustomerId = merchantCustomerId
        config.customerInfo = customerInfo
        config.sdkMode = sdkMode
        config.orderInfo = orderInfo
        config.customTheme = customTheme
        config.partnerInfo = partnerInfo
        config.delegate = self
        
        return config
    }
    
    private func constructCustomerInfo(from dict: [String: Any]?) -> Minkasu2FACustomerInfo? {
        guard let dict = dict else { return nil }
        
        let firstName = dict["firstName"] as? String
        let lastName = dict["lastName"] as? String
        let email = dict["email"] as? String
        let phone = dict["phone"] as? String
        
        var address: Minkasu2FAAddress? = nil
        if let addressDict = dict["address"] as? [String: Any] {
            address = constructAddress(from: addressDict)
        }
        
        let customerInfo = Minkasu2FACustomerInfo()
        customerInfo.firstName = firstName
        customerInfo.lastName = lastName
        customerInfo.email = email
        customerInfo.phone = phone
        customerInfo.address = address
        
        return customerInfo
    }
    
    private func constructAddress(from dict: [String: Any]) -> Minkasu2FAAddress {
        let address = Minkasu2FAAddress()
        
        if let line1 = dict["line1"] as? String {
            address.line1 = line1
        }
        if let line2 = dict["line2"] as? String {
            address.line2 = line2
        }
        if let city = dict["city"] as? String {
            address.city = city
        }
        if let state = dict["state"] as? String {
            address.state = state
        }
        if let country = dict["country"] as? String {
            address.country = country
        }
        if let zipCode = dict["zipCode"] as? String {
            address.zipCode = zipCode
        }
        
        return address
    }
    
    private func constructOrderInfo(from dict: [String: Any]?) -> Minkasu2FAOrderInfo? {
        guard let dict = dict else { return nil }
        
        let orderInfo = Minkasu2FAOrderInfo()
        orderInfo.orderId = dict["orderId"] as? String
        orderInfo.orderDetails = dict["orderDetails"] as? String
        orderInfo.billingCategory = dict["billingCategory"] as? String
        
        return orderInfo
    }
    
    private func constructPartnerInfo(from dict: [String: Any]?) -> Minkasu2FAPartnerInfo? {
        guard let dict = dict else { return nil }
        
        let partnerInfo = Minkasu2FAPartnerInfo()
        if let merchantId = dict["merchantId"] as? String {
            partnerInfo.merchantId = merchantId
        }
        if let merchantName = dict["merchantName"] as? String {
            partnerInfo.merchantName = merchantName
        }
        if let transactionId = dict["transactionId"] as? String {
            partnerInfo.transactionId = transactionId
        }
        
        return partnerInfo
    }
    
    private func constructSDKMode(from value: Int?) -> Minkasu2FASDKMode {
        guard let value = value else { return Minkasu2FASDKMode.MINKASU2FA_SANDBOX_MODE }
        return value == 0 ? Minkasu2FASDKMode.MINKASU2FA_PRODUCTION_MODE : Minkasu2FASDKMode.MINKASU2FA_SANDBOX_MODE
    }
    
    private func constructCustomTheme(from dict: [String: Any]) -> Minkasu2FACustomTheme {
        let theme = Minkasu2FACustomTheme()
        
        if let navBarColorValue = dict["navigationBarColor"] as? UInt {
            theme.navigationBarColor = getARGBColorComponents(from: navBarColorValue)
        }
        if let navBarTextColorValue = dict["navigationBarTextColor"] as? UInt {
            theme.navigationBarTextColor = getARGBColorComponents(from: navBarTextColorValue)
        }
        if let darkNavBarColorValue = dict["darkModeNavigationBarColor"] as? UInt {
            theme.darkModeNavigationBarColor = getARGBColorComponents(from: darkNavBarColorValue)
        }
        if let darkNavBarTextColorValue = dict["darkModeNavigationBarTextColor"] as? UInt {
            theme.darkModeNavigationBarTextColor = getARGBColorComponents(from: darkNavBarTextColorValue)
        }
        if let supportDarkMode = dict["supportDarkMode"] as? Bool {
            theme.supportDarkMode = supportDarkMode
        }
        
        return theme
    }
    
    private func getARGBColorComponents(from colorValue: UInt) -> UIColor {
        let alpha = CGFloat((colorValue >> 24) & 0xFF) / 255.0
        let red = CGFloat((colorValue >> 16) & 0xFF) / 255.0
        let green = CGFloat((colorValue >> 8) & 0xFF) / 255.0
        let blue = CGFloat(colorValue & 0xFF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    private func convertCallbackInfoToDictionary(from callbackInfo: Minkasu2FACallbackInfo) -> [String: Any] {
        let dictionary: [String: Any] = [
            "infoType": callbackInfo.infoType,
            "data": callbackInfo.data
        ]
        
        return dictionary
    }
    
    func minkasu2FACallback(_ minkasu2FACallbackInfo: Minkasu2FACallbackInfo) {
        let callbackDictionary = convertCallbackInfoToDictionary(from: minkasu2FACallbackInfo)
        self.channel?.invokeMethod("receiveMinkasu2FACallbackInfo", arguments: callbackDictionary)
    }
}
