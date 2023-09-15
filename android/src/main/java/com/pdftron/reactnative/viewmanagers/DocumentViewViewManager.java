package com.pdftron.reactnative.viewmanagers;

import android.content.Intent;
import android.util.Log;
import android.util.SparseArray;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.ViewGroupManager;
import com.facebook.react.uimanager.annotations.ReactProp;
import com.pdftron.common.PDFNetException;
import com.pdftron.pdf.dialog.signature.SignatureDialogFragment;
import com.pdftron.pdf.utils.PdfViewCtrlSettingsManager;
import com.pdftron.pdf.utils.ShortcutHelper;
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
            Log.d(getName(), "remove from map: " + v.getId());
            mDocumentViews.remove(v.getId());
        }
    };

    @Override
    protected DocumentView createViewInstance(ThemedReactContext reactContext) {
        DocumentView documentView = new DocumentView(reactContext);
        documentView.setup(reactContext);
        documentView.addOnAttachStateChangeListener(mOnAttachStateChangeListener);

        return documentView;
    }

    @ReactProp(name = "document")
    public void setDocument(DocumentView documentView, @NonNull String filepath) {
        documentView.setDocument(filepath);
    }

    @ReactProp(name = "source")
    public void setSource(DocumentView documentView, @NonNull String filepath) {
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

    @ReactProp(name = "enableAntialiasing")
    public void setAntiAliasing(DocumentView documentView, boolean enableAntialiasing) throws PDFNetException {
        documentView.setAntiAliasing(enableAntialiasing);
    }

    @ReactProp(name = "showLeadingNavButton")
    public void setShowNavButton(DocumentView documentView, boolean show) {
        documentView.setShowNavIcon(show);
    }

    @ReactProp(name = "overflowMenuButtonIcon")
    public void setOverflowMenuButtonIcon(DocumentView documentView, @NonNull String resName) {
        documentView.setOverflowResName(resName);
    }

    @ReactProp(name = "disabledElements")
    public void setDisabledElements(DocumentView documentView, @NonNull ReadableArray array) {
        documentView.setDisabledElements(array);
    }

    @ReactProp(name = "disabledTools")
    public void setDisabledTools(DocumentView documentView, @NonNull ReadableArray array) {
        documentView.setDisabledTools(array);
    }

    @ReactProp(name = "rememberLastUsedTool")
    public void setRememberLastUsedTool(DocumentView documentView, boolean rememberLastUsedTool) {
        documentView.setRememberLastUsedTool(rememberLastUsedTool);
    }

    @ReactProp(name = "customHeaders")
    public void setCustomHeaders(DocumentView documentView, @Nullable ReadableMap map) {
        documentView.setCustomHeaders(map);
    }

    @ReactProp(name = "documentExtension")
    public void setDocumentExtension(DocumentView documentView, String documentExtension) {
        documentView.setDocumentExtension(documentExtension);
    }

    @ReactProp(name = "initialPageNumber")
    public void setInitialPageNumber(DocumentView documentView, int pageNum) {
        documentView.setInitialPageNumber(pageNum);
    }

    @ReactProp(name = "page")
    public void setPage(DocumentView documentView, int pageNum) {
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

    @ReactProp(name = "bottomToolbar")
    public void bottomToolbar(DocumentView documentView, @NonNull ReadableArray bottomToolbarItems) {
        documentView.bottomToolbar(bottomToolbarItems);
    }

    @ReactProp(name = "hideToolbarsOnTap")
    public void setHideToolbarsOnTap(DocumentView documentView, boolean hideToolbarsOnTap) {
        documentView.setHideToolbarsOnTap(hideToolbarsOnTap);
    }

    @ReactProp(name = "tabletLayoutEnabled")
    public void setTabletLayoutEnabled(DocumentView documentView, boolean tabletLayoutEnabled) {
        documentView.setTabletLayoutEnabled(tabletLayoutEnabled);
    }

    @ReactProp(name = "documentSliderEnabled")
    public void setDocumentSliderEnabled(DocumentView documentView, boolean documentSliderEnabled) {
        documentView.setDocumentSliderEnabled(documentSliderEnabled);
    }

    @ReactProp(name = "downloadDialogEnabled")
    public void setDownloadDialogEnabled(DocumentView documentView, boolean downloadDialogEnabled) {
        documentView.setDownloadDialogEnabled(downloadDialogEnabled);
    }

    @ReactProp(name = "pageIndicatorEnabled")
    public void setPageIndicatorEnabled(DocumentView documentView, boolean pageIndicatorEnabled) {
        documentView.setPageIndicatorEnabled(pageIndicatorEnabled);
    }

    @ReactProp(name = "readOnly")
    public void setReadOnly(DocumentView documentView, boolean readOnly) {
        documentView.setReadOnly(readOnly);
    }

    @ReactProp(name = "fitMode")
    public void setFitMode(DocumentView documentView, String fitMode) {
        documentView.setFitMode(fitMode);
    }

    @ReactProp(name = "fitPolicy")
    public void setFitPolicy(DocumentView documentView, int fitPolicy) {
        documentView.setFitPolicy(fitPolicy);
    }

    @ReactProp(name = "maintainZoomEnabled")
    public void setMaintainZoomEnabled(DocumentView documentView, boolean maintainZoomEnabled) {
        documentView.setMaintainZoomEnabled(maintainZoomEnabled);
    }

    @ReactProp(name = "layoutMode")
    public void setLayoutMode(DocumentView documentView, String layoutMode) {
        documentView.setLayoutMode(layoutMode);
    }

    @ReactProp(name = "padStatusBar")
    public void setPadStatusBar(DocumentView documentView, boolean padStatusBar) {
        documentView.setPadStatusBar(padStatusBar);
    }

    @ReactProp(name = "continuousAnnotationEditing")
    public void setContinuousAnnotationEditing(DocumentView documentView, boolean contEditing) {
        documentView.setContinuousAnnotationEditing(contEditing);
    }

    @ReactProp(name = "annotationAuthor")
    public void setAnnotationAuthor(DocumentView documentView, String author) {
        documentView.setAnnotationAuthor(author);
    }

    @ReactProp(name = "showSavedSignatures")
    public void setShowSavedSignatures(DocumentView documentView, boolean show) {
        documentView.setShowSavedSignatures(show);
    }

    @ReactProp(name = "isBase64String")
    public void setIsBase64String(DocumentView documentView, boolean isBase64) {
        documentView.setIsBase64String(isBase64);
    }

    @ReactProp(name = "base64FileExtension")
    public void setBase64FileExtension(DocumentView documentView, String base64Extension) {
        documentView.setBase64FileExtension(base64Extension);
    }

    @ReactProp(name = "autoSaveEnabled")
    public void setAutoSaveEnabled(DocumentView documentView, boolean autoSaveEnabled) {
        documentView.setAutoSaveEnabled(autoSaveEnabled);
    }

    @ReactProp(name = "useStylusAsPen")
    public void setUseStylusAsPen(DocumentView documentView, boolean useStylusAsPen) {
        documentView.setUseStylusAsPen(useStylusAsPen);
    }

    @ReactProp(name = "collabEnabled")
    public void setCollabEnabled(DocumentView documentView, boolean collabEnabled) {
        documentView.setCollabEnabled(collabEnabled);
    }

    @ReactProp(name = "currentUser")
    public void setCurrentUser(DocumentView documentView, String currentUser) {
        documentView.setCurrentUser(currentUser);
    }

    @ReactProp(name = "currentUserName")
    public void setCurrentUserName(DocumentView documentView, String currentUserName) {
        documentView.setCurrentUserName(currentUserName);
    }

    @ReactProp(name = "annotationManagerEditMode")
    public void annotationManagerEditMode(DocumentView documentView, String annotationManagerEditMode) {
        documentView.setAnnotationManagerEditMode(annotationManagerEditMode);
    }

    @ReactProp(name = "annotationManagerUndoMode")
    public void annotationManagerUndoMode(DocumentView documentView, String annotationManagerUndoMode) {
        documentView.setAnnotationManagerUndoMode(annotationManagerUndoMode);
    }

    @ReactProp(name = "annotationMenuItems")
    public void setAnnotationMenuItems(DocumentView documentView, @NonNull ReadableArray items) {
        documentView.setAnnotationMenuItems(items);
    }

    @ReactProp(name = "longPressMenuItems")
    public void setLongPressMenuItems(DocumentView documentView, @NonNull ReadableArray items) {
        documentView.setLongPressMenuItems(items);
    }

    @ReactProp(name = "longPressMenuEnabled")
    public void setLongPressMenuEnabled(DocumentView documentView, boolean longPressMenuEnabled) {
        documentView.setLongPressMenuEnabled(longPressMenuEnabled);
    }

    @ReactProp(name = "defaultEraserType")
    public void setDefaultEraserType(DocumentView documentView, String eraserType) {
        documentView.setDefaultEraserType(eraserType);
    }

    @ReactProp(name = "hideAnnotationMenu")
    public void setHideAnnotationMenu(DocumentView documentView, @NonNull ReadableArray tools) {
        documentView.setHideAnnotationMenu(tools);
    }

    @ReactProp(name = "pageChangeOnTap")
    public void setPageChangeOnTap(DocumentView documentView, boolean pageChangeOnTap) {
        documentView.setPageChangeOnTap(pageChangeOnTap);
    }

    @ReactProp(name = "multiTabEnabled")
    public void setMultiTabEnabled(DocumentView documentView, boolean multiTab) {
        documentView.setMultiTabEnabled(multiTab);
    }

    @ReactProp(name = "tabTitle")
    public void setTabTitle(DocumentView documentView, String tabTitle) {
        documentView.setTabTitle(tabTitle);
    }

    @ReactProp(name = "maxTabCount")
    public void setMaxTabCount(DocumentView documentView, int maxTabCount) {
        documentView.setMaxTabCount(maxTabCount);
    }

    @ReactProp(name = "thumbnailViewEditingEnabled")
    public void setThumbnailViewEditingEnabled(DocumentView documentView, boolean thumbnailViewEditingEnabled) {
        documentView.setThumbnailViewEditingEnabled(thumbnailViewEditingEnabled);
    }

    @ReactProp(name = "imageInReflowEnabled")
    public void setImageInReflowEnabled(DocumentView documentView, boolean imageInReflowEnabled) {
        documentView.setImageInReflowEnabled(imageInReflowEnabled);
    }

    @ReactProp(name = "reflowOrientation")
    public void setReflowOrientation(DocumentView documentView, String reflowOrientation) {
        documentView.setReflowOrientation(reflowOrientation);
    }

    @ReactProp(name = "selectAnnotationAfterCreation")
    public void setSelectAnnotationAfterCreation(DocumentView documentView, boolean selectAnnotationAfterCreation) {
        documentView.setSelectAnnotationAfterCreation(selectAnnotationAfterCreation);
    }

    @ReactProp(name = "overrideAnnotationMenuBehavior")
    public void setOverrideAnnotationMenuBehavior(DocumentView documentView, @NonNull ReadableArray items) {
        documentView.setOverrideAnnotationMenuBehavior(items);
    }

    @ReactProp(name = "overrideLongPressMenuBehavior")
    public void setOverrideLongPressMenuBehavior(DocumentView documentView, @NonNull ReadableArray items) {
        documentView.setOverrideLongPressMenuBehavior(items);
    }

    @ReactProp(name = "overrideBehavior")
    public void setOverrideBehavior(DocumentView documentView, @NonNull ReadableArray items) {
        documentView.setOverrideBehavior(items);
    }

    @ReactProp(name = "followSystemDarkMode")
    public void setFollowSystemDarkMode(DocumentView documentView, boolean followSystem) {
        PdfViewCtrlSettingsManager.setFollowSystemDarkMode(documentView.getContext(), followSystem);
    }

    @ReactProp(name = "signSignatureFieldsWithStamps")
    public void setSignSignatureFieldsWithStamps(DocumentView documentView, boolean signWithStamp) {
        documentView.setSignSignatureFieldsWithStamps(signWithStamp);
    }

    @ReactProp(name = "annotationPermissionCheckEnabled")
    public void setAnnotationPermissionCheckEnabled(DocumentView documentView, boolean annotPermissionCheckEnabled) {
        documentView.setAnnotationPermissionCheckEnabled(annotPermissionCheckEnabled);
    }

    @ReactProp(name = "annotationToolbars")
    public void setAnnotationToolbars(DocumentView documentView, ReadableArray toolbars) {
        documentView.setAnnotationToolbars(toolbars);
    }

    @ReactProp(name = "initialToolbar")
    public void setInitialToolbar(DocumentView documentView, String toolbarTag) {
        documentView.setInitialToolbar(toolbarTag);
    }

    @ReactProp(name = "hideDefaultAnnotationToolbars")
    public void setHideDefaultAnnotationToolbars(DocumentView documentView, ReadableArray tags) {
        documentView.setHideDefaultAnnotationToolbars(tags);
    }

    @ReactProp(name = "hideAnnotationToolbarSwitcher")
    public void setHideAnnotationToolbarSwitcher(DocumentView documentView, boolean hide) {
        documentView.setHideAnnotationToolbarSwitcher(hide);
    }

    @ReactProp(name = "hideTopToolbars")
    public void setHideTopToolbars(DocumentView documentView, boolean hide) {
        documentView.setHideTopToolbars(hide);
    }

    @ReactProp(name = "hideTopAppNavBar")
    public void setHideTopAppNavBar(DocumentView documentView, boolean hide) {
        documentView.setHideTopAppNavBar(hide);
    }

    @ReactProp(name = "hideThumbnailFilterModes")
    public void setHideThumbnailFilterModes(DocumentView documentView, ReadableArray filterModes) {
        documentView.setHideThumbnailFilterModes(filterModes);
    }

    @ReactProp(name = "hideViewModeItems")
    public void hideViewModeItems(DocumentView documentView, ReadableArray viewModePickerItems) {
        documentView.viewModePickerItems(viewModePickerItems);
    }

    @ReactProp(name = "zoom")
    public void setZoom(DocumentView documentView, double zoom) {
        documentView.setZoom(zoom);
    }

    @ReactProp(name = "scale")
    public void setScale(DocumentView documentView, double scale) {
        documentView.setZoom(scale);
    }

    @ReactProp(name = "horizontalScrollPos")
    public void setHorizontalScrollPos(DocumentView documentView, double horizontalScrollPos) {
        documentView.setHorizontalScrollPos(horizontalScrollPos);
    }

    @ReactProp(name = "verticalScrollPos")
    public void setVerticalScrollPos(DocumentView documentView, double verticalScrollPos) {
        documentView.setVerticalScrollPos(verticalScrollPos);
    }

    @ReactProp(name = "pageStackEnabled")
    public void setPageStackEnabled(DocumentView documentView, boolean pageStackEnabled) {
        documentView.setPageStackEnabled(pageStackEnabled);
    }

    @ReactProp(name = "hideToolbarsOnAppear")
    public void setHideToolbarsOnAppear(DocumentView documentView, boolean hideToolbarsOnAppear) {
        documentView.setHideToolbarsOnAppear(hideToolbarsOnAppear);
    }

    @ReactProp(name = "showQuickNavigationButton")
    public void setShowQuickNavigationButton(DocumentView documentView, boolean showQuickNavigationButton) {
        documentView.setShowQuickNavigationButton(showQuickNavigationButton);
    }

    @ReactProp(name = "photoPickerEnabled")
    public void setPhotoPickerEnabled(DocumentView documentView, boolean photoPickerEnabled) {
        documentView.setPhotoPickerEnabled(photoPickerEnabled);
    }

    @ReactProp(name = "autoResizeFreeTextEnabled")
    public void setAutoResizeFreeTextEnabled(DocumentView documentView, boolean autoResizeFreeTextEnabled) {
        documentView.setAutoResizeFreeTextEnabled(autoResizeFreeTextEnabled);
    }

    @ReactProp(name = "annotationsListEditingEnabled")
    public void setAnnotationsListEditingEnabled(DocumentView documentView, boolean annotationsListEditingEnabled) {
        documentView.setAnnotationsListEditingEnabled(annotationsListEditingEnabled);
    }

    @ReactProp(name = "userBookmarksListEditingEnabled")
    public void setUserBookmarksListEditingEnabled(DocumentView documentView, boolean userBookmarksListEditingEnabled) {
        documentView.setUserBookmarksListEditingEnabled(userBookmarksListEditingEnabled);
    }

    @ReactProp(name = "excludedAnnotationListTypes")
    public void setExcludedAnnotationListTypes(DocumentView documentView, ReadableArray excludedTypes) {
        documentView.setExcludedAnnotationListTypes(excludedTypes);
    }

    @ReactProp(name = "showNavigationListAsSidePanelOnLargeDevices")
    public void setShowNavigationListAsSidePanelOnLargeDevices(DocumentView documentView,
            boolean showNavigationListAsSidePanelOnLargeDevices) {
        documentView.setShowNavigationListAsSidePanelOnLargeDevices(showNavigationListAsSidePanelOnLargeDevices);
    }

    @ReactProp(name = "restrictDownloadUsage")
    public void setRestrictDownloadUsage(DocumentView documentView, boolean restrictDownloadUsage) {
        documentView.setRestrictDownloadUsage(restrictDownloadUsage);
    }

    @ReactProp(name = "exportPath")
    public void setExportPath(DocumentView documentView, String exportPath) {
        documentView.setExportPath(exportPath);
    }

    @ReactProp(name = "openUrlPath")
    public void setOpenUrlPath(DocumentView documentView, String openUrlPath) {
        documentView.setOpenUrlPath(openUrlPath);
    }

    @ReactProp(name = "inkMultiStrokeEnabled")
    public void setInkMultiStrokeEnabled(DocumentView documentView, boolean inkMultiStrokeEnabled) {
        documentView.setInkMultiStrokeEnabled(inkMultiStrokeEnabled);
    }

    @ReactProp(name = "keyboardShortcutsEnabled")
    public void setKeyboardShortcutsEnabled(DocumentView documentView, boolean keyboardShortcutsEnabled) {
        ShortcutHelper.enable(keyboardShortcutsEnabled);
    }

    @ReactProp(name = "storeNewSignature")
    public void setStoreNewSignature(DocumentView documentView, boolean storeNewSignature) {
        documentView.setStoreNewSignature(storeNewSignature);
    }

    @ReactProp(name = "disableEditingByAnnotationType")
    public void setDisableEditingByAnnotationType(DocumentView documentView, ReadableArray annotationTypes) {
        documentView.setDisableEditingByAnnotationType(annotationTypes);
    }

    @ReactProp(name = "saveStateEnabled")
    public void setSaveStateEnabled(DocumentView documentView, boolean saveState) {
        documentView.setSaveStateEnabled(saveState);
    }

    @ReactProp(name = "openSavedCopyInNewTab")
    public void setOpenSavedCopyInNewTab(DocumentView documentView, boolean openSavedCopyInNewTab) {
        documentView.setOpenSavedCopyInNewTab(openSavedCopyInNewTab);
    }

    @ReactProp(name = "replyReviewStateEnabled")
    public void setReplyReviewStateEnabled(DocumentView documentView, boolean replyReviewStateEnabled) {
        documentView.setReplyReviewStateEnabled(replyReviewStateEnabled);
    }

    @ReactProp(name = "topAppNavBarRightBar")
    public void setTopAppNavBarRightBar(DocumentView documentView, ReadableArray menus) {
        documentView.setTopAppNavBarRightBar(menus);
    }

    @ReactProp(name = "hidePresetBar")
    public void setHidePresetBar(DocumentView documentView, boolean hidePresetBar) {
        documentView.setHidePresetBar(hidePresetBar);
    }

    @ReactProp(name = "hideThumbnailsViewItems")
    public void setHideThumbnailsViewItems(DocumentView documentView, ReadableArray thumbnailViewItems) {
        documentView.setHideThumbnailsViewItems(thumbnailViewItems);
    }

    @ReactProp(name = "highlighterSmoothingEnabled")
    public void setHighlighterSmoothingEnabled(DocumentView documentView, boolean highlighterSmoothingEnabled) {
        documentView.setHighlighterSmoothingEnabled(highlighterSmoothingEnabled);
    }

    @ReactProp(name = "maxSignatureCount")
    public void setMaxSignatureCount(DocumentView documentView, int maxSignatureCount) {
        SignatureDialogFragment.MAX_SIGNATURES = maxSignatureCount;
    }

    // Hygen Generated Props
    @ReactProp(name = "enableReadingModeQuickMenu")
    public void setEnableReadingModeQuickMenu(DocumentView documentView, boolean enabled) {
        documentView.setEnableReadingModeQuickMenu(enabled);
    }

    @ReactProp(name = "forceAppTheme")
    public void setForceAppTheme(DocumentView documentView, @NonNull String forcedAppThemeItems) {
        documentView.setForceAppTheme(forcedAppThemeItems);
    }

    @ReactProp(name = "signatureColors")
    public void setSignatureColors(DocumentView documentView, @NonNull ReadableArray signatureColors) {
        documentView.setSignatureColors(signatureColors);
    }

    @ReactProp(name = "overrideToolbarButtonBehavior")
    public void setOverrideToolbarButtonBehavior(DocumentView documentView, @NonNull ReadableArray items) {
        documentView.setOverrideToolbarButtonBehavior(items);
    }

    public void importBookmarkJson(int tag, String bookmarkJson) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.importBookmarkJson(bookmarkJson);
        } else {
            throw new PDFNetException("", 0L, getName(), "importBookmarkJson", "Unable to find DocumentView.");
        }
    }

    public void openBookmarkList(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.openBookmarkList();
        } else {
            throw new PDFNetException("", 0L, getName(), "openBookmarkList", "Unable to find DocumentView.");
        }
    }

    public void importAnnotationCommand(int tag, String xfdfCommand, boolean initialLoad) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.importAnnotationCommand(xfdfCommand, initialLoad);
        } else {
            throw new PDFNetException("", 0L, getName(), "importAnnotationCommand",
                    "set collabEnabled to true is required.");
        }
    }

    public WritableArray importAnnotations(int tag, String xfdf, boolean replace) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.importAnnotations(xfdf, replace);
        } else {
            throw new PDFNetException("", 0L, getName(), "importAnnotations", "Unable to find DocumentView.");
        }
    }

    public String exportAnnotations(int tag, ReadableMap options) throws Exception {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.exportAnnotations(options);
        } else {
            throw new PDFNetException("", 0L, getName(), "exportAnnotations", "Unable to find DocumentView.");
        }
    }

    public String saveDocument(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.saveDocument();
        } else {
            throw new PDFNetException("", 0L, getName(), "saveDocument", "Unable to find DocumentView.");
        }
    }

    public void flattenAnnotations(int tag, boolean formsOnly) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.flattenAnnotations(formsOnly);
        } else {
            throw new PDFNetException("", 0L, getName(), "flattenAnnotations", "Unable to find DocumentView.");
        }
    }

    public String getDocumentPath(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getDocumentPath();
        } else {
            throw new PDFNetException("", 0L, getName(), "setToolMode", "Unable to find DocumentView.");
        }
    }

    public WritableArray getAllFields(int tag, int pageNumber) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getAllFields(pageNumber);
        } else {
            throw new PDFNetException("", 0L, getName(), "getAllFields", "Unable to find DocumentView.");
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

    public boolean commitTool(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.commitTool();
        } else {
            throw new PDFNetException("", 0L, getName(), "commitTool", "Unable to find DocumentView.");
        }
    }

    public void setCurrentToolbar(int tag, String toolbarTag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setCurrentToolbar(toolbarTag);
        } else {
            throw new PDFNetException("", 0L, getName(), "setCurrentToolbar", "Unable to find DocumentView.");
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

    public void setFlagForFields(int tag, ReadableArray fields, Integer flag, Boolean value) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setFlagForFields(fields, flag, value);
        } else {
            throw new PDFNetException("", 0L, getName(), "setFlagForFields", "Unable to find DocumentView.");
        }
    }

    public void setValuesForFields(int tag, ReadableMap map) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setValuesForFields(map);
        } else {
            throw new PDFNetException("", 0L, getName(), "setValuesForFields", "Unable to find DocumentView.");
        }
    }

    public WritableMap getField(int tag, String fieldName) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getField(fieldName);
        } else {
            throw new PDFNetException("", 0L, getName(), "getField", "Unable to find DocumentView.");
        }
    }

    public void deleteAnnotations(int tag, ReadableArray annots) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.deleteAnnotations(annots);
        } else {
            throw new PDFNetException("", 0L, getName(), "deleteAnnotations", "Unable to find DocumentView.");
        }
    }

    public ReadableMap getAnnotationAt(int tag, int x, int y, double distanceThreshold, double minimumLineWeight)
            throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getAnnotationAt(x, y, distanceThreshold, minimumLineWeight);
        } else {
            throw new PDFNetException("", 0L, getName(), "getAnnotationAt", "Unable to find DocumentView.");
        }
    }

    public ReadableArray getAnnotationListAt(int tag, int x1, int y1, int x2, int y2) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getAnnotationListAt(x1, y1, x2, y2);
        } else {
            throw new PDFNetException("", 0L, getName(), "getAnnotationListAt", "Unable to find DocumentView.");
        }
    }

    public ReadableArray getAnnotationListOnPage(int tag, int pageNumber) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getAnnotationListOnPage(pageNumber);
        } else {
            throw new PDFNetException("", 0L, getName(), "getAnnotationListOnPage", "Unable to find DocumentView.");
        }
    }

    public void openAnnotationList(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.openAnnotationList();
        } else {
            throw new PDFNetException("", 0L, getName(), "openAnnotationList", "Unable to find DocumentView.");
        }
    }

    public String getCustomDataForAnnotation(int tag, String annotationID, int pageNumber, String key)
            throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getCustomDataForAnnotation(annotationID, pageNumber, key);
        } else {
            throw new PDFNetException("", 0L, getName(), "getCustomDataForAnnotation", "Unable to find DocumentView.");
        }
    }

    public void setAnnotationToolbarItemEnabled(int tag, String itemId, boolean enable) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setAnnotationToolbarItemEnabled(itemId, enable);
        } else {
            throw new PDFNetException("", 0L, getName(), "setAnnotationToolbarItemEnabled", "Unable to find DocumentView.");
        }
    }

    public boolean handleBackButton(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.handleBackButton();
        } else {
            throw new PDFNetException("", 0L, getName(), "handleBackButton", "Unable to find DocumentView.");
        }
    }

    public void setFlagsForAnnotations(int tag, ReadableArray annotationFlagList) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setFlagsForAnnotations(annotationFlagList);
        } else {
            throw new PDFNetException("", 0L, getName(), "setFlagsForAnnotation", "Unable to find DocumentView.");
        }
    }

    public void selectAnnotation(int tag, String annotId, int pageNumber) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.selectAnnotation(annotId, pageNumber);
        } else {
            throw new PDFNetException("", 0L, getName(), "selectAnnotation", "Unable to find DocumentView.");
        }
    }

    public void setPropertiesForAnnotation(int tag, String annotId, int pageNumber, ReadableMap propertyMap)
            throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setPropertiesForAnnotation(annotId, pageNumber, propertyMap);
        } else {
            throw new PDFNetException("", 0L, getName(), "setPropertiesForAnnotation", "Unable to find DocumentView.");
        }
    }

    public WritableMap getPropertiesForAnnotation(int tag, String annotId, int pageNumber) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getPropertiesForAnnotation(annotId, pageNumber);
        } else {
            throw new PDFNetException("", 0L, getName(), "getPropertiesForAnnotation", "Unable to find DocumentView.");
        }
    }

    public void setDrawAnnotations(int tag, boolean drawAnnotations) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setDrawAnnotations(drawAnnotations);
        } else {
            throw new PDFNetException("", 0L, getName(), "setVisibilityForAnnotation", "Unable to find DocumentView.");
        }
    }

    public void setVisibilityForAnnotation(int tag, String annotId, int pageNumber, boolean visibility)
            throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setVisibilityForAnnotation(annotId, pageNumber, visibility);
        } else {
            throw new PDFNetException("", 0L, getName(), "setVisibilityForAnnotation", "Unable to find DocumentView.");
        }
    }

    public void setHighlightFields(int tag, boolean highlightFields) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setHighlightFields(highlightFields);
        } else {
            throw new PDFNetException("", 0L, getName(), "setHighlightFields", "Unable to find DocumentView.");
        }
    }

    public void closeAllTabs(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.closeAllTabs();
        } else {
            throw new PDFNetException("", 0L, getName(), "closeAllTabs", "Unable to find DocumentView.");
        }
    }

    public void openTabSwitcher(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.openTabSwitcher();
        } else {
            throw new PDFNetException("", 0L, getName(), "openTabSwitcher", "Unable to find DocumentView.");
        }
    }

    public WritableMap getPageCropBox(int tag, int pageNumber) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getPageCropBox(pageNumber);
        } else {
            throw new PDFNetException("", 0L, getName(), "getPageCropBox", "Unable to find DocumentView.");
        }
    }

    public boolean setCurrentPage(int tag, int pageNumber) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            boolean setResult = documentView.setCurrentPage(pageNumber);
            return setResult;
        } else {
            throw new PDFNetException("", 0L, getName(), "setCurrentPage", "Unable to find DocumentView.");
        }
    }

    public WritableArray getVisiblePages(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getVisiblePages();
        } else {
            throw new PDFNetException("", 0L, getName(), "getVisiblePages", "Unable to find DocumentView.");
        }
    }

    public int getPageRotation(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            int rotation = documentView.getPageRotation();
            return rotation;
        } else {
            throw new PDFNetException("", 0L, getName(), "getPageRotation", "Unable to find DocumentView.");
        }
    }

    public void rotateClockwise(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.rotateClockwise();
        } else {
            throw new PDFNetException("", 0L, getName(), "rotateClockwise", "Unable to find DocumentView.");
        }
    }

    public void rotateCounterClockwise(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.rotateCounterClockwise();
        } else {
            throw new PDFNetException("", 0L, getName(), "rotateCounterClockwise", "Unable to find DocumentView.");
        }
    }

    public boolean gotoPreviousPage(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            boolean setResult = documentView.gotoPreviousPage();
            return setResult;
        } else {
            throw new PDFNetException("", 0L, getName(), "gotoPreviousPage", "Unable to find DocumentView.");
        }
    }

    public boolean gotoNextPage(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            boolean setResult = documentView.gotoNextPage();
            return setResult;
        } else {
            throw new PDFNetException("", 0L, getName(), "gotoNextPage", "Unable to find DocumentView.");
        }
    }

    public boolean gotoFirstPage(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            boolean setResult = documentView.gotoFirstPage();
            return setResult;
        } else {
            throw new PDFNetException("", 0L, getName(), "gotoFirstPage", "Unable to find DocumentView.");
        }
    }

    public boolean gotoLastPage(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            boolean setResult = documentView.gotoLastPage();
            return setResult;
        } else {
            throw new PDFNetException("", 0L, getName(), "gotoLastPage", "Unable to find DocumentView.");
        }
    }

    public double getZoom(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getZoom();
        } else {
            throw new PDFNetException("", 0L, getName(), "getZoom", "Unable to find DocumentView.");
        }
    }

    public void setZoomLimits(int tag, String zoomLimitMode, double minimum, double maximum) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setZoomLimits(zoomLimitMode, minimum, maximum);
        } else {
            throw new PDFNetException("", 0L, getName(), "setZoomLimits", "Unable to find DocumentView.");
        }
    }

    public void zoomWithCenter(int tag, double zoom, int x, int y) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.zoomWithCenter(zoom, x, y);
        } else {
            throw new PDFNetException("", 0L, getName(), "zoomWithCenter", "Unable to find DocumentView.");
        }
    }

    public void zoomToRect(int tag, int pageNumber, ReadableMap rect) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.zoomToRect(pageNumber, rect);
        } else {
            throw new PDFNetException("", 0L, getName(), "zoomToRect", "Unable to find DocumentView.");
        }
    }

    public void smartZoom(int tag, int x, int y, boolean animated) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.smartZoom(x, y, animated);
        } else {
            throw new PDFNetException("", 0L, getName(), "smartZoom", "Unable to find DocumentView.");
        }
    }

    public WritableMap getScrollPos(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getScrollPos();
        } else {
            throw new PDFNetException("", 0L, getName(), "getScrollPos", "Unable to find DocumentView.");
        }
    }

    public WritableMap getCanvasSize(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getCanvasSize();
        } else {
            throw new PDFNetException("", 0L, getName(), "getCanvasSize", "Unable to find DocumentView.");
        }
    }

    public WritableArray convertScreenPointsToPagePoints(int tag, ReadableArray points) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.convertScreenPointsToPagePoints(points);
        } else {
            throw new PDFNetException("", 0L, getName(), "convertScreenPointsToPagePoints",
                    "Unable to find DocumentView.");
        }
    }

    public WritableArray convertPagePointsToScreenPoints(int tag, ReadableArray points) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.convertPagePointsToScreenPoints(points);
        } else {
            throw new PDFNetException("", 0L, getName(), "convertPagePointsToScreenPoints",
                    "Unable to find DocumentView.");
        }
    }

    public int getPageNumberFromScreenPoint(int tag, double x, double y) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getPageNumberFromScreenPoint(x, y);
        } else {
            throw new PDFNetException("", 0L, getName(), "getPageNumberFromScreenPoint",
                    "Unable to find DocumentView.");
        }
    }

    public void setProgressiveRendering(int tag, boolean progressiveRendering, int initialDelay, int interval)
            throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setProgressiveRendering(progressiveRendering, initialDelay, interval);
        } else {
            throw new PDFNetException("", 0L, getName(), "setProgressiveRendering", "Unable to find DocumentView.");
        }
    }

    public void setImageSmoothing(int tag, boolean imageSmoothing) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setImageSmoothing(imageSmoothing);
        } else {
            throw new PDFNetException("", 0L, getName(), "setImageSmoothing", "Unable to find DocumentView.");
        }
    }

    public void setOverprint(int tag, String overprint) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setOverprint(overprint);
        } else {
            throw new PDFNetException("", 0L, getName(), "setOverprint", "Unable to find DocumentView.");
        }
    }

    public void setPageBorderVisibility(int tag, boolean pageBorderVisibility) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setPageBorderVisibility(pageBorderVisibility);
        } else {
            throw new PDFNetException("", 0L, getName(), "setPageBorderVisibility", "Unable to find DocumentView.");
        }
    }

    public void setPageTransparencyGrid(int tag, boolean pageTransparencyGrid) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setPageTransparencyGrid(pageTransparencyGrid);
        } else {
            throw new PDFNetException("", 0L, getName(), "setPageTransparencyGrid", "Unable to find DocumentView.");
        }
    }

    public void setDefaultPageColor(int tag, ReadableMap defaultPageColor) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setDefaultPageColor(defaultPageColor);
        } else {
            throw new PDFNetException("", 0L, getName(), "setDefaultPageColor", "Unable to find DocumentView.");
        }
    }

    public void setBackgroundColor(int tag, ReadableMap backgroundColor) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setBackgroundColor(backgroundColor);
        } else {
            throw new PDFNetException("", 0L, getName(), "setBackgroundColor", "Unable to find DocumentView.");
        }
    }

    public void setColorPostProcessMode(int tag, String colorPostProcessMode) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setColorPostProcessMode(colorPostProcessMode);
        } else {
            throw new PDFNetException("", 0L, getName(), "setColorPostProcessMode", "Unable to find DocumentView.");
        }
    }

    public void setColorPostProcessColors(int tag, ReadableMap whiteColor, ReadableMap blackColor)
            throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setColorPostProcessColors(whiteColor, blackColor);
        } else {
            throw new PDFNetException("", 0L, getName(), "setColorPostProcessColors", "Unable to find DocumentView.");
        }
    }

    public void startSearchMode(int tag, String searchString, boolean matchCase, boolean matchWholeWord)
            throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.startSearchMode(searchString, matchCase, matchWholeWord);
        } else {
            throw new PDFNetException("", 0L, getName(), "startSearchMode", "Unable to find DocumentView.");
        }
    }

    public void exitSearchMode(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.exitSearchMode();
        } else {
            throw new PDFNetException("", 0L, getName(), "exitSearchMode", "Unable to find DocumentView.");
        }
    }

    public void findText(int tag, String searchString, boolean matchCase, boolean matchWholeWord, boolean searchUp,
            boolean regExp) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.findText(searchString, matchCase, matchWholeWord, searchUp, regExp);
        } else {
            throw new PDFNetException("", 0L, getName(), "findText", "Unable to find DocumentView.");
        }
    }

    public void cancelFindText(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.cancelFindText();
        } else {
            throw new PDFNetException("", 0L, getName(), "cancelFindText", "Unable to find DocumentView.");
        }
    }

    public void openSearch(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.openSearch();
        } else {
            throw new PDFNetException("", 0L, getName(), "openSearch", "Unable to find DocumentView.");
        }
    }

    public WritableMap getSelection(int tag, int pageNumber) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            WritableMap selection = documentView.getSelection(pageNumber);
            return selection;
        } else {
            throw new PDFNetException("", 0L, getName(), "cancelFindText", "Unable to find DocumentView.");
        }
    }

    public boolean hasSelection(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            boolean hasSelection = documentView.hasSelection();
            return hasSelection;
        } else {
            throw new PDFNetException("", 0L, getName(), "hasSelection", "Unable to find DocumentView.");
        }
    }

    public void clearSelection(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.clearSelection();
        } else {
            throw new PDFNetException("", 0L, getName(), "clearSelection", "Unable to find DocumentView.");
        }
    }

    public WritableMap getSelectionPageRange(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            WritableMap pageRange = documentView.getSelectionPageRange();
            return pageRange;
        } else {
            throw new PDFNetException("", 0L, getName(), "getSelectionPageRange", "Unable to find DocumentView.");
        }
    }

    public boolean hasSelectionOnPage(int tag, int pageNumber) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            boolean hasSelection = documentView.hasSelectionOnPage(pageNumber);
            return hasSelection;
        } else {
            throw new PDFNetException("", 0L, getName(), "hasSelectionOnPage", "Unable to find DocumentView.");
        }
    }

    public boolean selectInRect(int tag, ReadableMap rect) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            boolean selected = documentView.selectInRect(rect);
            return selected;
        } else {
            throw new PDFNetException("", 0L, getName(), "selectInRect", "Unable to find DocumentView.");
        }
    }

    public boolean isThereTextInRect(int tag, ReadableMap rect) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            boolean hasText = documentView.isThereTextInRect(rect);
            return hasText;
        } else {
            throw new PDFNetException("", 0L, getName(), "isThereTextInRect", "Unable to find DocumentView.");
        }
    }

    public void selectAll(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.selectAll();
        } else {
            throw new PDFNetException("", 0L, getName(), "selectAll", "Unable to find DocumentView.");
        }
    }

    public String exportAsImage(final int tag, int pageNumber, double dpi, String exportFormat, boolean transparent) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.exportAsImage(pageNumber, dpi, exportFormat, transparent);
        } else {
            throw new PDFNetException("", 0L, getName(), "exportAsImage", "Unable to find DocumentView.");
        }
    }

    public void undo(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.undo();
        } else {
            throw new PDFNetException("", 0L, getName(), "undo", "Unable to find DocumentView.");
        }
    }

    public void redo(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.redo();
        } else {
            throw new PDFNetException("", 0L, getName(), "redo", "Unable to find DocumentView.");
        }
    }

    public boolean canUndo(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.canUndo();
        } else {
            throw new PDFNetException("", 0L, getName(), "canUndo", "Unable to find DocumentView.");
        }
    }

    public boolean canRedo(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.canRedo();
        } else {
            throw new PDFNetException("", 0L, getName(), "canRedo", "Unable to find DocumentView.");
        }
    }

    public void showViewSettings(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.showViewSettings();
        } else {
            throw new PDFNetException("", 0L, getName(), "showViewSettings", "Unable to find DocumentView.");
        }
    }

    public void showAddPagesView(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.showAddPagesView();
        } else {
            throw new PDFNetException("", 0L, getName(), "showAddPagesView", "Unable to find DocumentView.");
        }
    }

    public void shareCopy(int tag, boolean flattening) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.shareCopy(flattening);
        } else {
            throw new PDFNetException("", 0L, getName(), "shareCopy", "Unable to find DocumentView.");
        }
    }

    public void showCrop(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.showCropDialog();
        } else {
            throw new PDFNetException("", 0L, getName(), "showCrop", "Unable to find DocumentView.");
        }
    }

    public void showRotateDialog(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.showRotateDialog();
        } else {
            throw new PDFNetException("", 0L, getName(), "showRotateDialog", "Unable to find DocumentView.");
        }
    }

    public void openOutlineList(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.openOutlineList();
        } else {
            throw new PDFNetException("", 0L, getName(), "openOutlineList", "Unable to find DocumentView.");
        }
    }

    public void openLayersList(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.openLayersList();
        } else {
            throw new PDFNetException("", 0L, getName(), "openLayersList", "Unable to find DocumentView.");
        }
    }

    public void openNavigationLists(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.openNavigationLists();
        } else {
            throw new PDFNetException("", 0L, getName(), "openNavigationLists", "Unable to find DocumentView");
        }
    }

    public boolean isReflowMode(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.isReflowMode();
        } else {
            throw new PDFNetException("", 0L, getName(), "isReflowMode", "Unable to find DocumentView.");
        }
    }

    public void toggleReflow(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.toggleReflow();
        } else {
            throw new PDFNetException("", 0L, getName(), "toggleReflow", "Unable to find DocumentView.");
        }
    }

    public void openThumbnailsView(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.openThumbnailsView();
        } else {
            throw new PDFNetException("", 0L, getName(), "openThumbnailsView", "Unable to find DocumentView.");
        }
    }

    public void showGoToPageView(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.showGoToPageView();
        } else {
            throw new PDFNetException("", 0L, getName(), "showGoToPageView", "Unable to find DocumentView.");
        }
    }

    public ReadableArray getSavedSignatures(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getSavedSignatures();
        } else {
            throw new PDFNetException("", 0L, getName(), "getSavedSignatures", "Unable to find DocumentView.");
        }
    }

    public String getSavedSignatureFolder(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getSavedSignatureFolder();
        } else {
            throw new PDFNetException("", 0L, getName(), "getSavedSignatureFolder", "Unable to find DocumentView.");
        }
    }

    public String getSavedSignatureJpgFolder(int tag) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.getSavedSignatureJpgFolder();
        } else {
            throw new PDFNetException("", 0L, getName(), "getSavedSignatureJpgFolder", "Unable to find DocumentView.");
        }
    }

    // Hygen Generated Methods
    public void setStampImageData(int tag, String annotationId, int pageNumber, String stampImageDataUrl, Promise promise) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setStampImageData(annotationId, pageNumber, stampImageDataUrl, promise);
        } else {
            throw new PDFNetException("", 0L, getName(), "setStampImageData", "Unable to find DocumentView.");
        }
    }

    public void setFormFieldHighlightColor(int tag, ReadableMap fieldHighlightColor) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            documentView.setFormFieldHighlightColor(fieldHighlightColor);
        } else {
            throw new PDFNetException("", 0L, getName(), "setFormFieldHighlightColor", "Unable to find DocumentView.");
        }
    }


    @Override
    public boolean needsCustomLayoutForChildren() {
        return true;
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        for (int i = 0; i < mDocumentViews.size(); i++) {
            int key = mDocumentViews.keyAt(i);
            DocumentView documentView = mDocumentViews.get(key);
            documentView.onActivityResult(requestCode, resultCode, data);
        }
    }
}
