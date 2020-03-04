//
//  RNTPTDocumentViewManager.m
//  RNPdftron
//
//  Copyright © 2018 PDFTron. All rights reserved.
//

#import "RNTPTDocumentViewManager.h"

@implementation RNTPTDocumentViewManager

RCT_EXPORT_MODULE(RNTPTDocumentView)

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _documentViews = [NSMutableDictionary dictionary];
    }
    return self;
}

RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY(document, NSString, RNTPTDocumentView)
{
    if (json && [RCTConvert NSString:json]) {
        view.document = [RCTConvert NSString:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(password, NSString, RNTPTDocumentView)
{
    if (json) {
        view.password = [RCTConvert NSString:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(initialPageNumber, int, RNTPTDocumentView)
{
    if (json) {
        view.initialPageNumber = [RCTConvert int:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(pageNumber, int, RNTPTDocumentView)
{
    if (json) {
        view.pageNumber = [RCTConvert int:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(showLeadingNavButton, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.showNavButton = [RCTConvert BOOL:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(leadingNavButtonIcon, NSString, RNTPTDocumentView)
{
    if (json && [RCTConvert NSString:json]) {
        view.navButtonPath = [RCTConvert NSString:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(disabledElements, NSArray, RNTPTDocumentView)
{
    if (json) {
        NSArray* disabledElements = [RCTConvert NSArray:json];
        [view disableElements:disabledElements];
    }
    
}

RCT_CUSTOM_VIEW_PROPERTY(disabledTools, NSArray, RNTPTDocumentView)
{
    
    if( json ) {
        NSArray* disabledTools = [RCTConvert NSArray:json];
        [view setToolsPermission:disabledTools toValue:NO];
    }
}

// viewer options
//RCT_CUSTOM_VIEW_PROPERTY(nightModeEnabled, BOOL, RNTPTDocumentView)
//{
//    if (json) {
//        view.nightModeEnabled = [RCTConvert BOOL:json];
//    }
//}

RCT_CUSTOM_VIEW_PROPERTY(topToolbarEnabled, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.topToolbarEnabled = [RCTConvert BOOL:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(bottomToolbarEnabled, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.bottomToolbarEnabled = [RCTConvert BOOL:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(pageIndicatorEnabled, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.pageIndicatorEnabled = [RCTConvert BOOL:json];
    }
}

//RCT_CUSTOM_VIEW_PROPERTY(pageIndicatorShowsOnPageChange, BOOL, RNTPTDocumentView)
//{
//    if (json) {
//        view.pageIndicatorShowsOnPageChange = [RCTConvert BOOL:json];
//    }
//}
//
//RCT_CUSTOM_VIEW_PROPERTY(pageIndicatorShowsWithControls, BOOL, RNTPTDocumentView)
//{
//    if (json) {
//        view.pageIndicatorShowsWithControls = [RCTConvert BOOL:json];
//    }
//}

RCT_CUSTOM_VIEW_PROPERTY(customHeaders, NSDictionary, RNTPTDocumentView)
{
    if (json) {
        view.customHeaders = [RCTConvert NSDictionary:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(readOnly, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.readOnly = [RCTConvert BOOL:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(fitMode, NSString, RNTPTDocumentView)
{
    if (json) {
        view.fitMode = [RCTConvert NSString:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(layoutMode, NSString, RNTPTDocumentView)
{
    if (json) {
        view.layoutMode = [RCTConvert NSString:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(continuousAnnotationEditing, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.continuousAnnotationEditing = [RCTConvert BOOL:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(annotationAuthor, NSString, RNTPTDocumentView)
{
    if (json) {
        view.annotationAuthor = [RCTConvert NSString:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(showSavedSignatures, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.showSavedSignatures = [RCTConvert BOOL:json];
    }
}

- (UIView *)view
{
    RNTPTDocumentView *documentView = [[RNTPTDocumentView alloc] init];
    documentView.delegate = self;
    return documentView;
}

#pragma mark - Events

- (void)navButtonClicked: (RNTPTDocumentView *) sender
{
    if (sender.onChange) {
        sender.onChange(@{@"onLeadingNavButtonPressed": @(true)});
    }
}

- (void)documentLoaded:(RNTPTDocumentView *)sender
{
    if (sender.onChange) {
        sender.onChange(@{
                          @"onDocumentLoaded": (sender.document ?: @""),
                          });
    }
}

- (void)documentError:(RNTPTDocumentView *)sender error:(NSString *)error
{
    if (sender.onChange) {
        sender.onChange(@{
            @"onDocumentError": (error ?: @""),
        });
    }
}

- (void)pageChanged:(RNTPTDocumentView *)sender previousPageNumber:(int)previousPageNumber
{
    if (sender.onChange) {
        sender.onChange(@{
                          @"onPageChanged": @{
                                  @"previousPageNumber": @(previousPageNumber),
                                  @"pageNumber": @(sender.pageNumber),
                                  },
                          });
    }
}

- (void)annotationChanged:(RNTPTDocumentView *)sender annotation:(NSDictionary *)annotation action:(NSString *)action
{
    if (sender.onChange) {
        sender.onChange(@{
            @"onAnnotationChanged" : @"onAnnotationChanged",
            @"action": action,
            @"annotations": @[annotation],
        });
    }
}

#pragma mark - Methods

- (void)setToolModeForDocumentViewTag:(NSNumber *)tag toolMode:(NSString *)toolMode
{
    RNTPTDocumentView *documentView = self.documentViews[tag];
    if (documentView) {
        [documentView setToolMode:toolMode];
    }
}

- (int)getPageCountForDocumentViewTag:(NSNumber *)tag
{
    RNTPTDocumentView *documentView = self.documentViews[tag];
    if (documentView) {
        return documentView.documentViewController.pdfViewCtrl.pageCount;
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unable to find DocumentView for tag" userInfo:nil];
        return 0;
    }
}

- (NSString *)exportAnnotationsForDocumentViewTag:(NSNumber *)tag options:(NSDictionary *)options
{
    RNTPTDocumentView *documentView = self.documentViews[tag];
    if (documentView) {
        return [documentView exportAnnotationsWithOptions:options];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unable to find DocumentView for tag" userInfo:nil];
        return nil;
    }
}

- (void)importAnnotationsForDocumentViewTag:(NSNumber *)tag xfdf:(NSString *)xfdfString
{
    RNTPTDocumentView *documentView = self.documentViews[tag];
    if (documentView) {
        [documentView importAnnotations:xfdfString];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unable to find DocumentView for tag" userInfo:nil];
    }
}

- (void)flattenAnnotationsForDocumentViewTag:(NSNumber *)tag formsOnly:(BOOL)formsOnly
{
    RNTPTDocumentView *documentView = self.documentViews[tag];
    if (documentView) {
        [documentView flattenAnnotations:formsOnly];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unable to find DocumentView for tag" userInfo:nil];
    }
}

- (void)saveDocumentForDocumentViewTag:(NSNumber *)tag completionHandler:(void (^)(NSString * _Nullable filePath))completionHandler
{
    RNTPTDocumentView *documentView = self.documentViews[tag];
    if (documentView) {
        [documentView saveDocumentWithCompletionHandler:^(NSString * _Nullable filePath){
            if (completionHandler) {
                completionHandler(filePath);
            }
        }];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"Unable to find DocumentView for tag"
                                     userInfo:nil];
    }
}

#pragma mark - DocumentView attached/detached

- (void)documentViewAttachedToWindow:(RNTPTDocumentView *)documentView
{
    self.documentViews[documentView.reactTag] = documentView;
}

- (void)documentViewDetachedFromWindow:(RNTPTDocumentView *)documentView
{
    [self.documentViews removeObjectForKey:documentView.reactTag];
}

@end
