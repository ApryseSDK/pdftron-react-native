import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import {
  requireNativeComponent,
  ViewPropTypes,
  ViewProps,
  Platform,
  Alert,
  NativeModules,
  findNodeHandle,
} from 'react-native';
const { DocumentViewManager } = NativeModules;
import * as Config from "../Config/Config";
import * as AnnotOptions from "../AnnotOptions/AnnotOptions";

export interface DocumentViewProps extends ViewProps {
  document: string;
  password?: string;
  initialPageNumber?: number;
  pageNumber?: number;
  customHeaders?: object;
  leadingNavButtonIcon?: string;
  showLeadingNavButton?: boolean;
  onLeadingNavButtonPressed?: () => void;
  onDocumentLoaded?: (path : string) => void;
  onDocumentError?: (error: string) => void;
  onPageChanged?: ({previousPageNumber, pageNumber}: {previousPageNumber: number, pageNumber: number}) => void;
  onScrollChanged?: ({horizontal, vertical}: {horizontal: number, vertical: number}) => void;
  onZoomChanged?: ({zoom}: {zoom: number}) => void;
  onZoomFinished?: ({zoom}: {zoom: number}) => void;
  zoom?: number;
  disabledElements?: Array<Config.Tools>;
  disabledTools?: Array<Config.Tools>;
  longPressMenuItems?: Array<Config.LongPressMenu>;
  overrideLongPressMenuBehavior?: Array<Config.LongPressMenu>;
  onLongPressMenuPress?: ({longPressMenu, longPressText}: {longPressMenu: string, longPressText: string}) => void;
  longPressMenuEnabled?: boolean;
  annotationMenuItems?: Array<Config.AnnotationMenu>;
  overrideAnnotationMenuBehavior?: Array<Config.AnnotationMenu>;
  onAnnotationMenuPress?: ({annotationMenu, annotations}: {annotationMenu: string, annotations: Array<AnnotOptions.Annotation>}) => void;
  hideAnnotationMenu?: Array<Config.Tools>;
  overrideBehavior?: Array<Config.Actions>;
  onBehaviorActivated?: ({action, data}: {action: Config.Actions, data: AnnotOptions.LinkPressData | AnnotOptions.StickyNoteData}) => void;
  topToolbarEnabled?: boolean;
  bottomToolbarEnabled?: boolean;
  hideToolbarsOnTap?: boolean;
  documentSliderEnabled?: boolean;
  pageIndicatorEnabled?: boolean;
  keyboardShortcutsEnabled?: boolean;
  onAnnotationsSelected?: ({annotations}: {annotations: Array<AnnotOptions.Annotation>}) => void ;
  onAnnotationChanged?: ({action, annotations}: {action: string, annotations: Array<AnnotOptions.Annotation>}) => void;
  onFormFieldValueChanged?: ({fields}: {fields: Array<AnnotOptions.FieldWithStringValue>}) => void;
  readOnly?: boolean;
  thumbnailViewEditingEnabled?: boolean;
  fitMode?: Config.FitMode;
  layoutMode?: Config.LayoutMode;
  onLayoutChanged?: () => void;
  padStatusBar?: boolean;
  continuousAnnotationEditing?: boolean;
  selectAnnotationAfterCreation?: boolean;
  annotationAuthor?: string;
  showSavedSignatures?: boolean;
  isBase64String?: boolean;
  collabEnabled?: boolean;
  currentUser?: string;
  currentUserName?: string;
  onExportAnnotationCommand?: ({action, xfdfCommand, annotations}: {action: string, xfdfCommand: string, annotations: Array<AnnotOptions.Annotation>}) => void;
  autoSaveEnabled?: boolean;
  pageChangeOnTap?: boolean;
  followSystemDarkMode?: boolean;
  useStylusAsPen?: boolean;
  multiTabEnabled?: boolean;
  tabTitle?: string;
  maxTabCount?: number;
  signSignatureFieldsWithStamps?: boolean;
  annotationPermissionCheckEnabled?: boolean;
  annotationToolbars?: Array<Config.DefaultToolbars | Config.CustomToolbarKey>;
  hideDefaultAnnotationToolbars?: Array<Config.DefaultToolbars>;
  topAppNavBarRightBar?: Array<Config.Buttons>;
  bottomToolbar?: Array<Config.Buttons>;
  hideAnnotationToolbarSwitcher?: boolean;
  hideTopToolbars?: boolean;
  hideTopAppNavBar?: boolean;
  onBookmarkChanged?: ({bookmarkJson}: {bookmarkJson: string}) => void;
  hideThumbnailFilterModes?: Array<Config.ThumbnailFilterMode>;
  onToolChanged?: ({previousTool, tool}: {previousTool: Config.Tools | "unknown tool", tool: Config.Tools | "unknown tool"}) => void;
  horizontalScrollPos?: number;
  verticalScrollPos?: number;
  onTextSearchStart?: () => void;
  onTextSearchResult?: ({found, textSelection}: {found: boolean, textSelection: AnnotOptions.TextSelectionResult | null}) => void;
  hideViewModeItems?: Array<Config.ViewModePickerItem>;
  pageStackEnabled?: boolean;
  showQuickNavigationButton?: boolean;
  photoPickerEnabled?: boolean;
  autoResizeFreeTextEnabled?: boolean;
  annotationsListEditingEnabled?: boolean;
  showNavigationListAsSidePanelOnLargeDevices?: boolean;
  restrictDownloadUsage?: boolean;
  userBookmarksListEditingEnabled?: boolean;
  imageInReflowEnabled?: boolean;
  reflowOrientation?: Config.ReflowOrientation;
  onUndoRedoStateChanged?: () => void;
  tabletLayoutEnabled?: boolean;
  initialToolbar?: string;
  inkMultiStrokeEnabled?: boolean;
  defaultEraserType?: Config.EraserType;
  exportPath?: string;
  openUrlPath?: string;
  hideScrollbars?: boolean;
  saveStateEnabled?: boolean;
  openSavedCopyInNewTab?: boolean;

  onChange?(event): void;
}


export class DocumentView extends PureComponent<DocumentViewProps, any> {

  _viewerRef;

  static propTypes = {
    document: PropTypes.string,
    password: PropTypes.string,
    initialPageNumber: PropTypes.number,
    pageNumber: PropTypes.number,
    customHeaders: PropTypes.object,
    leadingNavButtonIcon: PropTypes.string,
    showLeadingNavButton: PropTypes.bool,
    onLeadingNavButtonPressed: PropTypes.func,
    onDocumentLoaded: PropTypes.func,
    onDocumentError: PropTypes.func,
    onPageChanged: PropTypes.func,
    onScrollChanged: PropTypes.func,
    onZoomChanged: PropTypes.func,
    onZoomFinished: PropTypes.func,
    zoom: PropTypes.number,
    disabledElements: PropTypes.array,
    disabledTools: PropTypes.array,
    longPressMenuItems: PropTypes.array,
    overrideLongPressMenuBehavior: PropTypes.array,
    onLongPressMenuPress: PropTypes.func,
    longPressMenuEnabled: PropTypes.bool,
    annotationMenuItems: PropTypes.array,
    overrideAnnotationMenuBehavior: PropTypes.array,
    onAnnotationMenuPress: PropTypes.func,
    hideAnnotationMenu: PropTypes.array,
    overrideBehavior: PropTypes.array,
    onBehaviorActivated: PropTypes.func,
    topToolbarEnabled: PropTypes.bool,
    bottomToolbarEnabled: PropTypes.bool,
    hideToolbarsOnTap: PropTypes.bool,
    documentSliderEnabled: PropTypes.bool,
    pageIndicatorEnabled: PropTypes.bool,
    keyboardShortcutsEnabled: PropTypes.bool,
    onAnnotationsSelected: PropTypes.func,
    onAnnotationChanged: PropTypes.func,
    onFormFieldValueChanged: PropTypes.func,
    readOnly: PropTypes.bool,
    thumbnailViewEditingEnabled: PropTypes.bool,
    fitMode: PropTypes.string,
    layoutMode: PropTypes.string,
    onLayoutChanged: PropTypes.func,
    padStatusBar: PropTypes.bool,
    continuousAnnotationEditing: PropTypes.bool,
    selectAnnotationAfterCreation: PropTypes.bool,
    annotationAuthor: PropTypes.string,
    showSavedSignatures: PropTypes.bool,
    isBase64String: PropTypes.bool,
    collabEnabled: PropTypes.bool,
    currentUser: PropTypes.string,
    currentUserName: PropTypes.string,
    onExportAnnotationCommand: PropTypes.func,
    autoSaveEnabled: PropTypes.bool,
    pageChangeOnTap: PropTypes.bool,
    followSystemDarkMode: PropTypes.bool,
    useStylusAsPen: PropTypes.bool,
    multiTabEnabled: PropTypes.bool,
    tabTitle: PropTypes.string,
    maxTabCount: PropTypes.number,
    signSignatureFieldsWithStamps: PropTypes.bool,
    annotationPermissionCheckEnabled: PropTypes.bool,
    annotationToolbars: PropTypes.array,
    hideDefaultAnnotationToolbars: PropTypes.array,
    topAppNavBarRightBar: PropTypes.array,
    bottomToolbar: PropTypes.array,
    hideAnnotationToolbarSwitcher: PropTypes.bool,
    hideTopToolbars: PropTypes.bool,
    hideTopAppNavBar: PropTypes.bool,
    onBookmarkChanged: PropTypes.func,
    hideThumbnailFilterModes: PropTypes.array,
    onToolChanged: PropTypes.func,
    horizontalScrollPos: PropTypes.number,
    verticalScrollPos: PropTypes.number,
    onTextSearchStart: PropTypes.func,
    onTextSearchResult: PropTypes.func,
    hideViewModeItems: PropTypes.array,
    pageStackEnabled: PropTypes.bool,
    showQuickNavigationButton: PropTypes.bool,
    photoPickerEnabled: PropTypes.bool,
    autoResizeFreeTextEnabled: PropTypes.bool,
    annotationsListEditingEnabled: PropTypes.bool,
    showNavigationListAsSidePanelOnLargeDevices: PropTypes.bool,
    restrictDownloadUsage: PropTypes.bool,
    userBookmarksListEditingEnabled: PropTypes.bool,
    imageInReflowEnabled: PropTypes.bool,
    reflowOrientation: PropTypes.string,
    onUndoRedoStateChanged: PropTypes.func,
    tabletLayoutEnabled: PropTypes.bool,
    initialToolbar: PropTypes.string,
    inkMultiStrokeEnabled: PropTypes.bool,
    defaultEraserType: PropTypes.string,
    exportPath: PropTypes.string,
    openUrlPath: PropTypes.string,
    hideScrollbars: PropTypes.bool,
    saveStateEnabled: PropTypes.bool,
    openSavedCopyInNewTab: PropTypes.bool,
    ...ViewPropTypes,
  };

  onChange = (event) => {
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
    }
  }

  // Methods

  getDocumentPath = (): Promise<void> | Promise<string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getDocumentPath(tag);
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

  commitTool = (): Promise<void> | Promise<boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.commitTool(tag);
    }
    return Promise.resolve();
  }

  getPageCount = (): Promise<void> | Promise<number> => {
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

  importAnnotations = (xfdf: string): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.importAnnotations(tag, xfdf);
    }
    return Promise.resolve();
  }

  exportAnnotations = (options?: {annotList: Array<AnnotOptions.Annotation>}): Promise<void> | Promise<string> => {
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

  saveDocument = (): Promise<void> | Promise<string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.saveDocument(tag);
    }
    return Promise.resolve();
  }

  setFlagForFields = (fields: Array<String>, flag: Config.FieldFlags, value: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.setFlagForFields(tag, fields, flag, value);
    }
    return Promise.resolve();
  }

  getField = (fieldName: string): Promise<void> | Promise<{fieldName: string, fieldValue?: any, fieldType?: string}> => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.getField(tag, fieldName);
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
    if(tag != null) {
      return DocumentViewManager.setValuesForFields(tag, fieldsMap);
    }
    return Promise.resolve();
  }

  handleBackButton = (): Promise<void> | Promise<boolean> => {
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
    return this._viewerRef.setPropertiesForAnnotation(id, pageNumber, propertyMap); // check this._viewerRef
  }

  setPropertiesForAnnotation = (id: string, pageNumber: number, propertyMap: AnnotOptions.AnnotationProperties): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setPropertiesForAnnotation(tag, id, pageNumber, propertyMap);
    }
    return Promise.resolve();
  }

  getPropertiesForAnnotation = (id: string, pageNumber: number): Promise<void> | Promise<AnnotOptions.AnnotationProperties> => {
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

  getAnnotationAtPoint = (x: number, y: number, distanceThreshold: number, minimumLineWeight: number): Promise<void> | Promise<AnnotOptions.Annotation> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationAt(tag, x, y, distanceThreshold, minimumLineWeight);
    }
    return Promise.resolve();
  }

  getAnnotationListAt = (x1: number, y1: number, x2: number, y2: number): Promise<void> | Promise<Array<AnnotOptions.Annotation>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationListAt(tag, x1, y1, x2, y2);
    }
    return Promise.resolve();
  }

  getAnnotationsOnPage = (pageNumber: number): Promise<void> | Promise<Array<AnnotOptions.Annotation>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationListOnPage(tag, pageNumber);
    }
    return Promise.resolve();
  }

  getCustomDataForAnnotation = (annotationID: string, pageNumber: number, key: string): Promise<void> | Promise<string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getCustomDataForAnnotation(tag, annotationID, pageNumber, key);
    }
    return Promise.resolve();
  }

  getPageCropBox = (pageNumber: number): Promise<void> | Promise<AnnotOptions.CropBox> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageCropBox(tag, pageNumber);
    }
    return Promise.resolve();
  }

  setCurrentPage = (pageNumber: number): Promise<void> | Promise<boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setCurrentPage(tag, pageNumber);
    }
    return Promise.resolve();
  }

  getVisiblePages = (): Promise<void> | Promise<Array<number>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getVisiblePages(tag);
    }
    return Promise.resolve();
  }

  gotoPreviousPage = (): Promise<void> | Promise<boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoPreviousPage(tag);
    }
    return Promise.resolve();
  }

  gotoNextPage = (): Promise<void> | Promise<boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoNextPage(tag);
    }
    return Promise.resolve();
  }

  gotoFirstPage = (): Promise<void> | Promise<boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoFirstPage(tag);
    }
    return Promise.resolve();
  }

  gotoLastPage = (): Promise<void> | Promise<boolean> => {
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

  getZoom = (): Promise<void> | Promise<number> => {
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
  
  getScrollPos = (): Promise<void> | Promise<{horizontal: number, vertical: number}> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getScrollPos(tag);
    }
    return Promise.resolve();
  }
    
  getCanvasSize = (): Promise<void> | Promise<{width: number, height: number}> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getCanvasSize(tag);
    }
    return Promise.resolve();
  }

  getPageRotation = (): Promise<void> | Promise<AnnotOptions.RotationDegree> => {
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


  convertScreenPointsToPagePoints = (points: Array<AnnotOptions.PointWithPage>): Promise<void> | Promise<Array<AnnotOptions.Point>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.convertScreenPointsToPagePoints(tag, points);
    }
    return Promise.resolve();
  }

  convertPagePointsToScreenPoints = (points: Array<AnnotOptions.PointWithPage>): Promise<void> | Promise<Array<AnnotOptions.Point>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.convertPagePointsToScreenPoints(tag, points);
    }
    return Promise.resolve();
  }

  getPageNumberFromScreenPoint = (x: number, y: number): Promise<void> | Promise<number> => {
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
      DocumentViewManager.setColorPostProcessMode(tag, colorPostProcessMode);
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

  getSelection = (pageNumber: number): Promise<void> | Promise<AnnotOptions.TextSelectionResult> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getSelection(tag, pageNumber);
    }
    return Promise.resolve();
  }

  hasSelection = (): Promise<void> | Promise<boolean> => {
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

  getSelectionPageRange = (): Promise<void> | Promise<{begin: number, end: number}> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getSelectionPageRange(tag);
    }
    return Promise.resolve();
  }

  hasSelectionOnPage = (pageNumber: number): Promise<void> | Promise<boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.hasSelectionOnPage(tag, pageNumber);
    }
    return Promise.resolve();
  }

  
  selectInRect = (rect: AnnotOptions.Rect): Promise<void> | Promise<boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.selectInRect(tag, rect);
    }
    return Promise.resolve();
  }

  isThereTextInRect = (rect: AnnotOptions.Rect): Promise<void> | Promise<boolean> => {
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


  setUrlExtraction = (urlExtraction: boolean): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.setUrlExtraction(tag, urlExtraction);
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

  exportAsImage = (pageNumber: number, dpi: number, exportFormat: Config.ExportFormat): Promise<void> | Promise<string> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.exportAsImage(tag, pageNumber, dpi, exportFormat);
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

  canUndo = (): Promise<void> | Promise<boolean> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.canUndo(tag);
    }
    return Promise.resolve();
  }

  canRedo = (): Promise<void> | Promise<boolean> => {
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

  openThumbnailsView = (): Promise<void> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.openThumbnailsView(tag);
    }
    return Promise.resolve();
  }

  _setNativeRef = (ref) => { // check ref type.
    this._viewerRef = ref;
  };

  render() {
    return (
      <RCTDocumentView
        ref={this._setNativeRef}
        style={{ flex:1 }}
        onChange={this.onChange} // needed to add onChange to props
        {...this.props}
      />
    )
  }
}

const name = Platform.OS === 'ios' ? 'RNTPTDocumentView' : 'RCTDocumentView';


const RCTDocumentView = requireNativeComponent( // https://github.com/facebook/react-native/issues/28351
  name,
  // @ts-ignore
  DocumentView,
  {
    nativeOnly: {
      onChange: true
    }
  }
);
