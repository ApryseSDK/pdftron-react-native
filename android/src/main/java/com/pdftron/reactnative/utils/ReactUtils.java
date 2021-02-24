package com.pdftron.reactnative.utils;

import android.content.ContentResolver;
import android.content.Context;
import android.net.Uri;
import android.util.Base64;
import android.util.Log;
import android.webkit.URLUtil;

import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.pdftron.pdf.utils.Utils;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.net.URLEncoder;
import java.util.HashMap;

public class ReactUtils {

    private static final String TAG = ReactUtils.class.getName();
    private static HashMap<String, byte[]> fileTypeMap = new HashMap<>();

    public static Uri getUri(Context context, String path, boolean isBase64) {
        if (context == null || path == null) {
            return null;
        }
        try {
            if (isBase64) {
                byte[] data = Base64.decode(path, Base64.DEFAULT);
                File tempFile = File.createTempFile("tmp", getFileTypeFromBase64(data));
                FileOutputStream fos = null;
                try {
                    fos = new FileOutputStream(tempFile);
                    IOUtils.write(data, fos);
                    return Uri.fromFile(tempFile);
                } finally {
                    IOUtils.closeQuietly(fos);
                }
            }
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
            } else if (URLUtil.isHttpUrl(path) || URLUtil.isHttpsUrl(path)) {
                // this is a link uri, let's encode the file name
                if (path.contains(" ")) {
                    String filename = FilenameUtils.getName(path);
                    if (filename.contains("?")) {
                        filename = filename.substring(0, filename.indexOf("?")); // remove query params
                    }
                    String encodedName = URLEncoder.encode(filename, "UTF-8").replace("+", "%20");
                    String newUrl = path.replace(filename, encodedName);
                    return Uri.parse(newUrl);
                }
            }
            return fileUri;
        } catch (Exception ex) {
            Log.e(TAG, ex.getMessage() != null ? ex.getMessage() : "unknown error");
            ex.printStackTrace();
        }
        return null;
    }

    public static JSONObject convertMapToJson(ReadableMap readableMap) throws JSONException {
        JSONObject object = new JSONObject();
        ReadableMapKeySetIterator iterator = readableMap.keySetIterator();
        while (iterator.hasNextKey()) {
            String key = iterator.nextKey();
            switch (readableMap.getType(key)) {
                case Null:
                    object.put(key, JSONObject.NULL);
                    break;
                case Boolean:
                    object.put(key, readableMap.getBoolean(key));
                    break;
                case Number:
                    object.put(key, readableMap.getDouble(key));
                    break;
                case String:
                    object.put(key, readableMap.getString(key));
                    break;
                case Map:
                    object.put(key, convertMapToJson(readableMap.getMap(key)));
                    break;
                case Array:
                    object.put(key, convertArrayToJson(readableMap.getArray(key)));
                    break;
            }
        }
        return object;
    }

    public static JSONArray convertArrayToJson(ReadableArray readableArray) throws JSONException {
        JSONArray array = new JSONArray();
        for (int i = 0; i < readableArray.size(); i++) {
            switch (readableArray.getType(i)) {
                case Null:
                    break;
                case Boolean:
                    array.put(readableArray.getBoolean(i));
                    break;
                case Number:
                    array.put(readableArray.getDouble(i));
                    break;
                case String:
                    array.put(readableArray.getString(i));
                    break;
                case Map:
                    array.put(convertMapToJson(readableArray.getMap(i)));
                    break;
                case Array:
                    array.put(convertArrayToJson(readableArray.getArray(i)));
                    break;
            }
        }
        return array;
    }

    // This function makes use of the magical numbers for the base64 string of different file types
    private static String getFileTypeFromBase64(byte[] byteArray) {
        if (fileTypeMap.isEmpty()) {
            fileTypeMap.put(".pdf", byteArray(0x25, 0x50, 0x44, 0x46, 0x2d));
            fileTypeMap.put(".jpg", byteArray(0xff, 0xd8));
            fileTypeMap.put(".png", byteArray(0x89, 0x50, 0x4e, 0x47));
            fileTypeMap.put(".ico", byteArray(0x00, 0x00, 0x01, 0x00));
            fileTypeMap.put(".gif", byteArray(0x47, 0x49, 0x46, 0x38));
            fileTypeMap.put(".tif", byteArray(0x49, 0x49));
        }

        // iterate through supported types to match the base64 byte array
        for (String extension : fileTypeMap.keySet()) {
            boolean matchExtensionPattern = true;
            byte[] extensionArray = fileTypeMap.get(extension);

            for (int i = 0; i < extensionArray.length; i ++) {
                if (i >= byteArray.length || extensionArray[i] != byteArray[i]) {
                    matchExtensionPattern = false;
                    break;
                }
            }
            if (matchExtensionPattern) {
                return extension;
            }
        }
        return ".pdf";
    }

    private static byte[] byteArray(int... parameters) {
        byte[] byteArray = new byte[parameters.length];
        for (int i = 0; i < parameters.length; i ++) {
            byteArray[i] = (byte)parameters[i];
        }
        return byteArray;
    }
}
