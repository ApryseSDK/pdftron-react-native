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

- (int)getPageCountForDocumentViewTag:(NSNumber *)tag;

- (void)importBookmarkJsonForDocumentViewTag:(NSNumber *)tag bookmarkJson:(NSString *)bookmarkJson;

- (NSString *)exportAnnotationsForDocumentViewTag:(NSNumber *)tag options:(NSDictionary *)options;
- (void)importAnnotationsForDocumentViewTag:(NSNumber *)tag xfdf:(NSString *)xfdfString;

- (void)flattenAnnotationsForDocumentViewTag:(NSNumber *)tag formsOnly:(BOOL)formsOnly;

- (void)deleteAnnotationsForDocumentViewTag:(NSNumber *)tag annotations:(NSArray *)annotations;

- (void)saveDocumentForDocumentViewTag:(NSNumber *)tag completionHandler:(void (^)(NSString * _Nullable filePath))completionHandler;

- (void)setFlagForFieldsForDocumentViewTag:(NSNumber *)tag forFields:(NSArray<NSString *> *)fields setFlag:(PTFieldFlag)flag toValue:(BOOL)value;

- (void)setValuesForFieldsForDocumentViewTag:(NSNumber *)tag map:(NSDictionary<NSString *, id> *)map;

- (NSDictionary *)getFieldForDocumentViewTag:(NSNumber *)tag fieldName:(NSString *)fieldName;

- (void)setFlagsForAnnotationsForDocumentViewTag:(NSNumber*) tag annotationFlagList:(NSArray *)annotationFlagList;

- (void)selectAnnotationForDocumentViewTag:(NSNumber *)tag annotationId:(NSString *)annotationId pageNumber:(NSInteger)pageNumber;

- (void)setPropertiesForAnnotationForDocumentViewTag:(NSNumber *)tag annotationId:(NSString *)annotationId pageNumber:(NSInteger)pageNumber propertyMap:(NSDictionary *)propertyMap;

- (void)setDrawAnnotationsForDocumentViewTag:(NSNumber *)tag drawAnnotations:(BOOL)drawAnnotations;

- (void)setVisibilityForAnnotationForDocumentViewTag:(NSNumber *)tag annotationId:(NSString *)annotationId pageNumber:(NSInteger)pageNumber visibility:(BOOL)visibility;

- (void)setHighlightFieldsForDocumentViewTag:(NSNumber *)tag highlightFields:(BOOL)highlightFields;

- (NSDictionary<NSString *, NSNumber *> *)getPageCropBoxForDocumentViewTag:(NSNumber *)tag pageNumber:(NSInteger)pageNumber;

- (BOOL)setCurrentPageForDocumentViewTag:(NSNumber *)tag pageNumber:(NSInteger)pageNumber;

- (void)closeAllTabsForDocumentViewTag:(NSNumber *)tag;

- (double)getZoom:(NSNumber *)tag;

- (NSDictionary<NSString *, NSNumber *> *)getScrollPosForDocumentViewTag:(NSNumber *)tag;

- (NSDictionary<NSString *, NSNumber *> *)getCanvasSizeForDocumentViewTag:(NSNumber *)tag;

- (void)findTextForDocumentViewTag:(NSNumber *)tag searchString:(NSString *)searchString matchCase:(BOOL)matchCase matchWholeWord:(BOOL)matchWholeWord searchUp:(BOOL)searchUp regExp:(BOOL)regExp;

- (void)cancelFindTextForDocumentViewTag:(NSNumber *)tag;

- (NSDictionary *)getSelectionForDocumentViewTag:(NSNumber *)tag pageNumber:(NSInteger)pageNumber;

- (BOOL)selectInRectForDocumentViewTag:(NSNumber *)tag rect:(NSDictionary *)rect;

- (BOOL)isThereTextInRectForDocumentViewTag:(NSNumber *)tag rect:(NSDictionary *)rect;

- (void)selectAllForDocumentViewTag:(NSNumber *)tag;

- (void)importAnnotationCommandForDocumentViewTag:(NSNumber *)tag xfdfCommand:(NSString *)xfdfCommand initialLoad:(BOOL)initialLoad;

@end
