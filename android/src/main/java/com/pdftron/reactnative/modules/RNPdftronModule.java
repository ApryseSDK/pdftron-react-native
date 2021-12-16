package com.pdftron.reactnative.modules;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.pdftron.pdf.Convert;
import com.pdftron.pdf.OfficeToPDFOptions;
import com.pdftron.pdf.PDFDoc;
import com.pdftron.pdf.PDFNet;
import com.pdftron.pdf.model.StandardStampOption;
import com.pdftron.pdf.utils.AppUtils;
import com.pdftron.pdf.utils.Utils;
import com.pdftron.pdf.utils.ViewerUtils;
import com.pdftron.reactnative.utils.ReactUtils;
import com.pdftron.sdf.SDFDoc;

import static com.pdftron.reactnative.utils.Constants.*;

import java.io.File;

public class RNPdftronModule extends ReactContextBaseJavaModule {

    private static final String REACT_CLASS = "RNPdftron";

    public RNPdftronModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Override
    public String getName() {
        return REACT_CLASS;
    }

    @ReactMethod
    public void initialize(@NonNull String key) {
        try {
            AppUtils.initializePDFNetApplication(getReactApplicationContext(), key);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    @ReactMethod
    public void enableJavaScript(boolean enabled) {
        try {
            PDFNet.enableJavaScript(enabled);
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    @ReactMethod
    public void getSystemFontList(final Promise promise) {
        String fontList = null;
        Exception exception = null;
        try {
            fontList = PDFNet.getSystemFontList();
        } catch (Exception e) {
            exception = e;
        }

        String finalFontList = fontList;
        Exception finalException = exception;
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {

            @Override
            public void run() {
                if (finalFontList != null) {
                    promise.resolve(finalFontList);
                } else {
                    promise.reject(finalException);
                }
            }
        });
    }

    @ReactMethod
    public void clearRubberStampCache(final Promise promise) {
        StandardStampOption.clearCache(getReactApplicationContext());
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                promise.resolve(null);
            }
        });
    }

    @ReactMethod
    public void encryptDocument(final String filePath, final String password, final String currentPassword, final Promise promise) {
        try {
            String oldPassword = currentPassword;
            if (Utils.isNullOrEmpty(currentPassword)) {
                oldPassword = "";
            }
            PDFDoc pdfDoc = new PDFDoc(filePath);
            if (pdfDoc.initStdSecurityHandler(oldPassword)) {
                ViewerUtils.passwordDoc(pdfDoc, password);
                pdfDoc.lock();
                pdfDoc.save(filePath, SDFDoc.SaveMode.REMOVE_UNUSED, null);
                pdfDoc.unlock();
                promise.resolve(null);
            } else {
                promise.reject("password", "Current password is incorrect.");
            }
        } catch (Exception ex) {
            promise.reject(ex);
        }
    }

    @ReactMethod
    public void getVersion(final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    promise.resolve(Double.toString(PDFNet.getVersion()));
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void getPlatformVersion(final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    promise.resolve("Android " + android.os.Build.VERSION.RELEASE);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }

    @ReactMethod
    public void pdfFromOffice(final String docxPath, final @Nullable ReadableMap options, final Promise promise) {
        try {
            PDFDoc doc = new PDFDoc();
            OfficeToPDFOptions conversionOptions = new OfficeToPDFOptions();

            if (options != null) {
                if (options.hasKey("applyPageBreaksToSheet")) {
                    if (!options.isNull("applyPageBreaksToSheet")) {
                        conversionOptions.setApplyPageBreaksToSheet(options.getBoolean("applyPageBreaksToSheet"));
                    }
                }

                if (options.hasKey("displayChangeTracking")) {
                    if (!options.isNull("displayChangeTracking")) {
                        conversionOptions.setDisplayChangeTracking(options.getBoolean("displayChangeTracking"));
                    }
                }

                if (options.hasKey("excelDefaultCellBorderWidth")) {
                    if (!options.isNull("excelDefaultCellBorderWidth")) {
                        conversionOptions.setExcelDefaultCellBorderWidth(options.getDouble("excelDefaultCellBorderWidth"));
                    }
                }

                if (options.hasKey("excelMaxAllowedCellCount")) {
                    if (!options.isNull("excelMaxAllowedCellCount")) {
                        conversionOptions.setExcelMaxAllowedCellCount(options.getInt("excelMaxAllowedCellCount"));
                    }
                }

                if (options.hasKey("locale")) {
                    if (!options.isNull("locale")) {
                        conversionOptions.setLocale(options.getString("locale"));
                    }
                }
            }

            Convert.officeToPdf(doc, docxPath, conversionOptions);
            File resultPdf = File.createTempFile("tmp", ".pdf", getReactApplicationContext().getFilesDir());
            doc.save(resultPdf.getAbsolutePath(), SDFDoc.SaveMode.NO_FLAGS, null);
            promise.resolve(resultPdf.getAbsolutePath());
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void pdfFromOfficeTemplate(final String docxPath, final ReadableMap json, final Promise promise) {
        try {
            PDFDoc doc = new PDFDoc();
            OfficeToPDFOptions options = new OfficeToPDFOptions();
            options.setTemplateParamsJson(ReactUtils.convertMapToJson(json).toString());
            Convert.officeToPdf(doc, docxPath, options);
            File resultPdf = File.createTempFile("tmp", ".pdf", getReactApplicationContext().getFilesDir());
            doc.save(resultPdf.getAbsolutePath(), SDFDoc.SaveMode.NO_FLAGS, null);
            promise.resolve(resultPdf.getAbsolutePath());
        } catch (Exception e) {
            promise.reject(e);
        }
    }

    @ReactMethod
    public void exportAsImage(int pageNumber, double dpi, String exportFormat, final String filePath, final Promise promise) {
        try {
            PDFDoc doc = new PDFDoc(filePath);
            doc.lockRead();
            String imagePath = ReactUtils.exportAsImageHelper(doc, pageNumber, dpi, exportFormat);
            doc.unlockRead();
            promise.resolve(imagePath);
        } catch (Exception e) {
            promise.reject(e);
        }
    }
}