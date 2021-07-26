export interface Pdftron {
    initialize(licenseKey: string) : void;
    enableJavaScript(enabled: boolean) : void;
    getVersion() : Promise<string>;
    gtPlatformVersion() : Promise<string>;
    getSystemFontList() : Promise<string>;
    clearRubberStampCache() : Promise<void>;
    encryptDocument(filePath: string, password: string, currentPassword: string) : Promise<void>;
    pdfFromOfficeTemplate(docxPath: string, json: object) : Promise<string>;
}

export const RNPdftron : Pdftron;

export {Config} from "./src/Config/config";

export {Buttons, Tools, FitMode, LayoutMode, FieldFlags,  AnnotationMenu, LongPressMenu, Actions, AnnotationFlags, 
        DefaultToolbars, ToolbarIcons, CustomToolbarKey, ThumbnailFilterMode, Conversion, ViewModePickerItem,
        ZoomLimitMode, OverprintMode, ColorPostProcessMode, ReflowOrientation, ExportFormat} from "./src/Config/config.options";

export {DocumentView, DocumentViewProps, Annotation, AnnotationFlag, AnnotationProperties, Rect, CropBox, 
        Field, FieldWithStringValue, Color, RotationDegree, TextSelectionResult, Quad, Point, PointWithPage} from "./src/DocumentView/document_view";
        
export {PDFViewCtrl, PDFViewCtrlProps} from "./src/PDFViewCtrl/pdf_view_ctrl";