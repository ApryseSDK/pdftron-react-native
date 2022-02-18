//
//  RNTPTDocumentViewManager.h
//  RNPdftron
//
//  Copyright © 2018 PDFTron. All rights reserved.
//

#import "RNTPTDocumentView.h"

#import <React/RCTViewManager.h>

@interface RNTPTDocumentViewManager : RCTViewManager <RNTPTDocumentViewDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, RNTPTDocumentView *> *documentViews;

- (void)setToolModeForDocumentViewTag:(NSNumber *)tag toolMode:(NSString *)toolMode;

- (BOOL)commitToolForDocumentViewTag:(NSNumber *)tag;

- (NSString *)getDocumentPathForDocumentViewTag:(NSNumber *)tag;

- (NSString*) exportAsImageForDocumentViewTag:(NSNumber*)tag pageNumber:(int)pageNumber dpi:(int)dpi exportFormat:(NSString*)exportFormat;

- (int)getPageCountForDocumentViewTag:(NSNumber *)tag;

- (void)importBookmarkJsonForDocumentViewTag:(NSNumber *)tag bookmarkJson:(NSString *)bookmarkJson;

- (void)openBookmarkListForDocumentViewTag:(NSNumber *)tag;

- (NSString *)exportAnnotationsForDocumentViewTag:(NSNumber *)tag options:(NSDictionary *)options;

- (void)importAnnotationsForDocumentViewTag:(NSNumber *)tag xfdf:(NSString *)xfdfString replace:(BOOL)replace;

- (void)flattenAnnotationsForDocumentViewTag:(NSNumber *)tag formsOnly:(BOOL)formsOnly;

- (void)deleteAnnotationsForDocumentViewTag:(NSNumber *)tag annotations:(NSArray *)annotations;

- (void)saveDocumentForDocumentViewTag:(NSNumber *)tag completionHandler:(void (^)(NSString * _Nullable filePath))completionHandler;

- (void)setFlagForFieldsForDocumentViewTag:(NSNumber *)tag forFields:(NSArray<NSString *> *)fields setFlag:(PTFieldFlag)flag toValue:(BOOL)value;

- (void)setValuesForFieldsForDocumentViewTag:(NSNumber *)tag map:(NSDictionary<NSString *, id> *)map;

- (NSDictionary *)getFieldForDocumentViewTag:(NSNumber *)tag fieldName:(NSString *)fieldName;

- (void)setFlagsForAnnotationsForDocumentViewTag:(NSNumber*) tag annotationFlagList:(NSArray *)annotationFlagList;

- (void)selectAnnotationForDocumentViewTag:(NSNumber *)tag annotationId:(NSString *)annotationId pageNumber:(NSInteger)pageNumber;

- (void)setPropertiesForAnnotationForDocumentViewTag:(NSNumber *)tag annotationId:(NSString *)annotationId pageNumber:(NSInteger)pageNumber propertyMap:(NSDictionary *)propertyMap;

- (NSDictionary *)getPropertiesForAnnotationForDocumentViewTag:(NSNumber *)tag annotationId:(NSString *)annotationId pageNumber:(NSInteger)pageNumber;

- (void)setDrawAnnotationsForDocumentViewTag:(NSNumber *)tag drawAnnotations:(BOOL)drawAnnotations;

- (void)setVisibilityForAnnotationForDocumentViewTag:(NSNumber *)tag annotationId:(NSString *)annotationId pageNumber:(NSInteger)pageNumber visibility:(BOOL)visibility;

- (void)setHighlightFieldsForDocumentViewTag:(NSNumber *)tag highlightFields:(BOOL)highlightFields;

- (NSDictionary *)getAnnotationAtForDocumentViewTag:(NSNumber *)tag x:(NSInteger)x y:(NSInteger)y distanceThreshold:(double)distanceThreshold minimumLineWeight:(double)minimumLineWeight;

- (NSArray *)getAnnotationListAtForDocumentViewTag:(NSNumber *)tag x1:(NSInteger)x1 y1:(NSInteger)y1 x2:(NSInteger)x2 y2:(NSInteger)y2;

- (NSArray *)getAnnotationListOnPageForDocumentViewTag:(NSNumber *)tag pageNumber:(NSInteger)pageNumber;

- (NSString *)getCustomDataForAnnotationForDocumentViewTag:(NSNumber *) tag annotationId:(NSString *)annotationId  pageNumber:(NSInteger)pageNumber key:(NSString *)key;

- (NSDictionary<NSString *, NSNumber *> *)getPageCropBoxForDocumentViewTag:(NSNumber *)tag pageNumber:(NSInteger)pageNumber;

- (NSMutableArray<NSDictionary *> *)getAllFieldsForDocumentViewTag:(NSNumber *)tag pageNumber:(NSInteger)pageNumber;

- (BOOL)setCurrentPageForDocumentViewTag:(NSNumber *)tag pageNumber:(NSInteger)pageNumber;

- (NSArray *)getVisiblePagesForDocumentViewTag:(NSNumber *)tag;

- (BOOL)gotoPreviousPageForDocumentViewTag:(NSNumber *)tag;

- (BOOL)gotoNextPageForDocumentViewTag:(NSNumber *)tag;

- (BOOL)gotoFirstPageForDocumentViewTag:(NSNumber *)tag;

- (BOOL)gotoLastPageForDocumentViewTag:(NSNumber *)tag;

-(void)showGoToPageViewForDocumentViewTag:(NSNumber *)tag;

- (void)closeAllTabsForDocumentViewTag:(NSNumber *)tag;

- (void)openTabSwitcherForDocumentViewTag:(NSNumber *)tag;

- (double)getZoomForDocumentViewTag:(NSNumber *)tag;

- (int)getPageRotationForDocumentViewTag:(NSNumber *)tag;

- (void)rotateClockwiseForDocumentViewTag:(NSNumber *)tag;

- (void)rotateCounterClockwiseForDocumentViewTag:(NSNumber *)tag;

- (void)undoForDocumentViewTag:(NSNumber *)tag;

- (void)redoForDocumentViewTag:(NSNumber *)tag;

- (bool)canUndoForDocumentViewTag:(NSNumber *)tag;

- (bool)canRedoForDocumentViewTag:(NSNumber *)tag;

- (void)setZoomLimitsForDocumentViewTag:(nonnull NSNumber *)tag zoomLimitMode:(NSString *)zoomLimitMode minimum:(double)minimum maximum:(double)maximum;

- (void)zoomWithCenterForDocumentViewTag:(nonnull NSNumber *)tag zoom:(double)zoom x:(int)x y:(int)y;

- (void)zoomToRectForDocumentViewTag:(nonnull NSNumber *)tag pageNumber:(int)pageNumber rect:(NSDictionary *)rect;

- (void)smartZoomForDocumentViewTag:(nonnull NSNumber *)tag x:(int)x y:(int)y animated:(BOOL)animated;

- (NSDictionary<NSString *, NSNumber *> *)getScrollPosForDocumentViewTag:(NSNumber *)tag;

- (NSDictionary<NSString *, NSNumber *> *)getCanvasSizeForDocumentViewTag:(NSNumber *)tag;

- (NSArray *)convertScreenPointsToPagePointsForDocumentViewTag:(nonnull NSNumber *)tag points:(NSArray *)points;

- (NSArray *)convertPagePointsToScreenPointsForDocumentViewTag:(nonnull NSNumber *)tag points:(NSArray *)points;

- (int)getPageNumberFromScreenPointForDocumentViewTag:(nonnull NSNumber *)tag x:(double)x y:(double)y;

- (void)setProgressiveRenderingForDocumentViewTag:(NSNumber *)tag progressiveRendering:(BOOL)progressiveRendering initialDelay:(NSInteger)initialDelay interval:(NSInteger)interval;

- (void)setImageSmoothingforDocumentViewTag:(NSNumber *)tag imageSmoothing:(BOOL)imageSmoothing;

- (void)setOverprintforDocumentViewTag:(NSNumber *)tag overprint:(NSString *)overprint;

- (void)setPageBorderVisibilityForDocumentViewTag:(NSNumber *)tag pageBorderVisibility:(BOOL)pageBorderVisibility;

- (void)setPageTransparencyGridForDocumentViewTag:(NSNumber *)tag pageTransparencyGrid:(BOOL)pageTransparencyGrid;

- (void)setDefaultPageColorForDocumentViewTag:(NSNumber *)tag defaultPageColor:(NSDictionary *)defaultPageColor;

- (void)setBackgroundColorForDocumentViewTag:(NSNumber *)tag backgroundColor:(NSDictionary *)backgroundColor;

- (void)setColorPostProcessModeForDocumentViewTag:(NSNumber *)tag colorPostProcessMode:(NSString *)colorPostProcessMode;

- (void)setColorPostProcessColorsForDocumentViewTag:(NSNumber *)tag whiteColor:(NSDictionary *)whiteColor blackColor:(NSDictionary *)blackColor;

- (void)findTextForDocumentViewTag:(NSNumber *)tag searchString:(NSString *)searchString matchCase:(BOOL)matchCase matchWholeWord:(BOOL)matchWholeWord searchUp:(BOOL)searchUp regExp:(BOOL)regExp;

- (void)cancelFindTextForDocumentViewTag:(NSNumber *)tag;

- (void)openSearchForDocumentViewTag:(NSNumber *)tag;

- (void)startSearchModeForDocumentViewTag:(NSNumber *)tag searchString:(NSString *)searchString matchCase:(BOOL)matchCase matchWholeWord:(BOOL)matchWholeWord;

- (void)exitSearchModeForDocumentViewTag:(NSNumber *)tag;

- (NSDictionary *)getSelectionForDocumentViewTag:(NSNumber *)tag pageNumber:(NSInteger)pageNumber;

- (BOOL)hasSelectionForDocumentViewTag:(NSNumber *)tag;

- (void)clearSelectionForDocumentViewTag:(NSNumber *)tag;

- (NSDictionary *)getSelectionPageRangeForDocumentViewTag:(NSNumber *)tag;

- (bool)hasSelectionOnPageForDocumentViewTag:(NSNumber *)tag pageNumber:(NSInteger)pageNumber;

- (BOOL)selectInRectForDocumentViewTag:(NSNumber *)tag rect:(NSDictionary *)rect;

- (BOOL)isThereTextInRectForDocumentViewTag:(NSNumber *)tag rect:(NSDictionary *)rect;

- (void)selectAllForDocumentViewTag:(NSNumber *)tag;

- (void)importAnnotationCommandForDocumentViewTag:(NSNumber *)tag xfdfCommand:(NSString *)xfdfCommand initialLoad:(BOOL)initialLoad;

- (void)setCurrentToolbarForDocumentViewTag:(NSNumber *)tag toolbarTitle:(NSString*)toolbarTitle;

- (void)openOutlineListForDocumentViewTag:(NSNumber *)tag;

- (void)openLayersListForDocumentViewTag:(NSNumber *)tag;

- (void)openNavigationListsForDocumentViewTag:(NSNumber *) tag;

- (void)openAnnotationListForDocumentViewTag:(NSNumber *)tag;

- (BOOL)isReflowModeForDocumentViewTag:(NSNumber *)tag;

- (void)toggleReflow:(NSNumber *)tag;

- (void)showViewSettingsForDocumentViewTag:(nonnull NSNumber *)tag rect:(NSDictionary *)rect;

- (void)showAddPagesViewForDocumentViewTag:(nonnull NSNumber *)tag rect:(NSDictionary *)rect;

- (void)shareCopyForDocumentViewTag:(nonnull NSNumber *)tag rect:(NSDictionary *)rect withFlattening:(BOOL)flattening;

- (void)openThumbnailsViewForDocumentViewTag:(NSNumber *)tag;

- (NSArray *)getSavedSignaturesForDocumentViewTag:(NSNumber *)tag;

- (NSString *)getSavedSignatureFolderForDocumentViewTag:(NSNumber *)tag;

@end
