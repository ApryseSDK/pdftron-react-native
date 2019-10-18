package com.pdftron.reactnative.modules;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
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
    public void importAnnotations(final int tag, final String xfdf, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    mDocumentViewInstance.importAnnotations(tag, xfdf);
                    promise.resolve(null);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void exportAnnotations(final int tag, final ReadableMap options, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    String xfdf = mDocumentViewInstance.exportAnnotations(tag, options);
                    promise.resolve(xfdf);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void flattenAnnotations(final int tag, final boolean formsOnly, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    mDocumentViewInstance.flattenAnnotations(tag, formsOnly);
                    promise.resolve(null);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void setToolMode(final int tag, final String item) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    mDocumentViewInstance.setToolMode(tag, item);
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
    }

    @ReactMethod
    public void getPageCount(final int tag, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    int count = mDocumentViewInstance.getPageCount(tag);
                    promise.resolve(count);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }
}
