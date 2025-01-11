package com.minkasu.androiddfm;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.webkit.WebView;

import androidx.annotation.NonNull;

import com.minkasu.android.twofa.enums.Minkasu2faOperationType;
import com.minkasu.android.twofa.model.Address;
import com.minkasu.android.twofa.model.Config;
import com.minkasu.android.twofa.model.CustomerInfo;
import com.minkasu.android.twofa.model.OrderInfo;
import com.minkasu.android.twofa.sdk.Minkasu2faCallback;
import com.minkasu.android.twofa.sdk.Minkasu2faCallbackInfo;
import com.minkasu.android.twofa.sdk.Minkasu2faSDK;
import com.minkasu.twofasample.Minkasu2faCallbackInterface;
import com.minkasu.twofasample.Minkasu2faDFMInterface;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class Minkasu2faDFM implements Minkasu2faDFMInterface {

    @Override
    public boolean initializeSDK(@NonNull Activity activity, @NonNull WebView webView, @NonNull JSONObject configJson, Minkasu2faCallbackInterface callback) {
        if (!JSONObject.NULL.equals(configJson)) {
            try {
                CustomerInfo customerInfo = new CustomerInfo();
                JSONObject customerInfoJson = configJson.optJSONObject("customer");
                if (!JSONObject.NULL.equals(customerInfoJson) && customerInfoJson != null) {
                    customerInfo.setFirstName(customerInfoJson.optString("first_name"));
                    customerInfo.setLastName(customerInfoJson.optString("last_name"));
                    customerInfo.setEmail(customerInfoJson.optString("email"));
                    customerInfo.setPhone(customerInfoJson.optString("phone_no"));
                }

                Address address = new Address();
                JSONObject addressJson = customerInfoJson.optJSONObject("address");
                if (!JSONObject.NULL.equals(addressJson) && addressJson != null) {
                    address.setAddressLine1(addressJson.optString("address_line1"));
                    address.setAddressLine2(addressJson.optString("address_line2"));
                    address.setCity(addressJson.optString("city"));
                    address.setState(addressJson.optString("state"));
                    address.setCountry(addressJson.optString("country"));
                    address.setZipCode(addressJson.optString("zip_code"));
                }
                customerInfo.setAddress(address);

                Config config = Config.getInstance(configJson.optString("id"), configJson.optString("token"), configJson.optString("customer_id"), customerInfo);
                if(configJson.optBoolean("sandbox_mode")) {
                    config.setSDKMode(Config.SANDBOX_MODE);
                }
                config.setDisableMinkasu2faUserAgent(configJson.optBoolean("disable_user_agent"));

                OrderInfo orderInfo = new OrderInfo();
                JSONObject orderJson = configJson.optJSONObject("order");
                if(!JSONObject.NULL.equals(orderJson) && orderJson != null){
                    orderInfo.setOrderId(orderJson.optString("order_id"));
                    orderInfo.setBillingCategory(orderJson.optString("billing_category"));
                    orderInfo.setCustomData(orderJson.optString("custom_data"));
                }
                config.setOrderInfo(orderInfo);

                Minkasu2faSDK.init(activity, config, webView, new Minkasu2faCallback() {
                    @Override
                    public void handleInfo(Minkasu2faCallbackInfo callbackInfo) {
                        if(callback!=null){
                            callback.handleInfo(callbackInfo.getInfoType(), callbackInfo.getData());
                        }
                    }
                });
                return true;
            } catch (Exception e) {
                Log.e("Minkasu2faDFM", "Error in initializing the Minkasu2FA. Error:" + e.getMessage());
            }
        }
        return false;
    }

    @Override
    public List<String> getAvailableMinkasu2FAOperation(Context context) {
        List<Minkasu2faOperationType> opTypes =  Minkasu2faSDK.getAvailableMinkasu2faOperations(context);
        List<String> operationTypes = new ArrayList<>();

        for(Minkasu2faOperationType opType: opTypes){
            operationTypes.add(opType.getValue());
        }
        return operationTypes;
    }

    @Override
    public void performMinkasu2FAOperation(Activity activity, String opType, String merchantCustomerId) {
        try {
            Minkasu2faSDK minkasu2faSDKInstance = Minkasu2faSDK.create(activity, Minkasu2faOperationType.fromString(opType), merchantCustomerId);
            minkasu2faSDKInstance.start();
        } catch (Exception e) {
            Log.e("Minkasu2faDFM", "Error in performing the Minkasu2FA Operation. Error:" + e.getMessage());
        }
    }

    @Override
    public boolean isSupportedPlatform() {
        return Minkasu2faSDK.isSupportedPlatform();
    }


}