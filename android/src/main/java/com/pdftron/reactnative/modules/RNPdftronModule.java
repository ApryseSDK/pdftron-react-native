
package com.pdftron.reactnative.modules;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.pdftron.pdf.PDFNet;
import com.pdftron.pdf.utils.AppUtils;

import androidx.annotation.NonNull;

public class RNPdftronModule extends ReactContextBaseJavaModule {

    private static final String REACT_CLASS = "RNPdftron";

    public RNPdftronModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @ReactMethod
    public void initialize(@NonNull String key) {
        try {
            AppUtils.initializePDFNetApplication(getReactApplicationContext(), key);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    @ReactMethod
    public void enableJavaScript(boolean enabled) {
        try {
            PDFNet.enableJavaScript(enabled);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}