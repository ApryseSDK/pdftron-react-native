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

import { DocumentView, RNPdftron, Config, AnnotOptions } from 'react-native-pdftron';

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
        this._viewer.addAnnotation('Text', 'text1', 2, 40, 40, 400, 80)
        .then((onFullfiled) => {
          console.log('onFullfiled', onFullfiled);
        })
        .catch((error) => {
          console.log('error', error);
        })

        this._viewer.addAnnotation('Text', 'text2', 1, 40, 40, 400, 80)
        .then((onFullfiled) => {
          console.log('onFullfiled', onFullfiled);
        })
        .catch((error) => {
          console.log('error', error);
        })

        this._viewer.addAnnotation('Sign', 'signature1', 1, 40, 100, 600, 200)
        .then((onFullfiled) => {
          console.log('onFullfiled', onFullfiled);
        })
        .catch((error) => {
          console.log('error', error);
        })

        this._viewer.addAnnotation('Sign', 'signature2', 2, 40, 100, 600, 200)
        .then((onFullfiled) => {
          console.log('onFullfiled', onFullfiled);
        })
        .catch((error) => {
          console.log('error', error);
        })
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
          hideDefaultAnnotationToolbars={[
            Config.DefaultToolbars.Annotate,
            Config.DefaultToolbars.Draw,
            Config.DefaultToolbars.Insert,
            Config.DefaultToolbars.FillAndSign,
            Config.DefaultToolbars.PrepareForm,
            Config.DefaultToolbars.Measure,
            Config.DefaultToolbars.Pens,
            Config.DefaultToolbars.Redaction,
            Config.DefaultToolbars.Favorite,
          ]}
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
          disabledElements={[
            Config.Buttons.editToolButton,
            Config.Buttons.viewControlsButton,
            Config.Buttons.freeHandToolButton,
            Config.Buttons.highlightToolButton,
            Config.Buttons.underlineToolButton,
            Config.Buttons.squigglyToolButton,
            Config.Buttons.strikeoutToolButton,
            Config.Buttons.rectangleToolButton,
            Config.Buttons.ellipseToolButton,
            Config.Buttons.lineToolButton,
            Config.Buttons.arrowToolButton,
            Config.Buttons.polylineToolButton,
            Config.Buttons.polygonToolButton,
            Config.Buttons.cloudToolButton,
            Config.Buttons.signatureToolButton,
            Config.Buttons.freeTextToolButton,
            Config.Buttons.stickyToolButton,
            Config.Buttons.calloutToolButton,
            Config.Buttons.stampToolButton,
            Config.Buttons.toolsButton,
            Config.Buttons.searchButton,
            Config.Buttons.shareButton,
            Config.Buttons.editPagesButton,
            Config.Buttons.viewLayersButton,
            Config.Buttons.printButton,
            Config.Buttons.closeButton,
            Config.Buttons.saveCopyButton,
            Config.Buttons.saveIdenticalCopyButton,
            Config.Buttons.saveFlattenedCopyButton,
            Config.Buttons.formToolsButton,
            Config.Buttons.fillSignToolsButton,
            Config.Buttons.moreItemsButton,
            Config.Buttons.digitalSignatureButton,
            Config.Buttons.thumbnailsButton,
            Config.Buttons.listsButton,
            Config.Buttons.thumbnailSlider,
            Config.Buttons.outlineListButton,
            Config.Buttons.annotationListButton,
            Config.Buttons.userBookmarkListButton,
            Config.Buttons.reflowButton,
            Config.Buttons.editMenuButton,
            Config.Buttons.cropPageButton,
            Config.Buttons.undo,
            Config.Buttons.redo,
            Config.Buttons.addPageButton,
            Config.Buttons.insertPageButton,
            Config.Buttons.saveCroppedCopyButton,
            Config.Buttons.InsertBlankPage,
            Config.Buttons.InsertFromImage,
            Config.Buttons.InsertFromDocument,
            Config.Buttons.InsertFromPhoto,
            Config.Buttons.InsertFromScanner,
            Config.Buttons.saveReducedCopyButton,
          ]}
          disabledTools={[
            Config.Tools.annotationEdit,
            Config.Tools.textSelect,
            Config.Tools.multiSelect,
            Config.Tools.pan,
            Config.Tools.annotationEraserTool,
            Config.Tools.annotationCountTool,
            Config.Tools.annotationCreateSticky,
            Config.Tools.annotationCreateFreeHand,
            Config.Tools.annotationCreateTextHighlight,
            Config.Tools.annotationCreateTextUnderline,
            Config.Tools.annotationCreateTextSquiggly,
            Config.Tools.annotationCreateTextStrikeout,
            Config.Tools.annotationCreateFreeText,
            Config.Tools.annotationCreateCallout,
            Config.Tools.annotationCreateSignature,
            Config.Tools.annotationCreateLine,
            Config.Tools.annotationCreateArrow,
            Config.Tools.annotationCreatePolyline,
            Config.Tools.annotationCreateStamp,
            Config.Tools.annotationCreateRubberStamp,
            Config.Tools.annotationCreateRectangle,
            Config.Tools.annotationCreateEllipse,
            Config.Tools.annotationCreatePolygon,
            Config.Tools.annotationCreatePolygonCloud,
            Config.Tools.annotationCreateDistanceMeasurement,
            Config.Tools.annotationCreatePerimeterMeasurement,
            Config.Tools.annotationCreateAreaMeasurement,
            Config.Tools.annotationCreateFileAttachment,
            Config.Tools.annotationCreateSound,
            Config.Tools.annotationCreateRedaction,
            Config.Tools.annotationCreateLink,
            Config.Tools.annotationCreateRedactionText,
            Config.Tools.annotationCreateFreeHighlighter,
            Config.Tools.annotationCreateSmartPen,
            Config.Tools.annotationCreateFreeTextDate,
            // Config.Tools.formCreateTextField,
            Config.Tools.formCreateCheckboxField,
            // Config.Tools.formCreateSignatureField,
            Config.Tools.formCreateRadioField,
            Config.Tools.formCreateComboBoxField,
            Config.Tools.formCreateListBoxField,
            // Config.Tools.formFill,
            Config.Tools.insertPage,
            Config.Tools.pencilKitDrawing,
          ]}
          fitMode={Config.FitMode.FitPage}
          layoutMode={Config.LayoutMode.Continuous}
          setStampImageData = {this.setStampImageData}
          openOutlineList = {true}
          signatureColors={[{red: 0, green: 0, blue: 0}]}
          signatureTypes={[0]}
        />
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  }
});
