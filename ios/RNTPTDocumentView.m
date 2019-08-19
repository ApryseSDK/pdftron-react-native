//
//  RNTPTDocumentView.m
//  RNPdftron
//
//  Copyright © 2018 PDFTron. All rights reserved.
//

#import "RNTPTDocumentView.h"

@class RNTPTDocumentViewController;

@protocol RNTPTDocumentViewControllerDelegate <PTDocumentViewControllerDelegate>
@optional

- (void)rnt_documentViewControllerDocumentLoaded:(RNTPTDocumentViewController *)documentViewController;

@end

@interface RNTPTDocumentViewController : PTDocumentViewController

@property (nonatomic) BOOL local;

@property (nonatomic) BOOL needsDocumentLoaded;
@property (nonatomic) BOOL needsRemoteDocumentLoaded;
@property (nonatomic) BOOL documentLoaded;

@property (nonatomic, weak, nullable) id<RNTPTDocumentViewControllerDelegate> delegate;

@end

@implementation RNTPTDocumentViewController

@dynamic delegate;

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    if (self.needsDocumentLoaded) {
        self.needsDocumentLoaded = NO;
        self.needsRemoteDocumentLoaded = NO;
        self.documentLoaded = YES;
        
        if ([self.delegate respondsToSelector:@selector(rnt_documentViewControllerDocumentLoaded:)]) {
            [self.delegate rnt_documentViewControllerDocumentLoaded:self];
        }
    }
}

- (void)openDocumentWithURL:(NSURL *)url password:(NSString *)password
{
    if ([url isFileURL]) {
        self.local = YES;
    } else {
        self.local = NO;
    }
    self.documentLoaded = NO;
    self.needsDocumentLoaded = NO;
    self.needsRemoteDocumentLoaded = NO;
    
    [super openDocumentWithURL:url password:password];
}

#pragma mark - <PTPDFViewCtrlDelegate>

- (void)pdfViewCtrl:(PTPDFViewCtrl *)pdfViewCtrl onSetDoc:(PTPDFDoc *)doc
{
    [super pdfViewCtrl:pdfViewCtrl onSetDoc:doc];
    
    if (self.local && !self.documentLoaded) {
        self.needsDocumentLoaded = YES;
    }
    else if (!self.local && !self.documentLoaded && self.needsRemoteDocumentLoaded) {
        self.needsDocumentLoaded = YES;
    }
}

- (void)pdfViewCtrl:(PTPDFViewCtrl *)pdfViewCtrl downloadEventType:(PTDownloadedType)type pageNumber:(int)pageNum
{
    if (type == e_ptdownloadedtype_finished && !self.documentLoaded) {
        self.needsRemoteDocumentLoaded = YES;
    }
    
    [super pdfViewCtrl:pdfViewCtrl downloadEventType:type pageNumber:pageNum];
}

@end

@interface RNTPTDocumentView () <RNTPTDocumentViewControllerDelegate>

@end

@implementation RNTPTDocumentView
@synthesize delegate;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _documentViewController = [[RNTPTDocumentViewController alloc] init];
        _documentViewController.delegate = self;
    }
    return self;
}

#pragma mark - View lifecycle

- (void)didMoveToWindow
{
    if (self.window) {
        if ([self.delegate respondsToSelector:@selector(documentViewAttachedToWindow:)]) {
            [self.delegate documentViewAttachedToWindow:self];
        }
        
        [self loadDocumentViewController];
    } else {
        if ([self.delegate respondsToSelector:@selector(documentViewDetachedFromWindow:)]) {
            [self.delegate documentViewDetachedFromWindow:self];
        }

        [self unloadDocumentViewController];
    }
}

#pragma mark - DocumentViewController loading

- (void)loadDocumentViewController
{
    // Check if document view controller has already been added to a navigation controller.
    if (self.documentViewController.navigationController) {
        return;
    }
    
    // Find the view's containing UIViewController.
    UIViewController *parentController = [self findParentViewController];
    if (parentController == nil || self.window == nil) {
        return;
    }
    
    if (self.showNavButton) {
        UIImage *navImage = [UIImage imageNamed:self.navButtonPath];
        UIBarButtonItem *navButton = [[UIBarButtonItem alloc] initWithImage:navImage
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(navButtonClicked)];
        self.documentViewController.navigationItem.leftBarButtonItem = navButton;
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.documentViewController];
    
    UIView *controllerView = navigationController.view;
    
    [parentController addChildViewController:navigationController];
    [self addSubview:controllerView];
    
    controllerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:
     @[[controllerView.topAnchor constraintEqualToAnchor:self.topAnchor],
       [controllerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
       [controllerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
       [controllerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
       ]];
    
    [navigationController didMoveToParentViewController:parentController];
    
    // Open a file URL.
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:self.document withExtension:@"pdf"];
    if ([self.document containsString:@"://"]) {
        fileURL = [NSURL URLWithString:self.document];
    } else if ([self.document hasPrefix:@"/"]) {
        fileURL = [NSURL fileURLWithPath:self.document];
    }
    
    [self.documentViewController openDocumentWithURL:fileURL password:self.password];
}

- (void)unloadDocumentViewController
{
    UINavigationController *navigationController = self.documentViewController.navigationController;
    if (navigationController) {
        // Clear navigation stack (PTDocumentViewController).
        navigationController.viewControllers = @[];

        // Remove from parent view controller.
        [navigationController willMoveToParentViewController:nil];
        [navigationController.view removeFromSuperview];
        [navigationController removeFromParentViewController];
    }
}

-(void)disableElements:(NSArray<NSString*>*)disabledElements
{
    [self disableElementsInternal:disabledElements];
}

-(void)disableElementsInternal:(NSArray<NSString*> *)disabledElements
{
    
    typedef void (^HideElementBlock)(void);
    
    NSDictionary *hideElementActions =
    @{
      @"toolsButton":
          ^{
              self.documentViewController.annotationToolbarButtonHidden = YES;
          },
      @"searchButton":
          ^{
              self.documentViewController.searchButtonHidden = YES;
          },
      @"shareButton":
          ^{
              self.documentViewController.shareButtonHidden = YES;
          },
      @"viewControlsButton":
          ^{
              self.documentViewController.viewerSettingsButtonHidden = YES;
          },
      @"thumbnailsButton":
          ^{
              self.documentViewController.thumbnailBrowserButtonHidden = YES;
          },
      @"listsButton":
          ^{
              self.documentViewController.navigationListsButtonHidden = YES;
          },
      @"thumbnailSlider":
          ^{
              self.documentViewController.thumbnailSliderHidden = YES;
          }
      };
    
    
    for(NSObject* item in disabledElements)
    {
        if( [item isKindOfClass:[NSString class]])
        {
            HideElementBlock block = hideElementActions[item];
            if (block)
            {
                block();
            }
        }
    }
    
    [self setToolsPermission:disabledElements toValue:NO];
    
}

-(void)setToolsPermission:(NSArray<NSString*>*) stringsArray toValue:(BOOL)value
{
    // TODO: AnnotationCreateDistanceMeasurement
    // AnnotationCreatePerimeterMeasurement
    // AnnotationCreateAreaMeasurement
    
    
    for(NSObject* item in stringsArray)
    {
        if( [item isKindOfClass:[NSString class]])
        {
            NSString* string = (NSString*)item;
            
            if( [string isEqualToString:@"AnnotationEdit"] )
            {
                // multi-select not implemented
            }
            else if( [string isEqualToString:@"AnnotationCreateSticky"] || [string isEqualToString:@"stickyToolButton"] )
            {
                self.documentViewController.toolManager.textAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreateFreeHand"] || [string isEqualToString:@"freeHandToolButton"] )
            {
                self.documentViewController.toolManager.inkAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"TextSelect"] )
            {
                self.documentViewController.toolManager.textSelectionEnabled = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreateTextHighlight"] || [string isEqualToString:@"highlightToolButton"] )
            {
                self.documentViewController.toolManager.highlightAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreateTextUnderline"] || [string isEqualToString:@"underlineToolButton"] )
            {
                self.documentViewController.toolManager.underlineAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreateTextSquiggly"] || [string isEqualToString:@"squigglyToolButton"] )
            {
                self.documentViewController.toolManager.squigglyAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreateTextStrikeout"] || [string isEqualToString:@"strikeoutToolButton"] )
            {
                self.documentViewController.toolManager.strikeOutAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreateFreeText"] || [string isEqualToString:@"freeTextToolButton"] )
            {
                self.documentViewController.toolManager.freeTextAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreateCallout"] || [string isEqualToString:@"calloutToolButton"] )
            {
                // not supported
            }
            else if ( [string isEqualToString:@"AnnotationCreateSignature"] || [string isEqualToString:@"signatureToolButton"] )
            {
                self.documentViewController.toolManager.signatureAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreateLine"] || [string isEqualToString:@"lineToolButton"] )
            {
                self.documentViewController.toolManager.lineAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreateArrow"] || [string isEqualToString:@"arrowToolButton"] )
            {
                self.documentViewController.toolManager.arrowAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreatePolyline"] || [string isEqualToString:@"polylineToolButton"] )
            {
                self.documentViewController.toolManager.polylineAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreateStamp"] || [string isEqualToString:@"stampToolButton"] )
            {
                self.documentViewController.toolManager.stampAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreateRectangle"] || [string isEqualToString:@"rectangleToolButton"] )
            {
                self.documentViewController.toolManager.squareAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreateEllipse"] || [string isEqualToString:@"ellipseToolButton"] )
            {
                self.documentViewController.toolManager.circleAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreatePolygon"] || [string isEqualToString:@"polygonToolButton"] )
            {
                self.documentViewController.toolManager.polygonAnnotationOptions.canCreate = value;
            }
            else if ( [string isEqualToString:@"AnnotationCreatePolygonCloud"] || [string isEqualToString:@"cloudToolButton"] )
            {
                self.documentViewController.toolManager.cloudyAnnotationOptions.canCreate = value;
            }
            
        }
    }
}

-(void)enableTools:(NSArray<NSString*>*)enabledTools
{
    [self setToolsPermission:enabledTools toValue:YES];
}

-(void)disableTools:(NSArray<NSString*>*)disabledTools
{
    [self setToolsPermission:disabledTools toValue:NO];
}

#pragma mark - Annotation import/export

- (NSString *)exportAnnotations
{
    PTPDFViewCtrl *pdfViewCtrl = self.documentViewController.pdfViewCtrl;
    BOOL shouldUnlock = NO;
    @try {
        [pdfViewCtrl DocLockRead];
        shouldUnlock = YES;
        
        PTFDFDoc *fdfDoc = [[pdfViewCtrl GetDoc] FDFExtract:e_ptboth];
        return [fdfDoc SaveAsXFDFToString];
    }
    @finally {
        if (shouldUnlock) {
            [pdfViewCtrl DocUnlockRead];
        }
    }
    
    return nil;
}

- (void)importAnnotations:(NSString *)xfdfString
{
    PTPDFViewCtrl *pdfViewCtrl = self.documentViewController.pdfViewCtrl;
    BOOL shouldUnlock = NO;
    @try {
        [pdfViewCtrl DocLockRead];
        shouldUnlock = YES;
        
        PTFDFDoc *fdfDoc = [PTFDFDoc CreateFromXFDF:xfdfString];
        
        [[pdfViewCtrl GetDoc] FDFUpdate:fdfDoc];
        [pdfViewCtrl Update:YES];
    }
    @finally {
        if (shouldUnlock) {
            [pdfViewCtrl DocUnlockRead];
        }
    }
}

#pragma mark - Viewer options

-(void)setNightModeEnabled:(BOOL)nightModeEnabled
{
    self.documentViewController.nightModeEnabled = nightModeEnabled;
    _nightModeEnabled = nightModeEnabled;
}

-(void)setBottomToolbarEnabled:(BOOL)bottomToolbarEnabled
{
    self.documentViewController.bottomToolbarEnabled = bottomToolbarEnabled;
    _bottomToolbarEnabled = bottomToolbarEnabled;
}

-(void)setPageIndicatorEnabled:(BOOL)pageIndicatorEnabled
{
    self.documentViewController.pageIndicatorEnabled = pageIndicatorEnabled;
    _pageIndicatorEnabled = pageIndicatorEnabled;
}

-(void)setPageIndicatorShowsOnPageChange:(BOOL)pageIndicatorShowsOnPageChange
{
    self.documentViewController.pageIndicatorShowsOnPageChange = pageIndicatorShowsOnPageChange;
    _pageIndicatorShowsOnPageChange = pageIndicatorShowsOnPageChange;
}

-(void)setPageIndicatorShowsWithControls:(BOOL)pageIndicatorShowsWithControls
{
    self.documentViewController.pageIndicatorShowsWithControls = pageIndicatorShowsWithControls;
    _pageIndicatorShowsWithControls = pageIndicatorShowsWithControls;
}

- (void)setCustomHeaders:(NSDictionary<NSString *,NSString *> *)customHeaders
{
    PTHTTPRequestOptions *options = self.documentViewController.httpRequestOptions;
    [customHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
        [options AddHeader:key val:value];
    }];
    _customHeaders = customHeaders;
}


- (void)navButtonClicked
{
    if([self.delegate respondsToSelector:@selector(navButtonClicked:)]) {
        [self.delegate navButtonClicked:self];
    }
}

- (UIViewController *)findParentViewController
{
    UIResponder *parentResponder = self;
    while ((parentResponder = parentResponder.nextResponder)) {
        if ([parentResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)parentResponder;
        }
    }
    return nil;
}

#pragma mark - <PTDocumentViewControllerDelegate>

//- (BOOL)documentViewController:(PTDocumentViewController *)documentViewController shouldExportCachedDocumentAtURL:(NSURL *)cachedDocumentUrl
//{
//    // Don't export the downloaded file (ie. keep using the cache file).
//    return NO;
//}

- (BOOL)documentViewController:(PTDocumentViewController *)documentViewController shouldDeleteCachedDocumentAtURL:(NSURL *)cachedDocumentUrl
{
    // Don't delete the cache file.
    // (This will only be called if -documentViewController:shouldExportCachedDocumentAtURL: returns YES)
    return NO;
}

#pragma mark - <RNTPTDocumentViewControllerDelegate>

- (void)rnt_documentViewControllerDocumentLoaded:(RNTPTDocumentViewController *)documentViewController
{
    if (self.initialPageNumber > 0) {
        [documentViewController.pdfViewCtrl SetCurrentPage:self.initialPageNumber];
    }
    
    if ([self.delegate respondsToSelector:@selector(documentLoaded:)]) {
        [self.delegate documentLoaded:self];
    }
}

@end
