package com.pdftron.reactnative.views;

import android.content.Context;
import android.net.Uri;
import android.util.AttributeSet;
import android.util.Log;
import android.view.ViewGroup;

import androidx.appcompat.app.AppCompatActivity;

import com.facebook.react.uimanager.ThemedReactContext;
import com.pdftron.pdf.PDFDoc;
import com.pdftron.pdf.PDFViewCtrl;
import com.pdftron.pdf.config.ToolManagerBuilder;
import com.pdftron.pdf.utils.AppUtils;
import com.pdftron.pdf.utils.Utils;
import com.pdftron.reactnative.utils.ReactUtils;

import javax.annotation.Nonnull;

public class PDFViewCtrlView extends PDFViewCtrl {

    private static final String TAG = PDFViewCtrlView.class.getSimpleName();

    private PDFDoc mPdfDoc = null;

    public PDFViewCtrlView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public PDFViewCtrlView(Context context, AttributeSet attrs, int defStyle) {
        super(context, attrs, defStyle);
    }

    public void setup(ThemedReactContext reactContext) {
        int width = ViewGroup.LayoutParams.MATCH_PARENT;
        int height = ViewGroup.LayoutParams.MATCH_PARENT;
        ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(width, height);
        setLayoutParams(params);
        try {
            AppUtils.setupPDFViewCtrl(this);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        if (reactContext.getCurrentActivity() instanceof AppCompatActivity) {
            ToolManagerBuilder.from().build((AppCompatActivity) reactContext.getCurrentActivity(), this);
        }
    }

    public void setDocument(@Nonnull String path) {
        try {
            Uri fileUri = ReactUtils.getUri(getContext(), path, false);
            mPdfDoc = openPDFUri(fileUri, "");
        } catch (Exception ex) {
            Log.e(TAG, ex.getMessage() != null ? ex.getMessage() : "unknown error");
            ex.printStackTrace();
        }
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();

    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();

        destroy();
        if (mPdfDoc != null) {
            Utils.closeQuietly(mPdfDoc);
        }
    }

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
}
