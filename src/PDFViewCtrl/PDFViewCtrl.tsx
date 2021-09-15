import React, { PureComponent } from 'react';
import PropTypes, { InferProps } from 'prop-types';
import {
  requireNativeComponent,
  ViewPropTypes,
  Platform
} from 'react-native';

/**
 * @desc This object outlines valid {@link PDFViewCtrl} class props. 
 * These can be passed into {@link PDFViewCtrl} to customize the viewer.
 * @ignore
 */
const PDFViewCtrlPropTypes = {
  /**
   * @memberof PDFViewCtrl
   * @type {string}
   * @desc The path or url to the document. Required.
   * @hidesource
   * @example
   * <PDFViewCtrl
   *   document={'https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_about.pdf'}
   * />
   */
  document: PropTypes.string.isRequired
}

// Generates the prop types for TypeScript users, from PropTypes.
type PDFViewCtrlProps = InferProps<typeof PDFViewCtrlPropTypes>;

/**
  * @class
  * @classdesc A React component for displaying documents of different types such as 
  * PDF, docx, pptx, xlsx and various image formats.
  * 
  * PDFViewCtrl is useful when a higher level of customization is required. 
  * For easy all-in-one document viewing and editing, use {@link DocumentView}.
  * @hideconstructor
  * @hidesource
  */
export class PDFViewCtrl extends PureComponent<PDFViewCtrlProps, any> {

  static propTypes = Object.assign(PDFViewCtrlPropTypes, { ...ViewPropTypes });

  render () {
    return (
      <RCTPDFViewCtrl
        // @ts-ignore
        style={{ flex: 1 }}
        {...this.props}
      />
    )
  }
}

const name = Platform.OS === 'ios' ? 'RNTPTPDFViewCtrl' : 'RCTPDFViewCtrl';

const RCTPDFViewCtrl = requireNativeComponent(name);
