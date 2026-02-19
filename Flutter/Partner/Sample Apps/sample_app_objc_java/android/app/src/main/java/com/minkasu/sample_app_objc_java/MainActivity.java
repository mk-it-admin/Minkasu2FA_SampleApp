package com.minkasu.sample_app_objc_java;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {
    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        Minkasu2FAUtils.getInstance().setUpMinkasu2FAUtils(flutterEngine, this);
    }
}
