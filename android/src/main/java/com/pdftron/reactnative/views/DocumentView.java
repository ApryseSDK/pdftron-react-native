package com.pdftron.reactnative.views;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Bundle;
import android.util.AttributeSet;
import android.util.Base64;
import android.util.SparseArray;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.ReadableMapKeySetIterator;
import com.facebook.react.bridge.ReadableType;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.pdftron.collab.db.entity.AnnotationEntity;
import com.pdftron.collab.ui.viewer.CollabManager;
import com.pdftron.collab.ui.viewer.CollabViewerBuilder2;
import com.pdftron.collab.ui.viewer.CollabViewerTabHostFragment2;
import com.pdftron.collab.utils.Keys;
import com.pdftron.common.PDFNetException;
import com.pdftron.fdf.FDFDoc;
import com.pdftron.pdf.Action;
import com.pdftron.pdf.ActionParameter;
import com.pdftron.pdf.Annot;
import com.pdftron.pdf.ColorPt;
import com.pdftron.pdf.DigitalSignatureField;
import com.pdftron.pdf.Element;
import com.pdftron.pdf.ElementBuilder;
import com.pdftron.pdf.ElementWriter;
import com.pdftron.pdf.Field;
import com.pdftron.pdf.Image;
import com.pdftron.pdf.PDFDoc;
import com.pdftron.pdf.PDFViewCtrl;
import com.pdftron.pdf.Page;
import com.pdftron.pdf.ViewChangeCollection;
import com.pdftron.pdf.annots.Markup;
import com.pdftron.pdf.annots.SignatureWidget;
import com.pdftron.pdf.annots.Widget;
import com.pdftron.pdf.config.PDFViewCtrlConfig;
import com.pdftron.pdf.config.ToolConfig;
import com.pdftron.pdf.config.ToolManagerBuilder;
import com.pdftron.pdf.config.ViewerConfig;
import com.pdftron.pdf.controls.PdfViewCtrlTabFragment2;
import com.pdftron.pdf.controls.PdfViewCtrlTabHostFragment2;
import com.pdftron.pdf.controls.ReflowControl;
import com.pdftron.pdf.controls.ThumbnailsViewFragment;
import com.pdftron.pdf.dialog.RotateDialogFragment;
import com.pdftron.pdf.dialog.ViewModePickerDialogFragment;
import com.pdftron.pdf.dialog.digitalsignature.DigitalSignatureDialogFragment;
import com.pdftron.pdf.dialog.pdflayer.PdfLayerDialog;
import com.pdftron.pdf.model.AnnotStyle;
import com.pdftron.pdf.model.UserBookmarkItem;
import com.pdftron.pdf.tools.AdvancedShapeCreate;
import com.pdftron.pdf.tools.AnnotEditTextMarkup;
import com.pdftron.pdf.tools.AnnotManager;
import com.pdftron.pdf.tools.Eraser;
import com.pdftron.pdf.tools.FreehandCreate;
import com.pdftron.pdf.tools.Pan;
import com.pdftron.pdf.tools.QuickMenu;
import com.pdftron.pdf.tools.QuickMenuItem;
import com.pdftron.pdf.tools.TextSelect;
import com.pdftron.pdf.tools.Tool;
import com.pdftron.pdf.tools.ToolManager;
import com.pdftron.pdf.tools.UndoRedoManager;
import com.pdftron.pdf.utils.ActionUtils;
import com.pdftron.pdf.utils.AnnotUtils;
import com.pdftron.pdf.utils.BookmarkManager;
import com.pdftron.pdf.utils.CommonToast;
import com.pdftron.pdf.utils.PdfDocManager;
import com.pdftron.pdf.utils.PdfViewCtrlSettingsManager;
import com.pdftron.pdf.utils.RequestCode;
import com.pdftron.pdf.utils.StampManager;
import com.pdftron.pdf.utils.Utils;
import com.pdftron.pdf.utils.ViewerUtils;
import com.pdftron.pdf.widget.bottombar.builder.BottomBarBuilder;
import com.pdftron.pdf.widget.toolbar.TopToolbarMenuId;
import com.pdftron.pdf.widget.toolbar.builder.AnnotationToolbarBuilder;
import com.pdftron.pdf.widget.toolbar.builder.ToolbarButtonType;
import com.pdftron.pdf.widget.toolbar.component.DefaultToolbars;
import com.pdftron.reactnative.R;
import com.pdftron.reactnative.nativeviews.RNCollabViewerTabHostFragment;
import com.pdftron.reactnative.nativeviews.RNPdfViewCtrlTabFragment;
import com.pdftron.reactnative.nativeviews.RNPdfViewCtrlTabHostFragment;
import com.pdftron.reactnative.utils.DocumentViewUtilsKt;
import com.pdftron.reactnative.utils.DownloadFileCallback;
import com.pdftron.reactnative.utils.ReactUtils;
import com.pdftron.sdf.Obj;

import org.apache.commons.io.FileUtils;
import org.json.JSONException;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicInteger;

import static com.pdftron.reactnative.utils.Constants.*;

public class DocumentView extends com.pdftron.pdf.controls.DocumentView2 {

    private static final String TAG = DocumentView.class.getSimpleName();

    private String mDocumentPath;
    private String mTabTitle;
    private boolean mIsBase64;
    private String mBase64Extension = ".pdf";
    private String mDocumentExtension;

    private ArrayList<File> mTempFiles = new ArrayList<>();

    private FragmentManager mFragmentManagerSave; // used to deal with lifecycle issue

    private PDFViewCtrlConfig mPDFViewCtrlConfig;
    private ToolManagerBuilder mToolManagerBuilder;
    private ViewerConfig.Builder mBuilder;

    private ArrayList<ToolManager.ToolMode> mDisabledTools = new ArrayList<>();

    private String mExportPath;
    private String mOpenUrlPath;
    private int mInitialPageNumber = -1;

    private boolean mPadStatusBar;

    private boolean mAutoSaveEnabled = true;

    private boolean mUseStylusAsPen = true;
    private boolean mSignWithStamps;

    public boolean isBookmarkListVisible = true;
    public boolean isOutlineListVisible = true;
    public boolean isAnnotationListVisible = true;

    // collab
    private CollabManager mCollabManager;
    private boolean mCollabEnabled;
    private String mCurrentUser;
    private String mCurrentUserName;
    private AnnotManager.EditPermissionMode mAnnotationManagerEditMode = AnnotManager.EditPermissionMode.EDIT_OWN;
    private PDFViewCtrl.AnnotationManagerMode mAnnotationManagerUndoMode = PDFViewCtrl.AnnotationManagerMode.ADMIN_UNDO_OWN;
    private File mCollabTempFile;

    // toolbar buttons
    private ArrayList<Object> mToolbarOverrideButtons;

    // quick menu
    private ArrayList<Object> mAnnotMenuItems;
    private ArrayList<Object> mAnnotMenuOverrideItems;
    private ArrayList<Object> mHideAnnotMenuTools;
    private ArrayList<Object> mLongPressMenuItems;
    private ArrayList<Object> mLongPressMenuOverrideItems;

    // custom behaviour
    private ReadableArray mActionOverrideItems;

    // RN specific behaviour
    private boolean mHideToolbarsOnAppear;

    private boolean mReadOnly;

    private boolean mFragmentTransactionFinished;

    private boolean mSaveStateEnabled = true;

    private boolean mShowAddPageToolbarButton = true;

    // overflow menu icon
    private String mOverflowResName = null;

    // custom tools
    private final SparseArray<String> mToolIdMap = new SparseArray<>();
    private final AtomicInteger mToolIdGenerator = new AtomicInteger(1000);

    private ArrayList<ViewModePickerDialogFragment.ViewModePickerItems> mViewModePickerItems = new ArrayList<>();
    private final RNPdfViewCtrlTabHostFragment.RNHostFragmentListener mRNHostFragmentListener =
            new RNPdfViewCtrlTabHostFragment.RNHostFragmentListener() {
                @Override
                public void onHostFragmentViewCreated() {
                    View fragmentView = mPdfViewCtrlTabHostFragment.getView();
                    if (fragmentView != null) {
                        fragmentView.clearFocus(); // work around issue where somehow new ui obtains focus
                        addView(fragmentView, LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
                    }
                }
            };
    private ArrayList<ThumbnailsViewFragment.ThumbnailsViewEditOptions> mThumbnailViewItems = new ArrayList<>();

    public DocumentView(Context context) {
        super(context);
    }

    public DocumentView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public DocumentView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void setup(ThemedReactContext reactContext) {
        // Must be called in order to properly pass onActivityResult intent to
        // DigitalSignatureDialogFragment
        DigitalSignatureDialogFragment.HANDLE_INTENT_IN_ACTIVITY = true;
        ThumbnailsViewFragment.HANDLE_INTENT_IN_ACTIVITY = true;

        // intercept toast
        CommonToast.CommonToastHandler.getInstance().setCommonToastListener(new CommonToast.CommonToastListener() {
            @Override
            public boolean canShowToast(int res, @Nullable CharSequence charSequence) {
                if (res == R.string.download_finished_message ||
                        res == R.string.document_saved_toast_message ||
                        res == R.string.download_failed_message) {
                    return false;
                }
                return true;
            }
        });

        int width = ViewGroup.LayoutParams.MATCH_PARENT;
        int height = ViewGroup.LayoutParams.MATCH_PARENT;
        ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(width, height);
        setLayoutParams(params);

        Activity currentActivity = reactContext.getCurrentActivity();
        if (currentActivity instanceof AppCompatActivity) {
            FragmentManager fragmentManager = ((AppCompatActivity) reactContext.getCurrentActivity())
                    .getSupportFragmentManager();
            setSupportFragmentManager(fragmentManager);
            mFragmentManagerSave = fragmentManager;
            String cacheDir = currentActivity.getCacheDir().getAbsolutePath();
            mExportPath = cacheDir;
            mOpenUrlPath = cacheDir;
            mPDFViewCtrlConfig = PDFViewCtrlConfig.getDefaultConfig(currentActivity);
        } else {
            throw new IllegalStateException("FragmentActivity required.");
        }

        PdfViewCtrlSettingsManager.setFullScreenMode(currentActivity, false);

        mToolManagerBuilder = ToolManagerBuilder.from()
                .setShowRichContentOption(false)
                .setOpenToolbar(true);
        mBuilder = new ViewerConfig.Builder();
        mBuilder
                .fullscreenModeEnabled(false)
                .multiTabEnabled(false)
                .maximumTabCount(Integer.MAX_VALUE)
                .showCloseTabOption(false)
                .useSupportActionBar(false)
                .showConversionDialog(false)
                .skipReadOnlyCheck(true);
    }

    @Override
    protected PdfViewCtrlTabHostFragment2 getViewer() {
        if (mCollabEnabled) {
            // Create the Fragment using CollabViewerBuilder
            CollabViewerBuilder2 builder2 = CollabViewerBuilder2.withUri(mDocumentUri, mPassword)
                    .usingConfig(mViewerConfig)
                    .usingNavIcon(mShowNavIcon ? mNavIconRes : 0)
                    .usingCustomHeaders(mCustomHeaders)
                    .usingAnnotationManagerEditMode(mAnnotationManagerEditMode)
                    .usingAnnotationManagerUndoMode(mAnnotationManagerUndoMode)
                    .usingTabHostClass(RNCollabViewerTabHostFragment.class);
            if (!Utils.isNullOrEmpty(mTabTitle)) {
                builder2.usingTabTitle(mTabTitle);
            }
            if (!Utils.isNullOrEmpty(mDocumentExtension)) {
                builder2.usingFileExtension(mDocumentExtension);
            }
            return builder2.usingTheme(R.style.RNAppTheme).build(getContext());
        }
        return super.getViewer();
    }

    @Override
    protected void buildViewer() {
        super.buildViewer();
        if (mViewerBuilder != null) {
            mViewerBuilder
                    .usingTabHostClass(RNPdfViewCtrlTabHostFragment.class)
                    .usingTabClass(RNPdfViewCtrlTabFragment.class);
            if (!Utils.isNullOrEmpty(mTabTitle)) {
                mViewerBuilder.usingTabTitle(mTabTitle);
            }
            if (!Utils.isNullOrEmpty(mDocumentExtension)) {
                mViewerBuilder.usingFileExtension(mDocumentExtension);
            }
            mViewerBuilder.usingTheme(R.style.RNAppTheme);
        }
    }

    public void setDocument(String path) {
        if (Utils.isNullOrEmpty(path)) {
            return;
        }
        if (mDocumentPath != null) {
            // we are switching document
            Uri fileUri = ReactUtils.getUri(getContext(), path, mIsBase64, mBase64Extension);

            if (fileUri != null) {
                if (mIsBase64) {
                    mTempFiles.add(new File(fileUri.getPath()));
                }
                setDocumentUri(fileUri);
                setViewerConfig(getConfig());
                prepView();
            }
        }
        mDocumentPath = path;
    }

    public void setNavResName(String resName) {
        setNavIconResName(resName);

        if (mShowNavIcon && mPdfViewCtrlTabHostFragment != null && mPdfViewCtrlTabHostFragment.getToolbar() != null) {
            int res = Utils.getResourceDrawable(this.getContext(), resName);
            if (res != 0) {
                mPdfViewCtrlTabHostFragment.getToolbar().setNavigationIcon(res);
            }
        }
    }

    public void setOverflowResName(String resName) {
        mOverflowResName = resName;
    }

    public void setDisabledElements(ReadableArray array) {
        disableElements(array);
    }

    public void setDisabledTools(ReadableArray array) {
        disableTools(array);
    }

    public void setRememberLastUsedTool(boolean rememberLastUsedTool) {
        mBuilder = mBuilder.rememberLastUsedTool(rememberLastUsedTool);
    }

    public void setCustomHeaders(ReadableMap map) {
        if (null == map) {
            return;
        }
        try {
            mCustomHeaders = ReactUtils.convertMapToJson(map);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    public void setDocumentExtension(String documentExtension) {
        mDocumentExtension = documentExtension;
    }

    public void setInitialPageNumber(int pageNum) {
        mInitialPageNumber = pageNum;
    }

    public void setPageNumber(int pageNumber) {
        if (getPdfViewCtrlTabFragment() != null &&
                getPdfViewCtrlTabFragment().isDocumentReady()) {
            try {
                getPdfViewCtrl().setCurrentPage(pageNumber);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
    }

    public void setTopToolbarEnabled(boolean topToolbarEnabled) {
        mBuilder = mBuilder.showTopToolbar(topToolbarEnabled);
    }

    public void setBottomToolbarEnabled(boolean bottomToolbarEnabled) {
        mBuilder = mBuilder.showBottomToolbar(bottomToolbarEnabled);
    }

    public void bottomToolbar(ReadableArray bottomToolbarItems) {
        BottomBarBuilder customBottomBar = BottomBarBuilder.withTag("CustomBottomBar");

        for (int i = 0; i < bottomToolbarItems.size(); i++) {
            String item = bottomToolbarItems.getString(i);

            if (BUTTON_THUMBNAILS.equals(item)) {
                customBottomBar.addCustomButton(R.string.pref_viewmode_thumbnails, R.drawable.ic_thumbnails_grid_black_24dp, R.id.action_thumbnails);
            } else if (BUTTON_LISTS.equals(item)) {
                customBottomBar.addCustomButton(R.string.action_outline, R.drawable.ic_outline_white_24dp, R.id.action_outline);
            } else if (BUTTON_SHARE.equals(item)) {
                customBottomBar.addCustomButton(R.string.action_file_share, R.drawable.ic_share_black_24dp, R.id.action_share);
            } else if (BUTTON_VIEW_CONTROLS.equals(item)) {
                customBottomBar.addCustomButton(R.string.action_view_mode, R.drawable.ic_viewing_mode_white_24dp, R.id.action_viewmode);
            } else if (BUTTON_SEARCH.equals(item)) {
                customBottomBar.addCustomButton(R.string.action_search, R.drawable.ic_search_white_24dp, R.id.action_search);
            } else if (BUTTON_REFLOW.equals(item)) {
                customBottomBar.addCustomButton(R.string.pref_viewmode_reflow, R.drawable.ic_view_mode_reflow_black_24dp, R.id.action_reflow_mode);
            }
        }

        mBuilder.bottomBarBuilder(customBottomBar);
    }

    public void setDocumentSliderEnabled(boolean documentSliderEnabled) {
        mBuilder = mBuilder.showDocumentSlider(documentSliderEnabled);
    }

    public void setDownloadDialogEnabled(boolean downloadDialogEnabled) {
        mBuilder = mBuilder.showDownloadDialog(downloadDialogEnabled);
    }

    public void setPageIndicatorEnabled(boolean pageIndicatorEnabled) {
        mBuilder = mBuilder.showPageNumberIndicator(pageIndicatorEnabled);
    }

    public void setHideToolbarsOnTap(boolean hideToolbarsOnTap) {
        mBuilder = mBuilder.permanentToolbars(!hideToolbarsOnTap);
    }

    public void setTabletLayoutEnabled(boolean tabletLayoutEnabled) {
        mBuilder = mBuilder.tabletLayoutEnabled(tabletLayoutEnabled);
    }

    public void setReadOnly(boolean readOnly) {
        mReadOnly = readOnly;
        if (readOnly) {
            mBuilder = mBuilder.skipReadOnlyCheck(false)
                    .documentEditingEnabled(false);
        } else {
            mBuilder = mBuilder.skipReadOnlyCheck(true)
                    .documentEditingEnabled(true);
        }
        if (getToolManager() != null) {
            getToolManager().setSkipReadOnlyCheck(false);
            getToolManager().setReadOnly(readOnly);
        }
    }

    public void setFitMode(String fitMode) {
        PDFViewCtrl.PageViewMode mode = null;
        if (FIT_MODE_FIT_PAGE.equals(fitMode)) {
            mode = PDFViewCtrl.PageViewMode.FIT_PAGE;
        } else if (FIT_MODE_FIT_WIDTH.equals(fitMode)) {
            mode = PDFViewCtrl.PageViewMode.FIT_WIDTH;
        } else if (FIT_MODE_FIT_HEIGHT.equals(fitMode)) {
            mode = PDFViewCtrl.PageViewMode.FIT_HEIGHT;
        } else if (FIT_MODE_ZOOM.equals(fitMode)) {
            mode = PDFViewCtrl.PageViewMode.ZOOM;
        }
        if (mode != null) {
            if (getPdfViewCtrl() != null) {
                getPdfViewCtrl().setPageViewMode(mode);
            } else if (mPDFViewCtrlConfig != null) {
                mPDFViewCtrlConfig.setPageViewMode(mode);
            }
        }
    }

    public void setFitPolicy(int fitPolicy) {
        PDFViewCtrl.PageViewMode mode = null;
        switch (fitPolicy) {
            case 1:
                mode = PDFViewCtrl.PageViewMode.FIT_WIDTH;
                break;
            case 2:
                mode = PDFViewCtrl.PageViewMode.FIT_HEIGHT;
            case 0:
            default:
                mode = PDFViewCtrl.PageViewMode.FIT_PAGE;
        }
        if (mode != null) {
            if (getPdfViewCtrl() != null) {
                getPdfViewCtrl().setPageViewMode(mode);
            } else if (mPDFViewCtrlConfig != null) {
                mPDFViewCtrlConfig.setPageViewMode(mode);
            }
        }
    }

    public void setMaintainZoomEnabled(boolean maintainZoomEnabled) {
        if (getPdfViewCtrl() != null) {
            try {
                getPdfViewCtrl().setMaintainZoomEnabled(maintainZoomEnabled);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } else if (mPDFViewCtrlConfig != null) {
            mPDFViewCtrlConfig.setMaintainZoomEnabled(maintainZoomEnabled);
        }
    }

    public void setLayoutMode(String layoutMode) {
        String mode = null;
        PDFViewCtrl.PagePresentationMode presentationMode = null;

        if (LAYOUT_MODE_SINGLE.equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_SINGLEPAGE_VALUE;
            presentationMode = PDFViewCtrl.PagePresentationMode.SINGLE;
        } else if (LAYOUT_MODE_CONTINUOUS.equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_CONTINUOUS_VALUE;
            presentationMode = PDFViewCtrl.PagePresentationMode.SINGLE_CONT;
        } else if (LAYOUT_MODE_FACING.equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACING_VALUE;
            presentationMode = PDFViewCtrl.PagePresentationMode.FACING;
        } else if (LAYOUT_MODE_FACING_CONTINUOUS.equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACING_CONT_VALUE;
            presentationMode = PDFViewCtrl.PagePresentationMode.FACING_CONT;
        } else if (LAYOUT_MODE_FACING_COVER.equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACINGCOVER_VALUE;
            presentationMode = PDFViewCtrl.PagePresentationMode.FACING_COVER;
        } else if (LAYOUT_MODE_FACING_COVER_CONTINUOUS.equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACINGCOVER_CONT_VALUE;
            presentationMode = PDFViewCtrl.PagePresentationMode.FACING_COVER_CONT;
        }
        Context context = getContext();
        if (mode != null && context != null && presentationMode != null) {
            PdfViewCtrlSettingsManager.updateViewMode(context, mode);
            if (getPdfViewCtrl() != null) {
                getPdfViewCtrl().setPagePresentationMode(presentationMode);
            }
        }
    }

    public void setPadStatusBar(boolean padStatusBar) {
        mPadStatusBar = padStatusBar;
    }

    public void setContinuousAnnotationEditing(boolean contEditing) {
        Context context = getContext();
        if (context != null) {
            PdfViewCtrlSettingsManager.setContinuousAnnotationEdit(context, contEditing);
        }
    }

    public void setStoreNewSignature(boolean storeNewSignature) {
        mToolManagerBuilder.setDefaultStoreNewSignature(storeNewSignature).setPersistStoreSignatureSetting(false);
    }

    public void setDisableEditingByAnnotationType(ReadableArray annotationTypes) {
        int[] annotTypes = new int[annotationTypes.size()];
        for (int i = 0; i < annotationTypes.size(); i++) {
            String item = annotationTypes.getString(i);
            annotTypes[i] = convStringToAnnotType(item);
        }

        if (annotTypes.length > 0) {
            mToolManagerBuilder = mToolManagerBuilder.disableAnnotEditing(annotTypes);
        }
    }

    public void setAnnotationAuthor(String author) {
        Context context = getContext();
        if (context != null && !Utils.isNullOrEmpty(author)) {
            PdfViewCtrlSettingsManager.updateAuthorName(context, author);
            PdfViewCtrlSettingsManager.setAnnotListShowAuthor(context, true);
        }
    }

    public void setShowSavedSignatures(boolean showSavedSignatures) {
        mToolManagerBuilder = mToolManagerBuilder.setShowSavedSignatures(showSavedSignatures);
    }

    public void setIsBase64String(boolean isBase64String) {
        mIsBase64 = isBase64String;
    }

    public void setBase64FileExtension(String base64Extension) {
        mBase64Extension = base64Extension;
    }

    public void setAutoSaveEnabled(boolean autoSaveEnabled) {
        mAutoSaveEnabled = autoSaveEnabled;
    }

    public void setUseStylusAsPen(boolean useStylusAsPen) {
        mUseStylusAsPen = useStylusAsPen;
    }

    public void setCollabEnabled(boolean collabEnabled) {
        mCollabEnabled = collabEnabled;
    }

    public void setCurrentUser(String currentUser) {
        mCurrentUser = currentUser;
    }

    public void setCurrentUserName(String currentUserName) {
        mCurrentUserName = currentUserName;
    }

    public void setAnnotationManagerEditMode(String annotationManagerEditMode) {
        if (KEY_ANNOTATION_MANAGER_EDIT_MODE_ALL.equals(annotationManagerEditMode)) {
            mAnnotationManagerEditMode = AnnotManager.EditPermissionMode.EDIT_OTHERS;
        } else {
            mAnnotationManagerEditMode = AnnotManager.EditPermissionMode.EDIT_OWN;
        }
    }

    public void setAnnotationManagerUndoMode(String annotationManagerUndoMode) {
        if (KEY_ANNOTATION_MANAGER_UNDO_MODE_ALL.equals(annotationManagerUndoMode)) {
            mAnnotationManagerUndoMode = PDFViewCtrl.AnnotationManagerMode.ADMIN_UNDO_OTHERS;
        } else {
            mAnnotationManagerUndoMode = PDFViewCtrl.AnnotationManagerMode.ADMIN_UNDO_OWN;
        }
    }

    public void setReplyReviewStateEnabled(boolean replyReviewStateEnabled) {
        mBuilder = mBuilder.showAnnotationReplyReviewState(replyReviewStateEnabled);
    }

    public void setTopAppNavBarRightBar(ReadableArray menus) {
        ArrayList<TopToolbarMenuId> menuIdArrayList = new ArrayList<>();
        for (int i = 0; i < menus.size(); i++) {
            String button = menus.getString(i);
            TopToolbarMenuId id = convButtonIdToMenuId(button);
            if (id != null) {
                menuIdArrayList.add(id);
            }
        }
        mBuilder = mBuilder.topToolbarMenuIds(menuIdArrayList.toArray(new TopToolbarMenuId[0]));
    }

    public void setAnnotationMenuItems(ReadableArray items) {
        mAnnotMenuItems = items != null ? items.toArrayList() : null;
    }

    public void setHideAnnotationMenu(ReadableArray tools) {
        mHideAnnotMenuTools = tools != null ? tools.toArrayList() : null;
    }

    public void setLongPressMenuItems(ReadableArray items) {
        mLongPressMenuItems = items != null ? items.toArrayList() : null;
    }

    public void setLongPressMenuEnabled(boolean longPressMenuEnabled) {
        mToolManagerBuilder = mToolManagerBuilder.setDisableQuickMenu(!longPressMenuEnabled);
    }

    public void setDefaultEraserType(String eraserType) {
        if (ANNOTATION_ERASER.equals(eraserType)) {
            mToolManagerBuilder = mToolManagerBuilder.setEraserType(Eraser.EraserType.ANNOTATION_ERASER);
        } else if (HYBRID_ERASER.equals(eraserType)) {
            mToolManagerBuilder = mToolManagerBuilder.setEraserType(Eraser.EraserType.HYBRID_ERASER);
        } else if (INK_ERASER.equals(eraserType)) {
            mToolManagerBuilder = mToolManagerBuilder.setEraserType(Eraser.EraserType.INK_ERASER);
        }
    }

    public void setPageChangeOnTap(boolean pageChangeOnTap) {
        Context context = getContext();
        if (context != null) {
            PdfViewCtrlSettingsManager.setAllowPageChangeOnTap(context, pageChangeOnTap);
        }
    }

    public void setMultiTabEnabled(boolean multiTab) {
        mBuilder = mBuilder.multiTabEnabled(multiTab);
    }

    public void setTabTitle(String tabTitle) {
        mTabTitle = tabTitle;
    }

    public void setMaxTabCount(int maxTabCount) {
        mBuilder = mBuilder.maximumTabCount(maxTabCount);
    }

    public void setThumbnailViewEditingEnabled(boolean thumbnailViewEditingEnabled) {
        mBuilder = mBuilder.thumbnailViewEditingEnabled(thumbnailViewEditingEnabled);
    }

    public void setAnnotationsListEditingEnabled(boolean annotationsListEditingEnabled) {
        mBuilder = mBuilder.annotationsListEditingEnabled(annotationsListEditingEnabled);
    }

    public void setUserBookmarksListEditingEnabled(boolean userBookmarksListEditingEnabled) {
        mBuilder = mBuilder.userBookmarksListEditingEnabled(userBookmarksListEditingEnabled);
    }

    public void setExcludedAnnotationListTypes(ReadableArray excludedTypes) {
        int[] annotTypes = new int[excludedTypes.size()];
        for (int i = 0; i < excludedTypes.size(); i++) {
            String type = excludedTypes.getString(i);
            annotTypes[i] = convStringToAnnotType(type);
        }

        mBuilder = mBuilder.excludeAnnotationListTypes(annotTypes);
    }

    public void setImageInReflowEnabled(boolean imageInReflowEnabled) {
        mBuilder = mBuilder.imageInReflowEnabled(imageInReflowEnabled);
    }

    public void setReflowOrientation(String reflowOrientation) {
        int orientation = ReflowControl.HORIZONTAL;
        if (KEY_REFLOW_ORIENTATION_VERTICAL.equals(reflowOrientation)) {
            orientation = ReflowControl.VERTICAL;
        }
        mBuilder = mBuilder.reflowOrientation(orientation);
    }

    public void setSelectAnnotationAfterCreation(boolean selectAnnotationAfterCreation) {
        mToolManagerBuilder = mToolManagerBuilder.setAutoSelect(selectAnnotationAfterCreation);
    }

    public void setOverrideAnnotationMenuBehavior(ReadableArray items) {
        mAnnotMenuOverrideItems = items != null ? items.toArrayList() : null;
    }

    public void setOverrideLongPressMenuBehavior(ReadableArray items) {
        mLongPressMenuOverrideItems = items != null ? items.toArrayList() : null;
    }

    public void setOverrideBehavior(@NonNull ReadableArray items) {
        mActionOverrideItems = items;
        if (!mCollabEnabled && getToolManager() != null) {
            getToolManager().setStickyNoteShowPopup(!isOverrideAction(KEY_CONFIG_STICKY_NOTE_SHOW_POP_UP));
        }
    }

    public void setOverrideToolbarButtonBehavior(ReadableArray items) {
        mToolbarOverrideButtons = items != null ? items.toArrayList() : null;
    }

    public void setSignSignatureFieldsWithStamps(boolean signWithStamps) {
        mSignWithStamps = signWithStamps;
    }

    public void setExportPath(String exportPath) {
        mExportPath = exportPath;
    }

    public void setOpenUrlPath(String openUrlPath) {
        mOpenUrlPath = openUrlPath;
    }

    public void setAnnotationPermissionCheckEnabled(boolean annotPermissionCheckEnabled) {
        mToolManagerBuilder = mToolManagerBuilder.setAnnotPermission(annotPermissionCheckEnabled);
    }

    public void setInitialToolbar(String toolbarTag) {
        mBuilder.initialToolbarTag(toolbarTag).rememberLastUsedToolbar(false);
    }

    public void setCurrentToolbar(String toolbarTag) {
        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.openToolbarWithTag(toolbarTag);
        }
    }

    // Hygen Generated Props
    public void setForceAppTheme(String forcedAppThemeItems) {
        if (THEME_DARK.equals(forcedAppThemeItems)) {
            PdfViewCtrlSettingsManager.setColorMode(getContext(), PdfViewCtrlSettingsManager.KEY_PREF_COLOR_MODE_NIGHT);
        } else if (THEME_LIGHT.equals(forcedAppThemeItems)) {
            PdfViewCtrlSettingsManager.setColorMode(getContext(), PdfViewCtrlSettingsManager.KEY_PREF_COLOR_MODE_NORMAL);
        }
    }

    public void setSignatureColors(@NonNull ReadableArray signatureColors) {
        int[] result = new int[signatureColors.size()];

        for (int i = 0; i < signatureColors.size(); i++) {
            ReadableType type = signatureColors.getType(i);

            if (type == ReadableType.Map) {
                ReadableMap map = signatureColors.getMap(i);

                int red = map.getInt(COLOR_RED);
                int green = map.getInt(COLOR_GREEN);
                int blue = map.getInt(COLOR_BLUE);

                result[i] = Color.rgb(red, green, blue);
            }
        }

        mToolManagerBuilder = mToolManagerBuilder.setSignatureColors(result);
    }

    public void setAnnotationToolbars(ReadableArray toolbars) {
        if (toolbars.size() == 0) {
            if (mPdfViewCtrlTabHostFragment != null) {
                mPdfViewCtrlTabHostFragment.setAnnotationToolbars(new ArrayList<>());
            } else {
                // turn back to view toolbar and hide the switcher to achieve the same effect
                mBuilder = mBuilder
                        .initialToolbarTag(DefaultToolbars.TAG_VIEW_TOOLBAR)
                        .rememberLastUsedToolbar(false)
                        .showToolbarSwitcher(false);
            }
            return;
        }
        ArrayList<AnnotationToolbarBuilder> annotationToolbarBuilders = new ArrayList<>();
        for (int i = 0; i < toolbars.size(); i++) {
            ReadableType type = toolbars.getType(i);
            if (type == ReadableType.String) {
                String tag = toolbars.getString(i);
                if (isValidToolbarTag(tag)) {
                    AnnotationToolbarBuilder toolbarBuilder = DefaultToolbars
                            .getDefaultAnnotationToolbarBuilderByTag(tag);
                    mBuilder = mBuilder.addToolbarBuilder(toolbarBuilder);
                    annotationToolbarBuilders.add(toolbarBuilder);
                }
            } else if (type == ReadableType.Map) {
                // custom toolbars
                ReadableMap map = toolbars.getMap(i);
                ReadableMapKeySetIterator iterator = map.keySetIterator();
                String tag = null, toolbarName = null, toolbarIcon = null;
                ReadableArray toolbarItems = null;
                while (iterator.hasNextKey()) {
                    String toolbarKey = iterator.nextKey();
                    if (TOOLBAR_KEY_ID.equals(toolbarKey)) {
                        tag = map.getString(toolbarKey);
                    } else if (TOOLBAR_KEY_NAME.equals(toolbarKey)) {
                        toolbarName = map.getString(toolbarKey);
                    } else if (TOOLBAR_KEY_ICON.equals(toolbarKey)) {
                        toolbarIcon = map.getString(toolbarKey);
                    } else if (TOOLBAR_KEY_ITEMS.equals(toolbarKey)) {
                        toolbarItems = map.getArray(toolbarKey);
                    }
                }
                if (!Utils.isNullOrEmpty(tag) && toolbarName != null &&
                        toolbarItems != null && toolbarItems.size() > 0) {
                    AnnotationToolbarBuilder toolbarBuilder = AnnotationToolbarBuilder.withTag(tag)
                            .setToolbarName(toolbarName)
                            .setIcon(convStringToToolbarDefaultIconRes(toolbarIcon));
                    boolean saveItemOrder = false;
                    for (int j = 0; j < toolbarItems.size(); j++) {
                        ReadableType itemType = toolbarItems.getType(j);
                        if (itemType == ReadableType.String) {
                            String toolStr = toolbarItems.getString(j);
                            ToolbarButtonType buttonType = convStringToToolbarType(toolStr);
                            int buttonId = convStringToButtonId(toolStr);
                            if (buttonType != null && buttonId != 0) {
                                if (buttonType == ToolbarButtonType.UNDO ||
                                        buttonType == ToolbarButtonType.REDO) {
                                    toolbarBuilder.addToolStickyButton(buttonType, buttonId);
                                } else {
                                    if (buttonType == ToolbarButtonType.EDIT_TOOLBAR) {
                                        // if user allow toolbar customization, then allow save order
                                        saveItemOrder = true;
                                    }
                                    toolbarBuilder.addToolButton(buttonType, buttonId);
                                }
                            }
                        } else if (itemType == ReadableType.Map) {
                            // custom buttons
                            ReadableMap itemMap = toolbarItems.getMap(j);
                            ReadableMapKeySetIterator itemIterator = itemMap.keySetIterator();
                            String itemId = null, itemName = null, itemIcon = null;
                            while (itemIterator.hasNextKey()) {
                                String toolbarKey = itemIterator.nextKey();
                                if (TOOLBAR_ITEM_KEY_ID.equals(toolbarKey)) {
                                    itemId = itemMap.getString(toolbarKey);
                                } else if (TOOLBAR_ITEM_KEY_NAME.equals(toolbarKey)) {
                                    itemName = itemMap.getString(toolbarKey);
                                } else if (TOOLBAR_ITEM_KEY_ICON.equals(toolbarKey)) {
                                    itemIcon = itemMap.getString(toolbarKey);
                                }
                            }
                            if (!Utils.isNullOrEmpty(itemId) && itemName != null && !Utils.isNullOrEmpty(itemIcon)) {
                                int res = Utils.getResourceDrawable(this.getContext(), itemIcon);
                                if (res != 0) {
                                    int id = mToolIdGenerator.getAndIncrement();
                                    mToolIdMap.put(id, itemId);
                                    toolbarBuilder.addCustomButton(itemName, res, id);
                                }
                            }
                        }
                    }
                    // SDK Support Issue 22893
                    // To ensure if the client changes the order of the annotation tools that the UI will reflect the changed state
                    mBuilder = mBuilder.addToolbarBuilder(toolbarBuilder).saveToolbarItemOrder(saveItemOrder);
                    annotationToolbarBuilders.add(toolbarBuilder);
                }
            }
        }
        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.setAnnotationToolbars(annotationToolbarBuilders);
        }
    }

    private boolean isValidToolbarTag(String tag) {
        if (tag != null) {
            if (TAG_VIEW_TOOLBAR.equals(tag) ||
                    TAG_ANNOTATE_TOOLBAR.equals(tag) ||
                    TAG_DRAW_TOOLBAR.equals(tag) ||
                    TAG_INSERT_TOOLBAR.equals(tag) ||
                    TAG_FILL_AND_SIGN_TOOLBAR.equals(tag) ||
                    TAG_PREPARE_FORM_TOOLBAR.equals(tag) ||
                    TAG_MEASURE_TOOLBAR.equals(tag) ||
                    TAG_PENS_TOOLBAR.equals(tag) ||
                    TAG_REDACTION_TOOLBAR.equals(tag) ||
                    TAG_FAVORITE_TOOLBAR.equals(tag)) {
                return true;
            }
        }
        return false;
    }

    public void setHideDefaultAnnotationToolbars(ReadableArray tags) {
        ArrayList<String> tagList = new ArrayList<>();
        for (int i = 0; i < tags.size(); i++) {
            String tag = tags.getString(i);
            if (!Utils.isNullOrEmpty(tag)) {
                tagList.add(tag);
            }
        }
        mBuilder = mBuilder.hideToolbars(tagList.toArray(new String[tagList.size()]));
    }

    public void setHideAnnotationToolbarSwitcher(boolean hideToolbarSwitcher) {
        mBuilder = mBuilder.showToolbarSwitcher(!hideToolbarSwitcher);

        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.setToolbarSwitcherVisible(!hideToolbarSwitcher);
        }
    }

    public void setHideTopToolbars(boolean hideTopToolbars) {
        mBuilder = mBuilder.showAppBar(!hideTopToolbars);
    }

    public void setHideTopAppNavBar(boolean hideTopAppNavBar) {
        mBuilder = mBuilder.showTopToolbar(!hideTopAppNavBar);
    }

    public void setHideThumbnailFilterModes(ReadableArray filterModes) {
        ArrayList<ThumbnailsViewFragment.FilterModes> hideList = new ArrayList<>();

        for (int i = 0; i < filterModes.size(); i++) {
            String mode = filterModes.getString(i);
            if (THUMBNAIL_FILTER_MODE_ANNOTATED.equals(mode)) {
                hideList.add(ThumbnailsViewFragment.FilterModes.ANNOTATED);
            } else if (THUMBNAIL_FILTER_MODE_BOOKMARKED.equals(mode)) {
                hideList.add(ThumbnailsViewFragment.FilterModes.BOOKMARKED);
            }
        }

        mBuilder.hideThumbnailFilterModes(hideList.toArray(new ThumbnailsViewFragment.FilterModes[0]));
    }

    public void viewModePickerItems(ReadableArray viewModePickerItems) {
        for (int i = 0; i < viewModePickerItems.size(); i++) {
            String mode = viewModePickerItems.getString(i);
            if (VIEW_MODE_CROP.equals(mode)) {
                mViewModePickerItems.add(ViewModePickerDialogFragment.ViewModePickerItems.ITEM_ID_USERCROP);
            } else if (VIEW_MODE_ROTATION.equals(mode)) {
                mViewModePickerItems.add(ViewModePickerDialogFragment.ViewModePickerItems.ITEM_ID_ROTATION);
            } else if (VIEW_MODE_COLORMODE.equals(mode)) {
                mViewModePickerItems.add(ViewModePickerDialogFragment.ViewModePickerItems.ITEM_ID_COLORMODE);
            } else if (VIEW_MODE_READER_MODE_SETTINGS.equals(mode)) {
                mViewModePickerItems.add(ViewModePickerDialogFragment.ViewModePickerItems.ITEM_ID_READING_MODE);
            }
        }
    }

    public void setHideThumbnailsViewItems(ReadableArray thumbnailViewItems) {
        for (int i = 0; i < thumbnailViewItems.size(); i++) {
            String viewItem = thumbnailViewItems.getString(i);
            if (THUMBNAIL_DELETE_PAGES.equals(viewItem)) {
                mThumbnailViewItems.add(ThumbnailsViewFragment.ThumbnailsViewEditOptions.OPTION_DELETE_PAGES);
            } else if (THUMBNAIL_DUPLICATE_PAGES.equals(viewItem)) {
                mThumbnailViewItems.add(ThumbnailsViewFragment.ThumbnailsViewEditOptions.OPTION_DUPLICATE_PAGES);
            } else if (THUMBNAIL_EXPORT_PAGES.equals(viewItem)) {
                mThumbnailViewItems.add(ThumbnailsViewFragment.ThumbnailsViewEditOptions.OPTION_EXPORT_PAGES);
            } else if (THUMBNAIL_INSERT_PAGES.equals(viewItem)) {
                mThumbnailViewItems.add(ThumbnailsViewFragment.ThumbnailsViewEditOptions.OPTION_INSERT_PAGES);
            } else if (THUMBNAIL_ROTATE_PAGES.equals(viewItem)) {
                mThumbnailViewItems.add(ThumbnailsViewFragment.ThumbnailsViewEditOptions.OPTION_ROTATE_PAGES);
            } else if (THUMBNAIL_INSERT_FROM_IMAGE.equals(viewItem)) {
                mThumbnailViewItems.add(ThumbnailsViewFragment.ThumbnailsViewEditOptions.OPTION_INSERT_FROM_IMAGE);
            } else if (THUMBNAIL_INSERT_FROM_DOCUMENT.equals(viewItem)) {
                mThumbnailViewItems.add(ThumbnailsViewFragment.ThumbnailsViewEditOptions.OPTION_INSERT_FROM_DOCUMENT);
            }
        }
    }

    public void setZoom(double zoom) {
        if (getPdfViewCtrlTabFragment() != null &&
                getPdfViewCtrlTabFragment().isDocumentReady()) {
            getPdfViewCtrl().setZoom(zoom);
        }
    }

    public void setAntiAliasing(boolean enableAntialiasing) throws PDFNetException {
        if (getPdfViewCtrl() != null) {
            try {
                getPdfViewCtrl().setAntiAliasing(enableAntialiasing);
            } catch (PDFNetException ex) {
                ex.printStackTrace();
            }
        }
    }

    public void setZoomLimits(String zoomLimitMode, double minimum, double maximum) {
        if (getPdfViewCtrl() != null) {

            PDFViewCtrl.ZoomLimitMode limitMode = null;

            switch (zoomLimitMode) {
                case KEY_zoomLimitAbsolute:
                    limitMode = PDFViewCtrl.ZoomLimitMode.ABSOLUTE;
                    break;
                case KEY_zoomLimitRelative:
                    limitMode = PDFViewCtrl.ZoomLimitMode.RELATIVE;
                    break;
                case KEY_zoomLimitNone:
                    limitMode = PDFViewCtrl.ZoomLimitMode.NONE;
                    break;
            }

            if (limitMode != null) {
                try {
                    getPdfViewCtrl().setZoomLimits(limitMode, minimum, maximum);
                } catch (PDFNetException ex) {
                    ex.printStackTrace();
                }
            }
        }
    }

    public void zoomWithCenter(double zoom, int x, int y) {
        if (getPdfViewCtrl() != null) {
            getPdfViewCtrl().setZoom(x, y, zoom);
        }
    }

    public void zoomToRect(int pageNumber, ReadableMap rectMap) {
        if (getPdfViewCtrl() != null) {
            try {
                if (rectMap != null && rectMap.hasKey(KEY_X1) && rectMap.hasKey(KEY_Y1) &&
                        rectMap.hasKey(KEY_X2) && rectMap.hasKey(KEY_Y2)) {
                    double rectX1 = rectMap.getDouble(KEY_X1);
                    double rectY1 = rectMap.getDouble(KEY_Y1);
                    double rectX2 = rectMap.getDouble(KEY_X2);
                    double rectY2 = rectMap.getDouble(KEY_Y2);
                    com.pdftron.pdf.Rect rect = new com.pdftron.pdf.Rect(rectX1, rectY1, rectX2, rectY2);
                    getPdfViewCtrl().showRect(pageNumber, rect);
                }
            } catch (PDFNetException ex) {
                ex.printStackTrace();
            }
        }
    }

    public void smartZoom(int x, int y, boolean animated) {
        if (getPdfViewCtrl() != null) {
            getPdfViewCtrl().smartZoom(x, y, animated);
        }
    }

    public void setHorizontalScrollPos(double horizontalScrollPos) {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        if (pdfViewCtrl != null) {
            pdfViewCtrl.setHScrollPos((int) (horizontalScrollPos + 0.5));
        }
    }

    public void setVerticalScrollPos(double verticalScrollPos) {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        if (pdfViewCtrl != null) {
            pdfViewCtrl.setVScrollPos((int) (verticalScrollPos + 0.5));
        }
    }

    public void setPageStackEnabled(boolean pageStackEnabled) {
        mBuilder = mBuilder.pageStackEnabled(pageStackEnabled);
    }

    public void setHideToolbarsOnAppear(boolean hideToolbarsOnAppear) {
        mHideToolbarsOnAppear = hideToolbarsOnAppear;
    }

    public void setShowQuickNavigationButton(boolean showQuickNavigationButton) {
        mBuilder = mBuilder.pageStackEnabled(showQuickNavigationButton);
    }

    public void setPhotoPickerEnabled(boolean photoPickerEnabled) {
        mToolManagerBuilder = mToolManagerBuilder.setShowSignatureFromImage(photoPickerEnabled);
    }

    public void setAutoResizeFreeTextEnabled(boolean autoResizeFreeTextEnabled) {
        mToolManagerBuilder = mToolManagerBuilder.setAutoResizeFreeText(autoResizeFreeTextEnabled);
    }

    public void setHidePresetBar(boolean hidePresetBar) {
        mBuilder = mBuilder.hidePresetBar(hidePresetBar);
    }

    public void setShowNavigationListAsSidePanelOnLargeDevices(boolean showNavigationListAsSidePanelOnLargeDevices) {
        mBuilder = mBuilder.navigationListAsSheetOnLargeDevice(showNavigationListAsSidePanelOnLargeDevices);
    }

    private void disableElements(ReadableArray args) {
        ArrayList<Integer> saveCopyOptions = new ArrayList<>();

        for (int i = 0; i < args.size(); i++) {
            String item = args.getString(i);
            if (BUTTON_TOOLS.equals(item)) {
                mBuilder = mBuilder.showAnnotationToolbarOption(false);
            } else if (BUTTON_SEARCH.equals(item)) {
                mBuilder = mBuilder.showSearchView(false);
            } else if (BUTTON_SHARE.equals(item)) {
                mBuilder = mBuilder.showShareOption(false);
            } else if (BUTTON_VIEW_CONTROLS.equals(item)) {
                mBuilder = mBuilder.showDocumentSettingsOption(false);
            } else if (BUTTON_THUMBNAILS.equals(item)) {
                mBuilder = mBuilder.showThumbnailView(false);
            } else if (BUTTON_LISTS.equals(item)) {
                mBuilder = mBuilder
                        .showAnnotationsList(false)
                        .showOutlineList(false)
                        .showUserBookmarksList(false);
                isBookmarkListVisible = false;
                isOutlineListVisible = false;
                isAnnotationListVisible = false;
            } else if (BUTTON_THUMBNAIL_SLIDER.equals(item)) {
                mBuilder = mBuilder.showBottomNavBar(false);
            } else if (BUTTON_VIEW_LAYERS.equals(item)) {
                mBuilder = mBuilder.showViewLayersToolbarOption(false);
            } else if (BUTTON_EDIT_PAGES.equals(item)) {
                mBuilder = mBuilder.showEditPagesOption(false);
                mShowAddPageToolbarButton = false;
            } else if (BUTTON_DIGITAL_SIGNATURE.equals(item)) {
                mBuilder = mBuilder.showDigitalSignaturesOption(false);
            } else if (BUTTON_PRINT.equals(item)) {
                mBuilder = mBuilder.showPrintOption(false);
            } else if (BUTTON_CLOSE.equals(item)) {
                mBuilder = mBuilder.showCloseTabOption(false);
            } else if (BUTTON_SAVE_COPY.equals(item)) {
                mBuilder = mBuilder.showSaveCopyOption(false);
            } else if (BUTTON_FORM_TOOLS.equals(item)) {
                mBuilder = mBuilder.showFormToolbarOption(false);
            } else if (BUTTON_FILL_SIGN_TOOLS.equals(item)) {
                mBuilder = mBuilder.showFillAndSignToolbarOption(false);
            } else if (BUTTON_MORE_ITEMS.equals(item)) {
                mBuilder = mBuilder
                        .showEditPagesOption(false)
                        .showPrintOption(false)
                        .showCloseTabOption(false)
                        .showSaveCopyOption(false)
                        .showFormToolbarOption(false)
                        .showFillAndSignToolbarOption(false)
                        .showEditMenuOption(false)
                        .showReflowOption(false);
            } else if (BUTTON_OUTLINE_LIST.equals(item)) {
                mBuilder = mBuilder.showOutlineList(false);
                isOutlineListVisible = false;
            } else if (BUTTON_ANNOTATION_LIST.equals(item)) {
                mBuilder = mBuilder.showAnnotationsList(false);
                isAnnotationListVisible = false;
            } else if (BUTTON_USER_BOOKMARK_LIST.equals(item)) {
                mBuilder = mBuilder.showUserBookmarksList(false);
                isBookmarkListVisible = false;
            } else if (BUTTON_REFLOW.equals(item)) {
                mBuilder = mBuilder.showReflowOption(false);
                mViewModePickerItems.add(ViewModePickerDialogFragment.ViewModePickerItems.ITEM_ID_REFLOW);
            } else if (BUTTON_EDIT_MENU.equals(item)) {
                mBuilder = mBuilder.showEditMenuOption(false);
            } else if (BUTTON_CROP_PAGE.equals(item)) {
                mViewModePickerItems.add(ViewModePickerDialogFragment.ViewModePickerItems.ITEM_ID_USERCROP);
            } else if (BUTTON_SAVE_IDENTICAL_COPY.equals(item)) {
                saveCopyOptions.add(R.id.menu_export_copy);
            } else if (BUTTON_SAVE_FLATTENED_COPY.equals(item)) {
                saveCopyOptions.add(R.id.menu_export_flattened_copy);
            } else if (BUTTON_SAVE_REDUCED_COPY.equals(item)) {
                saveCopyOptions.add(R.id.menu_export_optimized_copy);
            } else if (BUTTON_SAVE_CROPPED_COPY.equals(item)) {
                saveCopyOptions.add(R.id.menu_export_cropped_copy);
            } else if (BUTTON_SAVE_PASSWORD_COPY.equals(item)) {
                saveCopyOptions.add(R.id.menu_export_password_copy);
            }
        }

        if (!saveCopyOptions.isEmpty()) {
            int[] modes = new int[saveCopyOptions.size()];
            for (int j = 0; j < modes.length; j++) {
                modes[j] = saveCopyOptions.get(j);
            }
            mBuilder.hideSaveCopyOptions(modes);
        }

        disableTools(args);
    }

    private void disableTools(ReadableArray args) {
        for (int i = 0; i < args.size(); i++) {
            String item = args.getString(i);
            if (TOOL_BUTTON_ADD_PAGE.equals(item) ||
                    TOOL_BUTTON_INSERT_PAGE.equals(item) ||
                    TOOL_INSERT_PAGE.equals(item)) {
                mShowAddPageToolbarButton = false;
            }
            ToolManager.ToolMode mode = convStringToToolMode(item);
            if (mode != null) {
                mDisabledTools.add(mode);
            }
        }
    }

    @Nullable
    private int convStringToAnnotType(String item) {
        int annotType = Annot.e_Unknown;
        if (TOOL_BUTTON_FREE_HAND.equals(item) || TOOL_ANNOTATION_CREATE_FREE_HAND.equals(item)) {
            annotType = Annot.e_Ink;
        } else if (TOOL_BUTTON_HIGHLIGHT.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_HIGHLIGHT.equals(item)) {
            annotType = Annot.e_Highlight;
        } else if (TOOL_BUTTON_UNDERLINE.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_UNDERLINE.equals(item)) {
            annotType = Annot.e_Underline;
        } else if (TOOL_BUTTON_SQUIGGLY.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_SQUIGGLY.equals(item)) {
            annotType = Annot.e_Squiggly;
        } else if (TOOL_BUTTON_STRIKEOUT.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_STRIKEOUT.equals(item)) {
            annotType = Annot.e_StrikeOut;
        } else if (TOOL_BUTTON_RECTANGLE.equals(item) || TOOL_ANNOTATION_CREATE_RECTANGLE.equals(item)) {
            annotType = Annot.e_Square;
        } else if (TOOL_BUTTON_ELLIPSE.equals(item) || TOOL_ANNOTATION_CREATE_ELLIPSE.equals(item)) {
            annotType = Annot.e_Circle;
        } else if (TOOL_BUTTON_LINE.equals(item) || TOOL_ANNOTATION_CREATE_LINE.equals(item)) {
            annotType = Annot.e_Line;
        } else if (TOOL_BUTTON_ARROW.equals(item) || TOOL_ANNOTATION_CREATE_ARROW.equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_ARROW;
        } else if (TOOL_BUTTON_POLYLINE.equals(item) || TOOL_ANNOTATION_CREATE_POLYLINE.equals(item)) {
            annotType = Annot.e_Polyline;
        } else if (TOOL_BUTTON_POLYGON.equals(item) || TOOL_ANNOTATION_CREATE_POLYGON.equals(item)) {
            annotType = Annot.e_Polygon;
        } else if (TOOL_BUTTON_CLOUD.equals(item) || TOOL_ANNOTATION_CREATE_POLYGON_CLOUD.equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_CLOUD;
        } else if (TOOL_BUTTON_SIGNATURE.equals(item) || TOOL_ANNOTATION_CREATE_SIGNATURE.equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_SIGNATURE;
        } else if (TOOL_BUTTON_FREE_TEXT.equals(item) || TOOL_ANNOTATION_CREATE_FREE_TEXT.equals(item)) {
            annotType = Annot.e_FreeText;
        } else if (TOOL_BUTTON_STICKY.equals(item) || TOOL_ANNOTATION_CREATE_STICKY.equals(item)) {
            annotType = Annot.e_Text;
        } else if (TOOL_BUTTON_CALLOUT.equals(item) || TOOL_ANNOTATION_CREATE_CALLOUT.equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_CALLOUT;
        } else if (TOOL_BUTTON_STAMP.equals(item) || TOOL_ANNOTATION_CREATE_STAMP.equals(item)) {
            annotType = Annot.e_Stamp;
        } else if (TOOL_ANNOTATION_CREATE_DISTANCE_MEASUREMENT.equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_RULER;
        } else if (TOOL_ANNOTATION_CREATE_PERIMETER_MEASUREMENT.equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_PERIMETER_MEASURE;
        } else if (TOOL_ANNOTATION_CREATE_AREA_MEASUREMENT.equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_AREA_MEASURE;
        } else if (TOOL_ANNOTATION_CREATE_FILE_ATTACHMENT.equals(item)) {
            annotType = Annot.e_FileAttachment;
        } else if (TOOL_ANNOTATION_CREATE_SOUND.equals(item)) {
            annotType = Annot.e_Sound;
        } else if (TOOL_ANNOTATION_CREATE_REDACTION.equals(item)
                || TOOL_ANNOTATION_CREATE_REDACTION_TEXT.equals(item)) {
            annotType = Annot.e_Redact;
        } else if (TOOL_ANNOTATION_CREATE_LINK.equals(item) || TOOL_ANNOTATION_CREATE_LINK_TEXT.equals(item)) {
            annotType = Annot.e_Link;
        } else if (TOOL_TEXT_SELECT.equals(item)) {
            annotType = Annot.e_Unknown;
        } else if (TOOL_PAN.equals(item)) {
            annotType = Annot.e_Unknown;
        } else if (TOOL_ANNOTATION_EDIT.equals(item)) {
            annotType = Annot.e_Unknown;
        } else if (TOOL_MULTI_SELECT.equals(item)) {
            annotType = Annot.e_Unknown;
        } else if (TOOL_FORM_CREATE_TEXT_FIELD.equals(item)) {
            annotType = Annot.e_Widget;
        } else if (TOOL_FORM_CREATE_CHECKBOX_FIELD.equals(item)) {
            annotType = Annot.e_Widget;
        } else if (TOOL_FORM_CREATE_SIGNATURE_FIELD.equals(item)) {
            annotType = Annot.e_Widget;
        } else if (TOOL_FORM_CREATE_RADIO_FIELD.equals(item)) {
            annotType = Annot.e_Widget;
        } else if (TOOL_FORM_CREATE_COMBO_BOX_FIELD.equals(item)) {
            annotType = Annot.e_Widget;
        } else if (TOOL_FORM_CREATE_TOOL_BOX_FIELD.equals(item)) {
            annotType = Annot.e_Widget;
        } else if (TOOL_FORM_CREATE_LIST_BOX_FIELD.equals(item)) {
            annotType = Annot.e_Widget;
        } else if (TOOL_ANNOTATION_CREATE_FREE_HIGHLIGHTER.equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_FREE_HIGHLIGHTER;
        } else if (TOOL_COUNT_TOOL.equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_COUNT_MEASUREMENT;
        } else if (TOOL_ANNOTATION_CREATE_FREE_TEXT_DATE.equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_FREE_TEXT_DATE;
        }
        return annotType;
    }

    @Nullable
    private String convAnnotTypeToString(Annot annot, int annotType) {
        String annotString;
        switch (annotType) {
            case Annot.e_Ink:
                annotString = TOOL_ANNOTATION_CREATE_FREE_HAND;
                break;
            case Annot.e_Highlight:
                annotString = TOOL_ANNOTATION_CREATE_TEXT_HIGHLIGHT;
                break;
            case Annot.e_Underline:
                annotString = TOOL_ANNOTATION_CREATE_TEXT_UNDERLINE;
                break;
            case Annot.e_Squiggly:
                annotString = TOOL_ANNOTATION_CREATE_TEXT_SQUIGGLY;
                break;
            case Annot.e_StrikeOut:
                annotString = TOOL_ANNOTATION_CREATE_TEXT_STRIKEOUT;
                break;
            case Annot.e_Square:
                annotString = TOOL_ANNOTATION_CREATE_RECTANGLE;
                break;
            case Annot.e_Circle:
                annotString = TOOL_ANNOTATION_CREATE_ELLIPSE;
                break;
            case Annot.e_Line:
                annotString = TOOL_ANNOTATION_CREATE_LINE;
                break;
            case Annot.e_Polyline:
                annotString = TOOL_ANNOTATION_CREATE_POLYLINE;
                break;
            case Annot.e_Polygon:
                annotString = TOOL_ANNOTATION_CREATE_POLYGON;
                break;
            case AnnotStyle.CUSTOM_ANNOT_TYPE_CLOUD:
                annotString = TOOL_ANNOTATION_CREATE_POLYGON_CLOUD;
                break;
            case AnnotStyle.CUSTOM_ANNOT_TYPE_SIGNATURE:
                annotString = TOOL_ANNOTATION_CREATE_SIGNATURE;
                break;
            case Annot.e_FreeText:
                annotString = TOOL_ANNOTATION_CREATE_FREE_TEXT;
                break;
            case Annot.e_Text:
                annotString = TOOL_ANNOTATION_CREATE_STICKY;
                break;
            case AnnotStyle.CUSTOM_ANNOT_TYPE_CALLOUT:
                annotString = TOOL_ANNOTATION_CREATE_CALLOUT;
                break;
            case Annot.e_Stamp:
                annotString = TOOL_ANNOTATION_CREATE_STAMP;
                break;
            case AnnotStyle.CUSTOM_ANNOT_TYPE_RULER:
                annotString = TOOL_ANNOTATION_CREATE_DISTANCE_MEASUREMENT;
                break;
            case AnnotStyle.CUSTOM_ANNOT_TYPE_PERIMETER_MEASURE:
                annotString = TOOL_ANNOTATION_CREATE_PERIMETER_MEASUREMENT;
                break;
            case AnnotStyle.CUSTOM_ANNOT_TYPE_AREA_MEASURE:
                annotString = TOOL_ANNOTATION_CREATE_AREA_MEASUREMENT;
                break;
            case Annot.e_FileAttachment:
                annotString = TOOL_ANNOTATION_CREATE_FILE_ATTACHMENT;
                break;
            case Annot.e_Sound:
                annotString = TOOL_ANNOTATION_CREATE_SOUND;
                break;
            case Annot.e_Redact:
                annotString = TOOL_ANNOTATION_CREATE_LINK_TEXT;
                break;
            case Annot.e_Link:
                annotString = TOOL_ANNOTATION_CREATE_LINK;
                break;
            case AnnotStyle.CUSTOM_ANNOT_TYPE_FREE_HIGHLIGHTER:
                annotString = TOOL_ANNOTATION_CREATE_FREE_HIGHLIGHTER;
                break;
            case Annot.e_Widget:
                annotString = getWidgetFieldType(annot);
                break;
            case AnnotStyle.CUSTOM_ANNOT_TYPE_FREE_TEXT_DATE:
                annotString = TOOL_ANNOTATION_CREATE_FREE_TEXT_DATE;
                break;
            default:
                annotString = "";
                break;
        }
        return annotString;
    }

    private String getWidgetFieldType(Annot annot) {
        try {
            if (annot != null && annot.isValid()) {
                Widget widget = new Widget(annot);
                Field field = widget.getField();
                int fieldType = field.getType();
                if (fieldType == Field.e_text) {
                    return TOOL_FORM_CREATE_TEXT_FIELD;
                } else if (fieldType == Field.e_radio) {
                    return TOOL_FORM_CREATE_RADIO_FIELD;
                } else if (fieldType == Field.e_check) {
                    return TOOL_FORM_CREATE_CHECKBOX_FIELD;
                } else if (fieldType == Field.e_choice) {
                    return TOOL_FORM_CREATE_COMBO_BOX_FIELD;
                } else if (fieldType == Field.e_signature) {
                    return TOOL_FORM_CREATE_SIGNATURE_FIELD;
                }
            }
        } catch (PDFNetException e) {
            return "";
        }
        return "";
    }

    @Nullable
    private ToolManager.ToolMode convStringToToolMode(String item) {
        ToolManager.ToolMode mode = null;
        if (TOOL_BUTTON_FREE_HAND.equals(item) || TOOL_ANNOTATION_CREATE_FREE_HAND.equals(item)) {
            mode = ToolManager.ToolMode.INK_CREATE;
        } else if (TOOL_BUTTON_HIGHLIGHT.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_HIGHLIGHT.equals(item)) {
            mode = ToolManager.ToolMode.TEXT_HIGHLIGHT;
        } else if (TOOL_BUTTON_UNDERLINE.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_UNDERLINE.equals(item)) {
            mode = ToolManager.ToolMode.TEXT_UNDERLINE;
        } else if (TOOL_BUTTON_SQUIGGLY.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_SQUIGGLY.equals(item)) {
            mode = ToolManager.ToolMode.TEXT_SQUIGGLY;
        } else if (TOOL_BUTTON_STRIKEOUT.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_STRIKEOUT.equals(item)) {
            mode = ToolManager.ToolMode.TEXT_STRIKEOUT;
        } else if (TOOL_BUTTON_RECTANGLE.equals(item) || TOOL_ANNOTATION_CREATE_RECTANGLE.equals(item)) {
            mode = ToolManager.ToolMode.RECT_CREATE;
        } else if (TOOL_BUTTON_ELLIPSE.equals(item) || TOOL_ANNOTATION_CREATE_ELLIPSE.equals(item)) {
            mode = ToolManager.ToolMode.OVAL_CREATE;
        } else if (TOOL_BUTTON_LINE.equals(item) || TOOL_ANNOTATION_CREATE_LINE.equals(item)) {
            mode = ToolManager.ToolMode.LINE_CREATE;
        } else if (TOOL_BUTTON_ARROW.equals(item) || TOOL_ANNOTATION_CREATE_ARROW.equals(item)) {
            mode = ToolManager.ToolMode.ARROW_CREATE;
        } else if (TOOL_BUTTON_POLYLINE.equals(item) || TOOL_ANNOTATION_CREATE_POLYLINE.equals(item)) {
            mode = ToolManager.ToolMode.POLYLINE_CREATE;
        } else if (TOOL_BUTTON_POLYGON.equals(item) || TOOL_ANNOTATION_CREATE_POLYGON.equals(item)) {
            mode = ToolManager.ToolMode.POLYGON_CREATE;
        } else if (TOOL_BUTTON_CLOUD.equals(item) || TOOL_ANNOTATION_CREATE_POLYGON_CLOUD.equals(item)) {
            mode = ToolManager.ToolMode.CLOUD_CREATE;
        } else if (TOOL_BUTTON_SIGNATURE.equals(item) || TOOL_ANNOTATION_CREATE_SIGNATURE.equals(item)) {
            mode = ToolManager.ToolMode.SIGNATURE;
        } else if (TOOL_BUTTON_FREE_TEXT.equals(item) || TOOL_ANNOTATION_CREATE_FREE_TEXT.equals(item)) {
            mode = ToolManager.ToolMode.TEXT_CREATE;
        } else if (TOOL_BUTTON_STICKY.equals(item) || TOOL_ANNOTATION_CREATE_STICKY.equals(item)) {
            mode = ToolManager.ToolMode.TEXT_ANNOT_CREATE;
        } else if (TOOL_BUTTON_CALLOUT.equals(item) || TOOL_ANNOTATION_CREATE_CALLOUT.equals(item)) {
            mode = ToolManager.ToolMode.CALLOUT_CREATE;
        } else if (TOOL_BUTTON_STAMP.equals(item) || TOOL_ANNOTATION_CREATE_STAMP.equals(item)) {
            mode = ToolManager.ToolMode.STAMPER;
        } else if (TOOL_ANNOTATION_CREATE_RUBBER_STAMP.equals(item)) {
            mode = ToolManager.ToolMode.RUBBER_STAMPER;
        } else if (TOOL_ANNOTATION_CREATE_DISTANCE_MEASUREMENT.equals(item)) {
            mode = ToolManager.ToolMode.RULER_CREATE;
        } else if (TOOL_ANNOTATION_CREATE_PERIMETER_MEASUREMENT.equals(item)) {
            mode = ToolManager.ToolMode.PERIMETER_MEASURE_CREATE;
        } else if (TOOL_ANNOTATION_CREATE_AREA_MEASUREMENT.equals(item)) {
            mode = ToolManager.ToolMode.AREA_MEASURE_CREATE;
        } else if (TOOL_ANNOTATION_CREATE_FILE_ATTACHMENT.equals(item)) {
            mode = ToolManager.ToolMode.FILE_ATTACHMENT_CREATE;
        } else if (TOOL_ANNOTATION_CREATE_SOUND.equals(item)) {
            mode = ToolManager.ToolMode.SOUND_CREATE;
        } else if (TOOL_ANNOTATION_CREATE_REDACTION.equals(item)) {
            mode = ToolManager.ToolMode.RECT_REDACTION;
        } else if (TOOL_ANNOTATION_CREATE_LINK.equals(item)) {
            mode = ToolManager.ToolMode.RECT_LINK;
        } else if (TOOL_ANNOTATION_CREATE_REDACTION_TEXT.equals(item)) {
            mode = ToolManager.ToolMode.TEXT_REDACTION;
        } else if (TOOL_ANNOTATION_CREATE_LINK_TEXT.equals(item)) {
            mode = ToolManager.ToolMode.TEXT_LINK_CREATE;
        } else if (TOOL_TEXT_SELECT.equals(item)) {
            mode = ToolManager.ToolMode.TEXT_SELECT;
        } else if (TOOL_PAN.equals(item)) {
            mode = ToolManager.ToolMode.PAN;
        } else if (TOOL_BUTTON_EDIT.equals(item) || TOOL_ANNOTATION_EDIT.equals(item)) {
            mode = ToolManager.ToolMode.ANNOT_EDIT;
        } else if (TOOL_MULTI_SELECT.equals(item)) {
            mode = ToolManager.ToolMode.ANNOT_EDIT_RECT_GROUP;
        } else if (TOOL_FORM_CREATE_TEXT_FIELD.equals(item)) {
            mode = ToolManager.ToolMode.FORM_TEXT_FIELD_CREATE;
        } else if (TOOL_FORM_CREATE_CHECKBOX_FIELD.equals(item)) {
            mode = ToolManager.ToolMode.FORM_CHECKBOX_CREATE;
        } else if (TOOL_FORM_CREATE_SIGNATURE_FIELD.equals(item)) {
            mode = ToolManager.ToolMode.FORM_SIGNATURE_CREATE;
        } else if (TOOL_FORM_CREATE_RADIO_FIELD.equals(item)) {
            mode = ToolManager.ToolMode.FORM_RADIO_GROUP_CREATE;
        } else if (TOOL_FORM_CREATE_COMBO_BOX_FIELD.equals(item)) {
            mode = ToolManager.ToolMode.FORM_COMBO_BOX_CREATE;
        } else if (TOOL_FORM_CREATE_LIST_BOX_FIELD.equals(item)) {
            mode = ToolManager.ToolMode.FORM_LIST_BOX_CREATE;
        } else if (TOOL_ANNOTATION_ERASER_TOOL.equals(item)) {
            mode = ToolManager.ToolMode.INK_ERASER;
        } else if (TOOL_ANNOTATION_CREATE_FREE_HIGHLIGHTER.equals(item)) {
            mode = ToolManager.ToolMode.FREE_HIGHLIGHTER;
        } else if (TOOL_ANNOTATION_CREATE_SMART_PEN.equals(item)) {
            mode = ToolManager.ToolMode.SMART_PEN_INK;
        } else if (TOOL_FORM_FILL.equals(item)) {
            mode = ToolManager.ToolMode.FORM_FILL;
        } else if (TOOL_COUNT_TOOL.equals(item)) {
            mode = ToolManager.ToolMode.COUNT_MEASUREMENT;
        } else if (TOOL_ANNOTATION_CREATE_FREE_TEXT_DATE.equals(item)) {
            mode = ToolManager.ToolMode.FREE_TEXT_DATE_CREATE;
        }
        return mode;
    }

    @Nullable
    private String convToolModeToString(ToolManager.ToolMode toolMode) {
        String toolModeString = null;
        switch (toolMode) {
            case INK_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_FREE_HAND;
                break;
            case TEXT_HIGHLIGHT:
                toolModeString = TOOL_ANNOTATION_CREATE_TEXT_HIGHLIGHT;
                break;
            case TEXT_UNDERLINE:
                toolModeString = TOOL_ANNOTATION_CREATE_TEXT_UNDERLINE;
                break;
            case TEXT_SQUIGGLY:
                toolModeString = TOOL_ANNOTATION_CREATE_TEXT_SQUIGGLY;
                break;
            case TEXT_STRIKEOUT:
                toolModeString = TOOL_ANNOTATION_CREATE_TEXT_STRIKEOUT;
                break;
            case RECT_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_RECTANGLE;
                break;
            case OVAL_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_ELLIPSE;
                break;
            case LINE_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_LINE;
                break;
            case ARROW_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_ARROW;
                break;
            case POLYLINE_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_POLYLINE;
                break;
            case POLYGON_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_POLYGON;
                break;
            case CLOUD_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_POLYGON_CLOUD;
                break;
            case SIGNATURE:
                toolModeString = TOOL_ANNOTATION_CREATE_SIGNATURE;
                break;
            case TEXT_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_FREE_TEXT;
                break;
            case CALLOUT_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_CALLOUT;
                break;
            case TEXT_ANNOT_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_STICKY;
                break;
            case STAMPER:
                toolModeString = TOOL_ANNOTATION_CREATE_STAMP;
                break;
            case RUBBER_STAMPER:
                toolModeString = TOOL_ANNOTATION_CREATE_RUBBER_STAMP;
                break;
            case RULER_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_DISTANCE_MEASUREMENT;
                break;
            case PERIMETER_MEASURE_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_PERIMETER_MEASUREMENT;
                break;
            case AREA_MEASURE_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_AREA_MEASUREMENT;
                break;
            case RECT_AREA_MEASURE_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_RECT_AREA_MEASUREMENT;
                break;
            case FILE_ATTACHMENT_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_FILE_ATTACHMENT;
                break;
            case SOUND_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_SOUND;
                break;
            case RECT_REDACTION:
                toolModeString = TOOL_ANNOTATION_CREATE_REDACTION;
                break;
            case RECT_LINK:
                toolModeString = TOOL_ANNOTATION_CREATE_LINK;
                break;
            case TEXT_REDACTION:
                toolModeString = TOOL_ANNOTATION_CREATE_REDACTION_TEXT;
                break;
            case TEXT_LINK_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_LINK_TEXT;
                break;
            case TEXT_SELECT:
                toolModeString = TOOL_TEXT_SELECT;
                break;
            case PAN:
                toolModeString = TOOL_PAN;
                break;
            case ANNOT_EDIT_RECT_GROUP:
                toolModeString = TOOL_MULTI_SELECT;
                break;
            case ANNOT_EDIT:
                toolModeString = TOOL_ANNOTATION_EDIT;
                break;
            case FORM_TEXT_FIELD_CREATE:
                toolModeString = TOOL_FORM_CREATE_TEXT_FIELD;
                break;
            case FORM_CHECKBOX_CREATE:
                toolModeString = TOOL_FORM_CREATE_CHECKBOX_FIELD;
                break;
            case FORM_SIGNATURE_CREATE:
                toolModeString = TOOL_FORM_CREATE_SIGNATURE_FIELD;
                break;
            case FORM_RADIO_GROUP_CREATE:
                toolModeString = TOOL_FORM_CREATE_RADIO_FIELD;
                break;
            case FORM_COMBO_BOX_CREATE:
                toolModeString = TOOL_FORM_CREATE_COMBO_BOX_FIELD;
                break;
            case FORM_LIST_BOX_CREATE:
                toolModeString = TOOL_FORM_CREATE_LIST_BOX_FIELD;
                break;
            case INK_ERASER:
                toolModeString = TOOL_ANNOTATION_ERASER_TOOL;
                break;
            case FREE_HIGHLIGHTER:
                toolModeString = TOOL_ANNOTATION_CREATE_FREE_HIGHLIGHTER;
                break;
            case SMART_PEN_INK:
            case SMART_PEN_TEXT_MARKUP:
                toolModeString = TOOL_ANNOTATION_CREATE_SMART_PEN;
                break;
            case FREE_TEXT_SPACING_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_FREE_SPACING_TEXT;
                break;
            case FREE_TEXT_DATE_CREATE:
                toolModeString = TOOL_ANNOTATION_CREATE_FREE_TEXT_DATE;
                break;
            case COUNT_MEASUREMENT:
                toolModeString = TOOL_COUNT_TOOL;
                break;
        }

        return toolModeString;
    }

    private int convStringToButtonId(String item) {
        int buttonId = 0;
        if (TOOL_BUTTON_FREE_HAND.equals(item) || TOOL_ANNOTATION_CREATE_FREE_HAND.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.INK.value();
        } else if (TOOL_BUTTON_HIGHLIGHT.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_HIGHLIGHT.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.TEXT_HIGHLIGHT.value();
        } else if (TOOL_BUTTON_UNDERLINE.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_UNDERLINE.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.TEXT_UNDERLINE.value();
        } else if (TOOL_BUTTON_SQUIGGLY.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_SQUIGGLY.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.TEXT_SQUIGGLY.value();
        } else if (TOOL_BUTTON_STRIKEOUT.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_STRIKEOUT.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.TEXT_STRIKEOUT.value();
        } else if (TOOL_BUTTON_RECTANGLE.equals(item) || TOOL_ANNOTATION_CREATE_RECTANGLE.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.SQUARE.value();
        } else if (TOOL_BUTTON_ELLIPSE.equals(item) || TOOL_ANNOTATION_CREATE_ELLIPSE.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.CIRCLE.value();
        } else if (TOOL_BUTTON_LINE.equals(item) || TOOL_ANNOTATION_CREATE_LINE.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.LINE.value();
        } else if (TOOL_BUTTON_ARROW.equals(item) || TOOL_ANNOTATION_CREATE_ARROW.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.ARROW.value();
        } else if (TOOL_BUTTON_POLYLINE.equals(item) || TOOL_ANNOTATION_CREATE_POLYLINE.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.POLYLINE.value();
        } else if (TOOL_BUTTON_POLYGON.equals(item) || TOOL_ANNOTATION_CREATE_POLYGON.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.POLYGON.value();
        } else if (TOOL_BUTTON_CLOUD.equals(item) || TOOL_ANNOTATION_CREATE_POLYGON_CLOUD.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.POLY_CLOUD.value();
        } else if (TOOL_BUTTON_SIGNATURE.equals(item) || TOOL_ANNOTATION_CREATE_SIGNATURE.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.SIGNATURE.value();
        } else if (TOOL_BUTTON_FREE_TEXT.equals(item) || TOOL_ANNOTATION_CREATE_FREE_TEXT.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.FREE_TEXT.value();
        } else if (TOOL_BUTTON_STICKY.equals(item) || TOOL_ANNOTATION_CREATE_STICKY.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.STICKY_NOTE.value();
        } else if (TOOL_BUTTON_CALLOUT.equals(item) || TOOL_ANNOTATION_CREATE_CALLOUT.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.CALLOUT.value();
        } else if (TOOL_BUTTON_STAMP.equals(item) || TOOL_ANNOTATION_CREATE_STAMP.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.STAMP.value();
        } else if (TOOL_ANNOTATION_CREATE_RUBBER_STAMP.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.STAMP.value();
        } else if (TOOL_ANNOTATION_CREATE_DISTANCE_MEASUREMENT.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.RULER.value();
        } else if (TOOL_ANNOTATION_CREATE_PERIMETER_MEASUREMENT.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.PERIMETER.value();
        } else if (TOOL_ANNOTATION_CREATE_AREA_MEASUREMENT.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.AREA.value();
        } else if (TOOL_ANNOTATION_CREATE_FILE_ATTACHMENT.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.ATTACHMENT.value();
        } else if (TOOL_ANNOTATION_CREATE_SOUND.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.SOUND.value();
        } else if (TOOL_ANNOTATION_CREATE_REDACTION.equals(item)) {
            // TODO
        } else if (TOOL_ANNOTATION_CREATE_LINK.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.LINK.value();
        } else if (TOOL_ANNOTATION_CREATE_REDACTION_TEXT.equals(item)) {
            // TODO
        } else if (TOOL_ANNOTATION_CREATE_LINK_TEXT.equals(item)) {
            // TODO
        } else if (TOOL_BUTTON_EDIT.equals(item) || TOOL_ANNOTATION_EDIT.equals(item) || TOOL_MULTI_SELECT.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.MULTI_SELECT.value();
        } else if (TOOL_FORM_CREATE_TEXT_FIELD.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.TEXT_FIELD.value();
        } else if (TOOL_FORM_CREATE_CHECKBOX_FIELD.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.CHECKBOX.value();
        } else if (TOOL_FORM_CREATE_SIGNATURE_FIELD.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.SIGNATURE_FIELD.value();
        } else if (TOOL_FORM_CREATE_RADIO_FIELD.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.RADIO_BUTTON.value();
        } else if (TOOL_FORM_CREATE_COMBO_BOX_FIELD.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.COMBO_BOX.value();
        } else if (TOOL_FORM_CREATE_LIST_BOX_FIELD.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.LIST_BOX.value();
        } else if (TOOL_ANNOTATION_ERASER_TOOL.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.ERASER.value();
        } else if (TOOL_ANNOTATION_CREATE_FREE_HIGHLIGHTER.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.FREE_HIGHLIGHT.value();
        } else if (BUTTON_UNDO.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.UNDO.value();
        } else if (BUTTON_REDO.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.REDO.value();
        } else if (BUTTON_EDIT_MENU.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.CUSTOMIZE.value();
        } else if (TOOL_ANNOTATION_CREATE_FREE_TEXT_DATE.equals(item)) {
            buttonId = DefaultToolbars.ButtonId.DATE.value();
        }
        return buttonId;
    }

    @Nullable
    private TopToolbarMenuId convButtonIdToMenuId(String item) {
        if (BUTTON_TABS.equals(item)) {
            return TopToolbarMenuId.TABS;
        } else if (BUTTON_SEARCH.equals(item)) {
            return TopToolbarMenuId.SEARCH;
        } else if (BUTTON_VIEW_CONTROLS.equals(item)) {
            return TopToolbarMenuId.VIEW_MODE;
        } else if (BUTTON_THUMBNAILS.equals(item)) {
            return TopToolbarMenuId.THUMBNAILS;
        } else if (BUTTON_OUTLINE_LIST.equals(item)) {
            return TopToolbarMenuId.OUTLINE;
        } else if (BUTTON_UNDO.equals(item)) {
            return TopToolbarMenuId.UNDO;
        } else if (BUTTON_SHARE.equals(item)) {
            return TopToolbarMenuId.SHARE;
        } else if (BUTTON_REFLOW.equals(item)) {
            return TopToolbarMenuId.REFLOW_MODE;
        } else if (BUTTON_EDIT_PAGES.equals(item)) {
            return TopToolbarMenuId.EDIT_PAGES;
        } else if (BUTTON_SAVE_COPY.equals(item)) {
            return TopToolbarMenuId.EXPORT;
        } else if (BUTTON_PRINT.equals(item)) {
            return TopToolbarMenuId.PRINT;
        } else if (BUTTON_FILE_ATTACHMENT.equals(item)) {
            return TopToolbarMenuId.FILE_ATTACHMENT;
        } else if (BUTTON_VIEW_LAYERS.equals(item)) {
            return TopToolbarMenuId.OCG_LAYERS;
        } else if (BUTTON_DIGITAL_SIGNATURE.equals(item)) {
            return TopToolbarMenuId.DIGITAL_SIGNATURES;
        } else if (BUTTON_CLOSE.equals(item)) {
            return TopToolbarMenuId.CLOSE_TAB;
        }
        return null;
    }

    @Nullable
    private String convItemIdToString(int id) {
        String buttonId = null;
        if (id == R.id.action_tabs) {
            buttonId = BUTTON_TABS;
        } else if (id == R.id.action_search) {
            buttonId = BUTTON_SEARCH;
        } else if (id == R.id.action_viewmode) {
            buttonId = BUTTON_VIEW_CONTROLS;
        } else if (id == R.id.action_thumbnails) {
            buttonId = BUTTON_THUMBNAILS;
        } else if (id == R.id.action_outline) {
            buttonId = BUTTON_OUTLINE_LIST;
        } else if (id == R.id.undo) {
            buttonId = BUTTON_UNDO;
        } else if (id == R.id.action_share) {
            buttonId = BUTTON_SHARE;
        } else if (id == R.id.action_reflow_mode) {
            buttonId = BUTTON_REFLOW;
        } else if (id == R.id.action_editpages) {
            buttonId = BUTTON_EDIT_PAGES;
        } else if (id == R.id.action_export_options) {
            buttonId = BUTTON_SAVE_COPY;
        } else if (id == R.id.action_print) {
            buttonId = BUTTON_PRINT;
        } else if (id == R.id.action_file_attachment) {
            buttonId = BUTTON_FILE_ATTACHMENT;
        } else if (id == R.id.action_pdf_layers) {
            buttonId = BUTTON_VIEW_LAYERS;
        } else if (id == R.id.action_digital_signatures) {
            buttonId = BUTTON_DIGITAL_SIGNATURE;
        } else if (id == R.id.action_close_tab) {
            buttonId = BUTTON_CLOSE;
        }

        return buttonId;
    }

    @Nullable
    private ToolbarButtonType convStringToToolbarType(String item) {
        ToolbarButtonType buttonType = null;
        if (TOOL_BUTTON_FREE_HAND.equals(item) || TOOL_ANNOTATION_CREATE_FREE_HAND.equals(item)) {
            buttonType = ToolbarButtonType.INK;
        } else if (TOOL_BUTTON_HIGHLIGHT.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_HIGHLIGHT.equals(item)) {
            buttonType = ToolbarButtonType.TEXT_HIGHLIGHT;
        } else if (TOOL_BUTTON_UNDERLINE.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_UNDERLINE.equals(item)) {
            buttonType = ToolbarButtonType.TEXT_UNDERLINE;
        } else if (TOOL_BUTTON_SQUIGGLY.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_SQUIGGLY.equals(item)) {
            buttonType = ToolbarButtonType.TEXT_SQUIGGLY;
        } else if (TOOL_BUTTON_STRIKEOUT.equals(item) || TOOL_ANNOTATION_CREATE_TEXT_STRIKEOUT.equals(item)) {
            buttonType = ToolbarButtonType.TEXT_STRIKEOUT;
        } else if (TOOL_BUTTON_RECTANGLE.equals(item) || TOOL_ANNOTATION_CREATE_RECTANGLE.equals(item)) {
            buttonType = ToolbarButtonType.SQUARE;
        } else if (TOOL_BUTTON_ELLIPSE.equals(item) || TOOL_ANNOTATION_CREATE_ELLIPSE.equals(item)) {
            buttonType = ToolbarButtonType.CIRCLE;
        } else if (TOOL_BUTTON_LINE.equals(item) || TOOL_ANNOTATION_CREATE_LINE.equals(item)) {
            buttonType = ToolbarButtonType.LINE;
        } else if (TOOL_BUTTON_ARROW.equals(item) || TOOL_ANNOTATION_CREATE_ARROW.equals(item)) {
            buttonType = ToolbarButtonType.ARROW;
        } else if (TOOL_BUTTON_POLYLINE.equals(item) || TOOL_ANNOTATION_CREATE_POLYLINE.equals(item)) {
            buttonType = ToolbarButtonType.POLYLINE;
        } else if (TOOL_BUTTON_POLYGON.equals(item) || TOOL_ANNOTATION_CREATE_POLYGON.equals(item)) {
            buttonType = ToolbarButtonType.POLYGON;
        } else if (TOOL_BUTTON_CLOUD.equals(item) || TOOL_ANNOTATION_CREATE_POLYGON_CLOUD.equals(item)) {
            buttonType = ToolbarButtonType.POLY_CLOUD;
        } else if (TOOL_BUTTON_SIGNATURE.equals(item) || TOOL_ANNOTATION_CREATE_SIGNATURE.equals(item)) {
            buttonType = ToolbarButtonType.SIGNATURE;
        } else if (TOOL_BUTTON_FREE_TEXT.equals(item) || TOOL_ANNOTATION_CREATE_FREE_TEXT.equals(item)) {
            buttonType = ToolbarButtonType.FREE_TEXT;
        } else if (TOOL_BUTTON_STICKY.equals(item) || TOOL_ANNOTATION_CREATE_STICKY.equals(item)) {
            buttonType = ToolbarButtonType.STICKY_NOTE;
        } else if (TOOL_BUTTON_CALLOUT.equals(item) || TOOL_ANNOTATION_CREATE_CALLOUT.equals(item)) {
            buttonType = ToolbarButtonType.CALLOUT;
        } else if (TOOL_BUTTON_STAMP.equals(item) || TOOL_ANNOTATION_CREATE_STAMP.equals(item)) {
            buttonType = ToolbarButtonType.IMAGE;
        } else if (TOOL_ANNOTATION_CREATE_RUBBER_STAMP.equals(item)) {
            buttonType = ToolbarButtonType.STAMP;
        } else if (TOOL_ANNOTATION_CREATE_DISTANCE_MEASUREMENT.equals(item)) {
            buttonType = ToolbarButtonType.RULER;
        } else if (TOOL_ANNOTATION_CREATE_PERIMETER_MEASUREMENT.equals(item)) {
            buttonType = ToolbarButtonType.PERIMETER;
        } else if (TOOL_ANNOTATION_CREATE_AREA_MEASUREMENT.equals(item)) {
            buttonType = ToolbarButtonType.AREA;
        } else if (TOOL_ANNOTATION_CREATE_FILE_ATTACHMENT.equals(item)) {
            buttonType = ToolbarButtonType.ATTACHMENT;
        } else if (TOOL_ANNOTATION_CREATE_SOUND.equals(item)) {
            buttonType = ToolbarButtonType.SOUND;
        } else if (TOOL_ANNOTATION_CREATE_REDACTION.equals(item)) {
            buttonType = ToolbarButtonType.RECT_REDACTION;
        } else if (TOOL_ANNOTATION_CREATE_LINK.equals(item)) {
            buttonType = ToolbarButtonType.LINK;
        } else if (TOOL_ANNOTATION_CREATE_REDACTION_TEXT.equals(item)) {
            buttonType = ToolbarButtonType.TEXT_REDACTION;
        } else if (TOOL_ANNOTATION_CREATE_LINK_TEXT.equals(item)) {
            // TODO
        } else if (TOOL_BUTTON_EDIT.equals(item) || TOOL_ANNOTATION_EDIT.equals(item) || TOOL_MULTI_SELECT.equals(item)) {
            buttonType = ToolbarButtonType.MULTI_SELECT;
        } else if (TOOL_FORM_CREATE_TEXT_FIELD.equals(item)) {
            buttonType = ToolbarButtonType.TEXT_FIELD;
        } else if (TOOL_FORM_CREATE_CHECKBOX_FIELD.equals(item)) {
            buttonType = ToolbarButtonType.CHECKBOX;
        } else if (TOOL_FORM_CREATE_SIGNATURE_FIELD.equals(item)) {
            buttonType = ToolbarButtonType.SIGNATURE_FIELD;
        } else if (TOOL_FORM_CREATE_RADIO_FIELD.equals(item)) {
            buttonType = ToolbarButtonType.RADIO_BUTTON;
        } else if (TOOL_FORM_CREATE_COMBO_BOX_FIELD.equals(item)) {
            buttonType = ToolbarButtonType.COMBO_BOX;
        } else if (TOOL_FORM_CREATE_LIST_BOX_FIELD.equals(item)) {
            buttonType = ToolbarButtonType.LIST_BOX;
        } else if (TOOL_ANNOTATION_ERASER_TOOL.equals(item)) {
            buttonType = ToolbarButtonType.ERASER;
        } else if (TOOL_ANNOTATION_CREATE_FREE_HIGHLIGHTER.equals(item)) {
            buttonType = ToolbarButtonType.FREE_HIGHLIGHT;
        } else if (BUTTON_UNDO.equals(item)) {
            buttonType = ToolbarButtonType.UNDO;
        } else if (BUTTON_REDO.equals(item)) {
            buttonType = ToolbarButtonType.REDO;
        } else if (BUTTON_EDIT_MENU.equals(item)) {
            buttonType = ToolbarButtonType.EDIT_TOOLBAR;
        } else if (TOOL_ANNOTATION_CREATE_FREE_TEXT_DATE.equals(item)) {
            buttonType = ToolbarButtonType.DATE;
        }
        return buttonType;
    }

    private int convStringToToolbarDefaultIconRes(String item) {
        if (TAG_VIEW_TOOLBAR.equals(item)) {
            return R.drawable.ic_view;
        } else if (TAG_ANNOTATE_TOOLBAR.equals(item)) {
            return R.drawable.ic_annotation_underline_black_24dp;
        } else if (TAG_DRAW_TOOLBAR.equals(item)) {
            return R.drawable.ic_pens_and_shapes;
        } else if (TAG_INSERT_TOOLBAR.equals(item)) {
            return R.drawable.ic_add_image_white;
        } else if (TAG_FILL_AND_SIGN_TOOLBAR.equals(item)) {
            return R.drawable.ic_fill_and_sign;
        } else if (TAG_PREPARE_FORM_TOOLBAR.equals(item)) {
            return R.drawable.ic_prepare_form;
        } else if (TAG_MEASURE_TOOLBAR.equals(item)) {
            return R.drawable.ic_annotation_distance_black_24dp;
        } else if (TAG_PENS_TOOLBAR.equals(item)) {
            return R.drawable.ic_annotation_freehand_black_24dp;
        } else if (TAG_REDACTION_TOOLBAR.equals(item)) {
            return R.drawable.ic_annotation_redact_black_24dp;
        } else if (TAG_FAVORITE_TOOLBAR.equals(item)) {
            return R.drawable.ic_star_white_24dp;
        }
        return 0;
    }

    private void checkQuickMenu(List<QuickMenuItem> menuItems, ArrayList<Object> keepList, List<QuickMenuItem> removeList) {
        for (QuickMenuItem item : menuItems) {
            int menuId = item.getItemId();
            if (ToolConfig.getInstance().getToolModeByQMItemId(menuId) != null) {
                // skip real annotation tools
                return;
            }
            String menuStr = convQuickMenuIdToString(menuId);
            if (!keepList.contains(menuStr)) {
                removeList.add(item);
            }
        }
    }

    @Nullable
    private String convQuickMenuIdToString(int id) {
        String menuStr = null;
        if (id == R.id.qm_appearance) {
            menuStr = MENU_ID_STRING_STYLE;
        } else if (id == R.id.qm_note) {
            menuStr = MENU_ID_STRING_NOTE;
        } else if (id == R.id.qm_copy) {
            menuStr = MENU_ID_STRING_COPY;
        } else if (id == R.id.qm_delete) {
            menuStr = MENU_ID_STRING_DELETE;
        } else if (id == R.id.qm_flatten) {
            menuStr = MENU_ID_STRING_FLATTEN;
        } else if (id == R.id.qm_duplicate) {
            menuStr = MENU_ID_STRING_DUPLICATE;
        } else if (id == R.id.qm_text) {
            menuStr = MENU_ID_STRING_TEXT;
        } else if (id == R.id.qm_edit) {
            menuStr = MENU_ID_STRING_EDIT_INK;
        } else if (id == R.id.qm_search) {
            menuStr = MENU_ID_STRING_SEARCH;
        } else if (id == R.id.qm_share) {
            menuStr = MENU_ID_STRING_SHARE;
        } else if (id == R.id.qm_type) {
            menuStr = MENU_ID_STRING_MARKUP_TYPE;
        } else if (id == R.id.qm_screencap_create) {
            menuStr = MENU_ID_STRING_SCREEN_CAPTURE;
        } else if (id == R.id.qm_play_sound) {
            menuStr = MENU_ID_STRING_PLAY_SOUND;
        } else if (id == R.id.qm_open_attachment) {
            menuStr = MENU_ID_STRING_OPEN_ATTACHMENT;
        } else if (id == R.id.qm_tts) {
            menuStr = MENU_ID_STRING_READ;
        } else if (id == R.id.qm_calibrate) {
            menuStr = MENU_ID_STRING_CALIBRATE;
        } else if (id == R.id.qm_underline) {
            menuStr = MENU_ID_STRING_UNDERLINE;
        } else if (id == R.id.qm_redact) {
            menuStr = MENU_ID_STRING_REDACT;
        } else if (id == R.id.qm_redaction) {
            menuStr = MENU_ID_STRING_REDACTION;
        } else if (id == R.id.qm_strikeout) {
            menuStr = MENU_ID_STRING_STRIKEOUT;
        } else if (id == R.id.qm_squiggly) {
            menuStr = MENU_ID_STRING_SQUIGGLY;
        } else if (id == R.id.qm_link) {
            menuStr = MENU_ID_STRING_LINK;
        } else if (id == R.id.qm_highlight) {
            menuStr = MENU_ID_STRING_HIGHLIGHT;
        } else if (id == R.id.qm_floating_sig) {
            menuStr = MENU_ID_STRING_SIGNATURE;
        } else if (id == R.id.qm_rectangle) {
            menuStr = MENU_ID_STRING_RECTANGLE;
        } else if (id == R.id.qm_line) {
            menuStr = MENU_ID_STRING_LINE;
        } else if (id == R.id.qm_free_hand) {
            menuStr = MENU_ID_STRING_FREE_HAND;
        } else if (id == R.id.qm_image_stamper) {
            menuStr = MENU_ID_STRING_IMAGE;
        } else if (id == R.id.qm_form_text) {
            menuStr = MENU_ID_STRING_FORM_TEXT;
        } else if (id == R.id.qm_sticky_note) {
            menuStr = MENU_ID_STRING_STICKY_NOTE;
        } else if (id == R.id.qm_overflow) {
            menuStr = MENU_ID_STRING_OVERFLOW;
        } else if (id == R.id.qm_ink_eraser) {
            menuStr = MENU_ID_STRING_ERASER;
        } else if (id == R.id.qm_rubber_stamper) {
            menuStr = MENU_ID_STRING_STAMP;
        } else if (id == R.id.qm_page_redaction) {
            menuStr = MENU_ID_STRING_PAGE_REDACTION;
        } else if (id == R.id.qm_rect_redaction) {
            menuStr = MENU_ID_STRING_RECT_REDACTION;
        } else if (id == R.id.qm_search_redaction) {
            menuStr = MENU_ID_STRING_SEARCH_REDACTION;
        } else if (id == R.id.qm_shape) {
            menuStr = MENU_ID_STRING_SHAPE;
        } else if (id == R.id.qm_cloud) {
            menuStr = MENU_ID_STRING_CLOUD;
        } else if (id == R.id.qm_polygon) {
            menuStr = MENU_ID_STRING_POLYGON;
        } else if (id == R.id.qm_polyline) {
            menuStr = MENU_ID_STRING_POLYLINE;
        } else if (id == R.id.qm_free_highlighter) {
            menuStr = MENU_ID_STRING_FREE_HIGHLIGHTER;
        } else if (id == R.id.qm_arrow) {
            menuStr = MENU_ID_STRING_ARROW;
        } else if (id == R.id.qm_oval) {
            menuStr = MENU_ID_STRING_OVAL;
        } else if (id == R.id.qm_callout) {
            menuStr = MENU_ID_STRING_CALLOUT;
        } else if (id == R.id.qm_measurement) {
            menuStr = MENU_ID_STRING_MEASUREMENT;
        } else if (id == R.id.qm_area_measure) {
            menuStr = MENU_ID_STRING_AREA_MEASUREMENT;
        } else if (id == R.id.qm_perimeter_measure) {
            menuStr = MENU_ID_STRING_PERIMETER_MEASUREMENT;
        } else if (id == R.id.qm_rect_area_measure) {
            menuStr = MENU_ID_STRING_RECT_AREA_MEASUREMENT;
        } else if (id == R.id.qm_ruler) {
            menuStr = MENU_ID_STRING_RULER;
        } else if (id == R.id.qm_form) {
            menuStr = MENU_ID_STRING_FORM;
        } else if (id == R.id.qm_form_combo_box) {
            menuStr = MENU_ID_STRING_FORM_COMBO_BOX;
        } else if (id == R.id.qm_form_list_box) {
            menuStr = MENU_ID_STRING_FORM_LIST_BOX;
        } else if (id == R.id.qm_form_check_box) {
            menuStr = MENU_ID_STRING_FORM_CHECK_BOX;
        } else if (id == R.id.qm_form_signature) {
            menuStr = MENU_ID_STRING_FORM_SIGNATURE;
        } else if (id == R.id.qm_form_radio_group) {
            menuStr = MENU_ID_STRING_FORM_RADIO_GROUP;
        } else if (id == R.id.qm_attach) {
            menuStr = MENU_ID_STRING_ATTACH;
        } else if (id == R.id.qm_file_attachment) {
            menuStr = MENU_ID_STRING_FILE_ATTACHMENT;
        } else if (id == R.id.qm_sound) {
            menuStr = MENU_ID_STRING_SOUND;
        } else if (id == R.id.qm_free_text) {
            menuStr = MENU_ID_STRING_FREE_TEXT;
        } else if (id == R.id.qm_crop) {
            menuStr = MENU_ID_STRING_CROP;
        } else if (id == R.id.qm_crop_ok) {
            menuStr = MENU_ID_STRING_CROP_OK;
        } else if (id == R.id.qm_crop_cancel) {
            menuStr = MENU_ID_STRING_CROP_CANCEL;
        } else if (id == R.id.qm_define) {
            menuStr = MENU_ID_STRING_DEFINE;
        } else if (id == R.id.qm_field_signed) {
            menuStr = MENU_ID_STRING_FIELD_SIGNED;
        } else if (id == R.id.qm_first_row_group) {
            menuStr = MENU_ID_STRING_FIRST_ROW_GROUP;
        } else if (id == R.id.qm_second_row_group) {
            menuStr = MENU_ID_STRING_SECOND_ROW_GROUP;
        } else if (id == R.id.qm_group) {
            menuStr = MENU_ID_STRING_GROUP;
        } else if (id == R.id.qm_paste) {
            menuStr = MENU_ID_STRING_PASTE;
        } else if (id == R.id.qm_rect_group_select) {
            menuStr = MENU_ID_STRING_RECT_GROUP_SELECT;
        } else if (id == R.id.qm_sign_and_save) {
            menuStr = MENU_ID_STRING_SIGN_AND_SAVE;
        } else if (id == R.id.qm_thickness) {
            menuStr = MENU_ID_STRING_THICKNESS;
        } else if (id == R.id.qm_translate) {
            menuStr = MENU_ID_STRING_TRANSLATE;
        } else if (id == R.id.qm_ungroup) {
            menuStr = MENU_ID_STRING_UNGROUP;
        }

        return menuStr;
    }

    private ViewerConfig getConfig() {
        if (mExportPath != null) {
            mBuilder.saveCopyExportPath(mExportPath);
        }
        if (mOpenUrlPath != null) {
            mBuilder.openUrlCachePath(mOpenUrlPath);
        }

        if (mDisabledTools.size() > 0) {
            ToolManager.ToolMode[] modes = mDisabledTools.toArray(new ToolManager.ToolMode[0]);
            if (modes.length > 0) {
                mToolManagerBuilder = mToolManagerBuilder.disableToolModes(modes);
            }
        }
        if (mViewModePickerItems.size() > 0) {
            mBuilder = mBuilder.hideViewModeItems(mViewModePickerItems.toArray(new ViewModePickerDialogFragment.ViewModePickerItems[0]));
        }
        if (mThumbnailViewItems.size() > 0) {
            mBuilder = mBuilder.hideThumbnailEditOptions(mThumbnailViewItems
                    .toArray(new ThumbnailsViewFragment.ThumbnailsViewEditOptions[0]));
        }
        return mBuilder
                .pdfViewCtrlConfig(mPDFViewCtrlConfig)
                .toolManagerBuilder(mToolManagerBuilder)
                .build();
    }

    private boolean mShouldHandleKeyboard = false;

    private final ViewTreeObserver.OnGlobalLayoutListener mOnGlobalLayoutListener = new ViewTreeObserver.OnGlobalLayoutListener() {
        @Override
        public void onGlobalLayout() {
            Rect r = new Rect();
            getWindowVisibleDisplayFrame(r);
            int screenHeight = getRootView().getHeight();

            // r.bottom is the position above soft keypad or device button.
            // if keypad is shown, the r.bottom is smaller than that before.
            int keypadHeight = screenHeight - r.bottom;

            if (keypadHeight > screenHeight * 0.15) { // 0.15 ratio is perhaps enough to determine keypad height.
                // keyboard is opened
                mShouldHandleKeyboard = true;
            } else {
                // keyboard is closed
                if (mShouldHandleKeyboard) {
                    mShouldHandleKeyboard = false;
                    requestLayout();
                }
            }
        }
    };

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

    @Override
    protected void prepView() {
        super.prepView();

        if (mPdfViewCtrlTabHostFragment != null && mPdfViewCtrlTabHostFragment.getView() == null) {
            if (mPdfViewCtrlTabHostFragment instanceof RNPdfViewCtrlTabHostFragment) {
                ((RNPdfViewCtrlTabHostFragment) mPdfViewCtrlTabHostFragment).setRNHostFragmentListener(mRNHostFragmentListener);
            } else if (mPdfViewCtrlTabHostFragment instanceof RNCollabViewerTabHostFragment) {
                ((RNCollabViewerTabHostFragment) mPdfViewCtrlTabHostFragment).setRNHostFragmentListener(mRNHostFragmentListener);
            }
        }
    }

    @Override
    protected void onAttachedToWindow() {
        if (null == mFragmentManager) {
            setSupportFragmentManager(mFragmentManagerSave);
        }
        try {
            // check if the view is attached to a parent fragment
            Fragment fragment = FragmentManager.findFragment(this);
            mFragmentManagerSave = fragment.getChildFragmentManager();
            setSupportFragmentManager(mFragmentManagerSave);
        } catch (Exception ignored) {
        }

        // TODO, update base64 when ViewerBuilder supports byte array
        Uri fileUri = ReactUtils.getUri(getContext(), mDocumentPath, mIsBase64, mBase64Extension);

        if (fileUri != null) {
            if (mIsBase64) {
                mTempFiles.add(new File(fileUri.getPath()));
            }
            setDocumentUri(fileUri);
            setViewerConfig(getConfig());
        }
        super.onAttachedToWindow();

        mFragmentTransactionFinished = true;

        // since we are using this component as an individual component,
        // we don't want to fit system window, unless user specifies
        if (!mPadStatusBar) {
            View host = findViewById(R.id.pdfviewctrl_tab_host);
            if (host != null) {
                host.setFitsSystemWindows(false);
            }
            View tabContent = findViewById(R.id.realtabcontent);
            if (tabContent != null) {
                tabContent.setFitsSystemWindows(false);
            }
            View appBar = findViewById(R.id.app_bar_layout);
            if (appBar != null) {
                appBar.setFitsSystemWindows(false);
            }
            View annotToolbar = findViewById(R.id.annotation_toolbar);
            if (annotToolbar != null) {
                annotToolbar.setFitsSystemWindows(false);
            }
        }

        getViewTreeObserver().addOnGlobalLayoutListener(mOnGlobalLayoutListener);
    }

    @Override
    protected void onDetachedFromWindow() {
        if (getPdfViewCtrl() != null) {
            getPdfViewCtrl().removePageChangeListener(mPageChangeListener);
            getPdfViewCtrl().removeTextSearchListener(mTextSearchListener);
            getPdfViewCtrl().removeOnCanvasSizeChangeListener(mOnCanvasSizeChangeListener);
            getPdfViewCtrl().removeOnLayoutChangeListener(mLayoutChangedListener);
        }
        if (getToolManager() != null) {
            getToolManager().removeAnnotationModificationListener(mAnnotationModificationListener);
            getToolManager().removeAnnotationsSelectionListener(mAnnotationsSelectionListener);
            getToolManager().removePdfDocModificationListener(mPdfDocModificationListener);
            getToolManager().removeToolChangedListener(mToolChangedListener);
            getToolManager().getUndoRedoManger().removeUndoRedoStateChangeListener(mUndoRedoStateChangedListener);
            getToolManager().setPreToolManagerListener(null);
        }
        if (getPdfViewCtrlTabFragment() != null) {
            getPdfViewCtrlTabFragment().removeQuickMenuListener(mQuickMenuListener);
        }

        StampManager.getInstance().setSignatureListener(null);

        ActionUtils.getInstance().setActionInterceptCallback(null);

        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.removeOnToolbarChangedListener(mToolbarChangedListener);
        }

        super.onDetachedFromWindow();

        getViewTreeObserver().removeOnGlobalLayoutListener(mOnGlobalLayoutListener);

        if (mTempFiles != null) {
            for (File file : mTempFiles) {
                if (file != null && file.exists()) {
                    file.delete();
                }
            }
            mTempFiles = null;
        }
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.onActivityResult(requestCode, resultCode, data);
        }
        if (getPdfViewCtrlTabFragment() != null) {
            getPdfViewCtrlTabFragment().onActivityResult(requestCode, resultCode, data);
        }
        // Consume for ThumbnailsViewFragment
        if (requestCode == RequestCode.PICK_PDF_FILE || requestCode == RequestCode.PICK_PHOTO_CAM) {
            if (mFragmentManager != null) {
                Fragment fragment = mFragmentManager.findFragmentByTag("thumbnails_fragment");
                if (fragment instanceof ThumbnailsViewFragment) {
                    fragment.onActivityResult(requestCode, resultCode, data);
                }
            }
        }
    }

    @Override
    public void onNavButtonPressed() {
        if (getToolManager() != null) {
            getToolManager().setTool(getToolManager().createTool(ToolManager.ToolMode.PAN, null));
        }
        onReceiveNativeEvent(ON_NAV_BUTTON_PRESSED, ON_NAV_BUTTON_PRESSED);
    }

    @Override
    public boolean onToolbarOptionsItemSelected(MenuItem item) {
        int itemId = item.getItemId();
        String itemKey = mToolIdMap.get(itemId);
        if (itemKey != null) {
            // this is a custom button
            WritableMap params = Arguments.createMap();
            params.putString(ON_ANNOTATION_TOOLBAR_ITEM_PRESS, ON_ANNOTATION_TOOLBAR_ITEM_PRESS);
            params.putString(TOOLBAR_ITEM_KEY_ID, itemKey);
            onReceiveNativeEvent(params);
            return true;
        } else {
            itemKey = convItemIdToString(itemId);
            // check if the item's behavior should be overridden
            if (itemKey != null && mToolbarOverrideButtons != null && mToolbarOverrideButtons.contains(itemKey)) {
                WritableMap params = Arguments.createMap();
                params.putString(ON_TOOLBAR_BUTTON_PRESS, ON_TOOLBAR_BUTTON_PRESS);
                params.putString(TOOLBAR_ITEM_KEY_ID, itemKey);
                onReceiveNativeEvent(params);
                return true;
            }
        }

        return super.onToolbarOptionsItemSelected(item);
    }

    @Override
    public boolean canShowFileInFolder() {
        return false;
    }

    @Override
    public boolean canShowFileCloseSnackbar() {
        return false;
    }

    @Override
    public boolean canRecreateActivity() {
        return !mFragmentTransactionFinished;
    }

    private boolean hasAnnotationsSelected() {
        return mSelectedAnnots != null && !mSelectedAnnots.isEmpty();
    }

    private WritableArray getAnnotationsData(boolean overrideAction) {
        // overrideAction is for onBehaviorActivated
        WritableArray annots = Arguments.createArray();

        boolean shouldUnlockRead = false;
        try {
            getPdfViewCtrl().docLockRead();
            shouldUnlockRead = true;
            for (Map.Entry<Annot, Integer> entry : mSelectedAnnots.entrySet()) {
                WritableMap annotationData = getAnnotationData(entry.getKey(), entry.getValue());

                if (annotationData != null) {
                    if (overrideAction && isOverrideAction(KEY_CONFIG_STICKY_NOTE_SHOW_POP_UP)) {
                        WritableMap annotationDataCopy = Arguments.createMap();
                        annotationDataCopy.merge(annotationData);
                        try {
                            if (entry.getKey().getType() == Annot.e_Text) {
                                WritableMap params = Arguments.createMap();

                                params.putString(ON_BEHAVIOR_ACTIVATED, ON_BEHAVIOR_ACTIVATED);
                                params.putString(KEY_ACTION, KEY_CONFIG_STICKY_NOTE_SHOW_POP_UP);
                                params.putMap(KEY_DATA, annotationDataCopy);

                                onReceiveNativeEvent(params);
                            }
                        } catch (PDFNetException e) {
                            e.printStackTrace();
                        }
                    }

                    annots.pushMap(annotationData);
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        } finally {
            if (shouldUnlockRead) {
                getPdfViewCtrl().docUnlockRead();
            }
        }

        return annots;
    }

    private WritableMap getAnnotationData(Annot annot, int pageNumber) {
        WritableMap annotPair = Arguments.createMap();

        // try to obtain id
        String uid = null;
        try {
            uid = annot.getUniqueID() != null ? annot.getUniqueID().getAsPDFText() : null;
        } catch (Exception e) {
            e.printStackTrace();
        }

        annotPair.putString(KEY_ANNOTATION_ID, uid == null ? "" : uid);
        annotPair.putInt(KEY_ANNOTATION_PAGE, pageNumber);
        // try to obtain bbox and type
        try {
            annotPair.putString(KEY_ANNOTATION_TYPE, convAnnotTypeToString(annot, AnnotUtils.getAnnotType(annot)));
            // screen rect
            com.pdftron.pdf.Rect screenRect = getPdfViewCtrl().getScreenRectForAnnot(annot, pageNumber);
            WritableMap screenRectMap = Arguments.createMap();
            screenRectMap.putDouble(KEY_X1, screenRect.getX1());
            screenRectMap.putDouble(KEY_Y1, screenRect.getY1());
            screenRectMap.putDouble(KEY_X2, screenRect.getX2());
            screenRectMap.putDouble(KEY_Y2, screenRect.getY2());
            screenRectMap.putDouble(KEY_WIDTH, screenRect.getWidth());
            screenRectMap.putDouble(KEY_HEIGHT, screenRect.getHeight());
            annotPair.putMap(KEY_ANNOTATION_SCREEN_RECT, screenRectMap);
            // page rect
            com.pdftron.pdf.Rect pageRect = getPdfViewCtrl().getPageRectForAnnot(annot, pageNumber);
            WritableMap pageRectMap = Arguments.createMap();
            pageRectMap.putDouble(KEY_X1, pageRect.getX1());
            pageRectMap.putDouble(KEY_Y1, pageRect.getY1());
            pageRectMap.putDouble(KEY_X2, pageRect.getX2());
            pageRectMap.putDouble(KEY_Y2, pageRect.getY2());
            pageRectMap.putDouble(KEY_WIDTH, pageRect.getWidth());
            pageRectMap.putDouble(KEY_HEIGHT, pageRect.getHeight());
            annotPair.putMap(KEY_ANNOTATION_PAGE_RECT, pageRectMap);
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return annotPair;
    }

    private ToolManager.QuickMenuListener mQuickMenuListener = new ToolManager.QuickMenuListener() {
        @Override
        public boolean onQuickMenuClicked(QuickMenuItem quickMenuItem) {
            int menuId = quickMenuItem.getItemId();
            String menuStr = convQuickMenuIdToString(menuId);

            // check if this is an override menu
            boolean result = false;

            if (getPdfViewCtrl() != null && getToolManager() != null) {
                if (hasAnnotationsSelected()) {
                    if (mAnnotMenuOverrideItems != null) {
                        result = mAnnotMenuOverrideItems.contains(menuStr);
                    }
                    try {
                        // notify event
                        WritableMap params = Arguments.createMap();
                        params.putString(ON_ANNOTATION_MENU_PRESS, ON_ANNOTATION_MENU_PRESS);
                        params.putString(KEY_ANNOTATION_MENU, menuStr);
                        params.putArray(KEY_ANNOTATIONS, getAnnotationsData(false));
                        onReceiveNativeEvent(params);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                } else {
                    if (mLongPressMenuOverrideItems != null) {
                        result = mLongPressMenuOverrideItems.contains(menuStr);
                    }
                    try {
                        // notify event
                        WritableMap params = Arguments.createMap();
                        params.putString(ON_LONG_PRESS_MENU_PRESS, ON_LONG_PRESS_MENU_PRESS);
                        params.putString(KEY_LONG_PRESS_MENU, menuStr);
                        params.putString(KEY_LONG_PRESS_TEXT, ViewerUtils.getSelectedString(getPdfViewCtrl()));
                        onReceiveNativeEvent(params);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                    }
                }
            }

            return result;
        }

        @Override
        public boolean onShowQuickMenu(QuickMenu quickMenu, Annot annot) {
            // first check if we need to show at all
            if (mHideAnnotMenuTools != null && annot != null && getPdfViewCtrl() != null) {
                for (Object item : mHideAnnotMenuTools) {
                    if (item instanceof String) {
                        String mode = (String) item;
                        int type = convStringToAnnotType(mode);
                        boolean shouldUnlockRead = false;
                        try {
                            getPdfViewCtrl().docLockRead();
                            shouldUnlockRead = true;

                            int annotType = AnnotUtils.getAnnotType(annot);
                            if (annotType == type) {
                                return true;
                            }
                        } catch (Exception ex) {
                            ex.printStackTrace();
                        } finally {
                            if (shouldUnlockRead) {
                                getPdfViewCtrl().docUnlockRead();
                            }
                        }
                    }
                }
            }

            // remove unwanted items
            ToolManager.Tool currentTool = getToolManager() != null ? getToolManager().getTool() : null;
            boolean isPanOrTextSelect = (currentTool instanceof Pan || (currentTool instanceof TextSelect && !(currentTool instanceof AnnotEditTextMarkup)));
            if (mAnnotMenuItems != null && !isPanOrTextSelect) {
                List<QuickMenuItem> removeList = new ArrayList<>();
                checkQuickMenu(quickMenu.getFirstRowMenuItems(), mAnnotMenuItems, removeList);
                checkQuickMenu(quickMenu.getSecondRowMenuItems(), mAnnotMenuItems, removeList);
                checkQuickMenu(quickMenu.getOverflowMenuItems(), mAnnotMenuItems, removeList);
                quickMenu.removeMenuEntries(removeList);

                if (quickMenu.getFirstRowMenuItems().size() == 0) {
                    quickMenu.setDividerVisibility(View.GONE);
                }
            }
            if (mLongPressMenuItems != null && isPanOrTextSelect) {
                List<QuickMenuItem> removeList = new ArrayList<>();
                checkQuickMenu(quickMenu.getFirstRowMenuItems(), mLongPressMenuItems, removeList);
                checkQuickMenu(quickMenu.getSecondRowMenuItems(), mLongPressMenuItems, removeList);
                checkQuickMenu(quickMenu.getOverflowMenuItems(), mLongPressMenuItems, removeList);
                quickMenu.removeMenuEntries(removeList);

                if (quickMenu.getFirstRowMenuItems().size() == 0) {
                    quickMenu.setDividerVisibility(View.GONE);
                }
            }
            return false;
        }

        @Override
        public void onQuickMenuShown() {

        }

        @Override
        public void onQuickMenuDismissed() {

        }
    };

    private HashMap<Annot, Integer> mSelectedAnnots;
    private ToolManager.AnnotationsSelectionListener mAnnotationsSelectionListener = new ToolManager.AnnotationsSelectionListener() {
        @Override
        public void onAnnotationsSelectionChanged(HashMap<Annot, Integer> hashMap) {
            mSelectedAnnots = new HashMap<>(hashMap);

            if (hasAnnotationsSelected() && getPdfViewCtrl() != null && getToolManager() != null) {
                try {
                    // notify event
                    WritableArray annotationsData = getAnnotationsData(true);
                    WritableMap params = Arguments.createMap();
                    params.putString(ON_ANNOTATIONS_SELECTED, ON_ANNOTATIONS_SELECTED);
                    params.putArray(KEY_ANNOTATIONS, annotationsData);
                    onReceiveNativeEvent(params);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
        }
    };

    private boolean isOverrideAction(String action) {
        return mActionOverrideItems != null && mActionOverrideItems.toArrayList().contains(action);
    }

    private ActionUtils.ActionInterceptCallback mActionInterceptCallback = new ActionUtils.ActionInterceptCallback() {
        @Override
        public boolean onInterceptExecuteAction(ActionParameter actionParameter, PDFViewCtrl pdfViewCtrl) {
            if (!isOverrideAction(KEY_CONFIG_LINK_PRESS)) {
                return false;
            }
            String url = null;
            boolean shouldUnlockRead = false;
            try {
                pdfViewCtrl.docLockRead();
                shouldUnlockRead = true;

                Action action = actionParameter.getAction();
                int action_type = action.getType();
                if (action_type == Action.e_URI) {
                    Obj o = action.getSDFObj();
                    o = o.findObj("URI");
                    if (o != null) {
                        url = o.getAsPDFText();
                    }
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            } finally {
                if (shouldUnlockRead) {
                    pdfViewCtrl.docUnlockRead();
                }
            }
            if (url != null) {
                WritableMap params = Arguments.createMap();
                params.putString(ON_BEHAVIOR_ACTIVATED, ON_BEHAVIOR_ACTIVATED);
                params.putString(KEY_ACTION, KEY_CONFIG_LINK_PRESS);

                WritableMap data = Arguments.createMap();
                data.putString(KEY_LINK_BEHAVIOR_DATA, url);
                params.putMap(KEY_DATA, data);

                onReceiveNativeEvent(params);

                return true;
            }
            return false;
        }
    };

    private PDFViewCtrl.PageChangeListener mPageChangeListener = new PDFViewCtrl.PageChangeListener() {
        @Override
        public void onPageChange(int old_page, int cur_page, PDFViewCtrl.PageChangeState pageChangeState) {
            if (old_page != cur_page || pageChangeState == PDFViewCtrl.PageChangeState.END) {
                WritableMap params = Arguments.createMap();
                params.putString(ON_PAGE_CHANGED, ON_PAGE_CHANGED);
                params.putInt(PREV_PAGE_KEY, old_page);
                params.putInt(PAGE_CURRENT_KEY, cur_page);
                onReceiveNativeEvent(params);
            }
        }
    };

    private PDFViewCtrl.OnCanvasSizeChangeListener mOnCanvasSizeChangeListener = new PDFViewCtrl.OnCanvasSizeChangeListener() {
        @Override
        public void onCanvasSizeChanged() {
            WritableMap params = Arguments.createMap();
            params.putString(ON_ZOOM_CHANGED, ON_ZOOM_CHANGED);
            params.putDouble(ZOOM_KEY, getPdfViewCtrl().getZoom());
            onReceiveNativeEvent(params);
        }
    };

    private PDFViewCtrl.TextSearchListener mTextSearchListener = new PDFViewCtrl.TextSearchListener() {
        @Override
        public void onTextSearchStart() {
            WritableMap params = Arguments.createMap();
            params.putString(ON_TEXT_SEARCH_START, ON_TEXT_SEARCH_START);
            onReceiveNativeEvent(params);
        }

        @Override
        public void onTextSearchProgress(int i) {
        }

        @Override
        public void onTextSearchEnd(PDFViewCtrl.TextSearchResult textSearchResult) {
            WritableMap params = Arguments.createMap();
            params.putString(ON_TEXT_SEARCH_RESULT, ON_TEXT_SEARCH_RESULT);

            PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

            if (textSearchResult.equals(PDFViewCtrl.TextSearchResult.FOUND)) {
                params.putBoolean(KEY_TEXT_SELECTION_FOUND, true);
                int currentPage = pdfViewCtrl.getCurrentPage();
                PDFViewCtrl.Selection selection = pdfViewCtrl.getSelection(currentPage);
                params.putMap(KEY_TEXT_SELECTION, getMapFromSelection(selection));
            } else {
                params.putBoolean(KEY_TEXT_SELECTION_FOUND, false);
            }

            onReceiveNativeEvent(params);
        }
    };

    private ToolManager.AnnotationModificationListener mAnnotationModificationListener = new ToolManager.AnnotationModificationListener() {
        @Override
        public void onAnnotationsAdded(Map<Annot, Integer> map) {
            handleAnnotationChanged(KEY_ACTION_ADD, map);

            handleExportAnnotationCommand(KEY_ACTION_ADD, map);
        }

        @Override
        public void onAnnotationsPreModify(Map<Annot, Integer> map) {

        }

        @Override
        public void onAnnotationsModified(Map<Annot, Integer> map, Bundle bundle) {
            handleAnnotationChanged(KEY_ACTION_MODIFY, map);

            handleExportAnnotationCommand(KEY_ACTION_MODIFY, map);

            // handle form fields change
            WritableMap params = Arguments.createMap();
            params.putString(ON_FORM_FIELD_VALUE_CHANGED, ON_FORM_FIELD_VALUE_CHANGED);
            WritableArray fieldsArray = Arguments.createArray();
            for (Map.Entry<Annot, Integer> entry : map.entrySet()) {
                Annot annot = entry.getKey();
                try {
                    if (annot != null && annot.isValid()) {
                        if (annot.getType() == Annot.e_Widget) {
                            WritableMap resultMap = getField(annot);
                            if (resultMap != null) {
                                fieldsArray.pushMap(resultMap);
                            }
                        }
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            if (fieldsArray.size() > 0) {
                params.putArray(KEY_FIELDS, fieldsArray);
                onReceiveNativeEvent(params);
            }
        }

        @Override
        public void onAnnotationsPreRemove(Map<Annot, Integer> map) {
            handleAnnotationChanged(KEY_ACTION_DELETE, map);

            handleExportAnnotationCommand(KEY_ACTION_DELETE, map);
        }

        @Override
        public void onAnnotationsRemoved(Map<Annot, Integer> map) {
            ToolManager toolManager = getToolManager();
            if (toolManager != null) {
                ToolManager.AnnotAction lastAction = toolManager.getLastAnnotAction();
                if (lastAction == ToolManager.AnnotAction.FLATTEN) {
                    WritableMap params = Arguments.createMap();
                    params.putString(ON_ANNOTATION_FLATTENED, ON_ANNOTATION_FLATTENED);
                    WritableArray annotList = Arguments.createArray();
                    for (Map.Entry<Annot, Integer> entry : map.entrySet()) {
                        Annot key = entry.getKey();

                        String uid = null;
                        try {
                            uid = key.getUniqueID() != null ? key.getUniqueID().getAsPDFText() : "";
                        } catch (Exception e) {
                            e.printStackTrace();
                        }

                        WritableMap annotData = Arguments.createMap();
                        annotData.putString(KEY_ANNOTATION_ID, Utils.isNullOrEmpty(uid) ? null : uid);
                        annotData.putInt(KEY_ANNOTATION_PAGE, entry.getValue());
                        try {
                            annotData.putString(KEY_ANNOTATION_TYPE, convAnnotTypeToString(key, key.getType()));
                        } catch (PDFNetException e) {
                            e.printStackTrace();
                        }
                        annotList.pushMap(annotData);
                    }

                    params.putArray(KEY_ANNOTATIONS, annotList);
                    onReceiveNativeEvent(params);
                }
            }
        }

        @Override
        public void onAnnotationsRemovedOnPage(int i) {

        }

        @Override
        public void annotationsCouldNotBeAdded(String s) {

        }
    };

    private ToolManager.PdfDocModificationListener mPdfDocModificationListener = new ToolManager.PdfDocModificationListener() {

        @Override
        public void onBookmarkModified(@NonNull List<UserBookmarkItem> bookmarkItems) {
            if (getPdfDoc() != null) {
                WritableMap params = Arguments.createMap();
                params.putString(ON_BOOKMARK_CHANGED, ON_BOOKMARK_CHANGED);
                String bookmarkJson = null;
                try {
                    bookmarkJson = BookmarkManager.exportPdfBookmarks(getPdfDoc());
                } catch (JSONException ex) {
                    ex.printStackTrace();
                }

                if (bookmarkJson == null) {
                    params.putString(KEY_ERROR, "Bookmark cannot be exported");
                } else {
                    params.putString(KEY_BOOKMARK_JSON, bookmarkJson);
                }

                onReceiveNativeEvent(params);
            }
        }

        @Override
        public void onPagesCropped() {

        }

        @Override
        public void onPagesAdded(List<Integer> list) {
            WritableMap params = Arguments.createMap();
            WritableArray pageNumbers = Arguments.fromList(list);
            params.putString(ON_PAGES_ADDED, ON_PAGES_ADDED);
            params.putArray(KEY_PAGE_NUMBERS, pageNumbers);

            onReceiveNativeEvent(params);
        }

        @Override
        public void onPagesDeleted(List<Integer> list) {
            WritableMap params = Arguments.createMap();
            WritableArray pageNumbers = Arguments.fromList(list);
            params.putString(ON_PAGES_REMOVED, ON_PAGES_REMOVED);
            params.putArray(KEY_PAGE_NUMBERS, pageNumbers);

            onReceiveNativeEvent(params);
        }

        @Override
        public void onPagesRotated(List<Integer> list) {
            WritableMap params = Arguments.createMap();
            WritableArray pageNumbers = Arguments.fromList(list);
            params.putString(ON_PAGES_ROTATED, ON_PAGES_ROTATED);
            params.putArray(KEY_PAGE_NUMBERS, pageNumbers);

            onReceiveNativeEvent(params);
        }

        @Override
        public void onPageMoved(int from, int to) {
            WritableMap params = Arguments.createMap();
            params.putString(ON_PAGE_MOVED, ON_PAGE_MOVED);
            params.putInt(PREV_PAGE_KEY, from);
            params.putInt(PAGE_CURRENT_KEY, to);

            onReceiveNativeEvent(params);
        }

        @Override
        public void onPagesMoved(List<Integer> pagesMoved, int to, int currentPage) {

        }

        @Override
        public void onPageLabelsChanged() {

        }

        @Override
        public void onAllAnnotationsRemoved() {

        }

        @Override
        public void onAnnotationAction() {

        }
    };

    private final ToolManager.ToolChangedListener mToolChangedListener = new ToolManager.ToolChangedListener() {
        @Override
        public void toolChanged(ToolManager.Tool newTool, @Nullable ToolManager.Tool oldTool) {

            String newToolString = null;
            if (newTool != null) {
                newToolString = convToolModeToString((ToolManager.ToolMode) newTool.getToolMode());
            }

            String oldToolString = null;
            if (oldTool != null) {
                oldToolString = convToolModeToString((ToolManager.ToolMode) oldTool.getToolMode());
            }

            String unknownString = "unknown tool";

            WritableMap params = Arguments.createMap();
            params.putString(ON_TOOL_CHANGED, ON_TOOL_CHANGED);
            params.putString(KEY_PREVIOUS_TOOL, oldToolString != null ? oldToolString : unknownString);
            params.putString(KEY_TOOL, newToolString != null ? newToolString : unknownString);

            onReceiveNativeEvent(params);
        }
    };

    private View.OnLayoutChangeListener mLayoutChangedListener = new OnLayoutChangeListener() {
        @Override
        public void onLayoutChange(View view, int i, int i1, int i2, int i3, int i4, int i5, int i6, int i7) {

            WritableMap params = Arguments.createMap();
            params.putString(ON_LAYOUT_CHANGED, ON_LAYOUT_CHANGED);

            onReceiveNativeEvent(params);
        }
    };

    private UndoRedoManager.UndoRedoStateChangeListener mUndoRedoStateChangedListener = new UndoRedoManager.UndoRedoStateChangeListener() {
        @Override
        public void onStateChanged() {
            WritableMap params = Arguments.createMap();
            params.putString(ON_UNDO_REDO_STATE_CHANGED, ON_UNDO_REDO_STATE_CHANGED);

            onReceiveNativeEvent(params);
        }
    };

    private final StampManager.SignatureListener mSignatureListener = new StampManager.SignatureListener() {
        @Override
        public void onSavedSignatureDeleted() {
            WritableMap params = Arguments.createMap();
            params.putString(ON_SAVED_SIGNATURES_CHANGED, ON_SAVED_SIGNATURES_CHANGED);

            onReceiveNativeEvent(params);
        }

        @Override
        public void onSavedSignatureCreated() {
            WritableMap params = Arguments.createMap();
            params.putString(ON_SAVED_SIGNATURES_CHANGED, ON_SAVED_SIGNATURES_CHANGED);

            onReceiveNativeEvent(params);
        }
    };

    private final PdfViewCtrlTabHostFragment2.OnToolbarChangedListener mToolbarChangedListener = new PdfViewCtrlTabHostFragment2.OnToolbarChangedListener() {
        @Override
        public void onToolbarChanged(String toolbar) {
            WritableMap params = Arguments.createMap();
            params.putString(ON_CURRENT_TOOLBAR_CHANGED, ON_CURRENT_TOOLBAR_CHANGED);
            params.putString(KEY_TOOLBAR, toolbar);

            onReceiveNativeEvent(params);
        }
    };

    private void handleAnnotationChanged(String action, Map<Annot, Integer> map) {
        WritableMap params = Arguments.createMap();
        params.putString(ON_ANNOTATION_CHANGED, ON_ANNOTATION_CHANGED);
        params.putString(KEY_ACTION, action);

        WritableArray annotList = Arguments.createArray();
        for (Map.Entry<Annot, Integer> entry : map.entrySet()) {
            Annot key = entry.getKey();

            String uid = null;
            try {
                uid = key.getUniqueID() != null ? key.getUniqueID().getAsPDFText() : null;
            } catch (Exception e) {
                e.printStackTrace();
            }

            if (uid == null) {
                uid = UUID.randomUUID().toString();
                try {
                    key.setUniqueID(uid);
                } catch (PDFNetException e) {
                    e.printStackTrace();
                    uid = null;
                }
            }

            WritableMap annotData = Arguments.createMap();
            annotData.putString(KEY_ANNOTATION_ID, uid == null ? "" : uid);
            annotData.putInt(KEY_ANNOTATION_PAGE, entry.getValue());
            try {
                annotData.putString(KEY_ANNOTATION_TYPE, convAnnotTypeToString(key, key.getType()));
            } catch (PDFNetException e) {
                e.printStackTrace();
            }
            annotList.pushMap(annotData);
        }

        params.putArray(KEY_ANNOTATIONS, annotList);
        onReceiveNativeEvent(params);
    }

    private void handleExportAnnotationCommand(String action, Map<Annot, Integer> map) {
        if (mCollabManager == null) {
            // fallback for export annotations when collab not present
            ArrayList<Annot> annots = new ArrayList<>(map.keySet());
            String xfdfCommand = null;
            try {
                if (KEY_ACTION_ADD.equals(action)) {
                    xfdfCommand = generateXfdfCommand(annots, null, null);
                } else if (KEY_ACTION_MODIFY.equals(action)) {
                    xfdfCommand = generateXfdfCommand(null, annots, null);
                } else {
                    xfdfCommand = generateXfdfCommand(null, null, annots);
                }
            } catch (PDFNetException e) {
                e.printStackTrace();
            }

            WritableArray annotList = Arguments.createArray();
            for (Map.Entry<Annot, Integer> entry : map.entrySet()) {
                Annot key = entry.getKey();

                String uid = null;
                try {
                    uid = key.getUniqueID() != null ? key.getUniqueID().getAsPDFText() : null;
                } catch (Exception e) {
                    e.printStackTrace();
                }

                if (uid == null) {
                    uid = UUID.randomUUID().toString();
                    try {
                        key.setUniqueID(uid);
                    } catch (PDFNetException e) {
                        e.printStackTrace();
                        uid = null;
                    }
                }

                WritableMap annotData = Arguments.createMap();
                annotData.putString(KEY_ANNOTATION_ID, uid == null ? "" : uid);
                annotData.putInt(KEY_ANNOTATION_PAGE, entry.getValue());
                try {
                    annotData.putString(KEY_ANNOTATION_TYPE, convAnnotTypeToString(key, key.getType()));
                } catch (PDFNetException e) {
                    e.printStackTrace();
                }
                annotList.pushMap(annotData);
            }

            WritableMap params = Arguments.createMap();
            params.putString(ON_EXPORT_ANNOTATION_COMMAND, ON_EXPORT_ANNOTATION_COMMAND);
            if (xfdfCommand == null) {
                params.putString(KEY_ERROR, "XFDF command cannot be generated");
            } else {
                params.putString(KEY_ACTION, action);
                params.putString(KEY_XFDF_COMMAND, xfdfCommand);
                params.putArray(KEY_ANNOTATIONS, annotList);
            }
            onReceiveNativeEvent(params);
        }
    }

    // helper
    @Nullable
    private String generateXfdfCommand(@Nullable ArrayList<Annot> added,
            @Nullable ArrayList<Annot> modified,
            @Nullable ArrayList<Annot> removed) throws PDFNetException {
        PDFDoc pdfDoc = getPdfDoc();
        if (pdfDoc != null) {
            FDFDoc fdfDoc = pdfDoc.fdfExtract(added, modified, removed);
            return fdfDoc.saveAsXFDF();
        }
        return null;
    }

    @Override
    public void onTabDocumentLoaded(String tag) {
        super.onTabDocumentLoaded(tag);

        // set react context
        if (getPdfViewCtrlTabFragment() instanceof RNPdfViewCtrlTabFragment) {
            RNPdfViewCtrlTabFragment fragment = (RNPdfViewCtrlTabFragment) getPdfViewCtrlTabFragment();
            fragment.setReactContext((ReactContext) getContext(), getId());
        }

        // Hide add page annotation toolbar button
        if (!mShowAddPageToolbarButton) {
            mPdfViewCtrlTabHostFragment.toolbarButtonVisibility(ToolbarButtonType.ADD_PAGE, false);
        }

        if (!mCollabEnabled && getToolManager() != null) {
            getToolManager().setStickyNoteShowPopup(!isOverrideAction(KEY_CONFIG_STICKY_NOTE_SHOW_POP_UP));
        }

        if (mInitialPageNumber > 0) {
            try {
                getPdfViewCtrl().setCurrentPage(mInitialPageNumber);
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }

        if (!mAutoSaveEnabled) {
            getPdfViewCtrlTabFragment().setSavingEnabled(mAutoSaveEnabled);
        }

        if (mReadOnly) {
            getToolManager().setReadOnly(true);
        }

        if (mOverflowResName != null && mPdfViewCtrlTabHostFragment != null && mPdfViewCtrlTabHostFragment.getToolbar() != null) {
            int res = Utils.getResourceDrawable(this.getContext(), mOverflowResName);
            if (res != 0) {
                Drawable icon = Utils.getDrawable(this.getContext(), res);
                mPdfViewCtrlTabHostFragment.getToolbar().setOverflowIcon(icon);
            }
        }

        getPdfViewCtrl().addPageChangeListener(mPageChangeListener);
        getPdfViewCtrl().addOnCanvasSizeChangeListener(mOnCanvasSizeChangeListener);
        getPdfViewCtrl().addOnLayoutChangeListener(mLayoutChangedListener);
        getPdfViewCtrl().addTextSearchListener(mTextSearchListener);

        getToolManager().addAnnotationModificationListener(mAnnotationModificationListener);
        getToolManager().addAnnotationsSelectionListener(mAnnotationsSelectionListener);
        getToolManager().addPdfDocModificationListener(mPdfDocModificationListener);
        getToolManager().addToolChangedListener(mToolChangedListener);

        getToolManager().setStylusAsPen(mUseStylusAsPen);
        getToolManager().setSignSignatureFieldsWithStamps(mSignWithStamps);

        getToolManager().getUndoRedoManger().addUndoRedoStateChangeListener(mUndoRedoStateChangedListener);

        getPdfViewCtrlTabFragment().addQuickMenuListener(mQuickMenuListener);

        StampManager.getInstance().setSignatureListener(mSignatureListener);

        ActionUtils.getInstance().setActionInterceptCallback(mActionInterceptCallback);

        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.addOnToolbarChangedListener(mToolbarChangedListener);
        }

        // collab
        if (mPdfViewCtrlTabHostFragment instanceof CollabViewerTabHostFragment2) {
            CollabViewerTabHostFragment2 collabHost = (CollabViewerTabHostFragment2) mPdfViewCtrlTabHostFragment;
            mCollabManager = collabHost.getCollabManager();
            if (mCollabManager != null) {
                if (mCurrentUser != null) {
                    mCollabManager.setCurrentUser(mCurrentUser, mCurrentUserName);
                    mCollabManager.setCurrentDocument(mDocumentPath);
                    mCollabManager.setCollabManagerListener(new CollabManager.CollabManagerListener() {
                        @Override
                        public void onSendAnnotation(String s, ArrayList<AnnotationEntity> arrayList, String s1, @Nullable String s2) {
                            if (mCollabManager != null) {
                                WritableMap params = Arguments.createMap();

                                WritableArray annotList = Arguments.createArray();
                                for (AnnotationEntity annot : arrayList) {
                                    String uid = null;
                                    try {
                                        uid = annot.getId();
                                    } catch (Exception e) {
                                        e.printStackTrace();
                                    }

                                    if (uid == null) {
                                        uid = UUID.randomUUID().toString();
                                        try {
                                            annot.setId(uid);
                                        } catch (Exception e) {
                                            e.printStackTrace();
                                            uid = null;
                                        }
                                    }

                                    WritableMap annotData = Arguments.createMap();
                                    annotData.putString(KEY_ANNOTATION_ID, uid == null ? "" : uid);
                                    annotList.pushMap(annotData);
                                }

                                params.putString(ON_EXPORT_ANNOTATION_COMMAND, ON_EXPORT_ANNOTATION_COMMAND);
                                params.putString(KEY_ACTION, s);
                                params.putString(KEY_XFDF_COMMAND, mCollabManager.getLastXfdf());
                                params.putArray(KEY_ANNOTATIONS, annotList);
                                onReceiveNativeEvent(params);
                            }
                        }
                    });
                }
            }
        }

        if (mHideToolbarsOnAppear) {
            mPdfViewCtrlTabHostFragment.setToolbarsVisible(false, false);
        }

        onReceiveNativeEvent(ON_DOCUMENT_LOADED, tag);
    }

    @Override
    public void onTabHostShown() {
        super.onTabHostShown();
        if (getPdfViewCtrlTabFragment() != null) {
            getPdfViewCtrlTabFragment().setStateEnabled(mSaveStateEnabled);
        }
    }

    @Override
    public void onTabChanged(String tag) {
        super.onTabChanged(tag);
        if (getPdfViewCtrlTabFragment() != null) {
            getPdfViewCtrlTabFragment().setStateEnabled(mSaveStateEnabled);
        }

        WritableMap params = Arguments.createMap();
        params.putString(ON_TAB_CHANGED, ON_TAB_CHANGED);
        params.putString(KEY_CURRENT_TAB, tag);

        onReceiveNativeEvent(params);
    }

    @Override
    public boolean onOpenDocError() {
        super.onOpenDocError();

        String error = "Unknown error";
        if (getPdfViewCtrlTabFragment() != null) {
            int messageId = R.string.error_opening_doc_message;
            int errorCode = getPdfViewCtrlTabFragment().getTabErrorCode();
            switch (errorCode) {
                case PdfDocManager.DOCUMENT_SETDOC_ERROR_ZERO_PAGE:
                    messageId = R.string.error_empty_file_message;
                    break;
                case PdfDocManager.DOCUMENT_SETDOC_ERROR_OPENURL_CANCELLED:
                    messageId = R.string.download_cancelled_message;
                    break;
                case PdfDocManager.DOCUMENT_SETDOC_ERROR_WRONG_PASSWORD:
                    messageId = R.string.password_not_valid_message;
                    break;
                case PdfDocManager.DOCUMENT_SETDOC_ERROR_NOT_EXIST:
                    messageId = R.string.file_does_not_exist_message;
                    break;
                case PdfDocManager.DOCUMENT_SETDOC_ERROR_DOWNLOAD_CANCEL:
                    messageId = R.string.download_size_cancelled_message;
                    break;
            }
            error = mPdfViewCtrlTabHostFragment.getString(messageId);
        }
        onReceiveNativeEvent(ON_DOCUMENT_ERROR, error);
        return true;
    }

    // Hygen Generated Event Listeners

    public void importBookmarkJson(String bookmarkJson) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        PDFDoc pdfDoc = pdfViewCtrl.getDoc();

        boolean shouldUnlockRead = false;
        try {
            pdfViewCtrl.docLockRead();
            shouldUnlockRead = true;

            if (pdfDoc.hasDownloader()) {
                // still downloading file, let's wait for next call
                return;
            }
        } finally {
            if (shouldUnlockRead) {
                pdfViewCtrl.docUnlockRead();
            }
        }

        boolean shouldUnlock = false;
        try {
            pdfViewCtrl.docLock(true);
            shouldUnlock = true;

            BookmarkManager.importPdfBookmarks(pdfViewCtrl, bookmarkJson);
            PdfViewCtrlTabHostFragment2 hostFragment = getViewer();
            if (hostFragment != null) {
                hostFragment.reloadUserBookmarks();
            }
        } catch (JSONException ex) {
            throw new PDFNetException("", 0L, TAG, "importBookmarkJson", "Unable to parse bookmark json.");
        } finally {
            if (shouldUnlock) {
                pdfViewCtrl.docUnlock();
            }
        }
    }

    public void openBookmarkList() {
        if (isBookmarkListVisible && mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.onOutlineOptionSelected(0);
        }
    }

    public void importAnnotationCommand(String xfdfCommand, boolean initialLoad) throws PDFNetException {
        if (mCollabManager != null) {
            mCollabManager.importAnnotationCommand(xfdfCommand, initialLoad);
        } else {
            PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
            PDFDoc pdfDoc = getPdfDoc();
            if (null == pdfViewCtrl || null == pdfDoc || null == xfdfCommand) {
                return;
            }
            boolean shouldUnlockRead = false;
            try {
                pdfViewCtrl.docLockRead();
                shouldUnlockRead = true;

                if (pdfDoc.hasDownloader()) {
                    // still downloading file, let's wait for next call
                    return;
                }
            } finally {
                if (shouldUnlockRead) {
                    pdfViewCtrl.docUnlockRead();
                }
            }

            boolean shouldUnlock = false;
            try {
                pdfViewCtrl.docLock(true);
                shouldUnlock = true;

                FDFDoc fdfDoc = pdfDoc.fdfExtract(PDFDoc.e_both);
                fdfDoc.mergeAnnots(xfdfCommand);

                pdfDoc.fdfUpdate(fdfDoc);
                pdfViewCtrl.update(true);
            } finally {
                if (shouldUnlock) {
                    pdfViewCtrl.docUnlock();
                }
            }
        }
    }

    public WritableArray importAnnotations(String xfdf, boolean replace) throws PDFNetException {
        if (mCollabManager != null) {
            mCollabManager.importAnnotations(xfdf, false);
            return getAnnotationsFromXFDF(xfdf);
        } else {
            PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

            PDFDoc pdfDoc = pdfViewCtrl.getDoc();

            boolean shouldUnlockRead = false;
            try {
                pdfViewCtrl.docLockRead();
                shouldUnlockRead = true;

                if (pdfDoc.hasDownloader()) {
                    // still downloading file, let's wait for next call
                    return null;
                }
            } finally {
                if (shouldUnlockRead) {
                    pdfViewCtrl.docUnlockRead();
                }
            }

            boolean shouldUnlock = false;
            try {
                pdfViewCtrl.docLock(true);
                shouldUnlock = true;

                FDFDoc fdfDoc = FDFDoc.createFromXFDF(xfdf);
                if (replace) {
                    pdfDoc.fdfUpdate(fdfDoc);
                } else {
                    pdfDoc.fdfMerge(fdfDoc);
                }
                pdfViewCtrl.update(true);
                return getAnnotationsFromXFDF(xfdf);
            } finally {
                if (shouldUnlock) {
                    pdfViewCtrl.docUnlock();
                }
            }
        }
    }

    private static Integer safeGetObjAsInteger(Obj obj, String key) throws PDFNetException {
        if (obj != null) {
            Obj result = obj.findObj(key);
            if (result != null && result.isNumber()) {
                double number = result.getNumber();
                return (int) number;
            }
        }
        return null;
    }

    private static WritableArray getAnnotationsFromXFDF(String xfdf) throws PDFNetException {
        WritableArray annotations = Arguments.createArray();
        FDFDoc fdfDoc = FDFDoc.createFromXFDF(xfdf);
        Obj fdf = fdfDoc.getFDF();
        if (fdf != null) {
            Obj annots = fdf.findObj(Keys.FDF_ANNOTS);
            if (annots != null && annots.isArray()) {
                long size = annots.size();
                for (int i = 0; i < size; i++) {
                    Obj annotObj = annots.getAt(i);

                    if (annotObj != null) {
                        WritableMap annotPair = Arguments.createMap();
                        Annot annot = new Annot(annotObj);
                        String annotId = annot.getUniqueID().getAsPDFText();
                        Integer page = safeGetObjAsInteger(annotObj, Keys.FDF_PAGE) + 1;
                        annotPair.putString(KEY_ANNOTATION_ID, annotId);
                        annotPair.putInt(KEY_ANNOTATION_PAGE, page);
                        annotations.pushMap(annotPair);
                    }
                }
            }
        }
        return annotations;
    }

    public String exportAnnotations(ReadableMap options) throws Exception {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        boolean shouldUnlockRead = false;
        try {
            pdfViewCtrl.docLockRead();
            shouldUnlockRead = true;

            PDFDoc pdfDoc = pdfViewCtrl.getDoc();
            if (null == options || !options.hasKey(KEY_ANNOTATION_LIST)) {
                FDFDoc fdfDoc = pdfDoc.fdfExtract(PDFDoc.e_both);
                return fdfDoc.saveAsXFDF();
            } else {
                ReadableArray arr = options.getArray(KEY_ANNOTATION_LIST);
                ArrayList<Annot> annots = new ArrayList<>(arr.size());
                for (int i = 0; i < arr.size(); i++) {
                    ReadableMap annotData = arr.getMap(i);
                    String id = annotData.getString(KEY_ANNOTATION_ID);
                    int page = annotData.getInt(KEY_ANNOTATION_PAGE);
                    if (!Utils.isNullOrEmpty(id)) {
                        Annot ann = ViewerUtils.getAnnotById(getPdfViewCtrl(), id, page);
                        if (ann != null && ann.isValid()) {
                            annots.add(ann);
                        }
                    }
                }
                if (annots.size() > 0) {
                    FDFDoc fdfDoc = pdfDoc.fdfExtract(annots);
                    return fdfDoc.saveAsXFDF();
                }
                return "";
            }
        } finally {
            if (shouldUnlockRead) {
                pdfViewCtrl.docUnlockRead();
            }
        }
    }

    public String saveDocument() {
        if (getPdfViewCtrlTabFragment() != null) {
            commitTool();
            if (mCollabEnabled) {
                try {
                    if (mCollabTempFile == null || !mCollabTempFile.exists()) {
                        mCollabTempFile = File.createTempFile("tmp", ".pdf");
                    }
                    FileUtils.copyFile(getPdfViewCtrlTabFragment().getFile(), mCollabTempFile);
                    if (getToolManager() != null && getToolManager().getAnnotManager() != null) {
                        getToolManager().getAnnotManager().exportToFile(mCollabTempFile);
                        return mCollabTempFile.getAbsolutePath();
                    }
                    return "";
                } catch (Exception e) {
                    e.printStackTrace();
                    return "";
                }
            }
            getPdfViewCtrlTabFragment().setSavingEnabled(true);
            getPdfViewCtrlTabFragment().save(false, true, true);
            getPdfViewCtrlTabFragment().setSavingEnabled(mAutoSaveEnabled);

            if (getPdfViewCtrlTabFragment() != null && getPdfViewCtrlTabFragment().getFile() != null) {
                File file = getPdfViewCtrlTabFragment().getFile();
                if (mIsBase64) {
                    try {
                        byte[] data = FileUtils.readFileToByteArray(file);
                        return Base64.encodeToString(data, Base64.DEFAULT);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                        return "";
                    }
                } else {
                    if (getPdfViewCtrlTabFragment() != null) {
                        return getPdfViewCtrlTabFragment().getFilePath();
                    }
                }
            }
        }
        return null;
    }

    public void flattenAnnotations(boolean formsOnly) throws PDFNetException {
        // go back to pan tool first so it will commit currently typing text boxes
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        if (pdfViewCtrl.getToolManager() instanceof ToolManager) {
            ToolManager toolManager = (ToolManager) pdfViewCtrl.getToolManager();
            toolManager.setTool(toolManager.createTool(ToolManager.ToolMode.PAN, toolManager.getTool()));
        }

        PDFDoc pdfDoc = pdfViewCtrl.getDoc();

        boolean shouldUnlock = false;
        try {
            pdfViewCtrl.docLock(true);
            shouldUnlock = true;

            pdfDoc.flattenAnnotations(formsOnly);
        } finally {
            if (shouldUnlock) {
                pdfViewCtrl.docUnlock();
            }
        }
    }

    public int getPageCount() throws PDFNetException {
        return getPdfDoc().getPageCount();
    }

    public void deleteAnnotations(ReadableArray annots) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        int annotCount = annots.size();
        ToolManager toolManager = (ToolManager) pdfViewCtrl.getToolManager();

        for (int i = 0; i < annotCount; i++) {
            ReadableMap annotData = annots.getMap(i);
            if (null == annotData) {
                continue;
            }
            String annotId = annotData.getString(KEY_ANNOTATION_ID);
            int pageNum = annotData.getInt(KEY_ANNOTATION_PAGE);
            Annot annot = ViewerUtils.getAnnotById(pdfViewCtrl, annotId, pageNum);
            if (annot != null && annot.isValid()) {
                boolean shouldUnlock = false;
                try {
                    pdfViewCtrl.docLock(true);
                    shouldUnlock = true;

                    HashMap<Annot, Integer> map = new HashMap<>(1);
                    map.put(annot, pageNum);
                    toolManager.raiseAnnotationsPreRemoveEvent(map);

                    Page page = pdfViewCtrl.getDoc().getPage(pageNum);
                    page.annotRemove(annot);
                    pdfViewCtrl.update(annot, pageNum);

                    toolManager.raiseAnnotationsRemovedEvent(map);
                } finally {
                    if (shouldUnlock) {
                        pdfViewCtrl.docUnlock();
                    }
                }
                toolManager.deselectAll();
            }
        }
    }

    public WritableMap getAnnotationAt(int x, int y, double distanceThreshold, double minimumLineWeight) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        PDFDoc doc = getPdfDoc();

        WritableMap annotation = null;

        if (pdfViewCtrl != null && doc != null) {
            boolean shouldUnlockRead = false;
            try {
                doc.lockRead();
                shouldUnlockRead = true;
                Annot annot = pdfViewCtrl.getAnnotationAt(x, y, distanceThreshold, minimumLineWeight);

                if (annot != null && annot.isValid()) {
                    annotation = getAnnotationData(annot, pdfViewCtrl.getPageNumberFromScreenPt(x, y));
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            } finally {
                if (shouldUnlockRead) {
                    doc.unlockRead();
                }
            }
        }

        return annotation;
    }

    public WritableArray getAnnotationListAt(int x1, int y1, int x2, int y2) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        PDFDoc doc = getPdfDoc();

        WritableArray annotations = Arguments.createArray();

        if (pdfViewCtrl != null && doc != null) {
            boolean shouldUnlockRead = false;
            try {
                doc.lockRead();
                shouldUnlockRead = true;
                ArrayList<Annot> annots = pdfViewCtrl.getAnnotationListAt(x1, y1, x2, y2);
                int pageNumber = pdfViewCtrl.getPageNumberFromScreenPt(x1, y1);
                for (Annot annot : annots) {
                    if (annot.isValid()) {
                        annotations.pushMap(getAnnotationData(annot, pageNumber));
                    }
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            } finally {
                if (shouldUnlockRead) {
                    doc.unlockRead();
                }
            }
        }

        return annotations;
    }

    public WritableArray getAnnotationListOnPage(int pageNumber) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        PDFDoc doc = getPdfDoc();

        WritableArray annotations = Arguments.createArray();

        if (pdfViewCtrl != null && doc != null) {
            boolean shouldUnlockRead = false;
            try {
                doc.lockRead();
                shouldUnlockRead = true;
                ArrayList<Annot> annots = pdfViewCtrl.getAnnotationsOnPage(pageNumber);
                for (Annot annot : annots) {
                    if (annot.isValid()) {
                        annotations.pushMap(getAnnotationData(annot, pageNumber));
                    }
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            } finally {
                if (shouldUnlockRead) {
                    doc.unlockRead();
                }
            }
        }

        return annotations;
    }

    public void openAnnotationList() {
        if (isBookmarkListVisible) {
            if (isOutlineListVisible) {
                if (isAnnotationListVisible && mPdfViewCtrlTabHostFragment != null) {
                    mPdfViewCtrlTabHostFragment.onOutlineOptionSelected(2);
                }
            } else {
                if (isAnnotationListVisible && mPdfViewCtrlTabHostFragment != null) {
                    mPdfViewCtrlTabHostFragment.onOutlineOptionSelected(1);
                }
            }
        } else {
            if (isOutlineListVisible) {
                if (isAnnotationListVisible && mPdfViewCtrlTabHostFragment != null) {
                    mPdfViewCtrlTabHostFragment.onOutlineOptionSelected(1);
                }
            } else {
                if (isAnnotationListVisible && mPdfViewCtrlTabHostFragment != null) {
                    mPdfViewCtrlTabHostFragment.onOutlineOptionSelected(0);
                }
            }
        }
    }

    public String getCustomDataForAnnotation(String annotationID, int pageNumber, String key) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        String customData = "";

        if (pdfViewCtrl != null) {
            boolean shouldUnlockRead = false;
            try {
                pdfViewCtrl.docLockRead();
                shouldUnlockRead = true;
                Annot annot = ViewerUtils.getAnnotById(pdfViewCtrl, annotationID, pageNumber);
                if (annot != null) {
                    customData = annot.getCustomData(key);
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (shouldUnlockRead) {
                    pdfViewCtrl.docUnlockRead();
                }
            }
        }

        return customData;
    }

    public void setAnnotationToolbarItemEnabled(String itemId, boolean enable) {
        if (mPdfViewCtrlTabHostFragment != null &&
                mPdfViewCtrlTabHostFragment instanceof RNPdfViewCtrlTabHostFragment) {
            int buttonId = convStringToButtonId(itemId);
            if (buttonId == 0) {
                for (int i = 0; i < mToolIdMap.size(); i++) {
                    if (mToolIdMap.valueAt(i).equals(itemId)) {
                        buttonId = mToolIdMap.keyAt(i);
                        break;
                    }
                }
            }
            ((RNPdfViewCtrlTabHostFragment) mPdfViewCtrlTabHostFragment).setItemEnabled(buttonId, enable);
        }
    }

    public void setValuesForFields(ReadableMap readableMap) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        PDFDoc pdfDoc = pdfViewCtrl.getDoc();

        boolean shouldUnlock = false;
        try {
            pdfViewCtrl.docLock(true);
            shouldUnlock = true;

            ReadableMapKeySetIterator iterator = readableMap.keySetIterator();
            while (iterator.hasNextKey()) {
                String fieldName = iterator.nextKey();

                if (fieldName == null) continue;

                // loop through all fields looking for a matching name
                // in case multiple form fields share the same name
                Field field = pdfDoc.getField(fieldName);
                if (field != null && field.isValid()) {
                    setFieldValue(field, fieldName, readableMap);
                }
            }
        } finally {
            if (shouldUnlock) {
                pdfViewCtrl.docUnlock();
            }
        }
    }

    // write lock required around this method
    private void setFieldValue(@NonNull Field field, @NonNull String fieldName, @NonNull ReadableMap readableMap) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        int fieldType = field.getType();
        switch (readableMap.getType(fieldName)) {
            case Boolean: {
                boolean fieldValue = readableMap.getBoolean(fieldName);
                if (Field.e_check == fieldType) {
                    ViewChangeCollection view_change = field.setValue(fieldValue);
                    pdfViewCtrl.refreshAndUpdate(view_change);
                }
            }
            break;
            case Number: {
                if (Field.e_text == fieldType) {
                    double fieldValue = readableMap.getDouble(fieldName);
                    ViewChangeCollection view_change = field.setValue(String.valueOf(fieldValue));
                    pdfViewCtrl.refreshAndUpdate(view_change);
                }
            }
            break;
            case String: {
                String fieldValue = readableMap.getString(fieldName);
                if (fieldValue != null &&
                        (Field.e_text == fieldType ||
                                Field.e_radio == fieldType ||
                                Field.e_choice == fieldType)) {
                    ViewChangeCollection view_change = field.setValue(fieldValue);
                    pdfViewCtrl.refreshAndUpdate(view_change);
                }
            }
            break;
            case Null:
            case Map:
            case Array:
                break;
        }
    }

    public void setFlagForFields(ReadableArray fields, Integer flag, Boolean value) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        PDFDoc pdfDoc = pdfViewCtrl.getDoc();

        boolean shouldUnlock = false;
        try {
            pdfViewCtrl.docLock(true);
            shouldUnlock = true;

            int fieldCount = fields.size();

            for (int i = 0; i < fieldCount; i++) {
                String fieldName = fields.getString(i);
                if (fieldName == null) continue;

                Field field = pdfDoc.getField(fieldName);
                if (field != null && field.isValid()) {
                    field.setFlag(flag, value);
                }
            }

            pdfViewCtrl.update(true);
        } finally {
            if (shouldUnlock) {
                pdfViewCtrl.docUnlock();
            }
        }
    }

    @Nullable
    public WritableMap getField(Field field) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        if (pdfViewCtrl == null) {
            return null;
        }

        boolean shouldUnlockRead = false;
        try {
            pdfViewCtrl.docLockRead();
            shouldUnlockRead = true;

            if (field != null && field.isValid()) {
                WritableMap fieldMap = Arguments.createMap();
                int fieldType = field.getType();
                String typeString;
                switch (fieldType) {
                    case Field.e_button:
                        typeString = FIELD_TYPE_BUTTON;
                        break;
                    case Field.e_check:
                        typeString = FIELD_TYPE_CHECKBOX;
                        fieldMap.putBoolean(KEY_FIELD_VALUE, field.getValueAsBool());
                        break;
                    case Field.e_radio:
                        typeString = FIELD_TYPE_RADIO;
                        fieldMap.putString(KEY_FIELD_VALUE, field.getValueAsString());
                        break;
                    case Field.e_text:
                        typeString = FIELD_TYPE_TEXT;
                        fieldMap.putString(KEY_FIELD_VALUE, field.getValueAsString());
                        break;
                    case Field.e_choice:
                        typeString = FIELD_TYPE_CHOICE;
                        fieldMap.putString(KEY_FIELD_VALUE, field.getValueAsString());
                        break;
                    case Field.e_signature:
                        typeString = FIELD_TYPE_SIGNATURE;
                        break;
                    default:
                        typeString = FIELD_TYPE_UNKNOWN;
                        break;
                }

                fieldMap.putString(KEY_FIELD_NAME, field.getName());
                fieldMap.putString(KEY_FIELD_TYPE, typeString);
                return fieldMap;
            }
        } finally {
            if (shouldUnlockRead) {
                pdfViewCtrl.docUnlockRead();
            }
        }
        return null;
    }

    @Nullable
    public WritableMap getField(String fieldName) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        PDFDoc pdfDoc = pdfViewCtrl.getDoc();

        Field field = null;
        boolean shouldUnlockRead = false;
        try {
            pdfViewCtrl.docLockRead();
            shouldUnlockRead = true;

            field = pdfDoc.getField(fieldName);
        } finally {
            if (shouldUnlockRead) {
                pdfViewCtrl.docUnlockRead();
            }
        }
        if (field != null) {
            return getField(field);
        }
        return null;
    }

    /**
     * This method does not lock, a read lock is expected around this method
     */
    @Nullable
    public WritableMap getField(Annot annot) throws PDFNetException {
        WritableMap resultMap = null;
        if (annot != null && annot.isValid()) {
            if (annot.getType() == Annot.e_Widget) {
                Widget widget = new Widget(annot);
                Field field = widget.getField();
                resultMap = getField(field);
                if (resultMap != null) {
                    int fieldType = field.getType();
                    if (fieldType == Field.e_signature) {
                        SignatureWidget signatureWidget = new SignatureWidget(annot);
                        DigitalSignatureField digitalSignatureField = signatureWidget.getDigitalSignatureField();
                        boolean hasExistingSignature = digitalSignatureField.hasVisibleAppearance();
                        resultMap.putBoolean(KEY_FIELD_HAS_APPEARANCE, hasExistingSignature);
                    }
                }
            }
        }
        return resultMap;
    }

    public String getDocumentPath() {
        return getPdfViewCtrlTabFragment().getFilePath();
    }

    public WritableArray getAllFields(int pageNumber) {
        if (pageNumber == -1) {
            return getAllFields();
        }
        if (getPdfDoc() != null) {
            WritableArray fieldsArray = Arguments.createArray();
            boolean shouldUnlockRead = false;
            PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
            try {
                pdfViewCtrl.docLockRead();
                shouldUnlockRead = true;
                getFieldsForPage(pageNumber, fieldsArray);
            } catch (Exception ex) {
                ex.printStackTrace();
            } finally {
                if (shouldUnlockRead) {
                    pdfViewCtrl.docUnlockRead();
                }
            }
            return fieldsArray;
        }
        return null;
    }

    public WritableArray getAllFields() {
        if (getPdfDoc() != null) {
            WritableArray fieldsArray = Arguments.createArray();
            boolean shouldUnlockRead = false;
            PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
            try {
                pdfViewCtrl.docLockRead();
                shouldUnlockRead = true;
                for (int i = 1; i <= getPdfDoc().getPageCount(); i++) {
                    getFieldsForPage(i, fieldsArray);
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            } finally {
                if (shouldUnlockRead) {
                    pdfViewCtrl.docUnlockRead();
                }
            }
            return fieldsArray;
        }
        return null;
    }

    public void getFieldsForPage(int pageNumber, WritableArray fieldsArray) {
        try {
            Page page = getPdfDoc().getPage(pageNumber);
            int num_annots = page.getNumAnnots();
            for (int i = 0; i < num_annots; ++i) {
                Annot annot = page.getAnnot(i);
                if (annot != null && annot.isValid()) {
                    if (annot.getType() == Annot.e_Widget) {
                        WritableMap resultMap = getField(annot);
                        if (resultMap != null) {
                            fieldsArray.pushMap(resultMap);
                        }
                    }
                }
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void setToolMode(String item) {
        if (getToolManager() != null) {
            ToolManager.ToolMode mode = convStringToToolMode(item);
            Tool tool = (Tool) getToolManager().createTool(mode, null);
            boolean continuousAnnot = PdfViewCtrlSettingsManager.getContinuousAnnotationEdit(getContext());
            tool.setForceSameNextToolMode(continuousAnnot);
            getToolManager().setTool(tool);
        }
    }

    public boolean commitTool() {
        if (getToolManager() != null) {
            ToolManager.Tool currentTool = getToolManager().getTool();
            if (currentTool instanceof FreehandCreate) {
                ((FreehandCreate) currentTool).commitAnnotation();
                getToolManager().setTool(getToolManager().createTool(ToolManager.ToolMode.PAN, null));
                return true;
            } else if (currentTool instanceof AdvancedShapeCreate) {
                ((AdvancedShapeCreate) currentTool).commit();
                getToolManager().setTool(getToolManager().createTool(ToolManager.ToolMode.PAN, null));
                return true;
            }
        }
        return false;
    }

    public void selectAnnotation(String annotId, int pageNumber) {
        if (getToolManager() != null) {
            getToolManager().selectAnnot(annotId, pageNumber);
        }
    }

    public boolean handleBackButton() {
        if (mPdfViewCtrlTabHostFragment != null) {
            return mPdfViewCtrlTabHostFragment.handleBackPressed();
        }
        return false;
    }

    public void setPropertiesForAnnotation(String annotId, int pageNumber, ReadableMap propertyMap) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        ToolManager toolManager = getToolManager();

        boolean shouldUnlock = false;
        try {
            pdfViewCtrl.docLock(true);
            shouldUnlock = true;

            Annot annot = ViewerUtils.getAnnotById(pdfViewCtrl, annotId, pageNumber);
            if (annot != null && annot.isValid()) {

                HashMap<Annot, Integer> map = new HashMap<>(1);
                map.put(annot, pageNumber);
                toolManager.raiseAnnotationsPreModifyEvent(map);

                if (propertyMap.hasKey(KEY_ANNOTATION_CONTENTS)) {
                    String contents = propertyMap.getString(KEY_ANNOTATION_CONTENTS);
                    if (contents != null) {
                        annot.setContents(contents);
                    }
                }

                if (propertyMap.hasKey(KEY_ANNOTATION_RECT)) {
                    ReadableMap rectMap = propertyMap.getMap(KEY_ANNOTATION_RECT);

                    if (rectMap != null && rectMap.hasKey(KEY_X1) && rectMap.hasKey(KEY_Y1) &&
                            rectMap.hasKey(KEY_X2) && rectMap.hasKey(KEY_Y2)) {
                        double rectX1 = rectMap.getDouble(KEY_X1);
                        double rectY1 = rectMap.getDouble(KEY_Y1);
                        double rectX2 = rectMap.getDouble(KEY_X2);
                        double rectY2 = rectMap.getDouble(KEY_Y2);
                        com.pdftron.pdf.Rect rect = new com.pdftron.pdf.Rect(rectX1, rectY1, rectX2, rectY2);
                        annot.setRect(rect);
                    }
                }

                if (propertyMap.hasKey(KEY_ANNOTATION_CUSTOM_DATA)) {
                    ReadableMap customData = propertyMap.getMap(KEY_ANNOTATION_CUSTOM_DATA);

                    if (customData != null) {
                        ReadableMapKeySetIterator keySetIterator = customData.keySetIterator();
                        while (keySetIterator.hasNextKey()) {
                            String key = keySetIterator.nextKey();
                            String value = customData.getString(key);

                            annot.setCustomData(key, value);
                        }
                    }
                }

                if (propertyMap.hasKey(KEY_ANNOTATION_STROKE_COLOR)) {
                    ReadableMap strokeColor = propertyMap.getMap(KEY_ANNOTATION_STROKE_COLOR);

                    if (strokeColor != null && strokeColor.hasKey(COLOR_RED) && strokeColor.hasKey(COLOR_GREEN) &&
                            strokeColor.hasKey(COLOR_BLUE)) {
                        double red = (double) strokeColor.getInt(COLOR_RED) / 255F;
                        double green = (double) strokeColor.getInt(COLOR_GREEN) / 255F;
                        double blue = (double) strokeColor.getInt(COLOR_BLUE) / 255F;
                        ColorPt colorPt = new ColorPt(red, green, blue);
                        annot.setColor(colorPt);
                        annot.refreshAppearance();
                    }
                }

                if (annot.isMarkup()) {
                    Markup markupAnnot = new Markup(annot);

                    if (propertyMap.hasKey(KEY_ANNOTATION_SUBJECT)) {
                        String subject = propertyMap.getString(KEY_ANNOTATION_SUBJECT);
                        if (subject != null) {
                            markupAnnot.setSubject(subject);
                        }
                    }

                    if (propertyMap.hasKey(KEY_ANNOTATION_TITLE)) {
                        String title = propertyMap.getString(KEY_ANNOTATION_TITLE);
                        if (title != null) {
                            markupAnnot.setTitle(title);
                        }
                    }

                    if (propertyMap.hasKey(KEY_ANNOTATION_CONTENT_RECT)) {
                        ReadableMap contentRectMap = propertyMap.getMap(KEY_ANNOTATION_CONTENT_RECT);
                        if (contentRectMap != null && contentRectMap.hasKey(KEY_X1) && contentRectMap.hasKey(KEY_Y1) &&
                                contentRectMap.hasKey(KEY_X2) && contentRectMap.hasKey(KEY_Y2)) {
                            double rectX1 = contentRectMap.getDouble(KEY_X1);
                            double rectY1 = contentRectMap.getDouble(KEY_Y1);
                            double rectX2 = contentRectMap.getDouble(KEY_X2);
                            double rectY2 = contentRectMap.getDouble(KEY_Y2);
                            com.pdftron.pdf.Rect contentRect = new com.pdftron.pdf.Rect(rectX1, rectY1, rectX2, rectY2);
                            markupAnnot.setContentRect(contentRect);
                        }
                    }
                }

                pdfViewCtrl.update(annot, pageNumber);

                toolManager.raiseAnnotationsModifiedEvent(map, Tool.getAnnotationModificationBundle(null));
            }
        } finally {
            if (shouldUnlock) {
                pdfViewCtrl.docUnlock();
            }
        }
    }

    public WritableMap getPropertiesForAnnotation(String annotId, int pageNumber) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        WritableMap propertyMap = Arguments.createMap();

        if (pdfViewCtrl != null) {
            boolean shouldUnlockRead = false;
            try {
                pdfViewCtrl.docLockRead();
                shouldUnlockRead = true;
                Annot annot = ViewerUtils.getAnnotById(pdfViewCtrl, annotId, pageNumber);

                if (annot != null && annot.isValid()) {

                    String contents = annot.getContents();
                    if (!contents.isEmpty()) {
                        propertyMap.putString(KEY_ANNOTATION_CONTENTS, contents);
                    }

                    com.pdftron.pdf.Rect rect = annot.getRect();
                    if (rect != null) {
                        WritableMap rectMap = Arguments.createMap();
                        rectMap.putDouble(KEY_X1, rect.getX1());
                        rectMap.putDouble(KEY_Y1, rect.getY1());
                        rectMap.putDouble(KEY_X2, rect.getX2());
                        rectMap.putDouble(KEY_Y2, rect.getY2());
                        rectMap.putDouble(KEY_WIDTH, rect.getWidth());
                        rectMap.putDouble(KEY_HEIGHT, rect.getHeight());
                        propertyMap.putMap(KEY_ANNOTATION_RECT, rectMap);
                    }

                    ColorPt colorPt = annot.getColorAsRGB();
                    if (colorPt != null) {
                        WritableMap colorMap = Arguments.createMap();
                        colorMap.putDouble(COLOR_RED, colorPt.get(0) * 255F);
                        colorMap.putDouble(COLOR_GREEN, colorPt.get(1) * 255F);
                        colorMap.putDouble(COLOR_BLUE, colorPt.get(2) * 255F);
                        propertyMap.putMap(KEY_ANNOTATION_STROKE_COLOR, colorMap);
                    }

                    if (annot.isMarkup()) {
                        Markup markupAnnot = new Markup(annot);

                        String subject = markupAnnot.getSubject();
                        if (!subject.isEmpty()) {
                            propertyMap.putString(KEY_ANNOTATION_SUBJECT, subject);
                        }

                        String title = markupAnnot.getTitle();
                        if (!title.isEmpty()) {
                            propertyMap.putString(KEY_ANNOTATION_TITLE, title);
                        }

                        com.pdftron.pdf.Rect contentRect = markupAnnot.getContentRect();
                        if (contentRect != null) {
                            WritableMap contentRectMap = Arguments.createMap();
                            contentRectMap.putDouble(KEY_X1, contentRect.getX1());
                            contentRectMap.putDouble(KEY_Y1, contentRect.getY1());
                            contentRectMap.putDouble(KEY_X2, contentRect.getX2());
                            contentRectMap.putDouble(KEY_Y2, contentRect.getY2());
                            contentRectMap.putDouble(KEY_WIDTH, contentRect.getWidth());
                            contentRectMap.putDouble(KEY_HEIGHT, contentRect.getHeight());
                            propertyMap.putMap(KEY_ANNOTATION_CONTENT_RECT, contentRectMap);
                        }
                    }
                }
            } catch (Exception ex) {
                ex.printStackTrace();
            } finally {
                if (shouldUnlockRead) {
                    pdfViewCtrl.docUnlockRead();
                }
            }
        }
        return propertyMap;
    }

    public void setFlagsForAnnotations(ReadableArray annotationFlagList) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        ToolManager toolManager = getToolManager();
        int flagCount = annotationFlagList.size();

        boolean shouldUnlock = false;
        try {
            pdfViewCtrl.docLock(true);
            shouldUnlock = true;
            for (int i = 0; i < flagCount; i++) {
                ReadableMap annotFlagData = annotationFlagList.getMap(i);
                if (null == annotFlagData) {
                    continue;
                }
                String annotId = annotFlagData.getString(KEY_ANNOTATION_ID);
                int pageNum = annotFlagData.getInt(KEY_ANNOTATION_PAGE);
                String flag = annotFlagData.getString(KEY_ANNOTATION_FLAG);
                boolean flagValue = annotFlagData.getBoolean(KEY_ANNOTATION_FLAG_VALUE);

                Annot annot = ViewerUtils.getAnnotById(pdfViewCtrl, annotId, pageNum);
                if (annot != null && annot.isValid() && flag != null) {
                    int flagNum = -1;
                    switch (flag) {
                        case KEY_ANNOTATION_FLAG_HIDDEN:
                            flagNum = Annot.e_hidden;
                            break;
                        case KEY_ANNOTATION_FLAG_INVISIBLE:
                            flagNum = Annot.e_invisible;
                            break;
                        case KEY_ANNOTATION_FLAG_LOCKED:
                            flagNum = Annot.e_locked;
                            break;
                        case KEY_ANNOTATION_FLAG_LOCKED_CONTENTS:
                            flagNum = Annot.e_locked_contents;
                            break;
                        case KEY_ANNOTATION_FLAG_NO_ROTATE:
                            flagNum = Annot.e_no_rotate;
                            break;
                        case KEY_ANNOTATION_FLAG_NO_VIEW:
                            flagNum = Annot.e_no_view;
                            break;
                        case KEY_ANNOTATION_FLAG_NO_ZOOM:
                            flagNum = Annot.e_no_zoom;
                            break;
                        case KEY_ANNOTATION_FLAG_PRINT:
                            flagNum = Annot.e_print;
                            break;
                        case KEY_ANNOTATION_FLAG_READ_ONLY:
                            flagNum = Annot.e_read_only;
                            break;
                        case KEY_ANNOTATION_FLAG_TOGGLE_NO_VIEW:
                            flagNum = Annot.e_toggle_no_view;
                    }
                    if (flagNum != -1) {

                        HashMap<Annot, Integer> map = new HashMap<>(1);
                        map.put(annot, pageNum);
                        toolManager.raiseAnnotationsPreModifyEvent(map);

                        annot.setFlag(flagNum, flagValue);
                        pdfViewCtrl.update(annot, pageNum);

                        toolManager.raiseAnnotationsModifiedEvent(map, Tool.getAnnotationModificationBundle(null));
                    }
                }
            }
        } finally {
            if (shouldUnlock) {
                pdfViewCtrl.docUnlock();
            }
        }
    }

    public void setDrawAnnotations(boolean drawAnnotations) throws PDFNetException {
        if (getPdfViewCtrl() != null) {
            getPdfViewCtrl().setDrawAnnotations(drawAnnotations);
        }
    }

    public void setVisibilityForAnnotation(String annotId, int pageNumber, boolean visibility) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        boolean shouldUnlockRead = false;
        try {
            pdfViewCtrl.docLockRead();
            shouldUnlockRead = true;

            Annot annot = ViewerUtils.getAnnotById(pdfViewCtrl, annotId, pageNumber);
            if (annot != null && annot.isValid()) {

                if (visibility) {
                    pdfViewCtrl.showAnnotation(annot);
                } else {
                    pdfViewCtrl.hideAnnotation(annot);
                }

                pdfViewCtrl.update(annot, pageNumber);
            }
        } finally {
            if (shouldUnlockRead) {
                pdfViewCtrl.docUnlockRead();
            }
        }
    }

    public void setHighlightFields(boolean highlightFields) throws PDFNetException {
        if (getPdfViewCtrl() != null) {
            getPdfViewCtrl().setHighlightFields(highlightFields);
        }
    }

    public WritableMap getPageCropBox(int pageNumber) throws PDFNetException {
        com.pdftron.pdf.Rect rect = getPdfDoc().getPage(pageNumber).getCropBox();

        WritableMap map = Arguments.createMap();

        map.putDouble(KEY_X1, rect.getX1());
        map.putDouble(KEY_Y1, rect.getY1());
        map.putDouble(KEY_X2, rect.getX2());
        map.putDouble(KEY_Y2, rect.getY2());
        map.putDouble(KEY_WIDTH, rect.getWidth());
        map.putDouble(KEY_HEIGHT, rect.getHeight());

        return map;
    }

    public boolean setCurrentPage(int pageNumber) {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        return pdfViewCtrl.setCurrentPage(pageNumber);
    }

    public WritableArray getVisiblePages() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        return Arguments.fromArray(pdfViewCtrl.getVisiblePages());
    }

    public boolean gotoPreviousPage() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        return pdfViewCtrl.gotoPreviousPage();
    }

    public boolean gotoNextPage() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        return pdfViewCtrl.gotoNextPage();
    }

    public boolean gotoFirstPage() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        return pdfViewCtrl.gotoFirstPage();
    }

    public boolean gotoLastPage() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        return pdfViewCtrl.gotoLastPage();
    }

    public void closeAllTabs() {
        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.closeAllTabs();
        }
    }

    public void openTabSwitcher() {
        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.onOpenTabSwitcher();
        }
    }

    public int getPageRotation() {
        return getPdfViewCtrl().getPageRotation() * 90;
    }

    public void rotateClockwise() {
        getPdfViewCtrl().rotateClockwise();
    }

    public void rotateCounterClockwise() {
        getPdfViewCtrl().rotateCounterClockwise();
    }

    public double getZoom() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        return pdfViewCtrl.getZoom();
    }

    public WritableMap getScrollPos() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        WritableMap map = Arguments.createMap();

        if (pdfViewCtrl != null) {
            map.putDouble(KEY_HORIZONTAL, pdfViewCtrl.getHScrollPos());
            map.putDouble(KEY_VERTICAL, pdfViewCtrl.getVScrollPos());
        }

        return map;
    }

    public WritableMap getCanvasSize() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        WritableMap map = Arguments.createMap();

        if (pdfViewCtrl != null) {
            map.putDouble(KEY_WIDTH, pdfViewCtrl.getCanvasWidth());
            map.putDouble(KEY_HEIGHT, pdfViewCtrl.getCanvasHeight());
        }

        return map;
    }

    public WritableArray convertScreenPointsToPagePoints(ReadableArray points) {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        WritableArray convertedPoints = Arguments.createArray();

        if (pdfViewCtrl != null) {
            int currentPage = pdfViewCtrl.getCurrentPage();

            for (int i = 0; i < points.size(); i++) {
                ReadableMap point = points.getMap(i);
                double x = point.getDouble(KEY_COORDINATE_POINT_X);
                double y = point.getDouble(KEY_COORDINATE_POINT_Y);
                int pageNumber = currentPage;

                if (point.hasKey(KEY_COORDINATE_POINT_PAGE_NUMBER)) {
                    pageNumber = point.getInt(KEY_COORDINATE_POINT_PAGE_NUMBER);
                }
                double[] convertedPointCoordinates = pdfViewCtrl.convScreenPtToPagePt(x, y, pageNumber);

                WritableMap map = Arguments.createMap();
                map.putDouble(KEY_COORDINATE_POINT_X, convertedPointCoordinates[0]);
                map.putDouble(KEY_COORDINATE_POINT_Y, convertedPointCoordinates[1]);

                convertedPoints.pushMap(map);
            }
        }

        return convertedPoints;
    }

    public WritableArray convertPagePointsToScreenPoints(ReadableArray points) {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        WritableArray convertedPoints = Arguments.createArray();

        if (pdfViewCtrl != null) {
            int currentPage = pdfViewCtrl.getCurrentPage();

            for (int i = 0; i < points.size(); i++) {
                ReadableMap point = points.getMap(i);
                double x = point.getDouble(KEY_COORDINATE_POINT_X);
                double y = point.getDouble(KEY_COORDINATE_POINT_Y);
                int pageNumber = currentPage;

                if (point.hasKey(KEY_COORDINATE_POINT_PAGE_NUMBER)) {
                    pageNumber = point.getInt(KEY_COORDINATE_POINT_PAGE_NUMBER);
                }
                double[] convertedPointCoordinates = pdfViewCtrl.convPagePtToScreenPt(x, y, pageNumber);

                WritableMap map = Arguments.createMap();
                map.putDouble(KEY_COORDINATE_POINT_X, convertedPointCoordinates[0]);
                map.putDouble(KEY_COORDINATE_POINT_Y, convertedPointCoordinates[1]);

                convertedPoints.pushMap(map);
            }
        }

        return convertedPoints;
    }

    public int getPageNumberFromScreenPoint(double x, double y) {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        return pdfViewCtrl.getPageNumberFromScreenPt(x, y);
    }

    public void setProgressiveRendering(boolean progressiveRendering, int initialDelay, int interval) {
        if (getPdfViewCtrl() != null) {
            getPdfViewCtrl().setProgressiveRendering(progressiveRendering, initialDelay, interval);
        }
    }

    public void setImageSmoothing(boolean imageSmoothing) throws PDFNetException {
        if (getPdfViewCtrl() != null) {
            getPdfViewCtrl().setImageSmoothing(imageSmoothing);
        }
    }

    public void setOverprint(String overprint) throws PDFNetException {
        if (getPdfViewCtrl() != null) {
            PDFViewCtrl.OverPrintMode overprintMode = null;
            switch (overprint) {
                case KEY_OVERPRINT_MODE_ON:
                    overprintMode = PDFViewCtrl.OverPrintMode.ON;
                    break;
                case KEY_OVERPRINT_MODE_OFF:
                    overprintMode = PDFViewCtrl.OverPrintMode.OFF;
                    break;
                case KEY_OVERPRINT_MODE_PDFX:
                    overprintMode = PDFViewCtrl.OverPrintMode.PDFX;
                    break;
            }

            if (overprintMode != null) {
                getPdfViewCtrl().setOverprint(overprintMode);
            }
        }
    }

    public void setPageBorderVisibility(boolean pageBorderVisibility) throws PDFNetException {
        if (getPdfViewCtrl() != null) {
            getPdfViewCtrl().setPageBorderVisibility(pageBorderVisibility);
            getPdfViewCtrl().update(true);
        }
    }

    public void setPageTransparencyGrid(boolean pageTransparencyGrid) throws PDFNetException {
        if (getPdfViewCtrl() != null) {
            getPdfViewCtrl().setPageTransparencyGrid(pageTransparencyGrid);
            getPdfViewCtrl().update(true);
        }
    }

    public void setDefaultPageColor(ReadableMap defaultPageColor) throws PDFNetException {
        if (getPdfViewCtrl() != null) {
            int red = defaultPageColor.getInt(COLOR_RED);
            int green = defaultPageColor.getInt(COLOR_GREEN);
            int blue = defaultPageColor.getInt(COLOR_BLUE);
            getPdfViewCtrl().setDefaultPageColor(red, green, blue);
        }
    }

    public void setBackgroundColor(ReadableMap backgroundColor) throws PDFNetException {
        if (getPdfViewCtrl() != null) {
            int red = backgroundColor.getInt(COLOR_RED);
            int green = backgroundColor.getInt(COLOR_GREEN);
            int blue = backgroundColor.getInt(COLOR_BLUE);
            getPdfViewCtrl().setClientBackgroundColor(red, green, blue, false);
        }
    }

    public void setColorPostProcessMode(String colorPostProcessMode) throws PDFNetException {
        int colorPostProcessModeValue = -1;
        switch (colorPostProcessMode) {
            case KEY_COLOR_POST_PROCESS_MODE_NONE:
                colorPostProcessModeValue = 0;
                break;
            case KEY_COLOR_POST_PROCESS_MODE_INVERT:
                colorPostProcessModeValue = 1;
                break;
            case KEY_COLOR_POST_PROCESS_MODE_GRADIENT_MAP:
                colorPostProcessModeValue = 2;
                break;
            case KEY_COLOR_POST_PROCESS_MODE_NIGHT_MODE:
                colorPostProcessModeValue = 3;
                break;
        }

        if (colorPostProcessModeValue != -1 && getPdfViewCtrl() != null) {
            getPdfViewCtrl().setColorPostProcessMode(colorPostProcessModeValue);
        }
    }

    public void setColorPostProcessColors(ReadableMap whiteColor, ReadableMap blackColor) throws PDFNetException {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        if (pdfViewCtrl != null) {

            // convert white map to int (rgba)
            int whiteColorNumber = convertRGBAToHex(whiteColor);
            if (whiteColorNumber == -1) {
                return;
            }
            int blackColorNumber = convertRGBAToHex(blackColor);
            if (blackColorNumber == -1) {
                return;
            }

            pdfViewCtrl.setColorPostProcessColors(whiteColorNumber, blackColorNumber);
        }
    }

    private int convertRGBAToHex(ReadableMap color) {
        String[] colorKeys = {COLOR_ALPHA, COLOR_RED, COLOR_GREEN, COLOR_BLUE};
        int colorNumber = 0;
        for (String colorKey : colorKeys) {
            colorNumber <<= 8;
            if (!color.hasKey(colorKey)) {
                // not alpha
                if (!colorKey.equals(COLOR_ALPHA)) {
                    return -1;
                }
                // if alpha is not provided
                colorNumber += 255;
                continue;
            }
            int currentColorValue = color.getInt(colorKey);
            if (currentColorValue > 255 || currentColorValue < 0) {
                return -1;
            }
            colorNumber += currentColorValue;
        }
        return colorNumber;
    }

    private ColorPt convertRGBAToColorPt(ReadableMap color) throws PDFNetException {
        double red = (double) (color.getInt(COLOR_RED) / 255f);
        double green = (double) (color.getInt(COLOR_GREEN) / 255f);
        double blue = (double) (color.getInt(COLOR_BLUE) / 255f);
        double alpha = (double) (color.getInt(COLOR_ALPHA) / 255f);
        ColorPt colorPt = new ColorPt(red, green, blue, alpha);

        return colorPt;
    }

    public void startSearchMode(String searchString, boolean matchCase, boolean matchWholeWord) {
        PdfViewCtrlTabFragment2 fragment = getPdfViewCtrlTabFragment();
        if (fragment != null) {
            fragment.setSearchMode(true);
            fragment.setSearchQuery(searchString);
            fragment.setSearchMatchCase(matchCase);
            fragment.setSearchWholeWord(matchWholeWord);
            fragment.queryTextSubmit(searchString);
        }
    }

    public void exitSearchMode() {
        PdfViewCtrlTabFragment2 fragment = getPdfViewCtrlTabFragment();
        if (fragment != null) {
            fragment.setSearchMode(false);
            fragment.cancelFindText();
            fragment.exitSearchMode();
        }
    }

    public void findText(String searchString, boolean matchCase, boolean matchWholeWord, boolean searchUp, boolean regExp) {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        if (pdfViewCtrl != null) {
            pdfViewCtrl.findText(searchString, matchCase, matchWholeWord, searchUp, regExp);
        }
    }

    public void cancelFindText() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        if (pdfViewCtrl != null) {
            pdfViewCtrl.cancelFindText();
        }
    }

    public void openSearch() {
        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.onSearchOptionSelected();
        }
    }

    public WritableMap getSelection(int pageNumber) {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        if (pdfViewCtrl != null) {
            PDFViewCtrl.Selection selection = pdfViewCtrl.getSelection(pageNumber);
            // Valid
            if (selection.getPageNum() != -1) {
                return getMapFromSelection(selection);
            }
        }
        return null;
    }

    public boolean hasSelection() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        return pdfViewCtrl != null && pdfViewCtrl.hasSelection();
    }

    public void clearSelection() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        if (pdfViewCtrl != null) {
            pdfViewCtrl.clearSelection();
        }
    }

    public WritableMap getSelectionPageRange() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        if (pdfViewCtrl != null) {
            WritableMap selection = Arguments.createMap();
            int start = pdfViewCtrl.getSelectionBeginPage();

            int end = pdfViewCtrl.getSelectionEndPage();

            selection.putInt(KEY_TEXT_SELECTION_PAGE_RANGE_BEGIN, pdfViewCtrl.getSelectionBeginPage());
            selection.putInt(KEY_TEXT_SELECTION_PAGE_RANGE_END, pdfViewCtrl.getSelectionEndPage());
            return selection;
        }

        return null;
    }

    public boolean hasSelectionOnPage(int pageNumber) {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        return pdfViewCtrl != null && pdfViewCtrl.hasSelectionOnPage(pageNumber);
    }

    private WritableMap getMapFromSelection(PDFViewCtrl.Selection selection) {
        WritableMap selectionMap = Arguments.createMap();
        selectionMap.putInt(KEY_TEXT_SELECTION_PAGE_NUMBER, selection.getPageNum());
        selectionMap.putString(KEY_TEXT_SELECTION_UNICODE, selection.getAsUnicode());
        selectionMap.putString(KEY_TEXT_SELECTION_HTML, selection.getAsHtml());

        // convert all quads into points
        double[] quadDoubleArray = selection.getQuads();
        WritableArray quads = Arguments.createArray();
        for (int i = 0; i < quadDoubleArray.length; i += 8) {
            WritableArray quad = Arguments.createArray();
            for (int j = 0; j < 8; j += 2) {
                WritableMap point = Arguments.createMap();
                point.putDouble(KEY_TEXT_SELECTION_QUAD_POINT_X, quadDoubleArray[i + j]);
                point.putDouble(KEY_TEXT_SELECTION_QUAD_POINT_Y, quadDoubleArray[i + j + 1]);
                quad.pushMap(point);
            }
            quads.pushArray(quad);
        }
        selectionMap.putArray(KEY_TEXT_SELECTION_QUADS, quads);

        return selectionMap;
    }

    public boolean selectInRect(ReadableMap rect) {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        if (pdfViewCtrl != null && rect != null && rect.hasKey(KEY_X1) && rect.hasKey(KEY_Y1) &&
                rect.hasKey(KEY_X2) && rect.hasKey(KEY_Y2)) {
            double rectX1 = rect.getDouble(KEY_X1);
            double rectY1 = rect.getDouble(KEY_Y1);
            double rectX2 = rect.getDouble(KEY_X2);
            double rectY2 = rect.getDouble(KEY_Y2);
            return pdfViewCtrl.select(rectX1, rectY1, rectX2, rectY2);
        }
        return false;
    }

    public boolean isThereTextInRect(ReadableMap rect) {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        if (pdfViewCtrl != null && rect != null && rect.hasKey(KEY_X1) && rect.hasKey(KEY_Y1) &&
                rect.hasKey(KEY_X2) && rect.hasKey(KEY_Y2)) {
            double rectX1 = rect.getDouble(KEY_X1);
            double rectY1 = rect.getDouble(KEY_Y1);
            double rectX2 = rect.getDouble(KEY_X2);
            double rectY2 = rect.getDouble(KEY_Y2);
            return pdfViewCtrl.isThereTextInRect(rectX1, rectY1, rectX2, rectY2);
        }
        return false;
    }

    public void selectAll() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();

        if (pdfViewCtrl != null) {
            pdfViewCtrl.selectAll();
        }
    }

    public String exportAsImage(int pageNumber, double dpi, String exportFormat, boolean transparent) {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        if (pdfViewCtrl != null) {
            boolean shouldUnlockRead = false;
            try {
                pdfViewCtrl.docLockRead();
                shouldUnlockRead = true;
                return ReactUtils.exportAsImageHelper(pdfViewCtrl.getDoc(), pageNumber, dpi, exportFormat, transparent);
            } catch (Exception ex) {
                throw new RuntimeException(ex);
            } finally {
                if (shouldUnlockRead) {
                    pdfViewCtrl.docUnlockRead();
                }
            }
        }
        return null;
    }

    public void undo() {
        if (getPdfViewCtrlTabFragment() != null) {
            getPdfViewCtrlTabFragment().undo();
        }
    }

    public void redo() {
        if (getPdfViewCtrlTabFragment() != null) {
            getPdfViewCtrlTabFragment().redo();
        }
    }

    public boolean canUndo() {
        UndoRedoManager undoRedoManger = getToolManager().getUndoRedoManger();
        return undoRedoManger.canUndo();
    }

    public boolean canRedo() {
        UndoRedoManager undoRedoManger = getToolManager().getUndoRedoManger();
        return undoRedoManger.canRedo();
    }

    public void showViewSettings() {
        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.onViewModeOptionSelected();
        }
    }

    public void showAddPagesView() {
        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.addNewPage();
        }
    }

    public void shareCopy(boolean flattening) {
        PdfViewCtrlTabFragment2 currentFragment = getPdfViewCtrlTabFragment();
        if (mPdfViewCtrlTabHostFragment == null || !(currentFragment instanceof RNPdfViewCtrlTabFragment)) {
            return;
        }
        if (!mPdfViewCtrlTabHostFragment.checkTabConversionAndAlert(R.string.cant_share_while_converting_message, true)) {
            currentFragment.save(false, true, true);
            ((RNPdfViewCtrlTabFragment) currentFragment).shareCopy(flattening);
        }
    }

    public void showCropDialog() {
        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.onViewModeSelected(
                    PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_USERCROP_VALUE
            );
        }
    }

    public void showRotateDialog() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        if (pdfViewCtrl != null && mFragmentManager != null) {
            RotateDialogFragment.newInstance()
                    .setPdfViewCtrl(pdfViewCtrl)
                    .show(mFragmentManager, "rotate_dialog");
        }
    }

    public void openOutlineList() {
        if (isBookmarkListVisible) {
            if (mPdfViewCtrlTabHostFragment != null) {
                mPdfViewCtrlTabHostFragment.onOutlineOptionSelected(1);
            }
        } else {
            if (mPdfViewCtrlTabHostFragment != null) {
                mPdfViewCtrlTabHostFragment.onOutlineOptionSelected(0);
            }
        }
    }

    public void openLayersList() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        if (pdfViewCtrl != null) {
            PdfLayerDialog pdfLayerDialog = new PdfLayerDialog(pdfViewCtrl.getContext(), pdfViewCtrl);
            pdfLayerDialog.show();
        }
    }

    public void openNavigationLists() {
        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.onOutlineOptionSelected();
        }
    }

    public boolean isReflowMode() {
        if (getPdfViewCtrlTabFragment() != null) {
            return getPdfViewCtrlTabFragment().isReflowMode();
        }
        return false;
    }

    public void toggleReflow() {
        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.onToggleReflow();
        }
    }

    public void showGoToPageView() {
        if (getPdfViewCtrlTabFragment() instanceof RNPdfViewCtrlTabFragment) {
            RNPdfViewCtrlTabFragment fragment = (RNPdfViewCtrlTabFragment) getPdfViewCtrlTabFragment();
            fragment.showGoToPageView();
        }
    }

    public PdfViewCtrlTabFragment2 getPdfViewCtrlTabFragment() {
        if (mPdfViewCtrlTabHostFragment != null) {
            return mPdfViewCtrlTabHostFragment.getCurrentPdfViewCtrlFragment();
        }
        return null;
    }

    public PDFViewCtrl getPdfViewCtrl() {
        if (getPdfViewCtrlTabFragment() != null) {
            return getPdfViewCtrlTabFragment().getPDFViewCtrl();
        }
        return null;
    }

    public PDFDoc getPdfDoc() {
        if (getPdfViewCtrlTabFragment() != null) {
            return getPdfViewCtrlTabFragment().getPdfDoc();
        }
        return null;
    }

    public void setRestrictDownloadUsage(boolean restrictDownloadUsage) {
        mBuilder = mBuilder.restrictDownloadUsage(restrictDownloadUsage);
    }

    public void setInkMultiStrokeEnabled(boolean inkMultiStrokeEnabled) {
        mToolManagerBuilder.setInkMultiStrokeEnabled(inkMultiStrokeEnabled);
    }

    public void openThumbnailsView() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        if (pdfViewCtrl != null) {
            mPdfViewCtrlTabHostFragment.onPageThumbnailOptionSelected(false, null);
        }
    }

    public ReadableArray getSavedSignatures() {
        WritableArray signatures = Arguments.createArray();
        Context context = getContext();
        if (context != null) {
            File[] files = StampManager.getInstance().getSavedSignatures(context);
            for (int i = 0; i < files.length; i++) {
                signatures.pushString(files[i].getAbsolutePath());
            }
        }
        return signatures;
    }

    public String getSavedSignatureFolder() {
        Context context = getContext();
        if (context != null) {
            File file = StampManager.getInstance().getSavedSignatureFolder(context);
            return file.getAbsolutePath();
        }
        return "";
    }

    public String getSavedSignatureJpgFolder() {
        Context context = getContext();
        if (context != null) {
            File file = StampManager.getInstance().getSavedSignatureJpgFolder(context);
            return file.getAbsolutePath();
        }
        return "";
    }

    // Hygen Generated Methods
    public void setStampImageData(String annotationId, int pageNumber, String stampImageDataUrl, Promise promise) throws PDFNetException {
        // Initialize a new ElementWriter and ElementBuilder
        ElementWriter writer = new ElementWriter();
        ElementBuilder builder = new ElementBuilder();

        writer.begin(getPdfViewCtrl().getDoc().getSDFDoc(), true);

        Annot annot = ViewerUtils.getAnnotById(getPdfViewCtrl().getDoc(), annotationId, pageNumber);
        File file = new File(getContext().getFilesDir(), "image.png");
        DocumentViewUtilsKt.downloadFromURL(stampImageDataUrl, file.getAbsolutePath(), new DownloadFileCallback() {
            @Override
            public void downloadSuccess(@NonNull String path) {
                // Initialize the new image
                int w, h = 0;
                try {
                    Image image = Image.create(getPdfViewCtrl().getDoc().getSDFDoc(), path);

                    w = image.getImageWidth();
                    h = image.getImageHeight();
                    // Initialize a new image element
                    Element element = builder.createImage(image, 0, 0, w, h);

                    // Write the element
                    writer.writePlacedElement(element);

                    // Get the bounding box of the new element
                    com.pdftron.pdf.Rect bbox = element.getBBox();

                    // Configure the appearance stream that will be written to the annotation
                    Obj new_appearance_stream = writer.end();

                    // Set the bounding box to be the rect of the new element
                    new_appearance_stream.putRect(
                            "BBox",
                            bbox.getX1(),
                            bbox.getY1(),
                            bbox.getX2(),
                            bbox.getY2());

                    // Overwrite the annotation's appearance with the new appearance stream
                    annot.setAppearance(new_appearance_stream);

                    getPdfViewCtrl().update(annot, pageNumber);
                } catch (PDFNetException e) {
                    e.printStackTrace();
                }
                promise.resolve(annotationId);
            }

            @Override
            public void downloadFailed(@NonNull Exception e) {
                promise.reject("setStampData Error", e);
            }
        });
    }

    public void setFormFieldHighlightColor(ReadableMap fieldHighlightColor) throws PDFNetException {
        if (getPdfViewCtrl() != null && fieldHighlightColor != null) {
            getPdfViewCtrl().setFieldHighlightColor(convertRGBAToColorPt(fieldHighlightColor));
            getPdfViewCtrl().update(true);
        }
    }

    public void setSaveStateEnabled(boolean saveStateEnabled) {
        mSaveStateEnabled = saveStateEnabled;
    }

    public void setHighlighterSmoothingEnabled(boolean highlighterSmoothingEnabled) {
        if (!highlighterSmoothingEnabled) {
            mToolManagerBuilder = mToolManagerBuilder.setFreeHighlighterAutoSmoothingRange(0f);
        }
    }

    public void setOpenSavedCopyInNewTab(boolean openSavedCopyInNewTab) {
        mBuilder = mBuilder.openSavedCopyInNewTab(openSavedCopyInNewTab);
    }

    public ToolManager getToolManager() {
        if (getPdfViewCtrlTabFragment() != null) {
            return getPdfViewCtrlTabFragment().getToolManager();
        }
        return null;
    }

    public void onReceiveNativeEvent(String key, String message) {
        WritableMap event = Arguments.createMap();
        event.putString(key, message);
        ReactContext reactContext = (ReactContext) getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                getId(),
                "topChange",
                event);
    }

    public void onReceiveNativeEvent(WritableMap event) {
        ReactContext reactContext = (ReactContext) getContext();
        reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(
                getId(),
                "topChange",
                event);
    }
}
