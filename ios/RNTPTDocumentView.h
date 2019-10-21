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
- (void)documentViewAttachedToWindow:(RNTPTDocumentView *)documentView;
- (void)documentViewDetachedFromWindow:(RNTPTDocumentView *)documentView;

- (void)navButtonClicked:(RNTPTDocumentView *)sender;
- (void)documentLoaded:(RNTPTDocumentView *)sender;
- (void)pageChanged:(RNTPTDocumentView *)sender previousPageNumber:(int)previousPageNumber;

- (void)annotationChanged:(RNTPTDocumentView *)sender annotation:(NSDictionary *)annotation action:(NSString *)action;

@end

@interface RNTPTDocumentView : UIView

@property (nonatomic, readonly) PTDocumentViewController *documentViewController;

- (void)setToolMode:(NSString *)toolMode;

// viewer options
@property (nonatomic, assign) BOOL nightModeEnabled;
@property (nonatomic, assign) BOOL topToolbarEnabled;
@property (nonatomic, assign) BOOL bottomToolbarEnabled;
@property (nonatomic, assign) BOOL pageIndicatorEnabled;
@property (nonatomic, assign) BOOL pageIndicatorShowsOnPageChange;
@property (nonatomic, assign) BOOL pageIndicatorShowsWithControls;

@property NSString *password;
@property NSString *document;
@property (nonatomic) int initialPageNumber;
@property (nonatomic) int pageNumber;
@property BOOL showNavButton;
@property NSString *navButtonPath;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *customHeaders;
@property (nonatomic, assign, getter=isReadOnly) BOOL readOnly;

@property (nonatomic, copy) NSString *fitMode;
@property (nonatomic, copy) NSString *layoutMode;

@property (nonatomic, copy) RCTBubblingEventBlock onChange;

@property (nonatomic, weak) id <RNTPTDocumentViewDelegate> delegate;


-(void)disableElements:(NSArray<NSString*>*)disabledElements;
-(void)setToolsPermission:(NSArray<NSString*>*) stringsArray toValue:(BOOL)value;

- (NSString *)exportAnnotationsWithOptions:(NSDictionary *)options;
- (void)importAnnotations:(NSString *)xfdfString;

- (void)flattenAnnotations:(BOOL)formsOnly;

@end
