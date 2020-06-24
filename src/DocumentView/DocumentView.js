import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import {
  requireNativeComponent,
  ViewPropTypes,
  Platform,
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
    onZoomChanged: PropTypes.func,
    disabledElements: PropTypes.array,
    disabledTools: PropTypes.array,
    longPressMenuItems: PropTypes.array,
    overrideLongPressMenuBehavior: PropTypes.array,
    onLongPressMenuPress: PropTypes.func,
    annotationMenuItems: PropTypes.array,
    overrideAnnotationMenuBehavior: PropTypes.array,
    onAnnotationMenuPress: PropTypes.func,
    hideAnnotationMenu: PropTypes.array,
    overrideBehavior: PropTypes.array,
    onBehaviorActivated: PropTypes.func,
    topToolbarEnabled: PropTypes.bool,
    bottomToolbarEnabled: PropTypes.bool,
    pageIndicatorEnabled: PropTypes.bool,
    onAnnotationsSelected: PropTypes.func,
    onAnnotationChanged: PropTypes.func,
    readOnly: PropTypes.bool,
    thumbnailViewEditingEnabled: PropTypes.bool,
    fitMode: PropTypes.string,
    layoutMode: PropTypes.string,
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
    ...ViewPropTypes,
  };

  onChange = (event) => {
    if (event.nativeEvent.onLeadingNavButtonPressed) {
      if (this.props.onLeadingNavButtonPressed) {
        this.props.onLeadingNavButtonPressed();
      }
    } else if (event.nativeEvent.onDocumentLoaded) {
      if (this.props.onDocumentLoaded) {
        this.props.onDocumentLoaded();
      }
    } else if (event.nativeEvent.onPageChanged) {
      if (this.props.onPageChanged) {
        this.props.onPageChanged({
        	'previousPageNumber': event.nativeEvent.previousPageNumber,
        	'pageNumber': event.nativeEvent.pageNumber,
        });
      }
    } else if (event.nativeEvent.onZoomChanged) {
      if (this.props.onZoomChanged) {
        this.props.onZoomChanged({
        	'zoom': event.nativeEvent.zoom,
        });
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
    } else if (event.nativeEvent.onDocumentError) {
      if (this.props.onDocumentError) {
        this.props.onDocumentError();
      }
    } else if (event.nativeEvent.onExportAnnotationCommand) {
      if (this.props.onExportAnnotationCommand) {
        this.props.onExportAnnotationCommand({
          'action': event.nativeEvent.action,
          'xfdfCommand': event.nativeEvent.xfdfCommand,
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
    }
  }

  setToolMode = (toolMode) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
    	DocumentViewManager.setToolMode(tag, toolMode);
    }
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

  importAnnotationCommand = (xfdfCommand, initialLoad) => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
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

  setValueForFields = (fieldsMap) => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.setValueForFields(tag, fieldsMap);
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
