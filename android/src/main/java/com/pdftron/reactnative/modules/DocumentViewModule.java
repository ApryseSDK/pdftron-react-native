package com.pdftron.reactnative.modules;

import android.app.Activity;
import android.content.Intent;

import androidx.appcompat.app.AppCompatActivity;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.pdftron.pdf.dialog.digitalsignature.DigitalSignatureDialogFragment;
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
    public void importBookmarkJson(final int tag, final String bookmarkJson, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    mDocumentViewInstance.importBookmarkJson(tag, bookmarkJson);
                    promise.resolve(null);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
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
    public void getDocumentPath(final int tag, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    String path = mDocumentViewInstance.getDocumentPath(tag);
                    promise.resolve(path);
                } catch (Exception e) {
                    promise.reject(e);
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
    public void setValuesForFields(final int tag, final ReadableMap map, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    mDocumentViewInstance.setValuesForFields(tag, map);
                    promise.resolve(null);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void getField(final int tag, final String fieldName, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    WritableMap field = mDocumentViewInstance.getField(tag, fieldName);
                    promise.resolve(field);
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
    public void getAnnotationAtPoint(final int tag, final int x, final int y, final double distanceThreshold, final double minimumLineWeight, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    ReadableMap annotation = mDocumentViewInstance.getAnnotationAtPoint(tag, x, y, distanceThreshold, minimumLineWeight);
                    promise.resolve(annotation);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void getAnnotationsAtLine(final int tag, final int x1, final int y1, final int x2, final int y2, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    ReadableArray annotations = mDocumentViewInstance.getAnnotationsAtLine(tag, x1, y1, x2, y2);
                    promise.resolve(annotations);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void getAnnotationsOnPage(final int tag, final int pageNumber, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    ReadableArray annotations = mDocumentViewInstance.getAnnotationsOnPage(tag, pageNumber);
                    promise.resolve(annotations);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void handleBackButton(final int tag, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    boolean result = mDocumentViewInstance.handleBackButton(tag);
                    promise.resolve(result);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void closeAllTabs(final int tag, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    mDocumentViewInstance.closeAllTabs(tag);
                    promise.resolve(null);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void setFlagsForAnnotations(final int tag, final ReadableArray annotationFlaglist, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    mDocumentViewInstance.setFlagsForAnnotations(tag, annotationFlaglist);
                    promise.resolve(null);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void selectAnnotation(final int tag, final String annotId, final int pageNumber, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    mDocumentViewInstance.selectAnnotation(tag, annotId, pageNumber);
                    promise.resolve(null);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void setPropertiesForAnnotation(final int tag, final String annotId, final int pageNumber, final ReadableMap propertyMap, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    mDocumentViewInstance.setPropertiesForAnnotation(tag, annotId, pageNumber, propertyMap);
                    promise.resolve(null);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void getPageCropBox(final int tag, final int pageNumber, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    WritableMap box = mDocumentViewInstance.getPageCropBox(tag, pageNumber);
                    promise.resolve(box);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void setCurrentPage(final int tag, final int pageNumber, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    boolean setResult = mDocumentViewInstance.setCurrentPage(tag, pageNumber);
                    promise.resolve(setResult);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void getZoom(final int tag, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    double zoom = mDocumentViewInstance.getZoom(tag);
                    promise.resolve(zoom);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void getScrollPos(final int tag, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    WritableMap scrollPos = mDocumentViewInstance.getScrollPos(tag);
                    promise.resolve(scrollPos);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void getCanvasSize(final int tag, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    WritableMap canvasSize = mDocumentViewInstance.getCanvasSize(tag);
                    promise.resolve(canvasSize);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        mDocumentViewInstance.onActivityResult(requestCode, resultCode, data);

        // Handle onActivity result for digital signature using view model, which will
        // be consumed by DigitalSignatureDialogFragment
        if (activity instanceof AppCompatActivity) {
            if (DigitalSignatureDialogFragment.isDigitalSignatureIntent(requestCode)) {
                DigitalSignatureDialogFragment.getViewModel((AppCompatActivity) activity).setActivityResultIntent(requestCode, resultCode, data);
            }
        }
    }

    @Override
    public void onNewIntent(Intent intent) {

    }
}
