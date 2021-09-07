import {Config} from '../Config/Config';

/**
 * @typedef
 * @category AnnotOptions
 * @property {string} id
 * @property {number} [pageNumber]
 * @property {string} [type]
 * @property {Rect} [pageRect]
 * @property {Rect} [screenRect]
 */
export interface Annotation {
    id: string;
    pageNumber?: number;
    type?: string;
    pageRect?: Rect;
    screenRect?: Rect;
}

/**
 * @typedef
 * @category AnnotOptions
 * @property {number} [height]
 * @property {number} [width]
 * @property {number} x1
 * @property {number} y1
 * @property {number} x2
 * @property {number} y2
 */
export interface Rect {
    height?: number;
    width?: number;
    x1: number;
    y1: number;
    x2: number;
    y2: number;
}

/**
 * @typedef
 * @category AnnotOptions
 * @augments Rect
 */
export interface CropBox extends Rect {
    height: number;
    width: number;
};

/**
 * @interface
 * @category AnnotOptions
 * @property {number} red
 * @property {number} green
 * @property {number} blue
 */
export interface Color {
    red: number;
    green: number;
    blue: number;
}

/**
 * ActionRequest
 * @memberof AnnotOptions
 * @alias RotationDegree
 */
export type RotationDegree = 0 | 90 | 180 | 270;

/**
 * @typedef
 * @category AnnotOptions
 * @property {string} fieldName
 * @property {string} fieldType
 * @property {string | boolean | number | undefined} [fieldValue]
 */
export interface Field {
    fieldName: string;
    fieldType: string;
    fieldValue?: string | boolean | number | undefined;
}

/**
 * @typedef 
 * @category AnnotOptions
 * @property {number} x
 * @property {number} y
 * @property {number} [pageNumber]
 */
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