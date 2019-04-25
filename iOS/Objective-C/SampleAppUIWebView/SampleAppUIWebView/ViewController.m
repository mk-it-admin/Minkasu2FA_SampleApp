//
//  ViewController.m
//  SampleAppUIWebView
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
    //Initializing UIWebView
    self.uiWebView = [[UIWebView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y+150, self.view.frame.size.width, self.view.frame.size.height)];
    _uiWebView.delegate = self;
    [self.view addSubview:_uiWebView];

    [self.btnNetBanking.layer setCornerRadius:6.0];
    [self.btnCreditDebit.layer setCornerRadius:6.0];

    merchantCustomerId = @"M_C001";
}

//****START Minkasu2FA Code***************
- (void) initMinkasu2FA{
    //initialize Customer object
    Minkasu2FACustomerInfo *customer = [Minkasu2FACustomerInfo new];
    customer.firstName = @"TestFirstName";
    customer.lastName = @"TestLastName";
    customer.email = @"test@minkasupay.com";
    customer.phone = @"+919876543210";          // Format: +91XXXXXXXXXX (no spaces)

    Minkasu2FAAddress *address = [Minkasu2FAAddress new];
    address.line1 = @"123 Test Way";
    address.line2 = @"Test Apartments";
    address.city = @"Mumbai";
    address.state = @"Maharashtra";             // Unabbreviated e.g. Maharashtra (not MH)
    address.country= @"India";
    address.zipCode = @"400068";                // Format: XXXXXX (no spaces)
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

    //Initializing Minkasu2FA SDK with UIWebView object and the ViewController containing the UIWebView
    [Minkasu2FA initWithUIWebView:_uiWebView andConfiguration:config inViewController:self];
}
//****END Minkasu2FA Code***************

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //Return YES or NO based on wether the request is a Minkasu 2FA Bridge Function
    return ![Minkasu2FA request:request shouldHandleByMinkasu2FAInWebView:webView navigationType:navigationType];
}

- (IBAction)clickNetBanking:(id)sender {
    //Initializing Minkasu2FA SDK before initating Payment
    [self initMinkasu2FA];
    NSURL *nsurl=[NSURL URLWithString:@"https://sandbox.minkasupay.com/demo/Bank_Internet_Banking_login.htm"];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [_uiWebView loadRequest:nsrequest];
}

- (IBAction)clickCreditDebit:(id)sender {
    //Initializing Minkasu2FA SDK before initating Payment
    [self initMinkasu2FA];
    NSURL *nsurl=[NSURL URLWithString:@"https://sandbox.minkasupay.com/demo/Welcome_to_Net.html?minkasu2FA=true"];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [_uiWebView loadRequest:nsrequest];
}

- (IBAction)clickMenuOption:(id)sender {
    NSMutableArray *minkasu2FAOpertions = [Minkasu2FA getAvailableMinkasu2FAOperations];
    if([minkasu2FAOpertions count] > 0){
        UIAlertController *menuOptionsActionSheet = [UIAlertController alertControllerWithTitle:nil message:@"Menu" preferredStyle:UIAlertControllerStyleActionSheet];
        for (NSNumber *operation in minkasu2FAOpertions){
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
