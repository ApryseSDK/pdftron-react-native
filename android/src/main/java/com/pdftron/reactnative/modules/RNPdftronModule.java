
package com.pdftron.reactnative.modules;

import android.support.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.pdftron.pdf.PDFNet;
import com.pdftron.reactnative.R;

public class RNPdftronModule extends ReactContextBaseJavaModule {

    public RNPdftronModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return "RNPdftron";
    }

    @ReactMethod
    public void initialize(@NonNull String key) {
        try {
            if (!PDFNet.hasBeenInitialized()) {
                PDFNet.initialize(getReactApplicationContext(), R.raw.pdfnet, key);
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}