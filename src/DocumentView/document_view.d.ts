import { PureComponent } from "react";
import { ViewProps } from "react-native";
import { AnnotationMenu, Tools} from "react-native-pdftron/src/Config/config";

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
    disabledElements: array;
    disabledTools: array;
    longPressMenuItems: array;
    overrideLongPressMenuBehavior: array;
    onLongPressMenuPress?: (event: {longPressMenu: string, longPressText: string}) => void;
    longPressMenuEnabled?: boolean;
    annotationMenuItems: array;
    overrideAnnotationMenuBehavior: array;
    onAnnotationMenuPress?: (event: {annotationMenu: string, annotations: Array<Annotation>}) => void;
    hideAnnotationMenu: array;
    overrideBehavior: array;
    onBehaviorActivated?: (event: {action: string, data: object}) => void;
    topToolbarEnabled?: boolean;
    bottomToolbarEnabled?: boolean;
    hideToolbarsOnTap?: boolean;
    documentSliderEnabled?: boolean;
    pageIndicatorEnabled?: boolean;
    keyboardShortcutsEnabled?: boolean;
    onAnnotationsSelected?: (event: {annotations: Array<Annotation>}) => void ;
    onAnnotationChanged: (event: {action: string, annotations: Array<Annotation>}) => void;
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
    onExportAnnotationCommand?: () => void;
    autoSaveEnabled?: boolean;
    pageChangeOnTap?: boolean;
    followSystemDarkMode?: boolean;
    useStylusAsPen?: boolean;
    multiTabEnabled?: boolean;
    tabTitle?: string;
    maxTabCount?: number;
    signSignatureFieldsWithStamps?: boolean;
    annotationPermissionCheckEnabled?: boolean;
    annotationToolbars?: array;
    hideDefaultAnnotationToolbars: array;
    topAppNavBarRightBar: array;
    bottomToolbar: array;
    hideAnnotationToolbarSwitcher?: boolean;
    hideTopToolbars: boolean;
    hideTopAppNavBar: boolean;
    onBookmarkChanged: func;
    hideThumbnailFilterModes: array;
    onToolChanged: func;
    horizontalScrollPos: number;
    verticalScrollPos: number;
    onTextSearchStart: func;
    onTextSearchResult: func;
    hideViewModeItems: array;
    pageStackEnabled: boolean;
    showQuickNavigationButton: boolean;
    photoPickerEnabled: boolean;
    autoResizeFreeTextEnabled: boolean;
    annotationsListEditingEnabled: boolean;
    showNavigationListAsSidePanelOnLargeDevices: boolean;
    restrictDownloadUsage: boolean;
    userBookmarksListEditingEnabled: boolean;
    imageInReflowEnabled: boolean;
    reflowOrientation: string;
    onUndoRedoStateChanged: func;
    tabletLayoutEnabled: boolean;
    initialToolbar: string;
    inkMultiStrokeEnabled: boolean;
    defaultEraserType: string;
    exportPath: string;
    openUrlPath: string;
    saveStateEnabled: boolean;
    openSavedCopyInNewTab: boolean;
}

export class DocumentView extends PureComponent<DocumentViewProps | ViewProps, any>{};