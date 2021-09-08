/**
 * @constant
 * @class (Assigned to class for documentation purposes.)
 * @hideconstructor
 * @name Config
 * @classdesc Defines configuration constants for the viewer. 
 * See [`Config.ts`](https://github.com/PDFTron/pdftron-react-native/blob/master/src/Config/Config.js) 
 * for the full list of constants.
 * 
 * Due to the length of the source file, we have included links to the exact lines of the source code where these APIs have been implemented.
 */
export const Config = {

  /** 
   * @member
   * @description Buttons define the various kinds of buttons for the viewer
   */
  Buttons: {
    editToolButton: 'editToolButton',
    viewControlsButton: 'viewControlsButton',
    freeHandToolButton: 'freeHandToolButton',
    highlightToolButton: 'highlightToolButton',
    underlineToolButton: 'underlineToolButton',
    squigglyToolButton: 'squigglyToolButton',
    strikeoutToolButton: 'strikeoutToolButton',
    rectangleToolButton: 'rectangleToolButton',
    ellipseToolButton: 'ellipseToolButton',
    lineToolButton: 'lineToolButton',
    arrowToolButton: 'arrowToolButton',
    polylineToolButton: 'polylineToolButton',
    polygonToolButton: 'polygonToolButton',
    cloudToolButton: 'cloudToolButton',
    signatureToolButton: 'signatureToolButton',
    freeTextToolButton: 'freeTextToolButton',
    stickyToolButton: 'stickyToolButton',
    calloutToolButton: 'calloutToolButton',
    stampToolButton: 'stampToolButton',
    toolsButton: 'toolsButton',
    searchButton: 'searchButton',
    shareButton: 'shareButton',
    editPagesButton: 'editPagesButton',
    viewLayersButton: 'viewLayersButton',
    printButton: 'printButton',
    closeButton: 'closeButton',
    saveCopyButton: 'saveCopyButton',
    saveIdenticalCopyButton: 'saveIdenticalCopyButton',
    saveFlattenedCopyButton: 'saveFlattenedCopyButton',
    formToolsButton: 'formToolsButton',
    fillSignToolsButton: 'fillSignToolsButton',
    moreItemsButton: 'moreItemsButton',
    digitalSignatureButton: 'digitalSignatureButton',
    thumbnailsButton: 'thumbnailsButton',
    listsButton: 'listsButton',
    thumbnailSlider: 'thumbnailSlider',
    outlineListButton: 'outlineListButton',
    annotationListButton: 'annotationListButton',
    userBookmarkListButton: 'userBookmarkListButton',
    reflowButton: 'reflowButton',
    editMenuButton: 'editMenuButton',
    cropPageButton: 'cropPageButton',
    undo: 'undo',
    redo: 'redo',
    addPageButton: 'addPageButton',

    // Android only
    saveReducedCopyButton: 'saveReducedCopyButton',
    saveCroppedCopyButton: 'saveCroppedCopyButton',
    savePasswordCopyButton: 'savePasswordCopyButton',
  },

  /** 
   * @member
   * @description Tools define the various kinds of tools for the viewer
   */
  Tools: {
    annotationEdit: 'AnnotationEdit',
    textSelect: 'TextSelect',
    pan: 'Pan',
    annotationEraserTool: 'AnnotationEraserTool',
    annotationCreateSticky: 'AnnotationCreateSticky',
    annotationCreateFreeHand: 'AnnotationCreateFreeHand',
    annotationCreateTextHighlight: 'AnnotationCreateTextHighlight',
    annotationCreateTextUnderline: 'AnnotationCreateTextUnderline',
    annotationCreateTextSquiggly: 'AnnotationCreateTextSquiggly',
    annotationCreateTextStrikeout: 'AnnotationCreateTextStrikeout',
    annotationCreateFreeText: 'AnnotationCreateFreeText',
    annotationCreateCallout: 'AnnotationCreateCallout',
    annotationCreateSignature: 'AnnotationCreateSignature',
    annotationCreateLine: 'AnnotationCreateLine',
    annotationCreateArrow: 'AnnotationCreateArrow',
    annotationCreatePolyline: 'AnnotationCreatePolyline',
    annotationCreateStamp: 'AnnotationCreateStamp',
    annotationCreateRubberStamp: 'AnnotationCreateRubberStamp',
    annotationCreateRectangle: 'AnnotationCreateRectangle',
    annotationCreateEllipse: 'AnnotationCreateEllipse',
    annotationCreatePolygon: 'AnnotationCreatePolygon',
    annotationCreatePolygonCloud: 'AnnotationCreatePolygonCloud',
    annotationCreateDistanceMeasurement: 'AnnotationCreateDistanceMeasurement',
    annotationCreatePerimeterMeasurement: 'AnnotationCreatePerimeterMeasurement',
    annotationCreateAreaMeasurement: 'AnnotationCreateAreaMeasurement',
    annotationCreateFileAttachment: 'AnnotationCreateFileAttachment',
    annotationCreateSound: 'AnnotationCreateSound',
    annotationCreateRedaction: 'AnnotationCreateRedaction',
    annotationCreateLink: 'AnnotationCreateLink',
    annotationCreateRedactionText: 'AnnotationCreateRedactionText',
    annotationCreateLinkText: 'AnnotationCreateLinkText',
    annotationCreateFreeHighlighter: 'AnnotationCreateFreeHighlighter',
    formCreateTextField: 'FormCreateTextField',
    formCreateCheckboxField: 'FormCreateCheckboxField',
    formCreateSignatureField: 'FormCreateSignatureField',
    formCreateRadioField: 'FormCreateRadioField',
    formCreateComboBoxField: 'FormCreateComboBoxField',
    formCreateListBoxField: 'FormCreateListBoxField',

    // iOS only.
    pencilKitDrawing: 'PencilKitDrawing',
  },

  /** 
   * @member
   * @description FitMode define how a page should fit relative to the viewer, alternatively, the default zoom level
   */
  FitMode: {
    FitPage: 'FitPage',
    FitWidth: 'FitWidth',
    FitHeight: 'FitHeight',
    Zoom: 'Zoom',
  },

  /** 
   * @member
   * @description LayoutMode defines the layout mode of the viewer
   */
  LayoutMode: {
    Single: 'Single',
    Continuous: 'Continuous',
    Facing: 'Facing',
    FacingContinuous: 'FacingContinuous',
    FacingCover: 'FacingCover',
    FacingCoverContinuous: 'FacingCoverContinuous',
  },

  /** 
   * @member
   * @description FieldFlags define the property flags for a form field
   */
  FieldFlags: {
    ReadOnly: 0,
    Required: 1,
  },

  /** 
   * @member
   * @description AnnotationMenu defines the menu items when an annotation is selected
   */
  AnnotationMenu: {
    style: 'style',
    note: 'note',
    copy: 'copy',
    duplicate: 'duplicate',
    delete: 'delete',
    flatten: 'flatten',
    editText: 'editText',
    editInk: 'editInk',
    search: 'search',
    share: 'share',
    markupType: 'markupType',
    read: 'read',
    screenCapture: 'screenCapture',
    playSound: 'playSound',
    openAttachment: 'openAttachment',
    calibrate: 'calibrate',
  },

  /** 
   * @member
   * @description EraserType defines the type of earse that will be used when eraser is selected
   */
  EraserType: {
    annotationEraser: 'annotationEraser',
    hybrideEraser: 'hybrideEraser',
    inkEraser: 'inkEraser'
  },

  /** 
   * @member
   * @description LongPressMenu defines the menu items when a long press on empty space or text occurs
   */
  LongPressMenu: {
    copy: 'copy',
    paste: 'paste',
    search: 'search',
    share: 'share',
    read: 'read',
  },
  
  /** 
   * @member
   * @description Actions define potentially overridable action to the viewer
   */
  Actions: {
    linkPress: 'linkPress',
    stickyNoteShowPopUp: 'stickyNoteShowPopUp',
  },

  /** 
   * @member
   * @description AnnotationFlags define the flags for any annotation in the document
   */
  AnnotationFlags: {
    hidden: "hidden",
    invisible: "invisible",
    locked: "locked",
    lockedContents: "lockedContents",
    noRotate: "noRotate",
    noView: "noView",
    noZoom: "noZoom",
    print: "print",
    readOnly: "readOnly",
    toggleNoView: "toggleNoView"
  },

  /** 
   * @member
   * @description DefaultToolbars define a set of pre-designed toolbars for easier customization
   */
  DefaultToolbars: {
    View: "PDFTron_View",
    Annotate: "PDFTron_Annotate",
    Draw: "PDFTron_Draw",
    Insert: "PDFTron_Insert",
    FillAndSign: "PDFTron_Fill_and_Sign",
    PrepareForm: "PDFTron_Prepare_Form",
    Measure: "PDFTron_Measure",
    Pens: "PDFTron_Pens",
    Redaction: "PDFTron_Redact",
    Favorite: "PDFTron_Favorite"
  },

  /** 
   * @member
   * @description ToolbarIcons define default toolbar icons for use for potential custom toolbars
   */
  ToolbarIcons: {
    View: "PDFTron_View",
    Annotate: "PDFTron_Annotate",
    Draw: "PDFTron_Draw",
    Insert: "PDFTron_Insert",
    FillAndSign: "PDFTron_Fill_and_Sign",
    PrepareForm: "PDFTron_Prepare_Form",
    Measure: "PDFTron_Measure",
    Pens: "PDFTron_Pens",
    Redaction: "PDFTron_Redact",
    Favorite: "PDFTron_Favorite"
  },

  /** 
   * @member
   * @description CustomToolbarKey defines the necessary keys for a custom toolbar
   */
  CustomToolbarKey: {
    Id: "id",
    Name: "name",
    Icon: "icon",
    Items: "items"
  },

  /** 
   * @member
   * @description ThumbnailFilterMode defines filter modes in the thumbnails browser
   */
  ThumbnailFilterMode: {
    Annotated: "annotated",
    Bookmarked: "bookmarked",
  },

  /** 
   * @member
   * @description Conversion defines conversion sources and destinations
   */
  Conversion: {
    Screen: "screen",
    Canvas: "canvas",
    Page: "page",
  },
  
  /** 
   * @member
   * @description ViewModePickerItem defines view mode items in the view mode dialog
   */
  ViewModePickerItem: {
    Crop: "viewModeCrop",
    Rotation: "viewModeRotation",
    ColorMode: "viewModeColorMode",
  },

  /** 
   * @member
   * @description ZoomLimitMode defines the limit mode for zoom in the current document viewer
   */
  ZoomLimitMode: {
    None: "none",
    Absolute: "absolute",
    Relative: "relative",
  },

  /** 
   * @member
   * @description OverprintMode defines when overprint would be applied in the viewer
   */
  OverprintMode: {
    On: "on",
    Off: "off",
    OnlyPDFX: "pdfx", // only apply to PDF/X files
  },

  /** 
   * @member
   * @description ColorPostProcessMode defines color modifications after rendering in the viewer
   */
  ColorPostProcessMode: {
    None: "none",
    Invert: "invert",
    GradientMap: "gradientMap",
    NightMode: "nightMode"
  },

  /** 
   * @member
   * @description ReflowOrientation defines the scrolling direction when in reflow viewing mode
   */
  ReflowOrientation: {
    Horizontal: 'horizontal',
    Vertical: 'vertical',
  },

  /** 
   * @member
   * @description Export to format
   */
  ExportFormat: {
    BMP: "BMP",
    JPEG: "JPEG",
    PNG: "PNG",
  },
} as const;

/**
 * A generic used to create the custom types defined in the module below.
 * 
 * The variable `T` represents the type information being passed into the generic.
 * This generic accepts type information about the `Config` object above. We pass this
 * information in using `typeof Config.*`, * is any object nested in the `Config` object.
 * 
 * `keyof T` creates a union of the object's keys e.g 
 * `keyof typeof Config.ReflowOrientation == 'Horizonal' | 'Vertical'`
 * 
 * `T[]` is the indexed access type and takes the union produced by a `keyof T` and outputs
 * a union of value types corresponding to those keys, e.g.
 * `ValueOf<typeof Config.ReflowOrientation> == "horizontal" | "vertical"`
 * 
 * The above union is made up of string literal types because the `as const` operator sets the 
 * properties of the `Config` object to have literal types.
 * 
 * You can learn more about these special operators here:
 * - {@link https://www.typescriptlang.org/docs/handbook/2/typeof-types.html Typeof}
 * - {@link https://www.typescriptlang.org/docs/handbook/2/keyof-types.html Keyof} 
 * - {@link https://www.typescriptlang.org/docs/handbook/2/indexed-access-types.html Index Acess Types}
 * - {@link https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-4.html#const-assertions Const Assertions}
 */
type ValueOf<T> = T[keyof T];

/**
 * A module containing custom types formed from the constants in the Config object.
 * 
 * These types are used for props such as `disabledElements` and methods such as `exportAsImage`
 */
export module Config {
  export type Buttons = ValueOf<typeof Config.Buttons>;
  export type Tools = ValueOf<typeof Config.Tools>;
  export type FitMode = ValueOf<typeof Config.FitMode>;
  export type LayoutMode = ValueOf<typeof Config.LayoutMode>;
  export type FieldFlags = ValueOf<typeof Config.FieldFlags>;
  export type AnnotationMenu = ValueOf<typeof Config.AnnotationMenu>;
  export type EraserType = ValueOf<typeof Config.EraserType>;
  export type LongPressMenu = ValueOf<typeof Config.LongPressMenu>;
  export type Actions = ValueOf<typeof Config.Actions>;
  export type AnnotationFlags = ValueOf<typeof Config.AnnotationFlags>;
  export type DefaultToolbars = ValueOf<typeof Config.DefaultToolbars>;
  export type ToolbarIcons = ValueOf<typeof Config.ToolbarIcons>;
  export type ThumbnailFilterMode = ValueOf<typeof Config.ThumbnailFilterMode>;
  export type Conversion = ValueOf<typeof Config.Conversion>;
  export type ViewModePickerItem = ValueOf<typeof Config.ViewModePickerItem>;
  export type ZoomLimitMode = ValueOf<typeof Config.ZoomLimitMode>;
  export type OverprintMode = ValueOf<typeof Config.OverprintMode>;
  export type ColorPostProcessMode = ValueOf<typeof Config.ColorPostProcessMode>;
  export type ReflowOrientation = ValueOf<typeof Config.ReflowOrientation>;
  export type ExportFormat = ValueOf<typeof Config.ExportFormat>;
  export type CustomToolbarKey = {
    id : string;
    name: string;
    icon: ToolbarIcons;
    items: (Tools | Buttons)[];
  }
}