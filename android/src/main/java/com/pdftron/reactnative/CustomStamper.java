package com.pdftron.reactnative;

import android.net.Uri;
import androidx.annotation.NonNull;

import com.pdftron.pdf.Annot;
import com.pdftron.pdf.PDFViewCtrl;
import com.pdftron.pdf.tools.Stamper;
import com.pdftron.pdf.tools.ToolManager;

public class CustomStamper extends Stamper {
    private Uri mUri;

    public CustomStamper(@NonNull PDFViewCtrl ctrl) {
        super(ctrl);
    }

    public void setUri(Uri uri) {
        mUri = uri;
    }

    @Override
    protected void addStamp() {
        if (mUri != null) {
            createImageStamp(mUri, 0, "");
        } else {
            mNextToolMode = getToolMode();
        }
    }
}
