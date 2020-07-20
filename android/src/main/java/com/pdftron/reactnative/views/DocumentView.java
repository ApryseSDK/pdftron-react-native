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
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.events.RCTEventEmitter;
import com.pdftron.collab.db.entity.AnnotationEntity;
import com.pdftron.collab.ui.viewer.CollabManager;
import com.pdftron.collab.ui.viewer.CollabViewerBuilder;
import com.pdftron.collab.ui.viewer.CollabViewerTabHostFragment;
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
import com.pdftron.pdf.annots.Widget;
import com.pdftron.pdf.config.PDFViewCtrlConfig;
import com.pdftron.pdf.config.ToolConfig;
import com.pdftron.pdf.config.ToolManagerBuilder;
import com.pdftron.pdf.config.ViewerConfig;
import com.pdftron.pdf.controls.PdfViewCtrlTabFragment;
import com.pdftron.pdf.controls.PdfViewCtrlTabHostFragment;
import com.pdftron.pdf.dialog.ViewModePickerDialogFragment;
import com.pdftron.pdf.model.AnnotStyle;
import com.pdftron.pdf.tools.AdvancedShapeCreate;
import com.pdftron.pdf.tools.FreehandCreate;
import com.pdftron.pdf.tools.QuickMenu;
import com.pdftron.pdf.tools.QuickMenuItem;
import com.pdftron.pdf.tools.Tool;
import com.pdftron.pdf.tools.ToolManager;
import com.pdftron.pdf.utils.ActionUtils;
import com.pdftron.pdf.utils.AnnotUtils;
import com.pdftron.pdf.utils.PdfDocManager;
import com.pdftron.pdf.utils.PdfViewCtrlSettingsManager;
import com.pdftron.pdf.utils.Utils;
import com.pdftron.pdf.utils.ViewerUtils;
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

public class DocumentView extends com.pdftron.pdf.controls.DocumentView {

    private static final String TAG = DocumentView.class.getSimpleName();

    // EVENTS
    private static final String ON_NAV_BUTTON_PRESSED = "onLeadingNavButtonPressed";
    private static final String ON_DOCUMENT_LOADED = "onDocumentLoaded";
    private static final String ON_PAGE_CHANGED = "onPageChanged";
    private static final String ON_ZOOM_CHANGED = "onZoomChanged";
    private static final String ON_ANNOTATION_CHANGED = "onAnnotationChanged";
    private static final String ON_DOCUMENT_ERROR = "onDocumentError";
    private static final String ON_EXPORT_ANNOTATION_COMMAND = "onExportAnnotationCommand";
    private static final String ON_ANNOTATION_MENU_PRESS = "onAnnotationMenuPress";
    private static final String ON_LONG_PRESS_MENU_PRESS = "onLongPressMenuPress";
    private static final String ON_ANNOTATIONS_SELECTED = "onAnnotationsSelected";
    private static final String ON_BEHAVIOR_ACTIVATED = "onBehaviorActivated";
    private static final String ON_FORM_FIELD_VALUE_CHANGED = "onFormFieldValueChanged";

    private static final String PREV_PAGE_KEY = "previousPageNumber";
    private static final String PAGE_CURRENT_KEY = "pageNumber";

    private static final String ZOOM_KEY = "zoom";

    private static final String KEY_LINK_BEHAVIOR_DATA = "url";

    private static final String KEY_annotList = "annotList";
    private static final String KEY_annotId = "id";
    private static final String KEY_annotPage = "pageNumber";
    private static final String KEY_annotRect = "rect";

    private static final String KEY_action = "action";
    private static final String KEY_action_add = "add";
    private static final String KEY_action_modify = "modify";
    private static final String KEY_action_delete = "delete";
    private static final String KEY_annotations = "annotations";
    private static final String KEY_xfdfCommand = "xfdfCommand";
    private static final String Key_fields = "fields";
    private static final String Key_fieldName = "fieldName";
    private static final String Key_fieldValue = "fieldValue";

    private static final String KEY_annotationMenu = "annotationMenu";
    private static final String KEY_longPressMenu = "longPressMenu";
    private static final String KEY_longPressText = "longPressText";

    private static final String KEY_data = "data";

    private static final String KEY_x1 = "x1";
    private static final String KEY_x2 = "x2";
    private static final String KEY_y1 = "y1";
    private static final String KEY_y2 = "y2";
    private static final String KEY_width = "width";
    private static final String KEY_height = "height";
    // EVENTS END

    // Config keys
    private static final String KEY_Config_linkPress = "linkPress";

    private String mDocumentPath;
    private boolean mIsBase64;
    private File mTempFile;

    private FragmentManager mFragmentManagerSave; // used to deal with lifecycle issue

    private PDFViewCtrlConfig mPDFViewCtrlConfig;
    private ToolManagerBuilder mToolManagerBuilder;
    private ViewerConfig.Builder mBuilder;

    private ArrayList<ToolManager.ToolMode> mDisabledTools = new ArrayList<>();

    private String mCacheDir;
    private int mInitialPageNumber = -1;

    private boolean mTopToolbarEnabled = true;
    private boolean mPadStatusBar;

    private boolean mAutoSaveEnabled = true;

    private boolean mUseStylusAsPen = false;

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

        mToolManagerBuilder = ToolManagerBuilder.from().setOpenToolbar(true);
        mBuilder = new ViewerConfig.Builder();
        mBuilder
                .fullscreenModeEnabled(false)
                .multiTabEnabled(false)
                .showCloseTabOption(false)
                .useSupportActionBar(false);
    }

    @Override
    protected PdfViewCtrlTabHostFragment getViewer() {
        if (mCollabEnabled) {
            // Create the Fragment using CollabViewerBuilder
            return CollabViewerBuilder.withUri(mDocumentUri, mPassword)
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
        mTopToolbarEnabled = topToolbarEnabled;
    }

    public void setBottomToolbarEnabled(boolean bottomToolbarEnabled) {
        mBuilder = mBuilder.showBottomNavBar(bottomToolbarEnabled);
    }

    public void setPageIndicatorEnabled(boolean pageIndicatorEnabled) {
        mBuilder = mBuilder.showPageNumberIndicator(pageIndicatorEnabled);
    }

    public void setReadOnly(boolean readOnly) {
        mBuilder = mBuilder.documentEditingEnabled(!readOnly);
    }

    public void setFitMode(String fitMode) {
        if (mPDFViewCtrlConfig != null) {
            PDFViewCtrl.PageViewMode mode = null;
            if ("FitPage".equals(fitMode)) {
                mode = PDFViewCtrl.PageViewMode.FIT_PAGE;
            } else if ("FitWidth".equals(fitMode)) {
                mode = PDFViewCtrl.PageViewMode.FIT_WIDTH;
            } else if ("FitHeight".equals(fitMode)) {
                mode = PDFViewCtrl.PageViewMode.FIT_HEIGHT;
            } else if ("Zoom".equals(fitMode)) {
                mode = PDFViewCtrl.PageViewMode.ZOOM;
            }
            if (mode != null) {
                mPDFViewCtrlConfig.setPageViewMode(mode);
            }
        }
    }

    public void setLayoutMode(String layoutMode) {
        String mode = null;
        if ("Single".equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_SINGLEPAGE_VALUE;
        } else if ("Continuous".equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_CONTINUOUS_VALUE;
        } else if ("Facing".equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACING_VALUE;
        } else if ("FacingContinuous".equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACING_CONT_VALUE;
        } else if ("FacingCover".equals(layoutMode)) {
            mode = PdfViewCtrlSettingsManager.KEY_PREF_VIEWMODE_FACINGCOVER_VALUE;
        } else if ("FacingCoverContinuous".equals(layoutMode)) {
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

    private void disableElements(ReadableArray args) {
        for (int i = 0; i < args.size(); i++) {
            String item = args.getString(i);
            if ("toolsButton".equals(item)) {
                mBuilder = mBuilder.showAnnotationToolbarOption(false);
            } else if ("searchButton".equals(item)) {
                mBuilder = mBuilder.showSearchView(false);
            } else if ("shareButton".equals(item)) {
                mBuilder = mBuilder.showShareOption(false);
            } else if ("viewControlsButton".equals(item)) {
                mBuilder = mBuilder.showDocumentSettingsOption(false);
            } else if ("thumbnailsButton".equals(item)) {
                mBuilder = mBuilder.showThumbnailView(false);
            } else if ("listsButton".equals(item)) {
                mBuilder = mBuilder
                        .showAnnotationsList(false)
                        .showOutlineList(false)
                        .showUserBookmarksList(false);
            } else if ("thumbnailSlider".equals(item)) {
                mBuilder = mBuilder.showBottomNavBar(false);
            } else if ("editPagesButton".equals(item)) {
                mBuilder = mBuilder.showEditPagesOption(false);
            } else if ("printButton".equals(item)) {
                mBuilder = mBuilder.showPrintOption(false);
            } else if ("closeButton".equals(item)) {
                mBuilder = mBuilder.showCloseTabOption(false);
            } else if ("saveCopyButton".equals(item)) {
                mBuilder = mBuilder.showSaveCopyOption(false);
            } else if ("formToolsButton".equals(item)) {
                mBuilder = mBuilder.showFormToolbarOption(false);
            } else if ("fillSignToolsButton".equals(item)) {
                mBuilder = mBuilder.showFillAndSignToolbarOption(false);
            } else if ("moreItemsButton".equals(item)) {
                mBuilder = mBuilder
                        .showEditPagesOption(false)
                        .showPrintOption(false)
                        .showCloseTabOption(false)
                        .showSaveCopyOption(false)
                        .showFormToolbarOption(false)
                        .showFillAndSignToolbarOption(false)
                        .showEditMenuOption(false)
                        .showReflowOption(false);
            } else if ("outlineListButton".equals(item)) {
                mBuilder = mBuilder.showOutlineList(false);
            } else if ("annotationListButton".equals(item)) {
                mBuilder = mBuilder.showAnnotationsList(false);
            } else if ("userBookmarkListButton".equals(item)) {
                mBuilder = mBuilder.showUserBookmarksList(false);
            } else if ("reflowButton".equals(item)) {
                mBuilder = mBuilder.showReflowOption(false);
            } else if ("editMenuButton".equals(item)) {
                mBuilder = mBuilder.showEditMenuOption(false);
            } else if ("cropPageButton".equals(item)) {
                mBuilder = mBuilder.hideViewModeItems(new ViewModePickerDialogFragment.ViewModePickerItems[]{
                        ViewModePickerDialogFragment.ViewModePickerItems.ITEM_ID_USERCROP
                });
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
        if ("freeHandToolButton".equals(item) || "AnnotationCreateFreeHand".equals(item)) {
            annotType = Annot.e_Ink;
        } else if ("highlightToolButton".equals(item) || "AnnotationCreateTextHighlight".equals(item)) {
            annotType = Annot.e_Highlight;
        } else if ("underlineToolButton".equals(item) || "AnnotationCreateTextUnderline".equals(item)) {
            annotType = Annot.e_Underline;
        } else if ("squigglyToolButton".equals(item) || "AnnotationCreateTextSquiggly".equals(item)) {
            annotType = Annot.e_Squiggly;
        } else if ("strikeoutToolButton".equals(item) || "AnnotationCreateTextStrikeout".equals(item)) {
            annotType = Annot.e_StrikeOut;
        } else if ("rectangleToolButton".equals(item) || "AnnotationCreateRectangle".equals(item)) {
            annotType = Annot.e_Square;
        } else if ("ellipseToolButton".equals(item) || "AnnotationCreateEllipse".equals(item)) {
            annotType = Annot.e_Circle;
        } else if ("lineToolButton".equals(item) || "AnnotationCreateLine".equals(item)) {
            annotType = Annot.e_Line;
        } else if ("arrowToolButton".equals(item) || "AnnotationCreateArrow".equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_ARROW;
        } else if ("polylineToolButton".equals(item) || "AnnotationCreatePolyline".equals(item)) {
            annotType = Annot.e_Polyline;
        } else if ("polygonToolButton".equals(item) || "AnnotationCreatePolygon".equals(item)) {
            annotType = Annot.e_Polygon;
        } else if ("cloudToolButton".equals(item) || "AnnotationCreatePolygonCloud".equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_CLOUD;
        } else if ("signatureToolButton".equals(item) || "AnnotationCreateSignature".equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_SIGNATURE;
        } else if ("freeTextToolButton".equals(item) || "AnnotationCreateFreeText".equals(item)) {
            annotType = Annot.e_FreeText;
        } else if ("stickyToolButton".equals(item) || "AnnotationCreateSticky".equals(item)) {
            annotType = Annot.e_Text;
        } else if ("calloutToolButton".equals(item) || "AnnotationCreateCallout".equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_CALLOUT;
        } else if ("stampToolButton".equals(item) || "AnnotationCreateStamp".equals(item)) {
            annotType = Annot.e_Stamp;
        } else if ("AnnotationCreateDistanceMeasurement".equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_RULER;
        } else if ("AnnotationCreatePerimeterMeasurement".equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_PERIMETER_MEASURE;
        } else if ("AnnotationCreateAreaMeasurement".equals(item)) {
            annotType = AnnotStyle.CUSTOM_ANNOT_TYPE_AREA_MEASURE;
        } else if ("AnnotationCreateFileAttachment".equals(item)) {
            annotType = Annot.e_FileAttachment;
        } else if ("AnnotationCreateSound".equals(item)) {
            annotType = Annot.e_Sound;
        } else if ("AnnotationCreateRedaction".equals(item) || "AnnotationCreateRedactionText".equals(item)) {
            annotType = Annot.e_Redact;
        } else if ("AnnotationCreateLink".equals(item) || "AnnotationCreateLinkText".equals(item)) {
            annotType = Annot.e_Link;
        } else if ("TextSelect".equals(item)) {
            annotType = Annot.e_Unknown;
        } else if ("Pan".equals(item)) {
            annotType = Annot.e_Unknown;
        } else if ("AnnotationEdit".equals(item)) {
            annotType = Annot.e_Unknown;
        } else if ("FormCreateTextField".equals(item)) {
            annotType = Annot.e_Widget;
        } else if ("FormCreateCheckboxField".equals(item)) {
            annotType = Annot.e_Widget;
        } else if ("FormCreateSignatureField".equals(item)) {
            annotType = Annot.e_Widget;
        } else if ("FormCreateRadioField".equals(item)) {
            annotType = Annot.e_Widget;
        } else if ("FormCreateComboBoxField".equals(item)) {
            annotType = Annot.e_Widget;
        } else if ("FormCreateListBoxField".equals(item)) {
            annotType = Annot.e_Widget;
        }
        return annotType;
    }

    @Nullable
    private ToolManager.ToolMode convStringToToolMode(String item) {
        ToolManager.ToolMode mode = null;
        if ("freeHandToolButton".equals(item) || "AnnotationCreateFreeHand".equals(item)) {
            mode = ToolManager.ToolMode.INK_CREATE;
        } else if ("highlightToolButton".equals(item) || "AnnotationCreateTextHighlight".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_HIGHLIGHT;
        } else if ("underlineToolButton".equals(item) || "AnnotationCreateTextUnderline".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_UNDERLINE;
        } else if ("squigglyToolButton".equals(item) || "AnnotationCreateTextSquiggly".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_SQUIGGLY;
        } else if ("strikeoutToolButton".equals(item) || "AnnotationCreateTextStrikeout".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_STRIKEOUT;
        } else if ("rectangleToolButton".equals(item) || "AnnotationCreateRectangle".equals(item)) {
            mode = ToolManager.ToolMode.RECT_CREATE;
        } else if ("ellipseToolButton".equals(item) || "AnnotationCreateEllipse".equals(item)) {
            mode = ToolManager.ToolMode.OVAL_CREATE;
        } else if ("lineToolButton".equals(item) || "AnnotationCreateLine".equals(item)) {
            mode = ToolManager.ToolMode.LINE_CREATE;
        } else if ("arrowToolButton".equals(item) || "AnnotationCreateArrow".equals(item)) {
            mode = ToolManager.ToolMode.ARROW_CREATE;
        } else if ("polylineToolButton".equals(item) || "AnnotationCreatePolyline".equals(item)) {
            mode = ToolManager.ToolMode.POLYLINE_CREATE;
        } else if ("polygonToolButton".equals(item) || "AnnotationCreatePolygon".equals(item)) {
            mode = ToolManager.ToolMode.POLYGON_CREATE;
        } else if ("cloudToolButton".equals(item) || "AnnotationCreatePolygonCloud".equals(item)) {
            mode = ToolManager.ToolMode.CLOUD_CREATE;
        } else if ("signatureToolButton".equals(item) || "AnnotationCreateSignature".equals(item)) {
            mode = ToolManager.ToolMode.SIGNATURE;
        } else if ("freeTextToolButton".equals(item) || "AnnotationCreateFreeText".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_CREATE;
        } else if ("stickyToolButton".equals(item) || "AnnotationCreateSticky".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_ANNOT_CREATE;
        } else if ("calloutToolButton".equals(item) || "AnnotationCreateCallout".equals(item)) {
            mode = ToolManager.ToolMode.CALLOUT_CREATE;
        } else if ("stampToolButton".equals(item) || "AnnotationCreateStamp".equals(item)) {
            mode = ToolManager.ToolMode.STAMPER;
        } else if ("AnnotationCreateRubberStamp".equals(item)) {
            mode = ToolManager.ToolMode.RUBBER_STAMPER;
        } else if ("AnnotationCreateDistanceMeasurement".equals(item)) {
            mode = ToolManager.ToolMode.RULER_CREATE;
        } else if ("AnnotationCreatePerimeterMeasurement".equals(item)) {
            mode = ToolManager.ToolMode.PERIMETER_MEASURE_CREATE;
        } else if ("AnnotationCreateAreaMeasurement".equals(item)) {
            mode = ToolManager.ToolMode.AREA_MEASURE_CREATE;
        } else if ("AnnotationCreateFileAttachment".equals(item)) {
            mode = ToolManager.ToolMode.FILE_ATTACHMENT_CREATE;
        } else if ("AnnotationCreateSound".equals(item)) {
            mode = ToolManager.ToolMode.SOUND_CREATE;
        } else if ("AnnotationCreateRedaction".equals(item)) {
            mode = ToolManager.ToolMode.RECT_REDACTION;
        } else if ("AnnotationCreateLink".equals(item)) {
            mode = ToolManager.ToolMode.RECT_LINK;
        } else if ("AnnotationCreateRedactionText".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_REDACTION;
        } else if ("AnnotationCreateLinkText".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_LINK_CREATE;
        } else if ("TextSelect".equals(item)) {
            mode = ToolManager.ToolMode.TEXT_SELECT;
        } else if ("Pan".equals(item)) {
            mode = ToolManager.ToolMode.PAN;
        } else if ("AnnotationEdit".equals(item)) {
            mode = ToolManager.ToolMode.ANNOT_EDIT_RECT_GROUP;
        } else if ("FormCreateTextField".equals(item)) {
            mode = ToolManager.ToolMode.FORM_TEXT_FIELD_CREATE;
        } else if ("FormCreateCheckboxField".equals(item)) {
            mode = ToolManager.ToolMode.FORM_CHECKBOX_CREATE;
        } else if ("FormCreateSignatureField".equals(item)) {
            mode = ToolManager.ToolMode.FORM_SIGNATURE_CREATE;
        } else if ("FormCreateRadioField".equals(item)) {
            mode = ToolManager.ToolMode.FORM_RADIO_GROUP_CREATE;
        } else if ("FormCreateComboBoxField".equals(item)) {
            mode = ToolManager.ToolMode.FORM_COMBO_BOX_CREATE;
        } else if ("FormCreateListBoxField".equals(item)) {
            mode = ToolManager.ToolMode.FORM_LIST_BOX_CREATE;
        }
        return mode;
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
            menuStr = "style";
        } else if (id == R.id.qm_note) {
            menuStr = "note";
        } else if (id == R.id.qm_copy) {
            menuStr = "copy";
        } else if (id == R.id.qm_delete) {
            menuStr = "delete";
        } else if (id == R.id.qm_flatten) {
            menuStr = "flatten";
        } else if (id == R.id.qm_text) {
            menuStr = "editText";
        } else if (id == R.id.qm_edit) {
            menuStr = "editInk";
        } else if (id == R.id.qm_search) {
            menuStr = "search";
        } else if (id == R.id.qm_share) {
            menuStr = "share";
        } else if (id == R.id.qm_type) {
            menuStr = "markupType";
        } else if (id == R.id.qm_tts) {
            menuStr = "textToSpeech";
        } else if (id == R.id.qm_screencap_create) {
            menuStr = "screenCapture";
        } else if (id == R.id.qm_play_sound) {
            menuStr = "playSound";
        } else if (id == R.id.qm_open_attachment) {
            menuStr = "openAttachment";
        } else if (id == R.id.qm_tts) {
            menuStr = "read";
        } else if (id == R.id.qm_share) {
            menuStr = "share";
        } else if (id == R.id.qm_search) {
            menuStr = "search";
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

        if (mPdfViewCtrlTabHostFragment != null) {
            if (!mTopToolbarEnabled) {
                mPdfViewCtrlTabHostFragment.setToolbarTimerDisabled(true);
                if (mPdfViewCtrlTabHostFragment.getToolbar() != null) {
                    mPdfViewCtrlTabHostFragment.getToolbar().setVisibility(GONE);
                }
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
                annotPair.putString(KEY_annotId, uid);
                annotPair.putInt(KEY_annotPage, value);
                // try to obtain bbox
                try {
                    com.pdftron.pdf.Rect bbox = getPdfViewCtrl().getScreenRectForAnnot(key, value);
                    WritableMap bboxMap = Arguments.createMap();
                    bboxMap.putDouble(KEY_x1, bbox.getX1());
                    bboxMap.putDouble(KEY_y1, bbox.getY1());
                    bboxMap.putDouble(KEY_x2, bbox.getX2());
                    bboxMap.putDouble(KEY_y2, bbox.getY2());
                    bboxMap.putDouble(KEY_width, bbox.getWidth());
                    bboxMap.putDouble(KEY_height, bbox.getHeight());
                    annotPair.putMap(KEY_annotRect, bboxMap);
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
                        params.putString(KEY_annotationMenu, menuStr);
                        params.putArray(KEY_annotations, getAnnotationsData());
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
                        params.putString(KEY_longPressMenu, menuStr);
                        params.putString(KEY_longPressText, ViewerUtils.getSelectedString(getPdfViewCtrl()));
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
                    params.putArray(KEY_annotations, getAnnotationsData());
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
            if (!isOverrideAction(KEY_Config_linkPress)) {
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
                params.putString(KEY_action, KEY_Config_linkPress);

                WritableMap data = Arguments.createMap();
                data.putString(KEY_LINK_BEHAVIOR_DATA, url);
                params.putMap(KEY_data, data);

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
            handleAnnotationChanged(KEY_action_add, map);
        }

        @Override
        public void onAnnotationsPreModify(Map<Annot, Integer> map) {

        }

        @Override
        public void onAnnotationsModified(Map<Annot, Integer> map, Bundle bundle) {
            handleAnnotationChanged(KEY_action_modify, map);

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

                            resultMap.putString(Key_fieldName, name);
                            resultMap.putString(Key_fieldValue, field.getValueAsString());
                            fieldsArray.pushMap(resultMap);
                        }
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }
            params.putArray(Key_fields, fieldsArray);
            onReceiveNativeEvent(params);
        }

        @Override
        public void onAnnotationsPreRemove(Map<Annot, Integer> map) {
            handleAnnotationChanged(KEY_action_delete, map);
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

    private void handleAnnotationChanged(String action, Map<Annot, Integer> map) {
        WritableMap params = Arguments.createMap();
        params.putString(ON_ANNOTATION_CHANGED, ON_ANNOTATION_CHANGED);
        params.putString(KEY_action, action);

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
                annotData.putString(KEY_annotId, uid);
                annotData.putInt(KEY_annotPage, value);
                annotList.pushMap(annotData);
            }
        }

        params.putArray(KEY_annotations, annotList);
        onReceiveNativeEvent(params);
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

        getPdfViewCtrl().addPageChangeListener(mPageChangeListener);
        getPdfViewCtrl().addOnCanvasSizeChangeListener(mOnCanvasSizeChangeListener);

        getToolManager().addAnnotationModificationListener(mAnnotationModificationListener);
        getToolManager().addAnnotationsSelectionListener(mAnnotationsSelectionListener);

        getToolManager().setStylusAsPen(mUseStylusAsPen);

        getPdfViewCtrlTabFragment().addQuickMenuListener(mQuickMenuListener);

        ActionUtils.getInstance().setActionInterceptCallback(mActionInterceptCallback);

        // collab
        if (mPdfViewCtrlTabHostFragment instanceof CollabViewerTabHostFragment) {
            CollabViewerTabHostFragment collabHost = (CollabViewerTabHostFragment) mPdfViewCtrlTabHostFragment;
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
                                params.putString(KEY_action, s);
                                params.putString(KEY_xfdfCommand, mCollabManager.getLastXfdf());
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

    public void importAnnotationCommand(String xfdfCommand, boolean initialLoad) throws PDFNetException {
        if (mCollabManager != null) {
            mCollabManager.importAnnotationCommand(xfdfCommand, initialLoad);
        } else {
            throw new PDFNetException("", 0L, TAG, "importAnnotationCommand", "set collabEnabled to true is required.");
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
            if (null == options || !options.hasKey(KEY_annotList)) {
                FDFDoc fdfDoc = pdfDoc.fdfExtract(PDFDoc.e_both);
                return fdfDoc.saveAsXFDF();
            } else {
                ReadableArray arr = options.getArray(KEY_annotList);
                ArrayList<Annot> annots = new ArrayList<>(arr.size());
                for (int i = 0; i < arr.size(); i++) {
                    ReadableMap annotData = arr.getMap(i);
                    String id = annotData.getString(KEY_annotId);
                    int page = annotData.getInt(KEY_annotPage);
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
                return getPdfViewCtrlTabFragment().getFilePath();
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
            String annotId = annotData.getString(KEY_annotId);
            int pageNum = annotData.getInt(KEY_annotPage);
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

    public void setValueForFields(ReadableMap readableMap) throws PDFNetException {
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
                        (Field.e_text == fieldType || Field.e_radio == fieldType)) {
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

    public boolean canExitViewer() {
        PdfViewCtrlTabFragment currentFragment = getPdfViewCtrlTabFragment();
        if (currentFragment.isAnnotationMode()) {
            return false;
        }
        if (currentFragment.isSearchMode()) {
            return false;
        }
        return true;
    }

    public PdfViewCtrlTabFragment getPdfViewCtrlTabFragment() {
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
