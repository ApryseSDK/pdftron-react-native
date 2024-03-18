#import <Tools/Tools.h>
#import <React/RCTComponent.h>

#import <UIKit/UIKit.h>

#import "RNPdftron.h"

NS_ASSUME_NONNULL_BEGIN

static NSString * const PTToolsButtonKey = @"toolsButton";
static NSString * const PTSearchButtonKey = @"searchButton";
static NSString * const PTShareButtonKey = @"shareButton";
static NSString * const PTViewControlsButtonKey = @"viewControlsButton";
static NSString * const PTThumbNailsButtonKey = @"thumbnailsButton";
static NSString * const PTListsButtonKey = @"listsButton";
static NSString * const PTMoreItemsButtonKey = @"moreItemsButton";
static NSString * const PTThumbnailSliderButtonKey = @"thumbnailSlider";
static NSString * const PTOutlineListButtonKey = @"outlineListButton";
static NSString * const PTAnnotationListButtonKey = @"annotationListButton";
static NSString * const PTUserBookmarkListButtonKey = @"userBookmarkListButton";
static NSString * const PTLayerListButtonKey = @"viewLayersButton";
static NSString * const PTReflowButtonKey = @"reflowButton";
static NSString * const PTEditPagesButtonKey = @"editPagesButton";
static NSString * const PTPrintButtonKey = @"printButton";
static NSString * const PTCloseButtonKey = @"closeButton";
static NSString * const PTSaveCopyButtonKey = @"saveCopyButton";
static NSString * const PTSaveIdenticalCopyButtonKey = @"saveIdenticalCopyButton";
static NSString * const PTSaveFlattenedCopyButtonKey = @"saveFlattenedCopyButton";
static NSString * const PTSaveCroppedCopyButtonKey = @"saveCroppedCopyButton";
static NSString * const PTFormToolsButtonKey = @"formToolsButton";
static NSString * const PTFillSignToolsButtonKey = @"fillSignToolsButton";
static NSString * const PTEditMenuButtonKey = @"editMenuButton";
static NSString * const PTCropPageButtonKey = @"cropPageButton";

static NSString * const PTStickyToolButtonKey = @"stickyToolButton";
static NSString * const PTFreeHandToolButtonKey = @"freeHandToolButton";
static NSString * const PTHighlightToolButtonKey = @"highlightToolButton";
static NSString * const PTUnderlineToolButtonKey = @"underlineToolButton";
static NSString * const PTSquigglyToolButtonKey = @"squigglyToolButton";
static NSString * const PTStrikeoutToolButtonKey = @"strikeoutToolButton";
static NSString * const PTFreeTextToolButtonKey = @"freeTextToolButton";
static NSString * const PTCalloutToolButtonKey = @"calloutToolButton";
static NSString * const PTSignatureToolButtonKey = @"signatureToolButton";
static NSString * const PTLineToolButtonKey = @"lineToolButton";
static NSString * const PTArrowToolButtonKey = @"arrowToolButton";
static NSString * const PTPolylineToolButtonKey = @"polylineToolButton";
static NSString * const PTStampToolButtonKey = @"stampToolButton";
static NSString * const PTRectangleToolButtonKey = @"rectangleToolButton";
static NSString * const PTEllipseToolButtonKey = @"ellipseToolButton";
static NSString * const PTPolygonToolButtonKey = @"polygonToolButton";
static NSString * const PTCloudToolButtonKey = @"cloudToolButton";
static NSString * const PTEditToolButtonKey = @"editToolButton";
static NSString * const PTInsertPageButton = @"insertPageButton";
static NSString * const PTInsertBlankPageButton = @"insertBlankPageButton";
static NSString * const PTInsertFromImageButton = @"insertFromImageButton";
static NSString * const PTInsertFromPhotoButton = @"insertFromPhotoButton";
static NSString * const PTInsertFromDocumentButton = @"insertFromDocumentButton";
static NSString * const PTInsertFromScannerButton = @"insertFromScannerButton";

static NSString * const PTAnnotationEditToolKey = @"AnnotationEdit";
static NSString * const PTAnnotationCreateStickyToolKey = @"AnnotationCreateSticky";
static NSString * const PTAnnotationCreateFreeHandToolKey = @"AnnotationCreateFreeHand";
static NSString * const PTTextSelectToolKey = @"TextSelect";
static NSString * const PTMultiSelectToolKey = @"MultiSelect";
static NSString * const PTAnnotationCreateTextHighlightToolKey = @"AnnotationCreateTextHighlight";
static NSString * const PTAnnotationCreateTextUnderlineToolKey = @"AnnotationCreateTextUnderline";
static NSString * const PTAnnotationCreateTextSquigglyToolKey = @"AnnotationCreateTextSquiggly";
static NSString * const PTAnnotationCreateTextStrikeoutToolKey = @"AnnotationCreateTextStrikeout";
static NSString * const PTAnnotationCreateFreeTextToolKey = @"AnnotationCreateFreeText";
static NSString * const PTAnnotationCreateCalloutToolKey = @"AnnotationCreateCallout";
static NSString * const PTAnnotationCreateSignatureToolKey = @"AnnotationCreateSignature";
static NSString * const PTAnnotationCreateLineToolKey = @"AnnotationCreateLine";
static NSString * const PTAnnotationCreateArrowToolKey = @"AnnotationCreateArrow";
static NSString * const PTAnnotationCreatePolylineToolKey = @"AnnotationCreatePolyline";
static NSString * const PTAnnotationCreateStampToolKey = @"AnnotationCreateStamp";
static NSString * const PTAnnotationCreateRectangleToolKey = @"AnnotationCreateRectangle";
static NSString * const PTAnnotationCreateEllipseToolKey = @"AnnotationCreateEllipse";
static NSString * const PTAnnotationCreatePolygonToolKey = @"AnnotationCreatePolygon";
static NSString * const PTAnnotationCreatePolygonCloudToolKey = @"AnnotationCreatePolygonCloud";
static NSString * const PTAnnotationCreateFileAttachmentToolKey = @"AnnotationCreateFileAttachment";
static NSString * const PTAnnotationCreateDistanceMeasurementToolKey = @"AnnotationCreateDistanceMeasurement";
static NSString * const PTAnnotationCreatePerimeterMeasurementToolKey = @"AnnotationCreatePerimeterMeasurement";
static NSString * const PTAnnotationCreateAreaMeasurementToolKey = @"AnnotationCreateAreaMeasurement";
static NSString * const PTPanToolKey = @"Pan";
static NSString * const PTAnnotationEraserToolKey = @"AnnotationEraserTool";
static NSString * const PTAnnotationCountToolKey = @"AnnotationCountTool";
static NSString * const PTAnnotationCreateSoundToolKey = @"AnnotationCreateSound";
static NSString * const PTPencilKitDrawingToolKey = @"PencilKitDrawing";
static NSString * const PTAnnotationCreateFreeHighlighterToolKey = @"AnnotationCreateFreeHighlighter";
static NSString * const PTAnnotationCreateRubberStampToolKey = @"AnnotationCreateRubberStamp";
static NSString * const PTAnnotationCreateRedactionToolKey = @"AnnotationCreateRedaction";
static NSString * const PTAnnotationCreateLinkToolKey = @"AnnotationCreateLink";
static NSString * const PTAnnotationCreateRedactionTextToolKey = @"AnnotationCreateRedactionText";
static NSString * const PTAnnotationCreateLinkTextToolKey = @"AnnotationCreateLinkText";
static NSString * const PTAnnotationCreateSmartPenToolKey = @"AnnotationCreateSmartPen";
static NSString * const PTAnnotationCreateFreeTextDateToolKey = @"AnnotationCreateFreeTextDate";
static NSString * const PTFormCreateTextFieldToolKey = @"FormCreateTextField";
static NSString * const PTFormCreateCheckboxFieldToolKey = @"FormCreateCheckboxField";
static NSString * const PTFormCreateSignatureFieldToolKey = @"FormCreateSignatureField";
static NSString * const PTFormCreateRadioFieldToolKey = @"FormCreateRadioField";
static NSString * const PTFormCreateComboBoxFieldToolKey = @"FormCreateComboBoxField";
static NSString * const PTFormCreateListBoxFieldToolKey = @"FormCreateListBoxField";
static NSString * const PTInsertPageToolKey = @"InsertPage";
static NSString * const PTFormFillToolKey = @"FormFill";
static NSString * const PTAnnotationCreateCheckMarkStampKey = @"AnnotationCreateCheckMarkStamp";
static NSString * const PTAnnotationCreateCrossMarkStampKey = @"AnnotationCreateCrossMarkStamp";
static NSString * const PTAnnotationCreateDotStampKey = @"AnnotationCreateDotStamp";

static NSString * const PTHiddenAnnotationFlagKey = @"hidden";
static NSString * const PTInvisibleAnnotationFlagKey = @"invisible";
static NSString * const PTLockedAnnotationFlagKey = @"locked";
static NSString * const PTLockedContentsAnnotationFlagKey = @"lockedContents";
static NSString * const PTNoRotateAnnotationFlagKey = @"noRotate";
static NSString * const PTNoViewAnnotationFlagKey = @"noView";
static NSString * const PTNoZoomAnnotationFlagKey = @"noZoom";
static NSString * const PTPrintAnnotationFlagKey = @"print";
static NSString * const PTReadOnlyAnnotationFlagKey = @"readOnly";
static NSString * const PTToggleNoViewAnnotationFlagKey = @"toggleNoView";

static NSString * const PTFitPageFitModeKey = @"FitPage";
static NSString * const PTFitWidthFitModeKey = @"FitWidth";
static NSString * const PTFitHeightFitModeKey = @"FitHeight";
static NSString * const PTZoomFitModeKey = @"Zoom";

static NSString * const PTSingleLayoutModeKey = @"Single";
static NSString * const PTContinuousLayoutModeKey = @"Continuous";
static NSString * const PTFacingLayoutModeKey = @"Facing";
static NSString * const PTFacingContinuousLayoutModeKey = @"FacingContinuous";
static NSString * const PTFacingCoverLayoutModeKey = @"FacingCover";
static NSString * const PTFacingCoverContinuousLayoutModeKey = @"FacingCoverContinuous";

static NSString * const PTViewModeCropKey = @"viewModeCrop";
static NSString * const PTViewModeRotationKey = @"viewModeRotation";
static NSString * const PTViewModeColorModeKey = @"viewModeColorMode";
static NSString * const PTViewModeReaderModeSettingsKey = @"viewModeReaderModeSettings";

static NSString * const PTThumbnailsViewInsertPagesKey = @"thumbnailsInsertPages";
static NSString * const PTThumbnailsViewExportPagesKey = @"thumbnailsExportPages";
static NSString * const PTThumbnailsViewDuplicatePagesKey = @"thumbnailsDuplicatePages";
static NSString * const PTThumbnailsViewRotatePagesKey = @"thumbnailsRotatePages";
static NSString * const PTThumbnailsViewDeletePagesKey = @"thumbnailsDeletePages";
static NSString * const PTThumbnailsViewInsertFromImageKey = @"thumbnailsInsertFromImage";
static NSString * const PTThumbnailsViewInsertFromPhotoKey = @"thumbnailsInsertFromPhoto";
static NSString * const PTThumbnailsViewInsertFromDocumentKey = @"thumbnailsInsertFromDocument";
static NSString * const PTThumbnailsViewInsertFromScannerKey = @"thumbnailsInsertFromScanner";

static NSString * const PTModifyAnnotationActionKey = @"modify";
static NSString * const PTAddAnnotationActionKey = @"add";
static NSString * const PTDeleteAnnotationActionKey = @"delete";
static NSString * const PTRemoveAnnotationActionKey = @"remove";

static NSString * const PTAnnotListArgumentKey = @"annotList";
static NSString * const PTAnnotationIdKey = @"id";
static NSString * const PTAnnotationPageNumberKey = @"pageNumber";
static NSString * const PTAnnotationFlagKey = @"flag";
static NSString * const PTAnnotationFlagValueKey = @"flagValue";
static NSString * const PTAnnotationTypeKey = @"type";
static NSString * const PTAnnotationCustomDataKey = @"customData";

static NSString * const PTContentRectAnnotationPropertyKey = @"contentRect";
static NSString * const PTContentsAnnotationPropertyKey = @"contents";
static NSString * const PTSubjectAnnotationPropertyKey = @"subject";
static NSString * const PTTitleAnnotationPropertyKey = @"title";

static NSString * const PTLinkPressLinkAnnotationKey = @"linkPress";
static NSString * const PTURILinkAnnotationKey = @"URI";
static NSString * const PTURLLinkAnnotationKey = @"url";

static NSString * const PTStickyNoteShowPopUpKey = @"stickyNoteShowPopUp";

static NSString * const PTDataBehaviorKey = @"data";
static NSString * const PTActionBehaviorKey = @"action";

static NSString * const PTStyleMenuItemTitleKey = @"Style";
static NSString * const PTNoteMenuItemTitleKey = @"Note";
static NSString * const PTCommentsMenuItemTitleKey = @"Comments";
static NSString * const PTCopyMenuItemTitleKey = @"Copy";
static NSString * const PTPasteMenuItemTitleKey = @"Paste";
static NSString * const PTDuplicateMenuItemTitleKey = @"Duplicate";
static NSString * const PTDeleteMenuItemTitleKey = @"Delete";
static NSString * const PTTypeMenuItemTitleKey = @"Type";
static NSString * const PTSearchMenuItemTitleKey = @"Search";
static NSString * const PTEditMenuItemTitleKey = @"Edit";
static NSString * const PTFlattenMenuItemTitleKey = @"Flatten";
static NSString * const PTOpenMenuItemTitleKey = @"Open";
static NSString * const PTShareMenuItemTitleKey = @"Share";
static NSString * const PTReadMenuItemTitleKey = @"Read";
static NSString * const PTCalibrateMenuItemTitleKey = @"Calibrate";

static NSString * const PTStyleMenuItemIdentifierKey = @"style";
static NSString * const PTNoteMenuItemIdentifierKey = @"note";
static NSString * const PTCopyMenuItemIdentifierKey = @"copy";
static NSString * const PTPasteMenuItemIdentifierKey = @"paste";
static NSString * const PTDuplicateMenuItemIdentifierKey = @"duplicate";
static NSString * const PTDeleteMenuItemIdentifierKey = @"delete";
static NSString * const PTTypeMenuItemIdentifierKey = @"markupType";
static NSString * const PTSearchMenuItemIdentifierKey = @"search";
static NSString * const PTEditTextMenuItemIdentifierKey = @"editText";
static NSString * const PTEditInkMenuItemIdentifierKey = @"editInk";
static NSString * const PTFlattenMenuItemIdentifierKey = @"flatten";
static NSString * const PTOpenMenuItemIdentifierKey = @"openAttachment";
static NSString * const PTShareMenuItemIdentifierKey = @"share";
static NSString * const PTReadMenuItemIdentifierKey = @"read";
static NSString * const PTCalibrateMenuItemIdentifierKey = @"calibrate";

static NSString * const PTHighlightWhiteListKey = @"Highlight";
static NSString * const PTStrikeoutWhiteListKey = @"Strikeout";
static NSString * const PTUnderlineWhiteListKey = @"Underline";
static NSString * const PTSquigglyWhiteListKey = @"Squiggly";

static NSString * const PTAnnotatedFilterModeKey = @"annotated";
static NSString * const PTBookmarkedFilterModeKey = @"bookmarked";

static NSString * const PTAbsoluteZoomLimitModeKey = @"absolute";
static NSString * const PTRelativeZoomLimitModeKey = @"relative";

static NSString * const PTRectKey = @"rect";
static NSString * const PTScreenRectKey = @"screenRect";
static NSString * const PTPageRectKey = @"pageRect";
static NSString * const PTRectX1Key = @"x1";
static NSString * const PTRectY1Key = @"y1";
static NSString * const PTRectX2Key = @"x2";
static NSString * const PTRectY2Key = @"y2";
static NSString * const PTRectWidthKey = @"width";
static NSString * const PTRectHeightKey = @"height";

static NSString * const PTStrokeColorKey = @"strokeColor";

static NSString * const PTScrollHorizontalKey = @"horizontal";
static NSString * const PTScrollVerticalKey = @"vertical";

static NSString * const PTConversionScreenKey = @"screen";
static NSString * const PTConversionCanvasKey = @"canvas";
static NSString * const PTConversionPageKey = @"page";

static NSString * const PTCoordinatePointX = @"x";
static NSString * const PTCoordinatePointY = @"y";
static NSString * const PTCoordinatePointPageNumber = @"pageNumber";

static NSString * const PTFormFieldNameKey = @"fieldName";
static NSString * const PTFormFieldValueKey = @"fieldValue";
static NSString * const PTFormFieldTypeKey = @"fieldType";
static NSString * const PTFormFieldHasAppearanceKey = @"fieldHasAppearance";

static NSString * const PTFieldTypeUnknownKey = @"unknown";
static NSString * const PTFieldTypeButtonKey = @"button";
static NSString * const PTFieldTypeCheckboxKey = @"checkbox";
static NSString * const PTFieldTypeRadioKey = @"radio";
static NSString * const PTFieldTypeTextKey = @"text";
static NSString * const PTFieldTypeChoiceKey = @"choice";
static NSString * const PTFieldTypeSignatureKey = @"signature";

static NSString * const PTZoomScaleKey = @"scale";
static NSString * const PTZoomCenterKey = @"center";
static NSString * const PTZoomCenterXKey = @"x";
static NSString * const PTZoomCenterYKey = @"y";

static NSString * const PTZoomLimitRelativeKey = @"relative";
static NSString * const PTZoomLimitAbsoluteKey = @"absolute";
static NSString * const PTZoomLimitNoneKey = @"none";

static NSString * const PTOverprintModeOnKey = @"on";
static NSString * const PTOverprintModeOffKey = @"off";
static NSString * const PTOverprintModePdfxKey = @"pdfx";

static NSString * const PTColorRedKey = @"red";
static NSString * const PTColorGreenKey = @"green";
static NSString * const PTColorBlueKey = @"blue";
static NSString * const PTColorAlphaKey = @"alpha";

static NSString * const PTColorPostProcessModeNoneKey = @"none";
static NSString * const PTColorPostProcessModeInvertKey = @"invert";
static NSString * const PTColorPostProcessModeGradientMapKey = @"gradientMap";
static NSString * const PTColorPostProcessModeNightModeKey = @"nightMode";

static NSString * const PTTextSelectionPageNumberKey = @"pageNumber";
static NSString * const PTTextSelectionUnicodekey = @"unicode";
static NSString * const PTTextSelectionHtmlKey = @"html";
static NSString * const PTTextSelectionQuadsKey = @"quads";

static NSString * const PTTextSelectionQuadPointXKey = @"x";
static NSString * const PTTextSelectionQuadPointYKey = @"y";

static NSString * const PTTextSelectionPageRangeBeginKey = @"begin";
static NSString * const PTTextSelectionPageRangeEndKey = @"end";

// Annotation Manager Undo Modes
static NSString * const PTAnnotationManagerUndoModeOwn = @"own";
static NSString * const PTAnnotationManagerUndoModeAll = @"all";

// Annotation Manager Edit Modes
static NSString * const PTAnnotationManagerEditModeOwn = @"own";
static NSString * const PTAnnotationManagerEditModeAll = @"all";

// DefaultEraserType keys
static NSString * const PTInkEraserModeAllKey = @"annotationEraser";
static NSString * const PTInkEraserModePointsKey = @"hybrideEraser";

// ReflowOrientation keys
static NSString * const PTReflowOrientationHorizontalKey = @"horizontal";
static NSString * const PTReflowOrientationVerticalKey = @"veritcal";

// App Theme keys
static NSString * const PTAppDarkTheme = @"theme_dark";
static NSString * const PTAppLightTheme = @"theme_light";

// Default annotation toolbar names.
typedef NSString * PTDefaultAnnotationToolbarKey;
static const PTDefaultAnnotationToolbarKey PTAnnotationToolbarView = @"PDFTron_View";
static const PTDefaultAnnotationToolbarKey PTAnnotationToolbarAnnotate = @"PDFTron_Annotate";
static const PTDefaultAnnotationToolbarKey PTAnnotationToolbarDraw = @"PDFTron_Draw";
static const PTDefaultAnnotationToolbarKey PTAnnotationToolbarInsert = @"PDFTron_Insert";
static const PTDefaultAnnotationToolbarKey PTAnnotationToolbarFillAndSign = @"PDFTron_Fill_and_Sign";
static const PTDefaultAnnotationToolbarKey PTAnnotationToolbarPrepareForm = @"PDFTron_Prepare_Form";
static const PTDefaultAnnotationToolbarKey PTAnnotationToolbarMeasure = @"PDFTron_Measure";
static const PTDefaultAnnotationToolbarKey PTAnnotationToolbarPens = @"PDFTron_Pens";
static const PTDefaultAnnotationToolbarKey PTAnnotationToolbarRedaction = @"PDFTron_Redact";
static const PTDefaultAnnotationToolbarKey PTAnnotationToolbarFavorite = @"PDFTron_Favorite";

// Custom annotation toolbar keys.
typedef NSString * PTAnnotationToolbarKey;
static const PTAnnotationToolbarKey PTAnnotationToolbarKeyId = @"id";
static const PTAnnotationToolbarKey PTAnnotationToolbarKeyName = @"name";
static const PTAnnotationToolbarKey PTAnnotationToolbarKeyIcon = @"icon";
static const PTAnnotationToolbarKey PTAnnotationToolbarKeyItems = @"items";

// Custom annotation toolbar item keys.
typedef NSString * PTAnnotationToolbarItemKey NS_TYPED_EXTENSIBLE_ENUM;
static const PTAnnotationToolbarItemKey PTAnnotationToolbarItemKeyId = @"id";
static const PTAnnotationToolbarItemKey PTAnnotationToolbarItemKeyName = @"name";
static const PTAnnotationToolbarItemKey PTAnnotationToolbarItemKeyIcon = @"icon";

// Contexts.
static void *TabChangedContext = &TabChangedContext;

// To access the saved signatures folder
static NSString * const PTSignaturesManager_signatureDirectory = @"PTSignaturesManager_signatureDirectory";

@class RNTPTDocumentView;

@protocol RNTPTDocumentViewDelegate <NSObject>
@optional
- (void)documentViewAttachedToWindow:(RNTPTDocumentView *)documentView;
- (void)documentViewDetachedFromWindow:(RNTPTDocumentView *)documentView;

- (void)navButtonClicked:(RNTPTDocumentView *)sender;
- (void)documentLoaded:(RNTPTDocumentView *)sender;
- (void)documentError:(RNTPTDocumentView *)sender error:(nullable NSString *)error;
- (void)pageChanged:(RNTPTDocumentView *)sender previousPageNumber:(int)previousPageNumber;
- (void)scrollChanged:(RNTPTDocumentView *)sender horizontal:(double)horizontal vertical:(double)vertical;
- (void)zoomChanged:(RNTPTDocumentView *)sender zoom:(double)zoom;
- (void)zoomFinished:(RNTPTDocumentView *)sender zoom:(double)zoom;
- (void)layoutChanged:(RNTPTDocumentView *)sender;
- (void)textSearchStart:(RNTPTDocumentView *)sender;
- (void)textSearchResult:(RNTPTDocumentView *)sender found:(BOOL)found textSelection:(nullable NSDictionary *)textSelection;
- (void)pageMoved:(RNTPTDocumentView *)sender pageMovedFromPageNumber:(int)oldPageNumber toPageNumber:(int)newPageNumber;

- (void)pageAdded:(RNTPTDocumentView *)sender pageNumber:(int)pageNumber;

- (void)pageRemoved:(RNTPTDocumentView *)sender pageNumber:(int)pageNumber;

- (void)pagesRotated:(RNTPTDocumentView *)sender pageNumbers:(NSIndexSet *)pageNumbers;

- (void)tabChanged:(RNTPTDocumentView *)sender currentTab:(NSString *)currentTab;

- (void)annotationsSelected:(RNTPTDocumentView *)sender annotations:(NSArray<NSDictionary<NSString *, id> *> *)annotations;

- (void)annotationChanged:(RNTPTDocumentView *)sender annotation:(NSDictionary *)annotation action:(NSString *)action;
- (void)annotationFlattened:(RNTPTDocumentView *)sender annotation:(NSDictionary *)annotation;

- (void)savedSignaturesChanged:(RNTPTDocumentView *)sender;

- (void)formFieldValueChanged:(RNTPTDocumentView *)sender fields:(NSDictionary *)fields;

- (void)exportAnnotationCommand:(RNTPTDocumentView *)sender action:(NSString *)action xfdfCommand:(NSString *)xfdfCommand annotation:(NSDictionary*)annotation;

- (void)annotationMenuPressed:(RNTPTDocumentView *)sender annotationMenu:(NSString *)annotationMenu annotations:(NSArray<NSDictionary<NSString *, id> *> *)annotations;

- (void)longPressMenuPressed:(RNTPTDocumentView *)sender longPressMenu:(NSString *)longPressMenu longPressText:(NSString *)longPressText;

- (void)bookmarkChanged:(RNTPTDocumentView *)sender bookmarkJson:(NSString *)bookmarkJson;

- (void)toolChanged:(RNTPTDocumentView *)sender previousTool:(NSString *)previousTool tool:(NSString *)tool;

- (void)behaviorActivated:(RNTPTDocumentView *)sender action:(NSString *)action data:(NSDictionary *)data;

- (void)undoRedoStateChanged:(RNTPTDocumentView *)sender;

- (void)annotationToolbarItemPressed:(RNTPTDocumentView *)sender withKey:(NSString *)itemKey;

- (void)toolbarButtonPressed:(RNTPTDocumentView *)sender withKey:(NSString *)itemKey;

// Hygen Generated Event Listeners
- (void)currentToolbarChanged:(RNTPTDocumentView *)sender toolbar:(NSString *)toolbar;


@end

@interface RNTPTDocumentView : UIView

@property (nonatomic, copy, nullable) NSArray<NSString *> *disabledElements;
@property (nonatomic, copy, nullable) NSArray<NSString *> *disabledTools;
@property (nonatomic, copy, nullable) NSArray<NSString *> *uneditableAnnotationTypes;


// annotation selection menu customization
@property (nonatomic, copy, nullable) NSArray<NSString *> *overrideAnnotationMenuBehavior;
@property (nonatomic, copy, nullable) NSArray<NSString *> *overrideBehavior;
@property (nonatomic, copy, nullable) NSArray<NSString *> *hideAnnotMenuTools;

// long-press menu customization

@property (nonatomic, copy, nullable) NSArray<NSString *> *overrideLongPressMenuBehavior;
@property (nonatomic, copy, nullable) NSArray<NSString *> *longPressMenuItems;

// viewer options
@property (nonatomic, assign) BOOL nightModeEnabled;
@property (nonatomic, assign) BOOL topToolbarEnabled DEPRECATED_MSG_ATTRIBUTE("Use hideTopAppNavBar instead");
@property (nonatomic, assign) BOOL bottomToolbarEnabled;
@property (nonatomic, assign) BOOL pageIndicatorEnabled;
@property (nonatomic, assign) BOOL keyboardShortcutsEnabled;
@property (nonatomic, assign) BOOL hideToolbarsOnTap;
@property (nonatomic, assign) BOOL documentSliderEnabled;
@property (nonatomic, assign) BOOL pageIndicatorShowsOnPageChange;
@property (nonatomic, assign) BOOL pageIndicatorShowsWithControls;
@property (nonatomic, assign) BOOL autoSaveEnabled;
@property (nonatomic, assign) BOOL enableAntialiasing;

// Hygen Generated Props
@property (nonatomic, copy, nullable) NSString* forceAppTheme;
@property (nonatomic, copy, nullable) NSArray<NSDictionary *> *signatureColors;

@property (nonatomic, copy, nullable) NSString *password;
@property (nonatomic, copy, nullable) NSString *document;
@property (nonatomic, copy, nullable) NSString *source;
@property (nonatomic, getter=isBase64String) BOOL base64String;
@property (nonatomic, copy, nullable) NSString *base64Extension;
@property (nonatomic) int initialPageNumber;
@property (nonatomic) int page;
@property (nonatomic) int pageNumber;
@property (nonatomic, assign) BOOL showNavButton;
@property (nonatomic, copy, nullable) NSString *navButtonPath;
@property (nonatomic, copy, nullable) NSString *overflowMenuButtonPath;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *customHeaders;
@property (nonatomic, copy, nullable) NSString *documentExtension;
@property (nonatomic, assign, getter=isReadOnly) BOOL readOnly;

@property (nonatomic, copy) NSString *fitMode;
@property (nonatomic) int fitPolicy;
@property (nonatomic, copy) NSString *layoutMode;

@property (nonatomic, copy, nullable) NSArray<NSString *> *annotationMenuItems;

@property (nonatomic, assign) BOOL pageChangeOnTap;

@property (nonatomic, assign, getter=isThumbnailViewEditingEnabled) BOOL thumbnailViewEditingEnabled;

@property (nonatomic, assign) BOOL imageInReflowEnabled;

@property (nonatomic, copy, nullable) NSString *reflowOrientation;

@property (nonatomic, copy) NSString *annotationAuthor;

@property (nonatomic) BOOL continuousAnnotationEditing;

@property (nonatomic) BOOL inkMultiStrokeEnabled;

@property (nonatomic) BOOL useStylusAsPen;

@property (nonatomic) BOOL showSavedSignatures;

@property (nonatomic) BOOL storeNewSignature;

@property (nonatomic, assign) int maxSignatureCount;

@property (nonatomic, assign, getter=isCollabEnabled) BOOL collabEnabled;

@property (nonatomic, assign, getter=isReplyReviewStateEnabled) BOOL replyReviewStateEnabled;

@property (nonatomic, copy, nullable) NSString *currentUser;

@property (nonatomic, copy, nullable) NSString *currentUserName;

@property (nonatomic, assign) BOOL selectAnnotationAfterCreation;
@property (nonatomic, assign) BOOL autoResizeFreeTextEnabled;

@property (nonatomic, strong, nullable) PTCollaborationManager *collaborationManager;

@property (nonatomic, copy, nullable) RCTBubblingEventBlock onChange;

@property (nonatomic, weak, nullable) id <RNTPTDocumentViewDelegate> delegate;

@property (nonatomic, assign, getter=isLongPressMenuEnabled) BOOL longPressMenuEnabled;

@property (nonatomic, assign) BOOL followSystemDarkMode;

@property (nonatomic, assign) BOOL signSignatureFieldsWithStamps;

@property (nonatomic, assign) BOOL annotationPermissionCheckEnabled;

@property (nonatomic, assign, getter=isMultiTabEnabled) BOOL multiTabEnabled;
@property (nonatomic, copy, nullable) NSString *tabTitle;
@property (nonatomic, assign) int maxTabCount;

@property (nonatomic, copy, nullable) NSArray<id> *annotationToolbars;
@property (nonatomic, copy, nullable) NSArray<NSString *> *hideDefaultAnnotationToolbars;
@property (nonatomic, copy, nullable) NSArray<NSString *> *hideViewModeItems;
@property (nonatomic, copy, nullable) NSArray<NSString *> *hideThumbnailsViewItems;
@property (nonatomic, copy, nullable) NSArray<NSString *> *topAppNavBarRightBar;
@property (nonatomic, copy, nullable) NSArray<NSString *> *bottomToolbar;
@property (nonatomic, copy, nullable) NSString *initialToolbar;

@property (nonatomic) BOOL hideAnnotationToolbarSwitcher;
@property (nonatomic) BOOL hideTopToolbars;
@property (nonatomic) BOOL hideTopAppNavBar;
@property (nonatomic) BOOL presetsToolbarHidden;

@property (nonatomic, copy, nullable) NSArray<NSString *> *hideThumbnailFilterModes;

@property (nonatomic) double zoom;
@property (nonatomic) double scale;

@property (nonatomic) double horizontalScrollPos;
@property (nonatomic) double verticalScrollPos;

@property (nonatomic, assign) BOOL hideScrollbars;

@property (nonatomic) double canvasWidth;
@property (nonatomic) double canvasHeight;

@property (nonatomic, assign) BOOL annotationsListEditingEnabled;

@property (nonatomic, assign) BOOL showQuickNavigationButton;

@property (nonatomic, assign) BOOL showNavigationListAsSidePanelOnLargeDevices;

@property (nonatomic, assign) BOOL restrictDownloadUsage;

@property (nonatomic, assign) BOOL userBookmarksListEditingEnabled;

@property (nonatomic, assign) BOOL saveStateEnabled;

@property (nonatomic, copy, nullable) NSString* openUrlPath;

@property (nonatomic, copy, nullable) NSArray<NSString *> *excludedAnnotationListTypes;

@property (nonatomic, copy, nullable) NSString* annotationManagerUndoMode;

@property (nonatomic, copy, nullable) NSString* annotationManagerEditMode;

@property (nonatomic, copy, nullable) NSString *defaultEraserType;

@property (nonatomic, copy, nullable) NSArray<NSString *> *overrideToolbarButtonBehavior;

#pragma mark - Methods

- (void)setToolMode:(NSString *)toolMode;

- (BOOL)commitTool;

- (int)getPageCount;

- (void)importBookmarkJson:(NSString *)bookmarkJson;

- (void)openBookmarkList;

- (NSString *)getDocumentPath;

- (NSMutableArray<NSDictionary *> *)getAllFieldsForDocumentViewTag:(int)pageNumber;

- (NSString *)exportAsImage:(int)pageNumber dpi:(int)dpi exportFormat:(NSString*)exportFormat transparent:(BOOL)transparent;

- (nullable NSString *)exportAnnotationsWithOptions:(NSDictionary *)options;

- (nullable NSArray<NSDictionary *> *)importAnnotations:(NSString *)xfdfString replace:(BOOL)replace;

- (void)flattenAnnotations:(BOOL)formsOnly;

- (void)deleteAnnotations:(NSArray *)annotations;

- (void)saveDocumentWithCompletionHandler:(void (^)(NSString * _Nullable filePath))completionHandler;

- (void)setFlagForFields:(NSArray<NSString *> *)fields setFlag:(PTFieldFlag)flag toValue:(BOOL)value;

- (void)setValuesForFields:(NSDictionary<NSString *, id> *)map;

- (NSDictionary *)getField:(NSString *)fieldName;

- (void)setFlagsForAnnotations:(NSArray *)annotationFlagList;

- (void)selectAnnotation:(NSString *)annotationId pageNumber:(NSInteger)pageNumber;

- (void)setPropertiesForAnnotation:(NSString *)annotationId pageNumber:(NSInteger)pageNumber propertyMap:(NSDictionary *)propertyMap;

- (NSDictionary *)getPropertiesForAnnotation:(NSString *)annotationId pageNumber:(NSInteger)pageNumber;

- (void)setDrawAnnotations:(BOOL)drawAnnotations;

- (void)setVisibilityForAnnotation:(NSString *)annotationId pageNumber:(NSInteger)pageNumber visibility:(BOOL)visibility;

- (void)setHighlightFields:(BOOL)highlightFields;

- (NSDictionary *)getAnnotationAt:(NSInteger)x y:(NSInteger)y distanceThreshold:(double)distanceThreshold minimumLineWeight:(double)minimumLineWeight;

- (NSArray *)getAnnotationListAt:(NSInteger)x1 y1:(NSInteger)y1 x2:(NSInteger)x2 y2:(NSInteger)y2;

- (NSArray *)getAnnotationListOnPage:(NSInteger)pageNumber;

- (NSString *)getCustomDataForAnnotation: (NSString *)annotationId
    pageNumber:(NSInteger)pageNumber key:(NSString *)key;

- (void)setAnnotationToolbarItemEnabled:(NSString *)itemId enable:(BOOL)enable;

- (NSDictionary<NSString *, NSNumber *> *)getPageCropBox:(NSInteger)pageNumber;

- (bool)setCurrentPage:(NSInteger)pageNumber;

- (NSArray *)getVisiblePages;

- (bool)gotoPreviousPage;

- (bool)gotoNextPage;

- (bool)gotoFirstPage;

- (bool)gotoLastPage;

- (void)showGoToPageView;

- (void)closeAllTabs;

- (void)openTabSwitcher;

- (int)getPageRotation;

- (void)rotateClockwise;

- (void)rotateCounterClockwise;

- (void)undo;

- (void)redo;

- (bool)canUndo;

- (bool)canRedo;

- (double)getZoom;

- (void)setZoomLimits:(NSString *)zoomLimitMode minimum:(double)minimum maximum:(double)maximum;

- (void)zoomWithCenter:(double)zoom x:(int)x y:(int)y;

- (void)zoomToRect:(int)pageNumber rect:(NSDictionary *)rect;

- (void)smartZoom:(int)x y:(int)y animated:(BOOL)animated;

- (NSDictionary<NSString *, NSNumber *> *)getScrollPos;

- (NSDictionary<NSString *, NSNumber *> *)getCanvasSize;

- (NSArray *)convertScreenPointsToPagePoints:(NSArray *)points;

- (NSArray *)convertPagePointsToScreenPoints:(NSArray *)points;

- (int)getPageNumberFromScreenPoint:(double)x y:(double)y;

- (void)setProgressiveRendering:(BOOL)progressiveRendering initialDelay:(NSInteger)initialDelay interval:(NSInteger)interval;

- (void)setImageSmoothing:(BOOL)imageSmoothing;

- (void)setOverprint:(NSString *)overprint;

- (void)setPageBorderVisibility:(BOOL)pageBorderVisibility;

- (void)setPageTransparencyGrid:(BOOL)pageTransparencyGrid;

- (void)setDefaultPageColor:(NSDictionary *)defaultPageColor;

- (void)setBackgroundColor:(NSDictionary *)backgroundColor;

- (void)setColorPostProcessMode:(NSString *)colorPostProcessMode;

- (void)setColorPostProcessColors:(NSDictionary *)whiteColor blackColor:(NSDictionary *)blackColor;

- (void)findText:(NSString *)searchString matchCase:(BOOL)matchCase matchWholeWord:(BOOL)matchWholeWord searchUp:(BOOL)searchUp regExp:(BOOL)regExp;

- (void)cancelFindText;

- (void)openSearch;

- (void)startSearchMode:(NSString *)searchString matchCase:(BOOL)matchCase matchWholeWord:(BOOL)matchWholeWord;

- (void)exitSearchMode;

- (NSDictionary *)getSelection:(NSInteger)pageNumber;

- (BOOL)hasSelection;

- (void)clearSelection;

- (NSDictionary *)getSelectionPageRange;

- (bool)hasSelectionOnPage:(NSInteger)pageNumber;

- (BOOL)selectInRect:(NSDictionary *)rect;

- (BOOL)isThereTextInRect:(NSDictionary *)rect;

- (void)selectAll;

- (void)importAnnotationCommand:(NSString *)xfdfCommand initialLoad:(BOOL)initialLoad;

- (void)setCurrentToolbar:(NSString *)toolbarTitle;

- (void)openOutlineList;

- (void)openLayersList;

- (void)openNavigationLists;

- (void)openAnnotationList;

- (BOOL)isReflowMode;

- (void)toggleReflow;

- (void)showViewSettingsFromRect:(NSDictionary *)rect;

- (void)showAddPagesViewFromRect:(NSDictionary *)rect;

- (void)shareCopyfromRect:(NSDictionary *)rect withFlattening:(BOOL)flattening;

- (void)openThumbnailsView;

-(NSArray *)getSavedSignatures;

-(NSString *)getSavedSignatureFolder;

// Hygen Generated Methods
- (void)setStampImageData:(NSString *)annotationId pageNumber:(NSInteger)pageNumber stampImageDataUrl:(NSString *)stampImageDataUrl;
- (void)setFormFieldHighlightColor:(NSDictionary *)fieldHighlightColor;
@end


@interface RNTPTThumbnailsViewController : PTThumbnailsViewController

@end

@interface RNTPTAnnotationManager : PTAnnotationManager

@property (nonatomic, assign, getter=isReplyReviewStateEnabled) BOOL replyReviewStateEnabled;

@end

@interface RNTPTAnnotationReplyViewController : PTAnnotationReplyViewController

@end

@interface RNTPTDigitalSignatureTool : PTDigitalSignatureTool

@end

NS_ASSUME_NONNULL_END
