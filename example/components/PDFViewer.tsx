import React from 'react';
import {
  Platform,
  StyleSheet,
  PermissionsAndroid,
  BackHandler,
  Alert,
  View,
} from 'react-native';

import * as FileSystem from 'expo-file-system';
import {StackScreenProps} from '@react-navigation/stack';
import {useSafeAreaInsets} from 'react-native-safe-area-context';

import {DocumentView, RNPdftron, Config} from 'react-native-pdftron';

type PDFViewerParams = {
  PDFViewer: {currDir: string; path: string};
};

type PDFViewerProps = StackScreenProps<PDFViewerParams, 'PDFViewer'>;

const PDFViewer = ({navigation, route}: PDFViewerProps) => {
  const _viewer = React.useRef<DocumentView>(null);
  const insets = useSafeAreaInsets();

  const root: string = FileSystem.documentDirectory || '';
  const path =
    route?.params?.path !== undefined
      ? route?.params?.path + '/' + route.params.currDir
      : root;

  const myToolbar = {
    [Config.CustomToolbarKey.Id]: 'myToolbar',
    [Config.CustomToolbarKey.Name]: 'myToolbar',
    [Config.CustomToolbarKey.Icon]: Config.ToolbarIcons.FillAndSign,
    [Config.CustomToolbarKey.Items]: [
      Config.Tools.annotationCreateArrow,
      Config.Tools.annotationCreateCallout,
      Config.Buttons.undo,
    ],
  };

  const onLeadingNavButtonPressed = () => {
    if (navigation.canGoBack()) navigation.goBack();

    // console.log('leading nav button pressed');
    // if (_viewer.current) {
    //   _viewer.current.exportAnnotations().then(xfdf => {
    //     console.log('xfdf', xfdf);
    //   });
    // }
    //
    // if (Platform.OS === 'ios') {
    //   Alert.alert(
    //     'App',
    //     'onLeadingNavButtonPressed',
    //     [{text: 'OK', onPress: () => console.log('OK Pressed')}],
    //     {cancelable: true},
    //   );
    // } else {
    //   BackHandler.exitApp();
    // }
  };

  const onDocumentLoaded = () => {
    // if (_viewer.current) {
    //   const xfdf =
    //     '<?xml version="1.0" encoding="UTF-8"?>\n<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">\n\t<annots>\n\t\t<circle style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20190729202215Z" flags="print" date="D:20190729202215Z" page="0" rect="138.824,653.226,236.28,725.159" title="" />\n\t\t<circle style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20190729202215Z" flags="print" date="D:20190729202215Z" page="0" rect="103.114,501.958,245.067,590.92" title="" />\n\t\t<circle style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20190729202216Z" flags="print" date="D:20190729202216Z" page="0" rect="117.85,336.548,328.935,451.568" title="" />\n\t\t<freetext TextColor="#363636" style="solid" width="0" opacity="1" creationdate="D:20190729202455Z" flags="print" date="D:20190729202513Z" page="0" rect="320.774,646.323,550.446,716.498" title="">\n\t\t\t<defaultstyle>font: Roboto 24pt;color: #363636</defaultstyle>\n\t\t\t<defaultappearance> 1 1 1 RG 1 1 1 rg /F0 24 Tf </defaultappearance>\n\t\t\t<contents>HELLO PDFTRON!!!</contents>\n\t\t\t<apref y="716.498" x="320.774" gennum="0" objnum="404" />\n\t\t</freetext>\n\t\t<line style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20190729202507Z" flags="print" start="278.209,212.495" end="214.177,411.627" head="None" tail="OpenArrow" date="D:20190729202507Z" page="0" rect="206.039,211.73,280.589,416.387" title="" />\n\t</annots>\n\t<pages>\n\t\t<defmtx matrix="1.333333,0.000000,0.000000,-1.333333,0.000000,1056.000000" />\n\t</pages>\n\t<pdf-info version="2" xmlns="http://www.pdftron.com/pdfinfo" />\n</xfdf>';
    //   _viewer.current.importAnnotations(xfdf);
    // }
  };

  const onAnnotationChanged = ({
    action,
    annotations,
  }: {
    action: string;
    annotations: [];
  }) => {
    // console.log('action', action);
    // console.log('annotations', annotations);
    // if (_viewer.current) {
    //   _viewer.current.exportAnnotations({annotList: annotations}).then(xfdf => {
    //     console.log('xfdf for annotations', xfdf);
    //   });
    // }
  };

  const onZoomChanged = ({zoom}: {zoom: number}) => {
    // console.log('zoom', zoom);
  };

  const onExportAnnotationCommand = ({
    action,
    xfdfCommand,
  }: {
    action: string;
    xfdfCommand: string;
  }) => {
    console.log('action', action);
    console.log('xfdfCommand', xfdfCommand);
  };

  return (
    <View
      style={[
        styles.container,
        Platform.OS === 'android' ? {paddingTop: insets.top} : {},
      ]}>
      <DocumentView
        ref={_viewer}
        // hideDefaultAnnotationToolbars={[Config.DefaultToolbars.Annotate]}
        // annotationToolbars={[Config.DefaultToolbars.Annotate, myToolbar]}
        hideAnnotationToolbarSwitcher={false}
        hideTopToolbars={false}
        hideTopAppNavBar={false}
        document={path}
        padStatusBar={true}
        showLeadingNavButton={true}
        leadingNavButtonIcon={
          Platform.OS === 'ios'
            ? 'ic_close_black_24px.png'
            : 'ic_arrow_back_white_24dp'
        }
        onLeadingNavButtonPressed={onLeadingNavButtonPressed}
        onDocumentLoaded={onDocumentLoaded}
        onAnnotationChanged={onAnnotationChanged}
        onExportAnnotationCommand={onExportAnnotationCommand}
        onZoomChanged={onZoomChanged}
        readOnly={false}
        disabledElements={[Config.Buttons.userBookmarkListButton]}
        disabledTools={[
          Config.Tools.annotationCreateLine,
          Config.Tools.annotationCreateRectangle,
        ]}
        fitMode={Config.FitMode.FitPage}
        layoutMode={Config.LayoutMode.Continuous}
      />
    </View>
  );
};

export default PDFViewer;

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
});
