import { PureComponent } from 'react';
import { ViewProps } from 'react-native';
export interface PDFViewCtrlProps extends ViewProps {
    document: string;
    style?: object;
}
export declare class PDFViewCtrl extends PureComponent<PDFViewCtrlProps, any> {
    render(): JSX.Element;
}
