import { NativeModules } from 'react-native';
import { PDFViewCtrl } from './src/PDFViewCtrl/PDFViewCtrl';
import { DocumentView } from './src/DocumentView/DocumentView';
import { Config } from './src/Config/Config';
import * as AnnotOptions from './src/AnnotOptions/AnnotOptions';

/**
 * @typedef RNPdftron
 * @hidesource
 * @desc RNPdftron contains static methods for global library initialization, configuration, and 
 * utility methods.
 */
interface RNPdftron 
{
  /**
   * @method
   * @desc Initializes PDFTron SDK with your PDFTron commercial license key. 
   * You can run PDFTron in demo mode by passing an empty string.
   * @param {string} licenseKey your PDFTron license key
   * @example RNPdftron.initialize('your_license_key');
   */
  initialize(licenseKey: string) : void;
  
  /**
   * @method
   * @desc Enables JavaScript engine for PDFTron SDK, by default it is enabled.
   * @param {boolean} enabled whether to enable or disable JavaScript engine
   * @example RNPdftron.enableJavaScript(true);
   */
  enableJavaScript(enabled: boolean) : void;

  /**
   * @method
   * @desc Gets the current PDFNet version.
   * @returns {Promise<string>} version - current PDFNet version
   * @example
   * RNPdftron.getVersion().then((version) => {
   *   console.log("Current PDFNet version:", version);
   * });
   */
  getVersion() : Promise<string>;

  /**
   * @method
   * @desc Gets the version of current platform (Android/iOS).
   * @returns {Promise<string>} platformVersion - current platform version (Android/iOS)
   * @example
   * RNPdftron.getPlatformVersion().then((platformVersion) => {
   *   console.log("App currently running on:", platformVersion);
   * });
   */
  getPlatformVersion() : Promise<string>;

  /**
   * @method
   * @desc Gets the font list available on the OS (Android only).
   * This is typically useful when you are mostly working with non-ascii characters in the viewer.
   * @returns {Promise<string>} fontList - the font list available on Android
   * @example
   * RNPdftron.getSystemFontList().then((fontList) => {
   *   console.log("OS font list:", fontList);
   * });
   */
  getSystemFontList() : Promise<string>;

  /**
   * @method
   * @desc Clear the information and bitmap cache for rubber stamps (Android only).
   * This is typically useful when the content of rubber stamps has been changed in the viewer.
   * @example
   * RNPdftron.clearRubberStampCache().then(() => {
   *   console.log("Rubber stamp cache cleared");
   * });
   */
  clearRubberStampCache() : Promise<void>;

  /**
   * @method
   * @desc Encrypts (password-protect) a document (must be a PDF). 
   * 
   * **Note**: This function does not lock the document, 
   * it cannot be used while the document is opened in the viewer.
   * @param {string} filePath the local file path to the file
   * @param {string} password the password you would like to set
   * @param {string} currentPassword the current password, use empty string if no password
   * @example
   * RNPdftron.encryptDocument("/sdcard/Download/new.pdf", "1111", "").then(() => {
   *   console.log("done password");
   * });
   */
  encryptDocument(filePath: string, password: string, currentPassword: string) : Promise<void>;

  /**
   * @method
   * @desc Generates a PDF from an Office document
   * @param {string} docxPath the local file path to the Office file.
   * @param {boolean} [options.applyPageBreaksToSheet] Whether we should split Excel workheets into 
   * pages so that the output resembles print output.
   * @param {boolean} [options.displayChangeTracking] If this option is true, will display office 
   * change tracking markup present in the document (i.e, red strikethrough of deleted 
   * content and underlining of new content).
   * @param {double} [options.excelDefaultCellBorderWidth] Cell border width for table cells that 
   * would normally be drawn with no border.
   * @param {int} [options.excelMaxAllowedCellCount] Conversion will throw an exception if the 
   * number of cells in a Microsoft Excel document is above the set MaxAllowedCellCount.
   * @param {string} [options.locale] ISO 639-1 code of the current system locale. 
   * For example: 'en-US', 'ar-SA', 'de-DE', etc.
   * @returns {Promise<string>} resultPdfPath - the local file path to the generated PDF. 
   * The user is responsible for cleaning up the temporary file that is generated.
   * @example
   * // With options
   * RNPdftron.pdfFromOffice("/sdcard/Download/red.xlsx", 
   * {
   *  applyPageBreaksToSheet: true, 
   *  displayChangeTracking: true, 
   *  excelDefaultCellBorderWidth: 1, 
   *  excelMaxAllowedCellCount: 250000, 
   *  locale: 'en-US'
   * })
   * .then((resultPdfPath) => {
   *    console.log(resultPdfPath);
   * });
   *
   * // Without options
   * RNPdftron.pdfFromOffice("/sdcard/Download/red.xlsx", null).then((resultPdfPath) => {
   *  console.log(resultPdfPath);
   * });
   */
  pdfFromOffice(docxPath: string, options?: {applyPageBreaksToSheet?: boolean, 
    displayChangeTracking?: boolean, excelDefaultCellBorderWidth?: number, 
    excelMaxAllowedCellCount?: number, locale?: string}) : Promise<string>

  /**
   * @method
   * @desc Generates a PDF using a template in the form of an Office document 
   * and replacement data in the form of a JSON object.
   * For more information please see our 
   * [template guide](https://www.pdftron.com/documentation/core/guides/generate-via-template/).
   * 
   * The user is responsible for cleaning up the temporary file that is generated.
   * @param {string} docxPath the local file path to the template file
   * @param {object} json the replacement data in the form of a JSON object
   * @returns {Promise<string>} resultPdfPath - the local file path to the generated PDF 
   * @example
   * RNPdftron.pdfFromOfficeTemplate("/sdcard/Download/red.docx", json).then((resultPdfPath) => {
   *   console.log(resultPdfPath);
   * });
   */
  pdfFromOfficeTemplate(docxPath: string, json: object) : Promise<string>;

  /**
   * @method
   * @desc Export a PDF page to an image format defined in {@link Config.ExportFormat}. 
   * 
   * Unlike {@link DocumentView#exportAsImage DocumentView.exportAsImage}, 
   * this method is static and should only be called *before* a `DocumentView` 
   * instance has been created or else unexpected behaviour can occur. 
   * This method also takes a local file path to the desired PDF.
   * @param {int} pageNumber the page to be converted; 
   * if the value does not refer to a valid page number, the file path will be undefined
   * @param {double} dpi the output image resolution
   * @param {Config.ExportFormat} exportFormat image format to be exported to
   * @param {string} filePath local file path to pdf
   * @returns {Promise<string>} resultImagePath - the temp path of the created image, 
   * user is responsible for clean up the cache
   * @example
   * RNPdftron.exportAsImage(1, 92, Config.ExportFormat.BMP, "/sdcard/Download/red.pdf").then(
   *  (resultImagePath) => {
   *   console.log('export', resultImagePath);
   * });
   */
  exportAsImage(pageNumber: number, dpi: number, 
    exportFormat: Config.ExportFormat, filePath: string) : Promise<string>;
}

/**
 * @class
 * @hideconstructor
 */
// eslint-disable-next-line no-redeclare
const RNPdftron : RNPdftron = NativeModules.RNPdftron;

export {
  RNPdftron,
  PDFViewCtrl,
  DocumentView,
  Config,
  AnnotOptions
};
