package com.pdftron.reactnative.utils;

import android.content.ContentResolver;
import android.content.Context;
import android.net.Uri;
import android.util.Log;

import com.pdftron.pdf.utils.Utils;

import org.apache.commons.io.FilenameUtils;

import java.io.File;

public class ReactUtils {

    private static final String TAG = ReactUtils.class.getName();

    public static Uri getUri(Context context, String path) {
        if (context == null || path == null) {
            return null;
        }
        try {
            Uri fileUri = Uri.parse(path);
            if (ContentResolver.SCHEME_ANDROID_RESOURCE.equals(fileUri.getScheme())) {
                String resNameWithExtension = fileUri.getLastPathSegment();
                String extension = FilenameUtils.getExtension(resNameWithExtension);
                String resName = FilenameUtils.removeExtension(resNameWithExtension);
                int resId = Utils.getResourceRaw(context, resName);
                if (resId != 0) {
                    File file = Utils.copyResourceToLocal(context, resId,
                            resName, "." + extension);
                    if (null != file && file.exists()) {
                        fileUri = Uri.fromFile(file);
                    }
                }
            } else if (ContentResolver.SCHEME_FILE.equals(fileUri.getScheme())) {
                File file = new File(fileUri.getPath());
                fileUri = Uri.fromFile(file);
            }
            return fileUri;
        } catch (Exception ex) {
            Log.e(TAG, ex.getMessage() != null ? ex.getMessage() : "unknown error");
            ex.printStackTrace();
        }
        return null;
    }
}
