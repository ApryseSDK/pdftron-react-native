import * as ConfigOptions from './ConfigOptions';

export interface Annotation {
    id: string;
    pageNumber?: number;
    type?: string;
    rect?: Rect;
}

export interface Rect {
    x1: number;
    y1: number;
    x2: number;
    y2: number;
}

export interface Color {
    red: number;
    green: number;
    blue: number;
}

export type RotationDegree = 0 | 90 | 180 | 270;

export interface CropBox extends Rect {
    width: number;
    height: number;
}

export interface Field {
    fieldName: string;
    fieldValue: string | boolean | number;
}

export interface FieldWithStringValue {
    fieldName: string;
    fieldValue: string;
}

export interface Point {
    x: number;
    y: number;
}

export interface PointWithPage extends Point {
    pageNumber?: number;
}

export type Quad = [Point, Point, Point, Point];

export interface TextSelectionResult {
    html: string; 
    unicode: string; 
    pageNumber: number; 
    quads: Array<Quad>;
}

export interface AnnotationFlag {
    id: string;
    pageNumber: number;
    flag: ConfigOptions.AnnotationFlags;
    flagValue: boolean;
}

export interface AnnotationProperties {
    rect?: Rect;
    contents?: string;
    subject?: string;
    title?: string;
    contentRect?: Rect;
    customData?: object;
    strokeColor?: Color;
}

export interface LinkPressData {
    url: string;
}

export interface StickyNoteData	{
    id: string;
    pageNumber: number;
    type: string;
    rect: Rect;
}