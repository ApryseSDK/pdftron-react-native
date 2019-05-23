import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { NativeModules } from 'react-native';

import PDFViewCtrl from './src/PDFViewCtrl';
import DocumentView from './src/DocumentView';
import Config from './src/Config';

const { RNPdftron } = NativeModules;

export {
  RNPdftron,
  PDFViewCtrl,
  DocumentView,
  Config
};
