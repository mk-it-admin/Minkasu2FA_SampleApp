package com.minkasu.twofasample;

import android.app.Activity;
import android.content.Context;
import android.webkit.WebView;

import androidx.annotation.NonNull;

import org.json.JSONObject;

import java.util.List;

public interface Minkasu2faDFMInterface {
    String CHANGE_PAYPIN = "Change PayPIN";
    String ENABLE_BIOMETRICS = "Enable Biometrics";
    String DISABLE_BIOMETRICS = "Disable Biometrics";
    boolean initializeSDK(@NonNull Activity activity,@NonNull WebView webView,@NonNull JSONObject config, Minkasu2faCallbackInterface callback);
    List<String> getAvailableMinkasu2FAOperation(Context context);
    void performMinkasu2FAOperation(Activity activity, String opType, String merchantCustomerId);
    boolean isSupportedPlatform();


}
