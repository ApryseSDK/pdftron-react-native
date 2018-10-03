import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import {
  requireNativeComponent,
  ViewPropTypes,
  Text,
  View,
  Dimensions,
  Platform
} from 'react-native';

const { height, width } = Dimensions.get('window');

export default class PDFViewCtrl extends PureComponent {

  static propTypes = {
    document: PropTypes.string,
    ...ViewPropTypes,
  };

  render() {
    return (
      <RCTPDFViewCtrl
        style={{ flex:1 }}
        {...this.props}
      />
    )
  }
}

var iface = {
  name: 'PDFViewCtrl',
  propTypes: {
    document: PropTypes.string,
    ...ViewPropTypes, // include the default view properties
  },
};

const name = Platform.OS === 'ios' ? 'RNTPTPDFViewCtrl' : 'RCTPDFViewCtrl';

const RCTPDFViewCtrl = requireNativeComponent(name, PDFViewCtrl, iface);