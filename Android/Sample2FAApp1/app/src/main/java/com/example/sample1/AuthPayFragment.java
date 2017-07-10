package com.example.sample1;

import android.app.Fragment;
import android.content.Context;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.preference.PreferenceManager;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.webkit.WebChromeClient;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;

import com.minkasu.android.twofa.sdk.Minkasu2faSDK;
import com.minkasu.android.twofa.model.Config;
import com.minkasu.android.twofa.model.Address;
import com.minkasu.android.twofa.model.CustomerInfo;
import com.minkasu.android.twofa.model.OrderInfo;
import com.minkasu.android.twofa.model.OrderItem;

import java.util.ArrayList;
import java.util.List;


/**
 * A simple {@link Fragment} subclass.
 * Activities that contain this fragment must implement the
 * {@link AuthPayFragment.OnFragmentInteractionListener} interface
 * to handle interaction events.
 * Use the {@link AuthPayFragment#newInstance} factory method to
 * create an instance of this fragment.
 */
public class AuthPayFragment extends Fragment {
    private Button mNetPayButton;
    private Button mCreditPayButton;
    private WebView mWebView;
    private EditText mCustomerPhone;
    private LinearLayout llActions;
    private SharedPreferences mSharedPreferences;

    public void loadUrl(String url) {
        String host = "http://sandbox.minkasupay.com";

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

    /**
     * Use this factory method to create a new instance of
     * this fragment using the provided parameters.
     *
     * @param param1 Parameter 1.
     * @param param2 Parameter 2.
     * @return A new instance of fragment AuthPayFragment.
     */
    // TODO: Rename and change types and number of parameters
    public static AuthPayFragment newInstance(String param1, String param2) {
        AuthPayFragment fragment = new AuthPayFragment();
        Bundle args = new Bundle();
        fragment.setArguments(args);
        return fragment;
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (getArguments() != null) {
        }
         setHasOptionsMenu(true);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        // Inflate the layout for this fragment
        View inflatedView = inflater.inflate(R.layout.fragment_auth_pay, container, false);

        mSharedPreferences = PreferenceManager.getDefaultSharedPreferences(getActivity());
        mWebView = (WebView) inflatedView.findViewById(R.id.webview);
        mNetPayButton = (Button) inflatedView.findViewById(R.id.pay_net_button);
        mCreditPayButton = (Button) inflatedView.findViewById(R.id.pay_credit_button);
        mCustomerPhone = (EditText) inflatedView.findViewById(R.id.customer_phone);
        llActions = (LinearLayout) inflatedView.findViewById(R.id.llActions);
        mWebView.setWebViewClient(new WebViewClient());        // to handle clicks within WebView
        mWebView.setWebChromeClient(new WebChromeClient());    // to show javascript alerts

        //Loading Bank Login URL manually for testing purposes. Payment Gateway loads URL on the webview in live.
        //Net Banking Flow
        if (mNetPayButton != null) {
            mNetPayButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    initMinkasu2FASDK();
                    loadUrl("/demo/Bank_Internet_Banking_login.htm");
                }
            });
        }

        //Cards Flow
        if (mCreditPayButton != null) {
            mCreditPayButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    initMinkasu2FASDK();
                    loadUrl("/demo/Welcome_to_Net.html?minkasu2FA=true");
                }
            });
        }

        mCustomerPhone.setVisibility(View.GONE);
        return inflatedView;
    }

    @Override
    public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        super.onCreateOptionsMenu(menu, inflater);
        inflater.inflate(R.menu.fragment_menu, menu);
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
            customer.setPhone("+919876543210");

            Address address = new Address();
            address.setAddressLine1("123 Test way");
            address.setAddressLine2("Test Soc");
            address.setCity("Mumbai");
            address.setState("Maharastra");
            address.setCountry("India");
            address.setZipCode("400068");
            customer.setAddress(address);

            //Create the Config object with merchant_id, merchant_access_token, merchant_customer_id and customer object.
            Config config = Config.getInstance(<merchant_id>,<merchant_access_token>,<merchant_customer_id>,customer);

            //set up SDK mode ie. by default its always production if we dont set it
            config.setSDKMode(Config.SANDBOX_MODE);

            //Create the current Order Info.
            OrderInfo orderInfo = new OrderInfo();
            orderInfo.setOrderId("Ord01_"+Math.random());
            orderInfo.setBillingAddress(address);
            orderInfo.setShippingAddress(address);

            OrderItem item1 = new OrderItem();
            item1.setAmount(120.00);
            item1.setDescription("Phone Cover");
            item1.setQuantity(1);
            item1.setSkuId("sku342");
            OrderItem item2 = new OrderItem();
            item2.setAmount(126.00);
            item2.setDescription("Nexus Phone");
            item2.setQuantity(1);
            item2.setSkuId("sku300");

            List<OrderItem> orderItemList = new ArrayList<>();
            orderItemList.add(item1);
            orderItemList.add(item2);
            orderInfo.setOrderItemList(orderItemList);

            config.setOrderInfo(orderInfo);

            //Initialize Minkasu 2FA SDK with the Config object and the Webview.
            Minkasu2faSDK.init(getActivity(),config,mWebView);
        }
        catch(Exception e){
            e.printStackTrace();

        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // handle item selection
        switch (item.getItemId()) {
            case 0:
                // do s.th.
                return true;
            default:
                return super.onOptionsItemSelected(item);
        }
    }

    // TODO: Rename method, update argument and hook method into UI event
    public void onButtonPressed(Uri uri) {
    }

    @Override
    public void onAttach(Context context) {
        super.onAttach(context);
    }

    @Override
    public void onDetach() {
        super.onDetach();
        //mListener = null;
    }

    /**
     * This interface must be implemented by activities that contain this
     * fragment to allow an interaction in this fragment to be communicated
     * to the activity and potentially other fragments contained in that
     * activity.
     * <p>
     * See the Android Training lesson <a href=
     * "http://developer.android.com/training/basics/fragments/communicating.html"
     * >Communicating with Other Fragments</a> for more information.
     */
    public interface OnFragmentInteractionListener {
        // TODO: Update argument type and name
        //void onFragmentInteraction(Uri uri);
    }

    @Override
    public void onResume() {
        super.onResume();
    }

    @Override
    public void onStart() {
        super.onStart();
    }
}
