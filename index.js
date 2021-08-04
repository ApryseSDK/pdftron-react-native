import { NativeModules } from 'react-native';
import { PDFViewCtrl } from 'react-native-pdftron/types/PDFViewCtrl/PDFViewCtrl';
import { DocumentView } from 'react-native-pdftron/types/DocumentView/DocumentView';
import { Config } from 'react-native-pdftron/types/Config/Config';
const RNPdftron = NativeModules;
export { RNPdftron, PDFViewCtrl, DocumentView, Config };
