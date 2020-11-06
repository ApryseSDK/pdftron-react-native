#import "RNTPTDocumentView.h"

#import "RNTPTDocumentViewController.h"
#import "RNTPTCollaborationDocumentViewController.h"
#import "RNTPTDocumentController.h"
#import "RNTPTNavigationController.h"

#include <objc/runtime.h>

static BOOL RNTPT_addMethod(Class cls, SEL selector, void (^block)(id))
{
    const IMP implementation = imp_implementationWithBlock(block);
    
    const BOOL added = class_addMethod(cls, selector, implementation, "v@:");
    if (!added) {
        imp_removeBlock(implementation);
        return NO;
    }
    
    return YES;
}

NS_ASSUME_NONNULL_BEGIN

@interface RNTPTDocumentView () <RNTPTDocumentViewControllerDelegate, RNTPTDocumentControllerDelegate, PTCollaborationServerCommunication, RNTPTNavigationControllerDelegate>

@property (nonatomic, nullable) PTDocumentBaseViewController *documentViewController;

@property (nonatomic, readonly, nullable) PTPDFViewCtrl *pdfViewCtrl;
@property (nonatomic, readonly, nullable) PTToolManager *toolManager;

@property (nonatomic, readonly, nullable) RNTPTDocumentViewController *rnt_documentViewController;

@property (nonatomic, readonly, nullable) RNTPTCollaborationDocumentViewController *rnt_collabDocumentViewController;

@property (nonatomic, readonly, nullable) RNTPTDocumentController *rnt_documentController;

@property (nonatomic, assign) BOOL needsCustomHeadersUpdate;

// Array of wrapped PTExtendedAnnotTypes.
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *hideAnnotMenuToolsAnnotTypes;

@end

NS_ASSUME_NONNULL_END

@implementation RNTPTDocumentView

- (void)RNTPTDocumentView_commonInit
{
    _hideTopAppNavBar = NO;
    _hideTopToolbars = NO;
    
    _bottomToolbarEnabled = YES;
    _hideToolbarsOnTap = YES;
    
    _pageIndicatorEnabled = YES;
    _pageIndicatorShowsOnPageChange = YES;
    _pageIndicatorShowsWithControls = YES;
    
    _autoSaveEnabled = YES;
    
    _pageChangeOnTap = NO;
    _thumbnailViewEditingEnabled = YES;
    _selectAnnotationAfterCreation = YES;

    _useStylusAsPen = YES;
    _longPressMenuEnabled = YES;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self RNTPTDocumentView_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self RNTPTDocumentView_commonInit];
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

#pragma mark - DocumentViewController

- (RNTPTDocumentViewController *)rnt_documentViewController
{
    if ([self.documentViewController isKindOfClass:[RNTPTDocumentViewController class]]) {
        return (RNTPTDocumentViewController *)self.documentViewController;
    }
    return nil;
}

- (RNTPTCollaborationDocumentViewController *)rnt_collabDocumentViewController
{
    if ([self.documentViewController isKindOfClass:[RNTPTCollaborationDocumentViewController class]]) {
        return (RNTPTCollaborationDocumentViewController *)self.documentViewController;
    }
    return nil;
}

- (RNTPTDocumentController *)rnt_documentController
{
    if ([self.documentViewController isKindOfClass:[RNTPTDocumentController class]]) {
        return (RNTPTDocumentController *)self.documentViewController;
    }
    return nil;
}

#pragma mark - Convenience

- (nullable PTPDFViewCtrl *)pdfViewCtrl
{
    return self.documentViewController.pdfViewCtrl;
}

- (nullable PTToolManager *)toolManager
{
    return self.documentViewController.toolManager;
}

#pragma mark - Document Openining

-(void)openDocument
{
    if( self.documentViewController == Nil )
    {
        return;
    }
    
    if (![self isBase64String]) {
        // Open a file URL.
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:self.document withExtension:@"pdf"];
        if ([self.document containsString:@"://"]) {
            fileURL = [NSURL URLWithString:self.document];
        } else if ([self.document hasPrefix:@"/"]) {
            fileURL = [NSURL fileURLWithPath:self.document];
        }
        
        [self.documentViewController openDocumentWithURL:fileURL
                                                password:self.password];
        
        [self applyLayoutMode];
    } else {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:self.document options:0];
        
        PTPDFDoc *doc = nil;
        @try {
            doc = [[PTPDFDoc alloc] initWithBuf:data buf_size:data.length];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception: %@, %@", exception.name, exception.reason);
            return;
        }
        
        [self.documentViewController openDocumentWithPDFDoc:doc];
        
        [self applyLayoutMode];
    }
}

-(void)setDocument:(NSString *)document
{
    _document = document;
    [self openDocument];

}

#pragma mark - DocumentViewController loading

- (void)loadDocumentViewController
{
    BOOL isNewUIEnabled = YES;
    if (!self.documentViewController) {
        if (isNewUIEnabled) {
            RNTPTDocumentController *viewController = [[RNTPTDocumentController alloc] init];
            viewController.delegate = self;
            
            self.documentViewController = viewController;
        } else {
            if ([self isCollabEnabled]) {
                RNTPTCollaborationDocumentViewController *collaborationViewController = [[RNTPTCollaborationDocumentViewController alloc] initWithCollaborationService:self];
                collaborationViewController.delegate = self;
                
                self.documentViewController = collaborationViewController;
            } else {
                RNTPTDocumentViewController *viewController = [[RNTPTDocumentViewController alloc] init];
                viewController.delegate = self;
                
                self.documentViewController = viewController;
            }
        }
        
        [PTOverrides overrideClass:[PTThumbnailsViewController class] withClass:[RNTPTThumbnailsViewController class]];
        
        self.documentViewController.navigationListsViewController.bookmarkViewController.delegate = self;
        [self applyViewerSettings];
    }
    
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
        UIBarButtonItem *navButton;
        if (navImage == nil) {
            navButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemClose target:self action:@selector(navButtonClicked)];
        }else{
            navButton = [[UIBarButtonItem alloc] initWithImage:navImage
                                                         style:UIBarButtonItemStylePlain
                                                        target:self
                                                        action:@selector(navButtonClicked)];
        }
        self.documentViewController.navigationItem.leftBarButtonItem = navButton;
    }
    
    RNTPTNavigationController *navigationController = [[RNTPTNavigationController alloc] initWithRootViewController:self.documentViewController];
    navigationController.delegate = self;
    
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
    
    navigationController.navigationBarHidden = (self.hideTopAppNavBar || self.hideTopToolbars);
    
    [self openDocument];
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

    [center removeObserver:self
                      name:PTToolManagerFormFieldDataModifiedNotification
                    object:self.documentViewController.toolManager];
}

#pragma mark - Disabling elements

- (int)getPageCount
{
    return self.documentViewController.pdfViewCtrl.pageCount;
}

- (void)setDisabledElements:(NSArray<NSString *> *)disabledElements
{
    _disabledElements = [disabledElements copy];
    
    if (self.documentViewController) {
        [self disableElementsInternal:disabledElements];
    }
}

- (void)disableElementsInternal:(NSArray<NSString*> *)disabledElements
{
    typedef void (^HideElementBlock)(void);
    
    NSDictionary *hideElementActions = @{
        PTToolsButtonKey: ^{
            if ([self.documentViewController isKindOfClass:[PTDocumentViewController class]]) {
                PTDocumentViewController *viewController = (PTDocumentViewController *)self.documentViewController;
                viewController.annotationToolbarButtonHidden = YES;
            }
        },
        PTSearchButtonKey: ^{
            self.documentViewController.searchButtonHidden = YES;
        },
        PTShareButtonKey: ^{
            self.documentViewController.shareButtonHidden = YES;
        },
        PTViewControlsButtonKey: ^{
            self.documentViewController.viewerSettingsButtonHidden = YES;
        },
        PTThumbNailsButtonKey: ^{
            self.documentViewController.thumbnailBrowserButtonHidden = YES;
        },
        PTListsButtonKey: ^{
            self.documentViewController.navigationListsButtonHidden = YES;
        },
        PTMoreItemsButtonKey: ^{
            self.documentViewController.moreItemsButtonHidden = YES;
        },
        PTThumbnailSliderButtonKey: ^{
            self.documentViewController.thumbnailSliderHidden = YES;
        },
        PTOutlineListButtonKey: ^{
            self.documentViewController.outlineListHidden = YES;
        },
        PTAnnotationListButtonKey: ^{
            self.documentViewController.annotationListHidden = YES;
        },
        PTUserBookmarkListButtonKey: ^{
            self.documentViewController.bookmarkListHidden = YES;
        },
        PTReflowButtonKey: ^{
            self.documentViewController.readerModeButtonHidden = YES;
        },
    };
    
    for (NSObject *item in disabledElements) {
        if ([item isKindOfClass:[NSString class]]) {
            HideElementBlock block = hideElementActions[item];
            if (block) {
                block();
            }
        }
    }
    
    // Disable the elements' corresponding tools/annotation types creation.
    [self setToolsPermission:disabledElements toValue:NO];
}

#pragma mark - Disabled tools

- (void)setDisabledTools:(NSArray<NSString *> *)disabledTools
{
    _disabledTools = [disabledTools copy];
    
    if (self.documentViewController) {
        [self setToolsPermission:disabledTools toValue:NO];
    }
}

- (void)setToolsPermission:(NSArray<NSString *> *)stringsArray toValue:(BOOL)value
{
    for (NSObject *item in stringsArray) {
        if ([item isKindOfClass:[NSString class]]) {
            NSString *string = (NSString *)item;
            
            if ([string isEqualToString:PTAnnotationEditToolKey]) {
                // multi-select not implemented
            }
            else if ([string isEqualToString:PTAnnotationCreateStickyToolKey] ||
                     [string isEqualToString:PTStickyToolButtonKey]) {
                self.toolManager.textAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateFreeHandToolKey] ||
                     [string isEqualToString:PTFreeHandToolButtonKey]) {
                self.toolManager.inkAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTTextSelectToolKey]) {
                self.toolManager.textSelectionEnabled = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateTextHighlightToolKey] ||
                     [string isEqualToString:PTHighlightToolButtonKey]) {
                self.toolManager.highlightAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateTextUnderlineToolKey] ||
                     [string isEqualToString:PTUnderlineToolButtonKey]) {
                self.toolManager.underlineAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateTextSquigglyToolKey] ||
                     [string isEqualToString:PTSquigglyToolButtonKey]) {
                self.toolManager.squigglyAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateTextStrikeoutToolKey] ||
                     [string isEqualToString:PTStrikeoutToolButtonKey]) {
                self.toolManager.strikeOutAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateFreeTextToolKey] ||
                     [string isEqualToString:PTFreeTextToolButtonKey]) {
                self.toolManager.freeTextAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateCalloutToolKey] ||
                     [string isEqualToString:PTCalloutToolButtonKey]) {
                self.toolManager.calloutAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateSignatureToolKey] ||
                     [string isEqualToString:PTSignatureToolButtonKey]) {
                self.toolManager.signatureAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateLineToolKey] ||
                     [string isEqualToString:PTLineToolButtonKey]) {
                self.toolManager.lineAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateArrowToolKey] ||
                     [string isEqualToString:PTArrowToolButtonKey]) {
                self.toolManager.arrowAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreatePolylineToolKey] ||
                     [string isEqualToString:PTPolylineToolButtonKey]) {
                self.toolManager.polylineAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateStampToolKey] ||
                     [string isEqualToString:PTStampToolButtonKey]) {
                self.toolManager.imageStampAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateRectangleToolKey] ||
                     [string isEqualToString:PTRectangleToolButtonKey]) {
                self.toolManager.squareAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateEllipseToolKey] ||
                     [string isEqualToString:PTEllipseToolButtonKey]) {
                self.toolManager.circleAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreatePolygonToolKey] ||
                     [string isEqualToString:PTPolygonToolButtonKey]) {
                self.toolManager.polygonAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreatePolygonCloudToolKey] ||
                     [string isEqualToString:PTCloudToolButtonKey]) {
                self.toolManager.cloudyAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateFileAttachmentToolKey]) {
                self.toolManager.fileAttachmentAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateDistanceMeasurementToolKey]) {
                self.toolManager.rulerAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreatePerimeterMeasurementToolKey]) {
                self.toolManager.perimeterAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateAreaMeasurementToolKey]) {
                self.toolManager.areaAnnotationOptions.canCreate = value;
            }
        }
    }
}

- (void)setToolMode:(NSString *)toolMode
{
    if (toolMode.length == 0) {
        return;
    }
    
    Class toolClass = Nil;
    
    if( [toolMode isEqualToString:PTAnnotationEditToolKey] )
    {
        // multi-select not implemented
    }
    else if( [toolMode isEqualToString:PTAnnotationCreateStickyToolKey])
    {
        toolClass = [PTStickyNoteCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateFreeHandToolKey])
    {
        toolClass = [PTFreeHandCreate class];
    }
    else if ( [toolMode isEqualToString:PTTextSelectToolKey] )
    {
        toolClass = [PTTextSelectTool class];
    }
    else if ( [toolMode isEqualToString:PTPanToolKey] )
    {
        toolClass = [PTPanTool class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateTextHighlightToolKey])
    {
        toolClass = [PTTextHighlightCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateTextUnderlineToolKey])
    {
        toolClass = [PTTextUnderlineCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateTextSquigglyToolKey])
    {
        toolClass = [PTTextSquigglyCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateTextStrikeoutToolKey])
    {
        toolClass = [PTTextStrikeoutCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateFreeTextToolKey])
    {
        toolClass = [PTFreeTextCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateCalloutToolKey])
    {
        toolClass = [PTCalloutCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateSignatureToolKey])
    {
        toolClass = [PTDigitalSignatureTool class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateLineToolKey])
    {
        toolClass = [PTLineCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateArrowToolKey])
    {
        toolClass = [PTArrowCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreatePolylineToolKey])
    {
        toolClass = [PTPolylineCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateStampToolKey])
    {
        toolClass = [PTImageStampCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateRectangleToolKey])
    {
        toolClass = [PTRectangleCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateEllipseToolKey])
    {
        toolClass = [PTEllipseCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreatePolygonToolKey])
    {
        toolClass = [PTPolygonCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreatePolygonCloudToolKey])
    {
        toolClass = [PTCloudCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateDistanceMeasurementToolKey]) {
        toolClass = [PTRulerCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreatePerimeterMeasurementToolKey]) {
        toolClass = [PTPerimeterCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateAreaMeasurementToolKey]) {
        toolClass = [PTAreaCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationEraserToolKey]) {
        toolClass = [PTEraser class];
    }
    
    if (toolClass) {
        PTTool *tool = [self.documentViewController.toolManager changeTool:toolClass];
        
        tool.backToPanToolAfterUse = !self.continuousAnnotationEditing;
        
        if ([tool isKindOfClass:[PTFreeHandCreate class]]
            && ![tool isKindOfClass:[PTFreeHandHighlightCreate class]]) {
            ((PTFreeHandCreate *)tool).multistrokeMode = self.continuousAnnotationEditing;
        }
    }
}

- (BOOL)commitTool
{
    if ([self.toolManager.tool respondsToSelector:@selector(commitAnnotation)]) {
        [self.toolManager.tool performSelector:@selector(commitAnnotation)];
        
        [self.toolManager changeTool:[PTPanTool class]];
        
        return YES;
    }
    
    return NO;
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

#pragma mark - Bookmark import

- (void)importBookmarkJson:(NSString *)bookmarkJson
{
    NSError *error = nil;
    [self.pdfViewCtrl DocLock:YES withBlock:^(PTPDFDoc * _Nullable doc) {
        [PTBookmarkManager.defaultManager importBookmarksForDoc:doc fromJSONString:bookmarkJson];
        [self.documentViewController.pdfViewCtrl Update:YES];
    } error:&error];
    
    if (error) {
        NSLog(@"Error: There was an error while trying to import bookmark json. %@", error.localizedDescription);
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
        
        if (!options || !options[PTAnnotListArgumentKey]) {
            PTFDFDoc *fdfDoc = [[pdfViewCtrl GetDoc] FDFExtract:e_ptboth];
            return [fdfDoc SaveAsXFDFToString];
        } else {
            PTVectorAnnot *annots = [[PTVectorAnnot alloc] init];
            
            NSArray *arr = options[PTAnnotListArgumentKey];
            for (NSDictionary *annotation in arr) {
                NSString *annotationId = annotation[PTAnnotationIdKey];
                int pageNumber = ((NSNumber *)annotation[PTAnnotationPageNumberKey]).intValue;
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
    PTPDFViewCtrl *pdfViewCtrl = self.pdfViewCtrl;

    NSError *error;
    __block BOOL hasDownloader = false;
    
    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
        hasDownloader = [[pdfViewCtrl GetDoc] HasDownloader];
    } error:&error];
    
    if (hasDownloader || error) {
        return;
    }
    
    [pdfViewCtrl DocLock:YES withBlock:^(PTPDFDoc * _Nullable doc) {
        PTFDFDoc *fdfDoc = [PTFDFDoc CreateFromXFDF:xfdfString];
        [[pdfViewCtrl GetDoc] FDFUpdate:fdfDoc];
        [pdfViewCtrl Update:YES];
    } error:&error];
    
    if (error) {
        @throw [NSException exceptionWithName:NSGenericException reason:error.localizedFailureReason userInfo:error.userInfo];
    }
}

#pragma mark - Flatten annotations

- (void)flattenAnnotations:(BOOL)formsOnly
{
    [self.toolManager changeTool:[PTPanTool class]];
    
    PTPDFViewCtrl *pdfViewCtrl = self.pdfViewCtrl;
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

- (void)deleteAnnotations:(NSArray *)annotations
{
    if (annotations.count == 0) {
        return;
    }
    
    for (id annotationData in annotations) {
        if (![annotationData isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSDictionary *dict = (NSDictionary *)annotationData;
        
        NSString *annotId = dict[PTAnnotationIdKey];
        NSNumber *pageNumber = dict[PTAnnotationPageNumberKey];
        if (!annotId || !pageNumber) {
            continue;
        }
        int pageNumberValue = pageNumber.intValue;
        
        __block PTAnnot *annot = nil;
        NSError *error = nil;
        [self.pdfViewCtrl DocLock:YES withBlock:^(PTPDFDoc * _Nullable doc) {
            
            annot = [self findAnnotWithUniqueID:annotId onPageNumber:pageNumberValue];
            if (![annot IsValid]) {
                NSLog(@"Failed to find annotation with id \"%@\" on page number %d",
                      annotId, pageNumberValue);
                annot = nil;
                return;
            }
            
            [self.toolManager willRemoveAnnotation:annot onPageNumber:pageNumberValue];

            PTPage *page = [doc GetPage:pageNumberValue];
            if ([page IsValid]) {
                [page AnnotRemoveWithAnnot:annot];
            }
            
            [self.pdfViewCtrl UpdateWithAnnot:annot page_num:pageNumberValue];
        } error:&error];
        
        // Throw error as exception to reject promise.
        if (error) {
            @throw [NSException exceptionWithName:NSGenericException reason:error.localizedFailureReason userInfo:error.userInfo];
        } else if (annot) {
            [self.toolManager annotationRemoved:annot onPageNumber:pageNumberValue];
        }
    }
    
    [self.toolManager changeTool:[PTPanTool class]];
}

#pragma mark - Saving

- (void)saveDocumentWithCompletionHandler:(void (^)(NSString * _Nullable filePath))completionHandler
{
    if (![self isBase64String]) {
        NSString *filePath = self.documentViewController.coordinatedDocument.fileURL.path;
        
        [self.documentViewController saveDocument:e_ptincremental completionHandler:^(BOOL success) {
            if (completionHandler) {
                completionHandler((success) ? filePath : nil);
            }
        }];
    } else {
        __block NSString *base64String = nil;
        __block BOOL success = NO;
        NSError *error = nil;
        [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
            NSData *data = [doc SaveToBuf:0];
            
            base64String = [data base64EncodedStringWithOptions:0];
            success = YES;
        } error:&error];
        if (completionHandler) {
            completionHandler((error == nil) ? base64String : nil);
        }
    }
}

#pragma mark - Annotation Flag

- (void)setFlagsForAnnotations:(NSArray *)annotationFlagList
{
    if (annotationFlagList.count == 0) {
        return;
    }
    
    for (id annotationFlagEntry in annotationFlagList) {
        if (![annotationFlagEntry isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSDictionary *dict = (NSDictionary *)annotationFlagEntry;
        
        NSString *annotId = dict[PTAnnotationIdKey];
        NSNumber *pageNumber = dict[PTAnnotationPageNumberKey];
        NSString *flag = dict[PTAnnotationFlagKey];
        NSNumber *flagValue = dict[PTAnnotationFlagValueKey];
        if (!annotId || !pageNumber || !flag) {
            continue;
        }
        
        int pageNumberValue = pageNumber.intValue;
        
        __block PTAnnot *annot = nil;
        NSError *error = nil;
        int annotFlag = -1;
        
        if ([flag isEqualToString:PTHiddenAnnotationFlagKey]) {
            annotFlag = e_pthidden;
        } else if ([flag isEqualToString:PTInvisibleAnnotationFlagKey]) {
            annotFlag = e_ptinvisible;
        } else if ([flag isEqualToString:PTLockedAnnotationFlagKey]) {
            annotFlag = e_ptlocked;
        } else if ([flag isEqualToString:PTLockedContentsAnnotationFlagKey]) {
            annotFlag = e_ptlocked_contents;
        } else if ([flag isEqualToString:PTNoRotateAnnotationFlagKey]) {
            annotFlag = e_ptno_rotate;
        } else if ([flag isEqualToString:PTNoViewAnnotationFlagKey]) {
            annotFlag = e_ptno_view;
        } else if ([flag isEqualToString:PTNoZoomAnnotationFlagKey]) {
            annotFlag = e_ptno_zoom;
        } else if ([flag isEqualToString:PTPrintAnnotationFlagKey]) {
            annotFlag = e_ptprint_annot;
        } else if ([flag isEqualToString:PTReadOnlyAnnotationFlagKey]) {
            annotFlag = e_ptannot_read_only;
        } else if ([flag isEqualToString:PTToggleNoViewAnnotationFlagKey]) {
            annotFlag = e_pttoggle_no_view;
        }
        if (annotFlag != -1) {
            [self.pdfViewCtrl DocLock:YES withBlock:^(PTPDFDoc * _Nullable doc) {
                
                annot = [self findAnnotWithUniqueID:annotId onPageNumber:pageNumberValue];
                if (![annot IsValid]) {
                    NSLog(@"Failed to find annotation with id \"%@\" on page number %d",
                            annotId, pageNumberValue);
                    annot = nil;
                    return;
                }
                    
                [self.toolManager willModifyAnnotation:annot onPageNumber:(int)pageNumber];
                
                [annot SetFlag:annotFlag value:[flagValue boolValue]];
                [self.pdfViewCtrl UpdateWithAnnot:annot page_num:(int)pageNumber];
                
                [self.toolManager annotationModified:annot onPageNumber:(int)pageNumber];
            } error:&error];
        }
        // Throw error as exception to reject promise.
        if (error) {
            @throw [NSException exceptionWithName:NSGenericException reason:error.localizedFailureReason userInfo:error.userInfo];
        }
    }
}


#pragma mark - Fields

- (void)setFlagForFields:(NSArray<NSString *> *)fields setFlag:(PTFieldFlag)flag toValue:(BOOL)value
{
    PTPDFViewCtrl *pdfViewCtrl = self.pdfViewCtrl;
    BOOL shouldUnlock = NO;
    @try {
        [pdfViewCtrl DocLock:YES];
        shouldUnlock = YES;
        
        PTPDFDoc *doc = [pdfViewCtrl GetDoc];
        
        for (NSString *fieldName in fields) {
            PTField *field = [doc GetField:fieldName];
            if ([field IsValid]) {
                [field SetFlag:flag value:value];
            }
        }
        
        [pdfViewCtrl Update:YES];
    }
    @finally {
        if (shouldUnlock) {
            [pdfViewCtrl DocUnlock];
        }
    }
}

- (void)setValuesForFields:(NSDictionary<NSString *, id> *)map
{
    PTPDFViewCtrl *pdfViewCtrl = self.pdfViewCtrl;
    BOOL shouldUnlock = NO;
    @try {
        [pdfViewCtrl DocLock:YES];
        shouldUnlock = YES;
        
        PTPDFDoc *doc = [pdfViewCtrl GetDoc];
        
        for (NSString *fieldName in map) {
            PTField *field = [doc GetField:fieldName];
            if ([field IsValid]) {
                id value = map[fieldName];
                [self setFieldValue:field value:value];
            }
        }
    }
    @finally {
        if (shouldUnlock) {
            [pdfViewCtrl DocUnlock];
        }
    }
}

// write-lock acquired around this method
- (void)setFieldValue:(PTField *)field value:(id)value
{
    PTPDFViewCtrl *pdfViewCtrl = self.pdfViewCtrl;
    
    const PTFieldType fieldType = [field GetType];
    
    // boolean or number
    if ([value isKindOfClass:[NSNumber class]]) {
        NSNumber *numberValue = (NSNumber *)value;
        
        if (fieldType == e_ptcheck) {
            const BOOL fieldValue = numberValue.boolValue;
            PTViewChangeCollection *changeCollection = [field SetValueWithBool:fieldValue];
            [pdfViewCtrl RefreshAndUpdate:changeCollection];
        }
        else if (fieldType == e_pttext) {
            NSString *fieldValue = numberValue.stringValue;
            
            PTViewChangeCollection *changeCollection = [field SetValueWithString:fieldValue];
            [pdfViewCtrl RefreshAndUpdate:changeCollection];
        }
    }
    // string
    else if ([value isKindOfClass:[NSString class]]) {
        NSString *fieldValue = (NSString *)value;
        
        if (fieldValue &&
            (fieldType == e_pttext || fieldType == e_ptradio || fieldType == e_ptchoice)) {
            PTViewChangeCollection *changeCollection = [field SetValueWithString:fieldValue];
            [pdfViewCtrl RefreshAndUpdate:changeCollection];
        }
    }
}

-(void)setAnnotationPermissionCheckEnabled:(BOOL)annotationPermissionCheckEnabled
{
    _annotationPermissionCheckEnabled = annotationPermissionCheckEnabled;

    [self applyViewerSettings];
}

#pragma mark - Collaboration

- (void)importAnnotationCommand:(NSString *)xfdfCommand initialLoad:(BOOL)initialLoad
{
    if (self.collaborationManager) {
        [self.collaborationManager importAnnotationsWithXFDFCommand:xfdfCommand
                                                          isInitial:initialLoad];
    } else {
        PTPDFViewCtrl *pdfViewCtrl = self.pdfViewCtrl;
        PTPDFDoc *pdfDoc = [pdfViewCtrl GetDoc];
        BOOL shouldUnlockRead = NO;
        @try {
            [pdfViewCtrl DocLockRead];
            shouldUnlockRead = YES;
            if (pdfDoc.HasDownloader) {
                return;
            }
        }
        @finally {
            if (shouldUnlockRead) {
                [pdfViewCtrl DocUnlockRead];
            }
        }

        BOOL shouldUnlock = NO;
        @try {
            [pdfViewCtrl DocLock:YES];
            shouldUnlock = YES;

            PTFDFDoc *fdfDoc = [pdfDoc FDFExtract:e_ptboth];
            [fdfDoc MergeAnnots:xfdfCommand permitted_user:@""];
            [pdfDoc FDFUpdate:fdfDoc];
            [pdfViewCtrl Update:YES];
        }
        @finally {
            if (shouldUnlock) {
                [pdfViewCtrl DocUnlock];
            }
        }
    }
}

- (void)setAnnotationToolbars:(NSArray<id> *)annotationToolbars
{
    _annotationToolbars = [annotationToolbars copy];
    
    [self applyViewerSettings];
}

- (void)setHideDefaultAnnotationToolbars:(NSArray<NSString *> *)hideDefaultAnnotationToolbars
{
    _hideDefaultAnnotationToolbars = [hideDefaultAnnotationToolbars copy];
    
    [self applyViewerSettings];
}

- (void)setHideAnnotationToolbarSwitcher:(BOOL)hideAnnotationToolbarSwitcher
{
    _hideAnnotationToolbarSwitcher = hideAnnotationToolbarSwitcher;
    
    [self applyViewerSettings];
}

- (void)setHideTopToolbars:(BOOL)hideTopToolbars
{
    _hideTopToolbars = hideTopToolbars;
    
    [self applyViewerSettings];
}

- (void)setHideTopAppNavBar:(BOOL)hideTopAppNavBar
{
    _hideTopAppNavBar = hideTopAppNavBar;
    
    [self applyViewerSettings];
}

#pragma mark - Viewer options

-(void)setNightModeEnabled:(BOOL)nightModeEnabled
{
    _nightModeEnabled = nightModeEnabled;
    
    [self applyViewerSettings];
}

#pragma mark - Top/bottom toolbar

- (BOOL)isTopToolbarEnabled
{
    return !self.hideTopAppNavBar;
}

-(void)setTopToolbarEnabled:(BOOL)topToolbarEnabled
{
    self.hideTopAppNavBar = !topToolbarEnabled;
}

-(void)setBottomToolbarEnabled:(BOOL)bottomToolbarEnabled
{
    _bottomToolbarEnabled = bottomToolbarEnabled;
    
    [self applyViewerSettings];
}

- (void)setHideToolbarsOnTap:(BOOL)hideToolbarsOnTap
{
    _hideToolbarsOnTap = hideToolbarsOnTap;
    
    [self applyViewerSettings];
}

#pragma mark - Page indicator

-(void)setPageIndicatorEnabled:(BOOL)pageIndicatorEnabled
{
    _pageIndicatorEnabled = pageIndicatorEnabled;
    
    [self applyViewerSettings];
}

-(void)setPageIndicatorShowsOnPageChange:(BOOL)pageIndicatorShowsOnPageChange
{
    _pageIndicatorShowsOnPageChange = pageIndicatorShowsOnPageChange;
    
    [self applyViewerSettings];
}

-(void)setPageIndicatorShowsWithControls:(BOOL)pageIndicatorShowsWithControls
{
    _pageIndicatorShowsWithControls = pageIndicatorShowsWithControls;
    
    [self applyViewerSettings];
}

- (void)setAutoSaveEnabled:(BOOL)autoSaveEnabled
{
    _autoSaveEnabled = autoSaveEnabled;
    
    [self applyViewerSettings];
}

- (void)setPageChangeOnTap:(BOOL)pageChangeOnTap
{
    _pageChangeOnTap = pageChangeOnTap;
    
    [self applyViewerSettings];
}

- (void)setThumbnailViewEditingEnabled:(BOOL)enabled
{
    _thumbnailViewEditingEnabled = enabled;
    
    [self applyViewerSettings];
}

- (void)setSelectAnnotationAfterCreation:(BOOL)selectAnnotationAfterCreation
{
    _selectAnnotationAfterCreation = selectAnnotationAfterCreation;
    
    [self applyViewerSettings];
}

-(void)setHideAnnotMenuTools:(NSArray<NSString *> *)hideAnnotMenuTools
{
    _hideAnnotMenuTools = hideAnnotMenuTools;
    
    NSMutableArray* hideMenuTools = [[NSMutableArray alloc] init];
    
    for (NSString* hideMenuTool in hideAnnotMenuTools) {
        PTExtendedAnnotType toolTypeToHide = [self reactAnnotationNameToAnnotType:hideMenuTool];
        [hideMenuTools addObject:@(toolTypeToHide)];
    }
    
    self.hideAnnotMenuToolsAnnotTypes = [hideMenuTools copy];
}

#pragma mark -

- (void)applyViewerSettings
{
    if (!self.documentViewController) {
        return;
    }
    
    [self applyReadonly];
    
    // Thumbnail editing enabled.
    self.documentViewController.thumbnailsViewController.editingEnabled = self.thumbnailViewEditingEnabled;
    self.documentViewController.thumbnailsViewController.navigationController.toolbarHidden = !self.thumbnailViewEditingEnabled;
    
    // Select after creation.
    self.toolManager.selectAnnotationAfterCreation = self.selectAnnotationAfterCreation;
    
    // Auto save.
    self.documentViewController.automaticallySavesDocument = self.autoSaveEnabled;
    
    // Top toolbar.
    self.documentViewController.controlsHidden = (self.hideTopAppNavBar || self.hideTopToolbars);
    
    const BOOL translucent = (self.hideTopAppNavBar || self.hideTopToolbars);
    self.documentViewController.thumbnailSliderController.toolbar.translucent = translucent;
    self.documentViewController.navigationController.navigationBar.translucent = translucent;
    
    // Bottom toolbar.
    self.documentViewController.bottomToolbarEnabled = self.bottomToolbarEnabled;
    
    self.documentViewController.hidesControlsOnTap = self.hideToolbarsOnTap;
    self.documentViewController.pageFitsBetweenBars = !self.hideToolbarsOnTap;
    
    // Page indicator.
    self.documentViewController.pageIndicatorEnabled = self.pageIndicatorEnabled;
    
    // Page change on tap.
    self.documentViewController.changesPageOnTap = self.pageChangeOnTap;
    
    // Fit mode.
    if ([self.fitMode isEqualToString:PTFitPageFitModeKey]) {
        [self.pdfViewCtrl SetPageViewMode:e_trn_fit_page];
        [self.pdfViewCtrl SetPageRefViewMode:e_trn_fit_page];
    }
    else if ([self.fitMode isEqualToString:PTFitWidthFitModeKey]) {
        [self.pdfViewCtrl SetPageViewMode:e_trn_fit_width];
        [self.pdfViewCtrl SetPageRefViewMode:e_trn_fit_width];
    }
    else if ([self.fitMode isEqualToString:PTFitHeightFitModeKey]) {
        [self.pdfViewCtrl SetPageViewMode:e_trn_fit_height];
        [self.pdfViewCtrl SetPageRefViewMode:e_trn_fit_height];
    }
    else if ([self.fitMode isEqualToString:PTZoomFitModeKey]) {
        [self.pdfViewCtrl SetPageViewMode:e_trn_zoom];
        [self.pdfViewCtrl SetPageRefViewMode:e_trn_zoom];
    }
    
    // Layout mode.
    [self applyLayoutMode];
    
    // Continuous annotation editing.
    self.toolManager.tool.backToPanToolAfterUse = !self.continuousAnnotationEditing;
    
    // Annotation author.
    self.toolManager.annotationAuthor = self.annotationAuthor;
    
    // Shows saved signatures.
    self.toolManager.showDefaultSignature = self.showSavedSignatures;
    
    self.toolManager.signatureAnnotationOptions.signSignatureFieldsWithStamps = self.signSignatureFieldsWithStamps;

    // Annotation permission check
    self.toolManager.annotationPermissionCheckEnabled = self.annotationPermissionCheckEnabled;

    // Use Apple Pencil as a pen
    Class pencilTool = [PTFreeHandCreate class];
    if (@available(iOS 13.1, *)) {
        pencilTool = [PTPencilDrawingCreate class];
    }
    self.toolManager.pencilTool = self.useStylusAsPen ? pencilTool : [PTPanTool class];

    // Disable UI elements.
    [self disableElementsInternal:self.disabledElements];
    
    // Disable tools.
    [self setToolsPermission:self.disabledTools toValue:NO];
    
    PTDocumentController *documentController = self.rnt_documentController;
    if (documentController) {
        [self applyDocumentControllerSettings:documentController];
    }
        
    // Custom HTTP request headers.
    [self applyCustomHeaders];
}

- (void)applyDocumentControllerSettings:(PTDocumentController *)documentController
{
    PTToolGroupManager *toolGroupManager = documentController.toolGroupManager;
    
    documentController.toolGroupsEnabled = !self.hideTopToolbars;
    if ([documentController areToolGroupsEnabled]) {
        NSMutableArray<PTToolGroup *> *toolGroups = [toolGroupManager.groups mutableCopy];
        
        // Handle annotationToolbars.
        if (self.annotationToolbars.count > 0) {
            // Clear default/previous tool groups.
            [toolGroups removeAllObjects];
            
            for (id annotationToolbarValue in self.annotationToolbars) {
                if ([annotationToolbarValue isKindOfClass:[NSString class]]) {
                    // Default annotation toolbar key.
                    PTDefaultAnnotationToolbarKey annotationToolbar = (NSString *)annotationToolbarValue;
                    
                    PTToolGroup *toolGroup = [self toolGroupForKey:annotationToolbar
                                                  toolGroupManager:toolGroupManager];
                    if (toolGroup) {
                        [toolGroups addObject:toolGroup];
                    }
                }
                else if ([annotationToolbarValue isKindOfClass:[NSDictionary class]]) {
                    // Custom annotation toolbar dictionary.
                    NSDictionary<NSString *, id> *annotationToolbar = (NSDictionary *)annotationToolbarValue;
                    
                    PTToolGroup *toolGroup = [self createToolGroupWithDictionary:annotationToolbar
                                                                toolGroupManager:toolGroupManager];
                    [toolGroups addObject:toolGroup];
                }
            }
        }
        
        // Handle hideDefaultAnnotationToolbars.
        if (self.hideDefaultAnnotationToolbars.count > 0) {
            NSMutableArray<PTToolGroup *> *toolGroupsToRemove = [NSMutableArray array];
            for (NSString *defaultAnnotationToolbar in self.hideDefaultAnnotationToolbars) {
                if (![defaultAnnotationToolbar isKindOfClass:[NSString class]]) {
                    continue;
                }
                PTToolGroup *matchingGroup = [self toolGroupForKey:defaultAnnotationToolbar
                                                  toolGroupManager:toolGroupManager];
                if (matchingGroup) {
                    [toolGroupsToRemove addObject:matchingGroup];
                }
            }
            // Remove the indicated tool group(s).
            if (toolGroupsToRemove.count > 0) {
                [toolGroups removeObjectsInArray:toolGroupsToRemove];
            }
        }
        
        if (![toolGroupManager.groups isEqualToArray:toolGroups]) {
            toolGroupManager.groups = toolGroups;
        }
    }
    
    if (self.hideAnnotationToolbarSwitcher) {
        documentController.navigationItem.titleView = [[UIView alloc] init];
    } else {
        if ([documentController areToolGroupsEnabled] && toolGroupManager.groups.count > 0) {
            documentController.navigationItem.titleView = documentController.toolGroupIndicatorView;
        } else {
            documentController.navigationItem.titleView = nil;
        }
    }
}

- (PTToolGroup *)toolGroupForKey:(PTDefaultAnnotationToolbarKey)key toolGroupManager:(PTToolGroupManager *)toolGroupManager
{
    NSDictionary<PTDefaultAnnotationToolbarKey, PTToolGroup *> *toolGroupMap = @{
        PTAnnotationToolbarView: toolGroupManager.viewItemGroup,
        PTAnnotationToolbarAnnotate: toolGroupManager.annotateItemGroup,
        PTAnnotationToolbarDraw: toolGroupManager.drawItemGroup,
        PTAnnotationToolbarInsert: toolGroupManager.insertItemGroup,
        //PTAnnotationToolbarFillAndSign: [NSNull null], // not implemented
        //PTAnnotationToolbarPrepareForm: [NSNull null], // not implemented
        PTAnnotationToolbarMeasure: toolGroupManager.measureItemGroup,
        PTAnnotationToolbarPens: toolGroupManager.pensItemGroup,
        PTAnnotationToolbarFavorite: toolGroupManager.favoritesItemGroup,
    };

    return toolGroupMap[key];
}

- (PTToolGroup *)createToolGroupWithDictionary:(NSDictionary<NSString *, id> *)dictionary toolGroupManager:(PTToolGroupManager *)toolGroupManager
{
    NSString *toolbarId = dictionary[PTAnnotationToolbarKeyId];
    NSString *toolbarName = dictionary[PTAnnotationToolbarKeyName];
    NSString *toolbarIcon = dictionary[PTAnnotationToolbarKeyIcon];
    NSArray<NSString *> *toolbarItems = dictionary[PTAnnotationToolbarKeyItems];
    
    UIImage *toolbarImage = nil;
    if (toolbarIcon) {
        PTToolGroup *defaultGroup = [self toolGroupForKey:toolbarIcon
                                         toolGroupManager:toolGroupManager];
        toolbarImage = defaultGroup.image;
    }
    
    NSMutableArray<UIBarButtonItem *> *barButtonItems = [NSMutableArray array];
    
    for (NSString *toolbarItem in toolbarItems) {
        if (![toolbarItem isKindOfClass:[NSString class]]) {
            continue;
        }
        
        Class toolClass = [[self class] toolClassForKey:toolbarItem];
        if (!toolClass) {
            continue;
        }
        
        UIBarButtonItem *item = [toolGroupManager createItemForToolClass:toolClass];
        if (item) {
            [barButtonItems addObject:item];
        }
    }
    
    PTToolGroup *toolGroup = [PTToolGroup groupWithTitle:toolbarName
                                                   image:toolbarImage
                                          barButtonItems:[barButtonItems copy]];
    toolGroup.identifier = toolbarId;

    return toolGroup;
}

- (void)applyLayoutMode
{
    if ([self.layoutMode isEqualToString:PTSingleLayoutModeKey]) {
        [self.pdfViewCtrl SetPagePresentationMode:e_trn_single_page];
    }
    else if ([self.layoutMode isEqualToString:PTContinuousLayoutModeKey]) {
        [self.pdfViewCtrl SetPagePresentationMode:e_trn_single_continuous];
    }
    else if ([self.layoutMode isEqualToString:PTFacingLayoutModeKey]) {
        [self.pdfViewCtrl SetPagePresentationMode:e_trn_facing];
    }
    else if ([self.layoutMode isEqualToString:PTFacingContinuousLayoutModeKey]) {
        [self.pdfViewCtrl SetPagePresentationMode:e_trn_facing_continuous];
    }
    else if ([self.layoutMode isEqualToString:PTFacingCoverLayoutModeKey]) {
        [self.pdfViewCtrl SetPagePresentationMode:e_trn_facing_cover];
    }
    else if ([self.layoutMode isEqualToString:PTFacingCoverContinuousLayoutModeKey]) {
        [self.pdfViewCtrl SetPagePresentationMode:e_trn_facing_continuous_cover];
    }
}

#pragma mark - Custom headers

- (void)setCustomHeaders:(NSDictionary<NSString *, NSString *> *)customHeaders
{
    _customHeaders = [customHeaders copy];
    
    self.needsCustomHeadersUpdate = YES;
    
    if (self.documentViewController) {
        [self applyCustomHeaders];
    }
}

- (void)applyCustomHeaders
{
    if (!self.needsCustomHeadersUpdate) {
        return;
    }
    
    self.documentViewController.additionalHTTPHeaders = self.customHeaders;
    
    self.needsCustomHeadersUpdate = NO;
}

#pragma mark - Readonly

- (void)setReadOnly:(BOOL)readOnly
{
    _readOnly = readOnly;
    
    [self applyViewerSettings];
}

- (void)applyReadonly
{
    // Enable readonly flag on tool manager *only* when not already readonly.
    // If the document is being streamed or converted, we don't want to accidentally allow editing by
    // disabling the readonly flag.
    if (![self.documentViewController.toolManager isReadonly]) {
        self.documentViewController.toolManager.readonly = self.readOnly;
    }
    
    self.documentViewController.thumbnailsViewController.editingEnabled = !self.readOnly;
}

#pragma mark - Fit mode

- (void)setFitMode:(NSString *)fitMode
{
    _fitMode = [fitMode copy];
    
    [self applyViewerSettings];
}

#pragma mark - Layout mode

- (void)setLayoutMode:(NSString *)layoutMode
{
    _layoutMode = [layoutMode copy];
    
    [self applyViewerSettings];
}

#pragma mark - Continuous annotation editing

- (void)setContinuousAnnotationEditing:(BOOL)continuousAnnotationEditing
{
    _continuousAnnotationEditing = continuousAnnotationEditing;
    
    [self applyViewerSettings];
}

#pragma mark - Annotation author

- (void)setAnnotationAuthor:(NSString *)annotationAuthor
{
    _annotationAuthor = [annotationAuthor copy];
    
    [self applyViewerSettings];
}

#pragma mark - Show saved signatures

- (void)setShowSavedSignatures:(BOOL)showSavedSignatures
{
    _showSavedSignatures = showSavedSignatures;
    
    [self applyViewerSettings];
}

#pragma mark - Stylus

- (void)setUseStylusAsPen:(BOOL)useStylusAsPen
{
    _useStylusAsPen = useStylusAsPen;

    [self applyViewerSettings];
}

#pragma mark - Actions

- (void)navButtonClicked
{
    if([self.delegate respondsToSelector:@selector(navButtonClicked:)]) {
        [self.delegate navButtonClicked:self];
    }
}

#pragma mark - signSignatureFieldsWithStamps

-(void)setSignSignatureFieldsWithStamps:(BOOL)signSignatureFieldsWithStamps
{
    _signSignatureFieldsWithStamps = signSignatureFieldsWithStamps;
    
    [self applyViewerSettings];
}

#pragma mark - Convenience

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

-(PTExtendedAnnotType)reactAnnotationNameToAnnotType:(NSString*)reactString
{
    NSDictionary<NSString *, NSNumber *>* typeMap = @{
        PTAnnotationCreateStickyToolKey : @(PTExtendedAnnotTypeText),
        PTStickyToolButtonKey : @(PTExtendedAnnotTypeText),
        PTAnnotationCreateFreeHandToolKey : @(PTExtendedAnnotTypeInk),
        PTAnnotationCreateTextHighlightToolKey : @(PTExtendedAnnotTypeHighlight),
        PTAnnotationCreateTextUnderlineToolKey : @(PTExtendedAnnotTypeUnderline),
        PTAnnotationCreateTextSquigglyToolKey : @(PTExtendedAnnotTypeSquiggly),
        PTAnnotationCreateTextStrikeoutToolKey : @(PTExtendedAnnotTypeStrikeOut),
        PTAnnotationCreateFreeTextToolKey : @(PTExtendedAnnotTypeFreeText),
        PTAnnotationCreateCalloutToolKey : @(PTExtendedAnnotTypeCallout),
        PTAnnotationCreateSignatureToolKey : @(PTExtendedAnnotTypeSignature),
        PTAnnotationCreateLineToolKey : @(PTExtendedAnnotTypeLine),
        PTAnnotationCreateArrowToolKey : @(PTExtendedAnnotTypeArrow),
        PTAnnotationCreatePolylineToolKey : @(PTExtendedAnnotTypePolyline),
        PTAnnotationCreateStampToolKey : @(PTExtendedAnnotTypeImageStamp),
        PTAnnotationCreateRectangleToolKey : @(PTExtendedAnnotTypeSquare),
        PTAnnotationCreateEllipseToolKey : @(PTExtendedAnnotTypeCircle),
        PTAnnotationCreatePolygonToolKey : @(PTExtendedAnnotTypePolygon),
        PTAnnotationCreatePolygonCloudToolKey : @(PTExtendedAnnotTypeCloudy),
        PTAnnotationCreateDistanceMeasurementToolKey : @(PTExtendedAnnotTypeRuler),
        PTAnnotationCreatePerimeterMeasurementToolKey : @(PTExtendedAnnotTypePerimeter),
        PTAnnotationCreateAreaMeasurementToolKey : @(PTExtendedAnnotTypeArea),
        PTAnnotationCreateFileAttachmentToolKey : @(PTExtendedAnnotTypeFileAttachment),
        PTAnnotationCreateSoundToolKey : @(PTExtendedAnnotTypeSound),
//        @"FormCreateTextField" : @(),
//        @"FormCreateCheckboxField" : @(),
//        @"FormCreateRadioField" : @(),
//        @"FormCreateComboBoxField" : @(),
//        @"FormCreateListBoxField" : @()
    };
    
    PTExtendedAnnotType annotType = PTExtendedAnnotTypeUnknown;
    
    if( typeMap[reactString] )
    {
        annotType = [typeMap[reactString] unsignedIntValue];
    }

    return annotType;
    
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

#pragma mark - <PTDocumentControllerDelegate>

//- (BOOL)documentController:(PTDocumentController *)documentController shouldExportCachedDocumentAtURL:(NSURL *)cachedDocumentUrl
//{
//    // Don't export the downloaded file (ie. keep using the cache file).
//    return NO;
//}

- (BOOL)documentController:(PTDocumentController *)documentController shouldDeleteCachedDocumentAtURL:(NSURL *)cachedDocumentUrl
{
    // Don't delete the cache file.
    // (This will only be called if -documentController:shouldExportCachedDocumentAtURL: returns YES)
    return NO;
}

#pragma mark - <PTToolManagerDelegate>

- (UIViewController *)viewControllerForToolManager:(PTToolManager *)toolManager
{
    return self.documentViewController;
}

- (BOOL)toolManager:(PTToolManager *)toolManager shouldHandleLinkAnnotation:(PTAnnot *)annotation orLinkInfo:(PTLinkInfo *)linkInfo onPageNumber:(unsigned long)pageNumber
{
    if (![self.overrideBehavior containsObject:PTLinkPressLinkAnnotationKey]) {
        return YES;
    }
    
    __block NSString *url = nil;
    
    NSError *error = nil;
    [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
        // Check for a valid link annotation.
        if (![annotation IsValid] ||
            annotation.extendedAnnotType != PTExtendedAnnotTypeLink) {
            return;
        }
        
        PTLink *linkAnnot = [[PTLink alloc] initWithAnn:annotation];
        
        // Check for a valid URI action.
        PTAction *action = [linkAnnot GetAction];
        if (![action IsValid] ||
            [action GetType] != e_ptURI) {
            return;
        }
        
        PTObj *actionObj = [action GetSDFObj];
        if (![actionObj IsValid]) {
            return;
        }
        
        // Get the action's URI.
        PTObj *uriObj = [actionObj FindObj:PTURILinkAnnotationKey];
        if ([uriObj IsValid] && [uriObj IsString]) {
            url = [uriObj GetAsPDFText];
        }
    } error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    if (url) {
        self.onChange(@{
            @"onBehaviorActivated": @"onBehaviorActivated",
            PTActionLinkAnnotationKey: PTLinkPressLinkAnnotationKey,
            PTDataLinkAnnotationKey: @{
                PTURLLinkAnnotationKey: url,
            },
        });
        
        // Link handled.
        return NO;
    }
    
    return YES;
}

#pragma mark - <RNTPTDocumentViewControllerDelegate>

- (void)rnt_documentViewControllerDocumentLoaded:(PTDocumentBaseViewController *)documentViewController
{
    if (self.initialPageNumber > 0) {
        [documentViewController.pdfViewCtrl SetCurrentPage:self.initialPageNumber];
    }
    
    if ([self isReadOnly] && ![self.documentViewController.toolManager isReadonly]) {
        self.documentViewController.toolManager.readonly = YES;
    }
    
    [self applyLayoutMode];
    
    if ([self.delegate respondsToSelector:@selector(documentLoaded:)]) {
        [self.delegate documentLoaded:self];
    }
}

- (void)rnt_documentViewControllerDidZoom:(PTDocumentBaseViewController *)documentViewController
{
    const double zoom = self.pdfViewCtrl.zoom * self.pdfViewCtrl.zoomScale;
    
    if ([self.delegate respondsToSelector:@selector(zoomChanged:zoom:)]) {
        [self.delegate zoomChanged:self zoom:zoom];
    }
}

- (BOOL)rnt_documentViewControllerShouldGoBackToPan:(PTDocumentViewController *)documentViewController
{
    return !self.continuousAnnotationEditing;
}

- (BOOL)rnt_documentViewControllerIsTopToolbarEnabled:(PTDocumentBaseViewController *)documentViewController
{
    return (!self.hideTopAppNavBar && !self.hideTopToolbars);
}

- (NSArray<NSDictionary<NSString *, id> *> *)annotationDataForAnnotations:(NSArray<PTAnnot *> *)annotations pageNumber:(int)pageNumber
{
    NSMutableArray<NSDictionary<NSString *, id> *> *annotationData = [NSMutableArray array];
    
    if (annotations.count > 0) {
        [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc *doc) {
            for (PTAnnot *annot in annotations) {
                if (![annot IsValid]) {
                    continue;
                }
                
                NSString *uniqueId = nil;
                
                PTObj *uniqueIdObj = [annot GetUniqueID];
                if ([uniqueIdObj IsValid] && [uniqueIdObj IsString]) {
                    uniqueId = [uniqueIdObj GetAsPDFText];
                }
                
                PTPDFRect *screenRect = [self.pdfViewCtrl GetScreenRectForAnnot:annot
                                                                       page_num:pageNumber];
                [annotationData addObject:@{
                    PTAnnotationIdKey: (uniqueId ?: @""),
                    PTAnnotationPageNumberKey: @(pageNumber),
                    PTRectKey: @{
                            PTRectX1Key: @([screenRect GetX1]),
                            PTRectY1Key: @([screenRect GetY1]),
                            PTRectX2Key: @([screenRect GetX2]),
                            PTRectY2Key: @([screenRect GetY2]),
                    },
                }];
            }
        } error:nil];
    }

    return [annotationData copy];
}

- (void)rnt_documentViewController:(PTDocumentBaseViewController *)documentViewController didSelectAnnotations:(NSArray<PTAnnot *> *)annotations onPageNumber:(int)pageNumber
{
    NSArray<NSDictionary<NSString *, id> *> *annotationData = [self annotationDataForAnnotations:annotations pageNumber:pageNumber];
    
    if ([self.delegate respondsToSelector:@selector(annotationsSelected:annotations:)]) {
        [self.delegate annotationsSelected:self annotations:annotationData];
    }
}

- (BOOL)rnt_documentViewController:(PTDocumentBaseViewController *)documentViewController filterMenuItemsForAnnotationSelectionMenu:(UIMenuController *)menuController forAnnotation:(PTAnnot *)annot
{
    __block PTExtendedAnnotType annotType = PTExtendedAnnotTypeUnknown;
    
    NSError *error = nil;
    [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc *doc) {
        if ([annot IsValid]) {
            annotType = annot.extendedAnnotType;
        }
    } error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
        
    if ([self.hideAnnotMenuToolsAnnotTypes containsObject:@(annotType)]) {
        return NO;
    }
        
    NSString *editString = ([annot GetType] == e_ptFreeText) ? PTEditTextMenuItemIdentifierKey : PTEditInkMenuItemIdentifierKey;

    // Mapping from menu item title to identifier.
    NSDictionary<NSString *, NSString *> *map = @{
        PTStyleMenuItemTitleKey: PTStyleMenuItemIdentifierKey,
        PTNoteMenuItemTitleKey: PTNoteMenuItemIdentifierKey,
        PTCopyMenuItemTitleKey: PTCopyMenuItemIdentifierKey,
        PTDeleteMenuItemTitleKey: PTDeleteMenuItemIdentifierKey,
        PTTypeMenuItemTitleKey: PTTypeMenuItemIdentifierKey,
        PTSearchMenuItemTitleKey: PTSearchMenuItemIdentifierKey,
        PTEditMenuItemTitleKey: editString,
        PTFlattenMenuItemTitleKey: PTFlattenMenuItemIdentifierKey,
        PTOpenMenuItemTitleKey: PTOpenMenuItemIdentifierKey,
        PTCalibrateMenuItemTitleKey: PTCalibrateMenuItemIdentifierKey,
    };
    // Get the localized title for each menu item.
    NSMutableDictionary<NSString *, NSString *> *localizedMap = [NSMutableDictionary dictionary];
    for (NSString *key in map) {
        NSString *localizedKey = PTLocalizedString(key, nil);
        if (!localizedKey) {
            localizedKey = key;
        }
        localizedMap[localizedKey] = map[key];
    }
    
    NSMutableArray<UIMenuItem *> *permittedItems = [NSMutableArray array];
    
    for (UIMenuItem *menuItem in menuController.menuItems) {
        NSString *menuItemId = localizedMap[menuItem.title];
        
        if (!self.annotationMenuItems) {
            [permittedItems addObject:menuItem];
        }
        else {
            if (menuItemId && [self.annotationMenuItems containsObject:menuItemId]) {
                [permittedItems addObject:menuItem];
            }
        }
        
        // Override action of of overridden annotation menu items.
        if (menuItemId && [self.overrideAnnotationMenuBehavior containsObject:menuItemId]) {
            NSString *actionName = [NSString stringWithFormat:@"overriddenPressed_%@",
                                    menuItemId];
            const SEL selector = NSSelectorFromString(actionName);
            
            RNTPT_addMethod([self class], selector, ^(id self) {
                [self overriddenAnnotationMenuItemPressed:menuItemId];
            });
            
            menuItem.action = selector;
        }
    }
    
    menuController.menuItems = [permittedItems copy];
    
    return YES;
}

- (BOOL)rnt_documentViewController:(PTDocumentBaseViewController *)documentViewController filterMenuItemsForLongPressMenu:(UIMenuController *)menuController
{
    if (!self.longPressMenuEnabled) {
        menuController.menuItems = nil;
        return NO;
    }
    // Mapping from menu item title to identifier.
    NSDictionary<NSString *, NSString *> *map = @{
        PTCopyMenuItemTitleKey: PTCopyMenuItemIdentifierKey,
        PTSearchMenuItemTitleKey: PTSearchMenuItemIdentifierKey,
        PTShareMenuItemTitleKey: PTShareMenuItemIdentifierKey,
        PTReadMenuItemTitleKey: PTReadMenuItemIdentifierKey,
    };
    NSArray<NSString *> *whitelist = @[
        PTLocalizedString(PTHighlightWhiteListKey, nil),
        PTLocalizedString(PTStrikeoutWhiteListKey, nil),
        PTLocalizedString(PTUnderlineWhiteListKey, nil),
        PTLocalizedString(PTSquigglyWhiteListKey, nil),
    ];
    // Get the localized title for each menu item.
    NSMutableDictionary<NSString *, NSString *> *localizedMap = [NSMutableDictionary dictionary];
    for (NSString *key in map) {
        NSString *localizedKey = PTLocalizedString(key, nil);
        if (!localizedKey) {
            localizedKey = key;
        }
        localizedMap[localizedKey] = map[key];
    }
    
    NSMutableArray<UIMenuItem *> *permittedItems = [NSMutableArray array];
    for (UIMenuItem *menuItem in menuController.menuItems) {
        NSString *menuItemId = localizedMap[menuItem.title];
        
        if (self.longPressMenuItems.count == 0) {
            [permittedItems addObject:menuItem];
        }
        else {
            if ([whitelist containsObject:menuItem.title]) {
                [permittedItems addObject:menuItem];
            }
            else if (menuItemId && [self.longPressMenuItems containsObject:menuItemId]) {
                [permittedItems addObject:menuItem];
            }
        }
        
        // Override action of of overridden annotation menu items.
        if (menuItemId && [self.overrideLongPressMenuBehavior containsObject:menuItemId]) {
            NSString *actionName = [NSString stringWithFormat:@"overriddenPressed_%@",
                                    menuItemId];
            const SEL selector = NSSelectorFromString(actionName);
            
            RNTPT_addMethod([self class], selector, ^(id self) {
                [self overriddenLongPressMenuItemPressed:menuItemId];
            });
            
            menuItem.action = selector;
        }
    }
    
    menuController.menuItems = [permittedItems copy];
    
    return YES;
}

- (void)overriddenAnnotationMenuItemPressed:(NSString *)menuItemId
{
    NSMutableArray<PTAnnot *> *annotations = [NSMutableArray array];
    
    if ([self.toolManager.tool isKindOfClass:[PTAnnotEditTool class]]) {
        PTAnnotEditTool *annotEdit = (PTAnnotEditTool *)self.toolManager.tool;
        if (annotEdit.selectedAnnotations.count > 0) {
            [annotations addObjectsFromArray:annotEdit.selectedAnnotations];
        }
    }
    else if (self.toolManager.tool.currentAnnotation) {
        [annotations addObject:self.toolManager.tool.currentAnnotation];
    }
    
    const int pageNumber = self.toolManager.tool.annotationPageNumber;
    
    NSArray<NSDictionary<NSString *, id> *> *annotationData = [self annotationDataForAnnotations:annotations pageNumber:pageNumber];
        
    if ([self.delegate respondsToSelector:@selector(annotationMenuPressed:annotationMenu:annotations:)]) {
        [self.delegate annotationMenuPressed:self annotationMenu:menuItemId annotations:annotationData];
    }
}

- (void)overriddenLongPressMenuItemPressed:(NSString *)menuItemId
{
    NSMutableString *selectedText = [NSMutableString string];
    
    NSError *error = nil;
    [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc *doc) {
        if (![self.pdfViewCtrl HasSelection]) {
            return;
        }
        
        const int selectionBeginPage = self.pdfViewCtrl.selectionBeginPage;
        const int selectionEndPage = self.pdfViewCtrl.selectionEndPage;
        
        for (int pageNumber = selectionBeginPage; pageNumber <= selectionEndPage; pageNumber++) {
            if ([self.pdfViewCtrl HasSelectionOnPage:pageNumber]) {
                PTSelection *selection = [self.pdfViewCtrl GetSelection:pageNumber];
                NSString *selectionText = [selection GetAsUnicode];
                
                [selectedText appendString:selectionText];
            }
        }
    } error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
    if ([self.delegate respondsToSelector:@selector(longPressMenuPressed:
                                                    longPressMenu:
                                                    longPressText:)]) {
        [self.delegate longPressMenuPressed:self
                              longPressMenu:menuItemId
                              longPressText:[selectedText copy]];
    }
}

#pragma mark - <PTDocumentViewControllerDelegate>

- (void)documentViewController:(PTDocumentViewController *)documentViewController didFailToOpenDocumentWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(documentError:error:)]) {
        [self.delegate documentError:self error:error.localizedFailureReason];
    }
}

#pragma mark - <PTDocumentControllerDelegate>

- (void)documentController:(PTDocumentController *)documentController didFailToOpenDocumentWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(documentError:error:)]) {
        [self.delegate documentError:self error:error.localizedFailureReason];
    }
}

#pragma mark - <PTCollaborationServerCommunication>

- (NSString *)documentID
{
    return self.document;
}

- (NSString *)userID
{
    return self.currentUser;
}

- (void)documentLoaded
{
    // Use rnt_documentViewControllerDocumentLoaded
}

- (void)localAnnotationAdded:(PTCollaborationAnnotation *)collaborationAnnotation
{
    [self rnt_sendExportAnnotationCommandWithAction:PTAddAnnotationActionKey
                                        xfdfCommand:collaborationAnnotation.xfdf];
}

- (void)localAnnotationModified:(PTCollaborationAnnotation *)collaborationAnnotation
{
    [self rnt_sendExportAnnotationCommandWithAction:PTModifyAnnotationActionKey
                                        xfdfCommand:collaborationAnnotation.xfdf];
}

- (void)localAnnotationRemoved:(PTCollaborationAnnotation *)collaborationAnnotation
{
    [self rnt_sendExportAnnotationCommandWithAction:PTDeleteAnnotationActionKey
                                        xfdfCommand:collaborationAnnotation.xfdf];
}

- (void)rnt_sendExportAnnotationCommandWithAction:(NSString *)action xfdfCommand:(NSString *)xfdfCommand
{
    if ([self.delegate respondsToSelector:@selector(exportAnnotationCommand:action:xfdfCommand:)]) {
        [self.delegate exportAnnotationCommand:self action:action xfdfCommand:xfdfCommand];
    }
}

#pragma mark - <RNTPTNavigationController>

- (BOOL)navigationController:(RNTPTNavigationController *)navigationController shouldSetNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated
{
    if (!navigationBarHidden) {
        return !(self.hideTopAppNavBar || self.hideTopToolbars);
    }
    return YES;
}

- (BOOL)navigationController:(RNTPTNavigationController *)navigationController shouldSetToolbarHidden:(BOOL)toolbarHidden animated:(BOOL)animated
{
    if (!toolbarHidden) {
        return self.bottomToolbarEnabled;
    }
    return YES;
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
            PTAnnotationIdKey: annotId,
            PTAnnotationPageNumberKey: @(pageNumber),
        } action:PTAddAnnotationActionKey];
    }
    if (!self.collaborationManager) {
        PTVectorAnnot *annots = [[PTVectorAnnot alloc] init];
        [annots add:annot];
        [self rnt_sendExportAnnotationCommandWithAction:PTAddAnnotationActionKey xfdfCommand:[self generateXfdfCommand:annots modified:[[PTVectorAnnot alloc] init] deleted:[[PTVectorAnnot alloc] init]]];
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
            PTAnnotationIdKey: annotId,
            PTAnnotationPageNumberKey: @(pageNumber),
        } action:PTModifyAnnotationActionKey];
    }
    if (!self.collaborationManager) {
        PTVectorAnnot *annots = [[PTVectorAnnot alloc] init];
        [annots add:annot];
        [self rnt_sendExportAnnotationCommandWithAction:PTModifyAnnotationActionKey xfdfCommand:[self generateXfdfCommand:[[PTVectorAnnot alloc] init] modified:annots deleted:[[PTVectorAnnot alloc] init]]];
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
            PTAnnotationIdKey: annotId,
            PTAnnotationPageNumberKey: @(pageNumber),
        } action:PTRemoveAnnotationActionKey];
    }
    if (!self.collaborationManager) {
        PTVectorAnnot *annots = [[PTVectorAnnot alloc] init];
        [annots add:annot];
        [self rnt_sendExportAnnotationCommandWithAction:PTDeleteAnnotationActionKey xfdfCommand:[self generateXfdfCommand:[[PTVectorAnnot alloc] init] modified:[[PTVectorAnnot alloc] init] deleted:annots]];
    }
}

- (void)toolManagerDidModifyFormFieldDataWithNotification:(NSNotification *)notification
{
    if (notification.object != self.documentViewController.toolManager) {
        return;
    }

    PTAnnot *annot = notification.userInfo[PTToolManagerAnnotationUserInfoKey];
    if ([annot GetType] == e_ptWidget) {
        PTPDFViewCtrl *pdfViewCtrl = self.documentViewController.pdfViewCtrl;
        NSError* error;

        __block PTWidget *widget;
        __block PTField *field;
        __block NSString *fieldName;
        __block NSString *fieldValue;

        [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
            widget = [[PTWidget alloc] initWithAnn:annot];
            field = [widget GetField];
            fieldName = [field IsValid] ? [field GetName] : @"";
            fieldValue = [field IsValid] ? [field GetValueAsString] : @"";
        } error:&error];
        if (error) {
            NSLog(@"An error occurred: %@", error);
            return;
        }

        if ([self.delegate respondsToSelector:@selector(formFieldValueChanged:fields:)]) {
            [self.delegate formFieldValueChanged:self fields:@{
                PTFormFieldNameKey: fieldName,
                PTFormFieldValueKey: fieldValue,
            }];
        }
        if (!self.collaborationManager) {
            PTVectorAnnot *annots = [[PTVectorAnnot alloc] init];
            [annots add:annot];
            [self rnt_sendExportAnnotationCommandWithAction:PTModifyAnnotationActionKey xfdfCommand:[self generateXfdfCommand:[[PTVectorAnnot alloc] init] modified:annots deleted:[[PTVectorAnnot alloc] init]]];
        }
    }
}

-(NSString*)generateXfdfCommand:(PTVectorAnnot*)added modified:(PTVectorAnnot*)modified deleted:(PTVectorAnnot*)deleted {
    NSString *fdfCommand = @"";
    PTPDFViewCtrl *pdfViewCtrl = self.pdfViewCtrl;
    BOOL shouldUnlockRead = NO;
    @try {
        [pdfViewCtrl DocLockRead];
        shouldUnlockRead = YES;
        PTPDFDoc *pdfDoc = [self.pdfViewCtrl GetDoc];
        PTFDFDoc *fdfDoc = [pdfDoc FDFExtractCommand:added annot_modified:modified annot_deleted:deleted];
        fdfCommand = [fdfDoc SaveAsXFDFToString];
    }
    @finally {
        if (shouldUnlockRead) {
            [pdfViewCtrl DocUnlockRead];
        }
    }
    return fdfCommand;
}

#pragma mark - PTBookmarkViewControllerDelegate

- (void)bookmarkViewController:(PTBookmarkViewController *)bookmarkViewController didModifyBookmark:(PTUserBookmark *)bookmark {
    [self bookmarksModified];
}

- (void)bookmarkViewController:(PTBookmarkViewController *)bookmarkViewController didAddBookmark:(PTUserBookmark *)bookmark {
    [self bookmarksModified];
}

- (void)bookmarkViewController:(PTBookmarkViewController *)bookmarkViewController didRemoveBookmark:(nonnull PTUserBookmark *)bookmark {
    [self bookmarksModified];
}

- (void)bookmarksModified {
    if ([self.delegate respondsToSelector:@selector(bookmarkChanged:bookmarkJson:)]) {

        __block NSString* json;
        NSError* error;
        [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
            json = [PTBookmarkManager.defaultManager exportBookmarksFromDoc:doc];
        } error:&error];
    
        if(error)
        {
            NSLog(@"Error: There was an error while trying to export the bookmark json on events triggered. %@", error.localizedDescription);
        }
        [self.delegate bookmarkChanged:self bookmarkJson:json];
    }
}

#pragma mark - Select Annotation

-(void)selectAnnotation:(NSString *)annotationId pageNumber:(NSInteger)pageNumber {
    PTAnnot *annotation = [self findAnnotWithUniqueID:annotationId onPageNumber:(int)pageNumber];
    if (annotation) {
        [self.toolManager selectAnnotation:annotation onPageNumber:(unsigned long)pageNumber];
    }
}


#pragma mark - Set Property for Annotation

- (void)setPropertiesForAnnotation:(NSString *)annotationId pageNumber:(NSInteger)pageNumber propertyMap:(NSDictionary *)propertyMap {
    
    NSError *error;
    
    [self.pdfViewCtrl DocLock:YES withBlock:^(PTPDFDoc * _Nullable doc) {
        
        PTAnnot *annot = [self findAnnotWithUniqueID:annotationId onPageNumber:(int)pageNumber];
        if (![annot IsValid]) {
            NSLog(@"Failed to find annotation with id \"%@\" on page number %d",
                  annotationId, (int)pageNumber);
            annot = nil;
            return;
        }
        
        [self.toolManager willModifyAnnotation:annot onPageNumber:(int)pageNumber];
        
        NSString* annotContents = [RNTPTDocumentView PT_idAsNSString:propertyMap[PTContentsAnnotationPropertyKey]];
        if (annotContents) {
            [annot SetContents:annotContents];
        }
        
        NSDictionary *annotRect = [RNTPTDocumentView PT_idAsNSDictionary:propertyMap[PTRectKey]];
        if (annotRect) {
            NSNumber *rectX1 = [RNTPTDocumentView PT_idAsNSNumber:annotRect[PTRectX1Key]];
            NSNumber *rectY1 = [RNTPTDocumentView PT_idAsNSNumber:annotRect[PTRectY1Key]];
            NSNumber *rectX2 = [RNTPTDocumentView PT_idAsNSNumber:annotRect[PTRectX2Key]];
            NSNumber *rectY2 = [RNTPTDocumentView PT_idAsNSNumber:annotRect[PTRectY2Key]];
            if (rectX1 && rectY1 && rectX2 && rectY2) {
                PTPDFRect *rect = [[PTPDFRect alloc] initWithX1:[rectX1 doubleValue] y1:[rectY1 doubleValue] x2:[rectX2 doubleValue] y2:[rectY2 doubleValue]];
                [annot SetRect:rect];
            }
        }
        
        if ([annot IsMarkup]) {
            PTMarkup *markupAnnot = [[PTMarkup alloc] initWithAnn:annot];
            
            NSString *annotSubject = [RNTPTDocumentView PT_idAsNSString:propertyMap[PTSubjectAnnotationPropertyKey]];
            if (annotSubject) {
                [markupAnnot SetSubject:annotSubject];
            }
            
            NSString *annotTitle = [RNTPTDocumentView PT_idAsNSString:propertyMap[PTTitleAnnotationPropertyKey]];
            if (annotTitle) {
                [markupAnnot SetTitle:annotTitle];
            }
            
            NSDictionary *annotContentRect = [RNTPTDocumentView PT_idAsNSDictionary:propertyMap[PTContentRectAnnotationPropertyKey]];
            if (annotRect) {
                NSNumber *rectX1 = [RNTPTDocumentView PT_idAsNSNumber:annotContentRect[PTRectX1Key]];
                NSNumber *rectY1 = [RNTPTDocumentView PT_idAsNSNumber:annotContentRect[PTRectY1Key]];
                NSNumber *rectX2 = [RNTPTDocumentView PT_idAsNSNumber:annotContentRect[PTRectX2Key]];
                NSNumber *rectY2 = [RNTPTDocumentView PT_idAsNSNumber:annotContentRect[PTRectY2Key]];
                if (rectX1 && rectY1 && rectX2 && rectY2) {
                    PTPDFRect *contentRect = [[PTPDFRect alloc] initWithX1:[rectX1 doubleValue] y1:[rectY1 doubleValue] x2:[rectX2 doubleValue] y2:[rectY2 doubleValue]];
                    [markupAnnot SetContentRect:contentRect];
                }
            }
        }
        
        [self.pdfViewCtrl UpdateWithAnnot:annot page_num:(int)pageNumber];
        
        [self.toolManager annotationModified:annot onPageNumber:(int)pageNumber];
    } error:&error];
    
    // Throw error as exception to reject promise.
    if (error) {
        @throw [NSException exceptionWithName:NSGenericException reason:error.localizedFailureReason userInfo:error.userInfo];
    }
}

#pragma mark - Get Crop Box

- (NSDictionary<NSString *, NSNumber *> *)getPageCropBox:(NSInteger)pageNumber {
    
    __block NSDictionary<NSString *, NSNumber *> *map;
    [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc *doc) {
        
        PTPage *page = [doc GetPage:(int)pageNumber];
        if (page) {
            PTPDFRect *rect = [page GetCropBox];
            if (rect) {
                map = @{
                    PTRectX1Key: @([rect GetX1]),
                    PTRectY1Key: @([rect GetY1]),
                    PTRectX2Key: @([rect GetX2]),
                    PTRectY2Key: @([rect GetY2]),
                    PTRectWidthKey: @([rect Width]),
                    PTRectHeightKey: @([rect Height]),
                };
            }
            
        }
    } error:nil];
    
    return map;
}

#pragma mark - Set Current Page

- (bool)setCurrentPage:(NSInteger)pageNumber {
    return [self.pdfViewCtrl SetCurrentPage:(int)pageNumber];
}

#pragma mark - Get Document Path

- (NSString *) getDocumentPath {
    if (![self isBase64String]) {
        return self.documentViewController.coordinatedDocument.fileURL.path;
    } else {
        return nil;
    }
}

#pragma mark - Helper

+ (NSString *)PT_idAsNSString:(id)value
{
    if ([value isKindOfClass:[NSString class]]) {
        return (NSString *)value;
    }
    return nil;
}

+ (NSNumber *)PT_idAsNSNumber:(id)value
{
    if ([value isKindOfClass:[NSNumber class]]) {
        return (NSNumber *)value;
    }
    return nil;
}

+ (NSDictionary *)PT_idAsNSDictionary:(id)value
{
    if ([value isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)value;
    }
    return nil;
}

+ (Class)toolClassForKey:(NSString *)key
{
    if ([key isEqualToString:PTAnnotationEditToolKey]) {
        return [PTAnnotSelectTool class];
    }
    else if ([key isEqualToString:PTAnnotationCreateStickyToolKey] ||
             [key isEqualToString:PTStickyToolButtonKey]) {
        return [PTStickyNoteCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateFreeHandToolKey] ||
             [key isEqualToString:PTFreeHandToolButtonKey]) {
        return [PTFreeHandCreate class];
    }
    else if ([key isEqualToString:PTTextSelectToolKey]) {
        return [PTTextSelectTool class];
    }
    else if ([key isEqualToString:PTAnnotationCreateTextHighlightToolKey] ||
             [key isEqualToString:PTHighlightToolButtonKey]) {
        return [PTTextHighlightCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateTextUnderlineToolKey] ||
             [key isEqualToString:PTUnderlineToolButtonKey]) {
        return [PTTextUnderlineCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateTextSquigglyToolKey] ||
             [key isEqualToString:PTSquigglyToolButtonKey]) {
        return [PTTextSquigglyCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateTextStrikeoutToolKey] ||
             [key isEqualToString:PTStrikeoutToolButtonKey]) {
        return [PTTextStrikeoutCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateFreeTextToolKey] ||
             [key isEqualToString:PTFreeTextToolButtonKey]) {
        return [PTFreeTextCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateCalloutToolKey] ||
             [key isEqualToString:PTCalloutToolButtonKey]) {
        return [PTCalloutCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateSignatureToolKey] ||
             [key isEqualToString:PTSignatureToolButtonKey]) {
        return [PTDigitalSignatureTool class];
    }
    else if ([key isEqualToString:PTAnnotationCreateLineToolKey] ||
             [key isEqualToString:PTLineToolButtonKey]) {
        return [PTLineCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateArrowToolKey] ||
             [key isEqualToString:PTArrowToolButtonKey]) {
        return [PTArrowCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreatePolylineToolKey] ||
             [key isEqualToString:PTPolylineToolButtonKey]) {
        return [PTPolylineCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateStampToolKey] ||
             [key isEqualToString:PTStampToolButtonKey]) {
        return [PTImageStampCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateRectangleToolKey] ||
             [key isEqualToString:PTRectangleToolButtonKey]) {
        return [PTRectangleCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateEllipseToolKey] ||
             [key isEqualToString:PTEllipseToolButtonKey]) {
        return [PTEllipseCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreatePolygonToolKey] ||
             [key isEqualToString:PTPolygonToolButtonKey]) {
        return [PTPolygonCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreatePolygonCloudToolKey] ||
             [key isEqualToString:PTCloudToolButtonKey]) {
        return [PTCloudCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateFileAttachmentToolKey]) {
        return [PTFileAttachmentCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateDistanceMeasurementToolKey]) {
        return [PTRulerCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreatePerimeterMeasurementToolKey]) {
        return [PTPerimeterCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateAreaMeasurementToolKey]) {
        return [PTAreaCreate class];
    }
    
    return Nil;
}

@end

#pragma mark - RNTPTThumbnailsViewController

@implementation RNTPTThumbnailsViewController

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = !self.editingEnabled;
}
@end
