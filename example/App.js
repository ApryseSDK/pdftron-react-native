import React, { Component } from 'react';

import { DocumentView, RNPdftron } from 'react-native-pdftron';

type Props = {};
export default class App extends Component<Props> {

  constructor(props) {
    super(props);

    RNPdftron.initialize("");
  }

  onDocumentLoaded = () => {
    console.log('leading nav button pressed');
    if (this._viewer) {
      this._viewer.importAnnotations(`<?xml version="1.0" encoding="UTF-8" ?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><annots><highlight style="solid" width="1" color="#FFFF00" opacity="1" creationdate="D:20210405132121Z" flags="print" date="D:20210405132121Z" name="22DE6A5C-7F90-4853-AB13-87E9DC125271" page="0" coords="237.02,637.72,374.972,637.72,237.02,596.212,374.972,596.212" rect="232.698,596.212,379.294,637.72" title="Tiago Duarte" xmlns="http://ns.adobe.com/xfdf/"><popup date="D:20210405132121Z" page="0" rect="232.698,596.212,379.294,637.72"/><contents>Contract</contents><apref blend-mode="multiply" y="637.72" x="232.698" gennum="1" objnum="765"/></highlight></annots></xfdf>`);
    }
  }

  render() {
    const path = "https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_about.pdf";

    return (
      <DocumentView
          ref={(c) => this._viewer = c}
          document={path}
          hideToolbarsOnTap={false}
          onDocumentLoaded={this.onDocumentLoaded}
          padStatusBar
          collabEnabled
          currentUser={'Tiago Duarte'}
          currentUserName={'Tiago Duarte'}
        />
    );
  }
}
