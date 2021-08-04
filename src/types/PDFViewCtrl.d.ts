import { PureComponent } from 'react';
import { ViewProps } from 'react-native';

export interface PDFViewCtrlProps extends ViewProps {
    document: string;
}

export class PDFViewCtrl extends PureComponent<PDFViewCtrlProps, any> {}