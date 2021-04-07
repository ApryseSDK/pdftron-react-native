#import "RNTPTDocumentViewModule.h"

#import "RNTPTDocumentViewManager.h"

#import <React/RCTLog.h>
#import <PDFNet/PDFNet.h>

@implementation RNTPTDocumentViewModule

@synthesize bridge = _bridge;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE(DocumentViewManager) // JS-name

- (RNTPTDocumentViewManager *)documentViewManager
{
    return [self.bridge moduleForClass:[RNTPTDocumentViewManager class]];
}

- (NSError *)errorFromException:(NSException *)exception
{
    return [NSError errorWithDomain:@"com.pdftron.react-native" code:0 userInfo:
            @{
              NSLocalizedDescriptionKey: exception.name,
              NSLocalizedFailureReasonErrorKey: exception.reason,
              }];
}

#pragma mark - Methods

RCT_REMAP_METHOD(setToolMode,
                 setToolModeForDocumentViewTag:(nonnull NSNumber *)tag
                 toolMode:(NSString *)toolMode)
{
    [[self documentViewManager] setToolModeForDocumentViewTag:tag toolMode:toolMode];
}

RCT_REMAP_METHOD(commitTool,
                 commitToolForDocumentViewTag:(nonnull NSNumber *)tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        BOOL committed = [[self documentViewManager] commitToolForDocumentViewTag:tag];
        resolve(@(committed));
    }
    @catch (NSException *exception) {
        reject(@"commit_tool", @"Failed to commit tool", [self errorFromException:exception]);
    }
}

#pragma mark - Methods (w/ promises)

RCT_REMAP_METHOD(getDocumentPath,
                 getDocumentPathForDocumentViewTag:(nonnull NSNumber *)tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSString *path = [[self documentViewManager] getDocumentPathForDocumentViewTag:tag];
        resolve(path);
    }
    @catch (NSException *exception) {
        reject(@"export_failed", @"Failed to get document path", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(getPageCount,
                 getPageCountForDocumentViewTag:(nonnull NSNumber *)tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        int pageCount = [[self documentViewManager] getPageCountForDocumentViewTag:tag];
        resolve(@(pageCount));
    }
    @catch (NSException *exception) {
        reject(@"get_failed", @"Failed to get page count", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(importBookmarkJson,
                 importBookmarkJsonForDocumentViewTag:(nonnull NSNumber *)tag
                 bookmarkJson:(NSString *)bookmarkJson
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] importBookmarkJsonForDocumentViewTag:tag bookmarkJson:bookmarkJson];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"import_failed", @"Failed to import bookmark json", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(exportAnnotations,
                 exportAnnotationsForDocumentViewTag:(nonnull NSNumber *)tag
                 options:(NSDictionary *)options
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSString *xfdf = [[self documentViewManager] exportAnnotationsForDocumentViewTag:tag
                                                                                 options:options];
        resolve(xfdf);
    }
    @catch (NSException *exception) {
        reject(@"export_failed", @"Failed to export annotations", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(importAnnotations,
                 importAnnotationsForDocumentViewTag:(nonnull NSNumber *)tag
                 xfdf:(NSString *)xfdf
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] importAnnotationsForDocumentViewTag:tag xfdf:xfdf];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"import_failed", @"Failed to import annotations", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(flattenAnnotations,
                 flattenAnnotationsForDocumentViewTag:(nonnull NSNumber *)tag
                 formsOnly:(BOOL)formsOnly
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] flattenAnnotationsForDocumentViewTag:tag formsOnly:formsOnly];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"flatten_failed", @"Failed to flatten annotations", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(deleteAnnotations,
                 deleteAnnotationsForDocumentViewTag:(nonnull NSNumber *)tag
                 annotations:(NSArray *)annotations
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] deleteAnnotationsForDocumentViewTag:tag annotations:annotations];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"delete_failed", @"Failed to delete annotations", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(saveDocument,
                 saveDocumentForDocumentViewTag:(nonnull NSNumber *)tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] saveDocumentForDocumentViewTag:tag completionHandler:^(NSString * _Nullable filePath) {
            if (filePath) {
                resolve(filePath);
            } else {
                reject(@"save_failed", @"Failed to save document", nil);
            }
        }];
    }
    @catch (NSException *exception) {
        reject(@"save_failed", @"Failed to save document", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(setFlagForFields,
                 setFlagForFieldsForDocumentViewTag:(nonnull NSNumber *)tag
                 fields:(NSArray<NSString *> *)fields
                 flag:(NSInteger)flag
                 value:(BOOL)value
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] setFlagForFieldsForDocumentViewTag:tag forFields:fields setFlag:(PTFieldFlag)flag toValue:value];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"set_flag_for_fields", @"Failed to set flag on fields", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(setValuesForFields,
                 setValuesForFieldsForDocumentViewTag:(nonnull NSNumber *)tag
                 map:(NSDictionary<NSString *, id> *)map
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] setValuesForFieldsForDocumentViewTag:tag map:map];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"set_value_for_fields", @"Failed to set value on fields", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(getField,
                 getFieldForDocumentViewTag:(nonnull NSNumber *)tag
                 fieldName:(NSString *)fieldName
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSDictionary *field = [[self documentViewManager] getFieldForDocumentViewTag:tag fieldName:fieldName];
        resolve(field);
    }
    @catch (NSException *exception) {
        reject(@"set_value_for_fields", @"Failed to set value on fields", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(setFlagsForAnnotations,
                 setFlagsForAnnotationsForDocumentViewTag:(nonnull NSNumber *)tag
                 annotationFlagList:(NSArray *)annotationFlagList
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] setFlagsForAnnotationsForDocumentViewTag:tag annotationFlagList:annotationFlagList];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"set_flag_for_annotations", @"Failed to set flag on annotations", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(selectAnnotation,
                 selectAnnotationForDocumentViewTag:(nonnull NSNumber *)tag
                 annotationId:(NSString *)annotationId
                 pageNumber:(NSInteger)pageNumber
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] selectAnnotationForDocumentViewTag:tag annotationId:annotationId pageNumber:pageNumber];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"select_annotation", @"Failed to select annotation", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(setPropertiesForAnnotation,
                 setPropertiesForAnnotationForDocumentViewTag: (nonnull NSNumber *)tag
                 annotationId:(NSString *)annotationId
                 pageNumber:(NSInteger)pageNumber
                 propertyMap:(NSDictionary *)propertyMap
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] setPropertiesForAnnotationForDocumentViewTag:tag annotationId:annotationId pageNumber:pageNumber propertyMap:propertyMap];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"set_property_for_annotation", @"Failed to set property for annotation", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(setDrawAnnotations,
                 setDrawAnnotationsForDocumentViewTag: (nonnull NSNumber *)tag
                 drawAnnotations:(BOOL)drawAnnotations
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] setDrawAnnotationsForDocumentViewTag:tag drawAnnotations:drawAnnotations];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"set_draw_annotations", @"Failed to set draw annotations", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(setVisibilityForAnnotation,
                 setVisibilityForAnnotationForDocumentViewTag: (nonnull NSNumber *)tag
                 annotationId:(NSString *)annotationId
                 pageNumber:(NSInteger)pageNumber
                 visibility:(BOOL)visibility
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] setVisibilityForAnnotationForDocumentViewTag:tag annotationId:annotationId pageNumber:pageNumber visibility:visibility];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"set_visibility_for_annotation", @"Failed to set visibility for annotation", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(setHighlightFields,
                 setHighlightFieldsForDocumentViewTag: (nonnull NSNumber *)tag
                 highlightFields:(BOOL)highlightFields
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] setHighlightFieldsForDocumentViewTag:tag highlightFields:highlightFields];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"set_highlight_fields", @"Failed to set highlight fields", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(getPageCropBox,
                 getPageCropBoxForDocumentViewTag: (nonnull NSNumber *)tag
                 pageNumber:(NSInteger)pageNumber
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSDictionary<NSString *, NSNumber *> *cropBox = [[self documentViewManager] getPageCropBoxForDocumentViewTag:tag pageNumber:pageNumber];
        resolve(cropBox);
    }
    @catch (NSException *exception) {
        reject(@"get_page_crop_box", @"Failed to get page cropbox", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(setCurrentPage,
                 setCurrentPageforDocumentViewTag: (nonnull NSNumber *) tag
                 pageNumber:(NSInteger)pageNumber
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        bool setResult = [[self documentViewManager] setCurrentPageForDocumentViewTag:tag pageNumber:pageNumber];
        resolve([NSNumber numberWithBool:setResult]);
    }
    @catch (NSException *exception) {
        reject(@"set_current_page", @"Failed to set current page", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(gotoPreviousPage,
                 gotoPreviousPageforDocumentViewTag: (nonnull NSNumber *) tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        bool setResult = [[self documentViewManager] gotoPreviousPageForDocumentViewTag:tag];
        resolve([NSNumber numberWithBool:setResult]);
    }
    @catch (NSException *exception) {
        reject(@"goto_previous_page", @"Failed to go to previous page", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(gotoNextPage,
                 gotoNextPageforDocumentViewTag: (nonnull NSNumber *) tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        bool setResult = [[self documentViewManager] gotoNextPageForDocumentViewTag:tag];
        resolve([NSNumber numberWithBool:setResult]);
    }
    @catch (NSException *exception) {
        reject(@"goto_next_page", @"Failed to go to next page", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(gotoFirstPage,
                 gotoFirstPageforDocumentViewTag: (nonnull NSNumber *) tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        bool setResult = [[self documentViewManager] gotoFirstPageForDocumentViewTag:tag];
        resolve([NSNumber numberWithBool:setResult]);
    }
    @catch (NSException *exception) {
        reject(@"goto_first_page", @"Failed to go to first page", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(gotoLastPage,
                 gotoLastPageforDocumentViewTag: (nonnull NSNumber *) tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        bool setResult = [[self documentViewManager] gotoLastPageForDocumentViewTag:tag];
        resolve([NSNumber numberWithBool:setResult]);
    }
    @catch (NSException *exception) {
        reject(@"goto_last_page", @"Failed to go to last page", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(closeAllTabs,
                 closeAllTabsForDocumentViewTag:(nonnull NSNumber *)tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] closeAllTabsForDocumentViewTag:tag];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"export_failed", @"Failed to close all tabs", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(getPageRotation,
                 getPageRotationForDocumentViewTag: (nonnull NSNumber *)tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        int pageNumber = [[self documentViewManager] getPageRotationForDocumentViewTag:tag];
        resolve([NSNumber numberWithInt:pageNumber]);
    }
    @catch (NSException *exception) {
        reject(@"get_page_rotation", @"Failed to get page rotation", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(rotateClockwise,
                 rotateClockwiseForDocumentViewTag: (nonnull NSNumber *)tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] rotateClockwiseForDocumentViewTag:tag];
    }
    @catch (NSException *exception) {
        reject(@"rotate_clockwise", @"Failed to rotate clockwise", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(rotateCounterClockwise,
                 rotateCounterClockwiseForDocumentViewTag: (nonnull NSNumber *)tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] rotateCounterClockwiseForDocumentViewTag:tag];
    }
    @catch (NSException *exception) {
        reject(@"rotate_counter_clockwise", @"Failed to rotate counter-clockwise", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(getZoom,
                 getZoomForDocumentViewTag: (nonnull NSNumber *)tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        double zoom = [[self documentViewManager] getZoom:tag];
        resolve([NSNumber numberWithDouble:zoom]);
    }
    @catch (NSException *exception) {
        reject(@"get_zoom", @"Failed to get zoom", [self errorFromException:exception]);
    }
}
                 
RCT_REMAP_METHOD(setZoomLimits,
                 setZoomLimitsForDocumentViewTag:(nonnull NSNumber *)tag
                 zoomLimitMode:(NSString *)zoomLimitMode
                 minimum:(double)minimum
                 maximum:(double)maximum
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] setZoomLimitsForDocumentViewTag:tag zoomLimitMode:zoomLimitMode minimum:minimum maximum:maximum];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"set_failed", @"Failed to set zoom limits", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(zoomWithCenter,
                 zoomWithCenterForDocumentViewTag:(nonnull NSNumber *)tag
                 zoom:(double)zoom
                 x:(int)x
                 y:(int)y
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] zoomWithCenterForDocumentViewTag:tag zoom:zoom x:x y:y];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"zoom_failed", @"Failed to zoom with center", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(zoomToRect,
                 zoomToRect:(nonnull NSNumber *)tag
                 pageNumber:(int)pageNumber
                 rect:(NSDictionary *)rect
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] zoomToRectForDocumentViewTag:tag pageNumber:pageNumber rect:rect];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"zoom_failed", @"Failed to zoom to rect", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(smartZoom,
                 smartZoomForDocumentViewTag:(nonnull NSNumber *)tag
                 x:(int)x
                 y:(int)y
                 animated:(BOOL)animated
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] smartZoomForDocumentViewTag:tag x:x y:y animated:animated];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"zoom_failed", @"Failed to smart zoom", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(getScrollPos,
                 getScrollPosForDocumentViewTag: (nonnull NSNumber *)tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSDictionary<NSString *, NSNumber *> *scrollPos = [[self documentViewManager] getScrollPosForDocumentViewTag:tag];
        resolve(scrollPos);
    }
    @catch (NSException *exception) {
        reject(@"get_scroll_pos", @"Failed to get scroll pos", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(setProgressiveRendering,
                 setProgressiveRenderingforDocumentViewTag: (nonnull NSNumber *) tag
                 progressiveRendering:(BOOL)progressiveRendering
                 initialDelay:(NSInteger)initialDelay
                 interval:(NSInteger)interval
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] setProgressiveRenderingForDocumentViewTag:tag progressiveRendering:progressiveRendering initialDelay:initialDelay interval:interval];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"set_progressive_rendering", @"Failed to set progressive rendering", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(setImageSmoothing,
                 setImageSmoothingforDocumentViewTag: (nonnull NSNumber *) tag
                 imageSmoothing:(BOOL)imageSmoothing
                resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] setImageSmoothingforDocumentViewTag:tag imageSmoothing:imageSmoothing];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"set_image_smoothing", @"Failed to set image smoothing", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(getCanvasSize,
                 getCanvasSizeForDocumentViewTag: (nonnull NSNumber *)tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSDictionary<NSString *, NSNumber *> *canvasSize = [[self documentViewManager] getCanvasSizeForDocumentViewTag:tag];
        resolve(canvasSize);
    }
    @catch (NSException *exception) {
        reject(@"get_canvas_size", @"Failed to get canvas size", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(setOverprint,
                 setOverprintforDocumentViewTag: (nonnull NSNumber *) tag
                 overprint:(NSString *)overprint
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] setOverprintforDocumentViewTag:tag overprint:overprint];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"set_overprint", @"Failed to set overprint", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(findText,
                 findTextForDocumentViewTag: (nonnull NSNumber *)tag
                 searchString:(NSString *)searchString
                 matchCase:(BOOL)matchCase
                 matchWholeWord:(BOOL)matchWholeWord
                 searchUp:(BOOL)searchUp
                 regExp:(BOOL)regExp
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] findTextForDocumentViewTag:tag searchString:searchString matchCase:matchCase matchWholeWord:matchWholeWord searchUp:searchUp regExp:regExp];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"find_text", @"Failed to initiaze a text search", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(cancelFindText,
                 cancelFindTextForDocumentViewTag: (nonnull NSNumber *)tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] cancelFindTextForDocumentViewTag:tag];
    }
    @catch (NSException *exception) {
        reject(@"cancel_text", @"Failed to cancel text search", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(getSelection,
                 getSelectionForDocumentViewTag: (nonnull NSNumber *)tag
                 pageNumber:(NSInteger)pageNumber
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSDictionary *selection = [[self documentViewManager] getSelectionForDocumentViewTag:tag pageNumber:pageNumber];
        resolve(selection);
    }
    @catch (NSException *exception) {
        reject(@"get_selection", @"Failed to get text selection", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(selectInRect,
                 selectInRectForDocumentViewTag: (nonnull NSNumber *)tag
                 rect:(NSDictionary *)rect
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        BOOL selected = [[self documentViewManager] selectInRectForDocumentViewTag:tag rect:rect];
        resolve([NSNumber numberWithBool:selected]);
    }
    @catch (NSException *exception) {
        reject(@"select_in_rect", @"Failed to select in rect", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(isThereTextInRect,
                 isThereTextInRectForDocumentViewTag: (nonnull NSNumber *)tag
                 rect:(NSDictionary *)rect
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        BOOL hasText = [[self documentViewManager] isThereTextInRectForDocumentViewTag:tag rect:rect];
        resolve([NSNumber numberWithBool:hasText]);
    }
    @catch (NSException *exception) {
        reject(@"is_there_text_in_rect", @"Failed to get whether there is text in rect", [self errorFromException:exception]);
    }
}

RCT_REMAP_METHOD(selectAll,
                 selectAllForDocumentViewTag: (nonnull NSNumber *)tag
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejector:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] selectAllForDocumentViewTag:tag];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"select_all", @"Failed to select all", [self errorFromException:exception]);
    }
}

#pragma mark - Collaboration

RCT_REMAP_METHOD(importAnnotationCommand,
                 importAnnotationCommandForDocumentViewTag:(nonnull NSNumber *)tag
                 xfdf:(NSString *)xfdfCommand
                 initialLoad:(BOOL)initialLoad
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        [[self documentViewManager] importAnnotationCommandForDocumentViewTag:tag xfdfCommand:xfdfCommand initialLoad:initialLoad];
        resolve(nil);
    }
    @catch (NSException *exception) {
        reject(@"import_failed", @"Failed to import annotation command", [self errorFromException:exception]);
    }
}

@end
