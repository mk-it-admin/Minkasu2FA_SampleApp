//
//  ViewController.swift
//  SampleAppWKWebView-Swift
//
//  Created by Sachin Selvaraj on 11/28/18.
//  Copyright © 2018 Minkasu, Inc. All rights reserved.
//

import UIKit
import WebKit
import Minkasu2FA

class ViewController: UIViewController, WKUIDelegate , Minkasu2FACallbackDelegate {

    @IBOutlet weak var btnNetBanking: UIButton!
    @IBOutlet weak var btnCreditDebit: UIButton!
    @IBOutlet weak var btnItemMenuOption: UIBarButtonItem!

    var wkWebView : WKWebView!
    var merchantCustomerId : String!
    var config : Minkasu2FAConfig!

    override func viewDidLoad() {
        super.viewDidLoad()

        //Initializing WKWebView
        let wkWebViewConfig = WKWebViewConfiguration()
        wkWebView = WKWebView(frame: CGRect(x: view.frame.origin.x ,
            y: view.frame.origin.y+150,
            width: view.frame.size.width,
            height: view.frame.size.height), configuration: wkWebViewConfig)

        view.addSubview(wkWebView)

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
        customer.phone = <customer_phone>    // Format: +91XXXXXXXXXX (no spaces)

        let address = Minkasu2FAAddress()
        address.line1 = "123 Test Way"
        address.line2 = "Test Apartments"
        address.city = "Mumbai"
        address.state = "Maharashtra"       // Unabbreviated e.g. Maharashtra (not MH)
        address.country = "India"
        address.zipCode = "400068"          // Format: XXXXXX (no spaces)
        customer.address = address

        //Create the Config object with merchant_id, merchant_access_token, merchant_customer_id and customer object.
        //merchant_customer_id is a unique id associated with the currently logged in user.
        config = Minkasu2FAConfig()
        config.delegate = self
        config._id = <merchant_id>
        config.token = <merchant_access_token>
        config.merchantCustomerId = <merchant_customer_id>
        //add customer to the Config object
        config.customerInfo = customer

        let orderInfo = Minkasu2FAOrderInfo()
        orderInfo.orderId = <order_id>
        
        // Optionally specify billing category and order details
        orderInfo.billingCategory = <billing_category> // e.g. “FLIGHTS”
        let orderDetails = [String : Any]; // e.g. [<custom_key_1> : <custom_value_1>, <custom_key_2> : <custom_value_2>, <custom_key_3> : <custom_value_3>]
        let encoder = JSONEncoder()
        if let jsonData = try? encoder.encode(orderDetails) {
            if let orderDetailsJsonString = String(data: jsonData, encoding: .utf8) {
                orderInfo.orderDetails = orderDetailsJsonString
            }
        }
        config.orderInfo = orderInfo

        let mkColorTheme = Minkasu2FACustomTheme()
        mkColorTheme.navigationBarColor = UIColor.blue
        mkColorTheme.navigationBarTextColor = UIColor.white
        mkColorTheme.buttonBackgroundColor = UIColor.blue
        mkColorTheme.buttonTextColor = UIColor.white
        
        //Set supportDarkMode to true if the Merchant App supports Dark Mode
        mkColorTheme.supportDarkMode = true
        
        //Use this to set a separate color theme for Dark mode
        mkColorTheme.darkModeNavigationBarColor = UIColor.purple
        mkColorTheme.darkModeNavigationBarTextColor = UIColor.white
        mkColorTheme.darkModeButtonBackgroundColor = UIColor.purple
        mkColorTheme.darkModeButtonTextColor = UIColor.white
        
        config.customTheme = mkColorTheme

        //set sdkMode to MINKASU2FA_SANDBOX_MODE if testing on sandbox
        config.sdkMode = Minkasu2FASDKMode.MINKASU2FA_SANDBOX_MODE

        //Initializing Minkasu2FA SDK with WKWebView object
        if #available(iOS 13, *) {
            do {
                try Minkasu2FA.initWith(wkWebView, andConfiguration: config)
            } catch let error as NSError {
                //Minkasu init failed - handle error
                print("Minkasu init failed error with domain: \(error.domain) and description \(error.localizedDescription)")
            }
        }
    }

    @IBAction func clickNetBanking(_ sender: Any) {
        initMinkasu2FA()
        
        let encodedCustomerPhone = config.customerInfo.phone.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
        let paymentURL = "https://sandbox.minkasupay.com/demo/Bank_Internet_Banking_login.htm?bankPhone="+encodedCustomerPhone!
        let url = URL(string: paymentURL)
        wkWebView.load(URLRequest(url: url!))
    }

    @IBAction func clickCreditDebit(_ sender: Any) {
        initMinkasu2FA()
        
        let encodedCustomerPhone = config.customerInfo.phone.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
        let paymentURL = "https://sandbox.minkasupay.com/demo/Welcome_to_Net.html?bankPhone="+encodedCustomerPhone!
        let url = URL(string: paymentURL)
        wkWebView.load(URLRequest(url: url!))
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
                mkColorTheme.supportDarkMode = true
                
                //Use this to set a separate color theme for Dark mode
                mkColorTheme.darkModeNavigationBarColor = UIColor.purple
                mkColorTheme.darkModeNavigationBarTextColor = UIColor.white
                mkColorTheme.darkModeButtonBackgroundColor = UIColor.purple
                mkColorTheme.darkModeButtonTextColor = UIColor.white

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
    
    func minkasu2FACallback(_ minkasu2FACallbackInfo: Minkasu2FACallbackInfo) {
        if minkasu2FACallbackInfo.infoType == 1{  // INFO_TYPE_RESULT
            // Refer data format in table below.
        } else if minkasu2FACallbackInfo.infoType == 2{  // INFO_TYPE_EVENT
            // Refer data format in table below.
        } else if minkasu2FACallbackInfo.infoType == 3{  // INFO_TYPE_PROGRESS
            // Refer data format in table below.
        }
    }
}
