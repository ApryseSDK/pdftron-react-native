import React, { PureComponent } from 'react';
import PropTypes, { InferProps } from 'prop-types';
import {
  requireNativeComponent,
  ViewPropTypes,
  Platform
} from 'react-native';

const propTypes = {
  document: PropTypes.string.isRequired,
  ...ViewPropTypes,
}

type PDFViewCtrlProps = InferProps<typeof propTypes>;

/**
  * @class
  * @classdesc A React component for displaying documents of different types such as PDF, docx, pptx, xlsx and various image formats. 
  * 
  * PDFViewCtrl is useful when a higher level of customization is required. For easy all-in-one document viewing and editing, use {@link DocumentView}.
  * @hideconstructor
  */
export class PDFViewCtrl extends PureComponent<PDFViewCtrlProps, any> {

  static propTypes = propTypes;

  render() {
    return (
      <RCTPDFViewCtrl
        style={{ flex:1 }}
        {...this.props}
      />
    )
  }
}

const name = Platform.OS === 'ios' ? 'RNTPTPDFViewCtrl' : 'RCTPDFViewCtrl';

const RCTPDFViewCtrl = requireNativeComponent(name);