import React from 'react';
import {MaterialCommunityIcons} from '@expo/vector-icons';

export const pdfUrls: Array<string> = [
  'https://www.pdftron.com/webviewer/demo/gallery/PDFTRON_about.pdf',
  'https://www.pdftron.com/webviewer/demo/gallery/Report_2011.pdf',
  'https://www.pdftron.com/webviewer/demo/gallery/floorplan.pdf',
  'https://www.pdftron.com/webviewer/demo/gallery/chart_supported.pdf',
  'https://www.pdftron.com/webviewer/demo/gallery/magazine.pdf',
];

export const fileIcons: {
  [key: string]: React.ComponentProps<typeof MaterialCommunityIcons>['name'];
} = {
  json: 'code-json',
  pdf: 'file-pdf-box',
  msword: 'file-word-outline',
  'vnd.openxmlformats-officedocument.wordprocessingml.document':
    'file-word-outline',
  'vnd.ms-excel': 'file-excel-outline',
  'vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'file-excel-outline',
  'vnd.ms-powerpoint': 'file-powerpoint-outline',
  'vnd.openxmlformats-officedocument.presentationml.presentation':
    'file-powerpoint-outline',
  zip: 'folder-zip-outline',
  'vnd.rar': 'folder-zip-outline',
  'x-7z-compressed': 'folder-zip-outline',
  xml: 'xml',
  css: 'language-css3',
  csv: 'file-delimited-outline',
  html: 'language-html5',
  javascript: 'language-javascript',
  plain: 'text-box-outline',
};

export const officeFileTypes = [
  'vnd.openxmlformats-officedocument.wordprocessingml.document',
  'vnd.ms-excel',
  'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'vnd.ms-powerpoint',
  'vnd.openxmlformats-officedocument.presentationml.presentation',
];

export const humanFileSize = (bytes: number) => {
  const threshold = 1000;
  const dp = 1;
  const r = 10 ** dp;
  const units = ['kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

  if (Math.abs(bytes) < threshold) {
    return bytes + ' B';
  }

  let u = -1;
  do {
    bytes /= threshold;
    ++u;
  } while (
    Math.round(Math.abs(bytes) * r) / r >= threshold &&
    u < units.length - 1
  );

  return bytes.toFixed(dp) + ' ' + units[u];
};
