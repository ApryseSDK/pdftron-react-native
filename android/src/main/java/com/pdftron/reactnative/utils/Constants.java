package com.pdftron.reactnative.utils;

public final class Constants {
    // EVENTS
    public static final String ON_NAV_BUTTON_PRESSED = "onLeadingNavButtonPressed";
    public static final String ON_DOCUMENT_LOADED = "onDocumentLoaded";
    public static final String ON_PAGE_CHANGED = "onPageChanged";
    public static final String ON_ZOOM_CHANGED = "onZoomChanged";
    public static final String ON_ANNOTATION_CHANGED = "onAnnotationChanged";
    public static final String ON_DOCUMENT_ERROR = "onDocumentError";
    public static final String ON_EXPORT_ANNOTATION_COMMAND = "onExportAnnotationCommand";
    public static final String ON_ANNOTATION_MENU_PRESS = "onAnnotationMenuPress";
    public static final String ON_LONG_PRESS_MENU_PRESS = "onLongPressMenuPress";
    public static final String ON_ANNOTATIONS_SELECTED = "onAnnotationsSelected";
    public static final String ON_BEHAVIOR_ACTIVATED = "onBehaviorActivated";
    public static final String ON_FORM_FIELD_VALUE_CHANGED = "onFormFieldValueChanged";
    public static final String ON_BOOKMARK_CHANGED = "onBookmarkChanged";

    // BUTTONS
    public static final String BUTTON_TOOLS = "toolsButton";
    public static final String BUTTON_SEARCH = "searchButton";
    public static final String BUTTON_SHARE = "shareButton";
    public static final String BUTTON_VIEW_CONTROLS = "viewControlsButton";
    public static final String BUTTON_THUMBNAILS = "thumbnailsButton";
    public static final String BUTTON_LISTS = "listsButton";
    public static final String BUTTON_THUMBNAIL_SLIDER = "thumbnailSlider";
    public static final String BUTTON_SAVE_COPY = "saveCopyButton";
    public static final String BUTTON_EDIT_PAGES = "editPagesButton";
    public static final String BUTTON_PRINT = "printButton";
    public static final String BUTTON_CLOSE = "closeButton";
    public static final String BUTTON_FORM_TOOLS = "formToolsButton";
    public static final String BUTTON_FILL_SIGN_TOOLS = "fillSignToolsButton";
    public static final String BUTTON_MORE_ITEMS = "moreItemsButton";
    public static final String BUTTON_OUTLINE_LIST = "outlineListButton";
    public static final String BUTTON_ANNOTATION_LIST = "annotationListButton";
    public static final String BUTTON_USER_BOOKMARK_LIST = "userBookmarkListButton";
    public static final String BUTTON_REFLOW = "reflowButton";
    public static final String BUTTON_EDIT_MENU = "editMenuButton";
    public static final String BUTTON_CROP_PAGE = "cropPageButton";

    // TOOL BUTTONS
    public static final String TOOL_BUTTON_FREE_HAND = "freeHandToolButton";
    public static final String TOOL_BUTTON_HIGHTLIGHT = "hightlightToolButton";
    public static final String TOOL_BUTTON_UNDERLINE = "underlineToolButton";
    public static final String TOOL_BUTTON_SQUIGGLY = "squigglyToolButton";
    public static final String TOOL_BUTTON_STRIKEOUT = "strikeoutToolButton";
    public static final String TOOL_BUTTON_RECTANGLE = "rectangleToolButton";
    public static final String TOOL_BUTTON_ELLIPSE = "ellipseToolButton";
    public static final String TOOL_BUTTON_LINE = "lineToolButton";
    public static final String TOOL_BUTTON_ARROW = "arrowToolButton";
    public static final String TOOL_BUTTON_POLYLINE = "polylineToolButton";
    public static final String TOOL_BUTTON_POLYGON = "polygonToolButton";
    public static final String TOOL_BUTTON_CLOUD = "cloudToolButton";
    public static final String TOOL_BUTTON_SIGNATURE = "signatureToolButton";
    public static final String TOOL_BUTTON_FREE_TEXT = "freeTextToolButton";
    public static final String TOOL_BUTTON_STICKY = "stickyToolButton";
    public static final String TOOL_BUTTON_CALLOUT = "calloutToolButton";
    public static final String TOOL_BUTTON_STAMP = "stampToolButton";

    // TOOLS
    public static final String TOOL_ANNOTATION_CREATE_FREE_HAND = "AnnotationCreateFreeHand";
    public static final String TOOL_ANNOTATION_CREATE_TEXT_HIGHLIGHT = "AnnotationCreateTextHighlight";
    public static final String TOOL_ANNOTATION_CREATE_TEXT_UNDERLINE = "AnnotationCreateTextUnderline";
    public static final String TOOL_ANNOTATION_CREATE_TEXT_SQUIGGLY = "AnnotationCreateTextSquiggly";
    public static final String TOOL_ANNOTATION_CREATE_TEXT_STRIKEOUT = "AnnotationCreateTextStrikeout";
    public static final String TOOL_ANNOTATION_CREATE_RECTANGLE = "AnnotationCreateRectangle";
    public static final String TOOL_ANNOTATION_CREATE_ELLIPSE = "AnnotationCreateEllipse";
    public static final String TOOL_ANNOTATION_CREATE_LINE = "AnnotationCreateLine";
    public static final String TOOL_ANNOTATION_CREATE_ARROW = "AnnotationCreateArrow";
    public static final String TOOL_ANNOTATION_CREATE_POLYLINE = "AnnotationCreatePolyline";
    public static final String TOOL_ANNOTATION_CREATE_POLYGON = "AnnotationCreatePolygon";
    public static final String TOOL_ANNOTATION_CREATE_POLYGON_CLOUD = "AnnotationCreatePolygonCloud";
    public static final String TOOL_ANNOTATION_CREATE_SIGNATURE = "AnnotationCreateSignature";
    public static final String TOOL_ANNOTATION_CREATE_FREE_TEXT = "AnnotationCreateFreeText";
    public static final String TOOL_ANNOTATION_CREATE_STICKY = "AnnotationCreateSticky";
    public static final String TOOL_ANNOTATION_CREATE_CALLOUT = "AnnotationCreateCallout";
    public static final String TOOL_ANNOTATION_CREATE_STAMP = "AnnotationCreateStamp";
    public static final String TOOL_ANNOTATION_CREATE_DISTANCE_MEASUREMENT = "AnnotationCreateDistanceMeasurement";
    public static final String TOOL_ANNOTATION_CREATE_PERIMETER_MEASUREMENT = "AnnotationCreatePerimeterMeasurement";
    public static final String TOOL_ANNOTATION_CREATE_AREA_MEASUREMENT = "AnnotationCreateAreaMeasurement";
    public static final String TOOL_TEXT_SELECT = "TextSelect";
    public static final String TOOL_ANNOTATION_EDIT = "AnnotationEdit";
    public static final String TOOL_ANNOTATION_CREATE_SOUND = "AnnotationCreateSound";
    public static final String TOOL_PAN = "pan";
    public static final String TOOL_ANNOTATION_CREATE_FILE_ATTACHMENT = "AnnotationCreateFileAttachment";
    public static final String TOOL_ANNOTATION_CREATE_REDACTION = "AnnotationCreateRedaction";
    public static final String TOOL_ANNOTATION_CREATE_REDACTION_TEXT = "AnnotationCreateRedactionText";
    public static final String TOOL_ANNOTATION_CREATE_LINK = "AnnotationCreateLink";
    public static final String TOOL_ANNOTATION_CREATE_LINK_TEXT = "AnnotationCreateLinkText";
    public static final String TOOL_FORM_CREATE_TEXT_FIELD = "FormCreateTextField";
    public static final String TOOL_FORM_CREATE_CHECKBOX_FIELD = "FormCreateCheckboxField";
    public static final String TOOL_FORM_CREATE_SIGNATURE_FIELD = "FormCreateSignatureField";
    public static final String TOOL_FORM_CREATE_RADIO_FIELD = "FormCreateRadioField";
    public static final String TOOL_FORM_CREATE_COMBO_BOX_FIELD = "FormCreateComboBoxField";
    public static final String TOOL_FORM_CREATE_TOOL_BOX_FIELD = "FormCreateToolBoxField";
    public static final String TOOL_FORM_CREATE_LIST_BOX_FIELD = "FormCreateListBoxField";
    public static final String TOOL_ANNOTATION_CREATE_RUBBER_STAMP = "AnnotationCreateRubberStamp";
    public static final String TOOL_ANNOTATION_ERASER_TOOL = "AnnotationEraserTool";

    // FIT MODES
    public static final String FIT_MODE_FIT_PAGE = "FitPage";
    public static final String FIT_MODE_FIT_WIDTH = "FitWidth";
    public static final String FIT_MODE_FIT_HEIGHT = "FitHeight";
    public static final String FIT_MODE_ZOOM = "Zoom";

    // LAYOUT MODES
    public static final String LAYOUT_MODE_SINGLE = "Single";
    public static final String LAYOUT_MODE_CONTINUOUS = "Continuous";
    public static final String LAYOUT_MODE_FACING = "facing";
    public static final String LAYOUT_MODE_FACING_CONTINUOUS = "facingContinuous";
    public static final String LAYOUT_MODE_FACING_OVER = "facingOver";
    public static final String LAYOUT_MODE_FACING_OVER_CONTINUOUS = "facingOverContinuous";

    // MENU ID STRINGS
    public static final String MENU_ID_STRING_STYLE = "style";
    public static final String MENU_ID_STRING_NOTE = "note";
    public static final String MENU_ID_STRING_COPY = "copy";
    public static final String MENU_ID_STRING_DELETE = "delete";
    public static final String MENU_ID_STRING_FLATTEN = "flatten";
    public static final String MENU_ID_STRING_TEXT = "text";
    public static final String MENU_ID_STRING_EDIT_INK = "editInk";
    public static final String MENU_ID_STRING_SEARCH = "search";
    public static final String MENU_ID_STRING_SHARE = "share";
    public static final String MENU_ID_STRING_MARKUP_TYPE = "markupType";
    public static final String MENU_ID_STRING_SCREEN_CAPTURE = "screenCapture";
    public static final String MENU_ID_STRING_PLAY_SOUND = "playSound";
    public static final String MENU_ID_STRING_OPEN_ATTACHMENT = "openAttachment";
    public static final String MENU_ID_STRING_READ = "read";
    public static final String MENU_ID_STRING_CALIBRATE = "calibrate";


    public static final String PREV_PAGE_KEY = "previousPageNumber";
    public static final String PAGE_CURRENT_KEY = "pageNumber";

    public static final String ZOOM_KEY = "zoom";

    public static final String KEY_LINK_BEHAVIOR_DATA = "url";

    public static final String KEY_annotList = "annotList";
    public static final String KEY_annotId = "id";
    public static final String KEY_annotPage = "pageNumber";
    public static final String KEY_annotRect = "rect";
    public static final String KEY_annotFlag = "flag";
    public static final String KEY_annotFlagValue = "flagValue";
    public static final String KEY_annotSubject = "subject";
    public static final String KEY_annotTitle = "title";
    public static final String KEY_annotContents = "contents";
    public static final String KEY_annotContentRect = "contentRect";

    public static final String KEY_action = "action";
    public static final String KEY_action_add = "add";
    public static final String KEY_action_modify = "modify";
    public static final String KEY_action_delete = "delete";
    public static final String KEY_annotations = "annotations";
    public static final String KEY_xfdfCommand = "xfdfCommand";
    public static final String Key_fields = "fields";
    public static final String Key_fieldName = "fieldName";
    public static final String Key_fieldValue = "fieldValue";

    public static final String KEY_annotationMenu = "annotationMenu";
    public static final String KEY_longPressMenu = "longPressMenu";
    public static final String KEY_longPressText = "longPressText";

    public static final String KEY_data = "data";

    public static final String KEY_x1 = "x1";
    public static final String KEY_x2 = "x2";
    public static final String KEY_y1 = "y1";
    public static final String KEY_y2 = "y2";
    public static final String KEY_width = "width";
    public static final String KEY_height = "height";

    public static final String KEY_annotFlagHidden = "hidden";
    public static final String KEY_annotFlagInvisible = "invisible";
    public static final String KEY_annotFlagLocked = "locked";
    public static final String KEY_annotFlagLockedContents = "lockedContents";
    public static final String KEY_annotFlagNoRotate = "noRotate";
    public static final String KEY_flagNoView = "noView";
    public static final String KEY_flagNoZoom = "noZoom";
    public static final String kEY_flagPrint = "print";
    public static final String KEY_flagReadOnly = "readOnly";
    public static final String KEY_flagToggleNoView = "toggleNoView";

    public static final String KEY_bookmark_json = "bookmarkJson";
    // EVENTS END

    // Config keys
    public static final String KEY_Config_linkPress = "linkPress";
}
