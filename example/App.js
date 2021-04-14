import React, { Component } from 'react';

import { DocumentView, RNPdftron } from 'react-native-pdftron';

type Props = {};

export default class App extends Component<Props> {

  constructor(props) {
    super(props);

    RNPdftron.initialize("");
  }

  onPageChanged = ({pageNumber}) => {
    // 2 annotation commands for page 1 to 3, each page containing an add command for a highlight from Tiago Duarte, and a text from Maxwell
    const annotationCommandsForPages = [
      [
        // used to be: `<?xml version="1.0" encoding="UTF-8" ?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><annots><highlight page="1" rect="237.02,596.212,374.972,637.7199999999999" color="#FFCD45" flags="print" name="9c180db5-899b-2b3f-4cbf-8cef7e98b2e9" title="Tiago Duarte" subject="Highlight" date="D:20210413171202+01'00'" creationdate="D:20210413171202+01'00'" coords="237.02,637.7199999999999,374.972,637.7199999999999,237.02,596.212,374.972,596.212"><contents>Contract</contents></highlight></annots></xfdf>`,
        `<?xml version="1.0" encoding="UTF-8" ?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><add><highlight page="0" rect="237.02,596.212,374.972,637.7199999999999" color="#FFCD45" flags="print" name="9c180db5-899b-2b3f-4cbf-8cef7e98b2e9" title="Tiago Duarte" subject="Highlight" date="D:20210413171202+01'00'" creationdate="D:20210413171202+01'00'" coords="237.02,637.7199999999999,374.972,637.7199999999999,237.02,596.212,374.972,596.212"><contents>Contract</contents></highlight></add><modify /><delete /><pdf-info import-version="3" version="2" xmlns="http://www.pdftron.com/pdfinfo" /></xfdf>`
      ],
      [
        // used to be: `<?xml version="1.0" encoding="UTF-8" ?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><annots><highlight page="2" rect="216.02,465.39256,382.8014000000001,482.02876" color="#FFCD45" flags="print" name="3d2b21f0-ebe6-9a49-18d0-cdd372e8077a" title="Another User" subject="Highlight" date="D:20210413171402+01'00'" creationdate="D:20210413171402+01'00'" coords="216.02,482.02876,382.8014000000001,482.02876,216.02,465.39256,382.8014000000001,465.39256"><contents>THIS PAGE LEFT BLANK</contents></highlight></annots></xfdf>`,
        `<?xml version="1.0" encoding="UTF-8" ?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><add><highlight page="1" rect="216.02,465.39256,382.8014000000001,482.02876" color="#FFCD45" flags="print" name="3d2b21f0-ebe6-9a49-18d0-cdd372e8077a" title="Another User" subject="Highlight" date="D:20210413171402+01'00'" creationdate="D:20210413171402+01'00'" coords="216.02,482.02876,382.8014000000001,482.02876,216.02,465.39256,382.8014000000001,465.39256"><contents>THIS PAGE LEFT BLANK</contents></highlight></add><modify /><delete /><pdf-info import-version="3" version="2" xmlns="http://www.pdftron.com/pdfinfo" /></xfdf>`
      ],
    ];

    console.log(pageNumber);
    if (pageNumber >= 1 && pageNumber <= 2) {
      // import annotation based on current page. pageNumber from this event is 1-indexed
      for (const annotationCommand of annotationCommandsForPages[pageNumber - 1]) {
        this._viewer.importAnnotationCommand(annotationCommand);
      }
    }
  }

  render() {
    const path = "https://spexbook-public.s3.us-east-2.amazonaws.com/example.pdf";

    return (
      <DocumentView
          ref={(c) => this._viewer = c}
          document={path}
          hideToolbarsOnTap={false}
          onDocumentLoaded={this.onDocumentLoaded}
          onPageChanged={this.onPageChanged}
          padStatusBar
          collabEnabled
          currentUser={'Tiago Duarte'}
          currentUserName={'Tiago Duarte'}
        />
    );
  }
}