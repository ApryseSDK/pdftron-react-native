import { NativeModules } from 'react-native';
import { PDFViewCtrl } from './src/PDFViewCtrl/PDFViewCtrl';
import { DocumentView } from './src/DocumentView/DocumentView';
import { Config } from './src/Config/Config';
import * as AnnotOptions from './src/AnnotOptions/AnnotOptions';
const RNPdftron = NativeModules.RNPdftron;
export { RNPdftron, PDFViewCtrl, DocumentView, Config, AnnotOptions, };
