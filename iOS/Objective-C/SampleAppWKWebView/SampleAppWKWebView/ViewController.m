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
    customer.phone = @"+919876543210";

    Minkasu2FAAddress *address = [Minkasu2FAAddress new];
    address.line1 = @"123 Test way";
    address.line2 = @"Test Apartments";
    address.city = @"Mumbai";
    address.state = @"Maharashtra";
    address.country= @"India";
    address.zipCode = @"400068";
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

    //Initializing Minkasu2FA SDK with WKWebView object
    [Minkasu2FA initWithWKWebView:_wkWebView andConfiguration:config];
}
//****END Minkasu2FA Code***************


- (IBAction)clickNetBanking:(id)sender {
    //Initializing Minkasu2FA SDK before initating Payment
    [self initMinkasu2FA];
    NSURL *nsurl=[NSURL URLWithString:@"https://sandbox.minkasupay.com/demo/Bank_Internet_Banking_login.htm"];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [_wkWebView loadRequest:nsrequest];
}

- (IBAction)clickCreditDebit:(id)sender {
    //Initializing Minkasu2FA SDK before initating Payment
    [self initMinkasu2FA];
    NSURL *nsurl=[NSURL URLWithString:@"https://sandbox.minkasupay.com/demo/Welcome_to_Net.html?minkasu2FA=true"];
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
