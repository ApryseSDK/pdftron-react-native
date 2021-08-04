import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import { requireNativeComponent, ViewPropTypes, Dimensions, Platform } from 'react-native';
const { height, width } = Dimensions.get('window');
export class PDFViewCtrl extends PureComponent {
    render() {
        return (<RCTPDFViewCtrl style={{ flex: 1 }} {...this.props}/>);
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
// @ts-ignore
const RCTPDFViewCtrl = requireNativeComponent(name, PDFViewCtrl, iface); // https://github.com/facebook/react-native/issues/28351
