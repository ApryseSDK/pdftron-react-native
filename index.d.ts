import { PDFViewCtrl } from './types/PDFViewCtrl/PDFViewCtrl';
import { DocumentView } from './types/DocumentView/DocumentView';
import { Config, ConfigOptions } from './types/Config/Config';
import * as AnnotOptions from './types/AnnotOptions/AnnotOptions';
export interface Pdftron {
    initialize(licenseKey: string): void;
    enableJavaScript(enabled: boolean): void;
    getVersion(): Promise<string>;
    getPlatformVersion(): Promise<string>;
    getSystemFontList(): Promise<string>;
    clearRubberStampCache(): Promise<void>;
    encryptDocument(filePath: string, password: string, currentPassword: string): Promise<void>;
    pdfFromOfficeTemplate(docxPath: string, json: object): Promise<string>;
}
declare const RNPdftron: Pdftron;
export { RNPdftron, PDFViewCtrl, DocumentView, Config, AnnotOptions, ConfigOptions };
