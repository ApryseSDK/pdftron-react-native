package com.pdftron.reactnative.views;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Rect;
import android.net.Uri;
import android.os.Bundle;
import android.util.AttributeSet;
import android.util.Base64;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.FragmentManager;

import com.facebook.react.bridge.Arguments;
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
import com.pdftron.common.PDFNetException;
import com.pdftron.fdf.FDFDoc;
import com.pdftron.pdf.Action;
import com.pdftron.pdf.ActionParameter;
import com.pdftron.pdf.Annot;
import com.pdftron.pdf.Field;
import com.pdftron.pdf.PDFDoc;
import com.pdftron.pdf.PDFViewCtrl;
import com.pdftron.pdf.Page;
import com.pdftron.pdf.ViewChangeCollection;
import com.pdftron.pdf.annots.Markup;
import com.pdftron.pdf.annots.Widget;
import com.pdftron.pdf.config.PDFViewCtrlConfig;
import com.pdftron.pdf.config.ToolConfig;
import com.pdftron.pdf.config.ToolManagerBuilder;
import com.pdftron.pdf.config.ViewerConfig;
import com.pdftron.pdf.controls.PdfViewCtrlTabFragment2;
import com.pdftron.pdf.controls.PdfViewCtrlTabHostFragment2;
import com.pdftron.pdf.controls.ThumbnailsViewFragment;
import com.pdftron.pdf.dialog.ViewModePickerDialogFragment;
import com.pdftron.pdf.dialog.digitalsignature.DigitalSignatureDialogFragment;
import com.pdftron.pdf.model.AnnotStyle;
import com.pdftron.pdf.tools.AdvancedShapeCreate;
import com.pdftron.pdf.tools.FreehandCreate;
import com.pdftron.pdf.tools.QuickMenu;
import com.pdftron.pdf.tools.QuickMenuItem;
import com.pdftron.pdf.tools.Tool;
import com.pdftron.pdf.tools.ToolManager;
import com.pdftron.pdf.utils.ActionUtils;
import com.pdftron.pdf.utils.AnnotUtils;
import com.pdftron.pdf.utils.BookmarkManager;
import com.pdftron.pdf.utils.CommonToast;
import com.pdftron.pdf.utils.PdfDocManager;
import com.pdftron.pdf.utils.PdfViewCtrlSettingsManager;
import com.pdftron.pdf.utils.Utils;
import com.pdftron.pdf.utils.ViewerUtils;
import com.pdftron.pdf.widget.toolbar.builder.AnnotationToolbarBuilder;
import com.pdftron.pdf.widget.toolbar.builder.ToolbarButtonType;
import com.pdftron.pdf.widget.toolbar.component.DefaultToolbars;
import com.pdftron.reactnative.R;
import com.pdftron.reactnative.nativeviews.RNPdfViewCtrlTabFragment;
import com.pdftron.reactnative.utils.ReactUtils;
import com.pdftron.sdf.Obj;

import org.apache.commons.io.FileUtils;
import org.json.JSONException;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.pdftron.reactnative.utils.Constants.*;

public class DocumentView extends com.pdftron.pdf.controls.DocumentView2 {

    private static final String TAG = DocumentView.class.getSimpleName();

    private String mDocumentPath;
    private String mTabTitle;
    private boolean mIsBase64;
    private File mTempFile;

    private FragmentManager mFragmentManagerSave; // used to deal with lifecycle issue

    private PDFViewCtrlConfig mPDFViewCtrlConfig;
    private ToolManagerBuilder mToolManagerBuilder;
    private ViewerConfig.Builder mBuilder;

    private ArrayList<ToolManager.ToolMode> mDisabledTools = new ArrayList<>();

    private String mCacheDir;
    private int mInitialPageNumber = -1;

    private boolean mPadStatusBar;

    private boolean mAutoSaveEnabled = true;

    private boolean mUseStylusAsPen = true;
    private boolean mSignWithStamps;

    // collab
    private CollabManager mCollabManager;
    private boolean mCollabEnabled;
    private String mCurrentUser;
    private String mCurrentUserName;

    // quick menu
    private ArrayList<Object> mAnnotMenuItems;
    private ArrayList<Object> mAnnotMenuOverrideItems;
    private ArrayList<Object> mHideAnnotMenuTools;
    private ArrayList<Object> mLongPressMenuItems;
    private ArrayList<Object> mLongPressMenuOverrideItems;

    // custom behaviour
    private ReadableArray mActionOverrideItems;

    private boolean mReadOnly;

    private ArrayList<ViewModePickerDialogFragment.ViewModePickerItems> mViewModePickerItems = new ArrayList<>();

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
        // Must be called in order to properly pass onActivityResult intent to DigitalSignatureDialogFragment
        DigitalSignatureDialogFragment.HANDLE_INTENT_IN_ACTIVITY = true;

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
            FragmentManager fragmentManager = ((AppCompatActivity) reactContext.getCurrentActivity()).getSupportFragmentManager();
            setSupportFragmentManager(fragmentManager);
            mFragmentManagerSave = fragmentManager;
            mCacheDir = currentActivity.getCacheDir().getAbsolutePath();
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
                .skipReadOnlyCheck(true);
    }

    @Override
    protected PdfViewCtrlTabHostFragment2 getViewer() {
        if (mCollabEnabled) {
            // Create the Fragment using CollabViewerBuilder
            return CollabViewerBuilder2.withUri(mDocumentUri, mPassword)
                    .usingConfig(mViewerConfig)
                    .usingNavIcon(mShowNavIcon ? mNavIconRes : 0)
                    .usingCustomHeaders(mCustomHeaders)
                    .build(getContext());
        }
        return super.getViewer();
    }

    @Override
    protected void buildViewer() {
        super.buildViewer();
        mViewerBuilder = mViewerBuilder.usingTabClass(RNPdfViewCtrlTabFragment.class);
        if (!Utils.isNullOrEmpty(mTabTitle)) {
            mViewerBuilder = mViewerBuilder.usingTabTitle(mTabTitle);
        }
    }

    public void setDocument(String path) {
        if (Utils.isNullOrEmpty(path)) {
            return;
        }
        if (mDocumentPath != null) {
            // we are switching document
            Uri fileUri = ReactUtils.getUri(getContext(), path, mIsBase64);
            if (fileUri != null) {
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

    public void setDisabledElements(ReadableArray array) {
        disableElements(array);
    }

    public void setDisabledTools(ReadableArray array) {
        disableTools(array);
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

    public void setPageIndicatorEnabled(boolean pageIndicatorEnabled) {
        mBuilder = mBuilder.showPageNumberIndicator(pageIndicatorEnabled);
    }

    public void setHideToolbarsOnTap(boolean hideToolbarsOnTap) {
        mBuilder = mBuilder.permanentToolbars(!hideToolbarsOnTap);
    }

    public void setReadOnly(boolean readOnly) {
        mReadOnly = readOnly;
        if (readOnly) {
            mBuilder = mBuilder.skipReadOnlyCheck(false);
        } else {
            mBuilder = mBuilder.skipReadOnlyCheck(true);
        }
        if (getToolManager() != null) {
            getToolManager().setSkipReadOnlyCheck(false);
            getToolManager().setReadOnly(readOnly);
        }
    }

    public void setFitMode(String fitMode) {
        if (mPDFViewCtrlConfig != null) {
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
                mPDFViewCtrlConfig.setPageViewMode(mode);
            }
        }
    }

    public void setLayoutMode(String layoutMode) {
        String mode = null;
        if (LAYOUT_MODE_SINGLE.equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_SINGLEPAGE_VALUE;
        } else if (LAYOUT_MODE_CONTINUOUS.equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_CONTINUOUS_VALUE;
        } else if (LAYOUT_MODE_FACING.equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACING_VALUE;
        } else if (LAYOUT_MODE_FACING_CONTINUOUS.equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACING_CONT_VALUE;
        } else if (LAYOUT_MODE_FACING_COVER.equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACINGCOVER_VALUE;
        } else if (LAYOUT_MODE_FACING_COVER_CONTINUOUS.equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACINGCOVER_CONT_VALUE;
        }
        Context context = getContext();
        if (mode != null && context != null) {
            PdfViewCtrlSettingsManager.updateViewMode(context, mode);
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
    }

    public void setSignSignatureFieldsWithStamps(boolean signWithStamps) {
        mSignWithStamps = signWithStamps;
    }

    public void setAnnotationPermissionCheckEnabled(boolean annotPermissionCheckEnabled) {
        mToolManagerBuilder = mToolManagerBuilder.setAnnotPermission(annotPermissionCheckEnabled);
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
                    AnnotationToolbarBuilder toolbarBuilder = DefaultToolbars.getDefaultAnnotationToolbarBuilderByTag(tag);
                    mBuilder = mBuilder.addToolbarBuilder(toolbarBuilder);
                    annotationToolbarBuilders.add(toolbarBuilder);
                }
            } else if (type == ReadableType.Map) {
                // custom toolbars
                ReadableMap map = toolbars.getMap(i);
                if (map != null) {
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
                    if (!Utils.isNullOrEmpty(tag) && !Utils.isNullOrEmpty(toolbarName) &&
                            toolbarItems != null && toolbarItems.size() > 0) {
                        AnnotationToolbarBuilder toolbarBuilder = AnnotationToolbarBuilder.withTag(tag)
                                .setToolbarName(toolbarName)
                                .setIcon(convStringToToolbarDefaultIconRes(toolbarIcon));
                        for (int j = 0; j < toolbarItems.size(); j++) {
                            String toolStr = toolbarItems.getString(j);
                            ToolbarButtonType buttonType = convStringToToolbarType(toolStr);
                            int buttonId = convStringToButtonId(toolStr);
                            if (buttonType != null && buttonId != 0) {
                                if (buttonType == ToolbarButtonType.UNDO ||
                                        buttonType == ToolbarButtonType.REDO) {
                                    toolbarBuilder.addToolStickyButton(buttonType, buttonId);
                                } else {
                                    toolbarBuilder.addToolButton(buttonType, buttonId);
                                }
                            }
                        }
                        mBuilder = mBuilder.addToolbarBuilder(toolbarBuilder);
                        annotationToolbarBuilders.add(toolbarBuilder);
                    }
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

    private void disableElements(ReadableArray args) {
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
            } else if (BUTTON_THUMBNAIL_SLIDER.equals(item)) {
                mBuilder = mBuilder.showBottomNavBar(false);
            } else if (BUTTON_EDIT_PAGES.equals(item)) {
                mBuilder = mBuilder.showEditPagesOption(false);
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
            } else if (BUTTON_ANNOTATION_LIST.equals(item)) {
                mBuilder = mBuilder.showAnnotationsList(false);
            } else if (BUTTON_USER_BOOKMARK_LIST.equals(item)) {
                mBuilder = mBuilder.showUserBookmarksList(false);
            } else if (BUTTON_REFLOW.equals(item)) {
                mBuilder = mBuilder.showReflowOption(false);
                mViewModePickerItems.add(ViewModePickerDialogFragment.ViewModePickerItems.ITEM_ID_REFLOW);
            } else if (BUTTON_EDIT_MENU.equals(item)) {
                mBuilder = mBuilder.showEditMenuOption(false);
            } else if (BUTTON_CROP_PAGE.equals(item)) {
                mViewModePickerItems.add(ViewModePickerDialogFragment.ViewModePickerItems.ITEM_ID_USERCROP);
            }
        }
        disableTools(args);
    }

    private void disableTools(ReadableArray args) {
        for (int i = 0; i < args.size(); i++) {
            String item = args.getString(i);
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
        } else if (TOOL_ANNOTATION_CREATE_REDACTION.equals(item) || TOOL_ANNOTATION_CREATE_REDACTION_TEXT.equals(item)) {
            annotType = Annot.e_Redact;
        } else if (TOOL_ANNOTATION_CREATE_LINK.equals(item) || TOOL_ANNOTATION_CREATE_LINK_TEXT.equals(item)) {
            annotType = Annot.e_Link;
        } else if (TOOL_TEXT_SELECT.equals(item)) {
            annotType = Annot.e_Unknown;
        } else if (TOOL_PAN.equals(item)) {
            annotType = Annot.e_Unknown;
        } else if (TOOL_ANNOTATION_EDIT.equals(item)) {
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
        }
        return annotType;
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
        } else if (TOOL_ANNOTATION_EDIT.equals(item)) {
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
        } else if (TOOL_ANNOTATION_EDIT.equals(item)) {
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
            buttonType = ToolbarButtonType.STAMP;
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
            // TODO
        } else if (TOOL_ANNOTATION_CREATE_LINK.equals(item)) {
            buttonType = ToolbarButtonType.LINK;
        } else if (TOOL_ANNOTATION_CREATE_REDACTION_TEXT.equals(item)) {
            // TODO
        } else if (TOOL_ANNOTATION_CREATE_LINK_TEXT.equals(item)) {
            // TODO
        } else if (TOOL_ANNOTATION_EDIT.equals(item)) {
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
        } else if (id == R.id.qm_type) {
            menuStr = MENU_ID_STRING_TYPE;
        } else if (id == R.id.qm_ungroup) {
            menuStr = MENU_ID_STRING_UNGROUP;
        }

        return menuStr;
    }

    private ViewerConfig getConfig() {
        if (mCacheDir != null) {
            mBuilder.openUrlCachePath(mCacheDir)
                    .saveCopyExportPath(mCacheDir);
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
    protected void onAttachedToWindow() {
        if (null == mFragmentManager) {
            setSupportFragmentManager(mFragmentManagerSave);
        }
        // TODO, update base64 when ViewerBuilder supports byte array
        Uri fileUri = ReactUtils.getUri(getContext(), mDocumentPath, mIsBase64);
        if (fileUri != null) {
            setDocumentUri(fileUri);
            setViewerConfig(getConfig());
            if (mIsBase64 && fileUri.getPath() != null) {
                mTempFile = new File(fileUri.getPath());
            }
        }
        super.onAttachedToWindow();

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
            View annotToolbar = findViewById(R.id.annotationToolbar);
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
            getPdfViewCtrl().removeOnCanvasSizeChangeListener(mOnCanvasSizeChangeListener);
        }
        if (getToolManager() != null) {
            getToolManager().removeAnnotationModificationListener(mAnnotationModificationListener);
            getToolManager().removeAnnotationsSelectionListener(mAnnotationsSelectionListener);
            getToolManager().removePdfDocModificationListener(mPdfDocModificationListener);
            getToolManager().removeToolChangedListener(mToolChangedListener);
        }
        if (getPdfViewCtrlTabFragment() != null) {
            getPdfViewCtrlTabFragment().removeQuickMenuListener(mQuickMenuListener);
        }

        ActionUtils.getInstance().setActionInterceptCallback(null);

        super.onDetachedFromWindow();

        getViewTreeObserver().removeOnGlobalLayoutListener(mOnGlobalLayoutListener);

        if (mTempFile != null && mTempFile.exists()) {
            mTempFile.delete();
        }
    }

    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.onActivityResult(requestCode, resultCode, data);
        }
        if (getPdfViewCtrlTabFragment() != null) {
            getPdfViewCtrlTabFragment().onActivityResult(requestCode, resultCode, data);
        }
    }

    @Override
    public void onNavButtonPressed() {
        onReceiveNativeEvent(ON_NAV_BUTTON_PRESSED, ON_NAV_BUTTON_PRESSED);
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
        return false;
    }

    private boolean hasAnnotationsSelected() {
        return mSelectedAnnots != null && !mSelectedAnnots.isEmpty();
    }

    private WritableArray getAnnotationsData() {
        WritableArray annots = Arguments.createArray();

        for (Map.Entry<Annot, Integer> entry : mSelectedAnnots.entrySet()) {
            Annot key = entry.getKey();
            Integer value = entry.getValue();

            WritableMap annotPair = Arguments.createMap();

            // try to obtain id
            String uid = null;
            try {
                uid = key.getUniqueID() != null ? key.getUniqueID().getAsPDFText() : null;
            } catch (Exception e) {
                e.printStackTrace();
            }
            if (uid != null) {
                annotPair.putString(KEY_ANNOTATION_ID, uid);
                annotPair.putInt(KEY_ANNOTATION_PAGE, value);
                // try to obtain bbox
                try {
                    com.pdftron.pdf.Rect bbox = getPdfViewCtrl().getScreenRectForAnnot(key, value);
                    WritableMap bboxMap = Arguments.createMap();
                    bboxMap.putDouble(KEY_X1, bbox.getX1());
                    bboxMap.putDouble(KEY_Y1, bbox.getY1());
                    bboxMap.putDouble(KEY_X2, bbox.getX2());
                    bboxMap.putDouble(KEY_Y2, bbox.getY2());
                    bboxMap.putDouble(KEY_WIDTH, bbox.getWidth());
                    bboxMap.putDouble(KEY_HEIGHT, bbox.getHeight());
                    annotPair.putMap(KEY_ANNOTATION_RECT, bboxMap);
                } catch (Exception ex) {
                    ex.printStackTrace();
                }

                annots.pushMap(annotPair);
            }
        }
        return annots;
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
                        params.putArray(KEY_ANNOTATIONS, getAnnotationsData());
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
            if (mAnnotMenuItems != null && annot != null) {
                List<QuickMenuItem> removeList = new ArrayList<>();
                checkQuickMenu(quickMenu.getFirstRowMenuItems(), mAnnotMenuItems, removeList);
                checkQuickMenu(quickMenu.getSecondRowMenuItems(), mAnnotMenuItems, removeList);
                checkQuickMenu(quickMenu.getOverflowMenuItems(), mAnnotMenuItems, removeList);
                quickMenu.removeMenuEntries(removeList);

                if (quickMenu.getFirstRowMenuItems().size() == 0) {
                    quickMenu.setDividerVisibility(View.GONE);
                }
            }
            if (mLongPressMenuItems != null && null == annot) {
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
                    WritableMap params = Arguments.createMap();
                    params.putString(ON_ANNOTATIONS_SELECTED, ON_ANNOTATIONS_SELECTED);
                    params.putArray(KEY_ANNOTATIONS, getAnnotationsData());
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
                            WritableMap resultMap = Arguments.createMap();

                            Widget widget = new Widget(annot);
                            Field field = widget.getField();
                            String name = field.getName();

                            resultMap.putString(KEY_FIELD_NAME, name);
                            resultMap.putString(KEY_FIELD_VALUE, field.getValueAsString());
                            fieldsArray.pushMap(resultMap);
                        }
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            params.putArray(KEY_FIELDS, fieldsArray);
            onReceiveNativeEvent(params);
        }

        @Override
        public void onAnnotationsPreRemove(Map<Annot, Integer> map) {
            handleAnnotationChanged(KEY_ACTION_DELETE, map);

            handleExportAnnotationCommand(KEY_ACTION_DELETE, map);
        }

        @Override
        public void onAnnotationsRemoved(Map<Annot, Integer> map) {

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
        public void onBookmarkModified() {
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

        }

        @Override
        public void onPagesDeleted(List<Integer> list) {

        }

        @Override
        public void onPagesRotated(List<Integer> list) {

        }

        @Override
        public void onPageMoved(int i, int i1) {

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

    private ToolManager.ToolChangedListener mToolChangedListener = new ToolManager.ToolChangedListener() {
        @Override
        public void toolChanged(ToolManager.Tool newTool, @Nullable ToolManager.Tool oldTool) {

            String newToolString = null;
            if (newTool != null) {
                newToolString = convToolModeToString((ToolManager.ToolMode) newTool.getToolMode());
            }

            String oldToolString = null;
            if (oldTool != null) {
                oldToolString = convToolModeToString((ToolManager.ToolMode) newTool.getToolMode());
            }

            String unknownString = "unknown tool";

            WritableMap params = Arguments.createMap();
            params.putString(ON_TOOL_CHANGED, ON_TOOL_CHANGED);
            params.putString(KEY_PREVIOUS_TOOL, oldToolString != null ? oldToolString : unknownString);
            params.putString(KEY_TOOL, newToolString != null ? newToolString : unknownString);

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
            if (uid != null) {
                Integer value = entry.getValue();
                WritableMap annotData = Arguments.createMap();
                annotData.putString(KEY_ANNOTATION_ID, uid);
                annotData.putInt(KEY_ANNOTATION_PAGE, value);
                annotList.pushMap(annotData);
            }
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

            WritableMap params = Arguments.createMap();
            params.putString(ON_EXPORT_ANNOTATION_COMMAND, ON_EXPORT_ANNOTATION_COMMAND);
            if (xfdfCommand != null) {
                params.putString(KEY_ERROR, "XFDF command cannot be generated");
            } else {
                params.putString(KEY_ACTION, action);
                params.putString(KEY_XFDF_COMMAND, xfdfCommand);
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

        getPdfViewCtrl().addPageChangeListener(mPageChangeListener);
        getPdfViewCtrl().addOnCanvasSizeChangeListener(mOnCanvasSizeChangeListener);

        getToolManager().addAnnotationModificationListener(mAnnotationModificationListener);
        getToolManager().addAnnotationsSelectionListener(mAnnotationsSelectionListener);
        getToolManager().addPdfDocModificationListener(mPdfDocModificationListener);
        getToolManager().addToolChangedListener(mToolChangedListener);

        getToolManager().setStylusAsPen(mUseStylusAsPen);
        getToolManager().setSignSignatureFieldsWithStamps(mSignWithStamps);

        getPdfViewCtrlTabFragment().addQuickMenuListener(mQuickMenuListener);

        ActionUtils.getInstance().setActionInterceptCallback(mActionInterceptCallback);

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
                                params.putString(ON_EXPORT_ANNOTATION_COMMAND, ON_EXPORT_ANNOTATION_COMMAND);
                                params.putString(KEY_ACTION, s);
                                params.putString(KEY_XFDF_COMMAND, mCollabManager.getLastXfdf());
                                onReceiveNativeEvent(params);
                            }
                        }
                    });
                }
            }
        }

        onReceiveNativeEvent(ON_DOCUMENT_LOADED, tag);
    }

    @Override
    public boolean onOpenDocError() {
        super.onOpenDocError();

        String error = "Unknown error";
        if (getPdfViewCtrlTabFragment() != null) {
            int messageId = com.pdftron.pdf.tools.R.string.error_opening_doc_message;
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
            pdfViewCtrl.update(true);
        } catch (JSONException ex) {
            throw new PDFNetException("", 0L, TAG, "importBookmarkJson", "Unable to parse bookmark json.");
        } finally {
            if (shouldUnlock) {
                pdfViewCtrl.docUnlock();
            }
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

    public void importAnnotations(String xfdf) throws PDFNetException {
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

            FDFDoc fdfDoc = FDFDoc.createFromXFDF(xfdf);
            pdfDoc.fdfUpdate(fdfDoc);
            pdfViewCtrl.update(true);
        } finally {
            if (shouldUnlock) {
                pdfViewCtrl.docUnlock();
            }
        }
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
            getPdfViewCtrlTabFragment().setSavingEnabled(true);
            getPdfViewCtrlTabFragment().save(false, true, true);
            getPdfViewCtrlTabFragment().setSavingEnabled(mAutoSaveEnabled);
            if (mIsBase64 && mTempFile != null) {
                try {
                    byte[] data = FileUtils.readFileToByteArray(mTempFile);
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

    public String getDocumentPath() {
        if (mIsBase64 && mTempFile != null) {
            return mTempFile.getAbsolutePath();
        } else if (getPdfViewCtrlTabFragment() != null) {
            return getPdfViewCtrlTabFragment().getFilePath();
        }
        return null;
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

    public void closeAllTabs() {
        if (mPdfViewCtrlTabHostFragment != null) {
            mPdfViewCtrlTabHostFragment.closeAllTabs();
        }
    }

    public double getZoom() {
        PDFViewCtrl pdfViewCtrl = getPdfViewCtrl();
        return pdfViewCtrl.getZoom();
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
