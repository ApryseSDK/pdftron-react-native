import { NativeModules } from 'react-native';
import { PDFViewCtrl } from './types/PDFViewCtrl/PDFViewCtrl';
import { DocumentView } from './types/DocumentView/DocumentView';
import { Config } from './types/Config/Config';
const RNPdftron = NativeModules;
export { RNPdftron, PDFViewCtrl, DocumentView, Config };
