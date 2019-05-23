//
//  RNTPTDocumentViewManager.m
//  RNPdftron
//
//  Copyright © 2018 PDFTron. All rights reserved.
//

#import "RNTPTDocumentViewManager.h"

@implementation RNTPTDocumentViewManager

RCT_EXPORT_MODULE()

RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)

RCT_CUSTOM_VIEW_PROPERTY(document, NSString, RNTPTDocumentView)
{
    if (json && [RCTConvert NSString:json]) {
        view.document = [RCTConvert NSString:json];
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
RCT_CUSTOM_VIEW_PROPERTY(nightModeEnabled, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.nightModeEnabled = [RCTConvert BOOL:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(bottomToolbarEnabled, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.bottomToolbarEnabled = [RCTConvert BOOL:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(pageIndicatorShowsOnPageChange, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.pageIndicatorShowsOnPageChange = [RCTConvert BOOL:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(pageIndicatorShowsWithControls, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.pageIndicatorShowsWithControls = [RCTConvert BOOL:json];
    }
}


- (UIView *)view
{
    RNTPTDocumentView *documentView = [[RNTPTDocumentView alloc] init];
    documentView.delegate = self;
    return documentView;
}

- (void) navButtonClicked: (RNTPTDocumentView *) sender
{
    if (sender.onChange) {
        sender.onChange(@{@"onLeadingNavButtonPressed": @(true)});
    }
}

@end
