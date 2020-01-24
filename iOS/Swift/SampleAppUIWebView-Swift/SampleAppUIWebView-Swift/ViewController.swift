//
//  ViewController.swift
//  SampleAppUIWebView-Swift
//
//  Created by Sachin Selvaraj on 11/28/18.
//  Copyright © 2018 Minkasu, Inc. All rights reserved.
//

import UIKit
import Minkasu2FA

class ViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var btnItemMenuOption: UIBarButtonItem!
    @IBOutlet weak var btnCreditDebit: UIButton!
    @IBOutlet weak var btnNetBanking: UIButton!

    var uiWebView : UIWebView!
    var merchantCustomerId : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        //Initializing UIWebView
        uiWebView = UIWebView(frame: CGRect(x: view.frame.origin.x ,
                                            y: view.frame.origin.y+150,
                                            width: view.frame.size.width,
                                            height: view.frame.size.height))
        uiWebView.delegate = self
        view.addSubview(uiWebView)

        btnNetBanking.layer.cornerRadius = 6.0
        btnCreditDebit.layer.cornerRadius = 6.0

        merchantCustomerId = "M_C001"
    }

    func initMinkasu2FA(){

        //Initialize Customer object
        let customer = Minkasu2FACustomerInfo()
        customer.firstName = "TestFirstName"
        customer.lastName = "TestLastName"
        customer.email = "test@minkasupay.com"
        customer.phone = "+919876543210"        // Format: +91XXXXXXXXXX (no spaces)

        let address = Minkasu2FAAddress()
        address.line1 = "123 Test Way"
        address.line2 = "Test Apartments"
        address.city = "Mumbai"
        address.state = "Maharashtra"           // Unabbreviated e.g. Maharashtra (not MH)
        address.country = "India"
        address.zipCode = "400068"              // Format: XXXXXX (no spaces)
        customer.address = address

        //Create the Config object with merchant_id, merchant_access_token, merchant_customer_id and customer object.
        //merchant_customer_id is a unique id associated with the currently logged in user.
        let config = Minkasu2FAConfig()
        config.merchantId = <merchant_id>
        config.merchantToken = <merchant_access_token>
        config.merchantCustomerId = <merchant_customer_id>
        //add customer to the Config object
        config.customerInfo = customer

        let orderInfo = Minkasu2FAOrderInfo()
        orderInfo.orderId = <order_id>
        config.orderInfo = orderInfo

        let mkColorTheme = Minkasu2FACustomTheme()
        mkColorTheme.navigationBarColor = UIColor.blue
        mkColorTheme.navigationBarTextColor = UIColor.white
        mkColorTheme.buttonBackgroundColor = UIColor.blue
        mkColorTheme.buttonTextColor = UIColor.white
        
        //Set supportDarkMode to true if the Merchant App supports Dark Mode
        mkcolorTheme.supportDarkMode = true
        
        //Use this to set a separate color theme for Dark mode
        mkcolorTheme.darkModeNavigationBarColor = UIColor.purple
        mkcolorTheme.darkModeNavigationBarTextColor = UIColor.white
        mkcolorTheme.darkModeButtonBackgroundColor = UIColor.purple
        mkcolorTheme.darkModeButtonTextColor = UIColor.white
        
        config.customTheme = mkColorTheme

        //set sdkMode to MINKASU2FA_SANDBOX_MODE if testing on sandbox
        config.sdkMode = Minkasu2FASDKMode.MINKASU2FA_SANDBOX_MODE

        //Initializing Minkasu2FA SDK with UIWebView object and the ViewController containing the UIWebView
        Minkasu2FA.initWith(uiWebView, andConfiguration: config, in: self)
    }

    @IBAction func clickNetBanking(_ sender: Any) {
        initMinkasu2FA()
        let url = URL(string: "https://sandbox.minkasupay.com/demo/Bank_Internet_Banking_login.htm")
        uiWebView.loadRequest(URLRequest(url: url!))
    }

    @IBAction func clickCreditDebit(_ sender: Any) {
        initMinkasu2FA()
        let url = URL(string: "https://sandbox.minkasupay.com/demo/Welcome_to_Net.html?minkasu2FA=true")
        uiWebView.loadRequest(URLRequest(url: url!))
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        return !Minkasu2FA.request(request, shouldHandleByMinkasu2FAIn: webView, navigationType: navigationType)
    }
    @IBAction func clickMenuOption(_ sender: Any) {
        let minkasu2FAOperations = Minkasu2FA.getAvailableMinkasu2FAOperations()
        if(minkasu2FAOperations.count > 0){
            let menuOptionsActionSheet = UIAlertController.init(title: nil, message: "Menu", preferredStyle: UIAlertController.Style.actionSheet)
            for case let operation as Int in minkasu2FAOperations {
                let mkColorTheme = Minkasu2FACustomTheme()
                mkColorTheme.navigationBarColor = UIColor.blue
                mkColorTheme.navigationBarTextColor = UIColor.white
                mkColorTheme.buttonBackgroundColor = UIColor.blue
                mkColorTheme.buttonTextColor = UIColor.white
                
                //Set supportDarkMode to true if the Merchant App supports Dark Mode
                mkcolorTheme.supportDarkMode = true
                
                //Use this to set a separate color theme for Dark mode
                mkcolorTheme.darkModeNavigationBarColor = UIColor.purple
                mkcolorTheme.darkModeNavigationBarTextColor = UIColor.white
                mkcolorTheme.darkModeButtonBackgroundColor = UIColor.purple
                mkcolorTheme.darkModeButtonTextColor = UIColor.white

                var action : UIAlertAction!
                if (operation == Int(Minkasu2FAOperationType.MINKASU2FA_CHANGE_PAYPIN.rawValue)){
                    action = UIAlertAction.init(title: "Change PayPIN",
                                                style:UIAlertAction.Style.default,
                                                handler: {(alert : UIAlertAction!) in
                                                    //merchant_customer_id is a unique id associated with the currently logged in user.
                                                    Minkasu2FA.perform(Minkasu2FAOperationType.MINKASU2FA_CHANGE_PAYPIN, merchantCustomerId: <merchant_customer_id>, customTheme: mkColorTheme)
                    })
                } else if(operation == Int(Minkasu2FAOperationType.MINKASU2FA_ENABLE_BIOMETRY.rawValue)){
                    action = UIAlertAction.init(title: "Enable Touch ID",
                                                style:UIAlertAction.Style.default,
                                                handler: {(alert : UIAlertAction!) in
                                                    //merchant_customer_id is a unique id associated with the currently logged in user.
                                                    Minkasu2FA.perform(Minkasu2FAOperationType.MINKASU2FA_ENABLE_BIOMETRY, merchantCustomerId: <merchant_customer_id>, customTheme: mkColorTheme)
                    })
                } else if(operation == Int(Minkasu2FAOperationType.MINKASU2FA_DISABLE_BIOMETRY.rawValue)){
                    action = UIAlertAction.init(title: "Disable Touch ID",
                                                style:UIAlertAction.Style.default,
                                                handler: {(alert : UIAlertAction!) in
                                                    //merchant_customer_id is a unique id associated with the currently logged in user.
                                                    Minkasu2FA.perform(Minkasu2FAOperationType.MINKASU2FA_DISABLE_BIOMETRY, merchantCustomerId: <merchant_customer_id>, customTheme: mkColorTheme)
                    })
                }
                menuOptionsActionSheet.addAction(action)
            }
            menuOptionsActionSheet.addAction(UIAlertAction.init(title: "Cancel",
                                                                style:UIAlertAction.Style.cancel,
                                                                handler: {(alert : UIAlertAction!) in
                                                                    self.dismiss(animated: true, completion: nil)
            }))

            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad){
                menuOptionsActionSheet.popoverPresentationController?.barButtonItem = btnItemMenuOption
            }

            self.present(menuOptionsActionSheet, animated: true, completion: nil)
        }
    }
}
