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

export * as ConfigOptions from "./src/Config/config.options";

export {DocumentView} from "./src/DocumentView/document_view";
        
export {PDFViewCtrl} from "./src/PDFViewCtrl/pdf_view_ctrl";