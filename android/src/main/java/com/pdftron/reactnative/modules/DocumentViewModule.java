package com.pdftron.reactnative.modules;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.pdftron.common.PDFNetException;
import com.pdftron.reactnative.viewmanagers.DocumentViewViewManager;

import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class DocumentViewModule extends ReactContextBaseJavaModule {
    private static final String REACT_CLASS = "DocumentViewManager";

    private DocumentViewViewManager mDocumentViewInstance;

    public DocumentViewModule(ReactApplicationContext reactContext, DocumentViewViewManager viewManager) {
        super(reactContext);
        mDocumentViewInstance = viewManager;
    }

    @Override
    @NonNull
    public String getName() {
        return REACT_CLASS;
    }

    private static PDFNetException syncEx = null;
    private static boolean needWait = false;

    @ReactMethod
    public void forceDocumentSave(final int tag) throws PDFNetException {
        needWait = false;
        syncEx = null;
        final Lock lock = new ReentrantLock();
        synchronized (lock) {
            getReactApplicationContext().runOnUiQueueThread(new Runnable() {
                @Override
                public void run() {
                    if (lock.tryLock()) {
                        needWait = true;
                        try {
                            mDocumentViewInstance.forceDocSave(tag);
                        } catch (PDFNetException e) {
                            syncEx = e;
                        } finally {
                            lock.unlock();
                            needWait = false;
                        }
                    }
                    else {
                        syncEx = new PDFNetException("", 0L, getName(), "forceDocumentSave()", "Unable to acquire lock during save");
                    }
                }
            });
        }

        try {
            while (needWait) {
                Thread.sleep(1);
            }
        }
        catch (InterruptedException ignore) { }

        if (syncEx != null) {
            throw syncEx;
        }
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
                    mDocumentViewInstance.saveDocument(tag);
                    promise.resolve(null);
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
