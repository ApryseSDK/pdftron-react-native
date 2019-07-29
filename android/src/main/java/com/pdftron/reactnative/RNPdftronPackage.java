
package com.pdftron.reactnative;

import android.content.Context;
import android.util.Log;

import com.facebook.react.ReactPackage;
import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.uimanager.ViewManager;
import com.pdftron.pdf.PDFNet;
import com.pdftron.pdf.utils.AppUtils;
import com.pdftron.reactnative.modules.DocumentViewModule;
import com.pdftron.reactnative.modules.RNPdftronModule;
import com.pdftron.reactnative.viewmanagers.DocumentViewViewManager;
import com.pdftron.reactnative.viewmanagers.PDFViewCtrlViewManager;

import java.util.Arrays;
import java.util.List;

public class RNPdftronPackage implements ReactPackage {

    private DocumentViewViewManager mDocumentViewViewManager;

    public void initialize(Context context) {
        if (!PDFNet.hasBeenInitialized()) {
            try {
                AppUtils.initializePDFNetApplication(context);
                Log.d("PDFTron", "version: " + PDFNet.getVersion());
            } catch (Exception ex) {
                Log.e("PDFTron", ex.getMessage());
                ex.printStackTrace();
            }
        }
    }

    @Override
    public List<NativeModule> createNativeModules(ReactApplicationContext reactContext) {
        initialize(reactContext);
        if (null == mDocumentViewViewManager) {
            mDocumentViewViewManager = new DocumentViewViewManager();
        }
        return Arrays.<NativeModule>asList(
                new RNPdftronModule(reactContext),
                new DocumentViewModule(reactContext, mDocumentViewViewManager)
        );
    }

    @Override
    public List<ViewManager> createViewManagers(ReactApplicationContext reactContext) {
        initialize(reactContext);
        if (null == mDocumentViewViewManager) {
            mDocumentViewViewManager = new DocumentViewViewManager();
        }
        return Arrays.<ViewManager>asList(
                new PDFViewCtrlViewManager(),
                mDocumentViewViewManager
        );
    }
}