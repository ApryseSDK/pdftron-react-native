package com.pdftron.reactnative.viewmanagers;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.util.Log;
import android.util.SparseArray;
import android.view.View;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.pdftron.common.PDFNetException;
import com.pdftron.reactnative.views.DocumentView;

public class DocumentViewViewManager extends ViewGroupManager<DocumentView> {
    private static final String REACT_CLASS = "RCTDocumentView";

    private SparseArray<DocumentView> mDocumentViews = new SparseArray<>();

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    private View.OnAttachStateChangeListener mOnAttachStateChangeListener = new View.OnAttachStateChangeListener() {
        @Override
        public void onViewAttachedToWindow(View v) {
            DocumentView documentView = (DocumentView) v;
            Log.d(getName(), "add to map: " + v.getId());
            mDocumentViews.put(v.getId(), documentView);
        }

        @Override
        public void onViewDetachedFromWindow(View v) {
            DocumentView documentView = (DocumentView) v;
            Log.d(getName(), "remove from map: " + v.getId());
            mDocumentViews.remove(v.getId());
            documentView.removeOnAttachStateChangeListener(mOnAttachStateChangeListener);
        }
    };

    @Override
    protected DocumentView createViewInstance(ThemedReactContext reactContext) {
        DocumentView documentView = new DocumentView(reactContext);
        documentView.setup(reactContext);
        documentView.addOnAttachStateChangeListener(mOnAttachStateChangeListener);

        return documentView;
    }

    public void forceDocSave(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.doDocSave();
        } else {
            throw new PDFNetException("", 0L, getName(), "importAnnotations", "Unable to find DocumentView.");
        }
    }

    @ReactProp(name = "document")
    public void setDocument(DocumentView documentView, @NonNull String filepath) {
        documentView.setDocument(filepath);
    }

    @ReactProp(name = "password")
    public void setPassword(DocumentView documentView, @Nullable String password) {
        documentView.setPassword(password);
    }

    @ReactProp(name = "leadingNavButtonIcon")
    public void setNavButtonIcon(DocumentView documentView, @NonNull String resName) {
        documentView.setNavResName(resName);
    }

    @ReactProp(name = "showLeadingNavButton")
    public void setShowNavButton(DocumentView documentView, boolean show) {
        documentView.setShowNavIcon(show);
    }

    @ReactProp(name = "disabledElements")
    public void setDisabledElements(DocumentView documentView, @NonNull ReadableArray array) {
        documentView.setDisabledElements(array);
    }

    @ReactProp(name = "disabledTools")
    public void setDisabledTools(DocumentView documentView, @NonNull ReadableArray array) {
        documentView.setDisabledTools(array);
    }

    @ReactProp(name = "customHeaders")
    public void setCustomHeaders(DocumentView documentView, @Nullable ReadableMap map) {
        documentView.setCustomHeaders(map);
    }

    @ReactProp(name = "initialPageNumber")
    public void setInitialPageNumber(DocumentView documentView, int pageNum) {
        documentView.setInitialPageNumber(pageNum);
    }

    @ReactProp(name = "pageNumber")
    public void setPageNumber(DocumentView documentView, int pageNum) {
        documentView.setPageNumber(pageNum);
    }

    @ReactProp(name = "topToolbarEnabled")
    public void setTopToolbarEnabled(DocumentView documentView, boolean topToolbarEnabled) {
        documentView.setTopToolbarEnabled(topToolbarEnabled);
    }

    @ReactProp(name = "bottomToolbarEnabled")
    public void setBottomToolbarEnabled(DocumentView documentView, boolean bottomToolbarEnabled) {
        documentView.setBottomToolbarEnabled(bottomToolbarEnabled);
    }

    @ReactProp(name = "pageIndicatorEnabled")
    public void setPageIndicatorEnabled(DocumentView documentView, boolean pageIndicatorEnabled) {
        documentView.setPageIndicatorEnabled(pageIndicatorEnabled);
    }

    public void importAnnotations(int tag, String xfdf) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.importAnnotations(xfdf);
        } else {
            throw new PDFNetException("", 0L, getName(), "importAnnotations", "Unable to find DocumentView.");
        }
    }

    public String exportAnnotations(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.exportAnnotations();
        } else {
            throw new PDFNetException("", 0L, getName(), "exportAnnotations", "Unable to find DocumentView.");
        }
    }

    public void setToolMode(int tag, String item) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setToolMode(item);
        } else {
            throw new PDFNetException("", 0L, getName(), "setToolMode", "Unable to find DocumentView.");
        }
    }

    public int getPageCount(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getPageCount();
        } else {
            throw new PDFNetException("", 0L, getName(), "getPageCount", "Unable to find DocumentView.");
        }
    }

    @Override
    public boolean needsCustomLayoutForChildren() {
        return true;
    }
}
