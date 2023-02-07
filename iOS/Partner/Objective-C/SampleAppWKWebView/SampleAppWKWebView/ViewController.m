//
//  ViewController.m
//  SampleAppWKWebView
//
//  Created by Praveena Khanna on 10/9/18.
//  Copyright © 2018 minkasu. All rights reserved.
//

#import "ViewController.h"
#import <Minkasu2FA/Minkasu2FAHeader.h>

@interface ViewController ()

@end

@implementation ViewController{
    NSString *merchantCustomerId;
    Minkasu2FAConfig *config;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    //Initializing WKWebView
    WKWebViewConfiguration *theConfiguration = [[WKWebViewConfiguration alloc] init];
    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+150, self.view.frame.size.width, self.view.frame.size.height) configuration:theConfiguration];
    _wkWebView.UIDelegate = self;

    [self.view addSubview:_wkWebView];

    [self.btnNetBanking.layer setCornerRadius:6.0];
    [self.btnCreditDebit.layer setCornerRadius:6.0];

    merchantCustomerId = @"M_C001";
}

#pragma mark WKWebView Methods
//Handles the JavaScript Alert in Native iOS App
//- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
//
//    //Set Alert Title in Alert Pop-Up as "Minkasu Alert"
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
//
//    //Display OK in Pop-Up and close Pop-Up when OK Button is pressed (espace completion handler)
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        completionHandler();
//    }];
//
//    //Present Alert from Context
//    [alertController addAction:okAction];
//
//    [self presentViewController:alertController animated:TRUE completion:nil];
//}

//****START Minkasu2FA Code***************
- (void) initMinkasu2FA{
    //initialize Customer object
    Minkasu2FACustomerInfo *customer = [Minkasu2FACustomerInfo new];
    customer.firstName = @"TestFirtName";
    customer.lastName = @"TestLastName";
    customer.email = @"test@minkasupay.com";
    customer.phone = <customer_phone>;          // Format: +91XXXXXXXXXX (no spaces)

    Minkasu2FAAddress *address = [Minkasu2FAAddress new];
    address.line1 = @"123 Test Way";
    address.line2 = @"Test Apartments";
    address.city = @"Mumbai";
    address.state = @"Maharashtra";             // Unabbreviated e.g. Maharashtra (not MH)
    address.country= @"India";
    address.zipCode = @"400068";                // Format: XXXXXX (no spaces)
    customer.address = address;
    
    //Create the PartnerInfo object with partner_merchant_id, partner_merchant_name and partner_transaction_id.
    Minkasu2FAPartnerInfo *partnerInfo = [Minkasu2FAPartnerInfo new];
    partnerInfo.merchantId = <partner_merchant_id>;
    partnerInfo.merchantName = <partner_merchant_name>;
    partnerInfo.transactionId = <partner_transaction_id>;
    
    //Create the Config object with merchant_id, merchant_access_token, merchant_customer_id and customer object.
    //merchant_customer_id is a unique id associated with the currently logged in user.
    config = [Minkasu2FAConfig new];
    config._id = <partner_id>;
    config.token = <partner_access_token>;
    config.partnerInfo = partnerInfo;
    config.merchantCustomerId =<merchant_customer_id>;
    //add customer to the Config object
    config.customerInfo = customer;

    Minkasu2FAOrderInfo *orderInfo = [Minkasu2FAOrderInfo new];
    orderInfo.orderId = <order_id>;
    
    // Optionally specify billing category and order details
    orderInfo.billingCategory = <billing_category>; // e.g. “FLIGHTS”
    NSDictionary *orderDetails=[[NSDictionary alloc] init]; // e.g. @{<custom_key_1> : <custom_value_1>, <custom_key_2> : <custom_value_2>, <custom_key_3> : <custom_value_3>}
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
        NSLog(@"Minkasu init failed with error domain: %@ and description: %@",error.domain,error.localizedDescription);
    }
}
//****END Minkasu2FA Code***************


- (IBAction)clickNetBanking:(id)sender {
    //Initializing Minkasu2FA SDK before initating Payment
    [self initMinkasu2FA];
    
    NSString *encodedCustomerPhone = [config.customerInfo.phone stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.alphanumericCharacterSet];
    NSString *paymentURL = [NSString stringWithFormat:@"https://sandbox.minkasupay.com/demo/Bank_Internet_Banking_login.htm?bankPhone=%@", encodedCustomerPhone];
    NSURL *nsurl=[NSURL URLWithString:paymentURL];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [_wkWebView loadRequest:nsrequest];
}

- (IBAction)clickCreditDebit:(id)sender {
    //Initializing Minkasu2FA SDK before initating Payment
    [self initMinkasu2FA];
    
    NSString *encodedCustomerPhone = [config.customerInfo.phone stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.alphanumericCharacterSet];
    NSString *paymentURL = [NSString stringWithFormat:@"https://sandbox.minkasupay.com/demo/Welcome_to_Net.html?bankPhone=%@", encodedCustomerPhone];
    NSURL *nsurl=[NSURL URLWithString:paymentURL];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [_wkWebView loadRequest:nsrequest];
}

- (IBAction)clickMenuOption:(id)sender {
    NSMutableArray *minkasu2FAOperations = [Minkasu2FA getAvailableMinkasu2FAOperations];
    if([minkasu2FAOperations count] > 0){
        UIAlertController *menuOptionsActionSheet = [UIAlertController alertControllerWithTitle:nil message:@"Menu" preferredStyle:UIAlertControllerStyleActionSheet];
        for (NSNumber *operation in minkasu2FAOperations){
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

            UIAlertAction *action = nil;
            if(operation.intValue == MINKASU2FA_CHANGE_PAYPIN) {
                action = [UIAlertAction
                          actionWithTitle:@"Change PayPIN"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action) {
                              NSLog(@"Change PayPIN");
                              //merchant_customer_id is a unique id associated with the currently logged in user.
                              [Minkasu2FA performMinkasu2FAOperation:MINKASU2FA_CHANGE_PAYPIN merchantCustomerId:<merchant_customer_id> customTheme:mkcolorTheme];
                          }];
            } else if(operation.intValue == MINKASU2FA_ENABLE_BIOMETRY) {
                action = [UIAlertAction
                          actionWithTitle:@"Enable Touch ID"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action) {
                              NSLog(@"Enable Touch ID");
                              //merchant_customer_id is a unique id associated with the currently logged in user.
                              [Minkasu2FA performMinkasu2FAOperation:MINKASU2FA_ENABLE_BIOMETRY merchantCustomerId:<merchant_customer_id> customTheme:mkcolorTheme];
                          }];
            } else if(operation.intValue == MINKASU2FA_DISABLE_BIOMETRY) {
                action = [UIAlertAction
                          actionWithTitle:@"Disable Touch ID"
                          style:UIAlertActionStyleDefault
                          handler:^(UIAlertAction * action) {
                              NSLog(@"Disable Touch ID");
                              //merchant_customer_id is a unique id associated with the currently logged in user.
                              [Minkasu2FA performMinkasu2FAOperation:MINKASU2FA_DISABLE_BIOMETRY merchantCustomerId:<merchant_customer_id> customTheme:mkcolorTheme];
                          }];
            }
            [menuOptionsActionSheet addAction:action];
        }

        [menuOptionsActionSheet addAction:[UIAlertAction
                                           actionWithTitle:@"Cancel"
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction * action) {
                                               [self dismissViewControllerAnimated:YES completion:nil];
                                           }]];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [menuOptionsActionSheet popoverPresentationController].barButtonItem = self.btnItemMenuOption;
        }

        [self presentViewController:menuOptionsActionSheet animated:YES completion:nil];
    }
}

@end
