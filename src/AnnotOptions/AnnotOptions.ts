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

export interface ColorWithAlpha {
    red: number;
    green: number;
    blue: number;
    alpha: number;
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

/**
 * The default properties a tool gives the annotations it creates. Set with
 * {@link DocumentView.setDefaultPropertiesForTool}.
 *
 * Only the properties present are changed. The rest keep their current values.
 */
export interface ToolDefaultProperties {
    /** Stroke (line) colour. */
    strokeColor?: Color;
    /** Line or border thickness in points. For the eraser tool this is the erase width. */
    thickness?: number;
    /** Text colour, for tools that create text. */
    textColor?: Color;
    /** Text size in points, for tools that create text. */
    textSize?: number;
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