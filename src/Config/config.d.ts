export interface Buttons {
    editToolButton: string;
    viewControlsButton: string;
    freeHandToolButton: string;
    highlightToolButton: string;
    underlineToolButton: string;
    squigglyToolButton: string;
    strikeoutToolButton: string;
    rectangleToolButton: string;
    ellipseToolButton: string;
    lineToolButton: string;
    arrowToolButton: string;
    polylineToolButton: string;
    polygonToolButton: string;
    cloudToolButton: string;
    signatureToolButton: string;
    freeTextToolButton: string;
    stickyToolButton: string;
    calloutToolButton: string;
    stampToolButton: string;
    toolsButton: string;
    searchButton: string;
    shareButton: string;
    editPagesButton: string;
    viewLayersButton: string;
    printButton: string;
    closeButton: string;
    saveCopyButton: string;
    formToolsButton: string;
    fillSignToolsButton: string;
    moreItemsButton: string;
    digitalSignatureButton: string;
    thumbnailsButton: string;
    listsButton: string;
    thumbnailSlider: string;
    outlineListButton: string;
    annotationListButton: string;
    userBookmarkListButton: string;
    reflowButton: string;
    editMenuButton: string;
    cropPageButton: string;
    undo: string;
    redo: string;
    addPageButton: string;
}

export interface Tools {
    annotationEdit: string;
    textSelect: string;
    pan: string;
    annotationEraserTool: string;
    annotationCreateSticky: string;
    annotationCreateFreeHand: string;
    annotationCreateTextHighlight: string;
    annotationCreateTextUnderline: string;
    annotationCreateTextSquiggly: string;
    annotationCreateTextStrikeout: string;
    annotationCreateFreeText: string;
    annotationCreateCallout: string;
    annotationCreateSignature: string;
    annotationCreateLine: string;
    annotationCreateArrow: string;
    annotationCreatePolyline: string;
    annotationCreateStamp: string;
    annotationCreateRubberStamp: string;
    annotationCreateRectangle: string;
    annotationCreateEllipse: string;
    annotationCreatePolygon: string;
    annotationCreatePolygonCloud: string;
    annotationCreateDistanceMeasurement: string;
    annotationCreatePerimeterMeasurement: string;
    annotationCreateAreaMeasurement: string;
    annotationCreateFileAttachment: string;
    annotationCreateSound: string;
    annotationCreateRedaction: string;
    annotationCreateLink: string;
    annotationCreateRedactionText: string;
    annotationCreateLinkText: string;
    annotationCreateFreeHighlighter: string;
    formCreateTextField: string;
    formCreateCheckboxField: string;
    formCreateSignatureField: string;
    formCreateRadioField: string;
    formCreateComboBoxField: string;
    formCreateListBoxField: string;
    pencilKitDrawing: string;    
}

export interface FitMode {
    FitPage: string;
    FitWidth: string;
    FitHeight: string;
    Zoom: string;
}

export interface LayoutMode {
    Single: string;
    Continuous: string;
    Facing: string,
    FacingContinuous: string,
    FacingCover: string,
    FacingCoverContinuous: string,
}

export interface FieldFlags {
    ReadOnly: number;
    Required: number;
}

export interface AnnotationMenu {
    style: string;
    note: string;
    copy: string;
    delete: string;
    flatten: string;
    editText: string;
    editInk: string;
    search: string;
    share: string;
    markupType: string;
    read: string;
    screenCapture: string;
    playSound: string;
    openAttachment: string;
    calibrate: string;
}

export interface EraserType{
    annotationEraser: string;
    hybrideEraser: string;
    inkEraser: string;
}

export interface LongPressMenu {
    copy: string;
    paste: string;
    search: string;
    share: string;
    read: string;
}

export interface Actions {
    linkPress: string;
    stickyNoteShowPopUp: string;
}

export interface AnnotationFlags {
    hidden: string;
    invisible: string;
    locked: string;
    lockedContents: string;
    noRotate: string;
    noView: string;
    noZoom: string;
    print: string;
    readOnly: string;
    toggleNoView: string;
}

export interface DefaultToolbars {
    View:string;
    Annotate:string;
    Draw:string;
    Insert:string;
    FillAndSign: string,
    PrepareForm: string,
    Measure:string;
    Pens:string;
    Redaction:string;
    Favorite:string;
  }

export interface ToolbarIcons {
    View:string;
    Annotate:string;
    Draw:string;
    Insert:string;
    FillAndSign: string;
    PrepareForm: string;
    Measure:string;
    Pens:string;
    Redaction:string;
    Favorite:string;
}

export interface CustomToolbarKey {
    Id: string;
    Name: string;
    Icon: string;
    Items: string;
}

export interface ThumbnailFilterMode {
    Annotated: string;
    Bookmarked: string;
}

export interface Conversion {
    Screen: string;
    Canvas: string;
    Page: string;
}

export interface ViewModePickerItem {
    Crop: string;
    Rotation: string;
    ColorMode: string;
}

export interface ZoomLimitMode {
    None: string;
    Absolute: string;
    Relative: string;
}

export interface OverprintMode {
    On: string;
    Off: string;
    OnlyPDFX: string; 
}

export interface ColorPostProcessMode {
    None: string;
    Invert: string;
    GradientMap: string;
    NightMode: string
}

export interface ReflowOrientation {
    Horizontal: string;
    Vertical: string;
  }

export interface ExportFormat {
    BMP: string;
    JPEG: string;
    PNG: string;
}

export interface ConfigOptions {
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
    ViewPickerItemMode: ViewModePickerItem;
    ZoomLimitMode: ZoomLimitMode;
    OverprintMode: OverprintMode;
    ColorPostProcessMode: ColorPostProcessMode;
    ReflowOrientation: ReflowOrientation;
    ExportFormat: ExportFormat;
}

export const Config : ConfigOptions;