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

    RNPdftron.initialize("");
  }

  onLeadingNavButtonPressed = () => {
    console.log('leading nav button pressed');
    if (this._viewer) {
      this._viewer.exportAnnotations().then((xfdf) => {
        console.log('xfdf', xfdf);
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
      const xfdf = '<?xml version="1.0" encoding="UTF-8"?>\n<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">\n<add>\n<square style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20200831150749Z" flags="print,locked" date="D:20200831150749Z" name="1ebcb769-fdf6-4640-8840-ca2725e11dff" page="0" fringe="0,0,0,0" rect="132.938,176.482,440.414,251.448" title="bob" />\n</add>\n<modify />\n<delete />\n<pdf-info import-version="3" version="2" xmlns="http://www.pdftron.com/pdfinfo" />\n</xfdf>';
      this._viewer.importAnnotations(xfdf);
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

  render() {
    const path = "https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_mobile_about.pdf";

    return (
      <DocumentView
          ref={(c) => this._viewer = c}
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
          annotationPermissionCheckEnabled={true}
        />
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  }
});
