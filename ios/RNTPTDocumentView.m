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

@interface RNTPTDocumentViewController ()

@property (nonatomic) BOOL local;
@property (nonatomic) BOOL needsDocumentLoaded;
@property (nonatomic) BOOL needsRemoteDocumentLoaded;
@property (nonatomic) BOOL documentLoaded;

@property (nonatomic) BOOL continuousAnnotationEditing;

@property (nonatomic) BOOL topToolbarEnabled;

@property (nonatomic, weak, nullable) id<RNTPTDocumentViewControllerDelegate> delegate;

@end

@implementation RNTPTDocumentViewController

@dynamic delegate;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _topToolbarEnabled = YES;
    }
    return self;
}

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

- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (!hidden && !self.topToolbarEnabled){
        return;
    }
    
    [super setControlsHidden:hidden animated:animated];
}

#pragma mark - <PTAnnotationToolbarDelegate>

- (BOOL)toolShouldGoBackToPan:(PTAnnotationToolbar *)annotationToolbar
{
    return !self.continuousAnnotationEditing;
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

- (void)outlineViewControllerDidCancel:(PTOutlineViewController *)outlineViewController
{
    [outlineViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)annotationViewControllerDidCancel:(PTAnnotationViewController *)annotationViewController
{
    [annotationViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)bookmarkViewControllerDidCancel:(PTBookmarkViewController *)bookmarkViewController
{
    [bookmarkViewController dismissViewControllerAnimated:YES completion:nil];
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
        
        _topToolbarEnabled = YES;
        _bottomToolbarEnabled = YES;
        _pageIndicatorEnabled = YES;
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
    }
}

- (void)didMoveToSuperview
{
    if (!self.superview) {
        [self unloadDocumentViewController];
    }
}

#pragma mark - DocumentViewController loading

- (void)loadDocumentViewController
{
    [self registerForDocumentViewControllerNotifications];
    [self registerForPDFViewCtrlNotifications];
    
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
    
    const BOOL translucent = self.documentViewController.hidesControlsOnTap;
    navigationController.navigationBar.translucent = translucent;
    self.documentViewController.thumbnailSliderController.toolbar.translucent = translucent;
    
    UIView *controllerView = navigationController.view;
    
    // View controller containment.
    [parentController addChildViewController:navigationController];
    
    controllerView.frame = self.bounds;
    controllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addSubview:controllerView];
    
    [navigationController didMoveToParentViewController:parentController];
    
    navigationController.navigationBarHidden = !self.topToolbarEnabled;
    
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
    [self deregisterForPDFViewCtrlNotifications];
    
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

#pragma mark Notifications

- (void)registerForDocumentViewControllerNotifications
{
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;

    [center addObserver:self
               selector:@selector(documentViewControllerDidOpenDocumentWithNotification:)
                   name:PTDocumentViewControllerDidOpenDocumentNotification
                 object:self.documentViewController];
}

- (void)registerForPDFViewCtrlNotifications
{
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    
    [center addObserver:self
               selector:@selector(pdfViewCtrlDidChangePageWithNotification:)
                   name:PTPDFViewCtrlPageDidChangeNotification
                 object:self.documentViewController.pdfViewCtrl];
    
    [center addObserver:self
               selector:@selector(toolManagerDidAddAnnotationWithNotification:)
                   name:PTToolManagerAnnotationAddedNotification
                 object:self.documentViewController.toolManager];
    
    [center addObserver:self
               selector:@selector(toolManagerDidModifyAnnotationWithNotification:)
                   name:PTToolManagerAnnotationModifiedNotification
                 object:self.documentViewController.toolManager];
    
    [center addObserver:self
               selector:@selector(toolManagerDidRemoveAnnotationWithNotification:)
                   name:PTToolManagerAnnotationRemovedNotification
                 object:self.documentViewController.toolManager];
}

- (void)deregisterForPDFViewCtrlNotifications
{
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;

    [center removeObserver:self
                      name:PTPDFViewCtrlPageDidChangeNotification
                    object:self.documentViewController.pdfViewCtrl];
    
    [center removeObserver:self
                      name:PTToolManagerAnnotationAddedNotification
                    object:self.documentViewController.toolManager];
    
    [center removeObserver:self
                      name:PTToolManagerAnnotationModifiedNotification
                    object:self.documentViewController.toolManager];
    
    [center removeObserver:self
                      name:PTToolManagerAnnotationRemovedNotification
                    object:self.documentViewController.toolManager];
}

#pragma mark - Disabling elements

-(void)disableElements:(NSArray<NSString*>*)disabledElements
{
    [self disableElementsInternal:disabledElements];
}

-(void)disableElementsInternal:(NSArray<NSString*> *)disabledElements
{
    
    typedef void (^HideElementBlock)(void);
    
    NSDictionary *hideElementActions = @{
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
        @"moreItemsButton":
            ^{
                self.documentViewController.moreItemsButtonHidden = YES;
            },

        @"thumbnailSlider":
            ^{
                self.documentViewController.thumbnailSliderHidden = YES;
            },
        
        @"outlineListButton":
            ^{
                self.documentViewController.outlineListHidden = YES;
            },
        @"annotationListButton":
            ^{
                self.documentViewController.annotationListHidden = YES;
            },
        @"userBookmarkListButton":
            ^{
                self.documentViewController.bookmarkListHidden = YES;
            },
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

- (void)setToolMode:(NSString *)toolMode
{
    if (toolMode.length == 0) {
        return;
    }
    
    Class toolClass = Nil;
    
    if( [toolMode isEqualToString:@"AnnotationEdit"] )
    {
        // multi-select not implemented
    }
    else if( [toolMode isEqualToString:@"AnnotationCreateSticky"])
    {
        toolClass = [PTStickyNoteCreate class];
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreateFreeHand"])
    {
        toolClass = [PTFreeHandCreate class];
    }
    else if ( [toolMode isEqualToString:@"TextSelect"] )
    {
        toolClass = [PTTextSelectTool class];
    }
    else if ( [toolMode isEqualToString:@"Pan"] )
    {
        toolClass = [PTPanTool class];
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreateTextHighlight"])
    {
        toolClass = [PTTextHighlightCreate class];
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreateTextUnderline"])
    {
        toolClass = [PTTextUnderlineCreate class];
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreateTextSquiggly"])
    {
        toolClass = [PTTextSquigglyCreate class];
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreateTextStrikeout"])
    {
        toolClass = [PTTextStrikeoutCreate class];
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreateFreeText"])
    {
        toolClass = [PTFreeTextCreate class];
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreateCallout"])
    {
        // not supported
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreateSignature"])
    {
        toolClass = [PTDigitalSignatureTool class];
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreateLine"])
    {
        toolClass = [PTLineCreate class];
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreateArrow"])
    {
        toolClass = [PTArrowCreate class];
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreatePolyline"])
    {
        toolClass = [PTPolylineCreate class];
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreateStamp"])
    {
        // not implemented
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreateRectangle"])
    {
        toolClass = [PTRectangleCreate class];
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreateEllipse"])
    {
        toolClass = [PTEllipseCreate class];
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreatePolygon"])
    {
        toolClass = [PTPolygonCreate class];
    }
    else if ( [toolMode isEqualToString:@"AnnotationCreatePolygonCloud"])
    {
        toolClass = [PTCloudCreate class];
    }

    if (toolClass) {
        [self.documentViewController.toolManager changeTool:toolClass];
    }
}

- (void)setPageNumber:(int)pageNumber
{
    if (_pageNumber == pageNumber) {
        // No change.
        return;
    }
    
    BOOL success = NO;
    @try {
        success = [self.documentViewController.pdfViewCtrl SetCurrentPage:pageNumber];
    } @catch (NSException *exception) {
        NSLog(@"Exception: %@, %@", exception.name, exception.reason);
        success = NO;
    }
    
    if (success) {
        _pageNumber = pageNumber;
    } else {
        NSLog(@"Failed to set current page number");
    }
}

#pragma mark - Annotation import/export

- (PTAnnot *)findAnnotWithUniqueID:(NSString *)uniqueID onPageNumber:(int)pageNumber
{
    if (uniqueID.length == 0 || pageNumber < 1) {
        return nil;
    }
    PTPDFViewCtrl *pdfViewCtrl = self.documentViewController.pdfViewCtrl;
    
    BOOL shouldUnlock = NO;
    @try {
        [pdfViewCtrl DocLockRead];
        shouldUnlock = YES;
        
        NSArray<PTAnnot *> *annots = [pdfViewCtrl GetAnnotationsOnPage:pageNumber];
        for (PTAnnot *annot in annots) {
            if (![annot IsValid]) {
                continue;
            }
            
            // Check if the annot's unique ID matches.
            NSString *annotUniqueId = nil;
            PTObj *annotUniqueIdObj = [annot GetUniqueID];
            if ([annotUniqueIdObj IsValid]) {
                annotUniqueId = [annotUniqueIdObj GetAsPDFText];
            }
            if (annotUniqueId && [annotUniqueId isEqualToString:uniqueID]) {
                return annot;
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@, %@", exception.name, exception.reason);
    }
    @finally {
        if (shouldUnlock) {
            [pdfViewCtrl DocUnlockRead];
        }
    }
    
    return nil;
}


- (NSString *)exportAnnotationsWithOptions:(NSDictionary *)options
{
    PTPDFViewCtrl *pdfViewCtrl = self.documentViewController.pdfViewCtrl;
    BOOL shouldUnlock = NO;
    @try {
        [pdfViewCtrl DocLockRead];
        shouldUnlock = YES;
        
        if (!options || !options[@"annotList"]) {
            PTFDFDoc *fdfDoc = [[pdfViewCtrl GetDoc] FDFExtract:e_ptboth];
            return [fdfDoc SaveAsXFDFToString];
        } else {
            PTVectorAnnot *annots = [[PTVectorAnnot alloc] init];
            
            NSArray *arr = options[@"annotList"];
            for (NSDictionary *annotation in arr) {
                NSString *annotationId = annotation[@"id"];
                int pageNumber = ((NSNumber *)annotation[@"pageNumber"]).intValue;
                if (annotationId.length > 0) {
                    PTAnnot *annot = [self findAnnotWithUniqueID:annotationId
                                                    onPageNumber:pageNumber];
                    if ([annot IsValid]) {
                        [annots add:annot];
                    }
                }
            }
            
            if ([annots size] > 0) {
                PTFDFDoc *fdfDoc = [[pdfViewCtrl GetDoc] FDFExtractAnnots:annots];
                return [fdfDoc SaveAsXFDFToString];
            } else {
                return nil;
            }
        }
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

#pragma mark - Flatten annotations

- (void)flattenAnnotations:(BOOL)formsOnly
{
    [self.documentViewController.toolManager changeTool:[PTPanTool class]];
    
    PTPDFViewCtrl *pdfViewCtrl = self.documentViewController.pdfViewCtrl;
    BOOL shouldUnlock = NO;
    @try {
        [pdfViewCtrl DocLock:YES];
        shouldUnlock = YES;
        
        PTPDFDoc *doc = [pdfViewCtrl GetDoc];
        
        [doc FlattenAnnotations:formsOnly];
    }
    @finally {
        if (shouldUnlock) {
            [pdfViewCtrl DocUnlock];
        }
    }
    
    [pdfViewCtrl Update:YES];
}

- (void)saveDocumentWithCompletionHandler:(void (^)(NSString * _Nullable filePath))completionHandler
{
    NSString *filePath = self.documentViewController.coordinatedDocument.fileURL.path;

    [self.documentViewController saveDocument:e_ptincremental completionHandler:^(BOOL success) {
        if (completionHandler) {
            completionHandler((success) ? filePath : nil);
        }
    }];
}

#pragma mark - Viewer options

-(void)setNightModeEnabled:(BOOL)nightModeEnabled
{
    self.documentViewController.nightModeEnabled = nightModeEnabled;
    _nightModeEnabled = nightModeEnabled;
}

-(void)setTopToolbarEnabled:(BOOL)topToolbarEnabled
{
    self.documentViewController.topToolbarEnabled = topToolbarEnabled;
    
    if (!topToolbarEnabled) {
        self.documentViewController.hidesControlsOnTap = NO;
        self.documentViewController.controlsHidden = YES;
    } else {
        self.documentViewController.hidesControlsOnTap = YES;
        self.documentViewController.controlsHidden = NO;
    }
    const BOOL translucent = self.documentViewController.hidesControlsOnTap;
    self.documentViewController.thumbnailSliderController.toolbar.translucent = translucent;
    self.documentViewController.navigationController.navigationBar.translucent = translucent;
    
    _topToolbarEnabled = topToolbarEnabled;
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

- (void)setReadOnly:(BOOL)readOnly
{
    _readOnly = readOnly;
    
    // Enable readonly flag on tool manager *only* when not already readonly.
    // If the document is being streamed or converted, we don't want to accidentally allow editing by
    // disabling the readonly flag.
    if (![self.documentViewController.toolManager isReadonly]) {
        self.documentViewController.toolManager.readonly = YES;
    }
    
    self.documentViewController.thumbnailsViewController.editingEnabled = !readOnly;
}

- (void)setFitMode:(NSString *)fitMode
{
    if ([fitMode isEqualToString:@"FitPage"]) {
        [self.documentViewController.pdfViewCtrl SetPageViewMode:e_trn_fit_page];
        [self.documentViewController.pdfViewCtrl SetPageRefViewMode:e_trn_fit_page];
    }
    else if ([fitMode isEqualToString:@"FitWidth"]) {
        [self.documentViewController.pdfViewCtrl SetPageViewMode:e_trn_fit_width];
        [self.documentViewController.pdfViewCtrl SetPageRefViewMode:e_trn_fit_width];
    }
    else if ([fitMode isEqualToString:@"FitHeight"]) {
        [self.documentViewController.pdfViewCtrl SetPageViewMode:e_trn_fit_height];
        [self.documentViewController.pdfViewCtrl SetPageRefViewMode:e_trn_fit_height];
    }
    else if ([fitMode isEqualToString:@"Zoom"]) {
        [self.documentViewController.pdfViewCtrl SetPageViewMode:e_trn_zoom];
        [self.documentViewController.pdfViewCtrl SetPageRefViewMode:e_trn_zoom];
    }
}

- (void)setLayoutMode:(NSString *)layoutMode
{
    if ([layoutMode isEqualToString:@"Single"]) {
        [self.documentViewController.pdfViewCtrl SetPagePresentationMode:e_trn_single_page];
    }
    else if ([layoutMode isEqualToString:@"Continuous"]) {
        [self.documentViewController.pdfViewCtrl SetPagePresentationMode:e_trn_single_continuous];
    }
    else if ([layoutMode isEqualToString:@"Facing"]) {
        [self.documentViewController.pdfViewCtrl SetPagePresentationMode:e_trn_facing];
    }
    else if ([layoutMode isEqualToString:@"FacingContinuous"]) {
        [self.documentViewController.pdfViewCtrl SetPagePresentationMode:e_trn_facing_continuous];
    }
    else if ([layoutMode isEqualToString:@"FacingCover"]) {
        [self.documentViewController.pdfViewCtrl SetPagePresentationMode:e_trn_facing_cover];
    }
    else if ([layoutMode isEqualToString:@"FacingCoverContinuous"]) {
        [self.documentViewController.pdfViewCtrl SetPagePresentationMode:e_trn_facing_continuous_cover];
    }
}

- (void)setContinuousAnnotationEditing:(BOOL)continuousAnnotationEditing
{
    _continuousAnnotationEditing = continuousAnnotationEditing;
    
    self.documentViewController.continuousAnnotationEditing = continuousAnnotationEditing;
}

- (void)setAnnotationAuthor:(NSString *)annotationAuthor
{
    self.documentViewController.toolManager.annotationAuthor = annotationAuthor;
}

- (void)setShowSavedSignatures:(BOOL)showSavedSignatures
{
    self.documentViewController.toolManager.showDefaultSignature = showSavedSignatures;
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
    
    if ([self isReadOnly] && ![self.documentViewController.toolManager isReadonly]) {
        self.documentViewController.toolManager.readonly = YES;
    }
    
    if ([self.delegate respondsToSelector:@selector(documentLoaded:)]) {
        [self.delegate documentLoaded:self];
    }
}

- (void)documentViewController:(PTDocumentViewController *)documentViewController didFailToOpenDocumentWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(documentError:error:)]) {
        [self.delegate documentError:self error:error.localizedFailureReason];
    }
}

#pragma mark - Notifications

- (void)documentViewControllerDidOpenDocumentWithNotification:(NSNotification *)notification
{
    if (notification.object != self.documentViewController) {
        return;
    }
    
    if ([self isReadOnly] && ![self.documentViewController.toolManager isReadonly]) {
        self.documentViewController.toolManager.readonly = YES;
    }
}

- (void)pdfViewCtrlDidChangePageWithNotification:(NSNotification *)notification
{
    if (notification.object != self.documentViewController.pdfViewCtrl) {
        return;
    }
    
    int previousPageNumber = ((NSNumber *)notification.userInfo[PTPDFViewCtrlPreviousPageNumberUserInfoKey]).intValue;
    int pageNumber = ((NSNumber *)notification.userInfo[PTPDFViewCtrlCurrentPageNumberUserInfoKey]).intValue;
    
    _pageNumber = pageNumber;
    
    // Notify delegate of change.
    if ([self.delegate respondsToSelector:@selector(pageChanged:previousPageNumber:)]) {
        [self.delegate pageChanged:self previousPageNumber:previousPageNumber];
    }
}

- (void)toolManagerDidAddAnnotationWithNotification:(NSNotification *)notification
{
    if (notification.object != self.documentViewController.toolManager) {
        return;
    }
    
    PTAnnot *annot = notification.userInfo[PTToolManagerAnnotationUserInfoKey];
    int pageNumber = ((NSNumber *)notification.userInfo[PTToolManagerPageNumberUserInfoKey]).intValue;
    
    NSString *annotId = [[annot GetUniqueID] IsValid] ? [[annot GetUniqueID] GetAsPDFText] : @"";
    if (annotId.length == 0) {
        PTPDFViewCtrl *pdfViewCtrl = self.documentViewController.pdfViewCtrl;
        BOOL shouldUnlock = NO;
        @try {
            [pdfViewCtrl DocLock:YES];
            shouldUnlock = YES;
            
            annotId = [NSUUID UUID].UUIDString;
            [annot SetUniqueID:annotId id_buf_sz:0];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@, %@", exception.name, exception.reason);
        }
        @finally {
            if (shouldUnlock) {
                [pdfViewCtrl DocUnlock];
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(annotationChanged:annotation:action:)]) {
        [self.delegate annotationChanged:self annotation:@{
            @"id": annotId,
            @"pageNumber": @(pageNumber),
        } action:@"add"];
    }
}

- (void)toolManagerDidModifyAnnotationWithNotification:(NSNotification *)notification
{
    if (notification.object != self.documentViewController.toolManager) {
        return;
    }
    
    PTAnnot *annot = notification.userInfo[PTToolManagerAnnotationUserInfoKey];
    int pageNumber = ((NSNumber *)notification.userInfo[PTToolManagerPageNumberUserInfoKey]).intValue;
    
    NSString *annotId = [[annot GetUniqueID] IsValid] ? [[annot GetUniqueID] GetAsPDFText] : @"";
    
    if ([self.delegate respondsToSelector:@selector(annotationChanged:annotation:action:)]) {
        [self.delegate annotationChanged:self annotation:@{
            @"id": annotId,
            @"pageNumber": @(pageNumber),
        } action:@"modify"];
    }
}

- (void)toolManagerDidRemoveAnnotationWithNotification:(NSNotification *)notification
{
    if (notification.object != self.documentViewController.toolManager) {
        return;
    }
    
    PTAnnot *annot = notification.userInfo[PTToolManagerAnnotationUserInfoKey];
    int pageNumber = ((NSNumber *)notification.userInfo[PTToolManagerPageNumberUserInfoKey]).intValue;
    
    NSString *annotId = [[annot GetUniqueID] IsValid] ? [[annot GetUniqueID] GetAsPDFText] : @"";
    
    if ([self.delegate respondsToSelector:@selector(annotationChanged:annotation:action:)]) {
        [self.delegate annotationChanged:self annotation:@{
            @"id": annotId,
            @"pageNumber": @(pageNumber),
        } action:@"remove"];
    }
}

@end
