import {Config} from '../Config/Config';

export interface Annotation {
    id: string;
    pageNumber?: number;
    type?: string;
    pageRect?: Rect;
    screenRect?: Rect;
}

export interface Rect {
    height?: number;
    width?: number;
    x1: number;
    y1: number;
    x2: number;
    y2: number;
}

export type CropBox = Required<Rect>;

export interface Color {
    red: number;
    green: number;
    blue: number;
}

export type RotationDegree = 0 | 90 | 180 | 270;

export interface Field {
    fieldName: string;
    fieldType: string;
    fieldValue?: string | boolean | number | undefined;
    fieldHasAppearance?: boolean | undefined;
}

export interface Point {
    x: number;
    y: number;
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
    flag: Config.AnnotationFlags;
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
    pageRect?: Rect;
    screenRect?: Rect;
}

export type DrawnSignature = 0;

export type TypedSignature = 1;

export type ImageSignature = 2;

export type SignatureType = DrawnSignature | TypedSignature | ImageSignature;
