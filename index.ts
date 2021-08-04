import { NativeModules } from 'react-native';
import { PDFViewCtrl } from './types/PDFViewCtrl/PDFViewCtrl';
import { DocumentView } from './types/DocumentView/DocumentView';
import { Config } from './types/Config/Config';

export interface Pdftron {
    initialize?(licenseKey: string) : void;
    enableJavaScript?(enabled: boolean) : void;
    getVersion?() : Promise<string>;
    getPlatformVersion?() : Promise<string>;
    getSystemFontList?() : Promise<string>;
    clearRubberStampCache?() : Promise<void>;
    encryptDocument?(filePath: string, password: string, currentPassword: string) : Promise<void>;
    pdfFromOfficeTemplate?(docxPath: string, json: object) : Promise<string>;
}

const RNPdftron : Pdftron = NativeModules;

export {
    RNPdftron,
    PDFViewCtrl,
    DocumentView,
    Config
};