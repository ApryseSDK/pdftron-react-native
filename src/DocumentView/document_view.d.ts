import { number } from "prop-types";
import { PureComponent } from "react";
import { ViewProps } from "react-native";
import { Config } from "../Config/config";
export interface Annotation {
    id: string;
    pageNumber: number;
    type: string;
    rect: Rect
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

export interface Coords {
    x: number;
    y: number;
}

export type Quad = [Coords, Coords, Coords, Coords];

export interface TextSelectionResult {
    html: string;
    pageNumber: number;
    quads: Array<Quad> | null;
}

export interface AnnotationFlag {
    id: string;
    pageNumber: int;
    flag: Config.AnnotationFlagsSet;
    flagValue: boolean;
}

export interface Properties {
    rect?: Rect;
    contents?: string;
    subject?: string;
    title?: string;
    contentRect?: Rect;
    customData?: object;
    strokeColor?: Color;
}

export interface DocumentViewProps extends ViewProps{
    document: string;
    password?: string;
    initialPageNumber?: number;
    pageNumber?: number;
    customHeaders?: object;
    leadingNavButtonIcon?: string;
    showLeadingNavButton?: boolean;
    onLeadingNavButtonPressed?: () => void;
    onDocumentLoaded?: (event: {path : string}) => void;
    onDocumentError?: (event: {error: string}) => void;
    onPageChanged?: (event: {previousPageNumber: number, pageNumber: number}) => void;
    onScrollChanged?: (event: {horizontal: number, vertical: number}) => void;
    onZoomChanged?: (event: {zoom: number}) => void;
    onZoomFinished?: (event: {zoom: number}) => void;
    zoom?: number;
    disabledElements?: Array<string>;
    disabledTools?: Array<string>;
    longPressMenuItems?: Array<string>;
    overrideLongPressMenuBehavior?: Array<string>;
    onLongPressMenuPress?: (event: {longPressMenu: string, longPressText: string}) => void;
    longPressMenuEnabled?: boolean;
    annotationMenuItems?: Array<string>;
    overrideAnnotationMenuBehavior?: Array<string>;
    onAnnotationMenuPress?: (event: {annotationMenu: string, annotations: Array<Annotation>}) => void;
    hideAnnotationMenu?: Array<string>;
    overrideBehavior?: Array<string>;
    onBehaviorActivated?: (event: {action: string, data: object}) => void;
    topToolbarEnabled?: boolean;
    bottomToolbarEnabled?: boolean;
    hideToolbarsOnTap?: boolean;
    documentSliderEnabled?: boolean;
    pageIndicatorEnabled?: boolean;
    keyboardShortcutsEnabled?: boolean;
    onAnnotationsSelected?: (event: {annotations: Array<Annotation>}) => void ;
    onAnnotationChanged?: (event: {action: string, annotations: Array<Annotation>}) => void;
    onFormFieldValueChanged?: (event: {fields: Array<FieldWithStringValue>}) => void;
    readOnly?: boolean;
    thumbnailViewEditingEnabled?: boolean;
    fitMode?: string;
    layoutMode?: string;
    onLayoutChanged?: () => void;
    padStatusBar?: boolean;
    continuousAnnotationEditing?: boolean;
    selectAnnotationAfterCreation?: boolean;
    annotationAuthor?: string;
    showSavedSignatures?: boolean;
    isBase64String?: boolean;
    collabEnabled?: boolean;
    currentUser?: string;
    currentUserName?: string;
    onExportAnnotationCommand?: (event: {action: string, xfdfCommand: string, annotations: Array<Annotation>}) => void;
    autoSaveEnabled?: boolean;
    pageChangeOnTap?: boolean;
    followSystemDarkMode?: boolean;
    useStylusAsPen?: boolean;
    multiTabEnabled?: boolean;
    tabTitle?: string;
    maxTabCount?: number;
    signSignatureFieldsWithStamps?: boolean;
    annotationPermissionCheckEnabled?: boolean;
    annotationToolbars?: Array<string | object>;
    hideDefaultAnnotationToolbars?: Array<string>;
    topAppNavBarRightBar?: Array<string>;
    bottomToolbar?: Array<string>;
    hideAnnotationToolbarSwitcher?: boolean;
    hideTopToolbars?: boolean;
    hideTopAppNavBar?: boolean;
    onBookmarkChanged?: (event: {bookmarkJson: string}) => void;
    hideThumbnailFilterModes?: Array<string>;
    onToolChanged?: (event: {previousTool: string, tool: string}) => void;
    horizontalScrollPos?: number;
    verticalScrollPos?: number;
    onTextSearchStart?: () => void;
    onTextSearchResult?: (event: {found: boolean, textSelection: TextSelectionResult}) => void;
    hideViewModeItems?: Array<string>;
    pageStackEnabled?: boolean;
    showQuickNavigationButton?: boolean;
    photoPickerEnabled?: boolean;
    autoResizeFreeTextEnabled?: boolean;
    annotationsListEditingEnabled?: boolean;
    showNavigationListAsSidePanelOnLargeDevices?: boolean;
    restrictDownloadUsage?: boolean;
    userBookmarksListEditingEnabled?: boolean;
    imageInReflowEnabled?: boolean;
    reflowOrientation?: string;
    onUndoRedoStateChanged?: () => void;
    tabletLayoutEnabled?: boolean;
    initialToolbar?: string;
    inkMultiStrokeEnabled?: boolean;
    defaultEraserType?: string;
    exportPath?: string;
    openUrlPath?: string;
    saveStateEnabled?: boolean;
    openSavedCopyInNewTab?: boolean;
}

export class DocumentView extends PureComponent<DocumentViewProps, any>{
    getDocumentPath: () => Promise<void> | string;
    setToolMode: (toolMode: string) => Promise<void>;
    commitTool: () => Promise<void> | boolean;
    getPageCount: () => Promise<void> | number;
    importBookmarkJson: (bookmarkJson: string) => Promise<void>;
    importAnnotationCommand: (xfdfCommand: string, initialLoad: boolean) => Promise<void>;
    importAnnotations: (xfdf: string) => Promise<void>;
    exportAnnotations: (options?: {annotList: Array<Annotation>}) => Promise<void> | string;
    flattenAnnotations: (formsOnly: boolean) => Promise<void>;
    deleteAnnotations: (annotations: Array<Annotation>) => Promise<void>;
    saveDocument: () => Promise<void> | string;
    setFlagForFields: (fields: Array<String>, flag: number, value: boolean) => Promise<void>;
    getField: (fieldName: string) => Promise<void> | {fieldName: string, fieldValue?: any, fieldType?: string};
    setValueForFields: (fieldsMap: Map<{fieldName: string, fieldValue: any}>) => Promise<void>;
    setValuesForFields: (fieldsMap: Map<{fieldName: string, fieldValue: any}>) => Promise<void>;
    handleBackButton: () => Promise<void> | boolean;
    setFlagForAnnotations: (annotationFlagList: Array<AnnotationFlag>) => Promise<void>;
    setFlagsForAnnotations: (annotationFlagList: Array<AnnotationFlag>) => Promise<void>;
    selectAnnotation: (id: string, pageNumber: number) => Promise<void>;
    setPropertyForAnnotation: (id: string, pageNumber: number, propertyMap: Properties) => Promise<void>;
    setPropertiesForAnnotation: (id: string, pageNumber: number, propertyMap: Properties) => Promise<void>;
    getPropertiesForAnnotation: (id: string, pageNumber: number) => Promise<void> | Properties;
    setDrawAnnotations: (drawAnnotations: boolean) => Promise<void>;
    setVisibilityForAnnotation: (id: string, pageNumber: number, visibility: boolean) => Promise<void>;
    setHighlightFields: (highlightFields: boolean) => Promise<void>;
    getAnnotationAtPoint: (x: number, y: number, distanceThreshold: number, minimumLineWeight: number) => Promise<void> | Annotation;
    getAnnotationListAt: (x1: number, y1: number, x2: number, y2: number) => Promise<void> | Array<Annotation>;
    getAnnotationsOnPage: (pageNumber: number) => Promise<void> | Array<Annotation>;
    getCustomDataForAnnotation: (annotationID: string, pageNumber: integer, key: string) => Promise<void> | string;
    getPageCropBox: (pageNumber: number) => Promise<void> | CropBox;
    setCurrentPage: (pageNumber: number) => Promise<void> | boolean;
    getVisiblePages: () => Promise<void> | Array<number>;
    gotoPreviousPage: () => Promise<void> | boolean;
    gotoNextPage: () => Promise<void> | boolean;
    gotoFirstPage: () => Promise<void> | boolean;
    gotoLastPage: () => Promise<void> | boolean;
    showGoToPageView: () => Promise<void>;
    closeAllTabs: () => Promise<void>;
    getZoom: () => Promise<void> | number;
    setZoomLimits: (zoomLimitMode: string, minimum: number, maximum: number) => Promise<void>;
    zoomWithCenter: (zoom: number, x: number, y: number) => Promise<void>;
    zoomToRect: (pageNumber: number, rect: Rect) => Promise<void>;
    smartZoom: (x: number, y: number, animated: boolean) => Promise<void>;
    getScrollPos: () => Promise<void> | {horizontal: number, vertical: number};
    getCanvasSize: () => Promise<void> | {width: number, height: number};
    getPageRotation: () => Promise<void> | number;
    rotateClockwise: () => Promise<void>;
    rotateCounterClockwise: () => Promise<void>;
    // not done adding methods
};