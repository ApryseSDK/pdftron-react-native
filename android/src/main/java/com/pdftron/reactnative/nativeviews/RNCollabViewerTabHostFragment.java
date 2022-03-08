package com.pdftron.reactnative.nativeviews;

import android.os.Bundle;
import android.view.View;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.pdftron.collab.ui.viewer.CollabViewerTabHostFragment2;

public class RNCollabViewerTabHostFragment extends CollabViewerTabHostFragment2 {

    private RNPdfViewCtrlTabHostFragment.RNHostFragmentListener mListener;

    public void setRNHostFragmentListener(RNPdfViewCtrlTabHostFragment.RNHostFragmentListener listener) {
        mListener = listener;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        if (mListener != null) {
            mListener.onHostFragmentViewCreated();
        }
    }
}
