package com.minkasu.twofasample;

import android.graphics.Bitmap;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
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

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.play.core.splitinstall.SplitInstallManager;
import com.google.android.play.core.splitinstall.SplitInstallManagerFactory;
import com.google.android.play.core.splitinstall.SplitInstallRequest;
import com.google.android.play.core.splitinstall.SplitInstallSessionState;
import com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener;
import com.google.android.play.core.splitinstall.model.SplitInstallSessionStatus;
import com.google.android.play.core.splitinstall.testing.FakeSplitInstallManager;
import com.google.android.play.core.splitinstall.testing.FakeSplitInstallManagerFactory;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.util.Collections;


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
    private LinearLayout progressLay;
    private boolean redirectUrlLoading = false;
    private static final int PROGRESS_SHOW = 10231;
    private static final int PROGRESS_DISMISS = 10232;
    private int mySessionId;
    private Minkasu2faDFMInterface minkasu2faDFMInterface = null;

    private final Handler progressHandler = new Handler(new Handler.Callback() {
        @Override
        public boolean handleMessage(@NonNull Message msg) {
            if (msg.what == PROGRESS_DISMISS) {
                //Log.e("Progress Indicator", "Progress Indicator Dismiss");
                if (progressLay.getVisibility() == View.VISIBLE) {
                    progressLay.setVisibility(View.GONE);
                }
            } else if (msg.what == PROGRESS_SHOW) {
                //Log.e("Progress Indicator", "Progress Indicator Show");
                progressLay.setVisibility(View.VISIBLE);
            }
            return false;
        }
    });
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
        progressLay = inflatedView.findViewById(R.id.progressLay);
        mWebView.setWebViewClient(new WebViewClient());        // to handle clicks within WebView
        mWebView.setWebChromeClient(new WebChromeClient());    // to show javascript alerts
        WebSettings webSettings = mWebView.getSettings();
        webSettings.setBuiltInZoomControls(true);
        webSettings.setDisplayZoomControls(false);
        mWebView.setWebViewClient(new WebViewClient() {
            @Override
            public void onPageStarted(WebView view, String url, Bitmap favicon) {
                super.onPageStarted(view, url, favicon);
            }

            @Override
            public void onPageFinished(WebView view, String url) {
                super.onPageFinished(view, url);
                if(redirectUrlLoading){
                    //Log.e("Progress Indicator", "Progress Indicator Hide Inside webviewclient");
                    redirectUrlLoading = false;
                    progressHandler.sendEmptyMessage(PROGRESS_DISMISS);
                    //progressHandler.sendEmptyMessageDelayed(PROGRESS_DISMISS,1000); // Enable to check the progress bar implementation
                }
            }
        });

        try {
            Class<?> minkasuDFM = Class.forName("com.minkasu.androiddfm.Minkasu2faDFM");
            minkasu2faDFMInterface = (Minkasu2faDFMInterface) minkasuDFM.getDeclaredConstructor().newInstance();
        } catch (Exception e) {
            Log.e("MainActivity", "Error in initializing Minkasu2faDFM instance. Error:" + e.getMessage());
        }

        //Loading Bank Login URL manually for testing purposes. Payment Gateway loads URL on the webview in live.
        //Net Banking Flow
        if (mNetPayButton != null) {
            mNetPayButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if ( minkasu2faDFMInterface.isSupportedPlatform()) {
                        initMinkasu2FASDKDFM();
                        String bankCustomerPhone = mCustomerPhone.getText().toString().trim();
                        String encodedPhone = null;
                        try {
                            encodedPhone = URLEncoder.encode(bankCustomerPhone, "utf-8");
                        } catch (UnsupportedEncodingException io) {
                            System.out.println(io.getMessage());
                        }
                        loadUrl("/demo/nb_login.html?bankPhone=" + encodedPhone);

                    } else {
                        Toast.makeText(getActivity(), "Device is Rooted"
                                , Toast.LENGTH_LONG).show();
                        loadUrl("/demo/nb_login.html");
                    }
                }
            });
        }

        //Cards Flow
        if (mCreditPayButton != null) {
            mCreditPayButton.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if ( minkasu2faDFMInterface.isSupportedPlatform()) {
                        initMinkasu2FASDKDFM();
                        String bankCustomerPhone = mCustomerPhone.getText().toString().trim();
                        String encodedPhone = null;
                        try {
                            encodedPhone = URLEncoder.encode(bankCustomerPhone, "utf-8");
                        } catch (UnsupportedEncodingException io) {
                            System.out.println(io.getMessage());
                        }
                        loadUrl("/demo/card.html?bankPhone=" + encodedPhone);
                    }else{
                        Toast.makeText(getActivity(), "Device is Rooted"
                                , Toast.LENGTH_LONG).show();
                        loadUrl("/demo/card.html");
                    }
                }
            });
        }
        mCustomerPhone.setVisibility(View.GONE);

        changeButtonState(false);
        mNetPayButton.post(new Runnable() {
            @Override
            public void run() {
                downloadMinkasu2FADynamicModule();
            }
        });

        return inflatedView;
    }

    private void changeButtonState(boolean state) {
        mNetPayButton.setEnabled(state);
        mCreditPayButton.setEnabled(state);
    }

    private void downloadMinkasu2FADynamicModule() {
        Log.i("AuthPayFragment", "downloadMinkasu2FADynamicModule: ");
        SplitInstallManager splitInstallManager = SplitInstallManagerFactory.create(requireActivity());

        if (splitInstallManager.getInstalledModules().contains("minkasu_2fa_dfm")) {
            changeButtonState(true);
            Toast.makeText(getActivity(), "Dynamic Minaksu2FA Module is already installed", Toast.LENGTH_SHORT).show();
            return;
        }

        /*
        // Schedule the feature module for deferred installation
        splitInstallManager.deferredInstall(Collections.singletonList("minkasu_2fa_dfm"))
                .addOnSuccessListener(unused -> {
                    System.out.println("Module 'minkasu_2fa_dfm' has been scheduled for deferred install.");
                })
                .addOnFailureListener(exception -> {
                    // Handle any errors
                    System.err.println("Failed to schedule module 'minkasu_2fa_dfm' for deferred install.");
                    exception.printStackTrace();
                });
        */


        // Schedule the feature module for on ondemand installation
        SplitInstallRequest request = SplitInstallRequest.newBuilder()
                .addModule("minkasu_2fa_dfm").build();

        SplitInstallStateUpdatedListener listener = new SplitInstallStateUpdatedListener() {
            @Override
            public void onStateUpdate(SplitInstallSessionState splitInstallSessionState) {
                if (getActivity() == null) {
                    return;
                }
                if (splitInstallSessionState.sessionId() == mySessionId) {
                    switch (splitInstallSessionState.status()) {
                        case SplitInstallSessionStatus.DOWNLOADING:
                            Log.d("AuthPayFragment", "Dynamic Minaksu2FA Module DOWNLOADING");
                            Toast.makeText(getActivity(), "Dynamic Minaksu2FA Module downloading", Toast.LENGTH_SHORT).show();
                            break;
                        case SplitInstallSessionStatus.DOWNLOADED:
                            Log.d("AuthPayFragment", "Dynamic Minaksu2FA Module DOWNLOADED");
                            Toast.makeText(getActivity(), "Dynamic Minaksu2FA Module downloaded", Toast.LENGTH_SHORT).show();
                            break;
                        case SplitInstallSessionStatus.INSTALLING:
                            Log.d("AuthPayFragment", "Dynamic Minaksu2FA Module INSTALLING");
                            Toast.makeText(getActivity(), "Dynamic Minaksu2FA Module installing", Toast.LENGTH_SHORT).show();
                            break;
                        case SplitInstallSessionStatus.CANCELING:
                            Log.d("AuthPayFragment", "Dynamic Minaksu2FA Module CANCELING");
                            Toast.makeText(getActivity(), "Dynamic Minaksu2FA Module canceling", Toast.LENGTH_SHORT).show();
                            break;
                        case SplitInstallSessionStatus.CANCELED:
                            Log.d("AuthPayFragment", "Dynamic Minaksu2FA Module CANCELED");
                            Toast.makeText(getActivity(), "Dynamic Minaksu2FA Module canceled", Toast.LENGTH_SHORT).show();
                            break;
                        case SplitInstallSessionStatus.PENDING:
                            Log.d("AuthPayFragment", "Dynamic Minaksu2FA Module PENDING");
                            Toast.makeText(getActivity(), "Dynamic Minaksu2FA Module pending", Toast.LENGTH_SHORT).show();
                            break;
                        case SplitInstallSessionStatus.FAILED:
                            Log.d("AuthPayFragment", "Dynamic Minaksu2FA Module FAILED");
                            Toast.makeText(getActivity(), "Dynamic Minaksu2FA Module failed", Toast.LENGTH_SHORT).show();
                            break;
                        case SplitInstallSessionStatus.INSTALLED:
                            Log.d("AuthPayFragment", "Dynamic Minaksu2FA Module INSTALLED");
                            Toast.makeText(getActivity(), "Dynamic Minaksu2FA Module installed", Toast.LENGTH_SHORT).show();
                            changeButtonState(true);
                            break;
                    }
                }
            }
        };

        splitInstallManager.registerListener(listener);

        splitInstallManager.startInstall(request)
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(Exception e) {
                        Log.d("AuthPayFragment", "Exception: " + e);
                    }
                })
                .addOnSuccessListener(new OnSuccessListener<Integer>() {
                    @Override
                    public void onSuccess(Integer sessionId) {
                        mySessionId = sessionId;
                        Log.i("AuthPayFragment", "Success: ");
                    }

                });

    }


    private void initMinkasu2FASDKDFM() {
        try {
            String customerPhone = mCustomerPhone.getText().toString().trim();

            JSONObject configJson = new JSONObject();
            configJson.put("id", "13579");
            configJson.put("token", "789385aed6e4e3ff3e097f57dc58b4d8");
            configJson.put("customer_id", MainActivity.MERCHANT_CUSTOMER_ID);
            configJson.put("sandbox_mode", true);
            configJson.put("disable_user_agent", false);

            JSONObject customerJson = new JSONObject();
            customerJson.put("first_name", "TestCustomer");
            customerJson.put("last_name", "TestLastName");
            customerJson.put("email", "test@minkasupay.com");
            customerJson.put("phone_no", customerPhone);

            JSONObject addressJson = new JSONObject();
            addressJson.put("address_line1", "123 Test way");
            addressJson.put("address_line2", "Test Soc");
            addressJson.put("city", "Mumbai");
            addressJson.put("state", "Maharastra");
            addressJson.put("country", "India");
            addressJson.put("zip_code", "400068");

            customerJson.put("address", addressJson);
            configJson.put("customer", customerJson);

            JSONObject orderJson = new JSONObject();
            orderJson.put("order_id", "Ord01_" + Math.random());

            orderJson.put("billing_category", "FLIGHT");

            JSONObject orderDetails = new JSONObject();
            orderDetails.put("key1", "val1");
            orderDetails.put("key2", "val2");
            orderDetails.put("key3", "val3");
            orderJson.put("custom_data", orderDetails.toString());

            configJson.put("order", orderJson);

            //Class<?> minkasuDFM = Class.forName("com.minkasu.androiddfm.Minkasu2faDFM");
            //Minkasu2faDFMInterface minkasu2faDFMInterface = (Minkasu2faDFMInterface) minkasuDFM.getDeclaredConstructor().newInstance();
            boolean initializeStatus = minkasu2faDFMInterface.initializeSDK(requireActivity(), mWebView, configJson, new Minkasu2faCallbackInterface() {
                @Override
                public void handleInfo(int infoType, JSONObject payload) {
                    try {
                        Log.e("Minkasu Callback Type", String.valueOf(infoType));
                        if (infoType == 1) {
                            /*
                            {
                              "reference_id": "<minkasu_transaction_ref>",  // UUID string
                              "status": "<SUCCESS|FAILED|TIMEOUT|CANCELLED|DISABLED>",
                              "source": "<SDK|SERVER|BANK>",
                              "code": <result/error code>, // 0 => Status SUCCESS, Non-zero values => Other status.
                              "message": "<result/error message>"
                            }
                           */
                            Log.e("Minkasu Result", payload != null ? payload.toString() : "no result");
                        } else if (infoType == 2) {
                            /*
                            {
                              "reference_id": "<minkasu_transaction_ref>",  // UUID string
                              "screen": "<FTU_SETUP_CODE_SCREEN|FTU_AUTH_SCREEN|REPEAT_AUTH_SCREEN>",
                              "event": "<ENTRY>"
                            }
                           */
                            Log.e("Minkasu Event", payload != null ? payload.toString() : "no event");
                        } else if (infoType == 3) {
                            /*
                            {
                              "reference_id": "<minkasu_transaction_ref>",  // UUID string
                              "visibility": "<true/false>",
                              "start_timer": "<true/false>",
                              "redirect_url_loading":"<true/false>"
                            }
                           */
                            Log.e("Progress Indicator", payload != null ? payload.toString() : "no progress state");
                            if (payload != null && payload.has("visibility")) {
                                boolean visibility = payload.getBoolean("visibility");
                                progressHandler.removeCallbacksAndMessages(null);
                                redirectUrlLoading = false;
                                if (visibility) {
                                    progressHandler.sendEmptyMessage(PROGRESS_SHOW);
                                    if (payload.optBoolean("start_timer")) {
                                        progressHandler.sendEmptyMessageDelayed(PROGRESS_DISMISS, 5000);
                                    }
                                    redirectUrlLoading = payload.optBoolean("redirect_url_loading");
                                } else {
                                    progressHandler.sendEmptyMessageDelayed(PROGRESS_DISMISS, 1000);
                                }
                            }

                        }
                    } catch (Exception e) {
                        Log.e("AuthPayFragment", e.getMessage());
                    }
                }
            });

            if (!initializeStatus) {
                Log.e("AuthPayFragment", "Minkasu2FASDKInitialization Error");
            }
        } catch (Exception e) {
            Log.e("Error occurred", e.toString());
        }
    }
}
