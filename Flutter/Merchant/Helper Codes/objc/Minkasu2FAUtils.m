#import "Minkasu2FAUtils.h"
#import "Minkasu2FA/Minkasu2FACallbackDelegate.h"
#import <Minkasu2FA/Minkasu2FAHeader.h>
@import webview_flutter_wkwebview;

static NSString *channelName = @"minkasu2fa_method_channel";

@interface Minkasu2FAUtils () <Minkasu2FACallbackDelegate>
@property(nonatomic, strong) FlutterMethodChannel *channel;
@end

@implementation Minkasu2FAUtils

+ (instancetype)sharedInstance {
    static Minkasu2FAUtils *sharedInstance = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedInstance = [[super alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setUpMinkasu2FAWithController:(FlutterViewController *)controller {
    self.channel =
    [FlutterMethodChannel methodChannelWithName:channelName
                                binaryMessenger:controller.binaryMessenger];
    [self handleMethodCalls:nil];
}

- (void)setUpMinkasu2FAWithEngine:(FlutterEngine *)engine {
    self.channel =
    [FlutterMethodChannel methodChannelWithName:channelName
                                binaryMessenger:engine.binaryMessenger];
    [self handleMethodCalls:engine];
}

- (void)handleMethodCalls:(nullable FlutterEngine *)engine {
    [self.channel setMethodCallHandler:^(FlutterMethodCall *call,
                                         FlutterResult result) {
        if ([@"initMinkasu2FASDK" isEqualToString:call.method]) {
            NSDictionary *arguments = call.arguments;
            NSNumber *number = arguments[@"webViewId"];
            NSDictionary *configDictionary = arguments[@"config"];
            
            if ((arguments && arguments != nil) && (number && number != nil) &&
                (configDictionary && configDictionary != nil)) {
                Minkasu2FAConfig *config = [[Minkasu2FAUtils sharedInstance]
                                            constructConfigFrom:configDictionary];
                WKWebView *webView = nil;
                if (engine && engine != nil) {
                    webView = [[Minkasu2FAUtils sharedInstance]
                               fetchWebViewWithId:[number longValue]
                               andEngine:engine];
                } else {
                    webView = [[Minkasu2FAUtils sharedInstance]
                               fetchWebViewWithId:[number longValue]];
                }
                if (webView && webView != nil &&
                    ![webView isKindOfClass:[NSNull class]]) {
                    [[Minkasu2FAUtils sharedInstance] initSDKwithWebView:webView
                                                                  config:config
                                                               andResult:result];
                } else {
                    result(@{
                        @"status" : @"failed",
                        @"code" : @"MK2FA_F101",
                        @"message" : @"Error in accessing webview"
                    });
                }
            } else {
                result(@{
                    @"status" : @"failed",
                    @"code" : @"MK2FA_F101",
                    @"message" : @"Invalid arguments"
                });
            }
        } else {
            result(FlutterMethodNotImplemented);
        }
    }];
}

- (WKWebView *)fetchWebViewWithId:(long)webViewId
                        andEngine:(FlutterEngine *)engine {
    WKWebView *webView = (WKWebView *)[FWFWebViewFlutterWKWebViewExternalAPI
                                       webViewForIdentifier:webViewId
                                       withPluginRegistry:engine];
    return webView;
}

- (WKWebView *)fetchWebViewWithId:(long)webViewId {
    FlutterAppDelegate *flutterAppDelegate =
    (FlutterAppDelegate *)[UIApplication sharedApplication].delegate;
    if (!flutterAppDelegate || flutterAppDelegate == nil ||
        [flutterAppDelegate isKindOfClass:[NSNull class]]) {
        return nil;
    }
    WKWebView *webView = (WKWebView *)[FWFWebViewFlutterWKWebViewExternalAPI
                                       webViewForIdentifier:webViewId
                                       withPluginRegistry:flutterAppDelegate];
    return webView;
}

- (void)initSDKwithWebView:(WKWebView *)webView
                    config:(Minkasu2FAConfig *)config
                 andResult:(FlutterResult)result {
    NSError *error = nil;
    NSString *hybridSDKDetails = @"{\"platform\": \"flutter\"}";
    [Minkasu2FA initHybridSDKWithWKWebView:webView andConfiguration:config hybridSDKDetails: hybridSDKDetails inViewController:nil error:&error];
    if (error) {
        result(@{
            @"status" : @"failed",
            @"code" : error.domain,
            @"message" : error.userInfo[@"NSLocalizedDescription"],
        });
        return;
    }
    
    result(@{
        @"status" : @"success",
    });
}

- (Minkasu2FAConfig *)constructConfigFrom:(NSDictionary *)configDictionary {
    NSString *configId = configDictionary[@"id"];
    NSString *merchantCustomerId = configDictionary[@"merchantCustomerId"];
    NSString *token = configDictionary[@"token"];
    
    NSDictionary *customerDictionary = configDictionary[@"customerInfo"];
    Minkasu2FACustomerInfo *customerInfo =
    [self constructCustomerInfoFrom:customerDictionary];
    
    NSDictionary *orderInfoDictionary = configDictionary[@"orderInfo"];
    Minkasu2FAOrderInfo *orderInfo =
    [self constructOrderInfoFrom:orderInfoDictionary];
    
    NSNumber *sdkModeValue = configDictionary[@"sdkMode"];
    Minkasu2FASDKMode sdkMode = [self constructSDKModeFrom:sdkModeValue];
    
    NSDictionary *customThemeDictionary = configDictionary[@"customTheme"];
    Minkasu2FACustomTheme *customTheme = nil;
    if (customThemeDictionary && customThemeDictionary != nil &&
        ![customThemeDictionary isKindOfClass:[NSNull class]]) {
        customTheme = [self constructCustomThemeFrom:customThemeDictionary];
    }
    
    Minkasu2FAConfig *config = [Minkasu2FAConfig new];
    config._id = configId;
    config.token = token;
    config.merchantCustomerId = merchantCustomerId;
    config.customerInfo = customerInfo;
    config.sdkMode = sdkMode;
    config.orderInfo = orderInfo;
    config.customTheme = customTheme;
    config.delegate = self;
    
    return config;
}

- (Minkasu2FACustomerInfo *)constructCustomerInfoFrom:
(NSDictionary *)customerInfoDictionary {
    NSString *firstName = customerInfoDictionary[@"firstName"];
    NSString *lastName = customerInfoDictionary[@"lastName"];
    NSString *middleName = customerInfoDictionary[@"middleName"];
    NSString *email = customerInfoDictionary[@"email"];
    NSString *phone = customerInfoDictionary[@"phone"];
    
    NSDictionary *addressDictionary = customerInfoDictionary[@"address"];
    Minkasu2FAAddress *address = nil;
    
    if (addressDictionary && addressDictionary != nil &&
        ![addressDictionary isKindOfClass:[NSNull class]]) {
        address = [self constructAddressFrom:addressDictionary];
    }
    
    Minkasu2FACustomerInfo *customerInfo = [Minkasu2FACustomerInfo new];
    customerInfo.firstName = firstName;
    customerInfo.lastName = lastName;
    if (middleName && middleName != nil &&
        ![middleName isKindOfClass:[NSNull class]]) {
        customerInfo.middleName = middleName;
    }
    customerInfo.email = email;
    customerInfo.phone = phone;
    customerInfo.address = address;
    
    return customerInfo;
}

- (Minkasu2FAAddress *)constructAddressFrom:(NSDictionary *)addressDictionary {
    NSString *line1 = addressDictionary[@"line1"];
    NSString *line2 = addressDictionary[@"line2"];
    NSString *line3 = addressDictionary[@"line3"];
    NSString *city = addressDictionary[@"city"];
    NSString *state = addressDictionary[@"state"];
    NSString *country = addressDictionary[@"country"];
    NSString *zipCode = addressDictionary[@"zipCode"];
    
    Minkasu2FAAddress *address = [Minkasu2FAAddress new];
    if (line1 && line1 != nil && ![line1 isKindOfClass:[NSNull class]]) {
        address.line1 = line1;
    }
    if (line2 && line2 != nil && ![line2 isKindOfClass:[NSNull class]]) {
        address.line3 = line2;
    }
    if (line3 && line3 != nil && ![line3 isKindOfClass:[NSNull class]]) {
        address.line3 = line3;
    }
    if (city && city != nil && ![city isKindOfClass:[NSNull class]]) {
        address.city = city;
    }
    if (state && state != nil && ![state isKindOfClass:[NSNull class]]) {
        address.state = state;
    }
    if (country && country != nil && ![country isKindOfClass:[NSNull class]]) {
        address.country = country;
    }
    if (zipCode && zipCode != nil && ![zipCode isKindOfClass:[NSNull class]]) {
        address.zipCode = zipCode;
    }
    
    return address;
}

- (Minkasu2FAOrderInfo *)constructOrderInfoFrom:
(NSDictionary *)orderInfoDictionary {
    NSString *orderId = orderInfoDictionary[@"orderId"];
    NSString *orderDetails = orderInfoDictionary[@"orderDetails"];
    NSString *billingCategory = orderInfoDictionary[@"billingCategory"];
    
    Minkasu2FAOrderInfo *orderInfo = [Minkasu2FAOrderInfo new];
    orderInfo.orderId = orderId;
    
    if (orderDetails && orderDetails != nil &&
        ![orderDetails isKindOfClass:[NSNull class]]) {
        orderInfo.orderDetails = orderDetails;
    }
    if (billingCategory && billingCategory != nil &&
        ![billingCategory isKindOfClass:[NSNull class]]) {
        orderInfo.billingCategory = billingCategory;
    }
    
    return orderInfo;
}

- (Minkasu2FASDKMode)constructSDKModeFrom:(NSNumber *)sdkModeValue {
    if ([sdkModeValue intValue] == 0) {
        return MINKASU2FA_PRODUCTION_MODE;
    }
    return MINKASU2FA_SANDBOX_MODE;
}

- (Minkasu2FACustomTheme *)constructCustomThemeFrom:
(NSDictionary *)customThemeDictionary {
    NSNumber *navigationBarColor = customThemeDictionary[@"navigationBarColor"];
    NSNumber *navigationBarTextColor =
    customThemeDictionary[@"navigationBarTextColor"];
    NSNumber *darkModeNavigationBarColor =
    customThemeDictionary[@"darkModeNavigationBarColor"];
    NSNumber *darkModeNavigationBarTextColor =
    customThemeDictionary[@"darkModeNavigationBarTextColor"];
    BOOL supportDarkMode = customThemeDictionary[@"supportDarkMode"];
    
    Minkasu2FACustomTheme *customTheme = [Minkasu2FACustomTheme new];
    customTheme.navigationBarColor = [self
                                      getARGBComponentsFromColor:[navigationBarColor unsignedIntegerValue]];
    customTheme.navigationBarTextColor =
    [self getARGBComponentsFromColor:[navigationBarTextColor
                                      unsignedIntegerValue]];
    customTheme.darkModeNavigationBarColor =
    [self getARGBComponentsFromColor:[darkModeNavigationBarColor
                                      unsignedIntegerValue]];
    customTheme.darkModeNavigationBarTextColor =
    [self getARGBComponentsFromColor:[darkModeNavigationBarTextColor
                                      unsignedIntegerValue]];
    customTheme.supportDarkMode = supportDarkMode;
    
    return customTheme;
}

- (NSDictionary *)convertCallBackInfoToDictionaryFrom:
(Minkasu2FACallbackInfo *)callBackInfo {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    dictionary[@"infoType"] =
    [NSNumber numberWithInteger:callBackInfo.infoType];
    dictionary[@"data"] = callBackInfo.data;
    
    return dictionary;
}

- (UIColor *)getARGBComponentsFromColor:(NSUInteger)colorValue {
    
    CGFloat alpha = ((colorValue >> 24) & 0xFF) / 255.0;
    CGFloat red = ((colorValue >> 16) & 0xFF) / 255.0;
    CGFloat green = ((colorValue >> 8) & 0xFF) / 255.0;
    CGFloat blue = (colorValue & 0xFF) / 255.0;
    
    UIColor *color = [UIColor colorWithRed:red
                                     green:green
                                      blue:blue
                                     alpha:alpha];
    return color;
}

#pragma mark - Minkasu2FACallback Delegate

- (void)minkasu2FACallback:(Minkasu2FACallbackInfo *)minkasu2FACallbackInfo {
    NSDictionary *callBackDictionary =
    [self convertCallBackInfoToDictionaryFrom:minkasu2FACallbackInfo];
    [self.channel invokeMethod:@"receiveMinkasu2FACallbackInfo"
                     arguments:callBackDictionary];
}

@end
