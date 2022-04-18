package com.pdftron.reactnative.nativeviews;

import android.os.Bundle;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pdftron.pdf.controls.PdfViewCtrlTabHostFragment2;

public class RNPdfViewCtrlTabHostFragment extends PdfViewCtrlTabHostFragment2 {

    private RNHostFragmentListener mListener;

    public void setRNHostFragmentListener(RNHostFragmentListener listener) {
        mListener = listener;
    }

    public interface RNHostFragmentListener {
        void onHostFragmentViewCreated();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        if (mListener != null) {
            mListener.onHostFragmentViewCreated();
        }
    }
}
