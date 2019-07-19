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

export default class DocumentView extends PureComponent {

  static propTypes = {
    document: PropTypes.string,
    password: PropTypes.string,
    initialPageNumber: PropTypes.number,
    customHeaders: PropTypes.object,
    leadingNavButtonIcon: PropTypes.string,
    showLeadingNavButton: PropTypes.bool,
    onLeadingNavButtonPressed: PropTypes.func,
    disabledElements: PropTypes.array,
    disabledTools: PropTypes.array,
    ...ViewPropTypes,
  };

  onChange = (event) => {
    if (event.nativeEvent.onLeadingNavButtonPressed) {
      if (this.props.onLeadingNavButtonPressed) {
        this.props.onLeadingNavButtonPressed();
      }
    }
  }

  render() {
    return (
      <RCTDocumentView
        style={{ flex:1 }}
        onChange={this.onChange}
        {...this.props}
      />
    )
  }
}

const name = Platform.OS === 'ios' ? 'RNTPTDocumentView' : 'RCTDocumentView';

const RCTDocumentView = requireNativeComponent(
  name,
  DocumentView,
  {
    nativeOnly: {
      onChange: true
    }
  }
);
