package com.pdftron.reactnative.modules;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.pdftron.reactnative.viewmanagers.DocumentViewViewManager;

public class DocumentViewModule extends ReactContextBaseJavaModule {

    private static final String REACT_CLASS = "DocumentViewManager";

    private DocumentViewViewManager mDocumentViewInstance;

    public DocumentViewModule(ReactApplicationContext reactContext, DocumentViewViewManager viewManager) {
        super(reactContext);

        mDocumentViewInstance = viewManager;
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @ReactMethod
    public void importAnnotations(int tag, String xfdf, Promise promise) {
        try {
            mDocumentViewInstance.importAnnotations(tag, xfdf);
            promise.resolve(null);
        } catch (Exception ex) {
            promise.reject(ex);
        }
    }

    @ReactMethod
    public void exportAnnotations(int tag, Promise promise) {
        try {
            String xfdf = mDocumentViewInstance.exportAnnotations(tag);
            promise.resolve(xfdf);
        } catch (Exception ex) {
            promise.reject(ex);
        }
    }
}
