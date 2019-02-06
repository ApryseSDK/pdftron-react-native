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
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.pdftron.pdf.config.ToolManagerBuilder;
import com.pdftron.pdf.config.ViewerConfig;
import com.pdftron.pdf.tools.ToolManager;
import com.pdftron.pdf.utils.Utils;
import com.pdftron.reactnative.utils.ReactUtils;

public class DocumentView extends com.pdftron.pdf.controls.DocumentView {

    private static final String TAG = DocumentView.class.getSimpleName();

    // EVENTS
    private static final String ON_NAV_BUTTON_PRESSED = "onLeadingNavButtonPressed";
    // EVENTS END

    private String mDocumentPath;

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
        } else {
            throw new IllegalStateException("FragmentActivity required.");
        }
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
            ToolManagerBuilder toolManagerBuilder = ToolManagerBuilder.from()
                .disableToolModes(new ToolManager.ToolMode[]{
                    ToolManager.ToolMode.STAMPER
                });
            ViewerConfig.Builder builder = new ViewerConfig.Builder();
            ViewerConfig config = builder
                .fullscreenModeEnabled(false)
                .multiTabEnabled(false)
                .showCloseTabOption(false)
                .useSupportActionBar(false)
                .toolManagerBuilder(toolManagerBuilder)
                .build();
            setViewerConfig(config);
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
    public void onTabDocumentLoaded(String s) {
    }
}
