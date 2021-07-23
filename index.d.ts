export interface Pdftron {
    initialize(licenseKey: string) : void;
    enableJavaScript(enabled: boolean) : void;
    getVersion() : Promise<string>;
    gtPlatformVersion() : Promise<string>;
    getSystemFontList() : Promise<string>;
    clearRubberStampCache() : Promise<void>;
    encryptDocument(filePath: string, password: string, currentPassword: string) : Promise<void>;
    pdfFromOfficeTemplate(docxPath: string, json: object) : Promise<string>;
};

export const RNPdftron : Pdftron;

export {Config, ConfigOptions} from "./src/Config/config";
export {ButtonsOptions, ToolsOptions, FitModeOptions, LayoutModeOptions, 
        FieldFlagsOptions,  AnnotationMenuOptions, ExportFormatOptions, LongPressMenuOptions,
        ActionsOptions, AnnotationFlagsOptions, DefaultToolbarsOptions, ToolbarIconsOptions,
        CustomToolbarKeyOptions, ThumbnailFilterModeOptions, ConversionOptions, ViewModePickerItemOptions,
        ZoomLimitModeOptions, OverprintModeOptions, ColorPostProcessModeOptions, ReflowOrientationOptions, ExportFormatOptions} from "./src/Config/config.options";
export {DocumentView, DocumentViewProps, Annotation, Field, TextSelectionResult, Quad, Coords} from "./src/DocumentView/document_view";