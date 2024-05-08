import React, { PureComponent } from 'react';
import PropTypes, { Requireable, Validator } from 'prop-types';
import {
  requireNativeComponent,
  Platform,
  Alert,
  NativeModules,
  findNodeHandle,
} from 'react-native';
import { ViewPropTypes } from 'deprecated-react-native-prop-types';
const { DocumentViewManager } = NativeModules;
import { Config } from "../Config/Config";
import * as AnnotOptions from "../AnnotOptions/AnnotOptions";

/**
 * Object containing PropTypes types for {@link DocumentView} class.
 * Also used to generate prop types for TS users.
 *
 * To represent functions, please use {@link func}.
 * To represent "one of Config.Buttons values" or "an array of
 * Config.Buttons values", please use {@link oneOf} or {@link arrayOf}.
 */
const propTypes = {
  document: PropTypes.string.isRequired,
  source: PropTypes.string,
  password: PropTypes.string,
  initialPageNumber: PropTypes.number,
  page: PropTypes.number,
  pageNumber: PropTypes.number,
  customHeaders: PropTypes.object,
  documentExtension: PropTypes.string,
  leadingNavButtonIcon: PropTypes.string,
  enableAntialiasing: PropTypes.bool,
  showLeadingNavButton: PropTypes.bool,
  onLeadingNavButtonPressed: func<() => void>(),
  onDocumentLoaded: func<(path: string) => void>(),
  onLoadComplete: func<(path: string) => void>(),
  onDocumentError: func<(error: string) => void>(),
  onError: func<(error: string) => void>(),
  onPageChanged: func<(event: {previousPageNumber: number, pageNumber: number}) => void>(),
  onScrollChanged: func<(event: {horizontal: number, vertical: number}) => void>(),
  onZoomChanged: func<(event: {zoom: number}) => void>(),
  onScaleChanged: func<(event: {scale: number}) => void>(),
  onZoomFinished: func<(event: {zoom: number}) => void>(),
  zoom: PropTypes.number,
  scale: PropTypes.number,
  disabledElements: arrayOf<Config.Buttons>(Config.Buttons),
  disabledTools: arrayOf<Config.Tools>(Config.Tools),
  longPressMenuItems: arrayOf<Config.LongPressMenu>(Config.LongPressMenu),
  overrideLongPressMenuBehavior: arrayOf<Config.LongPressMenu>(Config.LongPressMenu),
  onLongPressMenuPress: func<(event: { longPressMenu: string, longPressText: string }) => void>(),
  longPressMenuEnabled: PropTypes.bool,
  annotationMenuItems: arrayOf<Config.AnnotationMenu>(Config.AnnotationMenu),
  overrideAnnotationMenuBehavior: arrayOf<Config.AnnotationMenu>(Config.AnnotationMenu),
  onAnnotationMenuPress: func<(event: { annotationMenu: string, annotations: Array<AnnotOptions.Annotation> }) => void>(),
  hideAnnotationMenu: arrayOf<Config.Tools>(Config.Tools),
  overrideBehavior: arrayOf<Config.Actions>(Config.Actions),
  onBehaviorActivated: func<(event: { action: Config.Actions, data: AnnotOptions.LinkPressData | AnnotOptions.StickyNoteData }) => void>(),
  topToolbarEnabled: PropTypes.bool,
  bottomToolbarEnabled: PropTypes.bool,
  hideToolbarsOnTap: PropTypes.bool,
  documentSliderEnabled: PropTypes.bool,
  downloadDialogEnabled: PropTypes.bool,
  pageIndicatorEnabled: PropTypes.bool,
  keyboardShortcutsEnabled: PropTypes.bool,
  onAnnotationsSelected: func<(event: {annotations: Array<AnnotOptions.Annotation>}) => void>(),
  onAnnotationChanged: func<(event: {action: string, annotations: Array<AnnotOptions.Annotation>}) => void>(),
  onAnnotationFlattened: func<(event: {annotations: Array<AnnotOptions.Annotation>}) => void>(),
  onFormFieldValueChanged: func<(event: {fields: Array<AnnotOptions.Field>}) => void>(),
  onAnnotationToolbarItemPress: func<(event: {id: string}) => void>(),
  onSavedSignaturesChanged: func<() => void>(),
  readOnly: PropTypes.bool,
  thumbnailViewEditingEnabled: PropTypes.bool,
  fitMode: oneOf<Config.FitMode>(Config.FitMode),
  fitPolicy: PropTypes.number,
  layoutMode: oneOf<Config.LayoutMode>(Config.LayoutMode),
  onLayoutChanged: func<() => void>(),
  padStatusBar: PropTypes.bool,
  continuousAnnotationEditing: PropTypes.bool,
  selectAnnotationAfterCreation: PropTypes.bool,
  annotationAuthor: PropTypes.string,
  showSavedSignatures: PropTypes.bool,
  storeNewSignature: PropTypes.bool,
  isBase64String: PropTypes.bool,
  collabEnabled: PropTypes.bool,
  currentUser: PropTypes.string,
  currentUserName: PropTypes.string,
  onExportAnnotationCommand: func<(event: { action: "modify" | "delete" | "add" | "undo" | "redo", xfdfCommand: string, annotations: Array<AnnotOptions.Annotation> }) => void>(),
  autoSaveEnabled: PropTypes.bool,
  pageChangeOnTap: PropTypes.bool,
  followSystemDarkMode: PropTypes.bool,
  useStylusAsPen: PropTypes.bool,
  multiTabEnabled: PropTypes.bool,
  highlighterSmoothingEnabled: PropTypes.bool,
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
      items: PropTypes.arrayOf(PropTypes.oneOfType([
        oneOf<Config.Tools | Config.Buttons>(Config.Tools, Config.Buttons).isRequired,
        PropTypes.exact({
          id: PropTypes.string.isRequired,
          name: PropTypes.string.isRequired,
          icon: PropTypes.string.isRequired,
        })
      ]))
    })
  ])),
  hideDefaultAnnotationToolbars: arrayOf<Config.DefaultToolbars>(Config.DefaultToolbars),
  topAppNavBarRightBar: arrayOf<Config.Buttons>(Config.Buttons),
  bottomToolbar: arrayOf<Config.Buttons>(Config.Buttons),
  hideAnnotationToolbarSwitcher: PropTypes.bool,
  hideTopToolbars: PropTypes.bool,
  hideTopAppNavBar: PropTypes.bool,
  hidePresetBar: PropTypes.bool,
  onBookmarkChanged: func<(event: { bookmarkJson: string }) => void>(),
  hideThumbnailFilterModes: arrayOf<Config.ThumbnailFilterMode>(Config.ThumbnailFilterMode),
  onToolChanged: func<(event: { previousTool: Config.Tools | "unknown tool", tool: Config.Tools | "unknown tool" }) => void>(),
  horizontalScrollPos: PropTypes.number,
  verticalScrollPos: PropTypes.number,
  onTextSearchStart: func<() => void>(),
  onTextSearchResult: func<(event: { found: boolean, textSelection: AnnotOptions.TextSelectionResult | null }) => void>(),
  hideViewModeItems: arrayOf<Config.ViewModePickerItem>(Config.ViewModePickerItem),
  hideThumbnailsViewItems: arrayOf<Config.ThumbnailsViewItem>(Config.ThumbnailsViewItem),
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
  annotationManagerEditMode: oneOf<Config.AnnotationManagerEditMode>(Config.AnnotationManagerEditMode),
  annotationManagerUndoMode: oneOf<Config.AnnotationManagerUndoMode>(Config.AnnotationManagerUndoMode),
  replyReviewStateEnabled: PropTypes.bool,
  onPageMoved: func<(event: {previousPageNumber: number, pageNumber: number}) => void>(),
  onPagesAdded: func<(event: {pageNumbers: Array<number>}) => void>(),
  onPagesRemoved: func<(event: {pageNumbers: Array<number>}) => void>(),
  onPagesRotated: func<(event: {pageNumbers: Array<number>}) => void>(),
  onTabChanged: func<(event: {currentTab: string}) => void>(),
  rememberLastUsedTool: PropTypes.bool,
  overflowMenuButtonIcon: PropTypes.string,
  maxSignatureCount: PropTypes.number,
  overrideToolbarButtonBehavior: arrayOf<Config.Buttons>(Config.Buttons),
  onToolbarButtonPress: func<(event: {id: string}) => void>(),

  // Hygen Generated Props
  enableReadingModeQuickMenu: PropTypes.bool,
  forceAppTheme: oneOf<Config.ThemeOptions>(Config.ThemeOptions),
  signatureColors: PropTypes.arrayOf(PropTypes.exact({
    red: PropTypes.number.isRequired,
    green: PropTypes.number.isRequired,
    blue: PropTypes.number.isRequired,
  })),
  onCurrentToolbarChanged: func<(event: { toolbar: string }) => void>(),

  ...ViewPropTypes,
};

// Generates the prop types for TypeScript users, from PropTypes.
type DocumentViewProps = PropTypes.InferProps<typeof propTypes>;

/**
* Creates a custom PropType for functions.
*
* If the resulting PropType is used to generate prop types for TS users,
* type checking for function parameters and return values will be provided.
* @returns {Requireable<T>} A custom PropType constant.
* @example
* func<(path: string) => void>()
*/
function func<T>(): Requireable<T> {

  let validator: Validator<T> = function (props: { [key: string]: any }, propName: string, componentName: string, location: string, propFullName: string): Error | null {
    if (typeof props[propName] !== "function" && typeof props[propName] !== "undefined") {
      return new Error(`Invalid prop \`${propName}\` of type \`${typeof props[propName]}\` supplied to \`${componentName}\`, expected a function.`);
    }
    return null;
  }

  const t: Requireable<T> = validator as Requireable<T>;
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
*/
function oneOf<T>(obj: object, ...rest: object[]): Requireable<T> {
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
*/
function arrayOf<T>(obj: object, ...rest: object[]): Requireable<T[]> {
  return PropTypes.arrayOf(oneOf<T>(obj, ...rest)) as Requireable<T[]>;
}
export class DocumentView extends PureComponent<DocumentViewProps, any> {

  _viewerRef: any;

  static propTypes = propTypes;

  onChange = (event: any) => {
    if (event.nativeEvent.onLeadingNavButtonPressed) {
      if (this.props.onLeadingNavButtonPressed) {
        this.props.onLeadingNavButtonPressed();
      }
    } else if (event.nativeEvent.onDocumentLoaded) {
      if (this.props.onDocumentLoaded) {
        this.props.onDocumentLoaded(event.nativeEvent.onDocumentLoaded);
      }
      if (this.props.onLoadComplete) {
        this.props.onLoadComplete(event.nativeEvent.onDocumentLoaded);
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
      if (this.props.onScaleChanged) {
        this.props.onScaleChanged({
        	'scale': event.nativeEvent.zoom,
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
    } else if (event.nativeEvent.onAnnotationFlattened) {
      if (this.props.onAnnotationFlattened) {
        this.props.onAnnotationFlattened({
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
    } else if (event.nativeEvent.onAnnotationToolbarItemPress) {
      if (this.props.onAnnotationToolbarItemPress) {
        this.props.onAnnotationToolbarItemPress({
          'id': event.nativeEvent.id,
        });
      }
    } else if (event.nativeEvent.onSavedSignaturesChanged) {
      if (this.props.onSavedSignaturesChanged) {
        this.props.onSavedSignaturesChanged();
      }
    } else if (event.nativeEvent.onDocumentError) {
      if (this.props.onDocumentError || this.props.onError) {
        if (this.props.onDocumentError) {
          this.props.onDocumentError(event.nativeEvent.onDocumentError);
        }
        if (this.props.onError) {
          this.props.onError(event.nativeEvent.onDocumentError);
        }
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
    } else if (event.nativeEvent.onPagesAdded) {
      if (this.props.onPagesAdded) {
        this.props.onPagesAdded({
          'pageNumbers': event.nativeEvent.pageNumbers,
        });
      }
    } else if (event.nativeEvent.onPagesRemoved) {
      if (this.props.onPagesRemoved) {
        this.props.onPagesRemoved({
          'pageNumbers': event.nativeEvent.pageNumbers,
        });
      }
    } else if (event.nativeEvent.onPagesRotated) {
      if (this.props.onPagesRotated) {
        this.props.onPagesRotated({
          'pageNumbers': event.nativeEvent.pageNumbers,
        });
      }
    } else if (event.nativeEvent.onTabChanged) {
      if (this.props.onTabChanged) {
        this.props.onTabChanged({
          'currentTab': event.nativeEvent.currentTab
        });
      }
    } else if (event.nativeEvent.onToolbarButtonPress) {
      if (this.props.onToolbarButtonPress) {
        this.props.onToolbarButtonPress({
          'id': event.nativeEvent.id,
        });
      }
    // Hygen Generated Event Listeners
    } else if (event.nativeEvent.onCurrentToolbarChanged) {
      if (this.props.onCurrentToolbarChanged) {
        this.props.onCurrentToolbarChanged({
          'toolbar': event.nativeEvent.toolbar,
        });
      }
    }
  }

  // Methods

  getDocumentPath = (): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getDocumentPath(tag);
    }
    return Promise.resolve();
  }

  getAllFields = (pageNumber?: number): Promise<void |  Array<AnnotOptions.Field>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      if (pageNumber === undefined) {
        pageNumber = -1;
      }
      return DocumentViewManager.getAllFields(tag, pageNumber);
    }
    return Promise.resolve();
  }


  setToolMode = (toolMode: Config.Tools): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setToolMode(tag, toolMode);
    }
    return Promise.resolve();
  }

  commitTool = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.commitTool(tag);
    }
    return Promise.resolve();
  }

  getPageCount = (): Promise<void | number> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageCount(tag);
    }
    return Promise.resolve();
  }

  importBookmarkJson = (bookmarkJson: string): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.importBookmarkJson(tag, bookmarkJson);
    }
    return Promise.resolve();
  }

  openBookmarkList = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openBookmarkList(tag);
    }
    return Promise.resolve();
  }

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

  importAnnotations = (xfdf: string, replace: boolean = false): Promise<void | Array<AnnotOptions.Annotation>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.importAnnotations(tag, xfdf, replace);
    }
    return Promise.resolve();
  }

  exportAnnotations = (options?: { annotList: Array<AnnotOptions.Annotation> }): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.exportAnnotations(tag, options);
    }
    return Promise.resolve();
  }

  flattenAnnotations = (formsOnly: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.flattenAnnotations(tag, formsOnly);
    }
    return Promise.resolve();
  }

  deleteAnnotations = (annotations: Array<AnnotOptions.Annotation>): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.deleteAnnotations(tag, annotations);
    }
    return Promise.resolve();
  }

  saveDocument = (): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.saveDocument(tag);
    }
    return Promise.resolve();
  }

  setFlagForFields = (fields: Array<string>, flag: Config.FieldFlags, value: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setFlagForFields(tag, fields, flag, value);
    }
    return Promise.resolve();
  }

  getField = (fieldName: string): Promise<void | { fieldName: string, fieldValue?: any, fieldType?: string }> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getField(tag, fieldName);
    }
    return Promise.resolve();
  }

  openAnnotationList = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openAnnotationList(tag);
    }
    return Promise.resolve();
  }

  // Hygen Generated Methods
  setStampImageData = (annotationId: string, pageNumber: number, stampImageDataUrl: string): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setStampImageData(tag, annotationId, pageNumber, stampImageDataUrl);
    }
    return Promise.resolve();
  }
  setFormFieldHighlightColor = (fieldHighlightColor: AnnotOptions.ColorWithAlpha): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setFormFieldHighlightColor(tag, fieldHighlightColor);
    }
    return Promise.resolve();
  }

  /**
  * note: this function exists for supporting the old version. It simply calls setValuesForFields.
  *
  */
  setValueForFields = (fieldsMap: Record<string, string | boolean | number>): Promise<void> => {
    return this.setValuesForFields(fieldsMap);
  }

  setValuesForFields = (fieldsMap: Record<string, string | boolean | number>): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setValuesForFields(tag, fieldsMap);
    }
    return Promise.resolve();
  }

  handleBackButton = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.handleBackButton(tag);
    }
    return Promise.resolve();
  }


  /**
  * note: this function exists for supporting the old version. It simply calls setFlagsForAnnotations.
  *
  */
  setFlagForAnnotations = (annotationFlagList: Array<AnnotOptions.AnnotationFlag>): Promise<void> => {
    return this.setFlagsForAnnotations(annotationFlagList);
  }

  setFlagsForAnnotations = (annotationFlagList: Array<AnnotOptions.AnnotationFlag>): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setFlagsForAnnotations(tag, annotationFlagList);
    }
    return Promise.resolve();
  }

  selectAnnotation = (id: string, pageNumber: number): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.selectAnnotation(tag, id, pageNumber);
    }
    return Promise.resolve();
  }

  /**
  * note: this function exists for supporting the old version. It simply calls setPropertiesForAnnotation.
  *
  */
  setPropertyForAnnotation = (id: string, pageNumber: number, propertyMap: AnnotOptions.AnnotationProperties): Promise<void> => {
    return this._viewerRef.setPropertiesForAnnotation(id, pageNumber, propertyMap);
  }

  setPropertiesForAnnotation = (id: string, pageNumber: number, propertyMap: AnnotOptions.AnnotationProperties): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setPropertiesForAnnotation(tag, id, pageNumber, propertyMap);
    }
    return Promise.resolve();
  }

  getPropertiesForAnnotation = (id: string, pageNumber: number): Promise<void | AnnotOptions.AnnotationProperties> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPropertiesForAnnotation(tag, id, pageNumber);
    }
    return Promise.resolve();
  }

  setDrawAnnotations = (drawAnnotations: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setDrawAnnotations(tag, drawAnnotations);
    }
    return Promise.resolve();
  }

  setVisibilityForAnnotation = (id: string, pageNumber: number, visibility: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      DocumentViewManager.setVisibilityForAnnotation(tag, id, pageNumber, visibility);
    }
    return Promise.resolve();
  }

  setHighlightFields = (highlightFields: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      DocumentViewManager.setHighlightFields(tag, highlightFields);
    }
    return Promise.resolve();
  }

  getAnnotationAtPoint = (x: number, y: number, distanceThreshold: number, minimumLineWeight: number): Promise<void | AnnotOptions.Annotation> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationAt(tag, x, y, distanceThreshold, minimumLineWeight);
    }
    return Promise.resolve();
  }

  getAnnotationListAt = (x1: number, y1: number, x2: number, y2: number): Promise<void | Array<AnnotOptions.Annotation>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationListAt(tag, x1, y1, x2, y2);
    }
    return Promise.resolve();
  }

  getAnnotationsOnPage = (pageNumber: number): Promise<void | Array<AnnotOptions.Annotation>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationListOnPage(tag, pageNumber);
    }
    return Promise.resolve();
  }

  getCustomDataForAnnotation = (annotationID: string, pageNumber: number, key: string): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getCustomDataForAnnotation(tag, annotationID, pageNumber, key);
    }
    return Promise.resolve();
  }

  setAnnotationToolbarItemEnabled = (itemId: string, enable: boolean) : Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setAnnotationToolbarItemEnabled(tag, itemId, enable);
    }
    return Promise.resolve();
  }

  getPageCropBox = (pageNumber: number): Promise<void | AnnotOptions.CropBox> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageCropBox(tag, pageNumber);
    }
    return Promise.resolve();
  }

  setCurrentPage = (pageNumber: number): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setCurrentPage(tag, pageNumber);
    }
    return Promise.resolve();
  }

  getVisiblePages = (): Promise<void | Array<number>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getVisiblePages(tag);
    }
    return Promise.resolve();
  }

  gotoPreviousPage = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoPreviousPage(tag);
    }
    return Promise.resolve();
  }

  gotoNextPage = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoNextPage(tag);
    }
    return Promise.resolve();
  }

  gotoFirstPage = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoFirstPage(tag);
    }
    return Promise.resolve();
  }

  gotoLastPage = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoLastPage(tag);
    }
    return Promise.resolve();
  }

  showGoToPageView = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.showGoToPageView(tag);
    }
    return Promise.resolve();
  }

  closeAllTabs = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.closeAllTabs(tag);
    }
    return Promise.resolve();
  }

  openTabSwitcher = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openTabSwitcher(tag);
    }
    return Promise.resolve();
  }

  getZoom = (): Promise<void | number> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getZoom(tag);
    }
    return Promise.resolve();
  }

  setZoomLimits = (zoomLimitMode: Config.ZoomLimitMode, minimum: number, maximum: number): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setZoomLimits(tag, zoomLimitMode, minimum, maximum);
    }
    return Promise.resolve();
  }

  zoomWithCenter = (zoom: number, x: number, y: number): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.zoomWithCenter(tag, zoom, x, y);
    }
    return Promise.resolve();
  }

  zoomToRect = (pageNumber: number, rect: AnnotOptions.Rect): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.zoomToRect(tag, pageNumber, rect);
    }
    return Promise.resolve();
  }

  smartZoom = (x: number, y: number, animated: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.smartZoom(tag, x, y, animated);
    }
    return Promise.resolve();
  }

  getScrollPos = (): Promise<void | { horizontal: number, vertical: number }> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getScrollPos(tag);
    }
    return Promise.resolve();
  }

  getCanvasSize = (): Promise<void | { width: number, height: number }> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getCanvasSize(tag);
    }
    return Promise.resolve();
  }

  getPageRotation = (): Promise<void | AnnotOptions.RotationDegree> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageRotation(tag);
    }
    return Promise.resolve();
  }

  rotateClockwise = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.rotateClockwise(tag);
    }
    return Promise.resolve();
  }

  rotateCounterClockwise = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.rotateCounterClockwise(tag);
    }
    return Promise.resolve();
  }


  convertScreenPointsToPagePoints = (points: Array<AnnotOptions.Point>): Promise<void | Array<AnnotOptions.Point>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.convertScreenPointsToPagePoints(tag, points);
    }
    return Promise.resolve();
  }

  convertPagePointsToScreenPoints = (points: Array<AnnotOptions.Point>): Promise<void | Array<AnnotOptions.Point>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.convertPagePointsToScreenPoints(tag, points);
    }
    return Promise.resolve();
  }

  getPageNumberFromScreenPoint = (x: number, y: number): Promise<void | number> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageNumberFromScreenPoint(tag, x, y);
    }
    return Promise.resolve();
  }

  setProgressiveRendering = (progressiveRendering: boolean, initialDelay: number, interval: number): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setProgressiveRendering(tag, progressiveRendering, initialDelay, interval);
    }
    return Promise.resolve();
  }

  setImageSmoothing = (imageSmoothing: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setImageSmoothing(tag, imageSmoothing);
    }
    return Promise.resolve();
  }

  setOverprint = (overprint: Config.OverprintMode): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setOverprint(tag, overprint);
    }
    return Promise.resolve();
  }

  setColorPostProcessMode = (colorPostProcessMode: Config.ColorPostProcessMode): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setColorPostProcessMode(tag, colorPostProcessMode);
    }
    return Promise.resolve();
  }

  setColorPostProcessColors = (whiteColor: AnnotOptions.Color, blackColor: AnnotOptions.Color): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setColorPostProcessColors(tag, whiteColor, blackColor);
    }
    return Promise.resolve();
  }

  startSearchMode = (searchString: string, matchCase: boolean, matchWholeWord: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.startSearchMode(tag, searchString, matchCase, matchWholeWord);
    }
    return Promise.resolve();
  }

  exitSearchMode = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.exitSearchMode(tag);
    }
    return Promise.resolve();
  }

  findText = (searchString: string, matchCase: boolean, matchWholeWord: boolean, searchUp: boolean, regExp: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.findText(tag, searchString, matchCase, matchWholeWord, searchUp, regExp);
    }
    return Promise.resolve();
  }

  cancelFindText = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.cancelFindText(tag);
    }
    return Promise.resolve();
  }

  openSearch = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openSearch(tag);
    }
    return Promise.resolve();
  }

  getSelection = (pageNumber: number): Promise<void | AnnotOptions.TextSelectionResult> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getSelection(tag, pageNumber);
    }
    return Promise.resolve();
  }

  hasSelection = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.hasSelection(tag);
    }
    return Promise.resolve();
  }

  clearSelection = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.clearSelection(tag);
    }
    return Promise.resolve();
  }

  getSelectionPageRange = (): Promise<void | { begin: number, end: number }> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getSelectionPageRange(tag);
    }
    return Promise.resolve();
  }

  hasSelectionOnPage = (pageNumber: number): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.hasSelectionOnPage(tag, pageNumber);
    }
    return Promise.resolve();
  }


  selectInRect = (rect: AnnotOptions.Rect): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.selectInRect(tag, rect);
    }
    return Promise.resolve();
  }

  isThereTextInRect = (rect: AnnotOptions.Rect): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.isThereTextInRect(tag, rect);
    }
    return Promise.resolve();
  }

  selectAll = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.selectAll(tag);
    }
    return Promise.resolve();
  }

  setPageBorderVisibility = (pageBorderVisibility: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setPageBorderVisibility(tag, pageBorderVisibility);
    }
    return Promise.resolve();
  }

  setPageTransparencyGrid = (pageTransparencyGrid: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setPageTransparencyGrid(tag, pageTransparencyGrid);
    }
    return Promise.resolve();
  }

  setDefaultPageColor = (defaultPageColor: AnnotOptions.Color): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setDefaultPageColor(tag, defaultPageColor);
    }
    return Promise.resolve();
  }

  setBackgroundColor = (backgroundColor: AnnotOptions.Color): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setBackgroundColor(tag, backgroundColor);
    }
    return Promise.resolve();
  }

  exportAsImage = (pageNumber: number, dpi: number, exportFormat: Config.ExportFormat, transparent: boolean = false): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.exportAsImage(tag, pageNumber, dpi, exportFormat, transparent);
    }
    return Promise.resolve();
  }

  undo = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.undo(tag);
    }
    return Promise.resolve();
  }

  redo = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.redo(tag);
    }
    return Promise.resolve();
  }

  canUndo = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.canUndo(tag);
    }
    return Promise.resolve();
  }

  canRedo = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.canRedo(tag);
    }
    return Promise.resolve();
  }

  showCrop = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.showCrop(tag);
    }
    return Promise.resolve();
  }

  setCurrentToolbar = (toolbar: string): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setCurrentToolbar(tag, toolbar);
    }
    return Promise.resolve();
  }

  showViewSettings = (rect: AnnotOptions.Rect): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.showViewSettings(tag, rect);
    }
    return Promise.resolve();
  }

  showRotateDialog = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.showRotateDialog(tag);
    }
    return Promise.resolve();
  }

  showAddPagesView = (rect: AnnotOptions.Rect): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.showAddPagesView(tag, rect);
    }
    return Promise.resolve();
  }

  isReflowMode = (): Promise<void | boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.isReflowMode(tag);
    }
    return Promise.resolve();
  }

  toggleReflow = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.toggleReflow(tag);
    }
    return Promise.resolve();
  }

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

  openOutlineList = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openOutlineList(tag);
    }
    return Promise.resolve();
  }

  openLayersList = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openLayersList(tag);
    }
    return Promise.resolve();
  }

  openNavigationLists = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.openNavigationLists(tag);
    }
    return Promise.resolve();
  }

  getSavedSignatures = (): Promise<void | Array<string>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getSavedSignatures(tag);
    }
    return Promise.resolve();
  }

  getSavedSignatureFolder = (): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getSavedSignatureFolder(tag);
    }
    return Promise.resolve();
  }

  getSavedSignatureJpgFolder = (): Promise<void | string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getSavedSignatureJpgFolder(tag);
    }
    return Promise.resolve();
  }

  _setNativeRef = (ref: any) => {
    this._viewerRef = ref;
  };

  render() {
    return (
      <RCTDocumentView
        ref={this._setNativeRef}
        // @ts-ignore
        style={{ flex: 1 }}
        // @ts-ignore: Intentionally exclude `onChange` from being exposed as a prop.
        onChange={this.onChange}
        {...this.props}
      />
    )
  }
}

const name = Platform.OS === 'ios' ? 'RNTPTDocumentView' : 'RCTDocumentView';

const RCTDocumentView = requireNativeComponent(name);
