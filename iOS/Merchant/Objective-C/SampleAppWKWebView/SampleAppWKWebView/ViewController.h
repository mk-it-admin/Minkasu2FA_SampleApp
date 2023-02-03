//
//  ViewController.h
//  SampleAppWKWebView
//
//  Created by Praveena Khanna on 10/9/18.
//  Copyright © 2018 minkasu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface ViewController : UIViewController<WKUIDelegate, NSURLConnectionDataDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnNetBanking;
@property (weak, nonatomic) IBOutlet UIButton *btnCreditDebit;
@property ( nonatomic)  WKWebView *wkWebView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnItemMenuOption;

- (IBAction)clickNetBanking:(id)sender;
- (IBAction)clickCreditDebit:(id)sender;
- (IBAction)clickMenuOption:(id)sender;

@end

