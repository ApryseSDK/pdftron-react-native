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

#pragma mark - Button Visbility

RCT_CUSTOM_VIEW_PROPERTY(shareButtonHidden, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.shareButtonHidden = [RCTConvert BOOL:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(searchButtonHidden, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.searchButtonHidden = [RCTConvert BOOL:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(annotationToolbarButtonHidden, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.annotationToolbarButtonHidden = [RCTConvert BOOL:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(thumbnailBrowserButtonHidden, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.thumbnailBrowserButtonHidden = [RCTConvert BOOL:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(navigationListsButtonHidden, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.navigationListsButtonHidden = [RCTConvert BOOL:json];
    }
}

RCT_CUSTOM_VIEW_PROPERTY(viewerSettingsButtonHidden, BOOL, RNTPTDocumentView)
{
    if (json) {
        view.viewerSettingsButtonHidden = [RCTConvert BOOL:json];
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
