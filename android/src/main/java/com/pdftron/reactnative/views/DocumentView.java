package com.pdftron.reactnative.views;

import android.app.Activity;
import android.content.Context;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Bundle;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.util.AttributeSet;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.FrameLayout;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.pdftron.pdf.config.ToolManagerBuilder;
import com.pdftron.pdf.config.ViewerConfig;
import com.pdftron.pdf.controls.PdfViewCtrlTabFragment;
import com.pdftron.pdf.controls.PdfViewCtrlTabHostFragment;
import com.pdftron.pdf.model.FileInfo;
import com.pdftron.pdf.utils.Utils;
import com.pdftron.reactnative.R;
import com.pdftron.reactnative.utils.ReactUtils;

public class DocumentView extends FrameLayout implements
        PdfViewCtrlTabHostFragment.TabHostListener {

    private static final String TAG = DocumentView.class.getSimpleName();

    // EVENTS
    private static final String ON_NAV_BUTTON_PRESSED = "onLeadingNavButtonPressed";
    // EVENTS END

    private PdfViewCtrlTabHostFragment mPdfViewCtrlTabHostFragment;
    private FragmentManager mFragmentManager;

    private int mNavIconRes = R.drawable.ic_arrow_back_white_24dp;
    private boolean mShowNavIcon = true;
    private String mDocumentPath;
    private String mPassword = "";

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
        if (currentActivity != null && currentActivity instanceof FragmentActivity) {
            mFragmentManager = ((FragmentActivity) reactContext.getCurrentActivity()).getSupportFragmentManager();
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

    public void setPassword(String password) {
        if (Utils.isNullOrEmpty(password)) {
            mPassword = password;
        }
    }

    public void setNavResName(String resName) {
        if (resName == null) {
            return;
        }
        int res = Utils.getResourceDrawable(getContext(), resName);
        if (res != 0) {
            mNavIconRes = res;
        }
    }

    public void setShowNavIcon(boolean showNavIcon) {
        mShowNavIcon = showNavIcon;
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

    public void prepView() {
        if (mDocumentPath == null) {
            return;
        }
        Uri fileUri = ReactUtils.getUri(getContext(), mDocumentPath);
        if (fileUri != null) {
            ToolManagerBuilder toolManagerBuilder = ToolManagerBuilder.from(getContext(), R.style.MyToolManager);

            ViewerConfig.Builder builder = new ViewerConfig.Builder();
            ViewerConfig config = builder
                    .fullscreenModeEnabled(false)
                    .multiTabEnabled(false)
                    .showCloseTabOption(false)
                    .setToolManagerBuilder(toolManagerBuilder)
                    .build();

            Bundle args = PdfViewCtrlTabFragment.createBasicPdfViewCtrlTabBundle(getContext(), fileUri, "", config);
            args.putParcelable(PdfViewCtrlTabHostFragment.BUNDLE_TAB_HOST_CONFIG, config);
            args.putInt(PdfViewCtrlTabHostFragment.BUNDLE_TAB_HOST_NAV_ICON, mShowNavIcon ? mNavIconRes : 0);

            if (mPdfViewCtrlTabHostFragment != null) {
                mPdfViewCtrlTabHostFragment.onOpenAddNewTab(args);
                return;
            }
            mPdfViewCtrlTabHostFragment = PdfViewCtrlTabHostFragment.newInstance(args);

            if (mFragmentManager != null) {
                mFragmentManager.beginTransaction()
                        .add(mPdfViewCtrlTabHostFragment, TAG)
                        .commitNow();

                View fragmentView = mPdfViewCtrlTabHostFragment.getView();
                if (fragmentView != null) {
                    addView(fragmentView, LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
                }
            }
        }
    }

    public void cleanup() {
        getViewTreeObserver().removeOnGlobalLayoutListener(mOnGlobalLayoutListener);
        if (mFragmentManager != null) {
            PdfViewCtrlTabHostFragment fragment = (PdfViewCtrlTabHostFragment) mFragmentManager.findFragmentByTag(TAG);
            if (fragment != null) {
                mFragmentManager.beginTransaction()
                        .remove(fragment)
                        .commitAllowingStateLoss();
            }
        }
        mPdfViewCtrlTabHostFragment = null;
        mFragmentManager = null;
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();

        prepView();

        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.addHostListener(this);
        }

        getViewTreeObserver().addOnGlobalLayoutListener(mOnGlobalLayoutListener);
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();

        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.removeHostListener(this);
        }

        cleanup();
    }

    @Override
    public void onTabHostShown() {

    }

    @Override
    public void onTabHostHidden() {

    }

    @Override
    public void onLastTabClosed() {

    }

    @Override
    public void onTabChanged(String tag) {

    }

    @Override
    public void onOpenDocError() {

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
    public void onShowFileInFolder(String fileName, String filepath, int itemSource) {

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
    public boolean onToolbarCreateOptionsMenu(Menu menu, MenuInflater inflater) {
        return false;
    }

    @Override
    public boolean onToolbarPrepareOptionsMenu(Menu menu) {
        return false;
    }

    @Override
    public boolean onToolbarOptionsItemSelected(MenuItem item) {
        return false;
    }

    @Override
    public void onStartSearchMode() {

    }

    @Override
    public void onExitSearchMode() {

    }

    @Override
    public boolean canRecreateActivity() {
        return false;
    }

    @Override
    public void onTabPaused(FileInfo fileInfo, boolean b) {

    }

    @Override
    public void onJumpToSdCardFolder() {

    }

    @Override
    public void onTabDocumentLoaded(String s) {

    }
}
