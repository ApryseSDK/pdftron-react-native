#import "RNTPTDocumentView.h"

#import "RNTPTDocumentViewController.h"
#import "RNTPTCollaborationDocumentController.h"
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

@interface RNTPTDocumentView () <PTTabbedDocumentViewControllerDelegate, RNTPTDocumentViewControllerDelegate, RNTPTDocumentControllerDelegate, PTCollaborationServerCommunication, RNTPTNavigationControllerDelegate>

@property (nonatomic, strong, nullable) UIViewController *viewController;

@property (nonatomic, strong, nullable) PTTabbedDocumentViewController *tabbedDocumentViewController;

@property (nonatomic, nullable) PTDocumentBaseViewController *documentViewController;

@property (nonatomic, readonly, nullable) PTDocumentBaseViewController *currentDocumentViewController;

@property (nonatomic, strong, nullable) UIBarButtonItem *leadingNavButtonItem;

// Array of wrapped PTExtendedAnnotTypes.
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *hideAnnotMenuToolsAnnotTypes;

@end

NS_ASSUME_NONNULL_END

@implementation RNTPTDocumentView

- (void)RNTPTDocumentView_commonInit
{
    _multiTabEnabled = NO;
    
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
    
    _maxTabCount = NSUIntegerMax;
    
    [PTOverrides overrideClass:[PTThumbnailsViewController class]
                     withClass:[RNTPTThumbnailsViewController class]];
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
        
        [self loadViewController];
    } else {
        if ([self.delegate respondsToSelector:@selector(documentViewDetachedFromWindow:)]) {
            [self.delegate documentViewDetachedFromWindow:self];
        }
    }
}

- (void)didMoveToSuperview
{
    if (!self.superview) {
        [self unloadViewController];
    }
}

#pragma mark - Document Openining

- (void)openDocument
{
    if (!self.documentViewController && !self.tabbedDocumentViewController) {
        return;
    }
    
    if (![self isBase64String]) {
        // Open a file URL.
        NSURL *fileURL = [RNTPTDocumentView PT_getFileURL:self.document];
        
        if (self.documentViewController) {
            [self.documentViewController openDocumentWithURL:fileURL
                                                    password:self.password];
            
            [self applyLayoutMode:self.documentViewController.pdfViewCtrl];
        } else {
            [self.tabbedDocumentViewController openDocumentWithURL:fileURL
                                                          password:self.password];
        }
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
        
        [self applyLayoutMode:self.documentViewController.pdfViewCtrl];
    }
}

- (void)setDocument:(NSString *)document
{
    _document = [document copy];
    
    [self openDocument];
}

#pragma mark - DocumentViewController loading

- (void)loadViewController
{
    if (!self.documentViewController && !self.tabbedDocumentViewController) {
        if ([self isCollabEnabled]) {
            RNTPTCollaborationDocumentController *collaborationViewController = [[RNTPTCollaborationDocumentController alloc] initWithCollaborationService:self];
            collaborationViewController.delegate = self;
            
            self.viewController = collaborationViewController;
            self.documentViewController = collaborationViewController;
        } else {
            if ([self isMultiTabEnabled]) {
                PTTabbedDocumentViewController *tabbedDocumentViewController = [[PTTabbedDocumentViewController alloc] init];
                tabbedDocumentViewController.maximumTabCount = self.maxTabCount;
                tabbedDocumentViewController.delegate = self;
                
                // Use the RNTPTDocumentController class inside the tabbed viewer.
                tabbedDocumentViewController.viewControllerClass = [RNTPTDocumentController class];
                
                self.viewController = tabbedDocumentViewController;
                self.tabbedDocumentViewController = tabbedDocumentViewController;
            } else {
                RNTPTDocumentController *documentViewController = [[RNTPTDocumentController alloc] init];
                documentViewController.delegate = self;
                
                self.viewController = documentViewController;
                self.documentViewController = documentViewController;
            }
        }
        
        if (self.documentViewController) {
            [self applyViewerSettings:self.documentViewController];
            
            [self registerForDocumentViewControllerNotifications:self.documentViewController];
            [self registerForPDFViewCtrlNotifications:self.documentViewController];
        } else {
            // Using tabbed viewer.
        }
    }
    
    // Check if document view controller has already been added to a navigation controller.
    if (self.viewController.navigationController) {
        return;
    }
    
    // Find the view's containing UIViewController.
    UIViewController *parentController = [self findParentViewController];
    if (parentController == nil || self.window == nil) {
        return;
    }
    
    [self applyLeadingNavButton];
    
    if (self.tabbedDocumentViewController) {
        [self.tabbedDocumentViewController.tabManager restoreItems];
    }
    
    RNTPTNavigationController *navigationController = [[RNTPTNavigationController alloc] initWithRootViewController:self.viewController];
    navigationController.delegate = self;
        
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

- (PTDocumentBaseViewController *)currentDocumentViewController
{
    if (self.documentViewController) {
        return self.documentViewController;
    } else if (self.tabbedDocumentViewController) {
        return self.tabbedDocumentViewController.selectedViewController;
    }
    return nil;
}

- (void)unloadViewController
{
    if (!self.viewController) {
        return;
    }
    
    if (self.documentViewController) {
        [self deregisterForPDFViewCtrlNotifications:self.documentViewController];
    }
    
    if (self.tabbedDocumentViewController) {
        [self.tabbedDocumentViewController.tabManager saveItems];
    }
    
    UINavigationController *navigationController = self.viewController.navigationController;
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

- (void)registerForDocumentViewControllerNotifications:(PTDocumentBaseViewController *)documentViewController
{
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    
    [center addObserver:self
               selector:@selector(documentViewControllerDidOpenDocumentWithNotification:)
                   name:PTDocumentViewControllerDidOpenDocumentNotification
                 object:documentViewController];
}

- (void)registerForPDFViewCtrlNotifications:(PTDocumentBaseViewController *)documentViewController
{
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    PTToolManager *toolManager = documentViewController.toolManager;
    
    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    
    [center addObserver:self
               selector:@selector(pdfViewCtrlDidChangePageWithNotification:)
                   name:PTPDFViewCtrlPageDidChangeNotification
                 object:pdfViewCtrl];
    
    [center addObserver:self
               selector:@selector(toolManagerDidAddAnnotationWithNotification:)
                   name:PTToolManagerAnnotationAddedNotification
                 object:toolManager];
    
    [center addObserver:self
               selector:@selector(toolManagerDidModifyAnnotationWithNotification:)
                   name:PTToolManagerAnnotationModifiedNotification
                 object:toolManager];
    
    [center addObserver:self
               selector:@selector(toolManagerDidRemoveAnnotationWithNotification:)
                   name:PTToolManagerAnnotationRemovedNotification
                 object:toolManager];
    
    [center addObserver:self
               selector:@selector(toolManagerDidModifyFormFieldDataWithNotification:) name:PTToolManagerFormFieldDataModifiedNotification
                 object:toolManager];
    
    [center addObserver:self
               selector:@selector(toolManagerDidChangeToolWithModification:)
                   name:PTToolManagerToolDidChangeNotification
                 object:toolManager];
}

- (void)deregisterForPDFViewCtrlNotifications:(PTDocumentBaseViewController *)documentViewController
{
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    PTToolManager *toolManager = documentViewController.toolManager;

    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
    
    [center removeObserver:self
                      name:PTPDFViewCtrlPageDidChangeNotification
                    object:pdfViewCtrl];
    
    [center removeObserver:self
                      name:PTToolManagerAnnotationAddedNotification
                    object:toolManager];
    
    [center removeObserver:self
                      name:PTToolManagerAnnotationModifiedNotification
                    object:toolManager];
    
    [center removeObserver:self
                      name:PTToolManagerAnnotationRemovedNotification
                    object:toolManager];

    [center removeObserver:self
                      name:PTToolManagerFormFieldDataModifiedNotification
                    object:toolManager];
    
    [center removeObserver:self
                      name:PTToolManagerToolDidChangeNotification
                    object:toolManager];
}

#pragma mark - Disabling elements

- (int)getPageCount
{
    return self.currentDocumentViewController.pdfViewCtrl.pageCount;
}

- (void)setDisabledElements:(NSArray<NSString *> *)disabledElements
{
    _disabledElements = [disabledElements copy];
    
    if (self.currentDocumentViewController) {
        [self disableElementsInternal:disabledElements documentViewController:self.currentDocumentViewController];
    }
}

- (void)disableElementsInternal:(NSArray<NSString*> *)disabledElements documentViewController:(PTDocumentBaseViewController *)documentViewController
{
    typedef void (^HideElementBlock)(void);
    
    NSDictionary *hideElementActions = @{
        PTToolsButtonKey: ^{
            if ([documentViewController isKindOfClass:[PTDocumentViewController class]]) {
                PTDocumentViewController *viewController = (PTDocumentViewController *)documentViewController;
                viewController.annotationToolbarButtonHidden = YES;
            }
        },
        PTSearchButtonKey: ^{
            documentViewController.searchButtonHidden = YES;
        },
        PTShareButtonKey: ^{
            documentViewController.shareButtonHidden = YES;
        },
        PTViewControlsButtonKey: ^{
            documentViewController.viewerSettingsButtonHidden = YES;
        },
        PTThumbNailsButtonKey: ^{
            documentViewController.thumbnailBrowserButtonHidden = YES;
        },
        PTListsButtonKey: ^{
            documentViewController.navigationListsButtonHidden = YES;
        },
        PTMoreItemsButtonKey: ^{
            documentViewController.moreItemsButtonHidden = YES;
        },
        PTThumbnailSliderButtonKey: ^{
            documentViewController.thumbnailSliderHidden = YES;
        },
        PTOutlineListButtonKey: ^{
            documentViewController.outlineListHidden = YES;
        },
        PTAnnotationListButtonKey: ^{
            documentViewController.annotationListHidden = YES;
        },
        PTUserBookmarkListButtonKey: ^{
            documentViewController.bookmarkListHidden = YES;
        },
        PTReflowButtonKey: ^{
            documentViewController.readerModeButtonHidden = YES;
        },
//        PTEditPagesButtonKey: ^{
//
//        },
//        PTPrintButtonKey: ^{
//
//        },
//        PTCloseButtonKey: ^{
//
//        },
//        PTSaveCopyButtonKey: ^{
//
//        },
//        PTFormToolsButtonKey: ^{
//
//        },
//        PTFillSignToolsButtonKey: ^{
//
//        },
//        PTEditMenuButtonKey: ^{
//
//        },
//        PTCropPageButtonKey: ^{
//
//        },
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
    [self setToolsPermission:disabledElements toValue:NO documentViewController:documentViewController];
}

- (void)setMultiTabEnabled:(BOOL)enabled
{
    _multiTabEnabled = enabled;
    
}

- (void)setTabTitle:(NSString *)tabTitle
{
    _tabTitle = [tabTitle copy];
    
}

#pragma mark - Disabled tools

- (void)setDisabledTools:(NSArray<NSString *> *)disabledTools
{
    _disabledTools = [disabledTools copy];
    
    if (self.currentDocumentViewController) {
        [self setToolsPermission:disabledTools toValue:NO documentViewController:self.currentDocumentViewController];
    }
}

- (void)setToolsPermission:(NSArray<NSString *> *)stringsArray toValue:(BOOL)value documentViewController:(PTDocumentBaseViewController *)documentViewController
{
    PTToolManager *toolManager = documentViewController.toolManager;
    
    for (NSObject *item in stringsArray) {
        if ([item isKindOfClass:[NSString class]]) {
            NSString *string = (NSString *)item;
            
            if ([string isEqualToString:PTAnnotationEditToolKey]) {
                // multi-select not implemented
            }
            else if ([string isEqualToString:PTAnnotationCreateStickyToolKey] ||
                     [string isEqualToString:PTStickyToolButtonKey]) {
                toolManager.textAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateFreeHandToolKey] ||
                     [string isEqualToString:PTFreeHandToolButtonKey]) {
                toolManager.inkAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTTextSelectToolKey]) {
                toolManager.textSelectionEnabled = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateTextHighlightToolKey] ||
                     [string isEqualToString:PTHighlightToolButtonKey]) {
                toolManager.highlightAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateTextUnderlineToolKey] ||
                     [string isEqualToString:PTUnderlineToolButtonKey]) {
                toolManager.underlineAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateTextSquigglyToolKey] ||
                     [string isEqualToString:PTSquigglyToolButtonKey]) {
                toolManager.squigglyAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateTextStrikeoutToolKey] ||
                     [string isEqualToString:PTStrikeoutToolButtonKey]) {
                toolManager.strikeOutAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateFreeTextToolKey] ||
                     [string isEqualToString:PTFreeTextToolButtonKey]) {
                toolManager.freeTextAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateCalloutToolKey] ||
                     [string isEqualToString:PTCalloutToolButtonKey]) {
                toolManager.calloutAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateSignatureToolKey] ||
                     [string isEqualToString:PTSignatureToolButtonKey]) {
                toolManager.signatureAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateLineToolKey] ||
                     [string isEqualToString:PTLineToolButtonKey]) {
                toolManager.lineAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateArrowToolKey] ||
                     [string isEqualToString:PTArrowToolButtonKey]) {
                toolManager.arrowAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreatePolylineToolKey] ||
                     [string isEqualToString:PTPolylineToolButtonKey]) {
                toolManager.polylineAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateStampToolKey] ||
                     [string isEqualToString:PTStampToolButtonKey]) {
                toolManager.imageStampAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateRectangleToolKey] ||
                     [string isEqualToString:PTRectangleToolButtonKey]) {
                toolManager.squareAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateEllipseToolKey] ||
                     [string isEqualToString:PTEllipseToolButtonKey]) {
                toolManager.circleAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreatePolygonToolKey] ||
                     [string isEqualToString:PTPolygonToolButtonKey]) {
                toolManager.polygonAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreatePolygonCloudToolKey] ||
                     [string isEqualToString:PTCloudToolButtonKey]) {
                toolManager.cloudyAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateFileAttachmentToolKey]) {
                toolManager.fileAttachmentAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateDistanceMeasurementToolKey]) {
                toolManager.rulerAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreatePerimeterMeasurementToolKey]) {
                toolManager.perimeterAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateAreaMeasurementToolKey]) {
                toolManager.areaAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTPencilKitDrawingToolKey]) {
                toolManager.pencilDrawingAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateFreeHighlighterToolKey]) {
                toolManager.freehandHighlightAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateRubberStampToolKey]) {
                // TODO
            }
            else if ([string isEqualToString:PTAnnotationCreateRedactionToolKey]) {
                toolManager.redactAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateLinkToolKey]) {
                toolManager.linkAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateRedactionTextToolKey]) {
                // TODO
            }
            else if ([string isEqualToString:PTAnnotationCreateLinkTextToolKey]) {
                // TODO
            }
            else if ([string isEqualToString:PTFormCreateTextFieldToolKey]) {
                // TODO
            }
            else if ([string isEqualToString:PTFormCreateCheckboxFieldToolKey]) {
                // TODO
            }
            else if ([string isEqualToString:PTFormCreateSignatureFieldToolKey]) {
                // TODO
            }
            else if ([string isEqualToString:PTFormCreateRadioFieldToolKey]) {
                // TODO
            }
            else if ([string isEqualToString:PTFormCreateComboBoxFieldToolKey]) {
                // TODO
            }
            else if ([string isEqualToString:PTFormCreateListBoxFieldToolKey]) {
                // TODO
            }
            else if ([string isEqualToString:PTPanToolKey]) {
                // TODO
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
    else if ( [toolMode isEqualToString:PTPencilKitDrawingToolKey]) {
        toolClass = [PTPencilDrawingCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateFreeHighlighterToolKey]) {
        toolClass = [PTFreeHandHighlightCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateRubberStampToolKey]) {
        toolClass = [PTRubberStampCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateRedactionToolKey]) {
        toolClass = [PTRectangleRedactionCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateLinkToolKey]) {
        // TODO
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateRedactionTextToolKey]) {
        toolClass = [PTTextRedactionCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateLinkTextToolKey]) {
        // TODO
    }
    else if ( [toolMode isEqualToString:PTFormCreateTextFieldToolKey]) {
        // TODO
    }
    else if ( [toolMode isEqualToString:PTFormCreateCheckboxFieldToolKey]) {
        // TODO
    }
    else if ( [toolMode isEqualToString:PTFormCreateSignatureFieldToolKey]) {
        // TODO
    }
    else if ( [toolMode isEqualToString:PTFormCreateRadioFieldToolKey]) {
        // TODO
    }
    else if ( [toolMode isEqualToString:PTFormCreateComboBoxFieldToolKey]) {
        // TODO
    }
    else if ( [toolMode isEqualToString:PTFormCreateListBoxFieldToolKey]) {
        // TODO
    }
    
    if (toolClass) {
        PTTool *tool = [self.currentDocumentViewController.toolManager changeTool:toolClass];
        
        tool.backToPanToolAfterUse = !self.continuousAnnotationEditing;
        
        if ([tool isKindOfClass:[PTFreeHandCreate class]]
            && ![tool isKindOfClass:[PTFreeHandHighlightCreate class]]) {
            ((PTFreeHandCreate *)tool).multistrokeMode = self.continuousAnnotationEditing;
        }
    }
}

- (BOOL)commitTool
{
    PTDocumentBaseViewController *viewController = nil;
    if (self.documentViewController) {
        viewController = self.documentViewController;
    } else if (self.tabbedDocumentViewController) {
        viewController = self.tabbedDocumentViewController.selectedViewController;
    }
    
    if (!viewController) {
        return NO;
    }
    
    PTToolManager *toolManager = viewController.toolManager;
    
    if ([toolManager.tool respondsToSelector:@selector(commitAnnotation)]) {
        [toolManager.tool performSelector:@selector(commitAnnotation)];
        
        [toolManager changeTool:[PTPanTool class]];
        
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
    
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    
    BOOL success = NO;
    @try {
        success = [pdfViewCtrl SetCurrentPage:pageNumber];
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
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;

    NSError *error = nil;
    [pdfViewCtrl DocLock:YES withBlock:^(PTPDFDoc * _Nullable doc) {
        [PTBookmarkManager.defaultManager importBookmarksForDoc:doc fromJSONString:bookmarkJson];
        [pdfViewCtrl Update:YES];
    } error:&error];
    
    if (error) {
        NSLog(@"Error: There was an error while trying to import bookmark json. %@", error.localizedDescription);
    }
}

#pragma mark - Annotation import/export

- (PTAnnot *)findAnnotWithUniqueID:(NSString *)uniqueID onPageNumber:(int)pageNumber pdfViewCtrl:(PTPDFViewCtrl *)pdfViewCtrl
{
    if (uniqueID.length == 0 || pageNumber < 1) {
        return nil;
    }
    
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
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
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
                                                    onPageNumber:pageNumber
                                                     pdfViewCtrl:pdfViewCtrl];
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
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;

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
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    PTToolManager *toolManager = self.currentDocumentViewController.toolManager;

    [toolManager changeTool:[PTPanTool class]];
    
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
    
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    PTToolManager *toolManager = documentViewController.toolManager;
    
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
        [pdfViewCtrl DocLock:YES withBlock:^(PTPDFDoc * _Nullable doc) {
            
            annot = [self findAnnotWithUniqueID:annotId onPageNumber:pageNumberValue pdfViewCtrl:pdfViewCtrl];
            if (![annot IsValid]) {
                NSLog(@"Failed to find annotation with id \"%@\" on page number %d",
                      annotId, pageNumberValue);
                annot = nil;
                return;
            }
            
            [toolManager willRemoveAnnotation:annot onPageNumber:pageNumberValue];

            PTPage *page = [doc GetPage:pageNumberValue];
            if ([page IsValid]) {
                [page AnnotRemoveWithAnnot:annot];
            }
            
            [pdfViewCtrl UpdateWithAnnot:annot page_num:pageNumberValue];
        } error:&error];
        
        // Throw error as exception to reject promise.
        if (error) {
            @throw [NSException exceptionWithName:NSGenericException reason:error.localizedFailureReason userInfo:error.userInfo];
        } else if (annot) {
            [toolManager annotationRemoved:annot onPageNumber:pageNumberValue];
        }
    }
    
    [toolManager changeTool:[PTPanTool class]];
}

#pragma mark - Saving

- (void)saveDocumentWithCompletionHandler:(void (^)(NSString * _Nullable filePath))completionHandler
{
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;

    if (![self isBase64String]) {
        NSString *filePath = documentViewController.coordinatedDocument.fileURL.path;
        
        [documentViewController saveDocument:e_ptincremental completionHandler:^(BOOL success) {
            if (completionHandler) {
                completionHandler((success) ? filePath : nil);
            }
        }];
    } else {
        __block NSString *base64String = nil;
        __block BOOL success = NO;
        NSError *error = nil;
        [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
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
    
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    PTToolManager *toolManager = documentViewController.toolManager;
    
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
            [pdfViewCtrl DocLock:YES withBlock:^(PTPDFDoc * _Nullable doc) {
                
                annot = [self findAnnotWithUniqueID:annotId onPageNumber:pageNumberValue pdfViewCtrl:pdfViewCtrl];
                if (![annot IsValid]) {
                    NSLog(@"Failed to find annotation with id \"%@\" on page number %d",
                            annotId, pageNumberValue);
                    annot = nil;
                    return;
                }
                    
                [toolManager willModifyAnnotation:annot onPageNumber:(int)pageNumber];
                
                [annot SetFlag:annotFlag value:[flagValue boolValue]];
                [pdfViewCtrl UpdateWithAnnot:annot page_num:(int)pageNumber];
                
                [toolManager annotationModified:annot onPageNumber:(int)pageNumber];
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
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    if (!pdfViewCtrl) {
        return;
    }
    
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
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    if (!pdfViewCtrl) {
        return;
    }

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
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    if (!pdfViewCtrl) {
        return;
    }

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
        PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
        if (!pdfViewCtrl) {
            return;
        }
        
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

#pragma mark - Leading nav button

- (void)setNavButtonPath:(NSString *)navButtonPath
{
    _navButtonPath = navButtonPath;
    
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
    [self applyViewerSettings:self.currentDocumentViewController];
}

- (void)applyViewerSettings:(PTDocumentBaseViewController *)documentViewController
{
    if (!documentViewController) {
        return;
    }
    
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    PTToolManager *toolManager = documentViewController.toolManager;
    
    documentViewController.navigationListsViewController.bookmarkViewController.delegate = self;
    
    [self applyReadonly:documentViewController];
    
    // Thumbnail editing enabled.
    documentViewController.thumbnailsViewController.editingEnabled = self.thumbnailViewEditingEnabled;
    documentViewController.thumbnailsViewController.navigationController.toolbarHidden = !self.thumbnailViewEditingEnabled;
    
    // Select after creation.
    toolManager.selectAnnotationAfterCreation = self.selectAnnotationAfterCreation;
    
    // Auto save.
    documentViewController.automaticallySavesDocument = self.autoSaveEnabled;
    
    // Top toolbar.
    documentViewController.controlsHidden = (self.hideTopAppNavBar || self.hideTopToolbars);
    
    const BOOL translucent = (self.hideTopAppNavBar || self.hideTopToolbars);
    documentViewController.thumbnailSliderController.toolbar.translucent = translucent;
    documentViewController.navigationController.navigationBar.translucent = translucent;
    
    // Bottom toolbar.
    documentViewController.bottomToolbarEnabled = self.bottomToolbarEnabled;
    
    documentViewController.hidesControlsOnTap = self.hideToolbarsOnTap;
    documentViewController.pageFitsBetweenBars = !self.hideToolbarsOnTap;
    
    // Page indicator.
    documentViewController.pageIndicatorEnabled = self.pageIndicatorEnabled;
    
    // Page change on tap.
    documentViewController.changesPageOnTap = self.pageChangeOnTap;
    
    // Fit mode.
    if ([self.fitMode isEqualToString:PTFitPageFitModeKey]) {
        [pdfViewCtrl SetPageViewMode:e_trn_fit_page];
        [pdfViewCtrl SetPageRefViewMode:e_trn_fit_page];
    }
    else if ([self.fitMode isEqualToString:PTFitWidthFitModeKey]) {
        [pdfViewCtrl SetPageViewMode:e_trn_fit_width];
        [pdfViewCtrl SetPageRefViewMode:e_trn_fit_width];
    }
    else if ([self.fitMode isEqualToString:PTFitHeightFitModeKey]) {
        [pdfViewCtrl SetPageViewMode:e_trn_fit_height];
        [pdfViewCtrl SetPageRefViewMode:e_trn_fit_height];
    }
    else if ([self.fitMode isEqualToString:PTZoomFitModeKey]) {
        [pdfViewCtrl SetPageViewMode:e_trn_zoom];
        [pdfViewCtrl SetPageRefViewMode:e_trn_zoom];
    }
    
    // Layout mode.
    [self applyLayoutMode:pdfViewCtrl];
    
    // Continuous annotation editing.
    toolManager.tool.backToPanToolAfterUse = !self.continuousAnnotationEditing;
    
    // Annotation author.
    toolManager.annotationAuthor = self.annotationAuthor;
    
    // Shows saved signatures.
    toolManager.showDefaultSignature = self.showSavedSignatures;
    
    toolManager.signatureAnnotationOptions.signSignatureFieldsWithStamps = self.signSignatureFieldsWithStamps;

    // Annotation permission check
    toolManager.annotationPermissionCheckEnabled = self.annotationPermissionCheckEnabled;

    // Use Apple Pencil as a pen
    Class pencilTool = [PTFreeHandCreate class];
    if (@available(iOS 13.1, *)) {
        pencilTool = [PTPencilDrawingCreate class];
    }
    toolManager.pencilTool = self.useStylusAsPen ? pencilTool : [PTPanTool class];

    // Disable UI elements.
    [self disableElementsInternal:self.disabledElements documentViewController:documentViewController];
    
    // Disable tools.
    [self setToolsPermission:self.disabledTools toValue:NO documentViewController:documentViewController];
    
    if ([documentViewController isKindOfClass:[PTDocumentController class]]) {
        PTDocumentController *documentController = (PTDocumentController *)documentViewController;
        [self applyDocumentControllerSettings:documentController];
    }
    
    // Leading Nav Icon.
    [self applyLeadingNavButton];
    
    // Thumbnail Filter Mode
    
    NSMutableArray <PTFilterMode>* filterModeArray = [[NSMutableArray alloc] init];
    
    [filterModeArray addObject:PTThumbnailFilterAll];
    [filterModeArray addObject:PTThumbnailFilterAnnotated];
    [filterModeArray addObject:PTThumbnailFilterBookmarked];
    
    for (NSString * filterModeString in self.hideThumbnailFilterModes) {
        if ([filterModeString isEqualToString:PTAnnotatedFilterModeKey]) {
            [filterModeArray removeObject:PTThumbnailFilterAnnotated];
        } else if ([filterModeString isEqualToString:PTBookmarkedFilterModeKey]) {
            [filterModeArray removeObject:PTThumbnailFilterBookmarked];
        }
    }
    
    NSOrderedSet* filterModeSet = [[NSOrderedSet alloc] initWithArray:filterModeArray];
    documentViewController.thumbnailsViewController.filterModes = filterModeSet;
    
    // Custom HTTP request headers.
    [self applyCustomHeaders:documentViewController];
}

- (void)applyLeadingNavButton
{
    if (self.showNavButton) {
        UIBarButtonItem* navButton = self.leadingNavButtonItem;
        UIImage *navImage = [UIImage imageNamed:self.navButtonPath];
        if (!navButton) {
            if (navImage == nil) {
                navButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemClose target:self action:@selector(navButtonClicked)];
            } else {
                navButton = [[UIBarButtonItem alloc] initWithImage:navImage
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(navButtonClicked)];
            }
            self.leadingNavButtonItem = navButton;
            
            if ([self.viewController isKindOfClass:[PTDocumentController class]]) {
                PTDocumentController *controller = (PTDocumentController *)self.viewController;
                
                NSArray<UIBarButtonItem *> *compactItems = [controller.navigationItem leftBarButtonItemsForSizeClass:UIUserInterfaceSizeClassCompact];
                if (compactItems) {
                    NSMutableArray<UIBarButtonItem *> *mutableItems = [compactItems mutableCopy];
                    [mutableItems insertObject:navButton atIndex:0];
                    compactItems = [mutableItems copy];
                } else {
                    compactItems = @[navButton];
                }
                [controller.navigationItem setLeftBarButtonItems:compactItems
                                                    forSizeClass:UIUserInterfaceSizeClassCompact
                                                        animated:NO];
                
                NSArray<UIBarButtonItem *> *regularItems = [controller.navigationItem leftBarButtonItemsForSizeClass:UIUserInterfaceSizeClassRegular];
                if (regularItems) {
                    NSMutableArray<UIBarButtonItem *> *mutableItems = [regularItems mutableCopy];
                    [mutableItems insertObject:navButton atIndex:0];
                    regularItems = [mutableItems copy];
                } else {
                    regularItems = @[navButton];
                }
                [controller.navigationItem setLeftBarButtonItems:regularItems
                                                    forSizeClass:UIUserInterfaceSizeClassRegular
                                                        animated:NO];
            } else {
                self.viewController.navigationItem.leftBarButtonItem = navButton;
            }
        } else {
            if (navImage) {
                [navButton setImage:navImage];
            }
        }
    }
}

- (void)applyDocumentControllerSettings:(PTDocumentController *)documentController
{
    PTToolGroupManager *toolGroupManager = documentController.toolGroupManager;
    
    documentController.toolGroupsEnabled = !self.hideTopToolbars;
    if ([documentController areToolGroupsEnabled]) {
        NSMutableArray<PTToolGroup *> *toolGroups = [toolGroupManager.groups mutableCopy];
        
        // Handle annotationToolbars.
        if (self.annotationToolbars && self.annotationToolbars.count >= 0) {
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
    
        if (toolGroups.count > 0) {
            if (![toolGroupManager.groups isEqualToArray:toolGroups]) {
                toolGroupManager.groups = toolGroups;
                toolGroupManager.selectedGroup = toolGroups.firstObject;
            }
            
            if (toolGroups.count == 1) {
                documentController.toolGroupIndicatorView.hidden = YES;
            }
        } else {
            documentController.toolGroupManager.selectedGroup = documentController.toolGroupManager.viewItemGroup;
            documentController.toolGroupIndicatorView.hidden = YES;
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

- (void)applyLayoutMode:(PTPDFViewCtrl *)pdfViewCtrl
{
    if ([self.layoutMode isEqualToString:PTSingleLayoutModeKey]) {
        [pdfViewCtrl SetPagePresentationMode:e_trn_single_page];
    }
    else if ([self.layoutMode isEqualToString:PTContinuousLayoutModeKey]) {
        [pdfViewCtrl SetPagePresentationMode:e_trn_single_continuous];
    }
    else if ([self.layoutMode isEqualToString:PTFacingLayoutModeKey]) {
        [pdfViewCtrl SetPagePresentationMode:e_trn_facing];
    }
    else if ([self.layoutMode isEqualToString:PTFacingContinuousLayoutModeKey]) {
        [pdfViewCtrl SetPagePresentationMode:e_trn_facing_continuous];
    }
    else if ([self.layoutMode isEqualToString:PTFacingCoverLayoutModeKey]) {
        [pdfViewCtrl SetPagePresentationMode:e_trn_facing_cover];
    }
    else if ([self.layoutMode isEqualToString:PTFacingCoverContinuousLayoutModeKey]) {
        [pdfViewCtrl SetPagePresentationMode:e_trn_facing_continuous_cover];
    }
}

#pragma mark - Custom headers

- (void)setCustomHeaders:(NSDictionary<NSString *, NSString *> *)customHeaders
{
    _customHeaders = [customHeaders copy];
    
    if (self.currentDocumentViewController) {
        [self applyCustomHeaders:self.currentDocumentViewController];
    }
}

- (void)applyCustomHeaders:(PTDocumentBaseViewController *)documentViewController
{
    documentViewController.additionalHTTPHeaders = self.customHeaders;
}

#pragma mark - Readonly

- (void)setReadOnly:(BOOL)readOnly
{
    _readOnly = readOnly;
    
    [self applyViewerSettings];
}

- (void)applyReadonly:(PTDocumentBaseViewController *)documentViewController
{
    PTToolManager *toolManager = documentViewController.toolManager;

    // Enable readonly flag on tool manager *only* when not already readonly.
    // If the document is being streamed or converted, we don't want to accidentally allow editing by
    // disabling the readonly flag.
    if( [documentViewController.document HasDownloader] )
    {
        if( ![toolManager isReadonly] )
         {
            toolManager.readonly = self.readOnly;
        }
    }
    else
    {
        toolManager.readonly = self.readOnly;
    }
    
    documentViewController.thumbnailsViewController.editingEnabled = !self.readOnly;
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
        PTPencilKitDrawingToolKey: @(PTExtendedAnnotTypePencilDrawing),
        PTAnnotationCreateFreeHighlighterToolKey: @(PTExtendedAnnotTypeFreehandHighlight),
//        PTPanToolKey: @(),
//        PTAnnotationCreateRubberStampToolKey: @(),
        PTAnnotationCreateRedactionToolKey : @(PTExtendedAnnotTypeRedact),
        PTAnnotationCreateLinkToolKey : @(PTExtendedAnnotTypeLink),
//        PTAnnotationCreateRedactionTextToolKey : @(),
//        PTAnnotationCreateLinkTextToolKey : @(),
//        PTFormCreateTextFieldToolKey : @(),
//        PTFormCreateCheckboxFieldToolKey : @(),
//        PTFormCreateSignatureFieldToolKey : @(),
//        PTFormCreateRadioFieldToolKey : @(),
//        PTFormCreateComboBoxFieldToolKey : @(),
//        PTFormCreateListBoxFieldToolKey : @(),
    };
    
    PTExtendedAnnotType annotType = PTExtendedAnnotTypeUnknown;
    
    if( typeMap[reactString] )
    {
        annotType = [typeMap[reactString] unsignedIntValue];
    }

    return annotType;
}

#pragma mark - <PTTabbedDocumentViewControllerDelegate>

- (void)tabbedDocumentViewController:(PTTabbedDocumentViewController *)tabbedDocumentViewController willAddDocumentViewController:(__kindof PTDocumentBaseViewController *)documentViewController
{
    if ([documentViewController isKindOfClass:[PTDocumentController class]]) {
        PTDocumentController *documentController = (PTDocumentController *)documentViewController;
        
        documentController.delegate = self;
    }
    
    [self applyViewerSettings:documentViewController];
    
    if (self.tabTitle) {
        PTDocumentTabItem *tabItem = documentViewController.documentTabItem;
        
        NSURL *fileURL = [RNTPTDocumentView PT_getFileURL:self.document];
        
        if ([tabItem.documentURL.absoluteString isEqualToString:fileURL.absoluteString] ||
            [tabItem.sourceURL.absoluteString isEqualToString:fileURL.absoluteString]) {
            tabItem.displayName = self.tabTitle;
        }
    }
    
    [self registerForDocumentViewControllerNotifications:documentViewController];
    [self registerForPDFViewCtrlNotifications:documentViewController];
}

- (BOOL)tabbedDocumentViewController:(PTTabbedDocumentViewController *)tabbedDocumentViewController shouldHideTabBarForTraitCollection:(UITraitCollection *)traitCollection
{
    // Always show tab bar when using tabbed viewer.
    return NO;
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
    return self.currentDocumentViewController;
}

- (BOOL)toolManager:(PTToolManager *)toolManager shouldHandleLinkAnnotation:(PTAnnot *)annotation orLinkInfo:(PTLinkInfo *)linkInfo onPageNumber:(unsigned long)pageNumber
{
    if (![self.overrideBehavior containsObject:PTLinkPressLinkAnnotationKey]) {
        return YES;
    }
    
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    
    __block NSString *url = nil;
    
    NSError *error = nil;
    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
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
    
    if ([self isReadOnly] && ![documentViewController.toolManager isReadonly]) {
        documentViewController.toolManager.readonly = YES;
    }
    
    [self applyLayoutMode:documentViewController.pdfViewCtrl];
    
    if (self.tabbedDocumentViewController) {
        [self.tabbedDocumentViewController.tabManager saveItems];
    }
    
    if ([self.delegate respondsToSelector:@selector(documentLoaded:)]) {
        [self.delegate documentLoaded:self];
    }
}

- (void)rnt_documentViewControllerDidZoom:(PTDocumentBaseViewController *)documentViewController
{
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    
    const double zoom = pdfViewCtrl.zoom * pdfViewCtrl.zoomScale;
    
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

- (BOOL)rnt_documentViewControllerAreTopToolbarsEnabled:(PTDocumentBaseViewController *)documentViewController;
{
    return !self.hideTopToolbars;
}

- (BOOL)rnt_documentViewControllerIsNavigationBarEnabled:(PTDocumentBaseViewController *)documentViewController
{
    return !self.hideTopAppNavBar;
}

- (NSArray<NSDictionary<NSString *, id> *> *)annotationDataForAnnotations:(NSArray<PTAnnot *> *)annotations pageNumber:(int)pageNumber pdfViewCtrl:(PTPDFViewCtrl *)pdfViewCtrl
{
    NSMutableArray<NSDictionary<NSString *, id> *> *annotationData = [NSMutableArray array];
    
    if (annotations.count > 0) {
        [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc *doc) {
            for (PTAnnot *annot in annotations) {
                if (![annot IsValid]) {
                    continue;
                }
                
                NSString *uniqueId = nil;
                
                PTObj *uniqueIdObj = [annot GetUniqueID];
                if ([uniqueIdObj IsValid] && [uniqueIdObj IsString]) {
                    uniqueId = [uniqueIdObj GetAsPDFText];
                }
                
                PTPDFRect *screenRect = [pdfViewCtrl GetScreenRectForAnnot:annot
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
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;

    NSArray<NSDictionary<NSString *, id> *> *annotationData = [self annotationDataForAnnotations:annotations pageNumber:pageNumber pdfViewCtrl:pdfViewCtrl];
    
    if ([self.delegate respondsToSelector:@selector(annotationsSelected:annotations:)]) {
        [self.delegate annotationsSelected:self annotations:annotationData];
    }
}

- (BOOL)rnt_documentViewController:(PTDocumentBaseViewController *)documentViewController filterMenuItemsForAnnotationSelectionMenu:(UIMenuController *)menuController forAnnotation:(PTAnnot *)annot
{
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;

    __block PTExtendedAnnotType annotType = PTExtendedAnnotTypeUnknown;
    
    NSError *error = nil;
    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc *doc) {
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
    
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    PTToolManager *toolManager = documentViewController.toolManager;
    
    if ([toolManager.tool isKindOfClass:[PTAnnotEditTool class]]) {
        PTAnnotEditTool *annotEdit = (PTAnnotEditTool *)toolManager.tool;
        if (annotEdit.selectedAnnotations.count > 0) {
            [annotations addObjectsFromArray:annotEdit.selectedAnnotations];
        }
    }
    else if (toolManager.tool.currentAnnotation) {
        [annotations addObject:toolManager.tool.currentAnnotation];
    }
    
    const int pageNumber = toolManager.tool.annotationPageNumber;
    
    NSArray<NSDictionary<NSString *, id> *> *annotationData = [self annotationDataForAnnotations:annotations pageNumber:pageNumber pdfViewCtrl:pdfViewCtrl];
        
    if ([self.delegate respondsToSelector:@selector(annotationMenuPressed:annotationMenu:annotations:)]) {
        [self.delegate annotationMenuPressed:self annotationMenu:menuItemId annotations:annotationData];
    }
}

- (void)overriddenLongPressMenuItemPressed:(NSString *)menuItemId
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;

    NSMutableString *selectedText = [NSMutableString string];
    
    NSError *error = nil;
    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc *doc) {
        if (![pdfViewCtrl HasSelection]) {
            return;
        }
        
        const int selectionBeginPage = pdfViewCtrl.selectionBeginPage;
        const int selectionEndPage = pdfViewCtrl.selectionEndPage;
        
        for (int pageNumber = selectionBeginPage; pageNumber <= selectionEndPage; pageNumber++) {
            if ([pdfViewCtrl HasSelectionOnPage:pageNumber]) {
                PTSelection *selection = [pdfViewCtrl GetSelection:pageNumber];
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
    PTDocumentBaseViewController *documentViewController = notification.object;

    if (documentViewController != self.currentDocumentViewController) {
        return;
    }
    
    if ([self isReadOnly] && ![documentViewController.toolManager isReadonly]) {
        documentViewController.toolManager.readonly = YES;
    }
}

- (void)pdfViewCtrlDidChangePageWithNotification:(NSNotification *)notification
{
    if (notification.object != self.currentDocumentViewController.pdfViewCtrl) {
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
    if (notification.object != self.currentDocumentViewController.toolManager) {
        return;
    }
    
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;

    PTAnnot *annot = notification.userInfo[PTToolManagerAnnotationUserInfoKey];
    int pageNumber = ((NSNumber *)notification.userInfo[PTToolManagerPageNumberUserInfoKey]).intValue;
    
    NSString *annotId = [[annot GetUniqueID] IsValid] ? [[annot GetUniqueID] GetAsPDFText] : @"";
    if (annotId.length == 0) {
        PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
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
        [self rnt_sendExportAnnotationCommandWithAction:PTAddAnnotationActionKey xfdfCommand:[self generateXfdfCommand:annots modified:[[PTVectorAnnot alloc] init] deleted:[[PTVectorAnnot alloc] init] pdfViewCtrl:pdfViewCtrl]];
    }
}

- (void)toolManagerDidModifyAnnotationWithNotification:(NSNotification *)notification
{
    if (notification.object != self.currentDocumentViewController.toolManager) {
        return;
    }
    
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    
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
        [self rnt_sendExportAnnotationCommandWithAction:PTModifyAnnotationActionKey xfdfCommand:[self generateXfdfCommand:[[PTVectorAnnot alloc] init] modified:annots deleted:[[PTVectorAnnot alloc] init] pdfViewCtrl:pdfViewCtrl]];
    }
}

- (void)toolManagerDidRemoveAnnotationWithNotification:(NSNotification *)notification
{
    if (notification.object != self.currentDocumentViewController.toolManager) {
        return;
    }
    
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    
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
        [self rnt_sendExportAnnotationCommandWithAction:PTDeleteAnnotationActionKey xfdfCommand:[self generateXfdfCommand:[[PTVectorAnnot alloc] init] modified:[[PTVectorAnnot alloc] init] deleted:annots pdfViewCtrl:pdfViewCtrl]];
    }
}

- (void)toolManagerDidModifyFormFieldDataWithNotification:(NSNotification *)notification
{
    if (notification.object != self.currentDocumentViewController.toolManager) {
        return;
    }
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;

    PTAnnot *annot = notification.userInfo[PTToolManagerAnnotationUserInfoKey];
    if ([annot GetType] == e_ptWidget) {
        PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
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
            [self rnt_sendExportAnnotationCommandWithAction:PTModifyAnnotationActionKey xfdfCommand:[self generateXfdfCommand:[[PTVectorAnnot alloc] init] modified:annots deleted:[[PTVectorAnnot alloc] init] pdfViewCtrl:pdfViewCtrl]];
        }
    }
}

-(void)toolManagerDidChangeToolWithModification:(NSNotification *)notification {
    if (notification.object != self.currentDocumentViewController.toolManager) {
        return;
    }
    
    NSString *toolClass = [RNTPTDocumentView keyForToolClass:[[notification.object tool] class]];
    NSString *previousToolClass = [RNTPTDocumentView keyForToolClass:[notification.userInfo[PTToolManagerPreviousToolUserInfoKey] class]];
    
    if ([self.delegate respondsToSelector:@selector(toolChanged:previousTool:tool:)]) {
        [self.delegate toolChanged:self previousTool:previousToolClass tool:toolClass];
    }
}

-(NSString*)generateXfdfCommand:(PTVectorAnnot*)added modified:(PTVectorAnnot*)modified deleted:(PTVectorAnnot*)deleted pdfViewCtrl:(PTPDFViewCtrl *)pdfViewCtrl {
    NSString *fdfCommand = @"";
    
    BOOL shouldUnlockRead = NO;
    @try {
        [pdfViewCtrl DocLockRead];
        shouldUnlockRead = YES;
        PTPDFDoc *pdfDoc = [pdfViewCtrl GetDoc];
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
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    [self bookmarksModified:documentViewController.pdfViewCtrl];
}

- (void)bookmarkViewController:(PTBookmarkViewController *)bookmarkViewController didAddBookmark:(PTUserBookmark *)bookmark {
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    [self bookmarksModified:documentViewController.pdfViewCtrl];
}

- (void)bookmarkViewController:(PTBookmarkViewController *)bookmarkViewController didRemoveBookmark:(nonnull PTUserBookmark *)bookmark {
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    [self bookmarksModified:documentViewController.pdfViewCtrl];
}

- (void)bookmarksModified:(PTPDFViewCtrl *)pdfViewCtrl
{
    if ([self.delegate respondsToSelector:@selector(bookmarkChanged:bookmarkJson:)]) {
        __block NSString* json;
        NSError* error;
        [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
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
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    PTToolManager *toolManager = self.currentDocumentViewController.toolManager;
    
    PTAnnot *annotation = [self findAnnotWithUniqueID:annotationId onPageNumber:(int)pageNumber pdfViewCtrl:pdfViewCtrl];
    if (annotation) {
        [toolManager selectAnnotation:annotation onPageNumber:(unsigned long)pageNumber];
    }
}


#pragma mark - Set Property for Annotation

- (void)setPropertiesForAnnotation:(NSString *)annotationId pageNumber:(NSInteger)pageNumber propertyMap:(NSDictionary *)propertyMap
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    PTToolManager *toolManager = self.currentDocumentViewController.toolManager;

    NSError *error;
    
    [pdfViewCtrl DocLock:YES withBlock:^(PTPDFDoc * _Nullable doc) {
        
        PTAnnot *annot = [self findAnnotWithUniqueID:annotationId onPageNumber:(int)pageNumber pdfViewCtrl:pdfViewCtrl];
        if (![annot IsValid]) {
            NSLog(@"Failed to find annotation with id \"%@\" on page number %d",
                  annotationId, (int)pageNumber);
            annot = nil;
            return;
        }
        
        [toolManager willModifyAnnotation:annot onPageNumber:(int)pageNumber];
        
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
        
        [pdfViewCtrl UpdateWithAnnot:annot page_num:(int)pageNumber];
        
        [toolManager annotationModified:annot onPageNumber:(int)pageNumber];
    } error:&error];
    
    // Throw error as exception to reject promise.
    if (error) {
        @throw [NSException exceptionWithName:NSGenericException reason:error.localizedFailureReason userInfo:error.userInfo];
    }
}

#pragma mark - Get Crop Box

- (NSDictionary<NSString *, NSNumber *> *)getPageCropBox:(NSInteger)pageNumber
{
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;

    __block NSDictionary<NSString *, NSNumber *> *map;
    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc *doc) {
        
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
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    return [pdfViewCtrl SetCurrentPage:(int)pageNumber];
}

#pragma mark - Get Document Path

- (NSString *) getDocumentPath {
    if (![self isBase64String]) {
        return self.currentDocumentViewController.coordinatedDocument.fileURL.path;
    } else {
        return nil;
    }
}

#pragma mark - Close all tabs

- (void)closeAllTabs
{
    if (!self.tabbedDocumentViewController) {
        return;
    }
    
    PTDocumentTabManager *tabManager = self.tabbedDocumentViewController.tabManager;
    NSArray<PTDocumentTabItem *> *items = [tabManager.items copy];
    
    // Close all tabs except the selected tab, which is displaying a view controller.
    for (PTDocumentTabItem *item in items) {
        if (item != tabManager.selectedItem) {
            [tabManager removeItem:item];
        }
    }
    // Close the selected tab last.
    if (tabManager.selectedItem) {
        [tabManager removeItem:tabManager.selectedItem];
    }
}

#pragma mark - Get Zoom

- (double)getZoom
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    return pdfViewCtrl.zoom * pdfViewCtrl.zoomScale;
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
    else if ([key isEqualToString:PTAnnotationEraserToolKey]) {
        return [PTEraser class];
    }
    else if ([key isEqualToString:PTAnnotationCreateFreeHighlighterToolKey]) {
        return [PTFreeHandHighlightCreate class];
    }
    else if ([key isEqualToString:PTPanToolKey]) {
        return [PTPanTool class];
    }
    else if ([key isEqualToString:PTAnnotationCreateRubberStampToolKey]) {
        return [PTRubberStampCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateRedactionToolKey]) {
        return [PTRectangleRedactionCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateLinkToolKey]) {
        // TODO
    }
    else if ([key isEqualToString:PTAnnotationCreateRedactionTextToolKey]) {
        return [PTTextRedactionCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateLinkTextToolKey]) {
        // TODO
    }
    else if ([key isEqualToString:PTFormCreateTextFieldToolKey]) {
        // TODO
    }
    else if ([key isEqualToString:PTFormCreateCheckboxFieldToolKey]) {
        // TODO
    }
    else if ([key isEqualToString:PTFormCreateSignatureFieldToolKey]) {
        // TODO
    }
    else if ([key isEqualToString:PTFormCreateRadioFieldToolKey]) {
        // TODO
    }
    else if ([key isEqualToString:PTFormCreateComboBoxFieldToolKey]) {
        // TODO
    }
    else if ([key isEqualToString:PTFormCreateListBoxFieldToolKey]) {
        // TODO
    }
    
    if (@available(iOS 13.1, *)) {
        if ([key isEqualToString:PTPencilKitDrawingToolKey]) {
            return [PTPencilDrawingCreate class];
        }
    }
    
    return Nil;
}

+ (NSString *)keyForToolClass:(Class)toolClass
{
    if (toolClass == [PTAnnotSelectTool class]) {
        return PTAnnotationEditToolKey;
    }
    else if (toolClass == [PTAnnotationCreateStickyToolKey class]) {
        return PTAnnotationCreateStickyToolKey;
    }
    else if (toolClass == [PTFreeHandCreate class]) {
        return PTAnnotationCreateFreeHandToolKey;
    }
    else if (toolClass == [PTTextSelectTool class]) {
        return PTTextSelectToolKey;
    }
    else if (toolClass == [PTTextHighlightCreate class]) {
        return PTAnnotationCreateTextHighlightToolKey;
    }
    else if (toolClass == [PTTextUnderlineCreate class]) {
        return PTAnnotationCreateTextUnderlineToolKey;
    }
    else if (toolClass == [PTTextSquigglyCreate class]) {
        return PTAnnotationCreateTextSquigglyToolKey;
    }
    else if (toolClass == [PTFreeTextCreate class]) {
        return PTAnnotationCreateFreeTextToolKey;
    }
    else if (toolClass == [PTCalloutCreate class]) {
        return PTAnnotationCreateCalloutToolKey;
    }
    else if (toolClass == [PTDigitalSignatureTool class]) {
        return PTAnnotationCreateSignatureToolKey;
    }
    else if (toolClass == [PTLineCreate class]) {
        return PTAnnotationCreateLineToolKey;
    }
    else if (toolClass == [PTArrowCreate class]) {
        return PTAnnotationCreateArrowToolKey;
    }
    else if (toolClass == [PTPolylineCreate class]) {
        return PTAnnotationCreatePolylineToolKey;
    }
    else if (toolClass == [PTImageStampCreate class]) {
        return PTAnnotationCreateStampToolKey;
    }
    else if (toolClass == [PTRectangleCreate class]) {
        return PTAnnotationCreateRectangleToolKey;
    }
    else if (toolClass == [PTEllipseCreate class]) {
        return PTAnnotationCreateEllipseToolKey;
    }
    else if (toolClass == [PTPolygonCreate class]) {
        return PTAnnotationCreatePolygonToolKey;
    }
    else if (toolClass == [PTCloudCreate class]) {
        return PTAnnotationCreatePolygonCloudToolKey;
    }
    else if (toolClass == [PTFileAttachmentCreate class]) {
        return PTAnnotationCreateFileAttachmentToolKey;
    }
    else if (toolClass == [PTRulerCreate class]) {
        return PTAnnotationCreateDistanceMeasurementToolKey;
    }
    else if (toolClass == [PTPerimeterCreate class]) {
        return PTAnnotationCreatePerimeterMeasurementToolKey;
    }
    else if (toolClass == [PTAreaCreate class]) {
        return PTAnnotationCreateAreaMeasurementToolKey;
    }
    else if (toolClass == [PTEraser class]) {
        return PTAnnotationEraserToolKey;
    }
    else if (toolClass == [PTFreeHandHighlightCreate class]) {
        return PTAnnotationCreateFreeHighlighterToolKey;
    }
    else if (toolClass == [PTRubberStampCreate class]) {
        return PTAnnotationCreateFreeHighlighterToolKey;
    }
    else if (toolClass == [PTRectangleRedactionCreate class]) {
        return PTAnnotationCreateRedactionToolKey;
    }
    else if (toolClass == [PTTextRedactionCreate class]) {
        return PTAnnotationCreateRedactionTextToolKey;
    }
    else if (toolClass == [PTPanTool class]) {
        return PTPanToolKey;
    }
    
    if (@available(iOS 13.1, *)) {
        if (toolClass == [PTPencilDrawingCreate class]) {
            return PTPencilKitDrawingToolKey;
        }
    }
    
    return Nil;
}

+ (NSURL *)PT_getFileURL:(NSString *)document
{
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:document withExtension:@"pdf"];
    if ([document containsString:@"://"]) {
        fileURL = [NSURL URLWithString:document];
    } else if ([document hasPrefix:@"/"]) {
        fileURL = [NSURL fileURLWithPath:document];
    }
    
    return fileURL;
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
