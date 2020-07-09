package com.pdftron.reactnative.modules;

import android.app.Activity;
import android.content.Intent;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.pdftron.reactnative.viewmanagers.DocumentViewViewManager;

public class DocumentViewModule extends ReactContextBaseJavaModule implements ActivityEventListener {

    private static final String REACT_CLASS = "DocumentViewManager";

    private DocumentViewViewManager mDocumentViewInstance;

    public DocumentViewModule(ReactApplicationContext reactContext, DocumentViewViewManager viewManager) {
        super(reactContext);
        reactContext.addActivityEventListener(this);

        mDocumentViewInstance = viewManager;
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @ReactMethod
    public void importAnnotationCommand(final int tag, final String xfdfCommand, final boolean initialLoad, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    mDocumentViewInstance.importAnnotationCommand(tag, xfdfCommand, initialLoad);
                    promise.resolve(null);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
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
    public void saveDocument(final int tag, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    String path = mDocumentViewInstance.saveDocument(tag);
                    promise.resolve(path);
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
    public void commitTool(final int tag, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    boolean result = mDocumentViewInstance.commitTool(tag);
                    promise.resolve(result);
                } catch (Exception e) {
                    promise.reject(e);
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

    @ReactMethod
    public void setFlagForFields(final int tag, final ReadableArray fields, final Integer flag, final Boolean value, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    mDocumentViewInstance.setFlagForFields(tag, fields, flag, value);
                    promise.resolve(null);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void setValueForFields(final int tag, final ReadableMap map, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    mDocumentViewInstance.setValueForFields(tag, map);
                    promise.resolve(null);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void deleteAnnotations(final int tag, final ReadableArray annots, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    mDocumentViewInstance.deleteAnnotations(tag, annots);
                    promise.resolve(null);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void canExitViewer(final int tag, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    boolean result = mDocumentViewInstance.canExitViewer(tag);
                    promise.resolve(result);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        mDocumentViewInstance.onActivityResult(requestCode, resultCode, data);
    }

    @Override
    public void onNewIntent(Intent intent) {

    }
}
