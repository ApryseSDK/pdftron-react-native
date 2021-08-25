package com.pdftron.reactnative.nativeviews;

import android.view.Gravity;
import androidx.appcompat.widget.Toolbar;

import com.pdftron.pdf.controls.PdfViewCtrlTabHostFragment2;
import com.pdftron.reactnative.R;

public class RNPdfViewCtrlTabHostFragment extends PdfViewCtrlTabHostFragment2 {
    @Override
    protected void initViews() {
        super.initViews();
        mSwitcherButton = mToolbar.findViewById(R.id.switcher_button);
        Toolbar.LayoutParams layoutParams = new Toolbar.LayoutParams(Toolbar.LayoutParams.WRAP_CONTENT, Toolbar.LayoutParams.WRAP_CONTENT);
        layoutParams.gravity = Gravity.CENTER;
        TextView text = mSwitcherButton.findViewById()
        mSwitcherButton.setLayoutParams(layoutParams);
    }
}