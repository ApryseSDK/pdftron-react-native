package com.pdftron.reactnative.utils;

public final class Constants {
    // EVENTS
    public static final String ON_NAV_BUTTON_PRESSED = "onLeadingNavButtonPressed";
    public static final String ON_DOCUMENT_LOADED = "onDocumentLoaded";
    public static final String ON_PAGE_CHANGED = "onPageChanged";
    public static final String ON_SCROLL_CHANGED = "onScrollChanged";
    public static final String ON_ZOOM_CHANGED = "onZoomChanged";
    public static final String ON_ZOOM_FINISHED = "onZoomFinished";
    public static final String ON_ANNOTATION_CHANGED = "onAnnotationChanged";
    public static final String ON_DOCUMENT_ERROR = "onDocumentError";
    public static final String ON_EXPORT_ANNOTATION_COMMAND = "onExportAnnotationCommand";
    public static final String ON_ANNOTATION_MENU_PRESS = "onAnnotationMenuPress";
    public static final String ON_LONG_PRESS_MENU_PRESS = "onLongPressMenuPress";
    public static final String ON_ANNOTATIONS_SELECTED = "onAnnotationsSelected";
    public static final String ON_BEHAVIOR_ACTIVATED = "onBehaviorActivated";
    public static final String ON_FORM_FIELD_VALUE_CHANGED = "onFormFieldValueChanged";
    public static final String ON_BOOKMARK_CHANGED = "onBookmarkChanged";
    public static final String ON_TOOL_CHANGED = "onToolChanged";
    public static final String ON_LAYOUT_CHANGED = "onLayoutChanged";
    public static final String ON_TEXT_SEARCH_START = "onTextSearchStart";
    public static final String ON_TEXT_SEARCH_RESULT = "onTextSearchResult";
    public static final String ON_UNDO_REDO_STATE_CHANGED = "onUndoRedoStateChanged";
    public static final String ON_PAGE_MOVED = "onPageMoved";
    public static final String ON_PAGES_ADDED = "onPagesAdded";
    public static final String ON_PAGES_REMOVED = "onPagesRemoved";
    public static final String ON_PAGES_ROTATED = "onPagesRotated";
    public static final String ON_TAB_CHANGED = "onTabChanged";
    public static final String ON_ANNOTATION_FLATTENED = "onAnnotationFlattened";
    public static final String ON_ANNOTATION_TOOLBAR_ITEM_PRESS = "onAnnotationToolbarItemPress";
    public static final String ON_SAVED_SIGNATURES_CHANGED = "onSavedSignaturesChanged";
    public static final String ON_TOOLBAR_BUTTON_PRESS = "onToolbarButtonPress";

    // Hygen Generated Event Listeners
    public static final String ON_CURRENT_TOOLBAR_CHANGED = "onCurrentToolbarChanged";

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
    public static final String BUTTON_DIGITAL_SIGNATURE = "digitalSignatureButton";
    public static final String BUTTON_VIEW_LAYERS = "viewLayersButton";
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
    public static final String BUTTON_UNDO = "undo";
    public static final String BUTTON_REDO = "redo";
    public static final String BUTTON_SAVE_IDENTICAL_COPY = "saveIdenticalCopyButton";
    public static final String BUTTON_SAVE_FLATTENED_COPY = "saveFlattenedCopyButton";
    public static final String BUTTON_SAVE_REDUCED_COPY = "saveReducedCopyButton";
    public static final String BUTTON_SAVE_CROPPED_COPY = "saveCroppedCopyButton";
    public static final String BUTTON_SAVE_PASSWORD_COPY = "savePasswordCopyButton";
    public static final String BUTTON_TABS = "tabsButton";
    public static final String BUTTON_FILE_ATTACHMENT = "fileAttachmentButton";

    // TOOL BUTTONS
    public static final String TOOL_BUTTON_FREE_HAND = "freeHandToolButton";
    public static final String TOOL_BUTTON_HIGHLIGHT = "highlightToolButton";
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
    public static final String TOOL_BUTTON_EDIT = "editToolButton";
    public static final String TOOL_BUTTON_ADD_PAGE = "addPageButton";
    public static final String TOOL_BUTTON_INSERT_PAGE = "insertPageButton";

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
    public static final String TOOL_ANNOTATION_CREATE_RECT_AREA_MEASUREMENT = "AnnotationCreateRectAreaMeasurement";
    public static final String TOOL_TEXT_SELECT = "TextSelect";
    public static final String TOOL_MULTI_SELECT = "MultiSelect";
    public static final String TOOL_ANNOTATION_EDIT = "AnnotationEdit";
    public static final String TOOL_ANNOTATION_CREATE_SOUND = "AnnotationCreateSound";
    public static final String TOOL_PAN = "Pan";
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
    public static final String TOOL_ANNOTATION_CREATE_FREE_HIGHLIGHTER = "AnnotationCreateFreeHighlighter";
    public static final String TOOL_ANNOTATION_CREATE_SMART_PEN = "AnnotationCreateSmartPen";
    public static final String TOOL_ANNOTATION_CREATE_FREE_TEXT_DATE = "AnnotationCreateFreeTextDate";
    public static final String TOOL_ANNOTATION_CREATE_FREE_SPACING_TEXT = "AnnotationCreateFreeSpacingText";
    public static final String TOOL_INSERT_PAGE = "InsertPage";
    public static final String TOOL_FORM_FILL = "FormFill";
    public static final String TOOL_ANNOTATION_CREATE_CHECK_MARK_STAMP = "AnnotationCreateCheckMarkStamp";
    public static final String TOOL_ANNOTATION_CREATE_CROSS_MARK_STAMP = "AnnotationCreateCrossMarkStamp";
    public static final String TOOL_ANNOTATION_CREATE_DOT_STAMP = "AnnotationCreateDotStamp";
    public static final String TOOL_COUNT_TOOL = "AnnotationCountTool";

    // Field types
    public static final String FIELD_TYPE_UNKNOWN = "unknown";
    public static final String FIELD_TYPE_BUTTON = "button";
    public static final String FIELD_TYPE_CHECKBOX = "checkbox";
    public static final String FIELD_TYPE_RADIO = "radio";
    public static final String FIELD_TYPE_TEXT = "text";
    public static final String FIELD_TYPE_CHOICE = "choice";
    public static final String FIELD_TYPE_SIGNATURE = "signature";

    // Toolbars
    public static final String TAG_VIEW_TOOLBAR = "PDFTron_View";
    public static final String TAG_ANNOTATE_TOOLBAR = "PDFTron_Annotate";
    public static final String TAG_DRAW_TOOLBAR = "PDFTron_Draw";
    public static final String TAG_INSERT_TOOLBAR = "PDFTron_Insert";
    public static final String TAG_FILL_AND_SIGN_TOOLBAR = "PDFTron_Fill_and_Sign";
    public static final String TAG_PREPARE_FORM_TOOLBAR = "PDFTron_Prepare_Form";
    public static final String TAG_MEASURE_TOOLBAR = "PDFTron_Measure";
    public static final String TAG_REDACTION_TOOLBAR = "PDFTron_Redact";
    public static final String TAG_PENS_TOOLBAR = "PDFTron_Pens";
    public static final String TAG_FAVORITE_TOOLBAR = "PDFTron_Favorite";

    // Custom toolbars
    public static final String TOOLBAR_KEY_ID = "id";
    public static final String TOOLBAR_KEY_NAME = "name";
    public static final String TOOLBAR_KEY_ICON = "icon";
    public static final String TOOLBAR_KEY_ITEMS = "items";

    // Custom button
    public static final String TOOLBAR_ITEM_KEY_ID = "id";
    public static final String TOOLBAR_ITEM_KEY_NAME = "name";
    public static final String TOOLBAR_ITEM_KEY_ICON = "icon";

    // FIT MODES
    public static final String FIT_MODE_FIT_PAGE = "FitPage";
    public static final String FIT_MODE_FIT_WIDTH = "FitWidth";
    public static final String FIT_MODE_FIT_HEIGHT = "FitHeight";
    public static final String FIT_MODE_ZOOM = "Zoom";

    // LAYOUT MODES
    public static final String LAYOUT_MODE_SINGLE = "Single";
    public static final String LAYOUT_MODE_CONTINUOUS = "Continuous";
    public static final String LAYOUT_MODE_FACING = "Facing";
    public static final String LAYOUT_MODE_FACING_CONTINUOUS = "FacingContinuous";
    public static final String LAYOUT_MODE_FACING_COVER = "FacingCover";
    public static final String LAYOUT_MODE_FACING_COVER_CONTINUOUS = "FacingCoverContinuous";

    // ERASER TYPES
    public static final String ANNOTATION_ERASER = "annotationEraser";
    public static final String HYBRID_ERASER = "hybrideEraser";
    public static final String INK_ERASER = "inkEraser";

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
    public static final String MENU_ID_STRING_REDACT = "redact";
    public static final String MENU_ID_STRING_REDACTION = "redaction";
    public static final String MENU_ID_STRING_UNDERLINE = "underline";
    public static final String MENU_ID_STRING_STRIKEOUT = "strikeout";
    public static final String MENU_ID_STRING_SQUIGGLY = "squiggly";
    public static final String MENU_ID_STRING_LINK = "link";
    public static final String MENU_ID_STRING_HIGHLIGHT = "highlight";
    public static final String MENU_ID_STRING_SIGNATURE = "signature";
    public static final String MENU_ID_STRING_RECTANGLE = "rectangle";
    public static final String MENU_ID_STRING_LINE = "line";
    public static final String MENU_ID_STRING_FREE_HAND = "freeHand";
    public static final String MENU_ID_STRING_IMAGE = "image";
    public static final String MENU_ID_STRING_FORM_TEXT = "formText";
    public static final String MENU_ID_STRING_STICKY_NOTE = "stickyNote";
    public static final String MENU_ID_STRING_OVERFLOW = "overflow";
    public static final String MENU_ID_STRING_ERASER = "eraser";
    public static final String MENU_ID_STRING_STAMP = "rubberStamp";
    public static final String MENU_ID_STRING_PAGE_REDACTION = "pageRedaction";
    public static final String MENU_ID_STRING_RECT_REDACTION = "rectRedaction";
    public static final String MENU_ID_STRING_SEARCH_REDACTION = "searchRedaction";
    public static final String MENU_ID_STRING_SHAPE = "shape";
    public static final String MENU_ID_STRING_CLOUD = "cloud";
    public static final String MENU_ID_STRING_POLYGON = "polygon";
    public static final String MENU_ID_STRING_POLYLINE = "polyline";
    public static final String MENU_ID_STRING_FREE_HIGHLIGHTER = "freeHighlighter";
    public static final String MENU_ID_STRING_ARROW = "arrow";
    public static final String MENU_ID_STRING_OVAL = "oval";
    public static final String MENU_ID_STRING_CALLOUT = "callout";
    public static final String MENU_ID_STRING_MEASUREMENT = "measurement";
    public static final String MENU_ID_STRING_AREA_MEASUREMENT = "areaMeasurement";
    public static final String MENU_ID_STRING_PERIMETER_MEASUREMENT = "perimeterMeasurement";
    public static final String MENU_ID_STRING_RECT_AREA_MEASUREMENT = "rectAreaMeasurement";
    public static final String MENU_ID_STRING_RULER = "ruler";
    public static final String MENU_ID_STRING_FORM = "form";
    public static final String MENU_ID_STRING_FORM_COMBO_BOX = "formComboBox";
    public static final String MENU_ID_STRING_FORM_LIST_BOX = "formListBox";
    public static final String MENU_ID_STRING_FORM_CHECK_BOX = "formCheckBox";
    public static final String MENU_ID_STRING_FORM_SIGNATURE = "formSignature";
    public static final String MENU_ID_STRING_FORM_RADIO_GROUP = "formRadioGroup";
    public static final String MENU_ID_STRING_ATTACH = "attach";
    public static final String MENU_ID_STRING_FILE_ATTACHMENT = "fileAttachment";
    public static final String MENU_ID_STRING_SOUND = "sound";
    public static final String MENU_ID_STRING_FREE_TEXT = "freeText";
    public static final String MENU_ID_STRING_CROP = "crop";
    public static final String MENU_ID_STRING_CROP_OK = "crossOK";
    public static final String MENU_ID_STRING_CROP_CANCEL = "crossCancel";
    public static final String MENU_ID_STRING_DEFINE = "define";
    public static final String MENU_ID_STRING_FIELD_SIGNED = "fieldSigned";
    public static final String MENU_ID_STRING_FIRST_ROW_GROUP = "firstRowGroup";
    public static final String MENU_ID_STRING_SECOND_ROW_GROUP = "secondRowGroup";
    public static final String MENU_ID_STRING_GROUP = "group";
    public static final String MENU_ID_STRING_PASTE = "paste";
    public static final String MENU_ID_STRING_RECT_GROUP_SELECT = "rectGroupSelect";
    public static final String MENU_ID_STRING_SIGN_AND_SAVE = "signAndSave";
    public static final String MENU_ID_STRING_THICKNESS = "thickness";
    public static final String MENU_ID_STRING_TRANSLATE = "translate";
    public static final String MENU_ID_STRING_UNGROUP = "ungroup";
    public static final String MENU_ID_STRING_DUPLICATE = "duplicate";

    // Thumbnails
    public static final String THUMBNAIL_FILTER_MODE_ANNOTATED = "annotated";
    public static final String THUMBNAIL_FILTER_MODE_BOOKMARKED = "bookmarked";
    public static final String THUMBNAIL_INSERT_PAGES = "thumbnailsInsertPages";
    public static final String THUMBNAIL_EXPORT_PAGES = "thumbnailsExportPages";
    public static final String THUMBNAIL_DUPLICATE_PAGES = "thumbnailsDuplicatePages";
    public static final String THUMBNAIL_ROTATE_PAGES = "thumbnailsRotatePages";
    public static final String THUMBNAIL_DELETE_PAGES = "thumbnailsDeletePages";
    public static final String THUMBNAIL_INSERT_FROM_IMAGE = "thumbnailsInsertFromImage";
    public static final String THUMBNAIL_INSERT_FROM_DOCUMENT = "thumbnailsInsertFromDocument";

    public static final String VIEW_MODE_CROP = "viewModeCrop";
    public static final String VIEW_MODE_ROTATION = "viewModeRotation";
    public static final String VIEW_MODE_COLORMODE = "viewModeColorMode";
    public static final String VIEW_MODE_READER_MODE_SETTINGS = "viewModeReaderModeSettings";

    public static final String PREV_PAGE_KEY = "previousPageNumber";
    public static final String PAGE_CURRENT_KEY = "pageNumber";

    public static final String ZOOM_KEY = "zoom";

    public static final String KEY_LINK_BEHAVIOR_DATA = "url";

    public static final String KEY_TEXT_SELECTION = "textSelection";
    public static final String KEY_TEXT_SELECTION_FOUND = "found";
    public static final String KEY_TEXT_SELECTION_PAGE_NUMBER = "pageNumber";
    public static final String KEY_TEXT_SELECTION_UNICODE = "unicode";
    public static final String KEY_TEXT_SELECTION_HTML = "html";
    public static final String KEY_TEXT_SELECTION_QUADS = "quads";

    public static final String KEY_TEXT_SELECTION_QUAD_POINT_X = "x";
    public static final String KEY_TEXT_SELECTION_QUAD_POINT_Y = "y";

    public static final String KEY_TEXT_SELECTION_PAGE_RANGE_BEGIN = "begin";
    public static final String KEY_TEXT_SELECTION_PAGE_RANGE_END = "end";

    public static final String KEY_ANNOTATION_LIST = "annotList";
    public static final String KEY_ANNOTATION_ID = "id";
    public static final String KEY_ANNOTATION_PAGE = "pageNumber";
    public static final String KEY_ANNOTATION_RECT = "rect";
    public static final String KEY_ANNOTATION_PAGE_RECT = "pageRect";
    public static final String KEY_ANNOTATION_SCREEN_RECT = "screenRect";
    public static final String KEY_ANNOTATION_FLAG = "flag";
    public static final String KEY_ANNOTATION_FLAG_VALUE = "flagValue";
    public static final String KEY_ANNOTATION_SUBJECT = "subject";
    public static final String KEY_ANNOTATION_TITLE = "title";
    public static final String KEY_ANNOTATION_CONTENTS = "contents";
    public static final String KEY_ANNOTATION_CONTENT_RECT = "contentRect";
    public static final String KEY_ANNOTATION_TYPE = "type";
    public static final String KEY_ANNOTATION_CUSTOM_DATA = "customData";
    public static final String KEY_ANNOTATION_STROKE_COLOR = "strokeColor";

    public static final String KEY_ACTION = "action";
    public static final String KEY_ACTION_ADD = "add";
    public static final String KEY_ACTION_MODIFY = "modify";
    public static final String KEY_ACTION_DELETE = "delete";
    public static final String KEY_ANNOTATIONS = "annotations";
    public static final String KEY_XFDF_COMMAND = "xfdfCommand";
    public static final String KEY_FIELDS = "fields";
    public static final String KEY_FIELD_NAME = "fieldName";
    public static final String KEY_FIELD_VALUE = "fieldValue";
    public static final String KEY_FIELD_TYPE = "fieldType";
    public static final String KEY_FIELD_HAS_APPEARANCE = "fieldHasAppearance";
    public static final String KEY_ERROR = "error";

    public static final String KEY_ANNOTATION_MENU = "annotationMenu";
    public static final String KEY_LONG_PRESS_MENU = "longPressMenu";
    public static final String KEY_LONG_PRESS_TEXT = "longPressText";

    public static final String KEY_DATA = "data";

    public static final String KEY_X1 = "x1";
    public static final String KEY_X2 = "x2";
    public static final String KEY_Y1 = "y1";
    public static final String KEY_Y2 = "y2";
    public static final String KEY_WIDTH = "width";
    public static final String KEY_HEIGHT = "height";

    public static final String KEY_HORIZONTAL = "horizontal";
    public static final String KEY_VERTICAL = "vertical";

    public static final String KEY_ANNOTATION_FLAG_HIDDEN = "hidden";
    public static final String KEY_ANNOTATION_FLAG_INVISIBLE = "invisible";
    public static final String KEY_ANNOTATION_FLAG_LOCKED = "locked";
    public static final String KEY_ANNOTATION_FLAG_LOCKED_CONTENTS = "lockedContents";
    public static final String KEY_ANNOTATION_FLAG_NO_ROTATE = "noRotate";
    public static final String KEY_ANNOTATION_FLAG_NO_VIEW = "noView";
    public static final String KEY_ANNOTATION_FLAG_NO_ZOOM = "noZoom";
    public static final String KEY_ANNOTATION_FLAG_PRINT = "print";
    public static final String KEY_ANNOTATION_FLAG_READ_ONLY = "readOnly";
    public static final String KEY_ANNOTATION_FLAG_TOGGLE_NO_VIEW = "toggleNoView";

    public static final String KEY_BOOKMARK_JSON = "bookmarkJson";

    public static final String KEY_PAGE_NUMBERS = "pageNumbers";

    public static final String KEY_PREVIOUS_TOOL = "previousTool";
    public static final String KEY_TOOL = "tool";

    public static final String KEY_CURRENT_TAB = "currentTab";

    // Hygen Generated Keys
    public static final String KEY_TOOLBAR = "toolbar";

    // Color RGBA
    public static final String COLOR_RED = "red";
    public static final String COLOR_GREEN = "green";
    public static final String COLOR_BLUE = "blue";
    public static final String COLOR_ALPHA = "alpha";

    // Config keys
    public static final String KEY_CONFIG_LINK_PRESS = "linkPress";
    public static final String KEY_CONFIG_STICKY_NOTE_SHOW_POP_UP = "stickyNoteShowPopUp";

    public static final String KEY_COORDINATE_POINT_X = "x";
    public static final String KEY_COORDINATE_POINT_Y = "y";
    public static final String KEY_COORDINATE_POINT_PAGE_NUMBER = "pageNumber";

    // Zoom
    public static final String KEY_zoomLimitAbsolute = "absolute";
    public static final String KEY_zoomLimitRelative = "relative";
    public static final String KEY_zoomLimitNone = "none";

    // OverprintMode
    public static final String KEY_OVERPRINT_MODE_ON = "on";
    public static final String KEY_OVERPRINT_MODE_OFF = "off";
    public static final String KEY_OVERPRINT_MODE_PDFX = "pdfx";

    // Color Post Process Modes
    public static final String KEY_COLOR_POST_PROCESS_MODE_NONE = "none";
    public static final String KEY_COLOR_POST_PROCESS_MODE_INVERT = "invert";
    public static final String KEY_COLOR_POST_PROCESS_MODE_GRADIENT_MAP = "gradientMap";
    public static final String KEY_COLOR_POST_PROCESS_MODE_NIGHT_MODE = "nightMode";

    // ReflowOrientation
    public static final String KEY_REFLOW_ORIENTATION_HORIZONTAL = "horizontal";
    public static final String KEY_REFLOW_ORIENTATION_VERTICAL = "vertical";

    // Export format
    public static final String KEY_EXPORT_FORMAT_BMP = "BMP";
    public static final String KEY_EXPORT_FORMAT_JPEG = "JPEG";
    public static final String KEY_EXPORT_FORMAT_PNG = "PNG";

    // AnnotationManagerEditMode
    public static final String KEY_ANNOTATION_MANAGER_EDIT_MODE_OWN = "own";
    public static final String KEY_ANNOTATION_MANAGER_EDIT_MODE_ALL = "all";

    // AnnotationManagerUndoMode
    public static final String KEY_ANNOTATION_MANAGER_UNDO_MODE_OWN = "own";
    public static final String KEY_ANNOTATION_MANAGER_UNDO_MODE_ALL = "all";

    // Application Theme
    public static final String THEME_DARK = "theme_dark";
    public static final String THEME_LIGHT = "theme_light";
}
