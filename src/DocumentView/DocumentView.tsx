import React, { PureComponent } from 'react';
import PropTypes, { Requireable, Validator } from 'prop-types';
import {
  requireNativeComponent,
  ViewPropTypes,
  Platform,
  Alert,
  NativeModules,
  findNodeHandle,
} from 'react-native';
const { DocumentViewManager } = NativeModules;
import {Config} from "../Config/Config";
import * as AnnotOptions from "../AnnotOptions/AnnotOptions";

/**
 * @description This object outlines valid {@link DocumentView} class props. 
 * These can be passed into {@link DocumentView} to customize the viewer.
 * 
 * For Contributors: The propTypes interface below contains PropTypes types for 
 * the {@link DocumentView} class.
 * It is also used to generate custom types for TS users.
 * 
 * To represent functions, please use {@link func}.
 * To represent "one of Config.Buttons values" or "an array of 
 * Config.Buttons values", please use {@link oneOf} or {@link arrayOf}.
 * 
 * @ignore
 */
export const DocumentViewPropTypes = {
  /**
   * @memberof DocumentView
   * @category Open a Document
   * @type {string}
   * @description The path or url to the document. Required.
   * @example
   * <DocumentView
   *   document={'https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_about.pdf'}
   * />
   */
  document: PropTypes.string.isRequired,
  /**
   * @memberof DocumentView
   * @category Open a Document
   * @type {string}
   * @optional
   * @description The password of the document, if any. 
   * @example
   * <DocumentView
   *   password={'password'}
   * />
   */
  password: PropTypes.string,

  /**
   * @memberof DocumentView
   * @category Page
   * @type {number}
   * @optional
   * @description Defines the initial page number that viewer displays when the document is opened. Note that page numbers are 1-indexed. 
   * @example
   * <DocumentView
   *   initialPageNumber={5}
   * />
   */
  initialPageNumber: PropTypes.number,

  /**
   * @memberof DocumentView
   * @category Page
   * @type {number}
   * @optional
   * @description Defines the currently displayed page number. Different from {@link DocumentView.initialPageNumber initialPageNumber}, changing this prop value at runtime will change the page accordingly. 
   * @example
   * <DocumentView
   *   pageNumber={5}
   * />
   */
  pageNumber: PropTypes.number,

  /**
   * @memberof DocumentView
   * @category Open a Document
   * @type {object}
   * @optional
   * @description Defines custom headers to use with HTTP/HTTPS requests. 
   * @example
   * <DocumentView
   *   customHeaders={{headerKey: 'headerValue'}}
   * />
   */
  customHeaders: PropTypes.object,

  /**
   * @memberof DocumentView
   * @category UI Customization
   * @type {string}
   * @optional
   * @description The file name of the icon to be used for the leading navigation button. The button will use the specified icon if it is valid, and the default icon otherwise. 
   * 
   * **Note**: to add the image file to your application, please follow the steps below:
   * 
   * ##### Android
   * 1. Add the image resource to the drawable directory in [`example/android/app/src/main/res`](https://github.com/PDFTron/pdftron-react-native/blob/master/example/android/app/src/main/res). For details about supported file types and potential compression, check out [here](https://developer.android.com/guide/topics/graphics/drawables#drawables-from-images).
   * 
   * <img alt='demo-android' src='https://pdftron.s3.amazonaws.com/custom/websitefiles/react-native/android_add_resources.png'/>
   * <br/><br/>
   * 2. Now you can use the image in the viewer. For example, if you add `button_close.png` to drawable, you could use `'button_close'` in leadingNavButtonIcon.
   * 
   * ##### iOS
   * 1. After pods has been installed, open the `.xcworkspace` file for this application in Xcode (in this case, it's [`example.xcworkspace`](https://github.com/PDFTron/pdftron-react-native/tree/master/example/ios/example.xcworkspace)), and navigate through the list below. This would allow you to add resources, in this case, an image, to your project.
   * - "Project navigator"
   * - "example" (or the app name)
   * - "Build Phases"
   * - "Copy Bundle Resources"
   * - "+".
   * 
   * <img alt='demo-ios' src='https://pdftron.s3.amazonaws.com/custom/websitefiles/react-native/ios_add_resources.png'/>
   * <br/><br/>
   * 2. Now you can use the image in the viewer. For example, if you add `button_open.png` to the bundle, you could use `'button_open.png'` in leadingNavButtonIcon.
   * 
   * @example
   * <DocumentView
   *   leadingNavButtonIcon={Platform.OS === 'ios' ? 'ic_close_black_24px.png' : 'ic_arrow_back_white_24dp'}
   * />
   */
  leadingNavButtonIcon: PropTypes.string,

  /**
   * @memberof DocumentView
   * @category UI Customization
   * @type {boolean}
   * @optional
   * @default true
   * @description Defines whether to show the leading navigation button. 
   * @example
   * <DocumentView
   *   showLeadingNavButton={true}
   * />
   */
  showLeadingNavButton: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category UI Customization
   * @event
   * @type {function}
   * @optional
   * @description This function is called when the leading navigation button is pressed. 
   * @example
   * <DocumentView
   *   onLeadingNavButtonPressed = {() => {
   *       console.log('The leading nav has been pressed');
   *   }}
   * />
   */
  onLeadingNavButtonPressed: func<() => void>(),

  /**
   * @memberof DocumentView
   * @category Open a Document
   * @event
   * @type {function}
   * @optional
   * @description This function is called when the document finishes loading.
   * @param {string} path
   * @example
   * <DocumentView
   *   onDocumentLoaded = {(path) => { 
   *     console.log('The document has finished loading:', path); 
   *   }}
   * />
   */  
  onDocumentLoaded: func<(path: string) => void>(),

  /**
   * @memberof DocumentView
   * @category Open a Document
   * @event
   * @type {function}
   * @optional
   * @description This function is called when document opening encounters an error.
   * @param {string} error
   * @example
   * <DocumentView
   *   onDocumentError = {(error) => { 
   *     console.log('Error occured during document opening:', error); 
   *   }}
   * />
   */  
  onDocumentError: func<(error: string) => void>(),
  
  /**
   * @memberof DocumentView
   * @category Page
   * @event
   * @type {function}
   * @optional
   * @description This function is called when the page number has been changed.
   * @param {int} previousPageNumber the previous page number
   * @param {int} pageNumber the current page number
   * @example
   * <DocumentView
   *   onPageChanged = {({previousPageNumber, pageNumber}) => {
   *     console.log('Page number changes from', previousPageNumber, 'to', pageNumber);
   *   }}
   * />
   */  
  onPageChanged: func<(event: {previousPageNumber: number, pageNumber: number}) => void>(),

  /**
   * @memberof DocumentView
   * @category Scroll
   * @event
   * @type {function}
   * @optional
   * @description This function is called when the scroll position has been changed.
   * @param {number} horizontal the horizontal position of the scroll
   * @param {number} vertical the vertical position of the scroll
   * @example
   * <DocumentView
   *   onScrollChanged = {({horizontal, vertical}) => {
   *     console.log('Current scroll position is', horizontal, 'horizontally, and', vertical, 'vertically.');
   *   }}
   * />
   */  
  onScrollChanged: func<(event: {horizontal: number, vertical: number}) => void>(),
  
  /**
   * @memberof DocumentView
   * @category Zoom
   * @event
   * @type {function}
   * @optional
   * @description This function is called when the zoom scale has been changed.
   * @param {double} zoom the current zoom ratio of the document
   * @example
   * <DocumentView
   *   onZoomChanged = {(zoom) => {
   *     console.log('Current zoom ratio is', zoom);
   *   }}
   * />
   */  
  onZoomChanged: func<(event: {zoom: number}) => void>(),

  /**
   * @memberof DocumentView
   * @category Zoom
   * @event
   * @type {function}
   * @optional
   * @description This function is called when a zooming has been finished. For example, if zoom via gesture, this is called on gesture release.
   * @param {double} zoom the current zoom ratio of the document
   * @example 
   * <DocumentView
   *   onZoomFinished = {(zoom) => {
   *     console.log('Current zoom ratio is', zoom);
   *   }}
   * />
   */  
  onZoomFinished: func<(event: {zoom: number}) => void>(),
  
  /**
   * @memberof DocumentView
   * @category Zoom
   * @type {number}
   * @optional
   * @description Zoom factor used to display the page content.
   * @example
   * <DocumentView
   *   zoom={1}
   * />
   */
  zoom: PropTypes.number,

  /**
   * @memberof DocumentView
   * @category UI Customization
   * @type {Config.Buttons[]}
   * @optional
   * @default Defaults to none.
   * @description Defines buttons to be disabled for the viewer.
   * @example
   * <DocumentView
   *   disabledElements={[Config.Buttons.userBookmarkListButton]}
   * />
   */
  disabledElements: arrayOf<Config.Buttons>(Config.Buttons),

  /**
   * @memberof DocumentView
   * @category UI Customization
   * @type {Config.Tools[]}
   * @optional
   * @default Defaults to none.
   * @description Defines tools to be disabled for the viewer.
   * @example
   * <DocumentView
   *   disabledTools={[Config.Tools.annotationCreateLine, Config.Tools.annotationCreateRectangle]}
   * />
   */
  disabledTools: arrayOf<Config.Tools>(Config.Tools),

  /**
   * @memberof DocumentView
   * @category Long Press Menu
   * @type {Config.LongPressMenu[]}
   * @optional
   * @default Contains all the items.
   * @description Defines menu items that can show when long press on text or blank space.
   * @example
   * <DocumentView
   *   longPressMenuItems={[Config.LongPressMenu.copy, Config.LongPressMenu.read]}
   * />
   */
  longPressMenuItems: arrayOf<Config.LongPressMenu>(Config.LongPressMenu),

  /**
   * @memberof DocumentView
   * @category Long Press Menu
   * @type {Config.LongPressMenu[]}
   * @optional
   * @default Defaults to none.
   * @description Defines the menu items on long press that will skip default behavior when pressed. 
   * They will still be displayed in the long press menu, and the function {@link DocumentView.event:onLongPressMenuPress onLongPressMenuPress} will be called where custom behavior can be implemented.
   * @example
   * <DocumentView
   *   overrideLongPressMenuBehavior={[Config.LongPressMenu.search]}
   * />
   */
  overrideLongPressMenuBehavior: arrayOf<Config.LongPressMenu>(Config.LongPressMenu),
  
  /**
   * @memberof DocumentView
   * @category Long Press Menu
   * @event
   * @type {function}
   * @optional
   * @description This function is called if the pressed long press menu item is passed in to {@link DocumentView.overrideLongPressMenuBehavior overrideLongPressMenuBehavior}.
   * @param {string} longPressMenu One of {@link Config.LongPressMenu} constants, representing which item has been pressed
   * @param {string} longPressText the selected text if pressed on text, empty otherwise
   * @example
   * <DocumentView
   *   onLongPressMenuPress = {({longPressMenu, longPressText}) => {
   *     console.log('Long press menu item', longPressMenu, 'has been pressed');
   *     if (longPressText !== '') {
   *       console.log('The selected text is', longPressText);
   *     }
   *   }}
   * />
   */  
  onLongPressMenuPress: func<(event: {longPressMenu: string, longPressText: string}) => void>(),
  
  /**
   * @memberof DocumentView
   * @category Long Press Menu
   * @type {boolean}
   * @optional
   * @default true
   * @description Defines whether to show the popup menu of options when the user long presses on text or blank space on the document.
   * @example
   * <DocumentView
   *   longPressMenuEnabled={true}
   * />
   */
  longPressMenuEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Annotation Menu
   * @type {Config.AnnotationMenu[]}
   * @optional
   * @default Contains all the items.
   * @description Defines the menu items that can show when an annotation is selected.
   * @example
   * <DocumentView
   *   annotationMenuItems={[Config.AnnotationMenu.search, Config.AnnotationMenu.share]}
   * />
   */
  annotationMenuItems: arrayOf<Config.AnnotationMenu>(Config.AnnotationMenu),

  /** 
   * @memberof DocumentView
   * @category Annotation Menu
   * @type {Config.AnnotationMenu[]}
   * @optional
   * @default Defaults to none.
   * @description Defines the menu items that will skip default behavior when pressed. They will still be displayed in the annotation menu, and the function {@link DocumentView.event:onAnnotationMenuPress onAnnotationMenuPress} will be called where custom behavior can be implemented.
   * @example 
   * <DocumentView
   *   overrideAnnotationMenuBehavior={[Config.AnnotationMenu.copy]}
   * />
   */
  overrideAnnotationMenuBehavior: arrayOf<Config.AnnotationMenu>(Config.AnnotationMenu),
  
  /**
   * @memberof DocumentView
   * @category Annotation Menu
   * @event
   * @type {function}
   * @optional
   * @description This function is called when an annotation menu item passed in to {@link DocumentView.overrideAnnotationMenuBehavior overrideAnnotationMenuBehavior} is pressed.
   * @param {string} annotationMenu One of {@link Config.AnnotationMenu} constants, representing which item has been pressed
   * @param {object[]} annotations An array of `{id: string, pageNumber: number, type: string, screenRect: object, pageRect: object}` objects.
   * 
   * `id` is the annotation identifier and `type` is one of the {@link Config.Tools} constants. 
   * 
   * `screenRect` was formerly called `rect`. 
   * 
   * Both rects are represented with `{x1: number, y1: number, x2: number, y2: number, width: number, height: number}` objects.
   * @example
   * <DocumentView
   *   onAnnotationMenuPress = {({annotationMenu, annotations}) => {
   *     console.log('Annotation menu item', annotationMenu, 'has been pressed');
   *     annotations.forEach(annotation => {
   *       console.log('The id of selected annotation is', annotation.id);
   *       console.log('The page number of selected annotation is', annotation.pageNumber);
   *       console.log('The type of selected annotation is', annotation.type);
   *       console.log('The screenRect of selected annotation is', annotation.screenRect);
   *       console.log('The pageRect of selected annotation is', annotation.pageRect);
   *     });
   *   }}
   * />
   */  
  onAnnotationMenuPress: func<(event: {annotationMenu: string, annotations: Array<AnnotOptions.Annotation>}) => void>(),
  
  /**
   * @memberof DocumentView
   * @category Annotation Menu
   * @type {Config.Tools[]}
   * @optional
   * @default Defaults to none.
   * @description Defines annotation types that will not show in the annotation (long-press) menu.
   * @example 
   * <DocumentView
   *   hideAnnotationMenu={[Config.Tools.annotationCreateArrow, Config.Tools.annotationEraserTool]}
   * />
   */
  hideAnnotationMenu: arrayOf<Config.Tools>(Config.Tools),

  /**
   * @memberof DocumentView
   * @category Custom Behavior
   * @type {Config.Actions[]}
   * @optional 
   * @default Defaults to none.
   * @description Defines actions that will skip default behavior, such as external link click. The function {@link DocumentView.event:onBehaviorActivated onBehaviorActivated} will be called where custom behavior can be implemented, whenever the defined actions occur.
   * @example
   * <DocumentView
   *   overrideBehavior={[Config.Actions.linkPress]}
   * />
   */
  overrideBehavior: arrayOf<Config.Actions>(Config.Actions),
  
  /**
   * @memberof DocumentView
   * @category Custom Behavior
   * @event
   * @type {function}
   * @optional
   * @description This function is called if the activated behavior is passed in to {@link DocumentView.overrideBehavior overrideBehavior}
   * @param {string} action One of {@link Config.Actions} constants, representing which action has been activated
   * @param {object} data A JSON object that varies depending on the action.
   * 
   * If action is `Config.Actions.linkPress`, data type is `{url: string}`.
   * 
   * If action is `Config.Actions.stickyNoteShowPopUp`, data type is `{id: string, pageNumber: number, type: string, screenRect: {x1: number, y1: number, x2: number, y2: number, width: number, height: number}, pageRect: {x1: number, y1: number, x2: number, y2: number, width: number, height: number}}`, 
   * where `type` is one of the {@link Config.Tools} constants, and `screenRect` was formerly called `rect`.
   * @example
   * <DocumentView
   *   onBehaviorActivated = {({action, data}) => {
   *     console.log('Activated action is', action);
   *     if (action === Config.Actions.linkPress) {
   *       console.log('The external link pressed is', data.url);
   *     } else if (action === Config.Actions.stickyNoteShowPopUp) {
   *       console.log('Sticky note has been activated, but it would not show a pop up window.');
   *     }
   *   }}
   * />
   */
  onBehaviorActivated: func<(event: {action: Config.Actions, data: AnnotOptions.LinkPressData | AnnotOptions.StickyNoteData}) => void>(),
  
  /**
   * @memberof DocumentView
   * @category Toolbar Customization
   * @type {boolean}
   * @optional
   * @default true
   * @deprecated Use {@link DocumentView.hideTopAppNavBar hideTopAppNavBar} prop instead.
   */
  topToolbarEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Toolbar Customization
   * @type {boolean}
   * @optional
   * @default true
   * @description Defines whether the bottom toolbar of the viewer is enabled.
   * @example
   * <DocumentView
   *   bottomToolbarEnabled={false}
   * />
   */
  bottomToolbarEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Toolbar Customization
   * @type {boolean}
   * @optional
   * @default true
   * @description Defines whether an unhandled tap in the viewer should toggle the visibility of the top and bottom toolbars. When false, the top and bottom toolbar visibility will not be toggled and the page content will fit between the bars, if any.
   * @example
   * <DocumentView
   *   hideToolbarsOnTap={false}
   * />
   */
  hideToolbarsOnTap: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category UI Customization
   * @type {boolean}
   * @optional
   * @default true
   * @description Defines whether the document slider of the viewer is enabled.
   * @example
   * <DocumentView
   *   documentSliderEnabled={false}
   * />
   */
  documentSliderEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Page
   * @type {boolean}
   * @optional
   * @default true
   * @description Defines whether to show the page indicator for the viewer.
   * @example
   * <DocumentView
   *   pageIndicatorEnabled={true}
   * />
   */
  pageIndicatorEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Page
   * @type {boolean}
   * @optional
   * @default true
   * @description iOS only
   * 
   * Defines whether the keyboard shortcuts of the viewer are enabled.
   * @example
   * <DocumentView
   *   keyboardShortcutsEnabled={false}
   * />
   */
  keyboardShortcutsEnabled: PropTypes.bool,
  
  /**
   * @memberof DocumentView
   * @event
   * @type {function}
   * @optional
   * @description This function is called when an annotation(s) is selected.
   * @param {object[]} annotations array of annotation data in the format `{id: string, pageNumber: number, type: string, screenRect: {x1: number, y1: number, x2: number, y2: number, width: number, height: number}, pageRect: {x1: number, y1: number, x2: number, y2: number, width: number, height: number}}`, representing the selected annotations. Type is one of the {@link Config.Tools} constants. `screenRect` was formerly called `rect`.
   * @example
   * <DocumentView
   *   onAnnotationsSelected = {({annotations}) => {
   *     annotations.forEach(annotation => {
   *       console.log('The id of selected annotation is', annotation.id);
   *       console.log('It is in page', annotation.pageNumber);
   *       console.log('Its type is', annotation.type);
   *     });
   *   }}
   * />
   */  
  onAnnotationsSelected: func<(event: {annotations: Array<AnnotOptions.Annotation>}) => void>(),

  /**
   * @memberof DocumentView
   * @event
   * @type {function}
   * @optional
   * @description This function is called if a change has been made to an annotation(s) in the current document.
   * @param {string} action the action that occurred (add, delete, modify)
   * @param {object[]} annotations array of annotation data in the format `{id: string, pageNumber: number, type: string}`, representing the annotations that have been changed. `type` is one of the {@link Config.Tools} constants
   * @example
   * <DocumentView
   *   onAnnotationChanged = {({action, annotations}) => {
   *     console.log('Annotation edit action is', action);
   *     annotations.forEach(annotation => {
   *       console.log('The id of changed annotation is', annotation.id);
   *       console.log('It is in page', annotation.pageNumber);
   *       console.log('Its type is', annotation.type);
   *     });
   *   }}
   * />
   */  
  onAnnotationChanged: func<(event: {action: string, annotations: Array<AnnotOptions.Annotation>}) => void>(),
  
  /**
   * @memberof DocumentView
   * @event
   * @type {function}
   * @optional
   * @description This function is called if a change has been made to form field values.
   * @param {object[]} fields array of field data in the format `{fieldName: string, fieldType: string, fieldValue: any}`, representing the fields that have been changed
   * @example
   * <DocumentView
   *   onFormFieldValueChanged = {({fields}) => {
   *     fields.forEach(field => {
   *       console.log('The name of the changed field is', field.fieldName);
   *       console.log('The type of the changed field is', field.fieldType);
   *       console.log('The value of the changed field is', field.fieldValue);
   *     });
   *   }}
   * />
   */  
  onFormFieldValueChanged: func<(event: {fields: Array<AnnotOptions.Field>}) => void>(),

  /**
   * @memberof DocumentView
   * @category Open a Document
   * @type {boolean}
   * @optional
   * @default false
   * @description Defines whether the viewer is read-only. If true, the UI will not allow the user to change the document.
   * @example
   * <DocumentView
   *   readOnly={true}
   * />
   */
  readOnly: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default true
   * @description Defines whether user can modify the document using the thumbnail view (eg add/remove/rotate pages).
   * @example
   * <DocumentView
   *   thumbnailViewEditingEnabled={true}
   * />
   */
  thumbnailViewEditingEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Layout
   * @type {Config.FitMode}
   * @optional
   * @default Config.FitMode.FitWidth
   * @description Defines the fit mode (default zoom level) of the viewer.
   * @example
   * <DocumentView
   *   fitMode={Config.FitMode.FitPage}
   * />
   */
  fitMode: oneOf<Config.FitMode>(Config.FitMode),

  /**
   * @memberof DocumentView
   * @category Layout
   * @type {Config.LayoutMode}
   * @optional
   * @default Config.LayoutMode.Continuous
   * @description Defines the layout mode of the viewer.
   * @example
   * <DocumentView
   *   layoutMode={Config.LayoutMode.FacingContinuous}
   * />
   */
  layoutMode: oneOf<Config.LayoutMode>(Config.LayoutMode),

  /**
   * @memberof DocumentView
   * @category Layout
   * @event
   * @type {function}
   * @optional
   * @description This function is called when the layout of the viewer has been changed.
   * @example 
   * <DocumentView
   *   onLayoutChanged = {() => {
   *     console.log('Layout has been updated.');
   *   }}
   * />
   */  
  onLayoutChanged: func<() => void>(),

  /**
   * @memberof DocumentView
   * @category Toolbar Customization
   * @type {boolean}
   * @optional
   * @default false
   * @description Android only
   * 
   * Defines whether the viewer will add padding to take account of the system status bar.
   * @example
   * <DocumentView
   *   padStatusBar={true}
   * />
   */
  padStatusBar: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default true
   * @description If true, the active annotation creation tool will remain in the current annotation creation tool. Otherwise, it will revert to the "pan tool" after an annotation is created.
   * @example
   * <DocumentView
   *   continuousAnnotationEditing={true}
   * />
   */
  continuousAnnotationEditing: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default true
   * @description Defines whether an annotation is selected after it is created. On iOS, this functions for shape and text markup annotations only.
   * @example
   * <DocumentView
   *   selectAnnotationAfterCreation={true}
   * />
   */
  selectAnnotationAfterCreation: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {string}
   * @optional
   * @description Defines the author name for all annotations created on the current document. Exported xfdfCommand will include this piece of information.
   * @example
   * <DocumentView
   *   annotationAuthor={'PDFTron'}
   * />
   */
  annotationAuthor: PropTypes.string,

  /** 
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default true
   * @description Defines whether to show saved signatures for re-use when using the signing tool.
   * @example
   * <DocumentView
   *   showSavedSignatures={true}
   * />
   */
  showSavedSignatures: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Open a Document
   * @type {boolean}
   * @optional
   * @default false
   * @description If true, {@link DocumentView.document document} prop will be treated as a base64 string. If it is not the base64 string of a pdf file, {@link DocumentView.base64FileExtension base64FileExtension} is required. 
   * 
   * When viewing a document initialized with a base64 string (i.e. a memory buffer), a temporary file is created on Android and iOS.
   * @example
   * <DocumentView
   *   isBase64String={true}
   *   document={'...'} // base 64 string
   * />
   */
  isBase64String: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default false
   * @description Defines whether to enable realtime collaboration. If true then {@link DocumentView.currentUser currentUser} must be set as well for collaboration mode to work. Feature set may vary between local and collaboration mode.
   * @example
   * <DocumentView
   *   collabEnabled={true}
   *   currentUser={'Pdftron'}
   * />
   */
  collabEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {string}
   * @description Required if {@link DocumentView.collabEnabled collabEnabled} is set to true.
   * 
   * Defines the current user. Created annotations will have their title (author) set to this string.
   * @example
   * <DocumentView
   *   collabEnabled={true}
   *   currentUser={'Pdftron'}
   * />
   */
  currentUser: PropTypes.string,

  /**
   * @memberof DocumentView
   * @type {string}
   * @optional
   * @description Defines the current user name. 
   * Will set the user name only if {@link DocumentView.collabEnabled collabEnabled} is true and {@link DocumentView.currentUser currentUser} is defined.
   * This should be used only if you want the user's display name to be different than the annotation's title/author 
   * (in the case that {@link DocumentView.currentUser currentUser} is an ID rather than a human-friendly name.)
   * @example
   * <DocumentView
   *   collabEnabled={true}
   *   currentUser={'Pdftron'}
   *   currentUserName={'Hello_World'}
   * />
   */
  currentUserName: PropTypes.string,

  /**
   * @memberof DocumentView
   * @event
   * @type {function}
   * @optional
   * @description This function is called if a change has been made to annotations in the current document. 
   * Unlike {@link DocumentView.event:onAnnotationChanged onAnnotationChanged}, this function has an XFDF command string as its parameter. 
   * If you are modifying or deleting multiple annotations, then on Android the function is only called once, and on iOS it is called for each annotation.
   * 
   * **Known Issues**
   * 
   * On iOS, there is currently a bug that prevents the last XFDF from being retrieved when modifying annotations while collaboration mode is enabled.
   * @param {string} action the action that occurred (add, delete, modify)
   * @param {string} xfdfCommand an xfdf string containing info about the edit
   * @param {array} annotations an array of annotation data. 
   * When collaboration is enabled data comes in the format `{id: string}`, otherwise the format is `{id: string, pageNumber: number, type: string}`. 
   * In both cases, the data represents the annotations that have been changed. 
   * `type` is one of the {@link Config.Tools} constants.
   * @example
   * <DocumentView
   *   onExportAnnotationCommand = {({action, xfdfCommand, annotations}) => {
   *     console.log('Annotation edit action is', action);
   *     console.log('The exported xfdfCommand is', xfdfCommand);
   *     annotations.forEach((annotation) => {
   *       console.log('Annotation id is', annotation.id);
   *     if (!this.state.collabEnabled) {
   *         console.log('Annotation pageNumber is', annotation.pageNumber);
   *         console.log('Annotation type is', annotation.type);
   *       }
   *     });
   *     }}
   *     collabEnabled={this.state.collabEnabled}
   *     currentUser={'Pdftron'}
   * />
   */  
  onExportAnnotationCommand: func<(event: {action: string, xfdfCommand: string, annotations: Array<AnnotOptions.Annotation>}) => void>(),

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default true
   * @description Defines whether document is automatically saved by the viewer.
   * @example
   * <DocumentView
   *   autoSaveEnabled={true}
   * />
   */
  autoSaveEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Page
   * @type {boolean}
   * @optional
   * @default true
   * @description Defines whether the viewer should change pages when the user taps the edge of a page, when the viewer is in a horizontal viewing mode.
   * @example
   * <DocumentView
   *   pageChangeOnTap={true}
   * />
   */
  pageChangeOnTap: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default true
   * @description Android and iOS 13+ only
   * 
   * Defines whether the UI will appear in a dark color when the system is dark mode. If false, it will use viewer setting instead.
   * @example
   * <DocumentView
   *   followSystemDarkMode={false}
   * />
   */
  followSystemDarkMode: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default true
   * @description Defines whether a stylus should act as a pen when in pan mode. If false, it will act as a finger.
   * @example
   * <DocumentView
   *   useStylusAsPen={true}
   * />
   */
  useStylusAsPen: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Multi-tab
   * @type {boolean}
   * @optional
   * @default false
   * @description Defines whether viewer will use tabs in order to have more than one document open simultaneously (like a web browser). 
   * Changing the {@link DocumentView.document document} prop value will cause a new tab to be opened with the associated file.
   * @example
   * <DocumentView
   *   multiTabEnabled={true}
   * />
   */
  multiTabEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Multi-tab
   * @type {string}
   * @optional
   * @default the file name
   * @description Set the tab title if {@link DocumentView.multiTabEnabled multiTabEnabled} is true.
   * @example
   * <DocumentView
   *   multiTabEnabled={true}
   *   tabTitle={'tab1'}
   * />
   */
  tabTitle: PropTypes.string,

  /**
   * @memberof DocumentView
   * @category Multi-tab
   * @type {number}
   * @optional
   * @default unlimited
   * @description Sets the limit on the maximum number of tabs that the viewer could have at a time. 
   * Open more documents after reaching this limit will overwrite the old tabs.
   * @example
   * <DocumentView
   *   multiTabEnabled={true}
   *   maxTabCount={5}
   * />
   */
  maxTabCount: PropTypes.number,

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default false
   * @description
   * Defines whether signature fields will be signed with image stamps.
   * This is useful if you are saving XFDF to remote source.
   * @example
   * <DocumentView
   *   signSignatureFieldsWithStamps={true}
   * />
   */
  signSignatureFieldsWithStamps: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default false
   * @description Defines whether an annotation's permission flags will be respected when it is selected. 
   * For example, a locked annotation can not be resized or moved.
   * @example
   * <DocumentView
   *   annotationPermissionCheckEnabled={true}
   * />
   */
  annotationPermissionCheckEnabled: PropTypes.bool,

  /**
   * @type {Config.DefaultToolbars[]|object}
   * @category Toolbar Customization
   * @memberof DocumentView
   * @optional
   * @default Defaults to none.
   * @description Type can be array of {@link Config.DefaultToolbars} constants or custom toolbar objects.
   * 
   * Defines custom toolbars. If passed in, the default toolbars will no longer appear.
   * It is possible to mix and match with default toolbars. See example below.
   * @example
   * const myToolbar = {
   *   [Config.CustomToolbarKey.Id]: 'myToolbar',
   *   [Config.CustomToolbarKey.Name]: 'myToolbar',
   *   [Config.CustomToolbarKey.Icon]: Config.ToolbarIcons.FillAndSign,
   *   [Config.CustomToolbarKey.Items]: [Config.Tools.annotationCreateArrow, 
   *      Config.Tools.annotationCreateCallout, Config.Buttons.undo]
   * };
   * ...
   * <DocumentView
   *   annotationToolbars={[Config.DefaultToolbars.Annotate, myToolbar]}
   * />
   */
  annotationToolbars: PropTypes.arrayOf(PropTypes.oneOfType([
    oneOf<Config.DefaultToolbars>(Config.DefaultToolbars),
    PropTypes.exact({
      id: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired,
      icon: oneOf<Config.ToolbarIcons>(Config.ToolbarIcons).isRequired,
      items: arrayOf<Config.Tools | Config.Buttons>(Config.Tools, Config.Buttons).isRequired
    })
  ])),

  /**
   * @memberof DocumentView
   * @category Toolbar Customization
   * @type {Config.DefaultToolbars[]}
   * @optional
   * @default Defaults to none.
   * @description Defines which default annotation toolbars should be hidden. 
   * Note that this prop should be used when {@link DocumentView.annotationToolbars annotationToolbars} is not defined.
   * @example
   * <DocumentView
   *   hideDefaultAnnotationToolbars={[Config.DefaultToolbars.Annotate, Config.DefaultToolbars.Favorite]}
   * />
   */
  hideDefaultAnnotationToolbars: arrayOf<Config.DefaultToolbars>(Config.DefaultToolbars),
  
  /**
   * @memberof DocumentView
   * @category Toolbar Customization
   * @type {Config.Buttons[]}
   * @optional
   * @description iOS only
   * 
   * Customizes the right bar section of the top app nav bar. If passed in, the default right bar section will not be used.
   * @example
   * <DocumentView
   *   topAppNavBarRightBar={[Config.Buttons.reflowButton, Config.Buttons.outlineListButton]}
   * />
   */
  topAppNavBarRightBar: arrayOf<Config.Buttons>(Config.Buttons),

  /** 
   * @memberof DocumentView
   * @type {Config.Buttons[]}
   * @category Toolbar Customization
   * @optional
   * @description Only the outline list, thumbnail list, share, view mode, search, and reflow buttons are supported on Android.
   * 
   * Defines a custom bottom toolbar. If passed in, the default bottom toolbar will not be used.
   * @example
   * <DocumentView
   *   bottomToolbar={[Config.Buttons.reflowButton, Config.Buttons.outlineListButton]}
   * />
  */
  bottomToolbar: arrayOf<Config.Buttons>(Config.Buttons),

  /**
   * @memberof DocumentView
   * @category Toolbar Customization
   * @type {boolean}
   * @optional
   * @default false
   * @description Defines whether to show the toolbar switcher in the top toolbar.
   * @example
   * <DocumentView
   *   hideAnnotationToolbarSwitcher={false}
   * />
   */
  hideAnnotationToolbarSwitcher: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Toolbar Customization
   * @type {boolean}
   * @optional
   * @default false
   * @description Defines whether to hide both the top app nav bar and the annotation toolbar.
   * @example
   * <DocumentView
   *   hideTopToolbars={false}
   * />
   */
  hideTopToolbars: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Toolbar Customization
   * @type {boolean}
   * @optional
   * @default false
   * @description Defines whether to hide the top navigation app bar.
   * @example
   * <DocumentView
   *   hideTopAppNavBar={true}
   * />
   */
  hideTopAppNavBar: PropTypes.bool,
  /**
   * @memberof DocumentView
   * @event
   * @type {function}
   * @optional
   * @description This function is called if a change has been made to user bookmarks.
   * @param {string} bookmarkJson the list of current bookmarks in JSON format
   * @example
   * <DocumentView
   *   onBookmarkChanged = {({bookmarkJson}) => {
   *     console.log('Bookmarks have been changed. Current bookmark collection is', bookmarkJson);
   *   }}
   * />
   */  
  onBookmarkChanged: func<(event: {bookmarkJson: string}) => void>(),

  /**
   * @memberof DocumentView
   * @type {Config.ThumbnailFilterMode[]}
   * @optional
   * @description Defines filter modes that should be hidden in the thumbnails browser. 
   * @example
   * <DocumentView
   *   hideThumbnailFilterModes={[Config.ThumbnailFilterMode.Annotated]}
   * />
   */
  hideThumbnailFilterModes: arrayOf<Config.ThumbnailFilterMode>(Config.ThumbnailFilterMode),

  /**
   * @memberof DocumentView
   * @category UI Customization
   * @event
   * @type {function}
   * @optional
   * @description This function is called when the current tool changes to a new tool
   * @param {string} previousTool the previous tool (one of the {@link Config.Tools} constants or "unknown tool"), representing the tool before change
   * @param {string} tool the current tool (one of the {@link Config.Tools} constants or "unknown tool"), representing the current tool
   * @example
   * <DocumentView
   *   onToolChanged = {({previousTool, tool}) => {
   *     console.log('Tool has been changed from', previousTool, 'to', tool);
   *   }}
   * />
   */  
  onToolChanged: func<(event: {previousTool: Config.Tools | "unknown tool", tool: Config.Tools | "unknown tool"}) => void>(),

  /**
   * @memberof DocumentView
   * @category Scroll
   * @type {number}
   * @optional
   * @description Defines the horizontal scroll position in the current document viewer.
   * @example
   * <DocumentView
   *   horizontalScrollPos={50}
   * />
   */
  horizontalScrollPos: PropTypes.number,

  /**
   * @memberof DocumentView
   * @category Scroll
   * @type {number}
   * @optional
   * @description Defines the vertical scroll position in the current document viewer.
   * @example
   * <DocumentView
   *   verticalScrollPos={50}
   * />
   */
  verticalScrollPos: PropTypes.number,

  /**
   * @memberof DocumentView
   * @event
   * @type {function}
   * @optional
   * @description This function is called immediately before a text search begins, 
   * either through user actions, or function calls such as {@link DocumentView#findText findText}.
   * @example
   * <DocumentView
   *   onTextSearchStart = {() => {
   *     console.log('Text search has started');
   *   }}
   * />
   */  
  onTextSearchStart: func<() => void>(),

  /**
   * @memberof DocumentView
   * @event
   * @type {function}
   * @optional
   * @description This function is called after a text search is finished or canceled.
   * @param {boolean} found whether a result is found. If no, it could be caused by not finding a matching result in the document, invalid text input, or action cancellation (user actions or {@link DocumentView#cancelFindText cancelFindText}
   * @param {object} textSelection the text selection, in the format `{html: string, unicode: string, pageNumber: number, quads: [[{x: number, y: number}, {x: number, y: number}, {x: number, y: number}, {x: number, y: number}], ...]}`. If no such selection could be found, this would be null
   * 
   * Quads indicate the quad boundary boxes for the selection, which could have a size larger than 1 if selection spans across different lines. Each quad have 4 points with x, y coordinates specified in number, representing a boundary box. The 4 points are in counter-clockwise order, though the first point is not guaranteed to be on lower-left relatively to the box.
   * @example
   * <DocumentView
   *   onTextSearchResult = {({found, textSelection}) => {
   *     if (found) {
   *       console.log('Found selection on page', textSelection.pageNumber);
   *       for (let i = 0; i < textSelection.quads.length; i ++) {
   *         const quad = textSelection.quads[i];
   *         console.log('selection boundary quad', i);
   *         for (const quadPoint of quad) {
   *           console.log('A quad point has coordinates', quadPoint.x, quadPoint.y);
   *         }
   *       }
   *     }
   *   }}
   * />
   */  
  onTextSearchResult: func<(event: {found: boolean, textSelection: AnnotOptions.TextSelectionResult | null}) => void>(),

  /**
   * @memberof DocumentView
   * @category UI Customization
   * @type {Config.ViewModePickerItem[]}
   * @optional
   * @default Defaults to none.
   * @description Defines view mode items to be hidden in the view mode dialog.
   * @example
   * <DocumentView
   *   hideViewModeItems={[
   *     Config.ViewModePickerItem.Crop,
   *     Config.ViewModePickerItem.Rotation,
   *     Config.ViewModePickerItem.ColorMode
   *   ]}
   * />
   */
  hideViewModeItems: arrayOf<Config.ViewModePickerItem>(Config.ViewModePickerItem),

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default true
   * @description Android only.
   * 
   * Defines whether the page stack navigation buttons will appear in the viewer.
   * @example
   * <DocumentView
   *   pageStackEnabled={false}
   * />
   */
  pageStackEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default true
   * @description Android only
   * 
   * Defines whether the quick navigation buttons will appear in the viewer.
   * @example
   * <DocumentView
   *   showQuickNavigationButton={false}
   * />
   */
  showQuickNavigationButton: PropTypes.bool,
  
  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default true.
   * @description Android only.
   * 
   * Defines whether to show the option to pick images in the signature dialog.
   * @example
   * <DocumentView
   *   photoPickerEnabled={true}
   * />
   */
  photoPickerEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default false
   * @description Defines whether to automatically resize the bounding box of free text annotations when editing.
   * @example
   * <DocumentView
   *   autoResizeFreeTextEnabled={true}
   * />
   */
  autoResizeFreeTextEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {bool}
   * @optional
   * @default true
   * @description Android only
   * 
   * If document editing is enabled, then this value determines if the annotation list is editable.
   * @example
   * <DocumentView
   *   annotationsListEditingEnabled={true}
   * />
   */
  annotationsListEditingEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default true on Android and false on iOS
   * @description Defines whether the navigation list will be displayed as a side panel on large devices such as iPads and tablets.
   * @example
   * <DocumentView
   *   showNavigationListAsSidePanelOnLargeDevices={true}
   * />
   */
  showNavigationListAsSidePanelOnLargeDevices: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default false
   * @description Defines whether to restrict data usage when viewing online PDFs.
   * @example
   * <DocumentView
   *   restrictDownloadUsage={true}
   * />
   */
  restrictDownloadUsage: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default true
   * @description Defines whether the bookmark list can be edited. If the viewer is readonly then bookmarks on Android are 
   * still editable but are saved to the device rather than the PDF.
   * @example
   * <DocumentView
   *   userBookmarksListEditingEnabled={true}
   * />
   */
  userBookmarksListEditingEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Reflow
   * @type {boolean}
   * @optional
   * @default true
   * @description Whether to show images in reflow mode. 
   * @example
   * <DocumentView
   *   imageInReflowEnabled={false}
   * />
   */
  imageInReflowEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Reflow
   * @type {Config.ReflowOrientation}
   * @optional
   * @default Config.ReflowOrientation.Horizontal 
   * @description Android only.
   * 
   * Sets the scrolling direction of the reflow control.
   * @example
   * <DocumentView
   *   reflowOrientation={Config.ReflowOrientation.Vertical} 
   * />
   */
  reflowOrientation: oneOf<Config.ReflowOrientation>(Config.ReflowOrientation),
  
  /**
   * @memberof DocumentView
   * @event
   * @type {function}
   * @optional
   * @description This function is called when the state of the current document's undo/redo stack has been changed.
   * @example
   * <DocumentView
   *   onUndoRedoStateChanged = {() => { 
   *     console.log("Undo/redo stack state changed");
   *   }}
   * />
   */  
  onUndoRedoStateChanged: func<() => void>(),

  /**
   * @memberof DocumentView
   * @category UI Customization
   * @type {boolean}
   * @optional
   * @default true
   * @description Android only.
   * 
   * Defines whether the tablet layout should be used on tablets. Otherwise uses the same layout as phones. 
   * @example
   * <DocumentView
   *   tabletLayoutEnabled={true}
   * />
   */
  tabletLayoutEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Toolbar Customization
   * @type {Config.DefaultToolbars|string}
   * @optional
   * @default Defaults to none.
   * @description Type can be one of the {@link Config.DefaultToolbars} constants or the `id` of a custom toolbar object.
   * 
   * Defines which {@link DocumentView.annotationToolbars annotationToolbar} should be selected when the document is opened.
   * @example
   * <DocumentView
   *   initialToolbar={Config.DefaultToolbars.Draw}
   * />
   */
  initialToolbar: PropTypes.string,

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default true
   * @description If true, ink tool will use multi-stroke mode. Otherwise, each stroke is a new ink annotation.
   * @example
   * <DocumentView
   *   inkMultiStrokeEnabled={true}
   * />
   */
  inkMultiStrokeEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Open a Document
   * @type {Config.EraserType}
   * @optional
   * @description Android only. 
   * 
   * Sets the default eraser tool type. Value only applied after a clean install. 
   * @example
   * <DocumentView
   *   defaultEraserType={Config.EraserType.hybrideEraser}
   * />
   */
  defaultEraserType: oneOf<Config.EraserType>(Config.EraserType),

  /**
   * @memberof DocumentView
   * @category Open a Document
   * @type {string}
   * @optional
   * @description Android only.
   * 
   * Sets the folder path for all save options, this defaults to the app cache path. 
   * Example:
   * @example
   * <DocumentView
   *   exportPath="/data/data/com.example/cache/test"
   * />
   */
  exportPath: PropTypes.string,

  /**
   * @memberof DocumentView
   * @category Open a Document
   * @type {string}
   * @optional
   * @description Android only.
   * 
   * Sets the cache folder used to cache PDF files opened using a http/https link, this defaults to the app cache path. 
   * @example
   * <DocumentView
   *   openUrlPath="/data/data/com.example/cache/test"
   * />
   */
  openUrlPath: PropTypes.string,

  /**
   * @memberof DocumentView
   * @type {Config.Tools[]}
   * @optional
   * @default Defaults to none.
   * @description Defines annotation types that cannot be edited after creation.
   * @example
   * <DocumentView
   *   disableEditingByAnnotationType={[Config.Tools.annotationCreateTextSquiggly, Config.Tools.annotationCreateEllipse]}
   * />
   */
  disableEditingByAnnotationType: arrayOf<Config.Tools>(Config.Tools),

  /**
   * @memberof DocumentView
   * @category Scroll
   * @type {boolean}
   * @optional 
   * @default false
   * @description iOS only.
   * 
   * Determines whether scrollbars will be hidden on the viewer.
   * @example
   * <DocumentView
   *   hideScrollbars={true}
   * />
   */
  hideScrollbars: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Open a Document
   * @type {boolean}
   * @optional 
   * @default true
   * @description Sets whether to remember the last visited page and zoom for a document if it gets opened again.
   * @example
   * <DocumentView
   *   saveStateEnabled={false}
   * />
   */
  saveStateEnabled: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @category Open a Document
   * @type {boolean}
   * @optional 
   * @default true
   * @description Android only.
   * 
   * Sets whether the new saved file should open after saving.
   * @example
   * <DocumentView
   *   openSavedCopyInNewTab={false}
   * />
   */
  openSavedCopyInNewTab: PropTypes.bool,

  /**
   * @memberof DocumentView
   * @type {Config.Tools[]}
   * @optional
   * @default Defaults to none.
   * @description
   * Defines types to be excluded from the annotation list. This feature will be soon be added to the official iOS release; to access it in the meantime, you can use the following podspec in the Podfile:
   * ```
   * pod 'PDFNet', podspec: 'https://nightly-pdftron.s3-us-west-2.amazonaws.com/stable/2021-08-04/9.0/cocoapods/xcframeworks/pdfnet/2021-08-04_stable_rev77892.podspec'
   * ```
   * 
   * and uncomment the following line in `ios/RNTPTDocumentView.m`:
   * ```objc
   * - (void)excludeAnnotationListTypes:(NSArray<NSString*> *)excludedAnnotationListTypes documentViewController:(PTDocumentBaseViewController *)documentViewController
   * {
   *     ...
   *     if (annotTypes.count > 0) {
   *         //documentViewController.navigationListsViewController.annotationViewController.excludedAnnotationTypes = annotTypes;
   *     }
   * }
   * ```
   * 
   * @example
   * <DocumentView
   *   excludedAnnotationListTypes={[Config.Tools.annotationCreateEllipse, Config.Tools.annotationCreateRectangle, Config.Tools.annotationCreateRedaction]}
   * />
   */
  excludedAnnotationListTypes: arrayOf<Config.Tools>(Config.Tools),

  /**
   * @memberof DocumentView
   * @type {boolean}
   * @optional
   * @default true
   * @description Android only.
   * 
   * Defines whether to show an annotation's reply review state.
   * @example
   * <DocumentView
   *   collabEnabled={true}
   *   currentUser={'Pdftron'}
   *   replyReviewStateEnabled={true}
   * />
   */
  replyReviewStateEnabled: PropTypes.bool,
  
  /**
   * @memberof DocumentView
   * @category Page
   * @event
   * @type {function}
   * @optional
   * @description This function is called when a page has been moved in the document.
   * @param {int} previousPageNumber the previous page number
   * @param {int} pageNumber the current page number
   * @example
   * <DocumentView
   *   onPageMoved = {({previousPageNumber, pageNumber}) => {
   *     console.log('Page moved from', previousPageNumber, 'to', pageNumber);
   *   }}
   * />
   */  
  onPageMoved: func<(event: {previousPageNumber: number, pageNumber: number}) => void>(),

  /**
   * @memberof DocumentView
   * @category Multi-tab
   * @event
   * @type {function}
   * @optional
   * @description The function is activated when a tab is changed. 
   * 
   * Please note that this API is meant for tab-specific changes. 
   * If you would like to know when the document finishes loading instead, see 
   * the {@link DocumentView.event:onDocumentLoaded onDocumentLoaded} event.
   * @param {string} currentTab The file path of current tab's document
   * @example
   * <DocumentView
   *   multiTabEnabled={true}
   *   onTabChanged={({currentTab}) => {
   *     console.log("The current tab is ", currentTab);
   *   }}
   * />
   */
  onTabChanged: func<(event: {currentTab: string}) => void>(),
  //...ViewPropTypes,
};

// Generates the prop types for TypeScript users, from PropTypes.
export type DocumentViewProps = PropTypes.InferProps<typeof DocumentViewPropTypes>;

/**
* Creates a custom PropType for functions.
*
* If the resulting PropType is used to generate prop types for TS users, 
* type checking for function parameters and return values will be provided.
* @returns {Requireable<T>} A custom PropType constant.
* @example
* func<(path: string) => void>()
* @ignore
*/
function func<T> () : Requireable<T> {
  
  let validator : Validator<T> = function (props: { [key: string]: any }, propName: string, componentName: string, location: string, propFullName: string) : Error | null {
    if (typeof props[propName] !== "function" && typeof props[propName] !== "undefined") {
      return new Error (`Invalid prop \`${propName}\` of type \`${typeof props[propName]}\` supplied to \`${componentName}\`, expected a function.`);
    }
    return null;
  }
  
  const t : Requireable<T> = validator as Requireable<T>;
  t.isRequired = validator as Validator<NonNullable<T>>;
  return t;
}

/** 
 * Creates a custom PropType representing any value from given object(s).
 * @param {object} obj An object containing values.
 * @param {...object} rest Indefinite number of other objects containing values.
 * @returns {Requireable<T>} A custom PropType constant.
 * @example
 * oneOf<Config.Tools>(Config.Tools)
 * oneOf<Config.Tools | Config.Buttons>(Config.Tools, Config.Buttons)
 * @ignore
 */
function oneOf<T>(obj: object, ...rest: object[]) : Requireable<T> {
  if (rest.length > 0) {
    return PropTypes.oneOf(Object.values(Object.assign({}, obj, ...rest)));
  }
  return PropTypes.oneOf(Object.values(obj));
}

/** 
 * Creates a custom PropType representing any array containing values from given object(s).
 * @param {object} obj An object containing values.
 * @param {...object} rest Indefinite number of other objects containing values.
 * @returns {Requireable<T[]>} A custom PropType constant.
 * @example
 * arrayOf<Config.Tools>(Config.Tools)
 * arrayOf<Config.Tools | Config.Buttons>(Config.Tools, Config.Buttons)
 * @ignore
*/
function arrayOf<T>(obj: object, ...rest: object[]) : Requireable<T[]> {
  return PropTypes.arrayOf(oneOf<T>(obj, ...rest)) as Requireable<T[]>;
}
/**
  * @class
  * @classdesc An all-in-one React component for displaying and editing documents of different types such as PDF, docx, pptx, xlsx and various image formats.
  * 
  * Due to the length of the source file, we have included links to the exact lines of the source code where these APIs have been implemented.
  * @hideconstructor
  */
 export class DocumentView extends PureComponent<DocumentViewProps, any> {

  _viewerRef: any;

  static propTypes = Object.assign(DocumentViewPropTypes, {...ViewPropTypes});

  onChange = (event: any) => {
    if (event.nativeEvent.onLeadingNavButtonPressed) {
      if (this.props.onLeadingNavButtonPressed) {
        this.props.onLeadingNavButtonPressed();
      }
    } else if (event.nativeEvent.onDocumentLoaded) {
      if (this.props.onDocumentLoaded) {
        this.props.onDocumentLoaded(event.nativeEvent.onDocumentLoaded);
      }
    } else if (event.nativeEvent.onPageChanged) {
      if (this.props.onPageChanged) {
        this.props.onPageChanged({
        	'previousPageNumber': event.nativeEvent.previousPageNumber,
        	'pageNumber': event.nativeEvent.pageNumber,
        });
      }
    } else if (event.nativeEvent.onScrollChanged) {
      if (this.props.onScrollChanged) {
        this.props.onScrollChanged({
        	'horizontal': event.nativeEvent.horizontal,
          'vertical': event.nativeEvent.vertical,
        });
      } 
    } else if (event.nativeEvent.onZoomChanged) {
      if (this.props.onZoomChanged) {
        this.props.onZoomChanged({
        	'zoom': event.nativeEvent.zoom,
        });
      }
    } else if (event.nativeEvent.onZoomFinished) {
      if (this.props.onZoomFinished) {
        this.props.onZoomFinished({
          'zoom': event.nativeEvent.zoom,
        });
      }
    } else if (event.nativeEvent.onLayoutChanged) {
      if (this.props.onLayoutChanged) {
        this.props.onLayoutChanged();
      }
    } else if (event.nativeEvent.onAnnotationChanged) {
      if (this.props.onAnnotationChanged) {
        this.props.onAnnotationChanged({
          'action': event.nativeEvent.action,
          'annotations': event.nativeEvent.annotations,
        });
      }
    } else if (event.nativeEvent.onAnnotationsSelected) {
    	if (this.props.onAnnotationsSelected) {
    		this.props.onAnnotationsSelected({
    			'annotations': event.nativeEvent.annotations,
    		});
    	}
    } else if (event.nativeEvent.onFormFieldValueChanged) {
      if (this.props.onFormFieldValueChanged) {
        this.props.onFormFieldValueChanged({
          'fields': event.nativeEvent.fields,
        });
      }
    } else if (event.nativeEvent.onDocumentError) {
      if (this.props.onDocumentError) {
        this.props.onDocumentError(event.nativeEvent.onDocumentError);
      } else {
        const msg = event.nativeEvent.onDocumentError ? event.nativeEvent.onDocumentError : 'Unknown error';
        Alert.alert(
          'Alert',
          msg,
          [
            { text: 'OK' }
          ],
          { cancelable: true }
        );
      }
    } else if (event.nativeEvent.onExportAnnotationCommand) {
      if (this.props.onExportAnnotationCommand) {
        this.props.onExportAnnotationCommand({
          'action': event.nativeEvent.action,
          'xfdfCommand': event.nativeEvent.xfdfCommand,
          'annotations': event.nativeEvent.annotations,
        });
      }
    } else if (event.nativeEvent.onAnnotationMenuPress) {
      if (this.props.onAnnotationMenuPress) {
        this.props.onAnnotationMenuPress({
          'annotationMenu': event.nativeEvent.annotationMenu,
          'annotations': event.nativeEvent.annotations,
        });
      }
    } else if (event.nativeEvent.onLongPressMenuPress) {
      if (this.props.onLongPressMenuPress) {
        this.props.onLongPressMenuPress({
          'longPressMenu': event.nativeEvent.longPressMenu,
          'longPressText': event.nativeEvent.longPressText,
        });
      }
    } else if (event.nativeEvent.onBehaviorActivated) {
      if (this.props.onBehaviorActivated) {
        this.props.onBehaviorActivated({
          'action': event.nativeEvent.action,
          'data': event.nativeEvent.data,
        });
      }
    } else if (event.nativeEvent.onBookmarkChanged) {
      if (this.props.onBookmarkChanged) {
        this.props.onBookmarkChanged({
          'bookmarkJson': event.nativeEvent.bookmarkJson,
        });
      }
    } else if (event.nativeEvent.onToolChanged) {
      if (this.props.onToolChanged) {
        this.props.onToolChanged({
          'previousTool': event.nativeEvent.previousTool,
          'tool': event.nativeEvent.tool,
        });
      }
    } else if (event.nativeEvent.onTextSearchStart) {
      if (this.props.onTextSearchStart) {
        this.props.onTextSearchStart();
      }
    } else if (event.nativeEvent.onTextSearchResult) {
      if (this.props.onTextSearchResult) {
        this.props.onTextSearchResult({
          'found': event.nativeEvent.found,
          'textSelection': event.nativeEvent.textSelection,
        });
      }
    } else if (event.nativeEvent.onUndoRedoStateChanged) {
      if (this.props.onUndoRedoStateChanged) {
        this.props.onUndoRedoStateChanged();
      }
    } else if (event.nativeEvent.onPageMoved) {
      if (this.props.onPageMoved) {
        this.props.onPageMoved({
          'previousPageNumber': event.nativeEvent.previousPageNumber,
          'pageNumber': event.nativeEvent.pageNumber,
        });
      }
    } else if (event.nativeEvent.onTabChanged) {
      if (this.props.onTabChanged) {
        this.props.onTabChanged({
          'currentTab' : event.nativeEvent.currentTab
        });
      }
    }
  }

  // Methods

  /**
   * @method
   * @description Returns the path of the current document. If {@link DocumentView.isBase64String isBase64String} is true, 
   * this would be the path to the temporary pdf file converted from the base64 string in {@link DocumentView.document document}.
   * @returns {Promise<void | string>} path - the document path. 
   * @example
   * this._viewer.getDocumentPath().then((path) => {
   *   console.log('The path to current document is: ' + path);
   * });
   */
  getDocumentPath = (): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getDocumentPath(tag);
    }
    return Promise.resolve();
  }
  
  /**
   * @method
   * @description Sets the current tool mode.
   * @param {string} toolMode One of {@link Config.Tools} constants, representing the tool mode to set.
   * @returns {Promise<void>}
   * @example
   * this._viewer.setToolMode(Config.Tools.annotationCreateFreeHand).then(() => {
   *   // done switching tools
   * });
   */
  setToolMode = (toolMode: Config.Tools): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
    	return DocumentViewManager.setToolMode(tag, toolMode);
    }
    return Promise.resolve();
  }

  /** 
   * @method 
   * @description Commits the current tool, only available for multi-stroke ink and poly-shape.
   * @returns {Promise<void | boolean>} committed - true if either ink or poly-shape tool is committed, false otherwise
   * @example
   * this._viewer.commitTool().then((committed) => {
   *   // committed: true if either ink or poly-shape tool is committed, false otherwise
   * });
   */
commitTool = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.commitTool(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Page
   * @description Gets the current page count of the document.
   * @returns {Promise<void | number>} pageCount - the current page count of the document
   * @example
   * this._viewer.getPageCount().then((pageCount) => {
   *   console.log('pageCount', pageCount);
   * });
   */
getPageCount = (): Promise<void | number> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageCount(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method 
   * @description Imports user bookmarks into the document. The input needs to be a valid bookmark JSON format.
   * @param {string} bookmarkJson needs to be in valid bookmark JSON format, for example {"0": "Page 1"}. The page numbers are 1-indexed
   * @returns {Promise<void>}
   * @example
   * this._viewer.importBookmarkJson("{\"0\": \"Page 1\", \"3\": \"Page 4\"}");
   */
importBookmarkJson = (bookmarkJson: string): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.importBookmarkJson(tag, bookmarkJson);
    }
    return Promise.resolve();
  }
  
  /** 
   * @method 
   * @description Displays the bookmark tab of the existing list container. 
   * If this tab has been disabled, the method does nothing.
   * @returns {Promise<void>}
   * @example
   * this._viewer.openBookmarkList();
   */
  openBookmarkList = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openBookmarkList(tag);
    }
    return Promise.resolve();
  }

  
/**
   * @method
   * @description Imports remote annotation command to local document.
   * @param {string} xfdfCommand the XFDF command string
   * @param {boolean} [initialLoad=false] whether this is for initial load.
   * @returns {Promise<void>}
   * @example
   * const xfdfCommand = '<?xml version="1.0" encoding="UTF-8"?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><add><circle style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20201218025606Z" flags="print" date="D:20201218025606Z" name="9d0f2d63-a0cc-4f06-b786-58178c4bd2b1" page="0" rect="56.4793,584.496,208.849,739.369" title="PDF" /></add><modify /><delete /><pdf-info import-version="3" version="2" xmlns="http://www.pdftron.com/pdfinfo" /></xfdf>';
   * this._viewer.importAnnotationCommand(xfdfCommand);
   */
  importAnnotationCommand = (xfdfCommand: string, initialLoad?: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      if (initialLoad === undefined) {
        initialLoad = false;
      }
      return DocumentViewManager.importAnnotationCommand(
        tag,
        xfdfCommand,
        initialLoad,
      );
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Imports XFDF annotation string to the current document.
   * @param {string} xfdf annotation string in XFDF format for import
   * @returns {Promise<void>}
   * @example
   * const xfdf = '<?xml version="1.0" encoding="UTF-8"?>\n<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">\n\t<annots>\n\t\t<circle style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20190729202215Z" flags="print" date="D:20190729202215Z" page="0" rect="138.824,653.226,236.28,725.159" title="" /></annots>\n\t<pages>\n\t\t<defmtx matrix="1.333333,0.000000,0.000000,-1.333333,0.000000,1056.000000" />\n\t</pages>\n\t<pdf-info version="2" xmlns="http://www.pdftron.com/pdfinfo" />\n</xfdf>';
   * this._viewer.importAnnotations(xfdf);
   */
importAnnotations = (xfdf: string): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.importAnnotations(tag, xfdf);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Extracts XFDF from the current document.
   * @param {object} options key: annotList, type: array. 
   * If specified, annotations with the matching id and pageNumber will be exported; 
   * otherwise, all annotations in the current document will be exported.
   * @returns {Promise<void | string>} xfdf - annotation string in XFDF format
   * @example <caption>Without options:</caption>
   * this._viewer.exportAnnotations().then((xfdf) => {
   *   console.log('XFDF for all annotations:', xfdf);
   * });
   * @example <caption>With options:</caption>
   * // annotList is an array of annotation data in the format {id: string, pageNumber: int}
   * const annotations = [{id: 'annot1', pageNumber: 1}, {id: 'annot2', pageNumber: 3}];
   * this._viewer.exportAnnotations({annotList: annotations}).then((xfdf) => {
   *   console.log('XFDF for 2 specified annotations', xfdf);
   * });
   */
exportAnnotations = (options?: {annotList: Array<AnnotOptions.Annotation>}): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.exportAnnotations(tag, options);
    }
    return Promise.resolve();
  }


/**
   * @method
   * @description Flattens the forms and (optionally) annotations in the current document.
   * @param {boolean} formsOnly Defines whether only forms are flattened. If false, all annotations will be flattened
   * @returns {Promise<void>}
   * @example
   * // flatten forms and annotations in the current document.
   * this._viewer.flattenAnnotations(false);
   */
  flattenAnnotations = (formsOnly: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.flattenAnnotations(tag, formsOnly);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Deletes the specified annotations in the current document.
   * @param {object[]} annotations Defines which annotation to be deleted. Each element is in the format {id: string, pageNumber: int}
   * @returns {Promise<void>}
   * @example
   * // delete annotations in the current document.
   * this._viewer.deleteAnnotations([
   *     {
   *         id: 'annotId1',
   *         pageNumber: 1,
   *     },
   *     {
   *         id: 'annotId2',
   *         pageNumber: 2,
   *     }
   * ]);
   */
deleteAnnotations = (annotations: Array<AnnotOptions.Annotation>): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.deleteAnnotations(tag, annotations);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Saves the current document. If {@link DocumentView.isBase64String isBase64String} is true, 
   * this would be the base64 string encoded from the temporary pdf file, which is created from the base64 string 
   * in {@link DocumentView.document document}.
   * @returns {Promise<void | string>} filePath - the location of the saved document, or the base64 string of the pdf in the case of base64
   * @example
   * this._viewer.saveDocument().then((filePath) => {
   *   console.log('saveDocument:', filePath);
   * });
   */
saveDocument = (): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.saveDocument(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Sets a field flag value on one or more form fields.
   * @param {string[]} fields list of field names for which the flag should be set
   * @param {int} flag flag to be set. Number should be a {@link Config.FieldFlags} constant
   * @param {bool} value value to set for flag
   * @returns {Promise<void>}
   * @example
   * this._viewer.setFlagForFields(['First Name', 'Last Name'], Config.FieldFlags.ReadOnly, true);
   */
setFlagForFields = (fields: Array<string>, flag: Config.FieldFlags, value: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.setFlagForFields(tag, fields, flag, value);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Get type and value information of a field using its name.
   * @param {string} fieldName name of the field
   * @returns {Promise<void | object>} field - an object with information keys: `fieldName`, `fieldValue` (undefined for fields with no values) and `fieldType`(one of button, checkbox, radio, text, choice,  signature and unknown), or undefined if such field does not exist
   * 
   * @example
   * this._viewer.getField('someFieldName').then((field) => {
   *   if (field !== undefined) {
   *     console.log('field name:', field.fieldName);
   *     console.log('field value:', field.fieldValue);
   *     console.log('field type:', field.fieldType);
   *   }
   * });
   */
getField = (fieldName: string): Promise<void | {fieldName: string, fieldValue?: any, fieldType?: string}> => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.getField(tag, fieldName);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Displays the annotation tab of the existing list container. If this tab has been disabled, the method does nothing.
   * @returns {Promise<void>}
   * @example
   * this._viewer.openAnnotationList();
   */
openAnnotationList = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.openAnnotationList(tag);
    }
    return Promise.resolve();
  }

/**
  * @method
  * @deprecated note: this function exists for supporting the old version. It simply calls {@link DocumentView#setValuesForFields setValuesForFields}.
  * @ignore
  */
   setValueForFields = (fieldsMap: Record<string, string | boolean | number>): Promise<void> => {
    return this.setValuesForFields(fieldsMap);
  }

  /** 
   * @method
   * @description Sets field values on one or more form fields.
   * 
   * Note: the old function `setValueForFields` is deprecated. Please use this one instead.
   * @param {object} fieldsMap map of field names and values which should be set
   * @returns {Promise<void>}
   * @example
   * this._viewer.setValuesForFields({
   *   'textField1': 'Test',
   *   'textField2': 1234,
   *   'checkboxField1': true,
   *   'checkboxField2': false,
   *   'radioButton1': 'Yes',
   *   'radioButton2': 'No'
   * });
   */
  setValuesForFields = (fieldsMap: Record<string, string | boolean | number>): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.setValuesForFields(tag, fieldsMap);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Handles the back button in search mode. Android only.
   * @returns {Promise<void | boolean>} handled - whether the back button is handled successfully
   * @example
   * this._viewer.handleBackButton().then((handled) => {
   *   if (!handled) {
   *     BackHandler.exitApp();
   *   }
   * });
   */
handleBackButton = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.handleBackButton(tag);
    }
    return Promise.resolve();
  }

  /**
  * @method
  * @deprecated note: this function exists for supporting the old version. It simply calls {@link DocumentView#setFlagsForAnnotations setFlagsForAnnotations}.
  * @ignore
  */
  setFlagForAnnotations = (annotationFlagList: Array<AnnotOptions.AnnotationFlag>): Promise<void> => {
    return this.setFlagsForAnnotations(annotationFlagList);  
  }
  
  /** 
   * @method
   * @description Sets flags for specified annotations in the current document. 
   * The `flagValue` controls whether a flag will be set to or removed from the annotation.
   * 
   * Note: the old function `setFlagForAnnotations` is deprecated. Please use this one.
   * 
   * @param {object[]} annotationFlagList A list of annotation flag operations. Each element is in the format {id: string, pageNumber: int, flag: One of {@link Config.AnnotationFlags} constants, flagValue: bool}
   * @returns {Promise<void>}
   * @example
   * //  Set flag for annotations in the current document.
   * this._viewer.setFlagsForAnnotations([
   *     {
   *         id: 'annotId1',
   *         pageNumber: 1,
   *         flag: Config.AnnotationFlags.noView,
   *         flagValue: true
   *     },
   *     {
   *         id: 'annotId2',
   *         pageNumber: 5,
   *         flag: Config.AnnotationFlags.lockedContents,
   *         flagValue: false
   *     }
   * ]);
   */
  setFlagsForAnnotations = (annotationFlagList: Array<AnnotOptions.AnnotationFlag>): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setFlagsForAnnotations(tag, annotationFlagList);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Selects the specified annotation in the current document.
   * @param {string} id the id of the target annotation
   * @param {integer} pageNumber the page number where the targe annotation is located. It is 1-indexed
   * @returns {Promise<void>}
   * @example
   * // select annotation in the current document.
   * this._viewer.selectAnnotation('annotId1', 1);
   */
selectAnnotation = (id: string, pageNumber: number): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.selectAnnotation(tag, id, pageNumber);
    }
    return Promise.resolve();
  }

/**
  * @method
  * @description
  * note: this function exists for supporting the old version. It simply calls setPropertiesForAnnotation.
  * @ignore
  */
  setPropertyForAnnotation = (id: string, pageNumber: number, propertyMap: AnnotOptions.AnnotationProperties): Promise<void> => {
    return this._viewerRef.setPropertiesForAnnotation(id, pageNumber, propertyMap);
  }

  /** 
   * @method
   * @description Sets properties for specified annotation in the current document, if it is valid.
   * 
   * Note: the old function `setPropertyForAnnotation` is deprecated. Please use this one.
   * 
   * @param {string} annotationId the unique id of the annotation
   * @param {integer} pageNumber the page number where annotation is located. It is 1-indexed
   * @param {object} propertyMap an object containing properties to be set. Available properties are listed below
   * 
   * Properties in propertyMap:
   * 
   * Name | Type | Markup exclusive | Example
   * --- | --- | --- | ---
   * rect | object | no | {x1: 1, y1: 2, x2: 3, y2: 4}
   * contents | string | no | "contents"
   * subject | string | yes | "subject"
   * title | string | yes | "title"
   * contentRect | object | yes | {x1: 1, y1: 2, x2: 3, y2: 4}
   * customData | object | no | {key: value}
   * strokeColor | object | no | {red: 255, green: 0, blue: 0}
   * 
   * @returns {Promise<void>}
   * @example
   * // Set properties for annotation in the current document.
   * this._viewer.setPropertiesForAnnotation('Pdftron', 1, {
   *   rect: {
   *     x1: 1.1,    // left
   *     y1: 3,      // bottom
   *     x2: 100.9,  // right
   *     y2: 99.8    // top
   *   },
   *   contents: 'Hello World',
   *   subject: 'Sample',
   *   title: 'set-prop-for-annot',
   *   customData: {
   *     key1: 'value1',
   *     key2: 'value2',
   *     key3: 'value3'
   *   },
   *   strokeColor: {
   *     "red": 255,
   *     "green": 0,
   *     "blue": 0
   *   }
   * });
   */
  setPropertiesForAnnotation = (id: string, pageNumber: number, propertyMap: AnnotOptions.AnnotationProperties): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setPropertiesForAnnotation(tag, id, pageNumber, propertyMap);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Gets properties for specified annotation in the current document, if it is valid. 
   * 
   * @param {string} annotationId the unique id of the annotation
   * @param {integer} pageNumber the page number where annotation is located. It is 1-indexed
   * @returns {Promise<void | object>} propertyMap - the non-null properties of the annotation
   * 
   * Name | Type | Markup exclusive | Example
   * --- | --- | --- | ---
   * rect | object | no | {x1: 1, y1: 1, x2: 2, y2: 2, width: 1, height: 1}
   * contents | string | no | "Contents"
   * subject | string | yes | "Subject"
   * title | string | yes | "Title"
   * contentRect | object | yes | {x1: 1, y1: 1, x2: 2, y2: 2, width: 1, height: 1}
   * strokeColor | object | no | {red: 255, green: 0, blue: 0}
   * @example
   * // Get properties for annotation in the current document.
   * this._viewer.getPropertiesForAnnotation('Pdftron', 1).then((properties) => {
   *   if (properties) {
   *     console.log('Properties for annotation: ', properties);
   *   }
   * })
   */
getPropertiesForAnnotation = (id: string, pageNumber: number): Promise<void | AnnotOptions.AnnotationProperties> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPropertiesForAnnotation(tag, id, pageNumber);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Sets whether all annotations and forms should be rendered. This method affects the viewer and does not change the document.
   * 
   * Unlike {@link DocumentView#setVisibilityForAnnotation setVisibilityForAnnotation}, this method is used to show and hide all annotations and forms in the viewer. 
   * @param {boolean} drawAnnotations whether all annotations and forms should be rendered
   * @returns {Promise<void>}
   * @example
   * this._viewer.setDrawAnnotations(false);
   */
setDrawAnnotations = (drawAnnotations: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setDrawAnnotations(tag, drawAnnotations);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Sets visibility for specified annotation in the current document, if it is valid. 
   * Note that if {@link DocumentView#setDrawAnnotations drawAnnotations} is set to false in the viewer, this function would not render the annotation even if visibility is true.
   * 
   * @param {string} annotationId the unique id of the annotation
   * @param {integer}pageNumber the page number where annotation is located. It is 1-indexed
   * @param {boolean }visibility whether the annotation should be visible
   * @returns {Promise<void>}
   * @example
   * this._viewer.setVisibilityForAnnotation('Pdftron', 1, true);
   */
setVisibilityForAnnotation = (id: string, pageNumber: number, visibility: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      DocumentViewManager.setVisibilityForAnnotation(tag, id, pageNumber, visibility);
    }
    return Promise.resolve();
  }
  
  /** 
   * @method
   * @description Enables or disables highlighting form fields. It is disabled by default.
   * @param {bool} highlightFields whether form fields should be highlighted
   * @example
   * this._viewer.setHighlightFields(true);
   */
  setHighlightFields = (highlightFields: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      DocumentViewManager.setHighlightFields(tag, highlightFields);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Gets an annotation at the (x, y) position in screen coordinates, if any.
   * @param {integer} x the x-coordinate of the point
   * @param {integer} y the y-coordinate of the point
   * @param {double} distanceThreshold maximum distance from the point (x, y) to the annotation for it to be considered a hit (in dp)
   * @param {double} minimumLineWeight For very thin lines, it is almost impossible to hit the actual line. This specifies a minimum line thickness (in screen coordinates) for the purpose of calculating whether a point is inside the annotation or not (in dp)
   * @returns {Promise<void | object>} annotation - the annotation found in the format of `{id: string, pageNumber: number, type: string, screenRect: {x1: number, y1: number, x2: number, y2: number, width: number, height: number}, pageRect: {x1: number, y1: number, x2: number, y2: number, width: number, height: number}}`. `type` is one of the {@link Config.Tools} constants. `screenRect` was formerly called `rect`.
   * @example
   * this._viewer.getAnnotationAtPoint(167, 287, 100, 10).then((annotation) => {
   *   if (annotation) {
   *     console.log('Annotation found at point (167, 287) has id:', annotation.id);
   *   }
   * })
   */
getAnnotationAtPoint = (x: number, y: number, distanceThreshold: number, minimumLineWeight: number): Promise<void | AnnotOptions.Annotation> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationAt(tag, x, y, distanceThreshold, minimumLineWeight);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Gets the list of annotations at a given line in screen coordinates. 
   * Note that this is not an area selection. It should be used similar 
   * to {@link DocumentView#getAnnotationAtPoint getAnnotationAtPoint}, except that this should 
   * be used when you want to get multiple annotations which are overlaying with each other.
   * @param {integer} x1 x-coordinate of an endpoint on the line
   * @param {integer} y1 y-coordinate of an endpoint on the line
   * @param {integer} x2 x-coordinate of the other endpoint on the line, usually used as a threshold
   * @param {integer} y2 y-coordinate of the other endpoint on the line, usually used as a threshold
   * @returns {Promise<void | object[]>} annotations - list of annotations at the target line, each in the format of `{id: string, pageNumber: number, type: string, screenRect: {x1: number, y1: number, x2: number, y2: number, width: number, height: number}, pageRect: {x1: number, y1: number, x2: number, y2: number, width: number, height: number}}`. `type` is one of the {@link Config.Tools} constants. `screenRect` was formerly called `rect`.
   * @example
   * this._viewer.getAnnotationListAt(0, 0, 200, 200).then((annotations) => {
   *   for (const annotation of annotations) {
   *     console.log('Annotation found at line has id:', annotation.id);
   *   }
   * })
   */
getAnnotationListAt = (x1: number, y1: number, x2: number, y2: number): Promise<void | Array<AnnotOptions.Annotation>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationListAt(tag, x1, y1, x2, y2);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Gets the list of annotations on a given page.
   * @param {integer} pageNumber the page number where annotations are located. It is 1-indexed
   * @returns {Promise<void | Array<object>>} annotations - list of annotations on the target page, each in the format of `{id: string, pageNumber: number, type: string, screenRect: {x1: number, y1: number, x2: number, y2: number, width: number, height: number}, pageRect: {x1: number, y1: number, x2: number, y2: number, width: number, height: number}}`. `type` is one of the {@link Config.Tools} constants. `screenRect` was formerly called `rect`.
   * @example
   * this._viewer.getAnnotationsOnPage(2).then((annotations) => {
   *   for (const annotation of annotations) {
   *     console.log('Annotation found on page 2 has id:', annotation.id);
   *   }
   * })
   */
getAnnotationsOnPage = (pageNumber: number): Promise<void | Array<AnnotOptions.Annotation>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationListOnPage(tag, pageNumber);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Gets an annotation's `customData` property.
   * @param {string} annotationId the unique id of the annotation
   * @param {integer} pageNumber the page number where annotation is located. It is 1-indexed
   * @param {string} key the unique key associated with the `customData` property
   * @returns {Promise<void | string>} value - the `customData` property associated with the given key
   * @example
   * this._viewer.setPropertiesForAnnotation("annotation1", 2, {
   *   customData: {
   *     data: "Nice annotation"
   *   }
   * }).then(() => {
   *   this._viewer.getCustomDataForAnnotation("annotation1", 2, "data").then((value) => {
   *     console.log(value === "Nice annotation");
   *   })
   * })
   */
getCustomDataForAnnotation = (annotationID: string, pageNumber: number, key: string): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getCustomDataForAnnotation(tag, annotationID, pageNumber, key);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Page
   * @description Gets the crop box for specified page as a JSON object.
   * @param pageNumber | integer | the page number for the target crop box. It is 1-indexed
   * @returns {Promise<void | object>} cropBox - an object with information about position (`x1`, `y1`, `x2` and `y2`) and size (`width` and `height`)
   * @example
   * this._viewer.getPageCropBox(1).then((cropBox) => {
   *   console.log('bottom-left coordinate:', cropBox.x1, cropBox.y1);
   *   console.log('top-right coordinate:', cropBox.x2, cropBox.y2);
   *   console.log('width and height:', cropBox.width, cropBox.height);
   * });
   */
getPageCropBox = (pageNumber: number): Promise<void | AnnotOptions.CropBox> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageCropBox(tag, pageNumber);
    }
    return Promise.resolve();
  }

/**
   * @method
   * @category Page
   * @description Sets current page of the document.
   * @param {integer} pageNumber the page number to be set as the current page; 1-indexed
   * @returns {Promise<void | boolean>} success - whether the setting process was successful
   * @example
   * this._viewer.setCurrentPage(4).then((success) => {
   *   if (success) {
   *     console.log("Current page is set to 4.");
   *   }
   * });
   */
  setCurrentPage = (pageNumber: number): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setCurrentPage(tag, pageNumber);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Page
   * @description Gets the visible pages in the current viewer as an array.
   * @returns {Promise<void | Array<number>>} visiblePages - a list of visible pages in the current viewer
   * @example
   * this._viewer.getVisiblePages().then((visiblePages) => {
   *   for (const page of visiblePages) {
   *     console.log('page', page, 'is visible.')
   *   }
   * });
   */
getVisiblePages = (): Promise<void | Array<number>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getVisiblePages(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Page
   * @description Go to the previous page of the document. If on first page, it would stay on first page.
   * @returns {Promise<void | boolean>} success - whether the setting process was successful (no change due to staying in first page counts as being successful)
   * @example
   * this._viewer.gotoPreviousPage().then((success) => {
   *   if (success) {
   *     console.log("Go to previous page.");
   *   }
   * });
   */
gotoPreviousPage = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoPreviousPage(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Page
   * @description Go to the next page of the document. If on last page, it would stay on last page.
   * @returns {Promise<void | boolean>} success - whether the setting process was successful (no change due to staying in last page counts as being successful)
   * @example
   * this._viewer.gotoNextPage().then((success) => {
   *   if (success) {
   *     console.log("Go to next page.");
   *   }
   * });
   */
gotoNextPage = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoNextPage(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Page
   * @description Go to the first page of the document.
   * @returns {Promise<void | boolean>} success - whether the setting process was successful
   * @example
   * this._viewer.gotoFirstPage().then((success) => {
   *   if (success) {
   *     console.log("Go to first page.");
   *   }
   * });
   */
gotoFirstPage = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoFirstPage(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Page
   * @description Go to the last page of the document.
   * @returns {Promise<void | boolean>} success - whether the setting process was successful
   * @example
   * this._viewer.gotoLastPage().then((success) => {
   *   if (success) {
   *     console.log("Go to last page.");
   *   }
   * });
   */
gotoLastPage = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoLastPage(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Page
   * @description Opens a go-to page dialog. If the user inputs a valid page number into the dialog, the viewer will go to that page.
   * @returns {Promise<void>}
   * @example
   * this._viewer.showGoToPageView();
   */
showGoToPageView = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.showGoToPageView(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Multi-tab
   * @description Closes all tabs in a multi-tab environment.
   * @returns {Promise<void>}
   * @example
   * // Do this only when DocumentView has multiTabEnabled = true
   * this._viewer.closeAllTabs();
   */
closeAllTabs = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.closeAllTabs(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Multi-tab
   * @description Opens the tab switcher in a multi-tab environment.
   * @returns {Promise<void>}
   * @example
   * // Do this only when DocumentView has multiTabEnabled = true
   * this._viewer.openTabSwitcher();
   */
openTabSwitcher = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openTabSwitcher(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Zoom
   * @description Returns the current zoom scale of current document viewer.
   * @returns {Promise<void | number>} zoom - current zoom scale in the viewer
   * @example
   * this._viewer.getZoom().then((zoom) => {
   *   console.log('Zoom scale of the current document is:', zoom);
   * });
   */
getZoom = (): Promise<void | number> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getZoom(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Zoom
   * @description Sets the minimum and maximum zoom bounds of current viewer.
   * @param {string} zoomLimitMode one of the constants in {@link Config.ZoomLimitMode}, defines whether bounds are relative to the standard zoom scale in the current viewer or absolute
   * @param {double} minimum the lower bound of the zoom limit range
   * @param {double} maximum the upper bound of the zoom limit range
   * @returns {Promise<void>}
   * @example
   * this._viewer.setZoomLimits(Config.ZoomLimitMode.Absolute, 1.0, 3.5);
   */
setZoomLimits = (zoomLimitMode: Config.ZoomLimitMode, minimum: number, maximum: number): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setZoomLimits(tag, zoomLimitMode, minimum, maximum);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Zoom
   * @description Sets the zoom scale in the current document viewer with a zoom center.
   * @param {double} zoom the zoom ratio to be set
   * @param {int} x the x-coordinate of the zoom center
   * @param {int} y the y-coordinate of the zoom center
   * @returns {Promise<void>}
   * @example
   * this._viewer.zoomWithCenter(3.0, 100, 300);
   */
zoomWithCenter = (zoom: number, x: number, y: number): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.zoomWithCenter(tag, zoom, x, y);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Zoom
   * @description Zoom the viewer to a specific rectangular area in a page.
   * @param {int} pageNumber the page number of the zooming area (1-indexed)
   * @param {map} rect The rectangular area with keys x1 (left), y1(bottom), y1(right), y2(top). Coordinates are in double
   * @returns {Promise<void>}
   * @example
   * this._viewer.zoomToRect(3, {'x1': 1.0, 'y1': 2.0, 'x2': 3.0, 'y2': 4.0});
   */
zoomToRect = (pageNumber: number, rect: AnnotOptions.Rect): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.zoomToRect(tag, pageNumber, rect);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Zoom
   * @description Zoom to a paragraph that contains the specified coordinate. If no paragraph contains the coordinate, the zooming would not happen.
   * @param {int} x the x-coordinate of the target coordinate
   * @param {int} y the y-coordinate of the target coordinate
   * @param {bool} animated whether the transition is animated
   * @returns {Promise<void>}
   * @example
   * this._viewer.smartZoom(100, 200, true);
   */
smartZoom = (x: number, y: number, animated: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.smartZoom(tag, x, y, animated);
    }
    return Promise.resolve();
  }
  
  /** 
   * @method
   * @category Scroll
   * @description Returns the horizontal and vertical scroll position of current document viewer.
   * @returns {Promise<void | object>} 
   * 
   * Name | Type | Description
   * --- | --- | ---
   * horizontal | number | current horizontal scroll position
   * vertical | number | current vertical scroll position
   * 
   * @example
   * this._viewer.getScrollPos().then(({horizontal, vertical}) => {
   *   console.log('Current horizontal scroll position is:', horizontal);
   *   console.log('Current vertical scroll position is:', vertical);
   * });
   */
  getScrollPos = (): Promise<void | {horizontal: number, vertical: number}> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getScrollPos(tag);
    }
    return Promise.resolve();
  }
    
  /** 
   * @method
   * @description Returns the canvas size of current document viewer.
   * @returns {Promise<void | object>}
   * 
   * Name | Type | Description
   * --- | --- | ---
   * width | number | current width of canvas
   * height | number | current height of canvas
   * 
   * @example
   * this._viewer.getCanvasSize().then(({width, height}) => {
   *   console.log('Current canvas width is:', width);
   *   console.log('Current canvas height is:', height);
   * });
   */
  getCanvasSize = (): Promise<void | {width: number, height: number}> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getCanvasSize(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Page
   * @description Gets the rotation value of all pages in the current document.
   * @returns {Promise<void | number>} pageRotation - the rotation degree of all pages, one of 0, 90, 180 or 270 (clockwise).
   * @example
   * this._viewer.getPageRotation().then((pageRotation) => {
   *   console.log('The current page rotation degree is' + pageRotation);
   * });
   */
getPageRotation = (): Promise<void | AnnotOptions.RotationDegree> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageRotation(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Page
   * @description Rotates all pages in the current document in clockwise direction (by 90 degrees).
   * @returns {Promise<void>}
   * @example
   * this._viewer.rotateClockwise();
   */
rotateClockwise = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.rotateClockwise(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Page
   * @description Rotates all pages in the current document in counter-clockwise direction (by 90 degrees).
   * @returns {Promise<void>}
   * @example
   * this._viewer.rotateCounterClockwise();
   */
rotateCounterClockwise = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.rotateCounterClockwise(tag);
    }
    return Promise.resolve();
  }

  /**
   * @method
   * @description Converts points from screen coordinates to page coordinates in the viewer.
   * @param {object[]} points list of points, each in the format `{x: number, y: number}`. You could optionally have a `pageNumber: number` in the object. Without specifying, the page system is referring to the current page
   * @returns {Promise<void | object[]>} convertedPoints - list of converted points in page system, each in the format `{x: number, y: number}`. It would be empty if conversion is unsuccessful
   * @example
   * // convert (50, 50) and (100, 100) from screen system to page system, on current page and page 1 respectively
   * this._viewer.convertScreenPointsToPagePoints([{x: 50, y: 50}, {x: 100, y:100, pageNumber: 1}]).then((convertedPoints) => {
   *   convertedPoints.forEach(point => {
   *     console.log(point);
   *   })
   * }); 
   */
  convertScreenPointsToPagePoints = (points: Array<AnnotOptions.Point>): Promise<void | Array<AnnotOptions.Point>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.convertScreenPointsToPagePoints(tag, points);
    }
    return Promise.resolve();
  }

  /**
   * @method
   * @description Converts points from page coordinates to screen coordinates in the viewer.
   * @param {object[]} points list of points, each in the format `{x: number, y: number}`. You could optionally have a `pageNumber: number` in the object. Without specifying, the page system is referring to the current page
   * @returns {Promise<void | object[]>} convertedPoints - list of converted points in screen system, each in the format `{x: number, y: number}`. It would be empty if conversion is unsuccessful
   * @example
   * // convert (50, 50) on current page and (100, 100) on page 1 from page system to screen system
   * this._viewer.convertPagePointsToScreenPoints([{x: 50, y: 50}, {x: 100, y:100, pageNumber: 1}]).then((convertedPoints) => {
   *   convertedPoints.forEach(point => {
   *     console.log(point);
   *   })
   * });
   */
  convertPagePointsToScreenPoints = (points: Array<AnnotOptions.Point>): Promise<void | Array<AnnotOptions.Point>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.convertPagePointsToScreenPoints(tag, points);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Returns the page number that contains the point on screen.
   * @param {number} x the x-coordinate of the screen point
   * @param {number} y the y-coordinate of the screen point
   * @returns {Promise<void | number>} pageNumber - the page number of the screen point
   * @example
   * this._viewer.getPageNumberFromScreenPoint(10.0,50.5).then((pageNumber) => {
   *   console.log('The page number of the screen point is', pageNumber);
   * });
   */
getPageNumberFromScreenPoint = (x: number, y: number): Promise<void | number> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageNumberFromScreenPoint(tag, x, y);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Sets whether the control will render progressively or will just draw once the entire view has been rendered.
   * @param {boolean} progressiveRendering whether to render progressively
   * @param {number} initialDelay delay before the progressive rendering timer is started, in milliseconds
   * @param {number} interval delay between refreshes, in milliseconds
   * @returns {Promise<void>}
   * @example
   * // delay for 10s before start, and refresh every 1s
   * this._viewer.setProgressiveRendering(true, 10000, 1000);
   */
setProgressiveRendering = (progressiveRendering: boolean, initialDelay: number, interval: number): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setProgressiveRendering(tag, progressiveRendering, initialDelay, interval);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Enables or disables image smoothing. The rasterizer allows a trade-off between rendering quality and rendering speed. This function can be used to indicate the preference between rendering speed and quality.
   * @param {boolean} imageSmoothing whether to enable image smoothing
   * @returns {Promise<void>}
   * @example
   * this._viewer.setImageSmoothing(false);
   */
setImageSmoothing = (imageSmoothing: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setImageSmoothing(tag, imageSmoothing);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Enables or disables support for overprint and overprint simulation. Overprint is a device dependent feature and the results will vary depending on the output color space and supported colorants (i.e. CMYK, CMYK+spot, RGB, etc).
   * @param {string} overprint the mode of overprint, should be a {@link Config.OverprintMode} constant
   * @returns {Promise<void>}
   * @example
   * this._viewer.setOverprint(Config.OverprintMode.Off);
   */
setOverprint = (overprint: Config.OverprintMode): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setOverprint(tag, overprint);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category UI Customization
   * @description Sets the color post processing transformation mode for the viewer.
   * @param {string} colorPostProcessMode color post processing transformation mode, should be a {@link Config.ColorPostProcessMode} constant
   * @example
   * this._viewer.setColorPostProcessMode(Config.ColorPostProcessMode.NightMode);
   */
setColorPostProcessMode = (colorPostProcessMode: Config.ColorPostProcessMode): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      DocumentViewManager.setColorPostProcessMode(tag, colorPostProcessMode);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category UI Customization
   * @description Sets the white and black color for the color post processing transformation.
   * @param {object} whiteColor the white color for the color post processing transformation, in the format `{red: number, green: number, blue: number}`. `alpha` could be optionally included (only Android would apply alpha), and all numbers should be in range [0, 255]
   * @param {object} blackColor the black color for the color post processing transformation, in the same format as whiteColor
   * @example
   * const whiteColor = {"red": 0, "green": 0, "blue": 255};
   * const blackColor = {"red": 255, "green": 0, "blue": 0};
   * this._viewer.setColorPostProcessColors(whiteColor, blackColor);
   */
setColorPostProcessColors = (whiteColor: AnnotOptions.Color, blackColor: AnnotOptions.Color): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setColorPostProcessColors(tag, whiteColor, blackColor);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Search for a term and all matching results will be highlighted.
   * @param {string} searchString the text to search for
   * @param {boolean} matchCase indicates if it is case sensitive
   * @param {boolean} matchWholeWord indicates if it matches an entire word only
   * @returns {Promise<void>}
   * @example
   * this._viewer.startSearchMode('PDFTron', false, false);
   */
startSearchMode = (searchString: string, matchCase: boolean, matchWholeWord: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.startSearchMode(tag, searchString, matchCase, matchWholeWord);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Finishes the current text search and remove all the highlights.
   * @returns {Promise<void>}
   * @example
   * this._viewer.exitSearchMode();
   */
exitSearchMode = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.exitSearchMode(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Searches asynchronously, starting from the current page, for the given text. PDFViewCtrl automatically scrolls to the position so that the found text is visible.
   * @param {string} searchString the text to search for
   * @param {bool} matchCase indicates if it is case sensitive
   * @param {bool} matchWholeWord indicates if it matches an entire word only
   * @param {bool} searchUp indicates if it searches upward
   * @param {bool} regExp indicates if searchString is a regular expression
   * @returns {Promise<void>}
   * @example
   * this._viewer.findText('PDFTron', false, false, true, false);
   */
findText = (searchString: string, matchCase: boolean, matchWholeWord: boolean, searchUp: boolean, regExp: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.findText(tag, searchString, matchCase, matchWholeWord, searchUp, regExp);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Cancels the current text search thread, if exists.
   * @returns {Promise<void>}
   * @example
   * this._viewer.cancelFindText();
   */
cancelFindText = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.cancelFindText(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Displays a search bar that allows the user to enter and search text within a document.
   * @returns {Promise<void>}
   * @example
   * this._viewer.openSearch();
   */
openSearch = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openSearch(tag);
    }
    return Promise.resolve();
  }
  
  /** 
   * @method
   * @description Returns the text selection on a given page, if any.
   * @param {number} pageNumber the specified page number. It is 1-indexed
   * @returns {Promise<void | object>} selection - the text selection, in the format `{html: string, unicode: string, pageNumber: number, quads: [[{x: number, y: number}, {x: number, y: number}, {x: number, y: number}, {x: number, y: number}], ...]}`. If no such selection could be found, this would be null
   * 
   * Quads indicate the quad boundary boxes for the selection, which could have a size larger than 1 if selection spans across different lines. Each quad have 4 points with x, y coordinates specified in number, representing a boundary box. The 4 points are in counter-clockwise order, though the first point is not guaranteed to be on lower-left relatively to the box.
   * @example
   * this._viewer.getSelection(2).then((selection) => {
   *   if (selection) {
   *     console.log('Found selection on page', selection.pageNumber);
   *     for (let i = 0; i < selection.quads.length; i ++) {
   *       const quad = selection.quads[i];
   *       console.log('selection boundary quad', i);
   *       for (const quadPoint of quad) {
   *         console.log('A quad point has coordinates', quadPoint.x, quadPoint.y);
   *       }
   *     }
   *   }
   * });
   */
  getSelection = (pageNumber: number): Promise<void | AnnotOptions.TextSelectionResult> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getSelection(tag, pageNumber);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Returns whether there is a text selection in the current document.
   * @returns {Promise<void | boolean>} hasSelection - whether a text selection exists
   * @example
   * this._viewer.hasSelection().then((hasSelection) => {
   *   console.log('There is a selection in the document.');
   * });
   */
hasSelection = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.hasSelection(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Clears any text selection in the current document.
   * @returns {Promise<void>}
   * @example
   * this._viewer.clearSelection();
   */
clearSelection = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.clearSelection(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Returns the page range (beginning and end) that has text selection on it.
   * @returns {Promise<void | object>}
   * 
   * Name | Type | Description
   * --- | --- | ---
   * begin | number | the first page to have selection, -1 if there are no selections
   * end | number | the last page to have selection,  -1 if there are no selections
   * 
   * @example
   * this._viewer.getSelectionPageRange().then(({begin, end}) => {
   *   if (begin === -1) {
   *     console.log('There is no selection');
   *   } else {
   *     console.log('The selection range is from', begin, 'to', end);
   *   }
   * });
   */
getSelectionPageRange = (): Promise<void | {begin: number, end: number}> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getSelectionPageRange(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Returns whether there is a text selection on the specified page in the current document.
   * @param {number} pageNumber the specified page number. It is 1-indexed
   * @returns {Promise<void | boolean>} hasSelection - whether a text selection exists on the specified page
   * @example
   * this._viewer.hasSelectionOnPage(5).then((hasSelection) => {
   *   if (hasSelection) {
   *     console.log('There is a selection on page 5 in the document.');
   *   }
   * });
   */
hasSelectionOnPage = (pageNumber: number): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.hasSelectionOnPage(tag, pageNumber);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Selects the text within the given rectangle region.
   * @param {object} rect the rectangle region in the format of `{x1: number, x2: number, y1: number, y2: number}`
   * @returns {Promise<void | boolean>} selected - whether there is text selected
   * @example
   * this._viewer.selectInRect({x1: 0, y1: 0, x2: 200.5, y2: 200.5}).then((selected) => {
   *         console.log(selected);
   * });
   */

  selectInRect = (rect: AnnotOptions.Rect): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.selectInRect(tag, rect);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Returns whether there is text in given rectangle region.
   * @param {object} rect the rectangle region in the format of `{x1: number, x2: number, y1: number, y2: number}`
   * @returns {Promise<void | boolean>} hasText - whether there is text in the region
   * @example
   * this._viewer.isThereTextInRect({x1: 0, y1: 0, x2: 200, y2: 200}).then((hasText) => {
   *         console.log(hasText);
   * });
   */
isThereTextInRect = (rect: AnnotOptions.Rect): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.isThereTextInRect(tag, rect);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Selects all text on the page.
   * @returns {Promise<void>}
   * @example
   * this._viewer.selectAll();
   */
selectAll = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.selectAll(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Sets whether borders of each page are visible in the viewer, which is disabled by default.
   * @param {boolean} pageBorderVisibility whether borders of each page are visible in the viewer
   * @example
   * this._viewer.setPageBorderVisibility(true);
   */
setPageBorderVisibility = (pageBorderVisibility: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.setPageBorderVisibility(tag, pageBorderVisibility);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Enables or disables transparency grid (check board pattern) to reflect page transparency, which is disabled by default.
   * @param {boolean} pageTransparencyGrid whether to use the transparency grid
   * @example
   * this._viewer.setPageTransparencyGrid(true);
   */
setPageTransparencyGrid = (pageTransparencyGrid: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setPageTransparencyGrid(tag, pageTransparencyGrid);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Sets the default page color of the viewer.
   * @param {object} defaultPageColor the default page color, in the format `{red: number, green: number, blue: number}`, each number in range [0, 255]
   * @example
   * this._viewer.setDefaultPageColor({red: 0, green: 255, blue: 0}); // green color
   */
setDefaultPageColor = (defaultPageColor: AnnotOptions.Color): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.setDefaultPageColor(tag, defaultPageColor);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Sets the background color of the viewer.
   * @param {object} backgroundColor the background color, in the format `{red: number, green: number, blue: number}`, each number in range [0, 255]
   * @example
   * this._viewer.setBackgroundColor({red: 0, green: 0, blue: 255}); // blue color
   */
setBackgroundColor = (backgroundColor: AnnotOptions.Color): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setBackgroundColor(tag, backgroundColor);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Export a PDF page to image format defined in {@link Config.ExportFormat}.
   * @param {int} pageNumber the page to be converted
   * @param {double} dpi the output image resolution
   * @param {string} exportFormat one of the {@link Config.ExportFormat} constants
   * @returns {Promise<void | string>} path - the temp path of the created image, user is responsible for clean up the cache
   * @example
   * this._viewer.exportToImage(1, 92, Config.ExportFormat.BMP).then((path) => {
   *   console.log('export', path);
   * });
   */
exportAsImage = (pageNumber: number, dpi: number, exportFormat: Config.ExportFormat): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.exportAsImage(tag, pageNumber, dpi, exportFormat);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Undo the last modification.
   * @returns {Promise<void>}
   * @example
   * this._viewer.undo();
   */
undo = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.undo(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Redo the last modification.
   * @returns {Promise<void>}
   * @example
   * this._viewer.redo();
   */
redo = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.redo(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Checks whether an undo operation can be performed from the current snapshot.
   * @returns {Promise<void | boolean>} canUndo - whether it is possible to undo from the current snapshot
   * @example
   * this._viewer.canUndo().then((canUndo) => {
   *   console.log(canUndo ? 'undo possible' : 'no action to undo');
   * });
   */
canUndo = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.canUndo(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Checks whether a redo operation can be perfromed from the current snapshot.
   * @returns {Promise<void | boolean>} canRedo - whether it is possible to redo from the current snapshot
   * @example
   * this._viewer.canRedo().then((canRedo) => {
   *   console.log(canRedo ? 'redo possible' : 'no action to redo');
   * });
   */
canRedo = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.canRedo(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Displays the page crop option. Android only.
   * @returns {Promise<void>}
   * @example
   * this._viewer.showCrop();
   */
showCrop = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.showCrop(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Sets the current {@link DocumentView.annotationToolbars annotationToolbars} for the viewer.
   * @param {string} toolbar the toolbar to enable. Should be one of the {@link Config.DefaultToolbars} constants or the `id` of a custom toolbar object.
   * @returns {Promise<void>}
   * @example
   * this._viewer.setCurrentToolbar(Config.DefaultToolbars.Insert).then(() => {
   *   // done switching toolbar
   * });
   */
setCurrentToolbar = (toolbar: string): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.setCurrentToolbar(tag, toolbar);
    }
    return Promise.resolve();
  }
  
  /** 
   * @method
   * @description Displays the view settings.
   * 
   * Requires a source rect in screen co-ordinates. On iOS this rect will be the anchor point for the view. The rect is ignored on Android.
   * @param {map} rect The rectangular area in screen co-ordinates with keys x1 (left), y1(bottom), y1(right), y2(top). Coordinates are in double format.
   * @returns {Promise<void>}
   * @example
   * this._viewer.showViewSettings({'x1': 10.0, 'y1': 10.0, 'x2': 20.0, 'y2': 20.0});
   */
  showViewSettings = (rect: AnnotOptions.Rect): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
        return DocumentViewManager.showViewSettings(tag, rect);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Page
   * @description Displays a rotate dialog. Android only.
   * 
   * The dialog allows users to rotate pages of the opened document by 90, 180 and 270 degrees. It also displays a thumbnail of the current page at the selected rotation angle.
   * @returns {Promise<void>}
   * @example
   * this._viewer.showRotateDialog();
   */
showRotateDialog = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.showRotateDialog(tag);
    }
    return Promise.resolve();
  }
  
  /**
   * @method
   * @description Displays the add pages view.
   * 
   * Requires a source rect in screen co-ordinates. On iOS this rect will be the anchor point for the view. The rect is ignored on Android.
   * @param {map} rect The rectangular area in screen co-ordinates with keys `x1` (left), `y1` (bottom), `y1` (right), `y2`(top). Coordinates are in double format.
   * @returns {Promise<void>}
   * @example
   * this._viewer.showAddPagesView({'x1': 10.0, 'y1': 10.0, 'x2': 20.0, 'y2': 20.0});
   */
  showAddPagesView = (rect: AnnotOptions.Rect): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
        return DocumentViewManager.showAddPagesView(tag, rect);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Reflow
   * @description Returns whether the viewer is currently in reflow mode.
   * @returns {Promise<void | boolean>} inReflow - whether the viewer is in reflow mode
   * @example
   * this._viewer.isReflowMode().then((inReflow) => {
   *   console.log(inReflow ? 'in reflow mode' : 'not in reflow mode');
   * });
   */
isReflowMode = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
        return DocumentViewManager.isReflowMode(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @category Reflow
   * @description Allows the user to programmatically enter and exit reflow mode.
   * @returns {Promise<void>}
   * @example
   * this._viewer.toggleReflow();
   */
toggleReflow = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.toggleReflow(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Displays the share copy view.
   * 
   * Requires a source rect in screen co-ordinates. On iOS this rect will be the anchor point for the view. The rect is ignored on Android.
   * @returns {Promise<void>}
   * @param {map} rect The rectangular area in screen co-ordinates with keys x1 (left), y1(bottom), y1(right), y2(top). Coordinates are in double format.
   * @param {boolean} flattening Whether the shared copy should be flattened before sharing.
   * @example
   * this._viewer.shareCopy({'x1': 10.0, 'y1': 10.0, 'x2': 20.0, 'y2': 20.0}, true);
   */
shareCopy = (rect: AnnotOptions.Rect, flattening: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
        return DocumentViewManager.shareCopy(tag, rect, flattening);
    }
    return Promise.resolve();
  }
 
  /**
   * @method
   * @description Display a page thumbnails view. 
   * 
   * This view allows users to navigate pages of a document. If {@link DocumentView.thumbnailViewEditingEnabled thumbnailViewEditingEnabled} is true, the user can also manipulate the document, including add, remove, re-arrange, rotate and duplicate pages.
   * @returns {Promise<void>}
   * @example
   * this._viewer.openThumbnailsView();
   */
  openThumbnailsView = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.openThumbnailsView(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description Displays the outline tab of the existing list container. If this tab has been disabled, the method does nothing.
   * @returns {Promise<void>}
   * @example
   * this._viewer.openOutlineList();
   */
openOutlineList = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openOutlineList(tag);
    }
    return Promise.resolve();
  }

  /** 
   * @method
   * @description On Android it displays the layers dialog while on iOS it displays the layers tab of the existing list container. If this tab has been disabled or there are no layers in the document, the method does nothing.
   * 
   * **Note** For proper functionality the PDFNet podspec with: https://nightly-pdftron.s3-us-west-2.amazonaws.com/stable/2021-07-16/9.0/cocoapods/pdfnet/2021-07-16_stable_rev77863.podspec
   * @returns {Promise<void>}
   * @example
   * this._viewer.openLayersList();
   */
openLayersList = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openLayersList(tag);
    }
    return Promise.resolve();
  }

/**
   * @method
   * @description Displays the existing list container. Its current tab will be the one last opened. 
   * @returns {Promise<void>}
   * @example
   * this._viewer.openNavigationLists();
   */
  openNavigationLists = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openNavigationLists(tag);
    }
    return Promise.resolve();
  }

  /**
   * @method
   * @description Gets a list of absolute file paths to PDFs containing the saved signatures.
   * @returns {Promise<void | Array<string>>} signatures - an array of string containing the absolute file paths; if there are no saved signatures, the value is an empty array
   * @example
   * this._viewer.getSavedSignatures().then((signatures) => {
   *   if (signatures.length > 0) {
   *     signatures.forEach((signature) => {
   *       console.log(signature);
   *     });
   *   }
   * }) 
   */
  getSavedSignatures = (): Promise<void | Array<string>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.getSavedSignatures(tag);
    }
    return Promise.resolve();
  }

  /**
   * @method
   * @description Retrieves the absolute file path to the folder containing the saved signatures
   * @returns {Promise<void | string>} path - the absolute file path to the folder
   * @example
   * this._viewer.getSavedSignatureFolder().then((path) => {
   *   if (path != null) {
   *     console.log(path);
   *   }
   * })
   */
  getSavedSignatureFolder = (): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.getSavedSignatureFolder(tag);
    }
    return Promise.resolve();
  }

  /** @ignore */
  _setNativeRef = (ref: any) => {
    this._viewerRef = ref;
  };

  /**
   * @ignore
   * 
   */
  render() {
    return (
      // @ts-ignore
      <RCTDocumentView
        ref={this._setNativeRef}
        // @ts-ignore
        style={{ flex:1 }}
        // @ts-ignore: Intentionally exclude `onChange` from being exposed as a prop.
        onChange={this.onChange}
        {...this.props}
      />
    )
  }
}

const name = Platform.OS === 'ios' ? 'RNTPTDocumentView' : 'RCTDocumentView';

const RCTDocumentView = requireNativeComponent(name);
