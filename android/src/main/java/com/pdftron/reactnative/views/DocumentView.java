package com.pdftron.reactnative.views;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.net.Uri;
import android.support.v4.app.FragmentActivity;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.pdftron.pdf.config.ToolManagerBuilder;
import com.pdftron.pdf.config.ViewerConfig;
import com.pdftron.pdf.tools.ToolManager;
import com.pdftron.pdf.utils.Utils;
import com.pdftron.reactnative.utils.ReactUtils;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

public class DocumentView extends com.pdftron.pdf.controls.DocumentView {

    private static final String TAG = DocumentView.class.getSimpleName();

    // EVENTS
    private static final String ON_NAV_BUTTON_PRESSED = "onLeadingNavButtonPressed";
    // EVENTS END

    private String mDocumentPath;

    private ToolManagerBuilder mToolManagerBuilder;
    private ViewerConfig.Builder mBuilder;
    private String mCacheDir;
    private int mInitialPageNumber = -1;

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
        if (currentActivity instanceof FragmentActivity) {
            setSupportFragmentManager(((FragmentActivity) reactContext.getCurrentActivity()).getSupportFragmentManager());
            mCacheDir = currentActivity.getCacheDir().getAbsolutePath();
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
            JSONObject headers = ReactUtils.convertMapToJson(map);
            // TODO
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void setInitialPageNumber(int pageNum) {
        mInitialPageNumber = pageNum;
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
            mBuilder.openUrlCachePath(mCacheDir);
        }
        return mBuilder
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

        getViewTreeObserver().addOnGlobalLayoutListener(mOnGlobalLayoutListener);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();

        getViewTreeObserver().removeOnGlobalLayoutListener(mOnGlobalLayoutListener);
    }

    @Override
    public void onNavButtonPressed() {
        WritableMap event = Arguments.createMap();
        event.putString(ON_NAV_BUTTON_PRESSED, ON_NAV_BUTTON_PRESSED);
        ReactContext reactContext = (ReactContext) getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                getId(),
                "topChange",
                event);
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

    @Override
    public void onTabDocumentLoaded(String tag) {
        super.onTabDocumentLoaded(tag);

        if (mInitialPageNumber > 0) {
            try {
                mPdfViewCtrlTabHostFragment.getCurrentPdfViewCtrlFragment().getPDFViewCtrl().setCurrentPage(mInitialPageNumber);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }
}
