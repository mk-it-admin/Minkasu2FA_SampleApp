package com.minkasu.sample_app

import android.app.Activity
import android.webkit.WebView
import com.minkasu.android.twofa.exceptions.MissingDataException
import com.minkasu.android.twofa.model.Address
import com.minkasu.android.twofa.model.Config
import com.minkasu.android.twofa.model.CustomerInfo
import com.minkasu.android.twofa.model.OrderInfo
import com.minkasu.android.twofa.model.PartnerInfo
import com.minkasu.android.twofa.sdk.Minkasu2faSDK
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugins.webviewflutter.WebViewFlutterAndroidExternalApi
import org.json.JSONObject

object Minkasu2FAUtils {
    private val CHANNEL = "minkasu2fa_method_channel"
    private var channel: MethodChannel? = null;

    fun setUpMinkasu2FA(engine: FlutterEngine, activity: Activity) {
        this.channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        handleMethodCalls(engine, activity);
    }

    private fun handleMethodCalls(engine: FlutterEngine, activity: Activity) {
        this.channel?.setMethodCallHandler{
                call, result ->
            if (call.method == "initMinkasu2FASDK") {
                val arguments: Map<String, Any>? = call.arguments()
                if (arguments != null) {
                    val webView = fetchWebViewWithId(arguments.get("webViewId") as Int, engine)
                    if (webView != null) {
                        initSDKWithWebView(
                            webView,
                            constructConfigFrom(arguments.get("config") as Map<String?, Any?>),
                            result,
                            activity,
                            this.channel
                        )
                    } else {
                        val resultMap: MutableMap<String, Any?> = HashMap()
                        resultMap["status"] = "failed"
                        resultMap["code"] = "MK2FA_F101"
                        resultMap["message"] = "Error in accessing WebView"
                        result.success(resultMap)
                    }
                } else {
                    val errorMap: MutableMap<String, Any> = HashMap()
                    errorMap["status"] = "failed"
                    errorMap["code"] = "MK2FA_F100"
                    errorMap["message"] = "Invalid arguments"
                    result.success(errorMap)
                }
                result.success(mapOf("status" to "success"))
            } else {
                result.notImplemented()
            }
        }
    }

    private fun fetchWebViewWithId(webViewId: Int, engine: FlutterEngine): WebView? {
        val webView = WebViewFlutterAndroidExternalApi.getWebView(
            engine,
            webViewId.toLong()
        )
        return webView
    }

    private fun initSDKWithWebView(webView: WebView, config: Config?, result: Result, activity: Activity, channel: MethodChannel?) {
        val resultMap: MutableMap<String, Any?> = HashMap()
        resultMap["status"] = "failed"

        if (config != null) {
            try {
                Minkasu2faSDK.init(
                    activity, config, webView
                ) { callbackInfo ->
                    val callBackInfoMap: MutableMap<String, Any> =
                        HashMap()
                    var infoType = -1
                    if (callbackInfo != null) {
                        callBackInfoMap["data"] = jsonToMap(callbackInfo.data)
                        infoType = callbackInfo.infoType
                    }
                    callBackInfoMap["infoType"] = infoType
                    channel?.invokeMethod("receiveMinkasu2FACallbackInfo", callBackInfoMap)
                }
                resultMap.clear()
                resultMap["status"] = "success"
            } catch (e: Exception) {
                resultMap["message"] = e.message
                if (e is MissingDataException) {
                    resultMap["code"] = (e as MissingDataException).errorCode
                } else {
                    resultMap.remove("code")
                }
            }
        } else {
            resultMap["code"] = "MK2FA_F102"
            resultMap["message"] = "Invalid Config Details"
        }

        result.success(resultMap)
    }


    private fun constructConfigFrom(configMap: Map<String?, Any?>): Config {
        val configId = configMap["id"] as String?
        val merchantCustomerId = configMap["merchantCustomerId"] as String?
        val token = configMap["token"] as String?

        val customerMap = configMap["customerInfo"] as Map<String, Any>?
        val customerInfo = constructCustomerInfoFromMap(customerMap)

        val orderInfoMap = configMap["orderInfo"] as Map<String, Any>?
        val orderInfo = constructOrderInfoFromMap(orderInfoMap)

        val partnerInfoMap = configMap["partnerInfo"] as Map<String, Any>?
        val partnerInfo = constructPartnerInfoFromMap(partnerInfoMap)

        val sdkModeValue = configMap["sdkMode"] as Int?
        val sdkMode = constructSDKMode(sdkModeValue)

        val config: Config = Config.getInstance(configId, token, merchantCustomerId, customerInfo)
        config.orderInfo = orderInfo
        config.partnerInfo = partnerInfo
        config.sdkMode = sdkMode

        return config
    }

    private fun constructCustomerInfoFromMap(customerInfoMap: Map<String, Any>?): CustomerInfo {
        val firstName = customerInfoMap!!["firstName"] as String?
        val lastName = customerInfoMap["lastName"] as String?
        val middleName = customerInfoMap["middleName"] as String?
        val email = customerInfoMap["email"] as String?
        val phone = customerInfoMap["phone"] as String?

        val addressMap = customerInfoMap["address"] as Map<String, Any>?

        val customerInfo = CustomerInfo()
        customerInfo.firstName = firstName
        customerInfo.lastName = lastName
        if (!middleName.isNullOrEmpty()) {
            customerInfo.middleName = middleName
        }
        customerInfo.email = email
        customerInfo.phone = phone
        if (addressMap != null) {
            val address: Address = constructAddressFromMap(addressMap)
            customerInfo.address = address
        }

        return customerInfo
    }

    private fun constructAddressFromMap(addressInfoMap: Map<String, Any>): Address {
        val line1 = addressInfoMap["line1"] as String?
        val line2 = addressInfoMap["line2"] as String?
        val line3 = addressInfoMap["line3"] as String?
        val city = addressInfoMap["city"] as String?
        val state = addressInfoMap["state"] as String?
        val country = addressInfoMap["country"] as String?
        val zipCode = addressInfoMap["zipCode"] as String?

        val address: Address = Address()
        if (!line1.isNullOrEmpty()) {
            address.setAddressLine1(line1)
        }
        if (!line2.isNullOrEmpty()) {
            address.setAddressLine2(line2)
        }
        if (!line3.isNullOrEmpty()) {
            address.setAddressLine3(line3)
        }
        if (!city.isNullOrEmpty()) {
            address.setCity(city)
        }
        if (!state.isNullOrEmpty()) {
            address.setState(state)
        }
        if (!country.isNullOrEmpty()) {
            address.setCountry(country)
        }
        if (!zipCode.isNullOrEmpty()) {
            address.setZipCode(zipCode)
        }

        return address
    }

    private fun constructOrderInfoFromMap(orderInfoMap: Map<String, Any>?): OrderInfo {
        val orderId = orderInfoMap!!["orderId"] as String?
        val orderDetails = orderInfoMap["orderDetails"] as String?
        val billingCategory = orderInfoMap["billingCategory"] as String?

        val orderInfo = OrderInfo()
        orderInfo.orderId = orderId

        if (!orderDetails.isNullOrEmpty()) {
            orderInfo.orderDetails = orderDetails
        }

        if (!billingCategory.isNullOrEmpty()) {
            orderInfo.billingCategory = billingCategory
        }

        return orderInfo
    }

    private fun constructPartnerInfoFromMap(partnerInfoMap: Map<String, Any>?): PartnerInfo {
        val merchantId = partnerInfoMap!!["merchantId"] as String?
        val merchantName = partnerInfoMap["merchantName"] as String?
        val transactionId = partnerInfoMap["transactionId"] as String?

        val partnerInfo = PartnerInfo(merchantId, merchantName, transactionId)
        return partnerInfo
    }

    private fun constructSDKMode(sdkModeValue: Int?): String {
        if (sdkModeValue == 0) {
            return Config.PRODUCTION_MODE
        }
        return Config.SANDBOX_MODE
    }

    private fun jsonToMap(jsonObject: JSONObject): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        val keys = jsonObject.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            map[key] = jsonObject.get(key)
        }
        return map
    }
}