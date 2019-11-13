package com.pdftron.reactnative.views;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Bundle;
import android.util.AttributeSet;
import android.util.Log;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.pdftron.common.PDFNetException;
import com.pdftron.fdf.FDFDoc;
import com.pdftron.pdf.Annot;
import com.pdftron.pdf.PDFDoc;
import com.pdftron.pdf.PDFViewCtrl;
import com.pdftron.pdf.config.PDFViewCtrlConfig;
import com.pdftron.pdf.config.ToolManagerBuilder;
import com.pdftron.pdf.config.ViewerConfig;
import com.pdftron.pdf.tools.ToolManager;
import com.pdftron.pdf.utils.PdfDocManager;
import com.pdftron.pdf.utils.PdfViewCtrlSettingsManager;
import com.pdftron.pdf.utils.Utils;
import com.pdftron.pdf.utils.ViewerUtils;
import com.pdftron.reactnative.R;
import com.pdftron.reactnative.utils.ReactUtils;

import org.json.JSONException;

import java.util.ArrayList;
import java.util.Map;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentActivity;

public class DocumentView extends com.pdftron.pdf.controls.DocumentView {
    private static final String TAG = DocumentView.class.getSimpleName();

    // EVENTS
    private static final String ON_NAV_BUTTON_PRESSED = "onLeadingNavButtonPressed";
    private static final String ON_DOCUMENT_LOADED = "onDocumentLoaded";
    private static final String ON_PAGE_CHANGED = "onPageChanged";
    private static final String ON_DOCUMENT_SAVE_START = "onDocumentSaveStart";
    private static final String ON_DOCUMENT_SAVE_FINISH = "onDocumentSaveFinish";
    private static final String ON_DOCUMENT_SAVE_FAIL = "onDocumentSaveFail";

    private static final String ON_ANNOTATION_CHANGED = "onAnnotationChanged";
    private static final String ON_DOCUMENT_ERROR = "onDocumentError";

    private static final String PREV_PAGE_KEY = "previousPageNumber";
    private static final String PAGE_CURRENT_KEY = "pageNumber";
    private static final String FAIL_MESSAGE_KEY = "failMessage";

    private static final String KEY_annotList = "annotList";
    private static final String KEY_annotId = "id";
    private static final String KEY_annotPage = "pageNumber";

    private static final String KEY_action = "action";
    private static final String KEY_action_add = "add";
    private static final String KEY_action_modify = "modify";
    private static final String KEY_action_delete = "delete";
    private static final String KEY_annotations = "annotations";
    // EVENTS END

    private String mDocumentPath;

    private PDFViewCtrlConfig mPDFViewCtrlConfig;
    private ToolManagerBuilder mToolManagerBuilder;
    private ViewerConfig.Builder mBuilder;

    private String mCacheDir;
    private int mInitialPageNumber = -1;
    private boolean mTopToolbarEnabled = true;

    public DocumentView(Context context) {
        super(context);
    }

    public DocumentView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public DocumentView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void setup(ThemedReactContext reactContext) {
        int width = ViewGroup.LayoutParams.MATCH_PARENT;
        int height = ViewGroup.LayoutParams.MATCH_PARENT;
        ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(width, height);
        setLayoutParams(params);

        Activity currentActivity = reactContext.getCurrentActivity();
        if (currentActivity instanceof AppCompatActivity) {
            setSupportFragmentManager(((AppCompatActivity) reactContext.getCurrentActivity()).getSupportFragmentManager());
            mCacheDir = currentActivity.getCacheDir().getAbsolutePath();
            mPDFViewCtrlConfig = PDFViewCtrlConfig.getDefaultConfig(currentActivity);
        } else {
            throw new IllegalStateException("FragmentActivity required.");
        }

        mToolManagerBuilder = ToolManagerBuilder.from();
        mBuilder = new ViewerConfig.Builder();
        mBuilder
                .fullscreenModeEnabled(false)
                .multiTabEnabled(false)
                .showCloseTabOption(false)
                .useSupportActionBar(false);
    }

    public void setDocument(String path) {
        if (Utils.isNullOrEmpty(path)) {
            return;
        }
        mDocumentPath = path;
    }

    public void setNavResName(String resName) {
        setNavIconResName(resName);
    }

    public void setDisabledElements(ReadableArray array) {
        disableElements(array);
    }

    public void setDisabledTools(ReadableArray array) {
        disableTools(array);
    }

    public void setCustomHeaders(ReadableMap map) {
        if (null == map) {
            return;
        }
        try {
            mCustomHeaders = ReactUtils.convertMapToJson(map);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void setInitialPageNumber(int pageNum) {
        mInitialPageNumber = pageNum;
    }

    public void setPageNumber(int pageNumber) {
        if (mPdfViewCtrlTabHostFragment != null &&
                mPdfViewCtrlTabHostFragment.getCurrentPdfViewCtrlFragment() != null &&
                mPdfViewCtrlTabHostFragment.getCurrentPdfViewCtrlFragment().isDocumentReady()) {
            try {
                getPdfViewCtrl().setCurrentPage(pageNumber);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    public void setTopToolbarEnabled(boolean topToolbarEnabled) {
        mTopToolbarEnabled = topToolbarEnabled;
    }

    public void setBottomToolbarEnabled(boolean bottomToolbarEnabled) {
        mBuilder = mBuilder.showBottomNavBar(bottomToolbarEnabled);
    }

    public void setPageIndicatorEnabled(boolean pageIndicatorEnabled) {
        mBuilder = mBuilder.showPageNumberIndicator(pageIndicatorEnabled);
    }

    public void setReadOnly(boolean readOnly) {
        mBuilder = mBuilder.documentEditingEnabled(!readOnly);
    }

    public void setFitMode(String fitMode) {
        if (mPDFViewCtrlConfig != null) {
            PDFViewCtrl.PageViewMode mode = null;
            if ("FitPage".equals(fitMode)) {
                mode = PDFViewCtrl.PageViewMode.FIT_PAGE;
            } else if ("FitWidth".equals(fitMode)) {
                mode = PDFViewCtrl.PageViewMode.FIT_WIDTH;
            } else if ("FitHeight".equals(fitMode)) {
                mode = PDFViewCtrl.PageViewMode.FIT_HEIGHT;
            } else if ("Zoom".equals(fitMode)) {
                mode = PDFViewCtrl.PageViewMode.ZOOM;
            }
            if (mode != null) {
                mPDFViewCtrlConfig.setPageViewMode(mode);
            }
        }
    }

    public void setLayoutMode(String layoutMode) {
        String mode = null;
        if ("Single".equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_SINGLEPAGE_VALUE;
        } else if ("Continuous".equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_CONTINUOUS_VALUE;
        } else if ("Facing".equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACING_VALUE;
        } else if ("FacingContinuous".equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACING_CONT_VALUE;
        } else if ("FacingCover".equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACINGCOVER_VALUE;
        } else if ("FacingCoverContinuous".equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACINGCOVER_CONT_VALUE;
        }
        Context context = getContext();
        if (mode != null && context != null) {
            PdfViewCtrlSettingsManager.updateViewMode(context, mode);
        }
    }

    public void setContinuousAnnotationEditing(boolean contEditing) {
        Context context = getContext();
        if (context != null) {
            PdfViewCtrlSettingsManager.setContinuousAnnotationEdit(context, contEditing);
        }
    }

    public void setAnnotationAuthor(String author) {
        Context context = getContext();
        if (context != null && !Utils.isNullOrEmpty(author)) {
            PdfViewCtrlSettingsManager.updateAuthorName(context, author);
            PdfViewCtrlSettingsManager.setAnnotListShowAuthor(context, true);
        }
    }

    private void disableElements(ReadableArray args) {
        for (int i = 0; i < args.size(); i++) {
            String item = args.getString(i);
            if ("toolsButton".equals(item)) {
                mBuilder = mBuilder.showAnnotationToolbarOption(false);
            } else if ("searchButton".equals(item)) {
                mBuilder = mBuilder.showSearchView(false);
            } else if ("shareButton".equals(item)) {
                mBuilder = mBuilder.showShareOption(false);
            } else if ("viewControlsButton".equals(item)) {
                mBuilder = mBuilder.showDocumentSettingsOption(false);
            } else if ("thumbnailsButton".equals(item)) {
                mBuilder = mBuilder.showThumbnailView(false);
            } else if ("listsButton".equals(item)) {
                mBuilder = mBuilder
                        .showAnnotationsList(false)
                        .showOutlineList(false)
                        .showUserBookmarksList(false);
            } else if ("thumbnailSlider".equals(item)) {
                mBuilder = mBuilder.showBottomNavBar(false);
            } else if ("editPagesButton".equals(item)) {
                mBuilder = mBuilder.showEditPagesOption(false);
            } else if ("printButton".equals(item)) {
                mBuilder = mBuilder.showPrintOption(false);
            } else if ("closeButton".equals(item)) {
                mBuilder = mBuilder.showCloseTabOption(false);
            } else if ("saveCopyButton".equals(item)) {
                mBuilder = mBuilder.showSaveCopyOption(false);
            } else if ("formToolsButton".equals(item)) {
                mBuilder = mBuilder.showFormToolbarOption(false);
            } else if ("moreItemsButton".equals(item)) {
                mBuilder = mBuilder
                        .showEditPagesOption(false)
                        .showPrintOption(false)
                        .showCloseTabOption(false)
                        .showSaveCopyOption(false)
                        .showFormToolbarOption(false);
            } else if ("outlineListButton".equals(item)) {
                mBuilder = mBuilder.showOutlineList(false);
            } else if ("annotationListButton".equals(item)) {
                mBuilder = mBuilder.showAnnotationsList(false);
            } else if ("userBookmarkListButton".equals(item)) {
                mBuilder = mBuilder.showUserBookmarksList(false);
            }
        }
        disableTools(args);
    }

    private void disableTools(ReadableArray args) {
        ArrayList<ToolManager.ToolMode> modesArr = new ArrayList<>();
        for (int i = 0; i < args.size(); i++) {
            String item = args.getString(i);
            ToolManager.ToolMode mode = convStringToToolMode(item);
            if (mode != null) {
                modesArr.add(mode);
            }
        }
        ToolManager.ToolMode[] modes = modesArr.toArray(new ToolManager.ToolMode[modesArr.size()]);
        if (modes.length > 0) {
            mToolManagerBuilder = mToolManagerBuilder.disableToolModes(modes);
        }
    }

    private ToolManager.ToolMode convStringToToolMode(String item) {
        ToolManager.ToolMode mode = null;
        if ("freeHandToolButton".equals(item) || "AnnotationCreateFreeHand".equals(item)) {
            mode = ToolManager.ToolMode.INK_CREATE;
        } else if ("highlightToolButton".equals(item) || "AnnotationCreateTextHighlight".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_HIGHLIGHT;
        } else if ("underlineToolButton".equals(item) || "AnnotationCreateTextUnderline".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_UNDERLINE;
        } else if ("squigglyToolButton".equals(item) || "AnnotationCreateTextSquiggly".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_SQUIGGLY;
        } else if ("strikeoutToolButton".equals(item) || "AnnotationCreateTextStrikeout".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_STRIKEOUT;
        } else if ("rectangleToolButton".equals(item) || "AnnotationCreateRectangle".equals(item)) {
            mode = ToolManager.ToolMode.RECT_CREATE;
        } else if ("ellipseToolButton".equals(item) || "AnnotationCreateEllipse".equals(item)) {
            mode = ToolManager.ToolMode.OVAL_CREATE;
        } else if ("lineToolButton".equals(item) || "AnnotationCreateLine".equals(item)) {
            mode = ToolManager.ToolMode.LINE_CREATE;
        } else if ("arrowToolButton".equals(item) || "AnnotationCreateArrow".equals(item)) {
            mode = ToolManager.ToolMode.ARROW_CREATE;
        } else if ("polylineToolButton".equals(item) || "AnnotationCreatePolyline".equals(item)) {
            mode = ToolManager.ToolMode.POLYLINE_CREATE;
        } else if ("polygonToolButton".equals(item) || "AnnotationCreatePolygon".equals(item)) {
            mode = ToolManager.ToolMode.POLYGON_CREATE;
        } else if ("cloudToolButton".equals(item) || "AnnotationCreatePolygonCloud".equals(item)) {
            mode = ToolManager.ToolMode.CLOUD_CREATE;
        } else if ("signatureToolButton".equals(item) || "AnnotationCreateSignature".equals(item)) {
            mode = ToolManager.ToolMode.SIGNATURE;
        } else if ("freeTextToolButton".equals(item) || "AnnotationCreateFreeText".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_CREATE;
        } else if ("stickyToolButton".equals(item) || "AnnotationCreateSticky".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_ANNOT_CREATE;
        } else if ("calloutToolButton".equals(item) || "AnnotationCreateCallout".equals(item)) {
            mode = ToolManager.ToolMode.CALLOUT_CREATE;
        } else if ("stampToolButton".equals(item) || "AnnotationCreateStamp".equals(item)) {
            mode = ToolManager.ToolMode.STAMPER;
        } else if ("AnnotationCreateDistanceMeasurement".equals(item)) {
            mode = ToolManager.ToolMode.RULER_CREATE;
        } else if ("AnnotationCreatePerimeterMeasurement".equals(item)) {
            mode = ToolManager.ToolMode.PERIMETER_MEASURE_CREATE;
        } else if ("AnnotationCreateAreaMeasurement".equals(item)) {
            mode = ToolManager.ToolMode.AREA_MEASURE_CREATE;
        } else if ("TextSelect".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_SELECT;
        } else if ("AnnotationEdit".equals(item)) {
            mode = ToolManager.ToolMode.ANNOT_EDIT_RECT_GROUP;
        }
        return mode;
    }

    private ViewerConfig getConfig() {
        if (mCacheDir != null) {
            mBuilder.openUrlCachePath(mCacheDir)
                    .saveCopyExportPath(mCacheDir);
        }
        return mBuilder
                .pdfViewCtrlConfig(mPDFViewCtrlConfig)
                .toolManagerBuilder(mToolManagerBuilder)
                .build();
    }

    private boolean mShouldHandleKeyboard = false;

    private final ViewTreeObserver.OnGlobalLayoutListener mOnGlobalLayoutListener = new ViewTreeObserver.OnGlobalLayoutListener() {
        @Override
        public void onGlobalLayout() {
            Rect r = new Rect();
            getWindowVisibleDisplayFrame(r);
            int screenHeight = getRootView().getHeight();

            // r.bottom is the position above soft keypad or device button.
            // if keypad is shown, the r.bottom is smaller than that before.
            int keypadHeight = screenHeight - r.bottom;

            if (keypadHeight > screenHeight * 0.15) { // 0.15 ratio is perhaps enough to determine keypad height.
                // keyboard is opened
                mShouldHandleKeyboard = true;
            } else {
                // keyboard is closed
                if (mShouldHandleKeyboard) {
                    mShouldHandleKeyboard = false;
                    requestLayout();
                }
            }
        }
    };

    private final Runnable mLayoutRunnable = new Runnable() {
        @Override
        public void run() {
            measure(
                    MeasureSpec.makeMeasureSpec(getWidth(), MeasureSpec.EXACTLY),
                    MeasureSpec.makeMeasureSpec(getHeight(), MeasureSpec.EXACTLY));
            layout(getLeft(), getTop(), getRight(), getBottom());
        }
    };

    public void doDocSave() {
        try {
            onReceiveNativeEvent(ON_DOCUMENT_SAVE_START, ON_DOCUMENT_SAVE_START);
            Log.d(TAG, "Starting document save...");
            getPdfDoc().save();
            onReceiveNativeEvent(ON_DOCUMENT_SAVE_FINISH, ON_DOCUMENT_SAVE_FINISH);
        } catch (Exception ex) {
            WritableMap params = Arguments.createMap();
            params.putString(ON_DOCUMENT_SAVE_FAIL, ON_DOCUMENT_SAVE_FAIL);
            params.putString(FAIL_MESSAGE_KEY, ex.getMessage());
            onReceiveNativeEvent(params);
        }
    }

    @Override
    public void requestLayout() {
        super.requestLayout();

        post(mLayoutRunnable);
    }

    @Override
    protected void onAttachedToWindow() {
        Uri fileUri = ReactUtils.getUri(getContext(), mDocumentPath);
        if (fileUri != null) {
            setDocumentUri(fileUri);
            setViewerConfig(getConfig());
        }
        super.onAttachedToWindow();

        if (!mTopToolbarEnabled) {
            mPdfViewCtrlTabHostFragment.setToolbarTimerDisabled(true);
            mPdfViewCtrlTabHostFragment.getToolbar().setVisibility(GONE);
        }

        getViewTreeObserver().addOnGlobalLayoutListener(mOnGlobalLayoutListener);
    }

    @Override
    protected void onDetachedFromWindow() {
        if (getPdfViewCtrl() != null) {
            getPdfViewCtrl().removePageChangeListener(mPageChangeListener);
        }
        if (getToolManager() != null) {
            getToolManager().removeAnnotationModificationListener(mAnnotationModificationListener);
        }

        super.onDetachedFromWindow();
        getViewTreeObserver().removeOnGlobalLayoutListener(mOnGlobalLayoutListener);
    }

    @Override
    public void onNavButtonPressed() {
        onReceiveNativeEvent(ON_NAV_BUTTON_PRESSED, ON_NAV_BUTTON_PRESSED);
    }

    @Override
    public boolean canShowFileInFolder() {
        return false;
    }

    @Override
    public boolean canShowFileCloseSnackbar() {
        return false;
    }

    @Override
    public boolean canRecreateActivity() {
        return false;
    }

    private PDFViewCtrl.PageChangeListener mPageChangeListener = new PDFViewCtrl.PageChangeListener() {
        @Override
        public void onPageChange(int old_page, int cur_page, PDFViewCtrl.PageChangeState pageChangeState) {
            if (old_page != cur_page || pageChangeState == PDFViewCtrl.PageChangeState.END) {
                WritableMap params = Arguments.createMap();
                params.putString(ON_PAGE_CHANGED, ON_PAGE_CHANGED);
                params.putInt(PREV_PAGE_KEY, old_page);
                params.putInt(PAGE_CURRENT_KEY, cur_page);
                onReceiveNativeEvent(params);
            }
        }
    };

    private ToolManager.AnnotationModificationListener mAnnotationModificationListener = new ToolManager.AnnotationModificationListener() {
        @Override
        public void onAnnotationsAdded(Map<Annot, Integer> map) {
            handleAnnotationChanged(KEY_action_add, map);
        }

        @Override
        public void onAnnotationsPreModify(Map<Annot, Integer> map) {

        }

        @Override
        public void onAnnotationsModified(Map<Annot, Integer> map, Bundle bundle) {
            handleAnnotationChanged(KEY_action_modify, map);
        }

        @Override
        public void onAnnotationsPreRemove(Map<Annot, Integer> map) {
            handleAnnotationChanged(KEY_action_delete, map);
        }

        @Override
        public void onAnnotationsRemoved(Map<Annot, Integer> map) {

        }

        @Override
        public void onAnnotationsRemovedOnPage(int i) {

        }

        @Override
        public void annotationsCouldNotBeAdded(String s) {

        }
    };

    private void handleAnnotationChanged(String action, Map<Annot, Integer> map) {
        WritableMap params = Arguments.createMap();
        params.putString(ON_ANNOTATION_CHANGED, ON_ANNOTATION_CHANGED);
        params.putString(KEY_action, action);

        WritableArray annotList = Arguments.createArray();
        for (Map.Entry<Annot, Integer> entry : map.entrySet()) {
            Annot key = entry.getKey();

            String uid = null;
            try {
                uid = key.getUniqueID() != null ? key.getUniqueID().getAsPDFText() : null;
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (uid != null) {
                Integer value = entry.getValue();
                WritableMap annotData = Arguments.createMap();
                annotData.putString(KEY_annotId, uid);
                annotData.putInt(KEY_annotPage, value);
                annotList.pushMap(annotData);
            }
        }

        params.putArray(KEY_annotations, annotList);
        onReceiveNativeEvent(params);
    }

    @Override
    public void onTabDocumentLoaded(String tag) {
        super.onTabDocumentLoaded(tag);

        if (mInitialPageNumber > 0) {
            try {
                getPdfViewCtrl().setCurrentPage(mInitialPageNumber);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }

        onReceiveNativeEvent(ON_DOCUMENT_LOADED, tag);

        getPdfViewCtrl().addPageChangeListener(mPageChangeListener);

        getToolManager().addAnnotationModificationListener(mAnnotationModificationListener);
    }

    @Override
    public void onOpenDocError() {
        super.onOpenDocError();

        String error = "Unknown error";
        if (mPdfViewCtrlTabHostFragment != null && mPdfViewCtrlTabHostFragment.getCurrentPdfViewCtrlFragment() != null) {
            int messageId = com.pdftron.pdf.tools.R.string.error_opening_doc_message;
            int errorCode = mPdfViewCtrlTabHostFragment.getCurrentPdfViewCtrlFragment().getTabErrorCode();
            switch (errorCode) {
                case PdfDocManager.DOCUMENT_SETDOC_ERROR_ZERO_PAGE:
                    messageId = R.string.error_empty_file_message;
                    break;
                case PdfDocManager.DOCUMENT_SETDOC_ERROR_OPENURL_CANCELLED:
                    messageId = R.string.download_cancelled_message;
                    break;
                case PdfDocManager.DOCUMENT_SETDOC_ERROR_WRONG_PASSWORD:
                    messageId = R.string.password_not_valid_message;
                    break;
                case PdfDocManager.DOCUMENT_SETDOC_ERROR_NOT_EXIST:
                    messageId = R.string.file_does_not_exist_message;
                    break;
                case PdfDocManager.DOCUMENT_SETDOC_ERROR_DOWNLOAD_CANCEL:
                    messageId = R.string.download_size_cancelled_message;
                    break;
            }
            error = mPdfViewCtrlTabHostFragment.getString(messageId);
        }
        onReceiveNativeEvent(ON_DOCUMENT_ERROR, error);
    }

    public void importAnnotations(String xfdf) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        PDFDoc pdfDoc = pdfViewCtrl.getDoc();

        boolean shouldUnlockRead = false;
        try {
            pdfViewCtrl.docLockRead();
            shouldUnlockRead = true;

            if (pdfDoc.hasDownloader()) {
                // still downloading file, let's wait for next call
                return;
            }
        } finally {
            if (shouldUnlockRead) {
                pdfViewCtrl.docUnlockRead();
            }
        }

        boolean shouldUnlock = false;
        try {
            pdfViewCtrl.docLock(true);
            shouldUnlock = true;

            FDFDoc fdfDoc = FDFDoc.createFromXFDF(xfdf);
            pdfDoc.fdfUpdate(fdfDoc);
            pdfViewCtrl.update(true);
        } finally {
            if (shouldUnlock) {
                pdfViewCtrl.docUnlock();
            }
        }
    }

    public String exportAnnotations(ReadableMap options) throws Exception {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        boolean shouldUnlockRead = false;
        try {
            pdfViewCtrl.docLockRead();
            shouldUnlockRead = true;

            PDFDoc pdfDoc = pdfViewCtrl.getDoc();
            if (null == options || !options.hasKey(KEY_annotList)) {
                FDFDoc fdfDoc = pdfDoc.fdfExtract(PDFDoc.e_both);
                return fdfDoc.saveAsXFDF();
            } else {
                ReadableArray arr = options.getArray(KEY_annotList);
                ArrayList<Annot> annots = new ArrayList<>(arr.size());
                for (int i = 0; i < arr.size(); i++) {
                    ReadableMap annotData = arr.getMap(i);
                    String id = annotData.getString(KEY_annotId);
                    int page = annotData.getInt(KEY_annotPage);
                    if (!Utils.isNullOrEmpty(id)) {
                        Annot ann = ViewerUtils.getAnnotById(getPdfViewCtrl(), id, page);
                        if (ann != null && ann.isValid()) {
                            annots.add(ann);
                        }
                    }
                }
                if (annots.size() > 0) {
                    FDFDoc fdfDoc = pdfDoc.fdfExtract(annots);
                    return fdfDoc.saveAsXFDF();
                }
                return "";
            }
        } finally {
            if (shouldUnlockRead) {
                pdfViewCtrl.docUnlockRead();
            }
        }
    }

    public void saveDocument() {
        if (mPdfViewCtrlTabHostFragment != null && mPdfViewCtrlTabHostFragment.getCurrentPdfViewCtrlFragment() != null) {
            mPdfViewCtrlTabHostFragment.getCurrentPdfViewCtrlFragment().save(false, true, true);
        }
    }

    public void flattenAnnotations(boolean formsOnly) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        PDFDoc pdfDoc = pdfViewCtrl.getDoc();

        boolean shouldUnlock = false;
        try {
            pdfViewCtrl.docLock(true);
            shouldUnlock = true;

            pdfDoc.flattenAnnotations(formsOnly);
        } finally {
            if (shouldUnlock) {
                pdfViewCtrl.docUnlock();
            }
        }
    }

    public int getPageCount() throws PDFNetException {
        return getPdfDoc().getPageCount();
    }

    public void setToolMode(String item) {
        if (getToolManager() != null) {
            ToolManager.ToolMode mode = convStringToToolMode(item);
            getToolManager().setTool(getToolManager().createTool(mode, null));
        }
    }

    public PDFViewCtrl getPdfViewCtrl() {
        if (mPdfViewCtrlTabHostFragment != null && mPdfViewCtrlTabHostFragment.getCurrentPdfViewCtrlFragment() != null) {
            return mPdfViewCtrlTabHostFragment.getCurrentPdfViewCtrlFragment().getPDFViewCtrl();
        }
        return null;
    }

    public PDFDoc getPdfDoc() {
        if (mPdfViewCtrlTabHostFragment != null && mPdfViewCtrlTabHostFragment.getCurrentPdfViewCtrlFragment() != null) {
            return mPdfViewCtrlTabHostFragment.getCurrentPdfViewCtrlFragment().getPdfDoc();
        }
        return null;
    }

    public ToolManager getToolManager() {
        if (mPdfViewCtrlTabHostFragment != null && mPdfViewCtrlTabHostFragment.getCurrentPdfViewCtrlFragment() != null) {
            return mPdfViewCtrlTabHostFragment.getCurrentPdfViewCtrlFragment().getToolManager();
        }
        return null;
    }

    public void onReceiveNativeEvent(String key, String message) {
        WritableMap event = Arguments.createMap();
        event.putString(key, message);
        ReactContext reactContext = (ReactContext) getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                getId(),
                "topChange",
                event);
    }

    public void onReceiveNativeEvent(WritableMap event) {
        ReactContext reactContext = (ReactContext) getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                getId(),
                "topChange",
                event);
    }
}
