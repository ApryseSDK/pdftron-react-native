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
    // if (this._viewer) {
    //   const xfdf = '<?xml version="1.0" encoding="UTF-8"?>\n<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">\n\t<annots>\n\t\t<circle style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20190729202215Z" flags="print" date="D:20190729202215Z" page="0" rect="138.824,653.226,236.28,725.159" title="" />\n\t\t<circle style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20190729202215Z" flags="print" date="D:20190729202215Z" page="0" rect="103.114,501.958,245.067,590.92" title="" />\n\t\t<circle style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20190729202216Z" flags="print" date="D:20190729202216Z" page="0" rect="117.85,336.548,328.935,451.568" title="" />\n\t\t<freetext TextColor="#363636" style="solid" width="0" opacity="1" creationdate="D:20190729202455Z" flags="print" date="D:20190729202513Z" page="0" rect="320.774,646.323,550.446,716.498" title="">\n\t\t\t<defaultstyle>font: Roboto 24pt;color: #363636</defaultstyle>\n\t\t\t<defaultappearance> 1 1 1 RG 1 1 1 rg /F0 24 Tf </defaultappearance>\n\t\t\t<contents>HELLO PDFTRON!!!</contents>\n\t\t\t<apref y="716.498" x="320.774" gennum="0" objnum="404" />\n\t\t</freetext>\n\t\t<line style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20190729202507Z" flags="print" start="278.209,212.495" end="214.177,411.627" head="None" tail="OpenArrow" date="D:20190729202507Z" page="0" rect="206.039,211.73,280.589,416.387" title="" />\n\t</annots>\n\t<pages>\n\t\t<defmtx matrix="1.333333,0.000000,0.000000,-1.333333,0.000000,1056.000000" />\n\t</pages>\n\t<pdf-info version="2" xmlns="http://www.pdftron.com/pdfinfo" />\n</xfdf>';
    //   this._viewer.importAnnotations(xfdf);
    // }
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
    console.log('zoom', zoom);
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
          onZoomChanged={this.onZoomChanged}
          readOnly={false}
          disabledElements={[Config.Buttons.moreItemsButton, Config.Buttons.userBookmarkListButton]}
          disabledTools={[Config.Tools.annotationCreateLine, Config.Tools.annotationCreateRectangle]}
          fitMode={Config.FitMode.FitPage}
          layoutMode={Config.LayoutMode.Continuous}
        />
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  }
});
