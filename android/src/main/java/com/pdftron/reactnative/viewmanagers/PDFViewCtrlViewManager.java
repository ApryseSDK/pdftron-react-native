package com.pdftron.reactnative.viewmanagers;

import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.pdftron.reactnative.views.PDFViewCtrlView;

import javax.annotation.Nonnull;

public class PDFViewCtrlViewManager extends ViewGroupManager<PDFViewCtrlView> {
    private static final String REACT_CLASS = "RCTPDFViewCtrl";

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @Override
    protected PDFViewCtrlView createViewInstance(ThemedReactContext reactContext) {
        PDFViewCtrlView pdfViewCtrlView = new PDFViewCtrlView(reactContext, null);
        pdfViewCtrlView.setup(reactContext);

        return pdfViewCtrlView;
    }

    @ReactProp(name = "document")
    public void setDocument(PDFViewCtrlView ctrl, @Nonnull String fileUriStr) {
        ctrl.setDocument(fileUriStr);
    }

    @Override
    public boolean needsCustomLayoutForChildren() {
        return true;
    }
}
