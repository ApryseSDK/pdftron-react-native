//
//  RNTPTDocumentView.h
//  RNPdftron
//
//  Copyright © 2018 PDFTron. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Tools/Tools.h>
#import <React/RCTComponent.h>

@class RNTPTDocumentView;

@protocol RNTPTDocumentViewDelegate <NSObject>
@optional
- (void)navButtonClicked:(RNTPTDocumentView *)sender;
@end

@interface RNTPTDocumentView : UIView

@property (readonly) PTDocumentViewController *documentController;

// viewer options
@property (nonatomic, assign) BOOL nightModeEnabled;
@property (nonatomic, assign) BOOL bottomToolbarEnabled;
@property (nonatomic, assign) BOOL pageIndicatorEnabled;
@property (nonatomic, assign) BOOL pageIndicatorShowsOnPageChange;
@property (nonatomic, assign) BOOL pageIndicatorShowsWithControls;

// button visibility
@property (nonatomic, assign) BOOL shareButtonHidden;
@property (nonatomic, assign) BOOL searchButtonHidden;
@property (nonatomic, assign) BOOL annotationToolbarButtonHidden;
@property (nonatomic, assign) BOOL thumbnailBrowserButtonHidden;
@property (nonatomic, assign) BOOL navigationListsButtonHidden;
@property (nonatomic, assign) BOOL viewerSettingsButtonHidden;

@property NSString *document;
@property BOOL showNavButton;
@property NSString *navButtonPath;

@property (nonatomic, copy) RCTBubblingEventBlock onChange;

@property (nonatomic, weak) id <RNTPTDocumentViewDelegate> delegate;

@end
