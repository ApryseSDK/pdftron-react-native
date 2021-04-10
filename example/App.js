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
        `<?xml version="1.0" encoding="UTF-8"?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><add><highlight style="solid" width="1" color="#FFFF00" opacity="1" creationdate="D:20210405132121Z" flags="print" date="D:20210405132121Z" name="22DE6A5C-7F90-4853-AB13-87E9DC125271" page="0" coords="237.02,637.72,374.972,637.72,237.02,596.212,374.972,596.212" rect="232.698,596.212,379.294,637.72" title="Tiago Duarte" xmlns="http://ns.adobe.com/xfdf/"><popup date="D:20210405132121Z" page="0" rect="232.698,596.212,379.294,637.72"/><contents>Contract</contents><apref blend-mode="multiply" y="637.72" x="232.698" gennum="1" objnum="765"/></highlight></add><modify /><delete /><pdf-info import-version="3" version="2" xmlns="http://www.pdftron.com/pdfinfo" /></xfdf>`,
        `<?xml version="1.0" encoding="UTF-8"?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><add><freetext TextColor="#E34134" style="solid" width="0" creationdate="D:20210409204619Z" flags="print" date="D:20210409204619Z" name="281DE170-3E43-430E-A6F1-355B48691051" page="0" rect="216.968,407.902,284.274,426.303" title="Maxwell"><defaultstyle>font: Helvetica 16pt;color: #E34134</defaultstyle><defaultappearance> 1 1 1 RG 1 1 1 rg /F0 16 Tf </defaultappearance><contents>PDFTron</contents><apref y="426.303" x="216.968" gennum="0" objnum="933" /></freetext></add><modify /><delete /><pdf-info import-version="3" version="2" xmlns="http://www.pdftron.com/pdfinfo" /></xfdf>`
      ],
      [
        `<?xml version="1.0" encoding="UTF-8"?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><add><highlight style="solid" width="1" color="#FFFF00" opacity="1" creationdate="D:20210405132121Z" flags="print" date="D:20210405132121Z" name="22DE6A5C-7F90-4853-AB13-87E9DC125272" page="1" coords="237.02,637.72,374.972,637.72,237.02,596.212,374.972,596.212" rect="232.698,596.212,379.294,637.72" title="Tiago Duarte" xmlns="http://ns.adobe.com/xfdf/"><popup date="D:20210405132121Z" page="1" rect="232.698,596.212,379.294,637.72"/><contents>Contract</contents><apref blend-mode="multiply" y="637.72" x="232.698" gennum="1" objnum="765"/></highlight></add><modify /><delete /><pdf-info import-version="3" version="2" xmlns="http://www.pdftron.com/pdfinfo" /></xfdf>`,
        `<?xml version="1.0" encoding="UTF-8"?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><add><freetext TextColor="#E34134" style="solid" width="0" creationdate="D:20210409204619Z" flags="print" date="D:20210409204619Z" name="281DE170-3E43-430E-A6F1-355B48691052" page="1" rect="216.968,407.902,284.274,426.303" title="Maxwell"><defaultstyle>font: Helvetica 16pt;color: #E34134</defaultstyle><defaultappearance> 1 1 1 RG 1 1 1 rg /F0 16 Tf </defaultappearance><contents>PDFTron</contents><apref y="426.303" x="216.968" gennum="0" objnum="933" /></freetext></add><modify /><delete /><pdf-info import-version="3" version="2" xmlns="http://www.pdftron.com/pdfinfo" /></xfdf>`
      ],
      [
        `<?xml version="1.0" encoding="UTF-8"?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><add><highlight style="solid" width="1" color="#FFFF00" opacity="1" creationdate="D:20210405132121Z" flags="print" date="D:20210405132121Z" name="22DE6A5C-7F90-4853-AB13-87E9DC125273" page="2" coords="237.02,637.72,374.972,637.72,237.02,596.212,374.972,596.212" rect="232.698,596.212,379.294,637.72" title="Tiago Duarte" xmlns="http://ns.adobe.com/xfdf/"><popup date="D:20210405132121Z" page="2" rect="232.698,596.212,379.294,637.72"/><contents>Contract</contents><apref blend-mode="multiply" y="637.72" x="232.698" gennum="1" objnum="765"/></highlight></add><modify /><delete /><pdf-info import-version="3" version="2" xmlns="http://www.pdftron.com/pdfinfo" /></xfdf>`,
        `<?xml version="1.0" encoding="UTF-8"?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><add><freetext TextColor="#E34134" style="solid" width="0" creationdate="D:20210409204619Z" flags="print" date="D:20210409204619Z" name="281DE170-3E43-430E-A6F1-355B48691053" page="2" rect="216.968,407.902,284.274,426.303" title="Maxwell"><defaultstyle>font: Helvetica 16pt;color: #E34134</defaultstyle><defaultappearance> 1 1 1 RG 1 1 1 rg /F0 16 Tf </defaultappearance><contents>PDFTron</contents><apref y="426.303" x="216.968" gennum="0" objnum="933" /></freetext></add><modify /><delete /><pdf-info import-version="3" version="2" xmlns="http://www.pdftron.com/pdfinfo" /></xfdf>`
      ]
    ];

    console.log(pageNumber);
    if (pageNumber >= 1 && pageNumber <= 3) {
      // import annotation based on current page. pageNumber from this event is 1-indexed
      for (const annotationCommand of annotationCommandsForPages[pageNumber - 1]) {
        this._viewer.importAnnotationCommand(annotationCommand);
      }
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
          onPageChanged={this.onPageChanged}
          padStatusBar
          collabEnabled
          currentUser={'Tiago Duarte'}
          currentUserName={'Tiago Duarte'}
        />
    );
  }
}
