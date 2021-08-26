package com.pdftron.reactnative.nativeviews;

import android.graphics.Typeface;
import android.view.Gravity;
import android.widget.TextView;
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
        TextView title = mSwitcherButton.findViewById(R.id.title);
        Typeface bold = Typeface.createFromAsset(getContext().getAssets(), "fonts/Roboto-Bold.ttf");
        title.setTypeface(bold);
        mSwitcherButton.setLayoutParams(layoutParams);
    }
}