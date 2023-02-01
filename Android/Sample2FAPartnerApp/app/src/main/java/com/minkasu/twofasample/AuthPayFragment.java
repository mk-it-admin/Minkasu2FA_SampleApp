package com.minkasu.twofasample;

import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Toast;

import androidx.fragment.app.Fragment;

import com.minkasu.android.twofa.model.PartnerInfo;
import com.minkasu.android.twofa.sdk.Minkasu2faCallback;
import com.minkasu.android.twofa.sdk.Minkasu2faCallbackInfo;
import com.minkasu.android.twofa.sdk.Minkasu2faSDK;
import com.minkasu.android.twofa.model.Config;
import com.minkasu.android.twofa.model.Address;
import com.minkasu.android.twofa.model.CustomerInfo;
import com.minkasu.android.twofa.model.OrderInfo;

import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 */
public class AuthPayFragment extends Fragment {
    private Button mNetPayButton;
    private Button mCreditPayButton;
    private WebView mWebView;
    private EditText mCustomerPhone;
    private LinearLayout llActions;
    private Config config;

    private void loadUrl(String url) {
        String host = "https://sandbox.minkasupay.com";      // Sandbox Mode
        // String host = "https://transactions.minkasupay.com"; // Production Mode

        mNetPayButton.setVisibility(View.GONE);
        mCreditPayButton.setVisibility(View.GONE);
        mCustomerPhone.setVisibility(View.GONE);
        llActions.setVisibility(View.GONE);
        mWebView.setVisibility(View.VISIBLE);
        mWebView.loadUrl(host+url);
    }

    public AuthPayFragment() {
        // Required empty public constructor
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View inflatedView = inflater.inflate(R.layout.fragment_auth_pay, container, false);
        mWebView = inflatedView.findViewById(R.id.webView);
        mNetPayButton = inflatedView.findViewById(R.id.pay_net_button);
        mCreditPayButton = inflatedView.findViewById(R.id.pay_credit_button);
        mCustomerPhone = inflatedView.findViewById(R.id.customer_phone);
        llActions = inflatedView.findViewById(R.id.llActions);
        mWebView.setWebViewClient(new WebViewClient());        // to handle clicks within WebView
        mWebView.setWebChromeClient(new WebChromeClient());    // to show javascript alerts
        WebSettings webSettings = mWebView.getSettings();
        webSettings.setBuiltInZoomControls(true);
        webSettings.setDisplayZoomControls(false);
        //Loading Bank Login URL manually for testing purposes. Payment Gateway loads URL on the webview in live.
        //Net Banking Flow
        if (mNetPayButton != null) {
            mNetPayButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if ( Minkasu2faSDK.isSupportedPlatform()) {
                        initMinkasu2FASDK();
                        String bankCustomerPhone = config.getCustomerInfo().getPhone();
                        String encodedPhone = null;
                        try {
                            encodedPhone = URLEncoder.encode(bankCustomerPhone, "utf-8");
                        } catch (UnsupportedEncodingException io) {
                            System.out.println(io.getMessage());
                        }
                        loadUrl("/demo/Bank_Internet_Banking_login.htm?bankPhone=" + encodedPhone);

                    } else {
                        Toast.makeText(getActivity(), "Device is Rooted"
                                , Toast.LENGTH_LONG).show();
                        loadUrl("/demo/Bank_Internet_Banking_login.htm");
                    }
                }
            });
        }

        //Cards Flow
        if (mCreditPayButton != null) {
            mCreditPayButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if ( Minkasu2faSDK.isSupportedPlatform()) {
                        initMinkasu2FASDK();
                        String bankCustomerPhone = config.getCustomerInfo().getPhone();
                        String encodedPhone = null;
                        try {
                            encodedPhone = URLEncoder.encode(bankCustomerPhone, "utf-8");
                        } catch (UnsupportedEncodingException io) {
                            System.out.println(io.getMessage());
                        }
                        loadUrl("/demo/Welcome_to_Net.html?bankPhone=" + encodedPhone);
                    }else{
                        Toast.makeText(getActivity(), "Device is Rooted"
                                , Toast.LENGTH_LONG).show();
                        loadUrl("/demo/Welcome_to_Net.html");
                    }
                }
            });
        }
        mCustomerPhone.setVisibility(View.GONE);
        return inflatedView;
    }

    /**
     * Initializing Minkasu 2FA SDK with the Config Object and Webview.
     */
    private void initMinkasu2FASDK() {
        try {
            // You can get the current SDK version using the method below.
            //Minkasu2faSDK.getSDKVersion(getActivity());

            //Create the Customer object. First Name, Last Name, email and phone are required fields.
            CustomerInfo customer = new CustomerInfo();
            customer.setFirstName("TestCustomer");
            customer.setLastName("TestLastName");
            customer.setEmail("test@minkasupay.com");
            customer.setPhone(<customer_phone>);     // Format: +91XXXXXXXXXX (no spaces)

            Address address = new Address();
            address.setAddressLine1("123 Test Way");
            address.setAddressLine2("Test Soc");
            address.setCity("Mumbai");
            address.setState("Maharastra");         // Unabbreviated e.g. Maharashtra (not MH)
            address.setCountry("India");
            address.setZipCode("400068");           // Format: XXXXXX (no spaces)
            customer.setAddress(address);

            //Create the PartnerInfo object with partner_merchant_id, partner_merchant_name and partner_transaction_id.
            PartnerInfo partnerInfo = new PartnerInfo(<partner_merchant_id>,<partner_merchant_name>, <partner_transaction_id>);

            //Create the Config object with partner_id, partner_access_token, merchant_customer_id, partnerInfo object and customer object.
            //merchant_customer_id is a unique id associated with the currently logged in user.
            config = Config.getInstance(<partner_id>,<partner_access_token>,MainActivity.MERCHANT_CUSTOMER_ID,partnerInfo,customer);

            //set up SDK mode ie. by default its always production if we dont set it
            config.setSDKMode(Config.SANDBOX_MODE);

            //Create the OrderInfo object with order_id as a compulsory parameter.
            OrderInfo orderInfo = new OrderInfo();
            orderInfo.setOrderId(<order_id>);

            //Optionally specify merchant’s billing category to identify the type of transaction for billing purposes.
            orderInfo.setBillingCategory(<billing_category>); // Billing category eg. FLIGHTS, BUS, TRAINS

            //Optionally specify any custom order data to be attributed to the transaction here.
            JSONObject orderDetails = new JSONObject();
            //Any number for key value pairs
            orderDetails.put(<key>,<value>);
            orderDetails.put(<key>,<value>);
            orderDetails.put(<key>,<value>);
            orderInfo.setCustomData(orderDetails.toString());
            config.setOrderInfo(orderInfo);

            //Initialize Minkasu 2FA SDK with the Config object and the Webview and the callback
            Utils.initMinkasu2FAWithCallback(requireActivity(), config, mWebView);
        }
        catch(Exception e){
            Log.i("Exception",e.toString());

        }
    }
}
