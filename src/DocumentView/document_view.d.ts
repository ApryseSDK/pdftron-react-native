import { PureComponent } from "react";
import { ViewProps } from "react-native";
export interface Annotation {
    id: string;
    pageNumber: number;
    type: string;
    rect: object
}

export interface Field {
    fieldName: string;
    fieldValue: string;
}

export interface Coords {
    x: number;
    y: number;
}

export type Quads = [Coords, Coords, Coords, Coords];

export interface TextSelectionResult {
    html: string;
    pageNumber: number;
    quads: Array<Quads>
}

export interface DocumentViewProps {
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
    onFormFieldValueChanged?: (event: {fields: Array<Field>}) => void;
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

export class DocumentView extends PureComponent<DocumentViewProps | ViewProps, any>{};