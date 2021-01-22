#import <Tools/Tools.h>
#import <React/RCTComponent.h>

#import <UIKit/UIKit.h>

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
static NSString * const PTReflowButtonKey = @"reflowButton";
static NSString * const PTEditPagesButtonKey = @"editPagesButton";
static NSString * const PTPrintButtonKey = @"printButton";
static NSString * const PTCloseButtonKey = @"closeButton";
static NSString * const PTSaveCopyButtonKey = @"saveCopyButton";
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


static NSString * const PTAnnotationEditToolKey = @"AnnotationEdit";
static NSString * const PTAnnotationCreateStickyToolKey = @"AnnotationCreateSticky";
static NSString * const PTAnnotationCreateFreeHandToolKey = @"AnnotationCreateFreeHand";
static NSString * const PTTextSelectToolKey = @"TextSelect";
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
static NSString * const PTAnnotationCreateSoundToolKey = @"AnnotationCreateSound";
static NSString * const PTPencilKitDrawingToolKey = @"PencilKitDrawing";
static NSString * const PTAnnotationCreateFreeHighlighterToolKey = @"AnnotationCreateFreeHighlighter";
static NSString * const PTAnnotationCreateRubberStampToolKey = @"AnnotationCreateRubberStamp";
static NSString * const PTAnnotationCreateRedactionToolKey = @"AnnotationCreateRedaction";
static NSString * const PTAnnotationCreateLinkToolKey = @"AnnotationCreateLink";
static NSString * const PTAnnotationCreateRedactionTextToolKey = @"AnnotationCreateRedactionText";
static NSString * const PTAnnotationCreateLinkTextToolKey = @"AnnotationCreateLinkText";
static NSString * const PTFormCreateTextFieldToolKey = @"FormCreateTextField";
static NSString * const PTFormCreateCheckboxFieldToolKey = @"FormCreateCheckboxField";
static NSString * const PTFormCreateSignatureFieldToolKey = @"FormCreateSignatureField";
static NSString * const PTFormCreateRadioFieldToolKey = @"FormCreateRadioField";
static NSString * const PTFormCreateComboBoxFieldToolKey = @"FormCreateComboBoxField";
static NSString * const PTFormCreateListBoxFieldToolKey = @"FormCreateListBoxField";

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

static NSString * const PTModifyAnnotationActionKey = @"modify";
static NSString * const PTAddAnnotationActionKey = @"add";
static NSString * const PTDeleteAnnotationActionKey = @"delete";
static NSString * const PTRemoveAnnotationActionKey = @"remove";

static NSString * const PTAnnotListArgumentKey = @"annotList";
static NSString * const PTAnnotationIdKey = @"id";
static NSString * const PTAnnotationPageNumberKey = @"pageNumber";
static NSString * const PTAnnotationFlagKey = @"flag";
static NSString * const PTAnnotationFlagValueKey = @"flagValue";

static NSString * const PTContentRectAnnotationPropertyKey = @"contentRect";
static NSString * const PTContentsAnnotationPropertyKey = @"contents";
static NSString * const PTSubjectAnnotationPropertyKey = @"subject";
static NSString * const PTTitleAnnotationPropertyKey = @"title";

static NSString * const PTLinkPressLinkAnnotationKey = @"linkPress";
static NSString * const PTURILinkAnnotationKey = @"URI";
static NSString * const PTURLLinkAnnotationKey = @"url";
static NSString * const PTDataLinkAnnotationKey = @"data";
static NSString * const PTActionLinkAnnotationKey = @"action";

static NSString * const PTStyleMenuItemTitleKey = @"Style";
static NSString * const PTNoteMenuItemTitleKey = @"Note";
static NSString * const PTCopyMenuItemTitleKey = @"Copy";
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

static NSString * const PTRectKey = @"rect";
static NSString * const PTRectX1Key = @"x1";
static NSString * const PTRectY1Key = @"y1";
static NSString * const PTRectX2Key = @"x2";
static NSString * const PTRectY2Key = @"y2";
static NSString * const PTRectWidthKey = @"width";
static NSString * const PTRectHeightKey = @"height";

static NSString * const PTFormFieldNameKey = @"fieldName";
static NSString * const PTFormFieldValueKey = @"fieldValue";

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
static const PTDefaultAnnotationToolbarKey PTAnnotationToolbarFavorite = @"PDFTron_Favorite";

// Custom annotation toolbar keys.
typedef NSString * PTAnnotationToolbarKey;
static const PTAnnotationToolbarKey PTAnnotationToolbarKeyId = @"id";
static const PTAnnotationToolbarKey PTAnnotationToolbarKeyName = @"name";
static const PTAnnotationToolbarKey PTAnnotationToolbarKeyIcon = @"icon";
static const PTAnnotationToolbarKey PTAnnotationToolbarKeyItems = @"items";

@class RNTPTDocumentView;

@protocol RNTPTDocumentViewDelegate <NSObject>
@optional
- (void)documentViewAttachedToWindow:(RNTPTDocumentView *)documentView;
- (void)documentViewDetachedFromWindow:(RNTPTDocumentView *)documentView;

- (void)navButtonClicked:(RNTPTDocumentView *)sender;
- (void)documentLoaded:(RNTPTDocumentView *)sender;
- (void)documentError:(RNTPTDocumentView *)sender error:(nullable NSString *)error;
- (void)pageChanged:(RNTPTDocumentView *)sender previousPageNumber:(int)previousPageNumber;
- (void)zoomChanged:(RNTPTDocumentView *)sender zoom:(double)zoom;

- (void)annotationsSelected:(RNTPTDocumentView *)sender annotations:(NSArray<NSDictionary<NSString *, id> *> *)annotations;

- (void)annotationChanged:(RNTPTDocumentView *)sender annotation:(NSDictionary *)annotation action:(NSString *)action;

- (void)formFieldValueChanged:(RNTPTDocumentView *)sender fields:(NSDictionary *)fields;

- (void)exportAnnotationCommand:(RNTPTDocumentView *)sender action:(NSString *)action xfdfCommand:(NSString *)xfdfCommand;

- (void)annotationMenuPressed:(RNTPTDocumentView *)sender annotationMenu:(NSString *)annotationMenu annotations:(NSArray<NSDictionary<NSString *, id> *> *)annotations;

- (void)longPressMenuPressed:(RNTPTDocumentView *)sender longPressMenu:(NSString *)longPressMenu longPressText:(NSString *)longPressText;

- (void)bookmarkChanged:(RNTPTDocumentView *)sender bookmarkJson:(NSString *)bookmarkJson;

- (void)toolChanged:(RNTPTDocumentView *)sender previousTool:(NSString *)previousTool tool:(NSString *)tool;

@end

@interface RNTPTDocumentView : UIView

@property (nonatomic, copy, nullable) NSArray<NSString *> *disabledElements;
@property (nonatomic, copy, nullable) NSArray<NSString *> *disabledTools;


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
@property (nonatomic, assign) BOOL hideToolbarsOnTap;
@property (nonatomic, assign) BOOL pageIndicatorShowsOnPageChange;
@property (nonatomic, assign) BOOL pageIndicatorShowsWithControls;
@property (nonatomic, assign) BOOL autoSaveEnabled;

@property (nonatomic, copy, nullable) NSString *password;
@property (nonatomic, copy, nullable) NSString *document;
@property (nonatomic, getter=isBase64String) BOOL base64String;
@property (nonatomic) int initialPageNumber;
@property (nonatomic) int pageNumber;
@property (nonatomic, assign) BOOL showNavButton;
@property (nonatomic, copy, nullable) NSString *navButtonPath;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *customHeaders;
@property (nonatomic, assign, getter=isReadOnly) BOOL readOnly;

@property (nonatomic, copy) NSString *fitMode;
@property (nonatomic, copy) NSString *layoutMode;

@property (nonatomic, copy, nullable) NSArray<NSString *> *annotationMenuItems;

@property (nonatomic, assign) BOOL pageChangeOnTap;

@property (nonatomic, assign, getter=isThumbnailViewEditingEnabled) BOOL thumbnailViewEditingEnabled;

@property (nonatomic, copy) NSString *annotationAuthor;

@property (nonatomic) BOOL continuousAnnotationEditing;

@property (nonatomic) BOOL useStylusAsPen;

@property (nonatomic) BOOL showSavedSignatures;

@property (nonatomic, assign, getter=isCollabEnabled) BOOL collabEnabled;

@property (nonatomic, copy, nullable) NSString *currentUser;

@property (nonatomic, copy, nullable) NSString *currentUserName;

@property (nonatomic, assign) BOOL selectAnnotationAfterCreation;

@property (nonatomic, strong, nullable) PTCollaborationManager *collaborationManager;

@property (nonatomic, copy, nullable) RCTBubblingEventBlock onChange;

@property (nonatomic, weak, nullable) id <RNTPTDocumentViewDelegate> delegate;

@property (nonatomic, assign, getter=isLongPressMenuEnabled) BOOL longPressMenuEnabled;

@property (nonatomic, assign) BOOL signSignatureFieldsWithStamps;

@property (nonatomic, assign) BOOL annotationPermissionCheckEnabled;

@property (nonatomic, assign, getter=isMultiTabEnabled) BOOL multiTabEnabled;
@property (nonatomic, copy, nullable) NSString *tabTitle;

@property (nonatomic, copy, nullable) NSArray<id> *annotationToolbars;
@property (nonatomic, copy, nullable) NSArray<NSString *> *hideDefaultAnnotationToolbars;
@property (nonatomic) BOOL hideAnnotationToolbarSwitcher;
@property (nonatomic) BOOL hideTopToolbars;
@property (nonatomic) BOOL hideTopAppNavBar;

@property (nonatomic, copy, nullable) NSArray<NSString *> *hideThumbnailFilterModes;

#pragma mark - Methods

- (void)setToolMode:(NSString *)toolMode;

- (BOOL)commitTool;

- (int)getPageCount;

- (void)importBookmarkJson:(NSString *)bookmarkJson;

- (NSString *)getDocumentPath;

- (nullable NSString *)exportAnnotationsWithOptions:(NSDictionary *)options;

- (void)importAnnotations:(NSString *)xfdfString;

- (void)flattenAnnotations:(BOOL)formsOnly;

- (void)deleteAnnotations:(NSArray *)annotations;

- (void)saveDocumentWithCompletionHandler:(void (^)(NSString * _Nullable filePath))completionHandler;

- (void)setFlagForFields:(NSArray<NSString *> *)fields setFlag:(PTFieldFlag)flag toValue:(BOOL)value;

- (void)setValuesForFields:(NSDictionary<NSString *, id> *)map;

- (void)setFlagsForAnnotations:(NSArray *)annotationFlagList;

- (void)selectAnnotation:(NSString *)annotationId pageNumber:(NSInteger)pageNumber;

- (void)setPropertiesForAnnotation:(NSString *)annotationId pageNumber:(NSInteger)pageNumber propertyMap:(NSDictionary *)propertyMap;

- (NSDictionary<NSString *, NSNumber *> *)getPageCropBox:(NSInteger)pageNumber;

- (bool)setCurrentPage:(NSInteger)pageNumber;

- (void)closeAllTabs;

- (double)getZoom;

- (void)importAnnotationCommand:(NSString *)xfdfCommand initialLoad:(BOOL)initialLoad;

@end


@interface RNTPTThumbnailsViewController : PTThumbnailsViewController

@end
NS_ASSUME_NONNULL_END
