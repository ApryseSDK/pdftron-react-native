import React, { Component } from 'react';
import {
  Platform,
  StyleSheet,
  Text,
  View,
  PermissionsAndroid,
  BackHandler,
  Alert
} from 'react-native';

import { DocumentView, RNPdftron, Config } from 'react-native-pdftron';

type Props = {};
export default class App extends Component<Props> {

  constructor(props) {
    super(props);
  }

  onLeadingNavButtonPressed = () => {
    console.log('leading nav button pressed');
    if (this._viewer) {
      this._viewer.setStampImageData().then((annotationId, pageNumber, stampImageDataUrl) => {
        annotationID = '75911d3a-f1fa-7a4f-8137-5885e3a4c4ae',
        pageNumber = 1,
        stampImageData = 'https://media.sproutsocial.com/uploads/2017/02/10x-featured-social-media-image-size.png';
      });
    }

    if (Platform.OS === 'ios') {
      Alert.alert(
        'App',
        'onLeadingNavButtonPressed',
        [
          {text: 'OK', onPress: () => console.log('OK Pressed')},
        ],
        { cancelable: true }
      )
    } else {
      BackHandler.exitApp();
    }
  }

  onDocumentLoaded = () => {
    if (this._viewer) {
      console.log('this._viewer', this._viewer.addAnnotation('Text', 40, 40, 60, 80));
    }
  }

  onAnnotationChanged = ({action, annotations}) => {
    // console.log('action', action);
    // console.log('annotations', annotations);
    // if (this._viewer) {
    //   this._viewer.exportAnnotations({annotList: annotations}).then((xfdf) => {
    //     console.log('xfdf for annotations', xfdf);
    //   });
    // }
  }

  onZoomChanged = ({zoom}) => {
    // console.log('zoom', zoom);
  }

  onExportAnnotationCommand = ({action, xfdfCommand}) => {
    console.log('action', action);
    console.log('xfdfCommand', xfdfCommand);
  }

  setStampImageData = ({annotationId, pageNumber, stampImageDataUrl}) => {
    annotationID = '75911d3a-f1fa-7a4f-8137-5885e3a4c4ae',
    pageNumber = 1,
    stampImageData = 'https://media.sproutsocial.com/uploads/2017/02/10x-featured-social-media-image-size.png';
  }

  render() {
    const path = "https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_about.pdf";
    const myToolbar = {
      [Config.CustomToolbarKey.Id]: 'myToolbar',
      [Config.CustomToolbarKey.Name]: 'myToolbar', 
      [Config.CustomToolbarKey.Icon]: Config.ToolbarIcons.FillAndSign,
      [Config.CustomToolbarKey.Items]: [Config.Tools.annotationCreateArrow, Config.Tools.annotationCreateCallout, Config.Buttons.undo]
    };

    return (
      <DocumentView
          ref={(c) => this._viewer = c}
          // hideDefaultAnnotationToolbars={[Config.DefaultToolbars.Annotate]}
          // annotationToolbars={[Config.DefaultToolbars.Annotate, myToolbar]}
          hideAnnotationToolbarSwitcher={false}
          hideTopToolbars={false}
          hideTopAppNavBar={false}
          document={path}
          padStatusBar={true}
          showLeadingNavButton={true}
          leadingNavButtonIcon={Platform.OS === 'ios' ? 'ic_close_black_24px.png' : 'ic_arrow_back_white_24dp'}
          onLeadingNavButtonPressed={this.onLeadingNavButtonPressed}
          onDocumentLoaded={this.onDocumentLoaded}
          onAnnotationChanged={this.onAnnotationChanged}
          onExportAnnotationCommand={this.onExportAnnotationCommand}
          onZoomChanged={this.onZoomChanged}
          readOnly={false}
          disabledElements={[Config.Buttons.userBookmarkListButton]}
          disabledTools={[Config.Tools.annotationCreateLine, Config.Tools.annotationCreateRectangle]}
          fitMode={Config.FitMode.FitPage}
          layoutMode={Config.LayoutMode.Continuous}
          setStampImageData = {this.setStampImageData}
          openOutlineList = {true}
        />
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  }
});
