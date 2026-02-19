package com.minkasu.sample_app_objc_java;

import android.app.Activity;
import android.webkit.WebView;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.webviewflutter.WebViewFlutterAndroidExternalApi;

import io.flutter.plugin.common.MethodChannel.Result;

import com.minkasu.android.twofa.exceptions.MissingDataException;
import com.minkasu.android.twofa.model.Address;
import com.minkasu.android.twofa.model.Config;
import com.minkasu.android.twofa.model.CustomerInfo;
import com.minkasu.android.twofa.model.OrderInfo;
import com.minkasu.android.twofa.model.PartnerInfo;
import com.minkasu.android.twofa.sdk.Minkasu2faCallback;
import com.minkasu.android.twofa.sdk.Minkasu2faCallbackInfo;
import com.minkasu.android.twofa.sdk.Minkasu2faSDK;

import org.json.JSONException;
import org.json.JSONObject;

public class Minkasu2FAUtils {
    private static final String channelName = "minkasu2fa_method_channel";
    private FlutterEngine flutterEngine;
    private Activity activity;
    private MethodChannel channel;

    private static final  Minkasu2FAUtils instance = new Minkasu2FAUtils();

    private Minkasu2FAUtils() {}

    public static Minkasu2FAUtils getInstance() {
        return instance;
    }

    public void setUpMinkasu2FAUtils(FlutterEngine flutterEngine, Activity activity) {
        this.activity = activity;
        this.flutterEngine = flutterEngine;
        this.channel = new MethodChannel(this.flutterEngine.getDartExecutor().getBinaryMessenger(), channelName);
        handleMethodCalls();
    }

    private void handleMethodCalls() {
        this.channel.setMethodCallHandler(
            (call, result) -> {
                switch (call.method) {
                    case "initMinkasu2FASDK": {
                        Map<String, Object> arguments = call.arguments();
                        if (arguments != null) {
                            Integer webViewId = (Integer) arguments.get("webViewId");
                            Map<String, Object> configMap = (Map<String, Object>) arguments.get("config");
                            WebView webView = fetchWebViewWithId(webViewId, this.flutterEngine);
                            if (webView != null) {
                                initSDKWithWebView(webView, constructConfigFrom(configMap), result, this.channel);
                            } else {
                                Map<String, Object> resultMap = new HashMap<>();
                                resultMap.put("status", "failed");
                                resultMap.put("code", "MK2FA_F101");
                                resultMap.put("message", "Error in accessing WebView");
                                result.success(resultMap);
                            }
                        } else {
                            Map<String, Object> errorMap = new HashMap<>();
                            errorMap.put("status", "failed");
                            errorMap.put("code", "MK2FA_F100");
                            errorMap.put("message", "Invalid arguments");
                            result.success(errorMap);
                        }
                        break;
                    }
                    default:
                        result.notImplemented();
                        break;
                }
            }
        );
    }

    private WebView fetchWebViewWithId(Integer webViewId, FlutterEngine flutterEngine) {
        return WebViewFlutterAndroidExternalApi.getWebView(
                flutterEngine,
                webViewId);
    }
    private void initSDKWithWebView(WebView webView, Config config, Result result, MethodChannel channel) {
        Map<String, Object> resultMap = new HashMap<>();
        resultMap.put("status", "failed");

        if (config != null) {
            try {
                Minkasu2faSDK.init(this.activity, config, webView, new Minkasu2faCallback() {
                    @Override
                    public void handleInfo(Minkasu2faCallbackInfo callbackInfo) {
                        Map<String, Object> callBackInfoMap = new HashMap<>();
                        int infoType = -1;
                        if (callbackInfo != null) {
                            callBackInfoMap.put("data", convertJsonToMap(callbackInfo.getData()));
                            infoType = callbackInfo.getInfoType();
                        }
                        callBackInfoMap.put("infoType", infoType);
                        channel.invokeMethod("receiveMinkasu2FACallbackInfo", callBackInfoMap);
                    }
                });
                resultMap.clear();
                resultMap.put("status", "success");
            } catch (Exception e) {
                resultMap.put("message", e.getMessage());
                if (e instanceof MissingDataException) {
                    resultMap.put("code", ((MissingDataException) e).getErrorCode());
                } else {
                    resultMap.remove("code");
                }
            }
        } else {
            resultMap.put("code", "MK2FA_F102");
            resultMap.put("message", "Invalid Config Details");
        }
        result.success(resultMap);
    }

    public Config constructConfigFrom(Map<String, Object> configMap) {
        if (configMap != null && !configMap.isEmpty()) {
            String configId = (String) configMap.get("id");
            String merchantCustomerId = (String) configMap.get("merchantCustomerId");
            String token = (String) configMap.get("token");

            Map<String, Object> customerInfoMap = (Map<String, Object>) configMap.get("customerInfo");
            CustomerInfo customerInfo = new CustomerInfo();
            if (customerInfoMap != null && !customerInfoMap.isEmpty()) {
                customerInfo.setFirstName((String) customerInfoMap.get("firstName"));
                customerInfo.setLastName((String) customerInfoMap.get("lastName"));
                customerInfo.setMiddleName((String) customerInfoMap.get("middleName"));
                customerInfo.setEmail((String) customerInfoMap.get("email"));
                customerInfo.setPhone((String) customerInfoMap.get("phone"));

                Map<String, Object> addressInfoMap = (Map<String, Object>) customerInfoMap.get("address");
                if (addressInfoMap != null && !addressInfoMap.isEmpty()) {
                    Address address = new Address();
                    address.setAddressLine1((String) addressInfoMap.get("line1"));
                    address.setAddressLine2((String) addressInfoMap.get("line2"));
                    address.setAddressLine3((String) addressInfoMap.get("line3"));
                    address.setCity((String) addressInfoMap.get("city"));
                    address.setState((String) addressInfoMap.get("state"));
                    address.setCountry((String) addressInfoMap.get("country"));
                    address.setZipCode((String) addressInfoMap.get("zipCode"));

                    customerInfo.setAddress(address);
                }
            }

            Map<String, Object> orderInfoMap = (Map<String, Object>) configMap.get("orderInfo");
            OrderInfo orderInfo = new OrderInfo();
            if (orderInfoMap != null && !orderInfoMap.isEmpty()) {
                orderInfo = new OrderInfo();
                orderInfo.setOrderId((String) orderInfoMap.get("orderId"));
                orderInfo.setBillingCategory((String) orderInfoMap.get("billingCategory"));
                orderInfo.setOrderDetails((String) orderInfoMap.get("orderDetails"));
            }

            Map<String, Object> partnerInfoMap = (Map<String, Object>) configMap.get("partnerInfo");
            String partnerMerchantId = (String) partnerInfoMap.get("merchantId");
            String partnerMerchantName = (String) partnerInfoMap.get("merchantName");
            String partnerTransactionId = (String) partnerInfoMap.get("transactionId");
            PartnerInfo partnerInfo = new PartnerInfo(partnerMerchantId, partnerMerchantName, partnerTransactionId);


            String sdkMode = Config.PRODUCTION_MODE;
            Integer sdkModeValue = (Integer) configMap.get("sdkMode");
            if (sdkModeValue != null && sdkModeValue == 1) {
                sdkMode = Config.SANDBOX_MODE;
            }
            Config config;
            config = Config.getInstance(configId, token, merchantCustomerId, customerInfo);
            config.setOrderInfo(orderInfo);
            config.setPartnerInfo(partnerInfo);
            config.setSDKMode(sdkMode);
            return config;
        }
        return null;
    }
    private Map<String, Object> convertJsonToMap(JSONObject json) {
        Map<String, Object> map = new HashMap<>();
        Iterator<String> keys = json.keys();
        while (keys.hasNext()) {
            String key = keys.next();
            try {
                Object value = json.get(key);
                map.put(key, value);
            } catch (JSONException ignored) {
            }
        }
        return map;
    }
}
