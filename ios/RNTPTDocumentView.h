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

@property (readonly) PTTabbedDocumentViewController *documentController;
@property NSString *document;
@property BOOL showNavButton;
@property NSString *navButtonPath;

@property (nonatomic, copy) RCTBubblingEventBlock onChange;

@property (nonatomic, weak) id <RNTPTDocumentViewDelegate> delegate;

@end
