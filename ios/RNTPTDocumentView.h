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

@property (readonly) PTDocumentViewController *documentViewController;

// viewer options
@property (nonatomic, assign) BOOL nightModeEnabled;
@property (nonatomic, assign) BOOL bottomToolbarEnabled;
@property (nonatomic, assign) BOOL pageIndicatorEnabled;
@property (nonatomic, assign) BOOL pageIndicatorShowsOnPageChange;
@property (nonatomic, assign) BOOL pageIndicatorShowsWithControls;

@property NSString *document;
@property BOOL showNavButton;
@property NSString *navButtonPath;

@property (nonatomic, copy) RCTBubblingEventBlock onChange;

@property (nonatomic, weak) id <RNTPTDocumentViewDelegate> delegate;


-(void)disableElements:(NSArray<NSString*>*)disabledElements;
-(void)setToolsPermission:(NSArray<NSString*>*) stringsArray toValue:(BOOL)value;

@end
