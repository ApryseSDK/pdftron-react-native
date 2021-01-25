package com.pdftron.reactnative.modules;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.pdftron.pdf.PDFDoc;
import com.pdftron.pdf.PDFNet;
import com.pdftron.pdf.model.StandardStampOption;
import com.pdftron.pdf.utils.AppUtils;
import com.pdftron.pdf.utils.Utils;
import com.pdftron.pdf.utils.ViewerUtils;
import com.pdftron.sdf.SDFDoc;

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

    @ReactMethod
    public void getSystemFontList(final Promise promise) {
        String fontList = null;
        Exception exception = null;
        try {
            fontList = PDFNet.getSystemFontList();
        } catch (Exception e) {
            exception = e;
        }

        String finalFontList = fontList;
        Exception finalException = exception;
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {

            @Override
            public void run() {
                if (finalFontList != null) {
                    promise.resolve(finalFontList);
                } else {
                    promise.reject(finalException);
                }
            }
        });
    }

    @ReactMethod
    public void clearRubberStampCache(final Promise promise) {
        StandardStampOption.clearCache(getReactApplicationContext());
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                promise.resolve(null);
            }
        });
    }

    @ReactMethod
    public void encryptDocument(final String filePath, final String password, final String currentPassword, final Promise promise) {
        try {
            String oldPassword = currentPassword;
            if (Utils.isNullOrEmpty(currentPassword)) {
                oldPassword = "";
            }
            PDFDoc pdfDoc = new PDFDoc(filePath);
            if (pdfDoc.initStdSecurityHandler(oldPassword)) {
                ViewerUtils.passwordDoc(pdfDoc, password);
                pdfDoc.lock();
                pdfDoc.save(filePath, SDFDoc.SaveMode.REMOVE_UNUSED, null);
                pdfDoc.unlock();
                promise.resolve(null);
            } else {
                promise.reject("password", "Current password is incorrect.");
            }
        } catch (Exception ex) {
            promise.reject(ex);
        }
    }

    @ReactMethod
    public void getVersion(final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    promise.resolve(Double.toString(PDFNet.getVersion()));
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void getPlatformVersion(final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    promise.resolve("Android " + android.os.Build.VERSION.RELEASE);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }
}