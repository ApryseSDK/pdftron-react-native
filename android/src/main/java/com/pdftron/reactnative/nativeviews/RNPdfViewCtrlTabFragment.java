package com.pdftron.reactnative.nativeviews;

import android.graphics.PointF;

import androidx.fragment.app.FragmentActivity;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.pdftron.pdf.controls.PdfViewCtrlTabFragment2;
import com.pdftron.pdf.tools.ToolManager;
import com.pdftron.pdf.utils.ViewerUtils;

import javax.annotation.Nullable;

import static com.pdftron.reactnative.utils.Constants.KEY_HORIZONTAL;
import static com.pdftron.reactnative.utils.Constants.KEY_VERTICAL;
import static com.pdftron.reactnative.utils.Constants.ON_SCROLL_CHANGED;
import static com.pdftron.reactnative.utils.Constants.ON_ZOOM_FINISHED;
import static com.pdftron.reactnative.utils.Constants.ZOOM_KEY;

public class RNPdfViewCtrlTabFragment extends PdfViewCtrlTabFragment2 {

    @Nullable
    private ReactContext mReactContext;
    private int mViewId;

    @Override
    public void imageStamperSelected(PointF targetPoint) {
        // in react native, intent must be sent from the activity
        // to be able to receive by the activity
        FragmentActivity activity = getActivity();
        if (null == activity) {
            return;
        }
        this.mImageCreationMode = ToolManager.ToolMode.STAMPER;
        this.mAnnotTargetPoint = targetPoint;
        this.mOutputFileUri = ViewerUtils.openImageIntent(activity);
    }

    @Override
    public void imageSignatureSelected(PointF targetPoint, int targetPage, Long widget) {
        // in react native, intent must be sent from the activity
        // to be able to receive by the activity
        FragmentActivity activity = getActivity();
        if (null == activity) {
            return;
        }
        mImageCreationMode = ToolManager.ToolMode.SIGNATURE;
        mAnnotTargetPoint = targetPoint;
        mAnnotTargetPage = targetPage;
        mTargetWidget = widget;
        mOutputFileUri = ViewerUtils.openImageIntent(activity);
    }

    @Override
    public void attachFileSelected(PointF targetPoint) {
        // in react native, intent must be sent from the activity
        // to be able to receive by the activity
        FragmentActivity activity = getActivity();
        if (null == activity) {
            return;
        }
        mAnnotTargetPoint = targetPoint;
        ViewerUtils.openFileIntent(activity);
    }

    @Override
    public boolean onScaleEnd(float x, float y) {
        WritableMap params = Arguments.createMap();
        params.putString(ON_ZOOM_FINISHED, ON_ZOOM_FINISHED);
        params.putDouble(ZOOM_KEY, mPdfViewCtrl.getZoom());
        onReceiveNativeEvent(params);

        return super.onScaleEnd(x, y);
    }

    @Override
    public void onScrollChanged(int l, int t, int oldl, int oldt) {
        super.onScrollChanged(l, t, oldl, oldt);

        WritableMap params = Arguments.createMap();
        params.putString(ON_SCROLL_CHANGED, ON_SCROLL_CHANGED);
        params.putInt(KEY_HORIZONTAL, l);
        params.putInt(KEY_VERTICAL, t);
        onReceiveNativeEvent(params);
    }

    public void setReactContext(@Nullable ReactContext reactContext, int id) {
        mReactContext = reactContext;
        mViewId = id;
    }

    public void onReceiveNativeEvent(WritableMap event) {
        if (mReactContext == null) {
            return;
        }
        mReactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                mViewId,
                "topChange",
                event);
    }
}
