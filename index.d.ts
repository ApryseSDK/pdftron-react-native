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

export {Config} from "./src/types/Config";

export * as ConfigOptions from "./src/types/ConfigOptions";

export {DocumentView} from "./src/types/DocumentView";

export * as AnnotOptions from "./src/types/AnnotOptions";
        
export {PDFViewCtrl} from "./src/types/PDFViewCtrl";