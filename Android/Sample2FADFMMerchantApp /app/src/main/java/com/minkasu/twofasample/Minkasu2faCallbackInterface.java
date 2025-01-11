package com.minkasu.twofasample;

import org.json.JSONObject;

public interface Minkasu2faCallbackInterface {
    void handleInfo(int infoType, JSONObject payload);
}
