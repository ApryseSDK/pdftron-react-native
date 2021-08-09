import { NativeModules } from 'react-native';
import { PDFViewCtrl } from './src/PDFViewCtrl/PDFViewCtrl';
import { DocumentView } from './src/DocumentView/DocumentView';
import { Config, ConfigOptions } from './src/Config/Config';
import * as AnnotOptions from './src/AnnotOptions/AnnotOptions';

export interface Pdftron {
    initialize(licenseKey: string) : void;
    enableJavaScript(enabled: boolean) : void;
    getVersion() : Promise<string>;
    getPlatformVersion() : Promise<string>;
    getSystemFontList() : Promise<string>;
    clearRubberStampCache() : Promise<void>;
    encryptDocument(filePath: string, password: string, currentPassword: string) : Promise<void>;
    pdfFromOfficeTemplate(docxPath: string, json: object) : Promise<string>;
}

const RNPdftron : Pdftron = NativeModules.RNPdftron;

export {
    RNPdftron,
    PDFViewCtrl,
    DocumentView,
    Config,
    AnnotOptions,
    ConfigOptions
};