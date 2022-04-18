import { NativeModules } from 'react-native';
import { PDFViewCtrl } from './src/PDFViewCtrl/PDFViewCtrl';
import { DocumentView } from './src/DocumentView/DocumentView';
import { Config } from './src/Config/Config';
import * as AnnotOptions from './src/AnnotOptions/AnnotOptions';

interface RNPdftron {
    initialize(licenseKey: string) : void;
    enableJavaScript(enabled: boolean) : void;
    getVersion() : Promise<string>;
    getPlatformVersion() : Promise<string>;
    getSystemFontList() : Promise<string>;
    clearRubberStampCache() : Promise<void>;
    encryptDocument(filePath: string, password: string, currentPassword: string) : Promise<void>;
    pdfFromOffice(docxPath: string, options?: {applyPageBreaksToSheet?: boolean, displayChangeTracking?: boolean, excelDefaultCellBorderWidth?: number, 
            excelMaxAllowedCellCount?: number, locale?: string}) : Promise<string>;
    pdfFromOfficeTemplate(docxPath: string, json: object) : Promise<string>;
    exportAsImage(pageNumber: number, dpi: number, exportFormat: Config.ExportFormat, filePath: string) : Promise<string>;
}

const RNPdftron : RNPdftron = NativeModules.RNPdftron;

export {
    RNPdftron,
    PDFViewCtrl,
    DocumentView,
    Config,
    AnnotOptions,
};