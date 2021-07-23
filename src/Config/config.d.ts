export interface Buttons {
    editToolButton: 'editToolButton';
    viewControlsButton: 'viewControlsButton';
    freeHandToolButton: 'freeHandToolButton';
    highlightToolButton: 'highlightToolButton';
    underlineToolButton: 'underlineToolButton';
    squigglyToolButton: 'squigglyToolButton';
    strikeoutToolButton: 'strikeoutToolButton';
    rectangleToolButton: 'rectangleToolButton';
    ellipseToolButton: 'ellipseToolButton';
    lineToolButton: 'lineToolButton';
    arrowToolButton: 'arrowToolButton';
    polylineToolButton: 'polylineToolButton';
    polygonToolButton: 'polygonToolButton';
    cloudToolButton: 'cloudToolButton';
    signatureToolButton: 'signatureToolButton';
    freeTextToolButton: 'freeTextToolButton';
    stickyToolButton: 'stickyToolButton';
    calloutToolButton: 'calloutToolButton';
    stampToolButton: 'stampToolButton';
    toolsButton: 'toolsButton';
    searchButton: 'searchButton';
    shareButton: 'shareButton';
    editPagesButton: 'editPagesButton';
    viewLayersButton: 'viewLayersButton';
    printButton: 'printButton';
    closeButton: 'closeButton';
    saveCopyButton: 'saveCopyButton';
    formToolsButton: 'formToolsButton';
    fillSignToolsButton: 'fillSignToolsButton';
    moreItemsButton: 'moreItemsButton';
    digitalSignatureButton: 'digitalSignatureButton';
    thumbnailsButton: 'thumbnailsButton';
    listsButton: 'listsButton';
    thumbnailSlider: 'thumbnailSlider';
    outlineListButton: 'outlineListButton';
    annotationListButton: 'annotationListButton';
    userBookmarkListButton: 'userBookmarkListButton';
    reflowButton: 'reflowButton';
    editMenuButton: 'editMenuButton';
    cropPageButton: 'cropPageButton';
    undo: 'undo';
    redo: 'redo';
    addPageButton: 'addPageButton';
}

export interface Tools {
    annotationEdit: 'AnnotationEdit';
    textSelect: 'TextSelect';
    pan: 'Pan';
    annotationEraserTool: 'AnnotationEraserTool';
    annotationCreateSticky: 'AnnotationCreateSticky';
    annotationCreateFreeHand: 'AnnotationCreateFreeHand';
    annotationCreateTextHighlight: 'AnnotationCreateTextHighlight';
    annotationCreateTextUnderline: 'AnnotationCreateTextUnderline';
    annotationCreateTextSquiggly: 'AnnotationCreateTextSquiggly';
    annotationCreateTextStrikeout: 'AnnotationCreateTextStrikeout';
    annotationCreateFreeText: 'AnnotationCreateFreeText';
    annotationCreateCallout: 'AnnotationCreateCallout';
    annotationCreateSignature: 'AnnotationCreateSignature';
    annotationCreateLine: 'AnnotationCreateLine';
    annotationCreateArrow: 'AnnotationCreateArrow';
    annotationCreatePolyline: 'AnnotationCreatePolyline';
    annotationCreateStamp: 'AnnotationCreateStamp';
    annotationCreateRubberStamp: 'AnnotationCreateRubberStamp';
    annotationCreateRectangle: 'AnnotationCreateRectangle';
    annotationCreateEllipse: 'AnnotationCreateEllipse';
    annotationCreatePolygon: 'AnnotationCreatePolygon';
    annotationCreatePolygonCloud: 'AnnotationCreatePolygonCloud';
    annotationCreateDistanceMeasurement: 'AnnotationCreateDistanceMeasurement';
    annotationCreatePerimeterMeasurement: 'AnnotationCreatePerimeterMeasurement';
    annotationCreateAreaMeasurement: 'AnnotationCreateAreaMeasurement';
    annotationCreateFileAttachment: 'AnnotationCreateFileAttachment';
    annotationCreateSound: 'AnnotationCreateSound';
    annotationCreateRedaction: 'AnnotationCreateRedaction';
    annotationCreateLink: 'AnnotationCreateLink';
    annotationCreateRedactionText: 'AnnotationCreateRedactionText';
    annotationCreateLinkText: 'AnnotationCreateLinkText';
    annotationCreateFreeHighlighter: 'AnnotationCreateFreeHighlighter';
    formCreateTextField: 'FormCreateTextField';
    formCreateCheckboxField: 'FormCreateCheckboxField';
    formCreateSignatureField: 'FormCreateSignatureField';
    formCreateRadioField: 'FormCreateRadioField';
    formCreateComboBoxField: 'FormCreateComboBoxField';
    formCreateListBoxField: 'FormCreateListBoxField';
    pencilKitDrawing: 'PencilKitDrawing';
}

export interface FitMode {
    FitPage: 'FitPage';
    FitWidth: 'FitWidth';
    FitHeight: 'FitHeight';
    Zoom: 'Zoom';
}

export interface LayoutMode {
    Single: 'Single';
    Continuous: 'Continuous';
    Facing: 'Facing';
    FacingContinuous: 'FacingContinuous';
    FacingCover: 'FacingCover';
    FacingCoverContinuous: 'FacingCoverContinuous';
}

export interface FieldFlags {
    ReadOnly: 0;
    Required: 1;
}

export interface AnnotationMenu {
    style: 'style';
    note: 'note';
    copy: 'copy';
    delete: 'delete';
    flatten: 'flatten';
    editText: 'editText';
    editInk: 'editInk';
    search: 'search';
    share: 'share';
    markupType: 'markupType';
    read: 'read';
    screenCapture: 'screenCapture';
    playSound: 'playSound';
    openAttachment: 'openAttachment';
    calibrate: 'calibrate';
}

export interface EraserType{
    annotationEraser: 'annotationEraser';
    hybrideEraser: 'hybrideEraser';
    inkEraser: 'inkEraser';
}

export interface LongPressMenu {
    copy: 'copy';
    paste: 'paste';
    search: 'search';
    share: 'share';
    read: 'read';
}

export interface Actions {
    linkPress: 'linkPress';
    stickyNoteShowPopUp: 'stickyNoteShowPopUp';
}

export interface AnnotationFlags {
    hidden: "hidden";
    invisible: "invisible";
    locked: "locked";
    lockedContents: "lockedContents";
    noRotate: "noRotate";
    noView: "noView";
    noZoom: "noZoom";
    print: "print";
    readOnly: "readOnly";
    toggleNoView: "toggleNoView";
}

export interface DefaultToolbars {
    View: "PDFTron_View";
    Annotate: "PDFTron_Annotate";
    Draw: "PDFTron_Draw";
    Insert: "PDFTron_Insert";
    FillAndSign: "PDFTron_Fill_and_Sign";
    PrepareForm: "PDFTron_Prepare_Form";
    Measure: "PDFTron_Measure";
    Pens: "PDFTron_Pens";
    Redaction: "PDFTron_Redact";
    Favorite: "PDFTron_Favorite";
  }

export interface ToolbarIcons {
    View: "PDFTron_View";
    Annotate: "PDFTron_Annotate";
    Draw: "PDFTron_Draw";
    Insert: "PDFTron_Insert";
    FillAndSign: "PDFTron_Fill_and_Sign";
    PrepareForm: "PDFTron_Prepare_Form";
    Measure: "PDFTron_Measure";
    Pens: "PDFTron_Pens";
    Redaction: "PDFTron_Redact";
    Favorite: "PDFTron_Favorite";
}

export interface CustomToolbarKey {
    Id: "id";
    Name: "name";
    Icon: "icon";
    Items: "items";
}

export interface ThumbnailFilterMode {
    Annotated: "annotated";
    Bookmarked: "bookmarked";
}

export interface Conversion {
    Screen: "screen";
    Canvas: "canvas";
    Page: "page";
}

export interface ViewModePickerItem {
    Crop: "viewModeCrop";
    Rotation: "viewModeRotation";
    ColorMode: "viewModeColorMode";
}

export interface ZoomLimitMode {
    None: "none";
    Absolute: "absolute";
    Relative: "relative";
}

export interface OverprintMode {
    On: "on";
    Off: "off";
    OnlyPDFX: "pdfx";
}

export interface ColorPostProcessMode {
    None: "none";
    Invert: "invert";
    GradientMap: "gradientMap";
    NightMode: "nightMode";
}

export interface ReflowOrientation {
    Horizontal: 'horizontal';
    Vertical: 'vertical';
  }

export interface ExportFormat {
    BMP: "BMP";
    JPEG: "JPEG";
    PNG: "PNG";
}

export interface Config {
    Buttons: Buttons;
    Tools: Tools;
    FitMode: FitMode;
    LayoutMode: LayoutMode;
    FieldFlags: FieldFlags;
    AnnotationMenu: AnnotationMenu;
    EraserType: EraserType;
    LongPressMenu: LongPressMenu;
    Actions: Actions;
    AnnotationFlags: AnnotationFlags;
    DefaultToolbars: DefaultToolbars;
    ToolbarIcons: ToolbarIcons;
    CustomToolbarKey: CustomToolbarKey;
    ThumbnailFilterMode: ThumbnailFilterMode;
    Conversion: Conversion;
    ViewModePickerItem: ViewModePickerItem;
    ZoomLimitMode: ZoomLimitMode;
    OverprintMode: OverprintMode;
    ColorPostProcessMode: ColorPostProcessMode;
    ReflowOrientation: ReflowOrientation;
    ExportFormat: ExportFormat;
}

export const Config : Config;