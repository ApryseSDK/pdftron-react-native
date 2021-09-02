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

// Generates the prop types for TypeScript users, from PropTypes.
type PDFViewCtrlProps = InferProps<typeof propTypes>;

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