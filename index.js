import { NativeModules } from 'react-native';
import { PDFViewCtrl } from './types/PDFViewCtrl/PDFViewCtrl';
import { DocumentView } from './types/DocumentView/DocumentView';
import { Config } from './types/Config/Config';
import * as AnnotOptions from './types/AnnotOptions/AnnotOptions';
const RNPdftron = NativeModules.RNPdftron;
export { RNPdftron, PDFViewCtrl, DocumentView, Config, AnnotOptions };
