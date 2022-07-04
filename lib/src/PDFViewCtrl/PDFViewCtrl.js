import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import { requireNativeComponent, Platform } from 'react-native';
// @ts-ignore
import { ViewPropTypes } from 'deprecated-react-native-prop-types';
const propTypes = {
    document: PropTypes.string.isRequired,
    ...ViewPropTypes,
};
export class PDFViewCtrl extends PureComponent {
    static propTypes = propTypes;
    render() {
        return (<RCTPDFViewCtrl 
        // @ts-ignore
        style={{ flex: 1 }} {...this.props}/>);
    }
}
const name = Platform.OS === 'ios' ? 'RNTPTPDFViewCtrl' : 'RCTPDFViewCtrl';
const RCTPDFViewCtrl = requireNativeComponent(name);
