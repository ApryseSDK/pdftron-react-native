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
    onPageChanged: PropTypes.func,
    onDocumentSaveStart: PropTypes.func,
    onDocumentSaveFinish: PropTypes.func,
    onDocumentSaveFailed: PropTypes.func,
    disabledElements: PropTypes.array,
    disabledTools: PropTypes.array,
    topToolbarEnabled: PropTypes.bool,
    bottomToolbarEnabled: PropTypes.bool,
    pageIndicatorEnabled: PropTypes.bool,
    ...ViewPropTypes,
  };

  onChange = (event) => {
    if (event.nativeEvent.onLeadingNavButtonPressed) {
      if (this.props.onLeadingNavButtonPressed) {
        this.props.onLeadingNavButtonPressed();
      }
    } else if (event.nativeEvent.onDocumentLoaded) {
      if (this.props.onDocumentLoaded) {
        console.log("Executing document load event.");
        this.props.onDocumentLoaded();
      }
    } else if (event.nativeEvent.onPageChanged) {
      if (this.props.onPageChanged) {
        this.props.onPageChanged({
        	'previousPageNumber': event.nativeEvent.previousPageNumber,
        	'pageNumber': event.nativeEvent.pageNumber,
        });
      }
    } else if (event.nativeEvent.onDocumentSaveStart) {
      console.log("Got native event onDocumentSaveStart");
      if (this.props.onDocumentSaveStart) {
        console.log("Executing onDocumentSaveStart callback.");
        this.props.onDocumentSaveStart();
      }
    } else if (event.nativeEvent.onDocumentSaveFinish) {
      console.log("Got native event onDocumentSaveFinish");
      if (this.props.onDocumentSaveFinish) {
        console.log("Executing onDocumentSaveFinsih callback.");
        this.props.onDocumentSaveFinish();
      }
    } else if (event.nativeEvent.onDocumentSaveFailed) {
      if (this.props.onDocumentSaveFailed) {
        this.props.onDocumentSaveFailed(event.nativeEvent.failMessage);
      }
    }
  }

  forceDocumentSave = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      console.log("Doing force save...");
      return DocumentViewManager.forceDocumentSave(tag);
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

  getPageCount = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.getPageCount(tag);
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

  exportAnnotations = () => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.exportAnnotations(tag);
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
