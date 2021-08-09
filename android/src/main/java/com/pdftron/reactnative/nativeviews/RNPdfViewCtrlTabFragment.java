package com.pdftron.reactnative.nativeviews;

import android.graphics.PointF;
import android.util.Pair;
import androidx.fragment.app.FragmentActivity;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.pdftron.pdf.PDFDoc;
import com.pdftron.pdf.controls.PdfViewCtrlTabBaseFragment;
import com.pdftron.pdf.controls.PdfViewCtrlTabFragment2;
import com.pdftron.pdf.tools.ToolManager;
import com.pdftron.pdf.utils.AnalyticsHandlerAdapter;
import com.pdftron.pdf.utils.DialogGoToPage;
import com.pdftron.pdf.utils.Utils;
import com.pdftron.pdf.utils.ViewerUtils;

import org.apache.commons.io.FilenameUtils;

import java.io.File;

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

    public void shareCopy(boolean flattening) {
        FragmentActivity activity = getActivity();
        if (activity == null) {
            return;
        }
        if (flattening) {
            File tempFile = new File(activity.getCacheDir(), getTabTitleWithExtension());
            String tempPath = Utils.getFileNameNotInUse(tempFile.getAbsolutePath());
            PdfViewCtrlTabBaseFragment.SaveFolderWrapper wrapper = new PdfViewCtrlTabBaseFragment.SaveFolderWrapper(
                    activity.getCacheDir(), FilenameUtils.getName(tempPath), true, null);
            PDFDoc copyDoc = wrapper.getDoc();
            if (copyDoc != null) {
                ViewerUtils.flattenDoc(copyDoc);
                Pair<Boolean, String> result = wrapper.save(copyDoc);
                Utils.sharePdfFile(activity, new File(result.second));
            }
        } else {
            handleOnlineShare();
        }
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

    public void showGoToPageView() {
        FragmentActivity activity = getActivity();
        if (null == activity) {
            return;
        }
        DialogGoToPage dlgGotoPage = new DialogGoToPage(activity, mPdfViewCtrl, new DialogGoToPage.DialogGoToPageListener() {
            @Override
            public void onPageSet(int pageNum) {
                setCurrentPageHelper(pageNum, true);
                if (mReflowControl != null) {
                    try {
                        mReflowControl.setCurrentPage(pageNum);
                    } catch (Exception e) {
                        AnalyticsHandlerAdapter.getInstance().sendException(e);
                    }
                }
            }
        });
        dlgGotoPage.show();
    }
}
