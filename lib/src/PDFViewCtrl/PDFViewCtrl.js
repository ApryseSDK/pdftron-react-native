import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import { requireNativeComponent, ViewPropTypes, Platform } from 'react-native';
const propTypes = {
    document: PropTypes.string.isRequired,
    ...ViewPropTypes,
};
export class PDFViewCtrl extends PureComponent {
    static propTypes = propTypes;
    render() {
        return (<RCTPDFViewCtrl style={{ flex: 1 }} {...this.props}/>);
    }
}
const name = Platform.OS === 'ios' ? 'RNTPTPDFViewCtrl' : 'RCTPDFViewCtrl';
const RCTPDFViewCtrl = requireNativeComponent(name);
