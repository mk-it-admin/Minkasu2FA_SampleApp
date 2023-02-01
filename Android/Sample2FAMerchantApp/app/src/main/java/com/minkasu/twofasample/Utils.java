package com.minkasu.twofasample;

import android.app.Activity;
import android.util.Log;
import android.webkit.WebView;

import com.minkasu.android.twofa.model.Config;
import com.minkasu.android.twofa.sdk.Minkasu2faCallback;
import com.minkasu.android.twofa.sdk.Minkasu2faCallbackInfo;
import com.minkasu.android.twofa.sdk.Minkasu2faSDK;

import org.json.JSONObject;

public class Utils {

    public static void initMinkasu2FA(Activity activity, Config config, WebView webview){
        //Initialize Minkasu 2FA SDK with the Config object and the Webview
        Minkasu2faSDK.init(activity,config,webview);
    }

    public static void initMinkasu2FAWithCallback(Activity activity, Config config, WebView webview){
        //Initialize Minkasu 2FA SDK with the Config object and the Webview and Minkasu2faCallback
        Minkasu2faSDK.init(activity, config,webview, new Minkasu2faCallback() {
            @Override
            public void handleInfo(Minkasu2faCallbackInfo callbackInfo) {
                int infoType = callbackInfo.getInfoType();
                Log.e("Minkasu Callback Type", String.valueOf(infoType));
                JSONObject payload = callbackInfo.getData();
                if (infoType == Minkasu2faCallbackInfo.INFO_TYPE_RESULT) {
                        /*
                        {
                          "reference_id": "<minkasu_transaction_ref>",  // UUID string
                          "status": "<SUCCESS|FAILED|TIMEOUT|CANCELLED|DISABLED>", // Constants are defined in Minkasu2faCallbackInfo class for reference such as Minkasu2faCallbackInfo.MK2FA_SUCCESS
                          "source": "<SDK|SERVER|BANK>", // Constants are defined in Minkasu2faCallbackInfo class for reference such as Minkasu2faCallbackInfo.SOURCE_SDK
                          "code": <result/error code>, // 0 => Status SUCCESS, Non-zero values => Other status . Available constants are defined in Minkasu2faCallbackInfo class for reference such as Minkasu2faCallbackInfo.<SCREEN_CLOSE_5500>
                          "message": "<result/error message>"
                        }
                       */
                    Log.e("Minkasu Result", payload != null ? payload.toString() : "no result");
                } else if (infoType == Minkasu2faCallbackInfo.INFO_TYPE_EVENT) {
                        /*
                        {
                          "reference_id": "<minkasu_transaction_ref>",  // UUID string
                          "screen": "<FTU_SETUP_CODE_SCREEN|FTU_AUTH_SCREEN|REPEAT_AUTH_SCREEN>",// Constants are defined in Minkasu2faCallbackInfo class for reference such as Minkasu2faCallbackInfo.FTU_SETUP_CODE_SCREEN
                          "event": "<ENTRY>"// Constants are defined in Minkasu2faCallbackInfo class for reference such as Minkasu2faCallbackInfo.ENTRY_EVENT
                        }
                       */
                    Log.e("Minkasu Event", payload != null ? payload.toString() : "no event");
                }
            }
        });
    }
}
