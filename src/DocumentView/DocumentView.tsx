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
 * For Contributors: The propTypes interface below contains PropTypes types for 
 * the {@link DocumentView} class.
 * It is also used to generate custom types for TS users.
 * 
 * To represent functions, please use {@link func}.
 * To represent "one of Config.Buttons values" or "an array of 
 * Config.Buttons values", please use {@link oneOf} or {@link arrayOf}.
 */

/** 
 * @interface
 * @description This object outlines valid {@link DocumentView} class props. 
 * These can be passed into {@link DocumentView} to customize the viewer.
 */
export const propTypes = {
  /**
   * @type {string}
   * @description The path or url to the document. Required.
   * @example
   * <DocumentView
   *   document={'https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_about.pdf'}
   * />
   */
  document: PropTypes.string.isRequired,
  /**
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
   * @type {number}
   * @optional
   * @description Defines the currently displayed page number. Different from {@link propTypes.initialPageNumber}, changing this prop value at runtime will change the page accordingly. 
   * @example
   * <DocumentView
   *   pageNumber={5}
   * />
   */
  pageNumber: PropTypes.number,

  /**
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
   * @type {string}
   * @optional
   * @description The file name of the icon to be used for the leading navigation button. The button will use the specified icon if it is valid, and the default icon otherwise. 
   * 
   * **Note**: to add the image file to your application, please follow the steps below:
   * 
   * ##### Android
   * 1. Add the image resource to the drawable directory in [`example/android/app/src/main/res`](./example/android/app/src/main/res). For details about supported file types and potential compression, check out [here](https://developer.android.com/guide/topics/graphics/drawables#drawables-from-images).
   * 
   * <img alt='demo-android' src='https://pdftron.s3.amazonaws.com/custom/websitefiles/react-native/android_add_resources.png'/>
   * 
   * 2. Now you can use the image in the viewer. For example, if you add `button_close.png` to drawable, you could use `'button_close'` in leadingNavButtonIcon.
   * 
   * ##### iOS
   * 1. After pods has been installed, open the `.xcworkspace` file for this application in Xcode (in this case, it's [`example.xcworkspace`](./example/ios/example.xcworkspace)), and navigate through the list below. This would allow you to add resources, in this case, an image, to your project.
   * - "Project navigator"
   * - "example" (or the app name)
   * - "Build Phases"
   * - "Copy Bundle Resources"
   * - "+".
   * 
   * <img alt='demo-ios' src='https://pdftron.s3.amazonaws.com/custom/websitefiles/react-native/ios_add_resources.png'/>
   * 
   * 2. Now you can use the image in the viewer. For example, if you add `button_open.png` to the bundle, you could use `'button_open.png'` in leadingNavButtonIcon.
   * 
   * @example
   * <DocumentView
   *   leadingNavButtonIcon={Platform.OS === 'ios' ? 'ic_close_black_24px.png' : 'ic_arrow_back_white_24dp'}
   * />
   */
  leadingNavButtonIcon: PropTypes.string,

  /**
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
   * @event
   * @type {function}
   * @optional
   * @description This function is called when the page number has been changed.
   * @param {object} event
   * @param {int} event.previousPageNumber the previous page number
   * @param {int} event.pageNumber the current page number
   * @example
   * <DocumentView
   *   onPageChanged = {({previousPageNumber, pageNumber}) => {
   *     console.log('Page number changes from', previousPageNumber, 'to', pageNumber);
   *   }}
   * />
   */  
  onPageChanged: func<(event: {previousPageNumber: number, pageNumber: number}) => void>(),

  /**
   * @event
   * @type {function}
   * @optional
   * @description This function is called when the scroll position has been changed.
   * @param {object} event
   * @param {number} event.horizontal the horizontal position of the scroll
   * @param {number} event.vertical the vertical position of the scroll
   * @example
   * <DocumentView
   *   onScrollChanged = {({horizontal, vertical}) => {
   *     console.log('Current scroll position is', horizontal, 'horizontally, and', vertical, 'vertically.');
   *   }}
   * />
   */  
  onScrollChanged: func<(event: {horizontal: number, vertical: number}) => void>(),
  
  /**
   * @event
   * @type {function}
   * @optional
   * @description This function is called when the zoom scale has been changed.
   * @param {object} event
   * @param {double} event.zoom the current zoom ratio of the document
   * @example
   * <DocumentView
   *   onZoomChanged = {(zoom) => {
   *     console.log('Current zoom ratio is', zoom);
   *   }}
   * />
   */  
  onZoomChanged: func<(event: {zoom: number}) => void>(),

  /**
   * @event
   * @type {function}
   * @optional
   * @description This function is called when a zooming has been finished. For example, if zoom via gesture, this is called on gesture release.
   * @param {object} event
   * @param {number} event.zoom the current zoom ratio of the document
   * @example (temp)
   */  
  onZoomFinished: func<(event: {zoom: number}) => void>(),
  
  /**
   * @type {number}
   * @optional
   */
  zoom: PropTypes.number,

  /**
   * @type {string[]}
   * @optional
   * @description Array of [`Config.Buttons`](./src/Config/Config.js) constants, defaults to none.
   * 
   * Defines buttons to be disabled for the viewer.
   * @example
   * <DocumentView
   *   disabledElements={[Config.Buttons.userBookmarkListButton]}
   * />
   */
  disabledElements: arrayOf<Config.Buttons>(Config.Buttons),

  /**
   * @type {string[]}
   * @optional
   * @description Array of [`Config.Tools`](./src/Config/Config.js) constants, defaults to none.
   * 
   * Defines tools to be disabled for the viewer.
   * @example
   * <DocumentView
   *   disabledTools={[Config.Tools.annotationCreateLine, Config.Tools.annotationCreateRectangle]}
   * />
   */
  disabledTools: arrayOf<Config.Tools>(Config.Tools),

  /**
   * @type {string[]}
   * @optional
   * @description Array of [`Config.LongPressMenu`](./src/Config/Config.js) constants, default contains all the items
   * 
   * Defines menu items that can show when long press on text or blank space.
   * @example
   * <DocumentView
   *   longPressMenuItems={[Config.LongPressMenu.copy, Config.LongPressMenu.read]}
   * />
   */
  longPressMenuItems: arrayOf<Config.LongPressMenu>(Config.LongPressMenu),

  /**
   * @type {string[]}
   * @optional
   * @description Array of [`Config.LongPressMenu`](./src/Config/Config.js) constants, defaults to none.
   * 
   * Defines the menu items on long press that will skip default behavior when pressed. They will still be displayed in the long press menu, and the function {onLongPressMenuPress}`](#onLongPressMenuPress) will be called where custom behavior can be implemented.
   * @example
   * <DocumentView
   *   overrideLongPressMenuBehavior={[Config.LongPressMenu.search]}
   * />
   */
  overrideLongPressMenuBehavior: arrayOf<Config.LongPressMenu>(Config.LongPressMenu),
  
  /**
   * @event
   * @type {function}
   * @optional
   * @description This function is called if the pressed long press menu item is passed in to [`overrideLongPressMenuBehavior`](#overrideLongPressMenuBehavior)
   * @param {object} event
   * @param {string} longPressMenu One of [`Config.LongPressMenu`](./src/Config/Config.js) constants, representing which item has been pressed
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
   * @type {string[]}
   * @optional
   * @description Array of [`Config.AnnotationMenu`](./src/Config/Config.js) constants, default contains all the items.
   * 
   * Defines the menu items that can show when an annotation is selected.
   * @example
   * <DocumentView
   *   annotationMenuItems={[Config.AnnotationMenu.search, Config.AnnotationMenu.share]}
   * />
   */
  annotationMenuItems: arrayOf<Config.AnnotationMenu>(Config.AnnotationMenu),

  /** 
   * @type {string[]}
   * @optional
   * @description Array of [`Config.AnnotationMenu`](./src/Config/Config.js) constants, defaults to none.
   * 
   * Defines the menu items that will skip default behavior when pressed. They will still be displayed in the annotation menu, and the function [`onAnnotationMenuPress`](#onAnnotationMenuPress) will be called where custom behavior can be implemented.
   * @example 
   * <DocumentView
   *   overrideAnnotationMenuBehavior={[Config.AnnotationMenu.copy]}
   * />
   */
  overrideAnnotationMenuBehavior: arrayOf<Config.AnnotationMenu>(Config.AnnotationMenu),
  
  /**
   * @event
   * @type {function}
   * @optional
   * @description This function is called when an annotation menu item passed in to [`overrideAnnotationMenuBehavior`](#overrideAnnotationMenuBehavior) is pressed.
   * @param {string} annotationMenu One of [`Config.AnnotationMenu`](./src/Config/Config.js) constants, representing which item has been pressed
   * @param {object[]} annotations An array of `{id: string, pageNumber: number, type: string, screenRect: object, pageRect: object}` objects.
   * 
   * `id` is the annotation identifier and `type` is one of the [`Config.Tools`](./src/Config/Config.js) constants. 
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
   * @type {string[]}
   * @optional
   * @description Array of [`Config.Tools`](./src/Config/Config.js) constants, optional, defaults to none
   * 
   * Defines annotation types that will not show in the annotation (long-press) menu.
   * @example 
   * <DocumentView
   *   hideAnnotationMenu={[Config.Tools.annotationCreateArrow, Config.Tools.annotationEraserTool]}
   * />
   */
  hideAnnotationMenu: arrayOf<Config.Tools>(Config.Tools),

  /**
   * @type {string[]}
   * @optional
   * @description Array of [`Config.Actions`](./src/Config/Config.js) constants, defaults to none
   * 
   * Defines actions that will skip default behavior, such as external link click. The function [`onBehaviorActivated`](#onBehaviorActivated) will be called where custom behavior can be implemented, whenever the defined actions occur.
   * @example
   * <DocumentView
   *   overrideBehavior={[Config.Actions.linkPress]}
   * />
   */
  overrideBehavior: arrayOf<Config.Actions>(Config.Actions),
  
  /**
   * @event
   * @type {function}
   * @optional
   * @description This function is called if the activated behavior is passed in to [`overrideBehavior`](#overrideBehavior)
   * @param {string} action One of [`Config.Actions`](./src/Config/Config.js) constants, representing which action has been activated
   * @param {object} data A JSON object that varies depending on the action.
   * 
   * If action is `Config.Actions.linkPress`, data type is `{url: string}`.
   * 
   * If action is `Config.Actions.stickyNoteShowPopUp`, data type is `{id: string, pageNumber: number, type: string, screenRect: {x1: number, y1: number, x2: number, y2: number, width: number, height: number}, pageRect: {x1: number, y1: number, x2: number, y2: number, width: number, height: number}}`, 
   * where `type` is one of the [`Config.Tools`](./src/Config/Config.js) constants, and `screenRect` was formerly called `rect`.
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
   * @type {boolean}
   * @optional
   * @default true
   * @deprecated Use [`hideTopAppNavBar`](#hideTopAppNavBar) prop instead.
   */
  topToolbarEnabled: PropTypes.bool,

  /**
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
   * @event
   * @type {function}
   * @optional
   * @description This function is called when an annotation(s) is selected.
   * @param {object} event
   * @param {object[]} annotations array of annotation data in the format `{id: string, pageNumber: number, type: string, screenRect: {x1: number, y1: number, x2: number, y2: number, width: number, height: number}, pageRect: {x1: number, y1: number, x2: number, y2: number, width: number, height: number}}`, representing the selected annotations. Type is one of the [`Config.Tools`](./src/Config/Config.js) constants. `screenRect` was formerly called `rect`.
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
   * @event
   * @type {function}
   * @optional
   * @description This function is called if a change has been made to an annotation(s) in the current document.
   * @param {object} event 
   * @param {string} event.action the action that occurred (add, delete, modify)
   * @param {object[]} event.annotations array of annotation data in the format `{id: string, pageNumber: number, type: string}`, representing the annotations that have been changed. `type` is one of the [`Config.Tools`](./src/Config/Config.js) constants
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
   * @event
   * @type {function}
   * @optional
   * @description This function is called if a change has been made to form field values.
   * @param {object} event
   * @param {object[]} event.fields array of field data in the format `{fieldName: string, fieldType: string, fieldValue: any}`, representing the fields that have been changed
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
   * @type {string}
   * @optional
   * @default 'FitWidth'
   * @description One of the [`Config.FitMode`](./src/Config/Config.js) constants.
   * 
   * Defines the fit mode (default zoom level) of the viewer.
   * @example
   * <DocumentView
   *   fitMode={Config.FitMode.FitPage}
   * />
   */
  fitMode: oneOf<Config.FitMode>(Config.FitMode),

  /**
   * @type {string}
   * @optional
   * @default 'Continuous'
   * @description One of the [`Config.LayoutMode`](./src/Config/Config.js) constants.
   * 
   * Defines the layout mode of the viewer.
   * @example
   * <DocumentView
   *   layoutMode={Config.LayoutMode.FacingContinuous}
   * />
   */
  layoutMode: oneOf<Config.LayoutMode>(Config.LayoutMode),

  /**
   * @event
   * @type {function}
   * @optional
   * @description (temp)
   * @example (temp)
   */  
  onLayoutChanged: func<() => void>(),
  padStatusBar: PropTypes.bool,
  continuousAnnotationEditing: PropTypes.bool,
  selectAnnotationAfterCreation: PropTypes.bool,
  annotationAuthor: PropTypes.string,
  showSavedSignatures: PropTypes.bool,
  isBase64String: PropTypes.bool,
  collabEnabled: PropTypes.bool,
  currentUser: PropTypes.string,
  currentUserName: PropTypes.string,

  /**
   * @event
   * @type {function}
   * @optional
   * @description (temp)
   * @example (temp)
   */  
  onExportAnnotationCommand: func<(event: {action: string, xfdfCommand: string, annotations: Array<AnnotOptions.Annotation>}) => void>(),
  autoSaveEnabled: PropTypes.bool,
  pageChangeOnTap: PropTypes.bool,
  followSystemDarkMode: PropTypes.bool,
  useStylusAsPen: PropTypes.bool,
  multiTabEnabled: PropTypes.bool,
  tabTitle: PropTypes.string,
  maxTabCount: PropTypes.number,
  signSignatureFieldsWithStamps: PropTypes.bool,
  annotationPermissionCheckEnabled: PropTypes.bool,
  annotationToolbars: PropTypes.arrayOf(PropTypes.oneOfType([
    oneOf<Config.DefaultToolbars>(Config.DefaultToolbars),
    PropTypes.exact({
      id: PropTypes.string.isRequired,
      name: PropTypes.string.isRequired,
      icon: oneOf<Config.ToolbarIcons>(Config.ToolbarIcons).isRequired,
      items: arrayOf<Config.Tools | Config.Buttons>(Config.Tools, Config.Buttons).isRequired
    })
  ])),
  hideDefaultAnnotationToolbars: arrayOf<Config.DefaultToolbars>(Config.DefaultToolbars),
  topAppNavBarRightBar: arrayOf<Config.Buttons>(Config.Buttons),
  bottomToolbar: arrayOf<Config.Buttons>(Config.Buttons),
  hideAnnotationToolbarSwitcher: PropTypes.bool,
  hideTopToolbars: PropTypes.bool,
  hideTopAppNavBar: PropTypes.bool,
  /**
   * @event
   * @type {function}
   * @optional
   * @description (temp)
   * @example (temp)
   */  
  onBookmarkChanged: func<(event: {bookmarkJson: string}) => void>(),
  hideThumbnailFilterModes: arrayOf<Config.ThumbnailFilterMode>(Config.ThumbnailFilterMode),

  /**
   * @event
   * @type {function}
   * @optional
   * @description (temp)
   * @example (temp)
   */  
  onToolChanged: func<(event: {previousTool: Config.Tools | "unknown tool", tool: Config.Tools | "unknown tool"}) => void>(),
  horizontalScrollPos: PropTypes.number,
  verticalScrollPos: PropTypes.number,

  /**
   * @event
   * @type {function}
   * @optional
   * @description (temp)
   * @example (temp)
   */  
  onTextSearchStart: func<() => void>(),

  /**
   * @event
   * @type {function}
   * @optional
   * @description (temp)
   * @example (temp)
   */  
  onTextSearchResult: func<(event: {found: boolean, textSelection: AnnotOptions.TextSelectionResult | null}) => void>(),
  hideViewModeItems: arrayOf<Config.ViewModePickerItem>(Config.ViewModePickerItem),
  pageStackEnabled: PropTypes.bool,
  showQuickNavigationButton: PropTypes.bool,
  photoPickerEnabled: PropTypes.bool,
  autoResizeFreeTextEnabled: PropTypes.bool,
  annotationsListEditingEnabled: PropTypes.bool,
  showNavigationListAsSidePanelOnLargeDevices: PropTypes.bool,
  restrictDownloadUsage: PropTypes.bool,
  userBookmarksListEditingEnabled: PropTypes.bool,
  imageInReflowEnabled: PropTypes.bool,
  reflowOrientation: oneOf<Config.ReflowOrientation>(Config.ReflowOrientation),
  
  /**
   * @event
   * @type {function}
   * @optional
   * @description (temp)
   * @example (temp)
   */  
  onUndoRedoStateChanged: func<() => void>(),
  tabletLayoutEnabled: PropTypes.bool,
  initialToolbar: PropTypes.string,
  inkMultiStrokeEnabled: PropTypes.bool,
  defaultEraserType: oneOf<Config.EraserType>(Config.EraserType),
  exportPath: PropTypes.string,
  openUrlPath: PropTypes.string,
  disableEditingByAnnotationType: arrayOf<Config.Tools>(Config.Tools),
  hideScrollbars: PropTypes.bool,
  saveStateEnabled: PropTypes.bool,
  openSavedCopyInNewTab: PropTypes.bool,
  excludedAnnotationListTypes: arrayOf<Config.Tools>(Config.Tools),
  replyReviewStateEnabled: PropTypes.bool,
  
  /**
   * @event
   * @type {function}
   * @optional
   * @description (temp)
   * @example (temp)
   */  
  onPageMoved: func<(event: {previousPageNumber: number, pageNumber: number}) => void>(),
  //...ViewPropTypes,
};

// Generates the prop types for TypeScript users, from PropTypes.
export type DocumentViewProps = PropTypes.InferProps<typeof propTypes>;

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
  * @hideconstructor
  */
 export class DocumentView extends PureComponent<DocumentViewProps, any> {

  _viewerRef: any;

  /**
   * Properties to pass into {@link DocumentView}. See {@link propTypes} for the full list of properties and their documentation.
   */
  static propTypes = Object.assign(propTypes, {...ViewPropTypes});

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
    }
  }

  // Methods

  /**
   * @method
   * @description Returns the path of the current document. If {@link propTypes.document document} is true, this would be the path to the temporary pdf file converted from the base64 string in {@link propTypes.document document}.
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
 * @param {string} toolMode One of [`Config.Tools`](./src/Config/Config.js) constants, representing the tool mode to set.
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

  /** @method */
commitTool = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.commitTool(tag);
    }
    return Promise.resolve();
  }

  /** @method */
getPageCount = (): Promise<void | number> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageCount(tag);
    }
    return Promise.resolve();
  }

  /** @method */
importBookmarkJson = (bookmarkJson: string): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.importBookmarkJson(tag, bookmarkJson);
    }
    return Promise.resolve();
  }
  
  /** @method */
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

  /** @method */
importAnnotations = (xfdf: string): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.importAnnotations(tag, xfdf);
    }
    return Promise.resolve();
  }

  /** @method */
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

  /** @method */
deleteAnnotations = (annotations: Array<AnnotOptions.Annotation>): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.deleteAnnotations(tag, annotations);
    }
    return Promise.resolve();
  }

  /** @method */
saveDocument = (): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.saveDocument(tag);
    }
    return Promise.resolve();
  }

  /** @method */
setFlagForFields = (fields: Array<string>, flag: Config.FieldFlags, value: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.setFlagForFields(tag, fields, flag, value);
    }
    return Promise.resolve();
  }

  /** @method */
getField = (fieldName: string): Promise<void | {fieldName: string, fieldValue?: any, fieldType?: string}> => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.getField(tag, fieldName);
    }
    return Promise.resolve();
  }

  /** @method */
openAnnotationList = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.openAnnotationList(tag);
    }
    return Promise.resolve();
  }

/**
  * @method
  * note: this function exists for supporting the old version. It simply calls setValuesForFields.
  * 
  */
   setValueForFields = (fieldsMap: Record<string, string | boolean | number>): Promise<void> => {
    return this.setValuesForFields(fieldsMap);
  }

  /** @method */
  setValuesForFields = (fieldsMap: Record<string, string | boolean | number>): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.setValuesForFields(tag, fieldsMap);
    }
    return Promise.resolve();
  }

  /** @method */
handleBackButton = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.handleBackButton(tag);
    }
    return Promise.resolve();
  }

  /**
  * @method
  * @description Sets flags for specified annotations in the current document. The `flagValue` controls whether a flag will be set to or removed from the annotation.
  * Note: the old function `setFlagForAnnotations` is deprecated. Please use this one.
  * 
  * @param {object} annotationFlagList A list of annotation flag operations. Each element is in the format {id: string, pageNumber: int, flag: One of AnnotationFlags constants, flagValue: bool}
  * @returns {Promise<void>}
  * 
  */
  setFlagForAnnotations = (annotationFlagList: Array<AnnotOptions.AnnotationFlag>): Promise<void> => {
    return this.setFlagsForAnnotations(annotationFlagList);  
  }
  
  /** @method */
  setFlagsForAnnotations = (annotationFlagList: Array<AnnotOptions.AnnotationFlag>): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setFlagsForAnnotations(tag, annotationFlagList);
    }
    return Promise.resolve();
  }

  /** @method */
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
  * 
  */
  setPropertyForAnnotation = (id: string, pageNumber: number, propertyMap: AnnotOptions.AnnotationProperties): Promise<void> => {
    return this._viewerRef.setPropertiesForAnnotation(id, pageNumber, propertyMap);
  }

  /** @method */
  setPropertiesForAnnotation = (id: string, pageNumber: number, propertyMap: AnnotOptions.AnnotationProperties): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setPropertiesForAnnotation(tag, id, pageNumber, propertyMap);
    }
    return Promise.resolve();
  }

  /** @method */
getPropertiesForAnnotation = (id: string, pageNumber: number): Promise<void | AnnotOptions.AnnotationProperties> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPropertiesForAnnotation(tag, id, pageNumber);
    }
    return Promise.resolve();
  }

  /** @method */
setDrawAnnotations = (drawAnnotations: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setDrawAnnotations(tag, drawAnnotations);
    }
    return Promise.resolve();
  }

  /** @method */
setVisibilityForAnnotation = (id: string, pageNumber: number, visibility: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      DocumentViewManager.setVisibilityForAnnotation(tag, id, pageNumber, visibility);
    }
    return Promise.resolve();
  }
  
  /** @method */
  setHighlightFields = (highlightFields: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      DocumentViewManager.setHighlightFields(tag, highlightFields);
    }
    return Promise.resolve();
  }

  /** @method */
getAnnotationAtPoint = (x: number, y: number, distanceThreshold: number, minimumLineWeight: number): Promise<void | AnnotOptions.Annotation> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationAt(tag, x, y, distanceThreshold, minimumLineWeight);
    }
    return Promise.resolve();
  }

  /** @method */
getAnnotationListAt = (x1: number, y1: number, x2: number, y2: number): Promise<void | Array<AnnotOptions.Annotation>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationListAt(tag, x1, y1, x2, y2);
    }
    return Promise.resolve();
  }

  /** @method */
getAnnotationsOnPage = (pageNumber: number): Promise<void | Array<AnnotOptions.Annotation>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationListOnPage(tag, pageNumber);
    }
    return Promise.resolve();
  }

  /** @method */
getCustomDataForAnnotation = (annotationID: string, pageNumber: number, key: string): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getCustomDataForAnnotation(tag, annotationID, pageNumber, key);
    }
    return Promise.resolve();
  }

  /** @method */
getPageCropBox = (pageNumber: number): Promise<void | AnnotOptions.CropBox> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageCropBox(tag, pageNumber);
    }
    return Promise.resolve();
  }

/**
   * @method
   * @description Sets current page of the document.
   * @param {integer} pageNumber the page number to be set as the current page; 1-indexed
   * @returns {boolean} whether the setting process was successful
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

  /** @method */
getVisiblePages = (): Promise<void | Array<number>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getVisiblePages(tag);
    }
    return Promise.resolve();
  }

  /** @method */
gotoPreviousPage = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoPreviousPage(tag);
    }
    return Promise.resolve();
  }

  /** @method */
gotoNextPage = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoNextPage(tag);
    }
    return Promise.resolve();
  }

  /** @method */
gotoFirstPage = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoFirstPage(tag);
    }
    return Promise.resolve();
  }

  /** @method */
gotoLastPage = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoLastPage(tag);
    }
    return Promise.resolve();
  }

  /** @method */
showGoToPageView = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.showGoToPageView(tag);
    }
    return Promise.resolve();
  }

  /** @method */
closeAllTabs = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.closeAllTabs(tag);
    }
    return Promise.resolve();
  }

  /** @method */
openTabSwitcher = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openTabSwitcher(tag);
    }
    return Promise.resolve();
  }

  /** @method */
getZoom = (): Promise<void | number> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getZoom(tag);
    }
    return Promise.resolve();
  }

  /** @method */
setZoomLimits = (zoomLimitMode: Config.ZoomLimitMode, minimum: number, maximum: number): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setZoomLimits(tag, zoomLimitMode, minimum, maximum);
    }
    return Promise.resolve();
  }

  /** @method */
zoomWithCenter = (zoom: number, x: number, y: number): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.zoomWithCenter(tag, zoom, x, y);
    }
    return Promise.resolve();
  }

  /** @method */
zoomToRect = (pageNumber: number, rect: AnnotOptions.Rect): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.zoomToRect(tag, pageNumber, rect);
    }
    return Promise.resolve();
  }

  /** @method */
smartZoom = (x: number, y: number, animated: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.smartZoom(tag, x, y, animated);
    }
    return Promise.resolve();
  }
  
  /** @method */
  getScrollPos = (): Promise<void | {horizontal: number, vertical: number}> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getScrollPos(tag);
    }
    return Promise.resolve();
  }
    
  /** @method */
  getCanvasSize = (): Promise<void | {width: number, height: number}> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getCanvasSize(tag);
    }
    return Promise.resolve();
  }

  /** @method */
getPageRotation = (): Promise<void | AnnotOptions.RotationDegree> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageRotation(tag);
    }
    return Promise.resolve();
  }

  /** @method */
rotateClockwise = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.rotateClockwise(tag);
    }
    return Promise.resolve();
  }

  /** @method */
rotateCounterClockwise = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.rotateCounterClockwise(tag);
    }
    return Promise.resolve();
  }

  /** @method */
  convertScreenPointsToPagePoints = (points: Array<AnnotOptions.PointWithPage>): Promise<void | Array<AnnotOptions.Point>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.convertScreenPointsToPagePoints(tag, points);
    }
    return Promise.resolve();
  }

  /** @method */
convertPagePointsToScreenPoints = (points: Array<AnnotOptions.PointWithPage>): Promise<void | Array<AnnotOptions.Point>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.convertPagePointsToScreenPoints(tag, points);
    }
    return Promise.resolve();
  }

  /** @method */
getPageNumberFromScreenPoint = (x: number, y: number): Promise<void | number> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageNumberFromScreenPoint(tag, x, y);
    }
    return Promise.resolve();
  }

  /** @method */
setProgressiveRendering = (progressiveRendering: boolean, initialDelay: number, interval: number): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setProgressiveRendering(tag, progressiveRendering, initialDelay, interval);
    }
    return Promise.resolve();
  }

  /** @method */
setImageSmoothing = (imageSmoothing: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setImageSmoothing(tag, imageSmoothing);
    }
    return Promise.resolve();
  }

  /** @method */
setOverprint = (overprint: Config.OverprintMode): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setOverprint(tag, overprint);
    }
    return Promise.resolve();
  }

  /** @method */
setColorPostProcessMode = (colorPostProcessMode: Config.ColorPostProcessMode): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      DocumentViewManager.setColorPostProcessMode(tag, colorPostProcessMode);
    }
    return Promise.resolve();
  }

  /** @method */
setColorPostProcessColors = (whiteColor: AnnotOptions.Color, blackColor: AnnotOptions.Color): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setColorPostProcessColors(tag, whiteColor, blackColor);
    }
    return Promise.resolve();
  }

  /** @method */
startSearchMode = (searchString: string, matchCase: boolean, matchWholeWord: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.startSearchMode(tag, searchString, matchCase, matchWholeWord);
    }
    return Promise.resolve();
  }

  /** @method */
exitSearchMode = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.exitSearchMode(tag);
    }
    return Promise.resolve();
  }

  /** @method */
findText = (searchString: string, matchCase: boolean, matchWholeWord: boolean, searchUp: boolean, regExp: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.findText(tag, searchString, matchCase, matchWholeWord, searchUp, regExp);
    }
    return Promise.resolve();
  }

  /** @method */
cancelFindText = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.cancelFindText(tag);
    }
    return Promise.resolve();
  }

  /** @method */
openSearch = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openSearch(tag);
    }
    return Promise.resolve();
  }
  
  /** @method */
  getSelection = (pageNumber: number): Promise<void | AnnotOptions.TextSelectionResult> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getSelection(tag, pageNumber);
    }
    return Promise.resolve();
  }

  /** @method */
hasSelection = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.hasSelection(tag);
    }
    return Promise.resolve();
  }

  /** @method */
clearSelection = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.clearSelection(tag);
    }
    return Promise.resolve();
  }

  /** @method */
getSelectionPageRange = (): Promise<void | {begin: number, end: number}> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getSelectionPageRange(tag);
    }
    return Promise.resolve();
  }

  /** @method */
hasSelectionOnPage = (pageNumber: number): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.hasSelectionOnPage(tag, pageNumber);
    }
    return Promise.resolve();
  }

  /** @method */

  selectInRect = (rect: AnnotOptions.Rect): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.selectInRect(tag, rect);
    }
    return Promise.resolve();
  }

  /** @method */
isThereTextInRect = (rect: AnnotOptions.Rect): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.isThereTextInRect(tag, rect);
    }
    return Promise.resolve();
  }

  /** @method */
selectAll = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.selectAll(tag);
    }
    return Promise.resolve();
  }

  /** @method */
setPageBorderVisibility = (pageBorderVisibility: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.setPageBorderVisibility(tag, pageBorderVisibility);
    }
    return Promise.resolve();
  }

  /** @method */
setPageTransparencyGrid = (pageTransparencyGrid: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setPageTransparencyGrid(tag, pageTransparencyGrid);
    }
    return Promise.resolve();
  }

  /** @method */
setDefaultPageColor = (defaultPageColor: AnnotOptions.Color): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.setDefaultPageColor(tag, defaultPageColor);
    }
    return Promise.resolve();
  }

  /** @method */
setBackgroundColor = (backgroundColor: AnnotOptions.Color): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setBackgroundColor(tag, backgroundColor);
    }
    return Promise.resolve();
  }

  /** @method */
exportAsImage = (pageNumber: number, dpi: number, exportFormat: Config.ExportFormat): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.exportAsImage(tag, pageNumber, dpi, exportFormat);
    }
    return Promise.resolve();
  }

  /** @method */
undo = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.undo(tag);
    }
    return Promise.resolve();
  }

  /** @method */
redo = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.redo(tag);
    }
    return Promise.resolve();
  }

  /** @method */
canUndo = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.canUndo(tag);
    }
    return Promise.resolve();
  }

  /** @method */
canRedo = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.canRedo(tag);
    }
    return Promise.resolve();
  }

  /** @method */
showCrop = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.showCrop(tag);
    }
    return Promise.resolve();
  }

  /** @method */
setCurrentToolbar = (toolbar: string): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.setCurrentToolbar(tag, toolbar);
    }
    return Promise.resolve();
  }
  
  /** @method */
  showViewSettings = (rect: AnnotOptions.Rect): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
        return DocumentViewManager.showViewSettings(tag, rect);
    }
    return Promise.resolve();
  }

  /** @method */
showRotateDialog = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.showRotateDialog(tag);
    }
    return Promise.resolve();
  }
  
  /**
   * @method
   */
  showAddPagesView = (rect: AnnotOptions.Rect): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
        return DocumentViewManager.showAddPagesView(tag, rect);
    }
    return Promise.resolve();
  }

  /** @method */
isReflowMode = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
        return DocumentViewManager.isReflowMode(tag);
    }
    return Promise.resolve();
  }

  /** @method */
toggleReflow = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.toggleReflow(tag);
    }
    return Promise.resolve();
  }

  /** @method */
shareCopy = (rect: AnnotOptions.Rect, flattening: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
        return DocumentViewManager.shareCopy(tag, rect, flattening);
    }
    return Promise.resolve();
  }
 
  openThumbnailsView = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.openThumbnailsView(tag);
    }
    return Promise.resolve();
  }

  /** @method */
openOutlineList = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openOutlineList(tag);
    }
    return Promise.resolve();
  }

  /** @method */
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
   * @example this._viewer.openNavigationLists();
   */
  
  openNavigationLists = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openNavigationLists(tag);
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
