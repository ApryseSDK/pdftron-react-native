/**
 * @constant
 * @class (Assigned to class for documentation purposes.)
 * @hideconstructor
 * @name Config
 * @classdesc Defines configuration constants for the viewer.
 * See [`Config.ts`](https://github.com/PDFTron/pdftron-react-native/blob/master/src/Config/Config.ts)
 * for the full list of constants.
 *
 * Due to the length of the source file, we have included links to the exact lines
 * of the source code where these APIs have been implemented.
 */
export const Config = {
    /**
     * @member
     * @desc Buttons define the various kinds of buttons for the viewer
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
        savePasswordCopyButton: 'savePasswordCopyButton'
    },
    /**
     * @member
     * @desc Tools define the various kinds of tools for the viewer
     */
    Tools: {
        annotationEdit: 'AnnotationEdit',
        textSelect: 'TextSelect',
        multiSelect: 'MultiSelect',
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
        annotationCreateSmartPen: 'AnnotationCreateSmartPen',
        formCreateTextField: 'FormCreateTextField',
        formCreateCheckboxField: 'FormCreateCheckboxField',
        formCreateSignatureField: 'FormCreateSignatureField',
        formCreateRadioField: 'FormCreateRadioField',
        formCreateComboBoxField: 'FormCreateComboBoxField',
        formCreateListBoxField: 'FormCreateListBoxField',
        // iOS only.
        pencilKitDrawing: 'PencilKitDrawing'
    },
    /**
     * @member
     * @desc FitMode define how a page should fit relative to the viewer,
     * alternatively, the default zoom level
     */
    FitMode: {
        FitPage: 'FitPage',
        FitWidth: 'FitWidth',
        FitHeight: 'FitHeight',
        Zoom: 'Zoom'
    },
    /**
     * @member
     * @desc LayoutMode defines the layout mode of the viewer
     */
    LayoutMode: {
        Single: 'Single',
        Continuous: 'Continuous',
        Facing: 'Facing',
        FacingContinuous: 'FacingContinuous',
        FacingCover: 'FacingCover',
        FacingCoverContinuous: 'FacingCoverContinuous'
    },
    /**
     * @member
     * @desc FieldFlags define the property flags for a form field
     */
    FieldFlags: {
        ReadOnly: 0,
        Required: 1
    },
    /**
     * @member
     * @desc AnnotationMenu defines the menu items when an annotation is selected
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
        calibrate: 'calibrate'
    },
    /**
     * @member
     * @desc EraserType defines the type of eraser that will be used when eraser is selected
     */
    EraserType: {
        annotationEraser: 'annotationEraser',
        hybrideEraser: 'hybrideEraser',
        inkEraser: 'inkEraser'
    },
    /**
     * @member
     * @desc LongPressMenu defines the menu items when a long press on empty space or text occurs
     */
    LongPressMenu: {
        copy: 'copy',
        paste: 'paste',
        search: 'search',
        share: 'share',
        read: 'read'
    },
    /**
     * @member
     * @desc Actions define potentially overridable action to the viewer
     */
    Actions: {
        linkPress: 'linkPress',
        stickyNoteShowPopUp: 'stickyNoteShowPopUp'
    },
    /**
     * @member
     * @desc AnnotationFlags define the flags for any annotation in the document
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
     * @desc DefaultToolbars define a set of pre-designed toolbars for easier customization
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
     * @desc ToolbarIcons define default toolbar icons for use for potential custom toolbars
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
     * @desc CustomToolbarKey defines the necessary keys for a custom toolbar
     */
    CustomToolbarKey: {
        Id: "id",
        Name: "name",
        Icon: "icon",
        Items: "items"
    },
    /**
     * @member
     * @desc ThumbnailFilterMode defines filter modes in the thumbnails browser
     */
    ThumbnailFilterMode: {
        Annotated: "annotated",
        Bookmarked: "bookmarked"
    },
    /**
     * @member
     * @desc Conversion defines conversion sources and destinations
     */
    Conversion: {
        Screen: "screen",
        Canvas: "canvas",
        Page: "page"
    },
    /**
     * @member
     * @desc ViewModePickerItem defines view mode items in the view mode dialog
     */
    ViewModePickerItem: {
        Crop: "viewModeCrop",
        Rotation: "viewModeRotation",
        ColorMode: "viewModeColorMode"
    },
    /**
     * @member
     * @desc ZoomLimitMode defines the limit mode for zoom in the current document viewer
     */
    ZoomLimitMode: {
        None: "none",
        Absolute: "absolute",
        Relative: "relative"
    },
    /**
     * @member
     * @desc OverprintMode defines when overprint would be applied in the viewer
     */
    OverprintMode: {
        On: "on",
        Off: "off",
        OnlyPDFX: "pdfx" // only apply to PDF/X files
    },
    /**
     * @member
     * @desc ColorPostProcessMode defines color modifications after rendering in the viewer
     */
    ColorPostProcessMode: {
        None: "none",
        Invert: "invert",
        GradientMap: "gradientMap",
        NightMode: "nightMode"
    },
    /**
     * @member
     * @desc ReflowOrientation defines the scrolling direction when in reflow viewing mode
     */
    ReflowOrientation: {
        Horizontal: 'horizontal',
        Vertical: 'vertical'
    },
    /**
     * @member
     * @desc Export to format
     */
    ExportFormat: {
        BMP: "BMP",
        JPEG: "JPEG",
        PNG: "PNG"
    },
    /**
     * @member
     * @desc AnnotationManagerEditMode determines whose changes can be edited.
     */
    AnnotationManagerEditMode: {
        Own: "own",
        All: "all"
    },
    /**
     * @member
     * @desc AnnotationManagerUndoMode determines whose changes can be undone.
     */
    AnnotationManagerUndoMode: {
        Own: "own",
        All: "all"
    }
};
