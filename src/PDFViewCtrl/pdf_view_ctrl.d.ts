import { PureComponent } from 'react';
import PropTypes from 'prop-types';

export interface PDFViewCtrlProps extends ViewProps {
    document: PropTypes.string;
}

export class PDFViewCtrl extends PureComponent<PDFViewCtrlProps, any> {}