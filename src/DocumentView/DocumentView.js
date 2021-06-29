import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import {
  requireNativeComponent,
  ViewPropTypes,
  Platform,
  Alert,
  NativeModules,
  findNodeHandle
} from 'react-native';
const { DocumentViewManager } = NativeModules;

export default class DocumentView extends PureComponent {

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
    annotationsListEditingEnabled: PropTypes.bool,
    showNavigationListAsSidePanelOnLargeDevices: PropTypes.bool,
    restrictDownloadUsage: PropTypes.bool,
    userBookmarksListEditingEnabled: PropTypes.bool,
    imageInReflowEnabled: PropTypes.bool,
    reflowOrientation: PropTypes.string,
    tabletLayoutEnabled: PropTypes.bool,
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
        this.props.onTextSearchStart(event.nativeEvent.onTextSearchStart);
      }
    } else if (event.nativeEvent.onTextSearchResult) {
      if (this.props.onTextSearchResult) {
        this.props.onTextSearchResult({
          'found': event.nativeEvent.found,
          'textSelection': event.nativeEvent.textSelection,
        });
      }
    }
  }

  getDocumentPath = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getDocumentPath(tag);
    }
    return Promise.resolve();
  }
  
  setToolMode = (toolMode) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
    	return DocumentViewManager.setToolMode(tag, toolMode);
    }
    return Promise.resolve();
  }

  commitTool = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.commitTool(tag);
    }
    return Promise.resolve();
  }

  getPageCount = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageCount(tag);
    }
    return Promise.resolve();
  }

  importBookmarkJson = (bookmarkJson) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.importBookmarkJson(tag, bookmarkJson);
    }
    return Promise.resolve();
  }

  importAnnotationCommand = (xfdfCommand, initialLoad) => {
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

  importAnnotations = (xfdf) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.importAnnotations(tag, xfdf);
    }
    return Promise.resolve();
  }

  exportAnnotations = (options) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.exportAnnotations(tag, options);
    }
    return Promise.resolve();
  }

  flattenAnnotations = (formsOnly) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.flattenAnnotations(tag, formsOnly);
    }
    return Promise.resolve();
  }

  deleteAnnotations = (annotations) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.deleteAnnotations(tag, annotations);
    }
    return Promise.resolve();
  }

  saveDocument = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.saveDocument(tag);
    }
    return Promise.resolve();
  }

  setFlagForFields = (fields, flag, value) => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.setFlagForFields(tag, fields, flag, value);
    }
    return Promise.resolve();
  }

  getField = (fieldName) => {
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
  setValueForFields = (fieldsMap) => {
    return this.setValuesForFields(fieldsMap);
  }

  setValuesForFields = (fieldsMap) => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.setValuesForFields(tag, fieldsMap);
    }
    return Promise.resolve();
  }

  handleBackButton = () => {
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
  setFlagForAnnotations = (annotationFlagList) => {
    return this.setFlagsForAnnotations(annotationFlagList);  
  }
  
  setFlagsForAnnotations = (annotationFlagList) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setFlagsForAnnotations(tag, annotationFlagList);
    }
    return Promise.resolve();
  }

  selectAnnotation = (id, pageNumber) => {
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
  setPropertyForAnnotation = (id, pageNumber, propertyMap) => {
    return setPropertiesForAnnotation(id, pageNumber, propertyMap);
  }

  setPropertiesForAnnotation = (id, pageNumber, propertyMap) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setPropertiesForAnnotation(tag, id, pageNumber, propertyMap);
    }
    return Promise.resolve();
  }

  getPropertiesForAnnotation = (id, pageNumber) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPropertiesForAnnotation(tag, id, pageNumber);
    }
    return Promise.resolve();
  }

  setDrawAnnotations = (drawAnnotations) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setDrawAnnotations(tag, drawAnnotations);
    }
    return Promise.resolve();
  }

  setVisibilityForAnnotation = (id, pageNumber, visibility) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      DocumentViewManager.setVisibilityForAnnotation(tag, id, pageNumber, visibility);
    }
    return Promise.resolve();
  }
  
  setHighlightFields = (highlightFields) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      DocumentViewManager.setHighlightFields(tag, highlightFields);
    }
    return Promise.resolve();
  }

  getAnnotationAtPoint = (x, y, distanceThreshold, minimumLineWeight) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationAtPoint(tag, x, y, distanceThreshold, minimumLineWeight);
    }
    return Promise.resolve();
  }

  getAnnotationListAt = (x1, y1, x2, y2) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationListAt(tag, x1, y1, x2, y2);
    }
    return Promise.resolve();
  }

  getAnnotationsOnPage = (pageNumber) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getAnnotationsOnPage(tag, pageNumber);
    }
    return Promise.resolve();
  }

  getCustomDataForAnnotation = (annotationID, pageNumber, key) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getCustomDataForAnnotation(tag, annotationID, pageNumber, key);
    }
    return Promise.resolve();
  }

  getPageCropBox = (pageNumber) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageCropBox(tag, pageNumber);
    }
    return Promise.resolve();
  }

  setCurrentPage = (pageNumber) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setCurrentPage(tag, pageNumber);
    }
    return Promise.resolve();
  }

  getVisiblePages = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getVisiblePages(tag);
    }
    return Promise.resolve();
  }

  gotoPreviousPage = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoPreviousPage(tag);
    }
    return Promise.resolve();
  }

  gotoNextPage = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoNextPage(tag);
    }
    return Promise.resolve();
  }

  gotoFirstPage = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoFirstPage(tag);
    }
    return Promise.resolve();
  }

  gotoLastPage = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.gotoLastPage(tag);
    }
    return Promise.resolve();
  }

  closeAllTabs = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.closeAllTabs(tag);
    }
    return Promise.resolve();
  }

  getZoom = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getZoom(tag);
    }
    return Promise.resolve();
  }

  setZoomLimits = (zoomLimitMode, minimum, maximum) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setZoomLimits(tag, zoomLimitMode, minimum, maximum);
    }
    return Promise.resolve();
  }

  zoomWithCenter = (zoom, x, y) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.zoomWithCenter(tag, zoom, x, y);
    }
    return Promise.resolve();
  }

  zoomToRect = (pageNumber, rect) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.zoomToRect(tag, pageNumber, rect);
    }
    return Promise.resolve();
  }

  smartZoom = (x, y, animated) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.smartZoom(tag, x, y, animated);
    }
    return Promise.resolve();
  }
  
  getScrollPos = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getScrollPos(tag);
    }
    return Promise.resolve();
  }
    
  getCanvasSize = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getCanvasSize(tag);
    }
    return Promise.resolve();
  }

  getPageRotation = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageRotation(tag);
    }
    return Promise.resolve();
  }

  rotateClockwise = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.rotateClockwise(tag);
    }
    return Promise.resolve();
  }

  rotateCounterClockwise = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.rotateCounterClockwise(tag);
    }
    return Promise.resolve();
  }


  convertScreenPointsToPagePoints = (points) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.convertScreenPointsToPagePoints(tag, points);
    }
    return Promise.resolve();
  }

  convertPagePointsToScreenPoints = (points) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.convertPagePointsToScreenPoints(tag, points);
    }
    return Promise.resolve();
  }

  getPageNumberFromScreenPoint = (x, y) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageNumberFromScreenPoint(tag, x, y);
    }
    return Promise.resolve();
  }

  setProgressiveRendering = (progressiveRendering, initialDelay, interval) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setProgressiveRendering(tag, progressiveRendering, initialDelay, interval);
    }
    return Promise.resolve();
  }

  setImageSmoothing = (imageSmoothing) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setImageSmoothing(tag, imageSmoothing);
    }
    return Promise.resolve();
  }

  setOverprint = (overprint) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setOverprint(tag, overprint);
    }
    return Promise.resolve();
  }

  setColorPostProcessMode = (colorPostProcessMode) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      DocumentViewManager.setColorPostProcessMode(tag, colorPostProcessMode);
    }
    return Promise.resolve();
  }

  setColorPostProcessColors = (whiteColor, blackColor) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setColorPostProcessColors(tag, whiteColor, blackColor);
    }
    return Promise.resolve();
  }    

  findText = (searchString, matchCase, matchWholeWord, searchUp, regExp) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.findText(tag, searchString, matchCase, matchWholeWord, searchUp, regExp);
    }
    return Promise.resolve();
  }

  cancelFindText = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.cancelFindText(tag);
    }
    return Promise.resolve();
  }

  getSelection = (pageNumber) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getSelection(tag, pageNumber);
    }
    return Promise.resolve();
  }

  hasSelection = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.hasSelection(tag);
    }
    return Promise.resolve();
  }

  clearSelection = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.clearSelection(tag);
    }
    return Promise.resolve();
  }

  getSelectionPageRange = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getSelectionPageRange(tag);
    }
    return Promise.resolve();
  }

  hasSelectionOnPage = (pageNumber) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.hasSelectionOnPage(tag, pageNumber);
    }
    return Promise.resolve();
  }

  
  selectInRect = (rect) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.selectInRect(tag, rect);
    }
    return Promise.resolve();
  }

  isThereTextInRect = (rect) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.isThereTextInRect(tag, rect);
    }
    return Promise.resolve();
  }

  selectAll = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.selectAll(tag);
    }
    return Promise.resolve();
  }


  setUrlExtraction = (urlExtraction) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.setUrlExtraction(tag, urlExtraction);
    }
    return Promise.resolve();
  }

  setPageBorderVisibility = (pageBorderVisibility) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.setPageBorderVisibility(tag, pageBorderVisibility);
    }
    return Promise.resolve();
  }

  setPageTransparencyGrid = (pageTransparencyGrid) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setPageTransparencyGrid(tag, pageTransparencyGrid);
    }
    return Promise.resolve();
  }

  setDefaultPageColor = (defaultPageColor) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.setDefaultPageColor(tag, defaultPageColor);
    }
    return Promise.resolve();
  }

  setBackgroundColor = (backgroundColor) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.setBackgroundColor(tag, backgroundColor);
    }
    return Promise.resolve();
  }

  exportAsImage = (pageNumber, dpi, exportFormat) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.exportAsImage(tag, pageNumber, dpi, exportFormat);
    }
    return Promise.resolve();
  }

  undo = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.undo(tag);
    }
    return Promise.resolve();
  }

  redo = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.redo(tag);
    }
    return Promise.resolve();
  }

  showCrop = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
       return DocumentViewManager.showCrop(tag);
    }
    return Promise.resolve();
  }

  _setNativeRef = (ref) => {
    this._viewerRef = ref;
  };

  render() {
    return (
      <RCTDocumentView
        ref={this._setNativeRef}
        style={{ flex:1 }}
        onChange={this.onChange}
        {...this.props}
      />
    )
  }
}

const name = Platform.OS === 'ios' ? 'RNTPTDocumentView' : 'RCTDocumentView';

const RCTDocumentView = requireNativeComponent(
  name,
  DocumentView,
  {
    nativeOnly: {
      onChange: true
    }
  }
);
