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

@class RNTPTCollaborationService;

NS_ASSUME_NONNULL_BEGIN

@interface RNTPTDocumentView () <PTTabbedDocumentViewControllerDelegate, RNTPTDocumentViewControllerDelegate, RNTPTDocumentControllerDelegate, PTCollaborationServerCommunication, RNTPTNavigationControllerDelegate, PTBookmarkViewControllerDelegate>
{
    NSMutableDictionary<NSString *, NSNumber *> *_annotationToolbarItemKeyMap;
    NSUInteger _annotationToolbarItemCounter;
}

@property (nonatomic, strong, nullable) UIViewController *viewController;

@property (nonatomic, strong, nullable) PTTabbedDocumentViewController *tabbedDocumentViewController;

@property (nonatomic, nullable) PTDocumentBaseViewController *documentViewController;

@property (nonatomic, readonly, nullable) PTDocumentBaseViewController *currentDocumentViewController;

@property (nonatomic, strong, nullable) UIBarButtonItem *leadingNavButtonItem;

// Array of wrapped PTExtendedAnnotTypes.
@property (nonatomic, strong, nullable) NSArray<NSNumber *> *hideAnnotMenuToolsAnnotTypes;

@property (nonatomic, strong, nullable) NSMutableArray<NSString *> *tempFilePaths;

@property (nonatomic, strong, nullable) RNTPTCollaborationService* collabService;

@end

NS_ASSUME_NONNULL_END


@interface RNTPTCollaborationService : NSObject<PTCollaborationServerCommunication>

@property (nonatomic, weak, nullable) RNTPTDocumentView* viewProxy;

@property (nonatomic, weak, nullable) PTBaseCollaborationManager* collaborationManager;

@property (nonatomic, readonly, copy, nullable) NSString *userID;

@property (nonatomic, readonly, copy, nullable) NSString *documentID;

@end

@implementation RNTPTCollaborationService

-(PTBaseCollaborationManager*)collaborationManger
{
    return self.viewProxy.collaborationManager;
}

-(void)setCollaborationManager:(PTCollaborationManager*)collaborationManager
{
    self.viewProxy.collaborationManager = collaborationManager;
}

- (NSString *)documentID
{
    return self.viewProxy.document;
}

- (NSString *)userID
{
    return self.viewProxy.currentUser;
}

- (void)documentLoaded
{
    [self.viewProxy documentLoaded];
}

- (void)localAnnotationAdded:(PTCollaborationAnnotation *)collaborationAnnotation
{
    [self.viewProxy localAnnotationAdded:collaborationAnnotation];
}

- (void)localAnnotationModified:(PTCollaborationAnnotation *)collaborationAnnotation
{
    [self.viewProxy localAnnotationModified:collaborationAnnotation];
}

- (void)localAnnotationRemoved:(PTCollaborationAnnotation *)collaborationAnnotation
{
    [self.viewProxy localAnnotationRemoved:collaborationAnnotation];
}

@end

@implementation RNTPTDocumentView

- (void)RNTPTDocumentView_commonInit
{
    _multiTabEnabled = NO;
    
    _hideTopAppNavBar = NO;
    _hideTopToolbars = NO;
    _presetsToolbarHidden = NO;
    
    _bottomToolbarEnabled = YES;
    _hideToolbarsOnTap = YES;
    
    _documentSliderEnabled = YES;
    
    _base64String = NO;
    _base64Extension = @".pdf";
    
    _pageIndicatorEnabled = YES;
    _pageIndicatorShowsOnPageChange = YES;
    _pageIndicatorShowsWithControls = YES;
    
    _keyboardShortcutsEnabled = YES;

    _autoSaveEnabled = YES;
    
    _pageChangeOnTap = NO;
    _thumbnailViewEditingEnabled = YES;
    _selectAnnotationAfterCreation = YES;
    _autoResizeFreeTextEnabled = YES;
    
    _inkMultiStrokeEnabled = YES;

    _followSystemDarkMode = YES;

    _useStylusAsPen = YES;
    _longPressMenuEnabled = YES;
    
    _maxTabCount = INT_MAX;
    
    _saveStateEnabled = YES;
    
    [PTOverrides overrideClass:[PTThumbnailsViewController class]
                     withClass:[RNTPTThumbnailsViewController class]];

    [PTOverrides overrideClass:[PTAnnotationManager class]
                     withClass:[RNTPTAnnotationManager class]];

    [PTOverrides overrideClass:[PTAnnotationReplyViewController class]
                     withClass:[RNTPTAnnotationReplyViewController class]];
    
    [PTOverrides overrideClass:[PTDigitalSignatureTool class]
                     withClass:[RNTPTDigitalSignatureTool class]];

    _tempFilePaths = [[NSMutableArray alloc] init];
    
    _showSavedSignatures = YES;
    _storeNewSignature = YES;

    _annotationsListEditingEnabled = YES;
    _userBookmarksListEditingEnabled = YES;
    
    _showQuickNavigationButton = YES;

    _replyReviewStateEnabled = YES;

    _annotationToolbarItemKeyMap = [NSMutableDictionary dictionary];
    _annotationToolbarItemCounter = 0;
    _maxSignatureCount = -1;
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

#pragma mark - Document Opening

- (void)openDocument
{
    if (!self.documentViewController && !self.tabbedDocumentViewController) {
        return;
    }
    
    NSURL* fileURL;
    if (![self isBase64String]) {
        fileURL = [RNTPTDocumentView PT_getFileURL:self.document];
    } else {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:self.document options:0];

        NSMutableString *path = [[NSMutableString alloc] init];
        [path appendFormat:@"%@tmp%@%@", NSTemporaryDirectory(), [[NSUUID UUID] UUIDString], self.base64Extension];

        fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
        NSError* error;

        [data writeToURL:fileURL options:NSDataWritingAtomic error:&error];
        
        if (error) {
            NSLog(@"Error: There was an error while trying to create a temporary file for base64 string. %@", error.localizedDescription);
            return;
        }

        [self.tempFilePaths addObject:path];
    }

    PTDocumentOptions *options = [PTDocumentOptions options];
    if (self.documentExtension != nil) {
        options.sourcePathExtension = self.documentExtension;
    }
    options.password = self.password;

    if (self.documentViewController) {
        [self.documentViewController openDocumentWithURL:fileURL
                                                 options:options];

        [self applyLayoutMode:self.documentViewController.pdfViewCtrl];
    } else {
        [self.tabbedDocumentViewController openDocumentWithURL:fileURL
                                                       options:options];
    }
}

- (void)setDocument:(NSString *)document
{
    if([document length] != 0){
        _document = [document copy];
    }
    
    [self openDocument];
}


- (void)setSource:(NSString *)source
{
    _document = [source copy];
    
    [self openDocument];
}

#pragma mark - DocumentViewController loading

- (void)loadViewController
{
    if (!self.documentViewController && !self.tabbedDocumentViewController) {
        if ([self isCollabEnabled]) {
            PTExternalAnnotManagerMode collabMode = e_ptadmin_undo_own;

            if ([PTAnnotationManagerUndoModeOwn isEqualToString:self.annotationManagerUndoMode]) {
                collabMode = e_ptadmin_undo_own;
            }

            if ([PTAnnotationManagerUndoModeAll isEqualToString:self.annotationManagerUndoMode]) {
                collabMode = e_ptadmin_undo_others;
            }
            
            self.collabService = [[RNTPTCollaborationService alloc] init];
            self.collabService.viewProxy = self;
            
            RNTPTCollaborationDocumentController *collaborationViewController = [[RNTPTCollaborationDocumentController alloc] initWithCollaborationService:self.collabService collaborationMode:collabMode];
            collaborationViewController.delegate = self;
            collaborationViewController.collaborationReplyViewController.annotationStateEnabled = self.replyReviewStateEnabled;
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
                RNTPTDocumentController *documentViewController = [[RNTPTDocumentController allocOverridden] init];
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
            [self registerForTabbedDocumentViewControllerNotifications:self.tabbedDocumentViewController];
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
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            @try {
                NSURL * const fileURLToRemove = PTDocumentTabManager.savedItemsURL;
                if (!fileURLToRemove) {
                    return;
                }
                [NSFileManager.defaultManager removeItemAtURL:fileURLToRemove
                                                        error:nil];
            }
            @catch (...) {
                // Ignored.
            }
        });
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
    
    // Follow System Dark Mode
    if (@available(iOS 13.0, *)) {
        UIViewController * const viewController = navigationController;
        viewController.overrideUserInterfaceStyle = (self.followSystemDarkMode ?
                                                     UIUserInterfaceStyleUnspecified :
                                                     UIUserInterfaceStyleLight);
        
        UIWindow * const window = self.window;
        if (window) {
            window.overrideUserInterfaceStyle = (self.followSystemDarkMode ?
                                                 UIUserInterfaceStyleUnspecified :
                                                 UIUserInterfaceStyleLight);
        }
    }
    
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
    
    if (self.tempFilePaths) {
        for (NSString* path in self.tempFilePaths) {
            NSError* error;
            [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            
            if (error) {
                NSLog(@"Error: There was an error while deleting the temporary file for base64. %@", error.localizedDescription);
            }
        }
    }
    if (!self.viewController) {
        return;
    }
    
    if (self.documentViewController) {
        [self deregisterForPDFViewCtrlNotifications:self.documentViewController];
    }
    
    if (self.tabbedDocumentViewController) {
        [self.tabbedDocumentViewController.tabManager saveItems];
        [self deregisterForTabbedDocumentViewControllerNotifications:self.tabbedDocumentViewController];
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
    NSUndoManager *undoManager = toolManager.undoManager;
    
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
               selector:@selector(toolManagerDidFlattenAnnotationWithNotification:)
                   name:PTToolManagerAnnotationFlattenedNotification
                 object:toolManager];
    
    [center addObserver:self
               selector:@selector(toolManagerDidModifyFormFieldDataWithNotification:) name:PTToolManagerFormFieldDataModifiedNotification
                 object:toolManager];

    [center addObserver:self
               selector:@selector(toolManagerWillChangeToolWithNotification:)
                   name:PTToolManagerToolWillChangeNotification
                 object:toolManager];

    [center addObserver:self
               selector:@selector(toolManagerDidChangeToolWithModification:)
                   name:PTToolManagerToolDidChangeNotification
                 object:toolManager];
    
    [center addObserver:self
               selector:@selector(undoManagerStateDidChangeWithModification:)
                   name:NSUndoManagerDidCloseUndoGroupNotification
                 object:undoManager];

    [center addObserver:self
               selector:@selector(undoManagerStateDidChangeWithModification:)
                   name:NSUndoManagerDidUndoChangeNotification
                 object:undoManager];

    [center addObserver:self
               selector:@selector(undoManagerStateDidChangeWithModification:)
                   name:NSUndoManagerDidRedoChangeNotification
                 object:undoManager];
    
    if ([[documentViewController class] isSubclassOfClass:[PTDocumentController class]]) {
        PTToolGroupManager *toolGroupManager = ((PTDocumentController *) documentViewController).toolGroupManager;
        
        [center addObserver:self
                   selector:@selector(toolGroupDidChangeWithNotification:)
                       name:PTToolGroupDidChangeNotification
                     object:toolGroupManager];
    }
}

- (void)deregisterForPDFViewCtrlNotifications:(PTDocumentBaseViewController *)documentViewController
{
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    PTToolManager *toolManager = documentViewController.toolManager;
    NSUndoManager *undoManager = toolManager.undoManager;

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
                      name:PTToolManagerAnnotationFlattenedNotification
                    object:toolManager];

    [center removeObserver:self
                      name:PTToolManagerFormFieldDataModifiedNotification
                    object:toolManager];
    
    [center removeObserver:self
                      name:PTToolManagerToolDidChangeNotification
                    object:toolManager];

    [center removeObserver:self
                   name:NSUndoManagerDidCloseUndoGroupNotification
                 object:undoManager];

    [center removeObserver:self
                   name:NSUndoManagerDidUndoChangeNotification
                 object:undoManager];

    [center removeObserver:self
                   name:NSUndoManagerDidRedoChangeNotification
                 object:undoManager];
    
    if ([[documentViewController class] isSubclassOfClass:[PTDocumentController class]]) {
        PTToolGroupManager *toolGroupManager = ((PTDocumentController *) documentViewController).toolGroupManager;
        
        [center removeObserver:self
                          name:PTToolGroupDidChangeNotification
                        object:toolGroupManager];
    }
}

- (void)registerForTabbedDocumentViewControllerNotifications:(PTTabbedDocumentViewController *)tabbedDocumentViewController
{
    [tabbedDocumentViewController addObserver:self forKeyPath:@"tabManager.selectedIndex" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:TabChangedContext];
}

- (void)deregisterForTabbedDocumentViewControllerNotifications:(PTTabbedDocumentViewController *)tabbedDocumentViewController
{
    [tabbedDocumentViewController removeObserver:self forKeyPath:@"tabManager.selectedIndex" context:TabChangedContext];
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
        PTLayerListButtonKey: ^{
            documentViewController.pdfLayerListHidden = YES;
            documentViewController.navigationListsViewController.pdfLayerViewControllerVisibility = PTNavigationListsViewControllerVisibilityAlwaysHidden;
        },
        PTReflowButtonKey: ^{
            documentViewController.readerModeButtonHidden = YES;
            documentViewController.settingsViewController.viewModeReaderHidden = YES;
        },
        PTEditPagesButtonKey: ^{
            documentViewController.addPagesButtonHidden = YES;
            if( [documentViewController isKindOfClass:[PTDocumentController class]] )
            {
                PTToolGroupManager *toolGroupManager = ((PTDocumentController*)documentViewController).toolGroupManager;
                PTToolGroup *insertItemGroup = toolGroupManager.insertItemGroup;
                NSMutableArray<UIBarButtonItem *> *barButtonItems = [insertItemGroup.barButtonItems mutableCopy];
                [barButtonItems removeObject:toolGroupManager.addPagesButtonItem];
                insertItemGroup.barButtonItems = [barButtonItems copy];
            }
        },
        PTEditMenuButtonKey: ^{
            if( [documentViewController isKindOfClass:[PTDocumentController class]] )
		    {
                PTDocumentController *documentController = (PTDocumentController *)documentViewController;
                documentController.toolGroupManager.editingEnabled = NO;
            }
        },
//        PTPrintButtonKey: ^{
//
//        },
//        PTCloseButtonKey: ^{
//
//        },
        PTSaveCopyButtonKey: ^{
            documentViewController.exportButtonHidden = YES;
        },
        PTSaveIdenticalCopyButtonKey: ^ {
            if (![documentViewController isExportButtonHidden]) {
                NSMutableArray * exportItems = [documentViewController.exportItems mutableCopy];
                [exportItems removeObject:documentViewController.exportCopyButtonItem];
                documentViewController.exportItems = [exportItems copy];
            }
        },
        PTSaveFlattenedCopyButtonKey: ^{
            if (![documentViewController isExportButtonHidden]) {
                NSMutableArray * exportItems = [documentViewController.exportItems mutableCopy];
                [exportItems removeObject:documentViewController.exportFlattenedCopyButtonItem];
                documentViewController.exportItems = [exportItems copy];
            }
        },
        PTSaveCroppedCopyButtonKey: ^{
            if (![documentViewController isExportButtonHidden]) {
                NSMutableArray * exportItems = [documentViewController.exportItems mutableCopy];
                [exportItems removeObject:documentViewController.exportCroppedCopyButtonItem];
                documentViewController.exportItems = [exportItems copy];
            }
        },
//        PTFormToolsButtonKey: ^{
//
//        },
//        PTFillSignToolsButtonKey: ^{
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

- (void)setExcludedAnnotationListTypes:(NSArray<NSString *> *)excludedAnnotationListTypes
{
    _excludedAnnotationListTypes = excludedAnnotationListTypes;
    
    if (self.currentDocumentViewController) {
        [self excludeAnnotationListTypes:excludedAnnotationListTypes documentViewController:self.currentDocumentViewController];
    }
}

- (void)excludeAnnotationListTypes:(NSArray<NSString*> *)excludedAnnotationListTypes documentViewController:(PTDocumentBaseViewController *)documentViewController
{
    NSMutableArray<NSNumber *> *annotTypes = [[NSMutableArray alloc] init];
    
    for (NSString *string in excludedAnnotationListTypes) {
        PTAnnotType annotType = [RNTPTDocumentView annotTypeForString:string];
        [annotTypes addObject:[NSNumber numberWithInt:annotType]];
    }
    
    if (annotTypes.count > 0) {
        documentViewController.navigationListsViewController.annotationViewController.excludedAnnotationTypes = annotTypes;
    }
}

- (void)setInkMultiStrokeEnabled:(BOOL)inkMultiStrokeEnabled
{
    _inkMultiStrokeEnabled = inkMultiStrokeEnabled;
}

- (void)setDefaultEraserType:(NSString *)defaultEraserType
{
    _defaultEraserType = defaultEraserType;
    
    if (self.currentDocumentViewController) {
        [self applyDefaultEraserType:defaultEraserType documentViewController:self.currentDocumentViewController];
    }
}

- (void)applyDefaultEraserType:(NSString *)defaultEraserType documentViewController:(PTDocumentBaseViewController *)documentViewController
{
    PTToolManager *toolManager = documentViewController.toolManager;
    
    if ([defaultEraserType isEqualToString:PTInkEraserModeAllKey]) {
        toolManager.eraserMode = PTInkEraserModeAll;
    } else if ([defaultEraserType isEqualToString:PTInkEraserModePointsKey]) {
        toolManager.eraserMode = PTInkEraserModePoints;
    }
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
    NSMutableArray *addPagesItems = [documentViewController.addPagesViewController.items mutableCopy];
    
    for (NSObject *item in stringsArray) {
        if ([item isKindOfClass:[NSString class]]) {
            NSString *string = (NSString *)item;
            
            if ([string isEqualToString:PTAnnotationEditToolKey] ||
                [string isEqualToString:PTEditToolButtonKey] ||
                [string isEqualToString:PTMultiSelectToolKey]) {
                toolManager.allowsMultipleAnnotationSelection = value;
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
            else if ([string isEqualToString:PTInsertPageToolKey] ||
                     [string isEqualToString:PTInsertPageButton]) {
                PTToolGroupManager *toolGroupManager = ((PTDocumentController*)documentViewController).toolGroupManager;
                PTToolGroup *insertItemGroup = toolGroupManager.insertItemGroup;
                NSMutableArray<UIBarButtonItem *> *barButtonItems = [insertItemGroup.barButtonItems mutableCopy];
                [barButtonItems removeObject:toolGroupManager.addPagesButtonItem];
                insertItemGroup.barButtonItems = [barButtonItems copy];
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
                toolManager.stampAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateRedactionToolKey] ||
                     [string isEqualToString:PTAnnotationCreateRedactionTextToolKey]) {
                toolManager.redactAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateLinkToolKey] ||
                     [string isEqualToString:PTAnnotationCreateLinkTextToolKey]) {
                toolManager.linkAnnotationOptions.canCreate = value;
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
            else if ([string isEqualToString:PTAnnotationCountToolKey]) {
                toolManager.countAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateSmartPenToolKey]) {
                toolManager.smartPenEnabled = value;
            }
            else if ([string isEqualToString:PTAnnotationCreateFreeTextDateToolKey]) {
                toolManager.dateTextAnnotationOptions.canCreate = value;
            }
            else if ([string isEqualToString:PTFormFillToolKey]) {
                toolManager.widgetAnnotationOptions.canEdit = value;
            }
            else if([string isEqualToString:PTInsertBlankPageButton]){
                [addPagesItems removeObject:documentViewController.addPagesViewController.addBlankPagesButtonItem];
            }
            else if([string isEqualToString:PTInsertFromImageButton]){
                [addPagesItems removeObject:documentViewController.addPagesViewController.addImagePageButtonItem];
            }
            else if([string isEqualToString:PTInsertFromPhotoButton]){
                [addPagesItems removeObject:documentViewController.addPagesViewController.addCameraImagePageButtonItem];
            }
            else if([string isEqualToString:PTInsertFromScannerButton]){
                [addPagesItems removeObject:documentViewController.addPagesViewController.addScannedPageButtonItem];
            }
            else if([string isEqualToString:PTInsertFromDocumentButton]){
                [addPagesItems removeObject:documentViewController.addPagesViewController.addDocumentPagesButtonItem];
            }
            else if([string isEqualToString:PTAnnotationCreateCheckMarkStampKey]) {
                // TODO
            }
            else if([string isEqualToString:PTAnnotationCreateCrossMarkStampKey]) {
                // TODO
            }
            else if([string isEqualToString:PTAnnotationCreateDotStampKey]) {
                // TODO
            }
        }
    }
    if([addPagesItems count] == 0){
        documentViewController.addPagesButtonHidden = true;
        PTToolGroupManager *toolGroupManager = ((PTDocumentController*)documentViewController).toolGroupManager;
        PTToolGroup *insertItemGroup = toolGroupManager.insertItemGroup;
        NSMutableArray<UIBarButtonItem *> *barButtonItems = [insertItemGroup.barButtonItems mutableCopy];
        [barButtonItems removeObject:toolGroupManager.addPagesButtonItem];
        insertItemGroup.barButtonItems = [barButtonItems copy];
    }
    documentViewController.addPagesViewController.items = [addPagesItems copy];
}

- (void)setToolMode:(NSString *)toolMode
{
    if (toolMode.length == 0) {
        return;
    }
    
    Class toolClass = Nil;
    
    if( [toolMode isEqualToString:PTAnnotationEditToolKey] )
    {
        toolClass = [PTAnnotEditTool class];
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
    else if ( [toolMode isEqualToString:PTMultiSelectToolKey] ) {
        toolClass = [PTAnnotSelectTool class];
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
    else if ( [toolMode isEqualToString:PTAnnotationCountToolKey]) {
        toolClass = [PTCountCreate class];
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
    else if ( [toolMode isEqualToString:PTAnnotationCreateLinkToolKey] ||
             [toolMode isEqualToString:PTAnnotationCreateLinkTextToolKey]) {
        toolClass = [PTLinkCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateRedactionTextToolKey]) {
        toolClass = [PTTextRedactionCreate class];
    }
    else if ( [toolMode isEqualToString:PTFormCreateTextFieldToolKey]) {
        toolClass = [PTTextFieldCreate class];
    }
    else if ( [toolMode isEqualToString:PTFormCreateCheckboxFieldToolKey]) {
        toolClass = [PTCheckBoxCreate class];
    }
    else if ( [toolMode isEqualToString:PTFormCreateSignatureFieldToolKey]) {
        toolClass = [PTSignatureFieldCreate class];
    }
    else if ( [toolMode isEqualToString:PTFormCreateRadioFieldToolKey]) {
        toolClass = [PTRadioButtonCreate class];
    }
    else if ( [toolMode isEqualToString:PTFormCreateComboBoxFieldToolKey]) {
        toolClass = [PTComboBoxCreate class];
    }
    else if ( [toolMode isEqualToString:PTFormCreateListBoxFieldToolKey]) {
        toolClass = [PTListBoxCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateFreeTextDateToolKey]) {
        toolClass = [PTDateTextCreate class];
    } 
    else if ( [toolMode isEqualToString:PTAnnotationCreateCheckMarkStampKey] ) {
        toolClass = [PTCheckMarkStampCreate class];
    } 
    else if ( [toolMode isEqualToString:PTAnnotationCreateCrossMarkStampKey] ) {
        toolClass = [PTCrossMarkStampCreate class];
    }
    else if ( [toolMode isEqualToString:PTAnnotationCreateDotStampKey] ) {
        toolClass = [PTDotStampCreate class];
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

#pragma mark - Uneditable annotation types

- (void)setUneditableAnnotationTypes:(NSArray<NSString *> *)uneditableAnnotationTypes
{
    _uneditableAnnotationTypes = [uneditableAnnotationTypes copy];
    
    if (self.currentDocumentViewController) {
        [self setAnnotationEditingPermission:uneditableAnnotationTypes toValue:NO documentViewController:self.currentDocumentViewController];
    }
}

- (void)setAnnotationEditingPermission:(NSArray<NSString *> *)stringsArray toValue:(BOOL)value documentViewController:(PTDocumentBaseViewController *)documentViewController
{
    PTToolManager *toolManager = documentViewController.toolManager;
    
    for (NSObject *item in stringsArray) {
        if ([item isKindOfClass:[NSString class]]) {
            NSString *string = (NSString *)item;
            PTExtendedAnnotType typeToSetPermission = [self reactAnnotationNameToAnnotType:string];
            
            [toolManager annotationOptionsForAnnotType:typeToSetPermission].canEdit = value;
        }
    }
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

#pragma mark - Bookmark

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

-(void)openBookmarkList
{
    if (!self.currentDocumentViewController.bookmarkListHidden) {
        PTNavigationListsViewController *navigationListsViewController = self.currentDocumentViewController.navigationListsViewController;
        navigationListsViewController.selectedViewController = navigationListsViewController.bookmarkViewController;
        [self.currentDocumentViewController presentViewController:navigationListsViewController animated:YES completion:nil];
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

- (nullable NSArray<NSDictionary *> *)importAnnotations:(NSString *)xfdfString
{
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;

    NSError *error;
    __block BOOL hasDownloader = false;
    
    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
        hasDownloader = [[pdfViewCtrl GetDoc] HasDownloader];
    } error:&error];
    
    if (hasDownloader || error) {
        return nil;
    }
    
    PTAnnotationManager * const annotationManager = documentViewController.toolManager.annotationManager;
    
    const BOOL updateSuccess = [annotationManager updateAnnotationsWithXFDFString:xfdfString
                                                                            error:&error];
    if (!updateSuccess || error) {
        @throw [NSException exceptionWithName:NSGenericException reason:error.localizedFailureReason userInfo:error.userInfo];
    }
    
    return [self getAnnotationFromXFDF:xfdfString];

}

-(NSArray<NSDictionary *> *)getAnnotationFromXFDF:(NSString *)xfdfString
{
    NSMutableArray<NSDictionary *> *annotations = [[NSMutableArray alloc] init];
    @try {
        PTFDFDoc *fdfDoc = [PTFDFDoc CreateFromXFDF:xfdfString];
        PTObj *fdf = [fdfDoc GetFDF];
        if ([fdf IsValid]) {
            PTObj *annots = [fdf FindObj:@"Annots"];
            if ([annots IsValid] && [annots IsArray]) {
                long size = [annots Size];
                for (int i = 0; i < size; i++) {
                    PTObj *annotObj = [annots GetAt:i];

                    if ([annotObj IsValid]) {
                        NSMutableDictionary *annotPair = [[NSMutableDictionary alloc] init];
                        PTAnnot *annot = [[PTAnnot alloc] initWithD:annotObj];
                        NSString *annotId = [[annot GetUniqueID] GetAsPDFText];
                        int page = [[annot GetPage] GetIndex] + 1;
                        if (annotId) {
                            [annotPair setValue:annotId forKey:PTAnnotationIdKey];
                        }
                        [annotPair setValue:[NSNumber numberWithInt:page] forKey:PTAnnotationPageNumberKey];
                        [annotations addObject:annotPair];
                    }
                }
            }
        }
    }   
    @catch (NSException *exception) {
        NSLog(@"Exception: %@, %@", exception.name, exception.reason);
    }

    return [annotations copy];
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

    NSString *filePath = documentViewController.coordinatedDocument.fileURL.path;

    [documentViewController saveDocument:e_ptincremental completionHandler:^(BOOL success) {
        if (completionHandler) {
            if (![self isBase64String]) {
                completionHandler((success) ? filePath : nil);
            } else if (!success) {
                completionHandler(nil);
            } else {
                __block NSString *base64String = nil;
                NSError *error = nil;
                [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
                    NSData *data = [doc SaveToBuf:0];

                    base64String = [data base64EncodedStringWithOptions:0];
                } error:&error];
                if (completionHandler) {
                    completionHandler((error == nil) ? base64String : nil);
                }
            }
        }
    }];
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

- (NSDictionary *)getField:(NSString *)fieldName
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    if (!pdfViewCtrl) {
        return nil;
    }
    
    NSMutableDictionary <NSString *, NSObject *> *fieldMap = [[NSMutableDictionary alloc] init];

    NSError *error;
    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
        
        PTField *field = [doc GetField:fieldName];
        if (field && [field IsValid]) {
            
            PTFieldType fieldType = [field GetType];
            NSString* typeString;
            if (fieldType == e_ptbutton) {
                typeString = PTFieldTypeButtonKey;
            } else if (fieldType == e_ptcheck) {
                typeString = PTFieldTypeCheckboxKey;
                [fieldMap setValue:[[NSNumber alloc] initWithBool:[field GetValueAsBool]] forKey:PTFormFieldValueKey];
            } else if (fieldType == e_ptradio) {
                typeString = PTFieldTypeRadioKey;
                [fieldMap setValue:[field GetValueAsString] forKey:PTFormFieldValueKey];
            } else if (fieldType == e_pttext) {
                typeString = PTFieldTypeTextKey;
                [fieldMap setValue:[field GetValueAsString] forKey:PTFormFieldValueKey];
            } else if (fieldType == e_ptchoice) {
                typeString = PTFieldTypeChoiceKey;
                [fieldMap setValue:[field GetValueAsString] forKey:PTFormFieldValueKey];
            } else if (fieldType == e_ptsignature) {
                typeString = PTFieldTypeSignatureKey;
            } else {
                typeString = PTFieldTypeUnknownKey;
            }
            
            [fieldMap setValue:typeString forKey:PTFormFieldTypeKey];
            [fieldMap setValue:fieldName forKey:PTFormFieldNameKey];
        }
            
        
    } error:&error];
    
    if (error) {
        NSLog(@"Error: There was an error while trying to get field. %@", error.localizedDescription);
    }
    
    return [[fieldMap allKeys] count] == 0 ? nil : fieldMap;
}

- (NSDictionary *)getFieldWithHasAppearance:(PTAnnot *)annot
{
    __block PTWidget *widget;
    __block PTField *field;
    __block NSString *fieldName;
    __block NSMutableDictionary <NSString *, NSObject *> *fieldMap = [[NSMutableDictionary alloc] init];
    
    widget = [[PTWidget alloc] initWithAnn:annot];
    field = [widget GetField];
    fieldName = [field IsValid] ? [field GetName] : @"";
    fieldMap = [self getField:fieldName];
    NSString *fieldType = fieldMap[PTFormFieldTypeKey];
    if([fieldType isEqualToString:PTFieldTypeSignatureKey]){
        PTSignatureWidget *signatureWidget = [[PTSignatureWidget alloc] initWithAnnot:annot];
        PTDigitalSignatureField *digitalSignatureField= [signatureWidget GetDigitalSignatureField];
        Boolean hasExistingSignature = [digitalSignatureField HasVisibleAppearance];
        [fieldMap setValue:[[NSNumber alloc] initWithBool:hasExistingSignature] forKey:PTFormFieldHasAppearanceKey];
    }   
    return [[fieldMap allKeys] count] == 0 ? nil : [fieldMap copy];
}

#pragma mark - Annotation

-(void)setAnnotationPermissionCheckEnabled:(BOOL)annotationPermissionCheckEnabled
{
    _annotationPermissionCheckEnabled = annotationPermissionCheckEnabled;

    [self applyViewerSettings];
}


- (void)importAnnotationCommand:(NSString *)xfdfCommand initialLoad:(BOOL)initialLoad
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
    
    PTAnnotationManager * const annotationManager = documentViewController.toolManager.annotationManager;
    
    const BOOL updateSuccess = [annotationManager updateAnnotationsWithXFDFCommand:xfdfCommand
                                                                             error:&error];
    if (!updateSuccess || error) {
        @throw [NSException exceptionWithName:NSGenericException reason:error.localizedFailureReason userInfo:error.userInfo];
    }
}

-(void)setAnnotationManagerUndoMode:(NSString *)annotationManagerUndoMode
{
    _annotationManagerUndoMode = [annotationManagerUndoMode copy];
    
    [self applyViewerSettings];
}

-(void)setAnnotationManagerEditMode:(NSString *)annotationManagerEditMode
{
    _annotationManagerEditMode = [annotationManagerEditMode copy];
    
    [self applyViewerSettings];
}

#pragma mark - Toolbar

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

- (void)setHideViewModeItems:(NSArray<NSString *> *)hideViewModeItems
{
    _hideViewModeItems = [hideViewModeItems copy];

    [self applyViewerSettings];
}

- (void)setHideThumbnailsViewItems:(NSArray<NSString *> *)hideThumbnailsViewItems
{
    _hideThumbnailsViewItems = [hideThumbnailsViewItems copy];

    [self applyViewerSettings];
}

- (void)setTopAppNavBarRightBar:(NSArray<NSString *> *)topAppNavBarRightBar
{
    _topAppNavBarRightBar = [topAppNavBarRightBar copy];
    
    [self applyViewerSettings];
}

- (void)setBottomToolbar:(NSArray<NSString *> *)bottomToolbar
{
    _bottomToolbar = [bottomToolbar copy];
    
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

- (void)setAnnotationToolbarItemEnabled:(NSString *)itemId enable:(BOOL)enable
{
    if ([self.documentViewController isKindOfClass:[PTDocumentController class]]) {
        PTDocumentController *controller = (PTDocumentController *) self.documentViewController;
        Class toolClass = [[self class] toolClassForKey:itemId];

        if (toolClass != Nil) {
            // default toolbar button
            for (PTToolGroup *toolGroup in controller.toolGroupManager.groups) {
                for (UIBarButtonItem *item in toolGroup.barButtonItems) {
                    if ([item isKindOfClass:[PTToolBarButtonItem class]]) {
                        PTToolBarButtonItem *toolItem = (PTToolBarButtonItem *)item;
                        
                        if ([toolItem.toolClass isEqual:toolClass]) {
                            toolItem.enabled = enable;
                        }
                    }
                }
            }
        } else {
            // custom toolbar button
            NSNumber *const itemTag = _annotationToolbarItemKeyMap[itemId];
            
            if (itemTag) {
                for (PTToolGroup *toolGroup in controller.toolGroupManager.groups) {
                    for (UIBarButtonItem *item in toolGroup.barButtonItems) {
                        if (item.tag == itemTag.integerValue) {
                            item.enabled = enable;
                        }
                    }
                }
            }
        }
    }
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

# pragma mark - Overflow Menu Button

- (void)setOverflowMenuButtonPath:(NSString *)overflowMenuButtonPath
{
    _overflowMenuButtonPath = overflowMenuButtonPath;
    
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

-(void)setPresetsToolbarHidden:(BOOL)presetsToolbarHidden
{
    _presetsToolbarHidden = presetsToolbarHidden;
    
    [self applyViewerSettings];
}


#pragma mark - Document Slider

- (void)setDocumentSliderEnabled:(BOOL)documentSliderEnabled
{
    _documentSliderEnabled = documentSliderEnabled;
    
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

#pragma mark - Keyboard shortcuts
- (void)setKeyboardShortcutsEnabled:(BOOL)keyboardShortcutsEnabled
{
    _keyboardShortcutsEnabled = keyboardShortcutsEnabled;
}

- (void)setAutoSaveEnabled:(BOOL)autoSaveEnabled
{
    _autoSaveEnabled = autoSaveEnabled;
    
    [self applyViewerSettings];
}

#pragma mark - Enable Anti Aliasing 
- (void)setEnableAntialiasing:(BOOL)enableAntialiasing
{
    _enableAntialiasing = enableAntialiasing;
    PTPDFViewCtrl* pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    if (pdfViewCtrl) {
        @try{
            [pdfViewCtrl SetAntiAliasing:enableAntialiasing];
        } @catch (NSException *exception) {
            NSLog(@"Exception: %@, %@", exception.name, exception.reason);
        }
    }

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

- (void)setImageInReflowEnabled:(BOOL)imageInReflowEnabled
{
   _imageInReflowEnabled = imageInReflowEnabled;

   [self applyViewerSettings];
}

- (void)reflowOrientation:(NSString*)reflowOrientation
{
    _reflowOrientation = [reflowOrientation copy];
    
    [self applyViewerSettings];
}

- (void)setSelectAnnotationAfterCreation:(BOOL)selectAnnotationAfterCreation
{
    _selectAnnotationAfterCreation = selectAnnotationAfterCreation;
    
    [self applyViewerSettings];
}

- (void)setAutoResizeFreeTextEnabled:(BOOL)autoResizeFreeTextEnabled
{
    _autoResizeFreeTextEnabled = autoResizeFreeTextEnabled;
    
    [self applyViewerSettings];
}

- (void)setReplyReviewStateEnabled:(BOOL)replyReviewStateEnabled
{
    _replyReviewStateEnabled = replyReviewStateEnabled;

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

#pragma mark - viewer settings

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
    
    // Auto resize free text enabled.
    toolManager.autoResizeFreeTextEnabled = self.autoResizeFreeTextEnabled;
    
    // Sticky note pop up.
    toolManager.textAnnotationOptions.opensPopupOnTap = ![self.overrideBehavior containsObject:PTStickyNoteShowPopUpKey];
    
    // Auto save.
    documentViewController.automaticallySavesDocument = self.autoSaveEnabled;
    
    // Top toolbar.
    const BOOL shouldHideNavigationBar = (self.hideTopAppNavBar || self.hideTopToolbars);
    documentViewController.hidesNavigationBar = !shouldHideNavigationBar;
    documentViewController.navigationController.navigationBarHidden = shouldHideNavigationBar;
    
    // Bottom toolbar.
    const BOOL shouldHideBottomBar = !self.bottomToolbarEnabled;
    documentViewController.hidesBottomBar = !shouldHideBottomBar;
    documentViewController.navigationController.toolbarHidden = shouldHideNavigationBar;
    
    documentViewController.hidesControlsOnTap = self.hideToolbarsOnTap;
    
    // Scrollbars.
    [self applyScrollbarVisibility:documentViewController];
    
    // Document slider.
    ((PTDocumentController*)documentViewController).documentSliderEnabled = self.documentSliderEnabled;
    
    // Re-apply scrollbar visibility.
    [self applyScrollbarVisibility:documentViewController];
    
    // Page indicator.
    documentViewController.pageIndicatorEnabled = self.pageIndicatorEnabled;
    
    // Page change on tap.
    documentViewController.changesPageOnTap = self.pageChangeOnTap;
    
    // Fit mode.
    if ([self.fitMode isEqualToString:PTFitPageFitModeKey] || (self.fitPolicy == 2)) {
        [pdfViewCtrl SetPageViewMode:e_trn_fit_page];
        [pdfViewCtrl SetPageRefViewMode:e_trn_fit_page];
    }
    else if ([self.fitMode isEqualToString:PTFitWidthFitModeKey] || (self.fitPolicy == 0)) {
        [pdfViewCtrl SetPageViewMode:e_trn_fit_width];
        [pdfViewCtrl SetPageRefViewMode:e_trn_fit_width];
    }
    else if ([self.fitMode isEqualToString:PTFitHeightFitModeKey] || (self.fitPolicy == 1)) {
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
    
    toolManager.signatureAnnotationOptions.storeNewSignature = self.storeNewSignature;
    
    toolManager.signatureAnnotationOptions.signSignatureFieldsWithStamps = self.signSignatureFieldsWithStamps;
    
    toolManager.signatureAnnotationOptions.maxSignatureCount = self.maxSignatureCount;

    // Annotation permission check
    toolManager.annotationPermissionCheckEnabled = self.annotationPermissionCheckEnabled;
    
    if (@available(iOS 13.4, *)) {
        toolManager.widgetAnnotationOptions.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    
    // Follow system dark mode.
    if (@available(iOS 13.0, *)) {
        UIViewController * const viewController = self.viewController.navigationController;
        viewController.overrideUserInterfaceStyle = (self.followSystemDarkMode ?
                                                     UIUserInterfaceStyleUnspecified :
                                                     UIUserInterfaceStyleLight);
        
        UIWindow * const window = self.window;
        if (window) {
            window.overrideUserInterfaceStyle = (self.followSystemDarkMode ?
                                                 UIUserInterfaceStyleUnspecified :
                                                 UIUserInterfaceStyleLight);
        }
    }
    
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
    
    // Disable editing by annotation type.
    [self setAnnotationEditingPermission:self.uneditableAnnotationTypes toValue:NO documentViewController:documentViewController];
    
    if ([documentViewController isKindOfClass:[PTDocumentController class]]) {
        PTDocumentController *documentController = (PTDocumentController *)documentViewController;
        [self applyDocumentControllerSettings:documentController];
    }
    
    // View Mode items
    for (NSString * viewModeItemString in self.hideViewModeItems) {
        if ([viewModeItemString isEqualToString:PTViewModeColorModeKey]) {
            documentViewController.settingsViewController.colorModeLightHidden = YES;
            documentViewController.settingsViewController.colorModeDarkHidden = YES;
            documentViewController.settingsViewController.colorModeSepiaHidden = YES;
        } else if ([viewModeItemString isEqualToString:PTViewModeRotationKey]) {
            documentViewController.settingsViewController.pageRotationHidden = YES;
        } else if ([viewModeItemString isEqualToString:PTViewModeCropKey]) {
            documentViewController.settingsViewController.cropPagesHidden = YES;
        } else if ([viewModeItemString isEqualToString:PTViewModeReaderModeSettingsKey]) {
            documentViewController.automaticallyHidesReflowSettingsButton = NO;
            documentViewController.reflowSettingsButtonHidden = YES;
        }
    }

    NSMutableArray *addPagesItems = [documentViewController.thumbnailsViewController.addPagesViewController.items mutableCopy];
    // Thumbnails view items
    for (NSString * thumbnailsItemString in self.hideThumbnailsViewItems) {
        if ([thumbnailsItemString isEqualToString:PTThumbnailsViewInsertPagesKey]) {
            [addPagesItems removeObject:documentViewController.thumbnailsViewController.addPagesViewController.addBlankPagesButtonItem];
        } else if ([thumbnailsItemString isEqualToString:PTThumbnailsViewExportPagesKey]) {
            documentViewController.thumbnailsViewController.exportPagesEnabled = NO;
        } else if ([thumbnailsItemString isEqualToString:PTThumbnailsViewDuplicatePagesKey]) {
            documentViewController.thumbnailsViewController.duplicatePagesEnabled = NO;
        } else if ([thumbnailsItemString isEqualToString:PTThumbnailsViewRotatePagesKey]) {
            documentViewController.thumbnailsViewController.rotatePagesEnabled = NO;
        } else if ([thumbnailsItemString isEqualToString:PTThumbnailsViewDeletePagesKey]) {
            documentViewController.thumbnailsViewController.deletePagesEnabled = NO;
        } else if ([thumbnailsItemString isEqualToString:PTThumbnailsViewInsertFromImageKey]) {
            [addPagesItems removeObject:documentViewController.thumbnailsViewController.addPagesViewController.addImagePageButtonItem];
        } else if ([thumbnailsItemString isEqualToString:PTThumbnailsViewInsertFromPhotoKey]) {
            [addPagesItems removeObject:documentViewController.thumbnailsViewController.addPagesViewController.addCameraImagePageButtonItem];
        } else if ([thumbnailsItemString isEqualToString:PTThumbnailsViewInsertFromDocumentKey]) {
            [addPagesItems removeObject:documentViewController.thumbnailsViewController.addPagesViewController.addDocumentPagesButtonItem];
        } else if ([thumbnailsItemString isEqualToString:PTThumbnailsViewInsertFromScannerKey]) {
            [addPagesItems removeObject:documentViewController.thumbnailsViewController.addPagesViewController.addScannedPageButtonItem];
        }
    }
    if([addPagesItems count] == 0){
        documentViewController.thumbnailsViewController.addPagesEnabled = NO;
    }
    documentViewController.thumbnailsViewController.addPagesViewController.items = [addPagesItems copy];

    // Leading Nav Icon.
    [self applyLeadingNavButton];
    
    // Overflow Menu Button Icon
    [self applyOverflowMenuButton];
    
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

    // Set Annotation List Editing 
     documentViewController.navigationListsViewController.annotationViewController.readonly = !self.annotationsListEditingEnabled;
    
    // Exclude annotation types from annotation list.
    [self excludeAnnotationListTypes:self.excludedAnnotationListTypes documentViewController:documentViewController];
    
    // Hanlde displays of various sizes
    documentViewController.alwaysShowNavigationListsAsModal = !self.showNavigationListAsSidePanelOnLargeDevices;
    
    // Data Usage
    [documentViewController.httpRequestOptions RestrictDownloadUsage: self.restrictDownloadUsage];
    
    // Set User Bookmark List Editing
    documentViewController.navigationListsViewController.bookmarkViewController.readonly = !self.userBookmarksListEditingEnabled;
    
    // Image in reflow mode enabled.
    // TODO: When supported use below
    // Instead use documentViewController.reflowViewController.reflowManager.includeImages = self.ImageInReflowEnabled;
    
    // Reflow Orientation
    if ([PTReflowOrientationHorizontalKey isEqualToString:self.reflowOrientation]) {
        documentViewController.reflowViewController.scrollingDirection = PTReflowViewControllerScrollingDirectionHorizontal;
    } else if ([PTReflowOrientationVerticalKey isEqualToString:self.reflowOrientation]) {
        documentViewController.reflowViewController.scrollingDirection = PTReflowViewControllerScrollingDirectionVertical;
    }
    
    // Set Default Eraser Type
    [self applyDefaultEraserType:self.defaultEraserType documentViewController:documentViewController];
    
    // Show Quick Navigation Button
    documentViewController.navigationHistoryEnabled = self.showQuickNavigationButton;
    
    // Annotation Manager Edit Mode
    if ([PTAnnotationManagerEditModeOwn isEqualToString:self.annotationManagerEditMode]) {
        documentViewController.toolManager.annotationManager.annotationEditMode = PTAnnotationModeEditOwn;
        documentViewController.toolManager.annotationAuthorCheckEnabled = YES;
        documentViewController.toolManager.annotationPermissionCheckEnabled = YES;
    } else if ([PTAnnotationManagerEditModeAll isEqualToString:self.annotationManagerEditMode]) {
        documentViewController.toolManager.annotationManager.annotationEditMode = PTAnnotationModeEditAll;
        documentViewController.toolManager.annotationAuthorCheckEnabled = YES;
        documentViewController.toolManager.annotationPermissionCheckEnabled = YES;
    }

    if ([documentViewController.toolManager.annotationManager isKindOfClass:RNTPTAnnotationManager.class]) {
        RNTPTAnnotationManager *annotationManager = (RNTPTAnnotationManager*)documentViewController.toolManager.annotationManager;
        annotationManager.replyReviewStateEnabled = self.replyReviewStateEnabled;
    }

    // Enable/disable restoring state (last read page).
    documentViewController.viewStatePersistenceEnabled = self.saveStateEnabled;
    [NSUserDefaults.standardUserDefaults setBool:self.saveStateEnabled
                                          forKey:@"gotoLastPage"];
    
    
    // Signature colors
    if (self.signatureColors) {
        NSMutableArray<UIColor *> *colorArray = [[NSMutableArray alloc] init];

        for (NSDictionary *color in self.signatureColors) {
            NSNumber *red = color[PTColorRedKey];
            NSNumber *green = color[PTColorGreenKey];
            NSNumber *blue = color[PTColorBlueKey];

            [colorArray addObject:[UIColor colorWithRed:[red doubleValue] / 255
                                                  green:[green doubleValue] / 255
                                                   blue:[blue doubleValue] / 255
                                                  alpha:1.0]];
        }

        toolManager.signatureAnnotationOptions.signatureColors = [colorArray copy];
    }
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

- (void) applyOverflowMenuButton
{
    if (self.overflowMenuButtonPath != nil) {
        UIImage *overflowImage = [UIImage imageNamed:self.overflowMenuButtonPath];
        if (overflowImage != nil) {
            self.currentDocumentViewController.moreItemsButtonItem.image = overflowImage;
        }
    }
}

- (void)applyDocumentControllerSettings:(PTDocumentController *)documentController
{
    PTToolGroupManager *toolGroupManager = documentController.toolGroupManager;
    
    const BOOL shouldHideToolGroupToolbar = self.hideTopToolbars;
    documentController.toolGroupsEnabled = !shouldHideToolGroupToolbar;
    documentController.hidesToolGroupToolbar = !shouldHideToolGroupToolbar;
    if (shouldHideToolGroupToolbar) {
        documentController.toolGroupToolbarHidden = YES;
    }
    
    documentController.toolGroupToolbar.itemsAlignment = PTToolGroupToolbarAlignmentTrailing;
    documentController.toolGroupToolbar.presetsToolbarEnabled = !self.presetsToolbarHidden;
    
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
            }
            
            if (toolGroups.count == 1) {
                documentController.toolGroupIndicatorView.hidden = YES;
            }
        } else {
            documentController.toolGroupManager.selectedGroup = documentController.toolGroupManager.viewItemGroup;
            documentController.toolGroupIndicatorView.hidden = YES;
        }

        if (self.initialToolbar.length > 0) {
           NSMutableArray *toolGroupTitles = [NSMutableArray array];
            NSMutableArray *toolGroupIdentifiers = [NSMutableArray array];

            for (PTToolGroup *toolGroup in documentController.toolGroupManager.groups) {
                [toolGroupTitles addObject:toolGroup.title.lowercaseString];
                [toolGroupIdentifiers addObject:toolGroup.identifier.lowercaseString];
            }

            NSInteger initialToolbarIndex = [toolGroupIdentifiers indexOfObject:self.initialToolbar.lowercaseString];

            if (initialToolbarIndex == NSNotFound) {
                // not found in identifiers, check titles
                initialToolbarIndex = [toolGroupTitles indexOfObject:self.initialToolbar.lowercaseString];
            }

            PTToolGroup *matchedDefaultGroup = [self toolGroupForKey:self.initialToolbar toolGroupManager:documentController.toolGroupManager];
            if (matchedDefaultGroup != nil) {
                // use a default group if its key is found
                [documentController.toolGroupManager setSelectedGroup:matchedDefaultGroup];
                [documentController.toolGroupIndicatorView.button setTitle:matchedDefaultGroup.title forState:UIControlStateNormal];
                if (@available(iOS 13.0, *)) {
                    documentController.toolGroupIndicatorView.button.largeContentImage = matchedDefaultGroup.image;
                }
                return;
            }

            if (initialToolbarIndex != NSNotFound) {
                [documentController.toolGroupManager setSelectedGroupIndex:initialToolbarIndex];
            }
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
    
    // Handle topAppNavBarRightBar.
    if (self.topAppNavBarRightBar && self.topAppNavBarRightBar.count >= 0) {
        
        NSMutableArray *rightBarItems = [[NSMutableArray alloc] init];
        
        for (NSString *rightBarItemString in self.topAppNavBarRightBar) {
            UIBarButtonItem *rightBarItem = [self itemForButton:rightBarItemString
                                               inViewController:documentController];
            if (rightBarItem) {
                [self removeLeftBarButtonItem:rightBarItem
                                inViewController:documentController];
                [self removeToolbarButtonItem:rightBarItem
                                inViewController:documentController];
                [self removeRightBarButtonItem:rightBarItem
                                inViewController:documentController];
                
                [rightBarItems addObject:rightBarItem];
            }
        }
        NSArray * reversedArray = [[rightBarItems reverseObjectEnumerator] allObjects];
        
        documentController.navigationItem.rightBarButtonItems = reversedArray;
    }
    
    // Handle bottomToolbar.
    if (self.bottomToolbar && self.bottomToolbar.count >= 0) {
        NSMutableArray<UIBarButtonItem *> *bottomToolbarItems = [[NSMutableArray alloc] init];
        
        for (NSString *bottomToolbarString in self.bottomToolbar) {
            UIBarButtonItem *bottomToolbarItem = [self itemForButton:bottomToolbarString
                                                    inViewController:documentController];
            if (bottomToolbarItem) {
                [self removeLeftBarButtonItem:bottomToolbarItem
                                inViewController:documentController];
                [self removeRightBarButtonItem:bottomToolbarItem
                                inViewController:documentController];
                [self removeToolbarButtonItem:bottomToolbarItem
                                inViewController:documentController];
                
                [bottomToolbarItems addObject:bottomToolbarItem];
                
                // the spacing item between elements
                UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                       target:nil
                                                                                       action:nil];
                [bottomToolbarItems addObject:space];
            }
        }
        
        // remove last spacing if there is at least 1 element
        if ([bottomToolbarItems count] > 0) {
            [bottomToolbarItems removeLastObject];
        }
        documentController.toolbarItems = [bottomToolbarItems copy];
    }
    
    // Override action of overridden toolbar button items
    if (self.overrideToolbarButtonBehavior) {
        for (NSString *buttonString in self.overrideToolbarButtonBehavior) {
            UIBarButtonItem *toolbarItem = [self itemForButton:buttonString
                                                 inViewController:documentController];
            
            NSString *actionName = [NSString stringWithFormat:@"overriddenPressed_%@",
                                    buttonString];
            const SEL selector = NSSelectorFromString(actionName);

            RNTPT_addMethod([documentController class], selector, ^(id documentController) {
                if ([documentController isKindOfClass:[RNTPTDocumentController class]]) {
                    RNTPTDocumentController *controller = documentController;
                    
                    if ([controller.delegate respondsToSelector:@selector(rnt_documentViewControllerToolbarButtonPressed:buttonString:)]) {
                        [controller.delegate rnt_documentViewControllerToolbarButtonPressed:controller
                                                                               buttonString:buttonString];
                    }
                } else if ([documentController isKindOfClass:[RNTPTCollaborationDocumentController class]]) {
                    RNTPTCollaborationDocumentController *controller = documentController;
                    
                    if ([controller.delegate respondsToSelector:@selector(rnt_documentViewControllerToolbarButtonPressed:buttonString:)]) {
                        [controller.delegate rnt_documentViewControllerToolbarButtonPressed:controller
                                                                               buttonString:buttonString];
                    }
                }
            });
            
            toolbarItem.action = selector;
        }
    }
}

- (PTDefaultAnnotationToolbarKey)keyForToolGroup:(PTToolGroup *)toolGroup toolGroupManager:(PTToolGroupManager *)toolGroupManager
{
    if ([toolGroup isEqual:toolGroupManager.viewItemGroup]) {
        return PTAnnotationToolbarView;
    } else if ([toolGroup isEqual:toolGroupManager.annotateItemGroup]) {
        return PTAnnotationToolbarAnnotate;
    } else if ([toolGroup isEqual:toolGroupManager.drawItemGroup]) {
        return PTAnnotationToolbarDraw;
    } else if ([toolGroup isEqual:toolGroupManager.insertItemGroup]) {
        return PTAnnotationToolbarInsert;
    } else if ([toolGroup isEqual:toolGroupManager.fillAndSignItemGroup]) {
        return PTAnnotationToolbarFillAndSign;
    } else if ([toolGroup isEqual:toolGroupManager.prepareFormItemGroup]) {
        return PTAnnotationToolbarPrepareForm;
    } else if ([toolGroup isEqual:toolGroupManager.measureItemGroup]) {
        return PTAnnotationToolbarMeasure;
    } else if ([toolGroup isEqual:toolGroupManager.redactItemGroup]) {
        return PTAnnotationToolbarRedaction;
    } else if ([toolGroup isEqual:toolGroupManager.pensItemGroup]) {
        return PTAnnotationToolbarPens;
    } else if ([toolGroup isEqual:toolGroupManager.favoritesItemGroup]) {
        return PTAnnotationToolbarFavorite;
    }
    
    return nil;
}

- (PTToolGroup *)toolGroupForKey:(PTDefaultAnnotationToolbarKey)key toolGroupManager:(PTToolGroupManager *)toolGroupManager
{
    NSDictionary<PTDefaultAnnotationToolbarKey, PTToolGroup *> *toolGroupMap = @{
        PTAnnotationToolbarView: toolGroupManager.viewItemGroup,
        PTAnnotationToolbarAnnotate: toolGroupManager.annotateItemGroup,
        PTAnnotationToolbarDraw: toolGroupManager.drawItemGroup,
        PTAnnotationToolbarInsert: toolGroupManager.insertItemGroup,
        PTAnnotationToolbarFillAndSign: toolGroupManager.fillAndSignItemGroup,
        PTAnnotationToolbarPrepareForm: toolGroupManager.prepareFormItemGroup,
        PTAnnotationToolbarMeasure: toolGroupManager.measureItemGroup,
        PTAnnotationToolbarRedaction: toolGroupManager.redactItemGroup, 
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
    NSArray<id> *toolbarItems = dictionary[PTAnnotationToolbarKeyItems];
    
    UIImage *toolbarImage = nil;
    if (toolbarIcon) {
        PTToolGroup *defaultGroup = [self toolGroupForKey:toolbarIcon
                                         toolGroupManager:toolGroupManager];
        toolbarImage = defaultGroup.image;
    }
    
    NSMutableArray<UIBarButtonItem *> *barButtonItems = [NSMutableArray array];
    
    for (id toolbarItemValue in toolbarItems) {
        if ([toolbarItemValue isKindOfClass:[NSString class]]) {
            NSString * const toolbarItemKey = (NSString *)toolbarItemValue;
            
            Class toolClass = [[self class] toolClassForKey:toolbarItemKey];
            if (!toolClass) {
                continue;
            }
            
            UIBarButtonItem *item = [toolGroupManager createItemForToolClass:toolClass];
            if (item) {
                [barButtonItems addObject:item];
            }
        }
        else if ([toolbarItemValue isKindOfClass:[NSDictionary class]]) {
            NSDictionary<NSString *, id> * const toolbarItem = (NSDictionary *)toolbarItemValue;
            
            NSString * const toolbarItemId = toolbarItem[PTAnnotationToolbarItemKeyId];
            NSString * const toolbarItemName = toolbarItem[PTAnnotationToolbarItemKeyName];
            NSString * const toolbarItemIconName = toolbarItem[PTAnnotationToolbarItemKeyIcon];
            
            // An item id, name, and icon are required.
            if (toolbarItemId.length == 0 ||
                !toolbarItemName ||
                toolbarItemIconName.length == 0) {
                continue;
            }
            
            UIImage * const toolbarItemIcon = [self imageForImageName:toolbarItemIconName];
            // NOTE: Use the image-based initializer to avoid showing the title (safe to set the title afterwards though).
            PTSelectableBarButtonItem * const item = [[PTSelectableBarButtonItem alloc]                                                                 initWithImage:toolbarItemIcon
                                                      style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(customToolGroupToolbarItemPressed:)];
            item.title = toolbarItemName;
            
            NSAssert(toolbarItemId != nil, @"Expected a toolbar item id");
            
            NSInteger itemTag = 0;
            
            // Check if this id has already been mapped before.
            NSNumber * const idNumberValue = _annotationToolbarItemKeyMap[toolbarItemId];
            if (idNumberValue) {
                // Use existing mapped integer tag.
                itemTag = idNumberValue.integerValue;
            } else {
                // We need to map this item id key to an integer.
                _annotationToolbarItemCounter++;
                
                itemTag = _annotationToolbarItemCounter;
                _annotationToolbarItemKeyMap[toolbarItemId] = @(itemTag);
            }
            
            item.tag = itemTag;
            
            [barButtonItems addObject:item];
        }
    }
    
    PTToolGroup *toolGroup = [PTToolGroup groupWithTitle:toolbarName
                                                   image:toolbarImage
                                          barButtonItems:[barButtonItems copy]];
    toolGroup.identifier = toolbarId;

    return toolGroup;
}

- (void)customToolGroupToolbarItemPressed:(PTSelectableBarButtonItem *)toolbarItem
{
    const NSInteger itemTag = toolbarItem.tag;
    
    // Find the corresponding item key string value for this item tag number.
    __block NSString *itemKey = nil;
    [_annotationToolbarItemKeyMap enumerateKeysAndObjectsUsingBlock:^(NSString * const currentItemKey,
                                                                      NSNumber * const currentItemTagNumber,
                                                                      BOOL * const stop) {
        const NSInteger currentItemTag = currentItemTagNumber.integerValue;
        if (itemTag == currentItemTag) {
            itemKey = currentItemKey;
            *stop = YES;
        }
    }];
    
    if (itemKey) {
        [self.delegate annotationToolbarItemPressed:self withKey:itemKey];
    }
}

- (void)setCurrentToolbar:(NSString *)toolbarTitle
{
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    if ([documentViewController isKindOfClass:[PTDocumentController class]]) {
        PTDocumentController *documentController = (PTDocumentController *)documentViewController;
        if (toolbarTitle.length > 0) {
            NSMutableArray *toolGroupTitles = [NSMutableArray array];
            NSMutableArray *toolGroupIdentifiers = [NSMutableArray array];

            for (PTToolGroup *toolGroup in documentController.toolGroupManager.groups) {
                [toolGroupTitles addObject:toolGroup.title.lowercaseString];
                [toolGroupIdentifiers addObject:toolGroup.identifier.lowercaseString];
            }

            NSInteger toolbarIndex = [toolGroupIdentifiers indexOfObject:toolbarTitle.lowercaseString];
            if (toolbarIndex == NSNotFound) {
                // not found in identifiers, check titles
                toolbarIndex = [toolGroupTitles indexOfObject:toolbarTitle.lowercaseString];
            }

            PTToolGroup *matchedDefaultGroup = [self toolGroupForKey:toolbarTitle toolGroupManager:documentController.toolGroupManager];
            if (matchedDefaultGroup != nil) {
                // use a default group if its key is found
                [documentController.toolGroupManager setSelectedGroup:matchedDefaultGroup];
                return;
            }

            if (toolbarIndex != NSNotFound) {
                [documentController.toolGroupManager setSelectedGroupIndex:toolbarIndex];
            }
        }
    }
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

- (void)applyForcedAppTheme
{
    // Force App Theme
    if (@available(iOS 13.0, *)) {
        if ([self.forceAppTheme isEqualToString:PTAppDarkTheme]) {
            UIViewController * const viewController = self.viewController.navigationController;
            viewController.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
            
            UIWindow * const window = self.window;
            if (window) {
                window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
            }
        } else if ([self.forceAppTheme isEqualToString:PTAppLightTheme]) {
            UIViewController * const viewController = self.viewController.navigationController;
            viewController.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            
            UIWindow * const window = self.window;
            if (window) {
                window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
            }
        }
    }
}

- (void)setPageBorderVisibility:(BOOL)pageBorderVisibility
{
    PTPDFViewCtrl *pdfViewCtrl = self.documentViewController.pdfViewCtrl;
    [pdfViewCtrl SetPageBorderVisibility:pageBorderVisibility];
    [pdfViewCtrl Update:YES];
}

- (void)setPageTransparencyGrid:(BOOL)pageTransparencyGrid
{
    PTPDFViewCtrl *pdfViewCtrl = self.documentViewController.pdfViewCtrl;
    [pdfViewCtrl SetPageTransparencyGrid:pageTransparencyGrid];
    [pdfViewCtrl Update:YES];
}

- (void)setDefaultPageColor:(NSDictionary *)defaultPageColor
{
    if (defaultPageColor) {
        NSArray *keyList = defaultPageColor.allKeys;
        
        BOOL containsValidKeys = [keyList containsObject:PTColorRedKey] &&
        [keyList containsObject:PTColorGreenKey] &&
        [keyList containsObject:PTColorBlueKey];
        NSAssert(containsValidKeys,
                 @"default page color does not have red, green or blue keys");
        
        if (!containsValidKeys) {
            return;
        }
         
        PTPDFViewCtrl *pdfViewCtrl = self.documentViewController.pdfViewCtrl;
            
        [pdfViewCtrl SetDefaultPageColor:[defaultPageColor[PTColorRedKey] unsignedCharValue] g:[defaultPageColor[PTColorGreenKey] unsignedCharValue]
                b:[defaultPageColor[PTColorBlueKey] unsignedCharValue]];
            
        [pdfViewCtrl Update:YES];
    }
}

- (void)setBackgroundColor:(NSDictionary *)backgroundColor
{
    if (backgroundColor) {
        NSArray *keyList = backgroundColor.allKeys;
        
        BOOL containsValidKeys = [keyList containsObject:PTColorRedKey] &&
        [keyList containsObject:PTColorGreenKey] &&
        [keyList containsObject:PTColorBlueKey];
        NSAssert(containsValidKeys,
                 @"background color does not have red, green or blue keys");
        
        if (!containsValidKeys) {
            return;
        }
            
        PTPDFViewCtrl *pdfViewCtrl = self.documentViewController.pdfViewCtrl;
            
        [pdfViewCtrl
         SetBackgroundColor:[backgroundColor[PTColorRedKey] unsignedCharValue] g:[backgroundColor[PTColorGreenKey] unsignedCharValue] b:[backgroundColor[PTColorBlueKey] unsignedCharValue] a:255];
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

- (void)setDocumentExtension:(NSString *)documentExtension
{
    _documentExtension = [documentExtension copy];
    
    [self applyViewerSettings];
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
            toolManager.annotateOnReflowEnabled = !self.readOnly;
        }
    }
    else
    {
        toolManager.readonly = self.readOnly;
        toolManager.annotateOnReflowEnabled = !self.readOnly;
    }
    
    documentViewController.thumbnailsViewController.editingEnabled = !self.readOnly;
}

- (void)setAnnotationsListEditingEnabled:(BOOL)annotationsListEditingEnabled
{
    _annotationsListEditingEnabled = annotationsListEditingEnabled;
    
    [self applyViewerSettings];
}

-(void)setUserBookmarksListEditingEnabled:(BOOL)userBookmarksListEditingEnabled
{
    _userBookmarksListEditingEnabled = userBookmarksListEditingEnabled;
    
    [self applyViewerSettings];
}

- (void)setSaveStateEnabled:(BOOL)enabled
{
    _saveStateEnabled = enabled;
    
    [self applyViewerSettings];
}

- (void)setOpenUrlCachePath:(NSString *)openUrlCachePath
{
    NSURL *cacheDirectoryURL = [NSURL fileURLWithPath:openUrlCachePath isDirectory:YES];
    
    if ([NSFileManager.defaultManager createDirectoryAtURL:cacheDirectoryURL withIntermediateDirectories:YES attributes:nil error:nil]) {
        self.documentViewController.documentManager.documentCacheDirectoryURL = cacheDirectoryURL;
    }
}

#pragma mark - Fit mode

- (void)setFitMode:(NSString *)fitMode
{
    _fitMode = [fitMode copy];
    
    [self applyViewerSettings];
}

#pragma mark - Fit Policy

- (void)setFitPolicy:(int)fitPolicy
{
    _fitPolicy = fitPolicy;
    
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

#pragma mark - Signatures

- (void)setShowSavedSignatures:(BOOL)showSavedSignatures
{
    _showSavedSignatures = showSavedSignatures;
    
    [self applyViewerSettings];
}

- (void)setStoreNewSignature:(BOOL)storeNewSignature
{
    _storeNewSignature = storeNewSignature;
    
    [self applyViewerSettings];
}

-(void)setSignSignatureFieldsWithStamps:(BOOL)signSignatureFieldsWithStamps
{
    _signSignatureFieldsWithStamps = signSignatureFieldsWithStamps;
    
    [self applyViewerSettings];
}

- (void)setMaxSignatureCount:(int)maxSignatureCount
{
    _maxSignatureCount = maxSignatureCount;
    
    [self applyViewerSettings];
}

- (NSArray *)getSavedSignatures
{
    PTSignaturesManager *signaturesManager = [[PTSignaturesManager alloc] init];
    signaturesManager.showDefaultSignature = self.showSavedSignatures;
    NSUInteger numOfSignatures = [signaturesManager numberOfSavedSignatures];
    NSMutableArray<NSString*> *signatures = [[NSMutableArray alloc] initWithCapacity:numOfSignatures];
    
    for (NSInteger i = 0; i < numOfSignatures; i++) {
        signatures[i] = [[signaturesManager savedSignatureAtIndex:i] GetFileName];
    }

    return signatures;
}

-(NSString *)getSavedSignatureFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = paths[0];

    NSString* fullPath = [libraryDirectory stringByAppendingPathComponent:PTSignaturesManager_signatureDirectory];
    return fullPath;
}

# pragma mark - Dark Mode

- (void)setFollowSystemDarkMode:(BOOL)followSystemDarkMode
{
    _followSystemDarkMode = followSystemDarkMode;

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

#pragma mark - Controls

- (void)showViewSettingsFromRect:(NSDictionary *)rect
{
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    NSNumber *rectX1 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectX1Key]];
    NSNumber *rectY1 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectY1Key]];
    NSNumber *rectX2 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectX2Key]];
    NSNumber *rectY2 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectY2Key]];
    CGRect screenRect = CGRectMake([rectX1 doubleValue], [rectY1 doubleValue], [rectX2 doubleValue]-[rectX1 doubleValue], [rectY2 doubleValue]-[rectY1 doubleValue]);
    [documentViewController showSettingsFromScreenRect:screenRect];
}

- (void)showAddPagesViewFromRect:(NSDictionary *)rect
{
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    NSNumber *rectX1 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectX1Key]];
    NSNumber *rectY1 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectY1Key]];
    NSNumber *rectX2 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectX2Key]];
    NSNumber *rectY2 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectY2Key]];
    CGRect screenRect = CGRectMake([rectX1 doubleValue], [rectY1 doubleValue], [rectX2 doubleValue]-[rectX1 doubleValue], [rectY2 doubleValue]-[rectY1 doubleValue]);
    [documentViewController showAddPagesViewFromScreenRect:screenRect];
}

- (void)shareCopyfromRect:(NSDictionary *)rect withFlattening:(BOOL)flattening
{
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    NSNumber *rectX1 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectX1Key]];
    NSNumber *rectY1 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectY1Key]];
    NSNumber *rectX2 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectX2Key]];
    NSNumber *rectY2 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectY2Key]];
    CGRect screenRect = CGRectMake([rectX1 doubleValue], [rectY1 doubleValue], [rectX2 doubleValue]-[rectX1 doubleValue], [rectY2 doubleValue]-[rectY1 doubleValue]);
    [documentViewController shareCopyFromScreenRect:screenRect withFlattening:flattening];
}

#pragma mark - Zoom

- (void)setZoom:(double)zoom
{
    _zoom = zoom;
    PTPDFViewCtrl* pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    if (pdfViewCtrl) {
        [pdfViewCtrl SetZoom:zoom];
    }
}

#pragma mark - Scale

- (void)setScale:(double)scale
{
    _scale = scale;
    PTPDFViewCtrl* pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    if (pdfViewCtrl) {
        [pdfViewCtrl SetZoom:scale];
    }
}

- (void)setZoomLimits:(NSString *)zoomLimitMode minimum:(double)minimum maximum:(double)maximum
{
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    
    if ([zoomLimitMode isEqualToString:PTZoomLimitAbsoluteKey]) {
        [pdfViewCtrl SetZoomLimits:e_trn_zoom_limit_absolute Minimum:minimum Maxiumum:maximum];
    } else if ([zoomLimitMode isEqualToString:PTZoomLimitRelativeKey]) {
        [pdfViewCtrl SetZoomLimits:e_trn_zoom_limit_relative Minimum:minimum Maxiumum:maximum];
    } else if ([zoomLimitMode isEqualToString:PTZoomLimitNoneKey]) {
        [pdfViewCtrl SetZoomLimits:e_trn_zoom_limit_none Minimum:minimum Maxiumum:maximum];
    }
}

- (void)zoomWithCenter:(double)zoom x:(int)x y:(int)y
{
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    
    [pdfViewCtrl SetZoomX:x Y:y Zoom:zoom];
}

- (void)zoomToRect:(int)pageNumber rect:(NSDictionary *)rect
{
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    
    NSNumber *rectX1 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectX1Key]];
    NSNumber *rectY1 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectY1Key]];
    NSNumber *rectX2 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectX2Key]];
    NSNumber *rectY2 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectY2Key]];
    
    if (rectX1 && rectY1 && rectX2 && rectY2) {
        PTPDFRect* rect = [[PTPDFRect alloc] initWithX1:[rectX1 doubleValue] y1:[rectY1 doubleValue] x2:[rectX2 doubleValue] y2:[rectY2 doubleValue]];
        [pdfViewCtrl ShowRect:pageNumber rect:rect];
    }
}

- (void)smartZoom:(int)x y:(int)y animated:(BOOL)animated
{
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    
    [pdfViewCtrl SmartZoomX:(double)x y:(double)y animated:animated];
}

# pragma mark - Color Post Process
- (void)setColorPostProcessMode:(NSString *)colorPostProcessMode
{
    PTPDFViewCtrl *pdfViewCtrl = [[self documentViewController] pdfViewCtrl];
    if (pdfViewCtrl) {
        
        if ([colorPostProcessMode isEqualToString:PTColorPostProcessModeNoneKey]) {
            [pdfViewCtrl SetColorPostProcessMode:e_ptpostprocess_none];
        } else if ([colorPostProcessMode isEqualToString:PTColorPostProcessModeInvertKey]) {
            [pdfViewCtrl SetColorPostProcessMode:e_ptpostprocess_invert];
        } else if ([colorPostProcessMode isEqualToString:PTColorPostProcessModeGradientMapKey]) {
            [pdfViewCtrl SetColorPostProcessMode:e_ptpostprocess_gradient_map];
        } else if ([colorPostProcessMode isEqualToString:PTColorPostProcessModeNightModeKey]) {
            [pdfViewCtrl SetColorPostProcessMode:e_ptpostprocess_night_mode];
        }
    }
}

- (void)setColorPostProcessColors:(NSDictionary *)whiteColor blackColor:(NSDictionary *)blackColor
{
    PTPDFViewCtrl *pdfViewCtrl = [[self documentViewController] pdfViewCtrl];
    if (pdfViewCtrl) {
        
        UIColor *whiteUIColor = [self convertRGBAToUIColor:whiteColor];
        NSAssert(whiteUIColor, @"white color is not valid for setting post process colors");
        
        if (!whiteUIColor) {
            return;
        }
        
        UIColor *blackUIColor = [self convertRGBAToUIColor:blackColor];
        NSAssert(blackUIColor, @"black color is not valid for setting post process colors");
        
        if (!blackUIColor) {
            return;
        }
        
        [pdfViewCtrl SetColorPostProcessColors:whiteUIColor black_color:blackUIColor];
    }
}

- (UIColor *)convertRGBAToUIColor:(NSDictionary *)colorMap
{
    NSString *requiredColorKeys[4] = {PTColorRedKey, PTColorGreenKey, PTColorBlueKey, PTColorAlphaKey};
    double colorValues[4];
    NSArray *colorKeys = [colorMap allKeys];
    
    for (int i = 0; i < 4; i ++) {
        if (![colorKeys containsObject:requiredColorKeys[i]]) {
            // not alpha
            if (![requiredColorKeys[i] isEqualToString:PTColorAlphaKey]) {
                return nil;
            }
            // alpha
            colorValues[i] = (double)1;
            continue;
        }
        
        double value = (double)[colorMap[requiredColorKeys[i]] intValue] / 255;
        if (value < 0 || value > 1) {
            return nil;
        }
        
        colorValues[i] = value;
    }
    
    return [UIColor colorWithRed:colorValues[0] green:colorValues[1] blue:colorValues[2] alpha:colorValues[3]];
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
        PTAnnotationCreateRubberStampToolKey: @(PTExtendedAnnotTypeStamp),
        PTAnnotationCreateRedactionToolKey : @(PTExtendedAnnotTypeRedact),
        PTAnnotationCreateLinkToolKey : @(PTExtendedAnnotTypeLink),
        PTAnnotationCreateLinkTextToolKey: @(PTExtendedAnnotTypeLink),
        PTFormCreateRadioFieldToolKey: @(PTExtendedAnnotTypeRadioButton),
        PTFormCreateListBoxFieldToolKey : @(PTExtendedAnnotTypeListBox),
        PTFormCreateSignatureFieldToolKey: @(PTExtendedAnnotTypeSignatureField),
        PTFormCreateTextFieldToolKey : @(PTExtendedAnnotTypeTextField),
        PTFormCreateCheckboxFieldToolKey : @(PTExtendedAnnotTypeCheckBox),
        PTFormCreateComboBoxFieldToolKey : @(PTExtendedAnnotTypeComboBox),
        PTAnnotationCreateRedactionTextToolKey : @(PTExtendedAnnotTypeTextRedact),
//        PTAnnotationEditToolKey: @(),
//        PTMultiSelectToolKey: @(),
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == TabChangedContext) {
        if ([self.delegate respondsToSelector:@selector(tabChanged:currentTab:)]) {
            PTDocumentTabItem *selectedItem = self.tabbedDocumentViewController.tabManager.selectedItem;
            if (selectedItem != nil) {
                NSURL *currentTab = selectedItem.documentURL ?: selectedItem.sourceURL;
                [self.delegate tabChanged:self currentTab:[currentTab absoluteString]];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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
        
        if ([self.delegate respondsToSelector:@selector(behaviorActivated:action:data:)]) {
            [self.delegate behaviorActivated:self action:PTLinkPressLinkAnnotationKey data:@{
                PTURLLinkAnnotationKey: url,
            }];
        }
        
        // Link handled.
        return NO;
    }
    
    return YES;
}

#pragma mark - <RNTPTDocumentViewControllerDelegate>

- (void)rnt_documentViewControllerDocumentLoaded:(PTDocumentBaseViewController *)documentViewController
{       
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

- (void)rnt_documentViewControllerDidScroll:(PTDocumentBaseViewController *)documentViewController
{
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    
    double horizontal = [pdfViewCtrl GetHScrollPos];
    double vertical = [pdfViewCtrl GetVScrollPos];
    
    if ([self.delegate respondsToSelector:@selector(scrollChanged:horizontal:vertical:)]) {
        [self.delegate scrollChanged:self horizontal:horizontal vertical:vertical];
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

- (void)rnt_documentViewControllerDidFinishZoom:(PTDocumentBaseViewController *)documentViewController
{
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    
    const double zoom = pdfViewCtrl.zoom * pdfViewCtrl.zoomScale;
    
    if ([self.delegate respondsToSelector:@selector(zoomFinished:zoom:)]) {
        [self.delegate zoomFinished:self zoom:zoom];
    }
}

- (void)rnt_documentViewControllerLayoutDidChange:(PTDocumentBaseViewController *)documentViewController
{
    if ([self.delegate respondsToSelector:@selector(layoutChanged:)]) {
        [self.delegate layoutChanged:self];
    }
}

- (void)rnt_documentViewControllerPageDidMove:(PTDocumentBaseViewController *)documentViewController pageMovedFromPageNumber:(int)oldPageNumber toPageNumber:(int)newPageNumber;
{
    if ([self.delegate respondsToSelector:@selector(pageMoved:pageMovedFromPageNumber:toPageNumber:)]) {
        [self.delegate pageMoved:self pageMovedFromPageNumber:oldPageNumber toPageNumber:newPageNumber];
    }
}

- (void)rnt_documentViewControllerPageAdded:(PTDocumentBaseViewController *)documentViewController pageNumber:(int)pageNumber
{
    if ([self.delegate respondsToSelector:@selector(pageAdded:pageNumber:)]) {
        [self.delegate pageAdded:self pageNumber:pageNumber];
    }
}

- (void)rnt_documentViewControllerPageRemoved:(PTDocumentBaseViewController *)documentViewController pageNumber:(int)pageNumber
{
    if ([self.delegate respondsToSelector:@selector(pageRemoved:pageNumber:)]) {
        [self.delegate pageRemoved:self pageNumber:pageNumber];
    }
}

- (void)rnt_documentViewControllerDidRotatePages:(PTDocumentBaseViewController *)documentViewController forPageNumbers:(NSIndexSet *)pageNumbers
{
    if ([self.delegate respondsToSelector:@selector(pagesRotated:pageNumbers:)]) {
        [self.delegate pagesRotated:self pageNumbers:pageNumbers];
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

- (BOOL)rnt_documentViewControllerAreKeyboardShortcutsEnabled:(PTDocumentBaseViewController *)documentViewController
{
    return self.keyboardShortcutsEnabled;
}

- (BOOL)rnt_documentViewControllerIsNavigationBarEnabled:(PTDocumentBaseViewController *)documentViewController
{
    return !self.hideTopAppNavBar;
}

- (void)rnt_documentViewControllerTextSearchDidStart:(PTDocumentBaseViewController *)documentViewController
{
    if ([self.delegate respondsToSelector:@selector(textSearchStart:)]) {
        [self.delegate textSearchStart:self];
    }
}

- (void)rnt_documentViewControllerTextSearchDidFindResult:(PTDocumentBaseViewController *)documentViewController selection:(PTSelection *)selection
{
    if ([self.delegate respondsToSelector:@selector(textSearchResult:found:textSelection:)]) {
        if ([selection GetPageNum] > 0) {
            [self.delegate textSearchResult:self found:YES textSelection:[self getMapFromSelection:selection]];
        } else {
            [self.delegate textSearchResult:self found:NO textSelection:nil];
        }
    }
}

- (void)rnt_documentViewControllerSavedSignaturesChanged:(PTDocumentBaseViewController *)documentViewController
{
    if ([self.delegate respondsToSelector:@selector(savedSignaturesChanged:)]) {
        [self.delegate savedSignaturesChanged:self];
    }
}

- (void)rnt_documentViewControllerToolbarButtonPressed:(PTDocumentBaseViewController *)documentViewController
                                          buttonString:(NSString *)buttonString
{
    if ([self.delegate respondsToSelector:@selector(toolbarButtonPressed:withKey:)]) {
        [self.delegate toolbarButtonPressed:self withKey:buttonString];
    }
}

- (NSDictionary<NSString *, id> *)getAnnotationData:(PTAnnot *)annot pageNumber:(int)pageNumber pdfViewCtrl:(PTPDFViewCtrl *)pdfViewCtrl {
    if (![annot IsValid]) {
        return nil;
    }
    
    NSString *uniqueId = nil;
    
    PTObj *uniqueIdObj = [annot GetUniqueID];
    if ([uniqueIdObj IsValid] && [uniqueIdObj IsString]) {
        uniqueId = [uniqueIdObj GetAsPDFText];
    }
    
    PTPDFRect *screenRect = [pdfViewCtrl GetScreenRectForAnnot:annot page_num:pageNumber];
    PTPDFRect *pageRect = [self convertScreenRectToPageRect:screenRect pageNumber:pageNumber pdfViewCtrl:pdfViewCtrl];
    
    NSString *annotationType = [RNTPTDocumentView stringForAnnotType:annot type:[annot GetType]];
    
    return @{
        PTAnnotationIdKey: (uniqueId ?: @""),
        PTAnnotationPageNumberKey: @(pageNumber),
        PTAnnotationTypeKey: annotationType,
        PTScreenRectKey: @{
                PTRectX1Key: @([screenRect GetX1]),
                PTRectY1Key: @([screenRect GetY1]),
                PTRectX2Key: @([screenRect GetX2]),
                PTRectY2Key: @([screenRect GetY2]),
                PTRectWidthKey: @([screenRect Width]),
                PTRectHeightKey: @([screenRect Height]),
        },
        PTPageRectKey: @{
                PTRectX1Key: @([pageRect GetX1]),
                PTRectY1Key: @([pageRect GetY1]),
                PTRectX2Key: @([pageRect GetX2]),
                PTRectY2Key: @([pageRect GetY2]),
                PTRectWidthKey: @([pageRect Width]),
                PTRectHeightKey: @([pageRect Height]),
        },
    };
}

- (PTPDFRect*)convertScreenRectToPageRect:(PTPDFRect*)screenRect pageNumber:(int)pageNumber pdfViewCtrl:(PTPDFViewCtrl *)pdfViewCtrl
{
    PTPDFPoint *screenRectPt1 = [[PTPDFPoint alloc] initWithPx:[screenRect GetX1] py:[screenRect GetY1]];
    PTPDFPoint *screenRectPt2 = [[PTPDFPoint alloc] initWithPx:[screenRect GetX2] py:[screenRect GetY2]];
    
    PTPDFPoint *pageRectPt1 = [pdfViewCtrl ConvScreenPtToPagePt:screenRectPt1 page_num:pageNumber];
    PTPDFPoint *pageRectPt2 = [pdfViewCtrl ConvScreenPtToPagePt:screenRectPt2 page_num:pageNumber];
    
    PTPDFRect* pageRect = [[PTPDFRect alloc] initWithX1:[pageRectPt1 getX] y1:[pageRectPt1 getY] x2:[pageRectPt2 getX] y2:[pageRectPt2 getY]];
    
    return pageRect;
}

- (NSArray<NSDictionary<NSString *, id> *> *)annotationDataForAnnotations:(NSArray<PTAnnot *> *)annotations pageNumber:(int)pageNumber pdfViewCtrl:(PTPDFViewCtrl *)pdfViewCtrl overrideAction:(bool)overrideAction
{
    NSMutableArray<NSDictionary<NSString *, id> *> *annotationsData = [NSMutableArray array];
    
    if (annotations.count > 0) {
        [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc *doc) {
            for (PTAnnot *annot in annotations) {
                NSDictionary *annotDict = [self getAnnotationData:annot pageNumber:pageNumber pdfViewCtrl:pdfViewCtrl];
                
                if (annotDict) {
                    [annotationsData addObject:annotDict];
                    
                    if (overrideAction && [self.overrideBehavior containsObject:PTStickyNoteShowPopUpKey]) {
                        if ([self.delegate respondsToSelector:@selector(behaviorActivated:action:data:)]) {
                            [self.delegate behaviorActivated:self action:PTStickyNoteShowPopUpKey data: annotDict];
                        }
                    }
                }
            }
        } error:nil];
    }

    return [annotationsData copy];
}



- (void)rnt_documentViewController:(PTDocumentBaseViewController *)documentViewController didSelectAnnotations:(NSArray<PTAnnot *> *)annotations onPageNumber:(int)pageNumber
{
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;

    NSArray<NSDictionary<NSString *, id> *> *annotationData = [self annotationDataForAnnotations:annotations pageNumber:pageNumber pdfViewCtrl:pdfViewCtrl overrideAction:YES];
    
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
        PTCommentsMenuItemTitleKey: PTNoteMenuItemIdentifierKey, // "Comments" has same id as "Note".
        PTCopyMenuItemTitleKey: PTCopyMenuItemIdentifierKey,
        PTDuplicateMenuItemTitleKey: PTDuplicateMenuItemIdentifierKey,
        PTDeleteMenuItemTitleKey: PTDeleteMenuItemIdentifierKey,
        PTTypeMenuItemTitleKey: PTTypeMenuItemIdentifierKey,
        PTSearchMenuItemTitleKey: PTSearchMenuItemIdentifierKey,
        PTEditMenuItemTitleKey: editString,
        PTFlattenMenuItemTitleKey: PTFlattenMenuItemIdentifierKey,
        PTOpenMenuItemTitleKey: PTOpenMenuItemIdentifierKey,
        PTCalibrateMenuItemTitleKey: PTCalibrateMenuItemIdentifierKey,
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
        
        if (!self.annotationMenuItems) {
            [permittedItems addObject:menuItem];
        }
        else {if ([whitelist containsObject:menuItem.title] && [self.annotationMenuItems containsObject:PTTypeMenuItemIdentifierKey]) {
            [permittedItems addObject:menuItem];
        }
        else
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
        PTPasteMenuItemTitleKey: PTPasteMenuItemIdentifierKey,
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
    
    NSArray<NSDictionary<NSString *, id> *> *annotationData = [self annotationDataForAnnotations:annotations pageNumber:pageNumber pdfViewCtrl:pdfViewCtrl overrideAction:NO];
        
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
    [self rnt_sendExportAnnotationCommandWithAction:PTAddAnnotationActionKey annotation:collaborationAnnotation pageNumber:-1 annotType:@""];
}

- (void)localAnnotationModified:(PTCollaborationAnnotation *)collaborationAnnotation
{
    [self rnt_sendExportAnnotationCommandWithAction:PTModifyAnnotationActionKey annotation:collaborationAnnotation pageNumber:-1 annotType:@""];
}

- (void)localAnnotationRemoved:(PTCollaborationAnnotation *)collaborationAnnotation
{
    [self rnt_sendExportAnnotationCommandWithAction:PTDeleteAnnotationActionKey annotation:collaborationAnnotation pageNumber:-1 annotType:@""];
}

- (void)rnt_sendExportAnnotationCommandWithAction:(NSString *)action annotation:(PTCollaborationAnnotation *)annot pageNumber:(int)pageNumber annotType:(NSString *)annotType
{
    NSDictionary * annotation;
    if (pageNumber >= 0 && ![annotType isEqualToString:@""]) {
        annotation = @{
            PTAnnotationIdKey: annot.annotationID,
            PTAnnotationPageNumberKey: @(pageNumber),
            PTAnnotationTypeKey: annotType
        };
    } else {
        annotation = @{
            PTAnnotationIdKey: annot.annotationID,
        };
    }
    
    if ([self.delegate respondsToSelector:@selector(exportAnnotationCommand:action:xfdfCommand:annotation:)]) {
        [self.delegate exportAnnotationCommand:self action:action xfdfCommand:annot.xfdf annotation:annotation];
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

    if (self.initialPageNumber > 0) {
        [documentViewController.pdfViewCtrl SetCurrentPage:self.initialPageNumber];
    }
    
    if (self.page > 0) {
        [documentViewController.pdfViewCtrl SetCurrentPage:self.page];
    }

    if ([self isReadOnly] && ![documentViewController.toolManager isReadonly]) {
        documentViewController.toolManager.readonly = YES;
    }
    
    [self applyForcedAppTheme];
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
    NSError *error;
    
    __block PTAnnot *annot;
    __block int pageNumber;
    __block NSString *annotId;

    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * doc) {
        annot = notification.userInfo[PTToolManagerAnnotationUserInfoKey];
        pageNumber = ((NSNumber *)notification.userInfo[PTToolManagerPageNumberUserInfoKey]).intValue;
        annotId = [[annot GetUniqueID] IsValid] ? [[annot GetUniqueID] GetAsPDFText] : @"";
    } error:&error];

    if (error) {
        NSLog(@"An error occurred: %@", error);
        return;
    }
    
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
            PTAnnotationTypeKey: [RNTPTDocumentView stringForAnnotType:annot type:[annot GetType]],
        } action:PTAddAnnotationActionKey];
    }
    if (!self.collaborationManager) {
        PTVectorAnnot *annots = [[PTVectorAnnot alloc] init];
        [annots add:annot];
        
        PTCollaborationAnnotation * collabAnnot = [[PTCollaborationAnnotation alloc] init];
        [collabAnnot setAnnotationID:annotId];
        [collabAnnot setXfdf:[self generateXfdfCommand:[[PTVectorAnnot alloc] init] modified:annots deleted:[[PTVectorAnnot alloc] init] pdfViewCtrl:pdfViewCtrl]];
        
        [self rnt_sendExportAnnotationCommandWithAction:PTAddAnnotationActionKey annotation:collabAnnot pageNumber:pageNumber annotType:[RNTPTDocumentView stringForAnnotType:annot type:[annot GetType]]];
    }
}

- (void)toolManagerDidModifyAnnotationWithNotification:(NSNotification *)notification
{
    if (notification.object != self.currentDocumentViewController.toolManager) {
        return;
    }
    
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    NSError *error;
    
    __block PTAnnot *annot;
    __block int pageNumber;
    __block NSString *annotId;

    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * doc) {
        annot = notification.userInfo[PTToolManagerAnnotationUserInfoKey];
        pageNumber = ((NSNumber *)notification.userInfo[PTToolManagerPageNumberUserInfoKey]).intValue;
        annotId = [[annot GetUniqueID] IsValid] ? [[annot GetUniqueID] GetAsPDFText] : @"";
    } error:&error];

    if (error) {
        NSLog(@"An error occurred: %@", error);
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(annotationChanged:annotation:action:)]) {
        [self.delegate annotationChanged:self annotation:@{
            PTAnnotationIdKey: annotId,
            PTAnnotationTypeKey: [RNTPTDocumentView stringForAnnotType:annot type:[annot GetType]],
            PTAnnotationPageNumberKey: @(pageNumber),
        } action:PTModifyAnnotationActionKey];
    }
    if (!self.collaborationManager) {
        PTVectorAnnot *annots = [[PTVectorAnnot alloc] init];
        [annots add:annot];
        
        PTCollaborationAnnotation * collabAnnot = [[PTCollaborationAnnotation alloc] init];
        [collabAnnot setAnnotationID:annotId];
        [collabAnnot setXfdf:[self generateXfdfCommand:[[PTVectorAnnot alloc] init] modified:annots deleted:[[PTVectorAnnot alloc] init] pdfViewCtrl:pdfViewCtrl]];
        
        [self rnt_sendExportAnnotationCommandWithAction:PTModifyAnnotationActionKey annotation:collabAnnot pageNumber:pageNumber annotType:[RNTPTDocumentView stringForAnnotType:annot type:[annot GetType]]];
    }
}

- (void)toolManagerDidRemoveAnnotationWithNotification:(NSNotification *)notification
{
    if (notification.object != self.currentDocumentViewController.toolManager) {
        return;
    }
    
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    NSError *error;
    
    __block PTAnnot *annot;
    __block int pageNumber;
    __block NSString *annotId;

    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * doc) {
        annot = notification.userInfo[PTToolManagerAnnotationUserInfoKey];
        pageNumber = ((NSNumber *)notification.userInfo[PTToolManagerPageNumberUserInfoKey]).intValue;
        annotId = [[annot GetUniqueID] IsValid] ? [[annot GetUniqueID] GetAsPDFText] : @"";
    } error:&error];

    if (error) {
        NSLog(@"An error occurred: %@", error);
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(annotationChanged:annotation:action:)]) {
        [self.delegate annotationChanged:self annotation:@{
            PTAnnotationIdKey: annotId,
            PTAnnotationPageNumberKey: @(pageNumber),
            PTAnnotationTypeKey: [RNTPTDocumentView stringForAnnotType: annot type:[annot GetType]],
        } action:PTRemoveAnnotationActionKey];
    }
    if (!self.collaborationManager) {
        PTVectorAnnot *annots = [[PTVectorAnnot alloc] init];
        [annots add:annot];
        
        PTCollaborationAnnotation * collabAnnot = [[PTCollaborationAnnotation alloc] init];
        [collabAnnot setAnnotationID:annotId];
        [collabAnnot setXfdf:[self generateXfdfCommand:[[PTVectorAnnot alloc] init] modified:annots deleted:[[PTVectorAnnot alloc] init] pdfViewCtrl:pdfViewCtrl]];
        
        [self rnt_sendExportAnnotationCommandWithAction:PTDeleteAnnotationActionKey annotation:collabAnnot pageNumber:pageNumber annotType:[RNTPTDocumentView stringForAnnotType:annot type:[annot GetType]]];
    }
}

- (void)toolManagerDidFlattenAnnotationWithNotification:(NSNotification *)notification
{
    if (notification.object != self.currentDocumentViewController.toolManager) {
        return;
    }
    
    __block PTAnnot *annot;
    __block int pageNumber;
    __block NSString *annotId;

    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    NSError *error;

    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * doc) {
        annot = notification.userInfo[PTToolManagerAnnotationUserInfoKey];
        pageNumber = ((NSNumber *)notification.userInfo[PTToolManagerPageNumberUserInfoKey]).intValue;
        annotId = [[annot GetUniqueID] IsValid] ? [[annot GetUniqueID] GetAsPDFText] : @"";
    } error:&error];

    if (error) {
        NSLog(@"An error occurred: %@", error);
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(annotationFlattened:annotation:)]) {
        [self.delegate annotationFlattened:self annotation:@{
            PTAnnotationIdKey: [annotId isEqualToString:@""] ? [NSNull null] : annotId,
            PTAnnotationPageNumberKey: @(pageNumber),
            PTAnnotationTypeKey: [RNTPTDocumentView stringForAnnotType:annot type:[annot GetType]],
        }];
    }
}

- (void)toolManagerDidModifyFormFieldDataWithNotification:(NSNotification *)notification
{
    if (notification.object != self.currentDocumentViewController.toolManager) {
        return;
    }
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    PTPDFViewCtrl *pdfViewCtrl = documentViewController.pdfViewCtrl;
    NSError *error;
    
    __block PTAnnot *annot;
    __block int pageNumber;
    __block NSString *annotId;

    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * doc) {
        annot = notification.userInfo[PTToolManagerAnnotationUserInfoKey];
        pageNumber = ((NSNumber *)notification.userInfo[PTToolManagerPageNumberUserInfoKey]).intValue;
        annotId = [[annot GetUniqueID] IsValid] ? [[annot GetUniqueID] GetAsPDFText] : @"";
    } error:&error];

    if (error) {
        NSLog(@"An error occurred: %@", error);
        return;
    }
    
    if ([annot GetType] == e_ptWidget) {
        __block NSDictionary *fieldMap;

        [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
            fieldMap = [self getFieldWithHasAppearance:annot];
        } error:&error];
        
        if (error) {
            NSLog(@"An error occurred: %@", error);
            return;
        }

        if ([self.delegate respondsToSelector:@selector(formFieldValueChanged:fields:)]) {
            [self.delegate formFieldValueChanged:self fields:fieldMap];
        }
        if (!self.collaborationManager) {
            PTVectorAnnot *annots = [[PTVectorAnnot alloc] init];
            [annots add:annot];
            
            PTCollaborationAnnotation * collabAnnot = [[PTCollaborationAnnotation alloc] init];
            [collabAnnot setAnnotationID:annotId];
            [collabAnnot setXfdf:[self generateXfdfCommand:[[PTVectorAnnot alloc] init] modified:annots deleted:[[PTVectorAnnot alloc] init] pdfViewCtrl:pdfViewCtrl]];
            
            [self rnt_sendExportAnnotationCommandWithAction:PTModifyAnnotationActionKey annotation:collabAnnot pageNumber:pageNumber annotType:[RNTPTDocumentView stringForAnnotType:annot type:[annot GetType]]];
        }
    }
}

-(void)toolManagerWillChangeToolWithNotification:(NSNotification *)notification {
    if (notification.object != self.currentDocumentViewController.toolManager) {
        return;
    }

    PTTool *previousTool = self.currentDocumentViewController.toolManager.tool;
    if ([previousTool isKindOfClass:[PTCreateToolBase class]]) {
        PTCreateToolBase *createTool = (PTCreateToolBase *)previousTool;
        if ([createTool isUndoManagerEnabled]) {
            [self endObservingUndoManager:createTool.undoManager];
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

    PTTool *tool = self.currentDocumentViewController.toolManager.tool;

    if([tool isKindOfClass:[PTDigitalSignatureTool class]]){
        [(PTDigitalSignatureTool *)tool showSignatureList];
        return;
    }

    if ([tool isKindOfClass:[PTCreateToolBase class]]) {
        PTCreateToolBase *createTool = (PTCreateToolBase *)tool;
        if ([createTool isUndoManagerEnabled]) {
            [self beginObservingUndoManager:createTool.undoManager];
        }
    }
}

-(void)toolGroupDidChangeWithNotification:(NSNotification *)notification
{
    if (![[self.currentDocumentViewController class] isSubclassOfClass:[PTDocumentController class]] ||
        notification.object != ((PTDocumentController *) self.currentDocumentViewController).toolGroupManager) {
        return;
    }
    
    PTToolGroupManager *toolGroupManager = ((PTDocumentController *) self.currentDocumentViewController).toolGroupManager;
    PTToolGroup *toolGroup = toolGroupManager.selectedGroup;
    
    NSString *toolGroupId = [self keyForToolGroup:toolGroup toolGroupManager:toolGroupManager];
    
    if (!toolGroupId) {
        // custom toolbar
        toolGroupId = toolGroup.identifier;
    }
    
    if ([self.delegate respondsToSelector:@selector(currentToolbarChanged:toolbar:)]) {
        [self.delegate currentToolbarChanged:self toolbar:toolGroupId];
    }
}

- (void)beginObservingUndoManager:(NSUndoManager *)undoManager
{
    if (!undoManager) {
        return;
    }

    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;

    [center addObserver:self
               selector:@selector(undoManagerStateDidChange:)
                   name:NSUndoManagerDidCloseUndoGroupNotification
                 object:undoManager];
    [center addObserver:self
               selector:@selector(undoManagerStateDidChange:)
                   name:NSUndoManagerDidUndoChangeNotification
                 object:undoManager];
    [center addObserver:self
               selector:@selector(undoManagerStateDidChange:)
                   name:NSUndoManagerDidRedoChangeNotification
                 object:undoManager];
}

- (void)endObservingUndoManager:(NSUndoManager *)undoManager
{
    if (!undoManager) {
        return;
    }

    NSNotificationCenter *center = NSNotificationCenter.defaultCenter;

    [center removeObserver:self
                      name:NSUndoManagerDidCloseUndoGroupNotification
                    object:undoManager];
    [center removeObserver:self
                      name:NSUndoManagerDidUndoChangeNotification
                    object:undoManager];
    [center removeObserver:self
                      name:NSUndoManagerDidRedoChangeNotification
                    object:undoManager];
}

- (void)undoManagerStateDidChange:(NSNotification *)notification
{
    NSUndoManager *undoManager = notification.object;
    PTTool *tool = self.currentDocumentViewController.toolManager.tool;
    if (undoManager != tool.undoManager) {
        return;
    }

    if (@available(iOS 13.1, *)) {
        if ([self.currentDocumentViewController.toolManager.tool isKindOfClass:[PTPencilDrawingCreate class]]) {
            if (!self.inkMultiStrokeEnabled) {
                [((PTPencilDrawingCreate*)self.currentDocumentViewController.toolManager.tool) commitAnnotation];
            }
        }
    }

    if ([self.currentDocumentViewController.toolManager.tool isKindOfClass:[PTFreeHandCreate class]]) {
        if (!self.inkMultiStrokeEnabled) {
            [((PTFreeHandCreate*)self.currentDocumentViewController.toolManager.tool) commitAnnotation];
        }
    }
}

- (void)undoManagerStateDidChangeWithModification:(NSNotification *)notification
{
    if (notification.object != self.currentDocumentViewController.toolManager.undoManager) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(undoRedoStateChanged:)]) {
        [self.delegate undoRedoStateChanged:self];
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
    
    [documentViewController bookmarkViewController:bookmarkViewController
                                 didModifyBookmark:bookmark];
    
    [self bookmarksModified:documentViewController.pdfViewCtrl];
}

- (void)bookmarkViewController:(PTBookmarkViewController *)bookmarkViewController didAddBookmark:(PTUserBookmark *)bookmark {
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    
    [documentViewController bookmarkViewController:bookmarkViewController
                                    didAddBookmark:bookmark];
    
    [self bookmarksModified:documentViewController.pdfViewCtrl];
}

- (void)bookmarkViewController:(PTBookmarkViewController *)bookmarkViewController didRemoveBookmark:(nonnull PTUserBookmark *)bookmark {
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    
    [documentViewController bookmarkViewController:bookmarkViewController
                                 didRemoveBookmark:bookmark];
    
    [self bookmarksModified:documentViewController.pdfViewCtrl];
}

- (void)bookmarkViewController:(PTBookmarkViewController *)bookmarkViewController selectedBookmark:(PTUserBookmark *)bookmark
{
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    
    [documentViewController bookmarkViewController:bookmarkViewController
                                  selectedBookmark:bookmark];
}

- (void)bookmarkViewControllerDidCancel:(PTBookmarkViewController *)bookmarkViewController
{
    PTDocumentBaseViewController *documentViewController = self.currentDocumentViewController;
    
    [documentViewController bookmarkViewControllerDidCancel:bookmarkViewController];
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
        
        NSDictionary *customData = [RNTPTDocumentView PT_idAsNSDictionary:propertyMap[PTAnnotationCustomDataKey]];
        if (customData) {
            [customData enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL* stop) {
                if ([key isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                    [annot SetCustomData:key value:value];
                }
            }];
        }
        
        NSDictionary *annotStrokeColor = [RNTPTDocumentView PT_idAsNSDictionary:propertyMap[PTStrokeColorKey]];
        if (annotStrokeColor) {
            UIColor *strokeColor = [self convertRGBAToUIColor:annotStrokeColor];
            int componentCount;
            PTColorPt *strokePTColor = [PTColorPt colorFromUIColor:strokeColor componentCount:&componentCount];
            if (componentCount) {
                [annot SetColor:strokePTColor numcomp:componentCount];
                [annot RefreshAppearance];
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

- (NSDictionary *)getPropertiesForAnnotation:(NSString *)annotationId pageNumber:(NSInteger)pageNumber
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;

    NSError *error;
    
    __block NSMutableDictionary<NSString *, NSObject *> *map = [[NSMutableDictionary alloc] init];
    if (pdfViewCtrl) {
        NSError *error;

        [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
            
            PTAnnot *annot = [self findAnnotWithUniqueID:annotationId onPageNumber:(int)pageNumber pdfViewCtrl:pdfViewCtrl];
            if (![annot IsValid]) {
                NSLog(@"Failed to find annotation with id \"%@\" on page number %d",
                    annotationId, (int)pageNumber);
                annot = nil;
                return;
            }
            
            NSString *contents = [annot GetContents];
            if (contents) {
                [map setObject:[annot GetContents] forKey:PTContentsAnnotationPropertyKey];
            }
            
            PTPDFRect *rect = [annot GetRect];
            if (rect) {
                NSDictionary *rectDict = @{
                    PTRectX1Key: @([rect GetX1]),
                    PTRectY1Key: @([rect GetY1]),
                    PTRectX2Key: @([rect GetX2]),
                    PTRectY2Key: @([rect GetY2]),
                    PTRectWidthKey: @([rect Width]),
                    PTRectHeightKey: @([rect Height])
                };
                [map setObject:rectDict forKey:PTRectKey];
            }
            
            PTColorPt *color = [annot GetColorAsRGB];
            if (color) {
                double red = [color Get:0] * 255;
                double green = [color Get:1] * 255;
                double blue = [color Get:2] * 255;
                NSDictionary *colorDict = @{
                    PTColorRedKey: @(red),
                    PTColorGreenKey: @(green),
                    PTColorBlueKey: @(blue)
                };
                [map setObject:colorDict forKey:PTStrokeColorKey];
            }
            
            if ([annot IsMarkup]) {
                PTMarkup *markupAnnot = [[PTMarkup alloc] initWithAnn:annot];
                
                NSString *subject = [markupAnnot GetSubject];
                if (subject) {
                    [map setObject:subject forKey:PTSubjectAnnotationPropertyKey];
                }
                
                NSString *title = [markupAnnot GetTitle];
                if (title) {
                    [map setObject:title forKey:PTTitleAnnotationPropertyKey];
                }
                                
                PTPDFRect *contentRect = [markupAnnot GetContentRect];
                if (contentRect) {
                    NSDictionary *contentRectDict = @{
                        PTRectX1Key: @([contentRect GetX1]),
                        PTRectY1Key: @([contentRect GetY1]),
                        PTRectX2Key: @([contentRect GetX2]),
                        PTRectY2Key: @([contentRect GetY2]),
                        PTRectWidthKey: @([contentRect Width]),
                        PTRectHeightKey: @([contentRect Height])
                    };
                    [map setObject:contentRectDict forKey:PTContentRectAnnotationPropertyKey];
                }
            }
        } error:&error];
    }
    
    // Throw error as exception to reject promise.
    if (error) {
        @throw [NSException exceptionWithName:NSGenericException reason:error.localizedFailureReason userInfo:error.userInfo];
    }

    return [map copy];
}

#pragma mark - Annotation Visibility

- (void)setDrawAnnotations:(BOOL)drawAnnotations
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    [pdfViewCtrl SetDrawAnnotations:drawAnnotations];
    [pdfViewCtrl Update:YES];
}

- (void)setVisibilityForAnnotation:(NSString *)annotationId pageNumber:(NSInteger)pageNumber visibility:(BOOL)visibility
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;

    NSError *error;
    
    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
        
        PTAnnot *annot = [self findAnnotWithUniqueID:annotationId onPageNumber:(int)pageNumber pdfViewCtrl:pdfViewCtrl];
        if (![annot IsValid]) {
            NSLog(@"Failed to find annotation with id \"%@\" on page number %d",
                  annotationId, (int)pageNumber);
            annot = nil;
            return;
        }
        
        if (visibility) {
            [pdfViewCtrl ShowAnnotation:annot];
        } else {
            [pdfViewCtrl HideAnnotation:annot];
        }
        
        [pdfViewCtrl UpdateWithAnnot:annot page_num:(int)pageNumber];
        
    } error:&error];
    
    // Throw error as exception to reject promise.
    if (error) {
        @throw [NSException exceptionWithName:NSGenericException reason:error.localizedFailureReason userInfo:error.userInfo];
    }
}

- (void)setHighlightFields:(BOOL)highlightFields
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    [pdfViewCtrl SetHighlightFields:highlightFields];
    [pdfViewCtrl Update];
}

#pragma mark - Get Annotation(s)

- (NSDictionary *)getAnnotationAt:(NSInteger)x y:(NSInteger)y distanceThreshold:(double)distanceThreshold minimumLineWeight:(double)minimumLineWeight
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    PTPDFDoc *pdfDoc = self.currentDocumentViewController.document;
    
    __block NSDictionary *annotation;
    if (pdfViewCtrl && pdfDoc) {
        NSError *error;
        
        [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
            PTAnnot *annot = [pdfViewCtrl GetAnnotationAt:(int)x y:(int)y distanceThreshold:distanceThreshold minimumLineWeight:minimumLineWeight];
            
            if (annot && [annot IsValid]) {
                annotation = [self getAnnotationData:annot pageNumber:[pdfViewCtrl GetPageNumberFromScreenPt:(double)x y:(double)y] pdfViewCtrl:pdfViewCtrl];
            }
        } error:&error];
        
        // Throw error as exception to reject promise.
        if (error) {
            @throw [NSException exceptionWithName:NSGenericException reason:error.localizedFailureReason userInfo:error.userInfo];
        }
    }
    
    return annotation ? [annotation copy] : nil;
}

- (NSArray *)getAnnotationListAt:(NSInteger)x1 y1:(NSInteger)y1 x2:(NSInteger)x2 y2:(NSInteger)y2
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    PTPDFDoc *pdfDoc = self.currentDocumentViewController.document;
    
    __block NSMutableArray *annotations = [[NSMutableArray alloc] init];
    if (pdfViewCtrl && pdfDoc) {
        NSError *error;
        
        [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
            NSArray <PTAnnot *> *annots = [pdfViewCtrl GetAnnotationListAt:(int)x1 y1:(int)y1 x2:(int)x2 y2:(int)y2];
            
            int pageNumber = [pdfViewCtrl GetPageNumberFromScreenPt:(double)x1 y:(double)y1];
            
            for (PTAnnot *annot in annots) {
                if ([annot IsValid]) {
                    [annotations addObject:[self getAnnotationData:annot pageNumber:pageNumber pdfViewCtrl:pdfViewCtrl]];
                }
            }
        } error:&error];
        
        // Throw error as exception to reject promise.
        if (error) {
            @throw [NSException exceptionWithName:NSGenericException reason:error.localizedFailureReason userInfo:error.userInfo];
        }
    }
    
    return [annotations copy];
}

- (NSArray *)getAnnotationListOnPage:(NSInteger)pageNumber
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    PTPDFDoc *pdfDoc = self.currentDocumentViewController.document;
    
    __block NSMutableArray *annotations = [[NSMutableArray alloc] init];
    if (pdfViewCtrl && pdfDoc) {
        NSError *error;
        
        [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
            NSArray <PTAnnot *> *annots = [pdfViewCtrl GetAnnotationsOnPage:(int)pageNumber];
            
            for (PTAnnot *annot in annots) {
                if ([annot IsValid]) {
                    [annotations addObject:[self getAnnotationData:annot pageNumber:(int)pageNumber pdfViewCtrl:pdfViewCtrl]];
                }
            }
        } error:&error];
        
        // Throw error as exception to reject promise.
        if (error) {
            @throw [NSException exceptionWithName:NSGenericException reason:error.localizedFailureReason userInfo:error.userInfo];
        }
    }
    
    return [annotations copy];
}

-(void)openAnnotationList
{
    if (!self.currentDocumentViewController.annotationListHidden) {
        PTNavigationListsViewController *navigationListsViewController = self.currentDocumentViewController.navigationListsViewController;
        navigationListsViewController.selectedViewController = navigationListsViewController.annotationViewController;
        [self.currentDocumentViewController presentViewController:navigationListsViewController animated:YES completion:nil];
    }
}

- (NSString *)getCustomDataForAnnotation:(NSString *)annotationId pageNumber:(NSInteger)pageNumber key:(NSString *)key
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    PTPDFDoc *pdfDoc = self.currentDocumentViewController.document;
    
    __block NSString *customData = @"";
    if (pdfViewCtrl && pdfDoc) {
        NSError *error;
        
        [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
            NSArray <PTAnnot *> *annots = [pdfViewCtrl GetAnnotationsOnPage:(int)pageNumber];
            for (PTAnnot *annot in annots) {
                if ([[annot GetUniqueIDAsString] isEqualToString:annotationId]) {
                    customData = [[annot GetCustomData:key] copy];
                }
            }
        } error:&error];
        
        // Throw error as exception to reject promise.
        if (error) {
            @throw [NSException exceptionWithName:NSGenericException reason:error.localizedFailureReason userInfo:error.userInfo];
        }
    }
    
    return [customData copy];
}

#pragma mark - Page

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

- (bool)setCurrentPage:(NSInteger)pageNumber {
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    return [pdfViewCtrl SetCurrentPage:(int)pageNumber];
}

- (NSArray *)getVisiblePages {
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    return [pdfViewCtrl GetVisiblePages];
}

- (bool)gotoPreviousPage {
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    return [pdfViewCtrl GotoPreviousPage];
}

- (bool)gotoNextPage {
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    return [pdfViewCtrl GotoNextPage];
}

- (bool)gotoFirstPage {
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    return [pdfViewCtrl GotoFirstPage];
}

- (bool)gotoLastPage {
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    return [pdfViewCtrl GotoLastPage];
}

- (void) showGoToPageView {
    PTPageIndicatorViewController * pageIndicator = self.currentDocumentViewController.pageIndicatorViewController;
    [pageIndicator presentGoToPageController];
}

#pragma mark - Get Document Path

- (NSString *) getDocumentPath {
    return self.currentDocumentViewController.coordinatedDocument.fileURL.path;
}

#pragma mark - Get All Fields

- (NSArray<NSDictionary *> *)getAllFieldsForDocumentViewTag:(int)pageNumber
{
    if(pageNumber == -1){
        return [self getAllFields];
    }
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    if (!pdfViewCtrl) {
        return nil;
    }
    NSMutableArray<NSDictionary *> *resultMap = [[NSMutableArray alloc] init];
    NSError *error;
    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
        PTPage *page = [doc GetPage:pageNumber];
        [resultMap addObjectsFromArray:[self getFieldsForPage:page]];
    } error:&error];
        
    if (error) {
        NSLog(@"An error occurred: %@", error);
        return nil;
    }
    
    return [resultMap copy];
}

- (NSArray<NSDictionary *> *)getAllFields
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    if (!pdfViewCtrl) {
        return nil;
    }

    NSMutableArray<NSDictionary *> *resultMap = [[NSMutableArray alloc] init];
    NSError *error;
    [pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
        int pageCount = [doc GetPageCount];
        for (int i = 1; i <= pageCount; i ++){
            PTPage *page = [doc GetPage:i];
            [resultMap addObjectsFromArray:[self getFieldsForPage:page]];
        }
    } error:&error];
        
    if (error) {
        NSLog(@"An error occurred: %@", error);
        return nil;
    }
    
    return [resultMap copy];
}

- (NSArray<NSDictionary *>*)getFieldsForPage:(PTPage*)page
{
    NSMutableArray<NSDictionary *> *resultMap = [[NSMutableArray alloc] init];
    int num_annots = [page GetNumAnnots];
    for (int i = 0; i < num_annots; i ++){
        PTAnnot *annot = [page GetAnnot:i];
        if(annot != nil) {
            if ([annot GetType] == e_ptWidget) {
                __block NSDictionary* fieldMap = [self getFieldWithHasAppearance:annot];
                [resultMap addObject:fieldMap];
            }
        }
    }
    return [resultMap copy];
}

#pragma mark - Export as image

- (NSString *)exportAsImage:(int)pageNumber dpi:(int)dpi exportFormat:(NSString*)exportFormat transparent:(BOOL)transparent
{
    PTPDFDoc * doc = [self.currentDocumentViewController.pdfViewCtrl GetDoc];
    return [RNPdftron exportAsImageHelper:doc pageNumber:pageNumber dpi:dpi exportFormat:exportFormat transparent:transparent];
}

#pragma mark - Tabs

- (void)setMultiTabEnabled:(BOOL)enabled
{
    _multiTabEnabled = enabled;
    
}

- (void)setTabTitle:(NSString *)tabTitle
{
    _tabTitle = [tabTitle copy];
    
}

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

- (void)openTabSwitcher
{
    if (self.tabbedDocumentViewController) {
        [self.tabbedDocumentViewController showTabsList:self.tabbedDocumentViewController.tabBar];
    }
}

#pragma mark - Page Rotation

- (int)getPageRotation
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    PTRotate rotation = [pdfViewCtrl GetRotation];
    
    if (rotation == e_pt0) {
        return 0;
    } else if (rotation == e_pt90) {
        return 90;
    } else if (rotation == e_pt180) {
        return 180;
    } else {
        return 270;
    }
}

- (void)rotateClockwise
{
    [self.currentDocumentViewController.pdfViewCtrl RotateClockwise];
}

- (void)rotateCounterClockwise
{
    [self.currentDocumentViewController.pdfViewCtrl RotateCounterClockwise];
}

#pragma mark - Undo/Redo

- (void)undo
{
    [self.currentDocumentViewController.undoManager undo];
}

- (void)redo
{
    [self.currentDocumentViewController.undoManager redo];
}

#pragma mark - Can Undo/Can Redo

- (bool)canUndo
{
    return [self.currentDocumentViewController.undoManager canUndo];
}

- (bool)canRedo
{
    return [self.currentDocumentViewController.undoManager canRedo];
}

#pragma mark - Get Zoom

- (double)getZoom
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    return pdfViewCtrl.zoom * pdfViewCtrl.zoomScale;
}

#pragma mark - Scroll Pos

- (void)setHorizontalScrollPos:(double)horizontalScrollPos
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    [pdfViewCtrl SetHScrollPos:horizontalScrollPos];
}

- (void)setVerticalScrollPos:(double)verticalScrollPos
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    [pdfViewCtrl SetVScrollPos:verticalScrollPos];
}

- (NSDictionary<NSString *, NSNumber *> *)getScrollPos
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    
    NSDictionary<NSString *, NSNumber *> * scrollPos = @{
        PTScrollHorizontalKey: [[NSNumber alloc] initWithDouble:[pdfViewCtrl GetHScrollPos]],
        PTScrollVerticalKey: [[NSNumber alloc] initWithDouble:[pdfViewCtrl GetVScrollPos]],
    };
    
    return scrollPos;
}

#pragma mark - Scrollbars

- (void)setHideScrollbars:(BOOL)hideScrollbars
{
    _hideScrollbars = hideScrollbars;
    
    if (self.documentViewController) {
        [self applyViewerSettings];
    }
}

- (void)applyScrollbarVisibility:(PTDocumentBaseViewController *)documentBaseViewController
{
    const BOOL hideScrollbars = self.hideScrollbars;
    
    if ([documentBaseViewController isKindOfClass:[PTDocumentController class]]) {
        PTDocumentController * const documentController = (PTDocumentController *)documentBaseViewController;
        
        documentController.documentSliderViewController.hidesPDFViewCtrlScrollIndicators = hideScrollbars;
    }
    
    PTPDFViewCtrl* pdfViewCtrl = documentBaseViewController.pdfViewCtrl;
    if (pdfViewCtrl) {
        pdfViewCtrl.contentScrollView.showsHorizontalScrollIndicator = !hideScrollbars;
        pdfViewCtrl.contentScrollView.showsVerticalScrollIndicator = !hideScrollbars;
        
        pdfViewCtrl.pagingScrollView.showsHorizontalScrollIndicator = !hideScrollbars;
        pdfViewCtrl.pagingScrollView.showsVerticalScrollIndicator = !hideScrollbars;
    }
}

#pragma mark - Canvas Size

- (NSDictionary<NSString *, NSNumber *> *)getCanvasSize
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    
    NSDictionary<NSString *, NSNumber *> * canvasSize = @{
        PTRectWidthKey: [[NSNumber alloc] initWithDouble:[pdfViewCtrl GetCanvasWidth]],
        PTRectHeightKey: [[NSNumber alloc] initWithDouble:[pdfViewCtrl GetCanvasHeight]],
    };
    
    return canvasSize;
}

#pragma mark - Coordinate

- (NSArray *)convertScreenPointsToPagePoints:(NSArray *)points
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    NSMutableArray <NSDictionary *> *convertedPoints = [[NSMutableArray alloc] init];
    
    if (pdfViewCtrl) {
        int currentPage = [pdfViewCtrl GetCurrentPage];
        
        PTPDFPoint *pdfPoint = [[PTPDFPoint alloc] initWithPx:0 py:0];
        PTPDFPoint *convertedPdfPoint;
        
        for (NSDictionary *point in points) {
            [pdfPoint setX:[point[PTCoordinatePointX] doubleValue]];
            [pdfPoint setY:[point[PTCoordinatePointY] doubleValue]];
            int pageNumber = currentPage;
            
            if ([[point allKeys] containsObject:PTCoordinatePointPageNumber]) {
                pageNumber = [point[PTCoordinatePointPageNumber] intValue];
            }
            convertedPdfPoint = [pdfViewCtrl ConvScreenPtToPagePt:pdfPoint page_num:pageNumber];
            
            [convertedPoints addObject:@{
                PTCoordinatePointX: @([convertedPdfPoint getX]),
                PTCoordinatePointY: @([convertedPdfPoint getY]),
            }];
        }
    }
    
    return [convertedPoints copy];
}

- (NSArray *)convertPagePointsToScreenPoints:(NSArray *)points
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    NSMutableArray <NSDictionary *> *convertedPoints = [[NSMutableArray alloc] init];
    
    if (pdfViewCtrl) {
        int currentPage = [pdfViewCtrl GetCurrentPage];
        
        PTPDFPoint *pdfPoint = [[PTPDFPoint alloc] initWithPx:0 py:0];
        PTPDFPoint *convertedPdfPoint;
        
        for (NSDictionary *point in points) {
            [pdfPoint setX:[point[PTCoordinatePointX] doubleValue]];
            [pdfPoint setY:[point[PTCoordinatePointY] doubleValue]];
            int pageNumber = currentPage;
            
            if ([[point allKeys] containsObject:PTCoordinatePointPageNumber]) {
                pageNumber = [point[PTCoordinatePointPageNumber] intValue];
            }
            convertedPdfPoint = [pdfViewCtrl ConvPagePtToScreenPt:pdfPoint page_num:pageNumber];
            
            [convertedPoints addObject:@{
                PTCoordinatePointX: @([convertedPdfPoint getX]),
                PTCoordinatePointY: @([convertedPdfPoint getY]),
            }];
        }
    }
    
    return [convertedPoints copy];
}

- (int)getPageNumberFromScreenPoint:(double)x y:(double)y
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    return [pdfViewCtrl GetPageNumberFromScreenPt:x y:y];
}

#pragma mark - Rendering Options

- (void)setProgressiveRendering:(BOOL)progressiveRendering initialDelay:(NSInteger)initialDelay interval:(NSInteger)interval
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    [pdfViewCtrl SetProgressiveRendering:progressiveRendering withInitialDelay:(int)initialDelay withInterval:(int)interval];
}


- (void)setImageSmoothing:(BOOL)imageSmoothing
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    [pdfViewCtrl SetImageSmoothing:imageSmoothing];
}

- (void)setOverprint:(NSString *)overprint {
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    
    if ([overprint isEqualToString:PTOverprintModeOnKey]) {
        [pdfViewCtrl SetOverprint:e_ptop_on];
    } else if ([overprint isEqualToString:PTOverprintModeOffKey]) {
        [pdfViewCtrl SetOverprint:e_ptop_off];
    } else if ([overprint isEqualToString:PTOverprintModePdfxKey]) {
        [pdfViewCtrl SetOverprint:e_ptop_pdfx_on];
    }
}

# pragma mark - Text Search

- (void)findText:(NSString *)searchString matchCase:(BOOL)matchCase matchWholeWord:(BOOL)matchWholeWord searchUp:(BOOL)searchUp regExp:(BOOL)regExp
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    
    [pdfViewCtrl FindText:searchString MatchCase:matchCase MatchWholeWord:matchWholeWord SearchUp:searchUp RegExp:regExp];
}

- (void)cancelFindText
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    
    [pdfViewCtrl CancelFindText];
}

- (void)openSearch
{
    [self.currentDocumentViewController showSearchViewController];
}

- (void)startSearchMode:(NSString *)searchString matchCase:(BOOL)matchCase matchWholeWord:(BOOL)matchWholeWord;
{
    self.currentDocumentViewController.textSearchViewController.showsKeyboardOnViewDidAppear = NO;
    unsigned int mode = e_ptambient_string | e_ptpage_stop | e_pthighlight;
    if (matchCase) {
        mode |= e_ptcase_sensitive;
    }
    if (matchWholeWord) {
        mode |= e_ptwhole_word;
    }

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.currentDocumentViewController.textSearchViewController];
    nav.modalPresentationStyle = UIModalPresentationCustom;
    [self.currentDocumentViewController presentViewController:nav animated:NO completion:^{
        [self.currentDocumentViewController.textSearchViewController findText:searchString withSearchMode:mode];
    }];
}

- (void)exitSearchMode;
{
    if (self.currentDocumentViewController.textSearchViewController.presentingViewController) {
        [self.currentDocumentViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (NSDictionary *)getSelection:(NSInteger)pageNumber
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    
    PTSelection *selection = [pdfViewCtrl GetSelection:(int)pageNumber];
    
    if ([selection GetPageNum] != -1 && pdfViewCtrl) {
        return [self getMapFromSelection:selection];
    }
    
    return nil;
}

- (NSDictionary *)getMapFromSelection:(PTSelection *)selection
{
    NSMutableDictionary *selectionMap = [[NSMutableDictionary alloc] initWithCapacity:4];
    [selectionMap setValue:[NSNumber numberWithInt:[selection GetPageNum]] forKey:PTTextSelectionPageNumberKey];
    [selectionMap setValue:[selection GetAsUnicode] forKey:PTTextSelectionUnicodekey];
    [selectionMap setValue:[selection GetAsHtml] forKey:PTTextSelectionHtmlKey];
    
    PTVectorQuadPoint *vectorQuads = [selection GetQuads];
    NSMutableArray *quads = [[NSMutableArray alloc] initWithCapacity:[vectorQuads size]];
    
    for (int i = 0; i < [vectorQuads size]; i ++) {
        PTQuadPoint *quad = [vectorQuads get:i];
        NSMutableArray *points = [[NSMutableArray alloc] initWithCapacity:4];
        for (int j = 0; j < 4; j ++) {
            PTPDFPoint *point;
            if (j == 0) {
                point = [quad getP1];
            } else if (j == 1) {
                point = [quad getP2];
            } else if (j == 2) {
                point = [quad getP3];
            } else if (j == 3) {
                point = [quad getP4];
            }
            
            [points addObject:@{PTTextSelectionQuadPointXKey: [NSNumber numberWithDouble:[point getX]], PTTextSelectionQuadPointYKey: [NSNumber numberWithDouble:[point getY]]}];
        }
        
        [quads addObject:[points copy]];
    }
    
    
    [selectionMap setValue:[quads copy] forKey:PTTextSelectionQuadsKey];
    return selectionMap;
}

- (BOOL)hasSelection
{
    return [self.currentDocumentViewController.pdfViewCtrl HasSelection];
}

- (void)clearSelection
{
    [self.currentDocumentViewController.pdfViewCtrl ClearSelection];
}

- (NSDictionary *)getSelectionPageRange
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    
    if (pdfViewCtrl) {
        return @{PTTextSelectionPageRangeBeginKey: [NSNumber numberWithInt:(int)[pdfViewCtrl GetSelectionBeginPage]],
                 PTTextSelectionPageRangeEndKey: [NSNumber numberWithInt:(int)[pdfViewCtrl GetSelectionEndPage]]
        };
    }
    
    return nil;
}

- (bool)hasSelectionOnPage:(NSInteger)pageNumber
{
    return [self.currentDocumentViewController.pdfViewCtrl HasSelectionOnPage:(int)pageNumber];
}

- (BOOL)selectInRect:(NSDictionary *)rect
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    
    if (pdfViewCtrl && rect) {
        NSNumber *rectX1 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectX1Key]];
        NSNumber *rectY1 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectY1Key]];
        NSNumber *rectX2 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectX2Key]];
        NSNumber *rectY2 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectY2Key]];
        if (rectX1 && rectY1 && rectX2 && rectY2) {
            return [pdfViewCtrl SelectX1:[rectX1 doubleValue] Y1:[rectY1 doubleValue] X2:[rectX2 doubleValue] Y2:[rectY2 doubleValue]];
        }
    }
    
    return NO;
}

- (BOOL)isThereTextInRect:(NSDictionary *)rect
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    
    if (pdfViewCtrl && rect) {
        NSNumber *rectX1 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectX1Key]];
        NSNumber *rectY1 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectY1Key]];
        NSNumber *rectX2 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectX2Key]];
        NSNumber *rectY2 = [RNTPTDocumentView PT_idAsNSNumber:rect[PTRectY2Key]];
        if (rectX1 && rectY1 && rectX2 && rectY2) {
            return [pdfViewCtrl IsThereTextInRect:[rectX1 doubleValue] y1:[rectY1 doubleValue] x2:[rectX2 doubleValue] y2:[rectY2 doubleValue]];
        }
    }
    
    return NO;
}

- (void)selectAll
{
    PTPDFViewCtrl *pdfViewCtrl = self.currentDocumentViewController.pdfViewCtrl;
    
    if (pdfViewCtrl) {
        [pdfViewCtrl SelectAll];
    }
}

- (BOOL)isReflowMode
{
    return !(self.documentViewController.isReflowHidden);
}

- (void)toggleReflow
{
    self.documentViewController.reflowHidden = !(self.documentViewController.isReflowHidden);
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

- (UIBarButtonItem *)itemForButton:(NSString *)buttonString
                  inViewController:(PTDocumentBaseViewController *)documentViewController
{
    if ([buttonString isEqualToString:PTSearchButtonKey]) {
        return documentViewController.searchButtonItem;
    } else if ([buttonString isEqualToString:PTMoreItemsButtonKey]) {
        return documentViewController.moreItemsButtonItem;
    } else if ([buttonString isEqualToString:PTThumbNailsButtonKey]) {
        return documentViewController.thumbnailsButtonItem;
    } else if ([buttonString isEqualToString:PTListsButtonKey]) {
        return documentViewController.navigationListsButtonItem;
    } else if ([buttonString isEqualToString:PTReflowButtonKey]) {
        return documentViewController.readerModeButtonItem;
    } else if ([buttonString isEqualToString:PTShareButtonKey]) {
        return documentViewController.shareButtonItem;
    } else if ([buttonString isEqualToString:PTViewControlsButtonKey]) {
        return documentViewController.settingsButtonItem;
    }
    return nil;
}

- (void)removeToolbarButtonItem:(UIBarButtonItem *)item
                       inViewController:(PTDocumentBaseViewController *)documentViewController
{
    if (!item) {
        return;
    }
    
    if ([documentViewController isKindOfClass:[PTDocumentController class]]) {
        PTDocumentController * const documentController = (PTDocumentController *)documentViewController;

        NSArray<UIBarButtonItem *> * const compactToolbarItems = [documentController toolbarItemsForSizeClass:UIUserInterfaceSizeClassCompact];
        if ([compactToolbarItems containsObject:item]) {
            NSMutableArray<UIBarButtonItem *> * const mutableToolbarItems = [compactToolbarItems mutableCopy];
            
            [mutableToolbarItems removeObject:item];
            
            [documentController setToolbarItems: [mutableToolbarItems copy]
                                   forSizeClass:UIUserInterfaceSizeClassCompact
                                       animated: NO];

        }
        NSArray<UIBarButtonItem *> * const regularToolbarItems = [documentController toolbarItemsForSizeClass:UIUserInterfaceSizeClassRegular];
        if ([regularToolbarItems containsObject:item]) {
            NSMutableArray<UIBarButtonItem *> * const mutableToolbarItems = [regularToolbarItems mutableCopy];
            
            [mutableToolbarItems removeObject:item];
            
            [documentController setToolbarItems:[mutableToolbarItems copy]
                                     forSizeClass:UIUserInterfaceSizeClassRegular
                                         animated:NO];
        }
    } else {
        PTDocumentController * const documentController = (PTDocumentController *)documentViewController;
        
        NSArray<UIBarButtonItem *> * const toolbarItems = documentController.toolbarItems;
        if ([toolbarItems containsObject:item]) {
            NSMutableArray<UIBarButtonItem *> * const mutableToolbarItems = [toolbarItems mutableCopy];
            
            [mutableToolbarItems removeObject:item];
            
            [documentController setToolbarItems:[mutableToolbarItems copy]
                                       animated:NO];
        }
    }
}

- (void)removeRightBarButtonItem:(UIBarButtonItem *)item
                       inViewController:(PTDocumentBaseViewController *)documentViewController
{
    if (!item) {
        return;
    }

    if ([documentViewController isKindOfClass:[PTDocumentController class]]) {
        PTDocumentController * const documentController = (PTDocumentController *)documentViewController;
        PTDocumentNavigationItem * const navigationItem = documentController.navigationItem;
        
        NSArray<UIBarButtonItem *> * const compactRightBarButtonItems = [navigationItem rightBarButtonItemsForSizeClass:UIUserInterfaceSizeClassCompact];
        if ([compactRightBarButtonItems containsObject:item]) {
            NSMutableArray<UIBarButtonItem *> * const mutableRightBarButtonItems = [compactRightBarButtonItems mutableCopy];
            
            [mutableRightBarButtonItems removeObject:item];
            
            [navigationItem setRightBarButtonItems:[mutableRightBarButtonItems copy]
                                      forSizeClass:UIUserInterfaceSizeClassCompact
                                          animated:NO];
        }
        NSArray<UIBarButtonItem *> * const regularRightBarButtonItems = [navigationItem rightBarButtonItemsForSizeClass:UIUserInterfaceSizeClassRegular];
        if ([regularRightBarButtonItems containsObject:item]) {
            NSMutableArray<UIBarButtonItem *> * const mutableRightBarButtonItems = [regularRightBarButtonItems mutableCopy];
            
            [mutableRightBarButtonItems removeObject:item];
            
            [navigationItem setRightBarButtonItems:[mutableRightBarButtonItems copy]
                                      forSizeClass:UIUserInterfaceSizeClassRegular
                                          animated:NO];
        }
    } else {
        UINavigationItem * const navigationItem = documentViewController.navigationItem;
        
        NSArray<UIBarButtonItem *> * const rightBarButtonItems = navigationItem.rightBarButtonItems;
        if ([rightBarButtonItems containsObject:item]) {
            NSMutableArray<UIBarButtonItem *> * const mutableRightBarButtonItems = [rightBarButtonItems mutableCopy];
            
            [mutableRightBarButtonItems removeObject:item];
            
            [navigationItem setRightBarButtonItems:[mutableRightBarButtonItems copy]
                                          animated:NO];
        }
    }
}

- (void)removeLeftBarButtonItem:(UIBarButtonItem *)item
                       inViewController:(PTDocumentBaseViewController *)documentViewController
{
    if (!item) {
        return;
    }
    
    if ([documentViewController isKindOfClass:[PTDocumentController class]]) {
        PTDocumentController * const documentController = (PTDocumentController *)documentViewController;
        PTDocumentNavigationItem * const navigationItem = documentController.navigationItem;
        
        NSArray<UIBarButtonItem *> * const compactLeftBarButtonItems = [navigationItem leftBarButtonItemsForSizeClass:UIUserInterfaceSizeClassCompact];
        if ([compactLeftBarButtonItems containsObject:item]) {
            NSMutableArray<UIBarButtonItem *> * const mutableLeftBarButtonItems = [compactLeftBarButtonItems mutableCopy];
            
            [mutableLeftBarButtonItems removeObject:item];
            
            [navigationItem setLeftBarButtonItems:[mutableLeftBarButtonItems copy]
                                     forSizeClass:UIUserInterfaceSizeClassCompact
                                         animated:NO];
        }
        NSArray<UIBarButtonItem *> * const regularLeftBarButtonItems = [navigationItem leftBarButtonItemsForSizeClass:UIUserInterfaceSizeClassRegular];
        if ([regularLeftBarButtonItems containsObject:item]) {
            NSMutableArray<UIBarButtonItem *> * const mutableLeftBarButtonItems = [regularLeftBarButtonItems mutableCopy];
            
            [mutableLeftBarButtonItems removeObject:item];
            
            [navigationItem setLeftBarButtonItems:[mutableLeftBarButtonItems copy]
                                     forSizeClass:UIUserInterfaceSizeClassRegular
                                         animated:NO];
        }
    } else {
        UINavigationItem * const navigationItem = documentViewController.navigationItem;
        
        NSArray<UIBarButtonItem *> * const leftBarButtonItems = navigationItem.leftBarButtonItems;
        if ([leftBarButtonItems containsObject:item]) {
            NSMutableArray<UIBarButtonItem *> * const mutableLeftBarButtonItems = [leftBarButtonItems mutableCopy];
            
            [mutableLeftBarButtonItems removeObject:item];
            
            [navigationItem setLeftBarButtonItems:[mutableLeftBarButtonItems copy]
                                         animated:NO];
        }
    }
}

+ (Class)toolClassForKey:(NSString *)key
{
    if ([key isEqualToString:PTAnnotationEditToolKey] ||
        [key isEqualToString:PTEditToolButtonKey]) {
        return [PTAnnotEditTool class];
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
    else if ([key isEqualToString:PTMultiSelectToolKey]) {
        return [PTAnnotSelectTool class];
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
    else if ([key isEqualToString:PTAnnotationCountToolKey]) {
        return [PTCountCreate class];
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
    else if ([key isEqualToString:PTAnnotationCreateLinkToolKey] ||
             [key isEqualToString:PTAnnotationCreateLinkTextToolKey]) {
        return [PTLinkCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateRedactionTextToolKey]) {
        return [PTTextRedactionCreate class];
    }
    else if ([key isEqualToString:PTFormCreateTextFieldToolKey]) {
        return [PTTextFieldCreate class];
    }
    else if ([key isEqualToString:PTFormCreateCheckboxFieldToolKey]) {
        return [PTCheckBoxCreate class];
    }
    else if ([key isEqualToString:PTFormCreateSignatureFieldToolKey]) {
        return [PTSignatureFieldCreate class];
    }
    else if ([key isEqualToString:PTFormCreateRadioFieldToolKey]) {
        return [PTRadioButtonCreate class];
    }
    else if ([key isEqualToString:PTFormCreateComboBoxFieldToolKey]) {
        return [PTComboBoxCreate class];
    }
    else if ([key isEqualToString:PTFormCreateListBoxFieldToolKey]) {
        return [PTListBoxCreate class];
    }
    else if ([key isEqualToString:PTAnnotationCreateFreeTextDateToolKey]) {
        return [PTDateTextCreate class];
    }
    else if ( [key isEqualToString:PTAnnotationCreateCheckMarkStampKey] ) {
        return [PTCheckMarkStampCreate class];
    }
    else if ( [key isEqualToString:PTAnnotationCreateCrossMarkStampKey] ) {
        return [PTCrossMarkStampCreate class];
    }
    else if ( [key isEqualToString:PTAnnotationCreateDotStampKey] ) {
        return [PTDotStampCreate class];
    }
    else if (toolClass == [RNTPTDigitalSignatureTool class]) {
        return PTAnnotationCreateSignatureToolKey;
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
    if (toolClass == [PTAnnotEditTool class]) {
        return PTAnnotationEditToolKey;
    }
    else if (toolClass == [PTStickyNoteCreate class]) {
        return PTAnnotationCreateStickyToolKey;
    }
    else if (toolClass == [PTFreeHandCreate class]) {
        return PTAnnotationCreateFreeHandToolKey;
    }
    else if (toolClass == [PTTextSelectTool class]) {
        return PTTextSelectToolKey;
    }
    else if (toolClass == [PTAnnotSelectTool class]) {
        return PTMultiSelectToolKey;
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
    else if (toolClass == [PTTextStrikeoutCreate class]) {
        return PTAnnotationCreateTextStrikeoutToolKey;
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
    else if (toolClass == [PTCountCreate class]) {
        return PTAnnotationCountToolKey;
    }
    else if (toolClass == [PTFreeHandHighlightCreate class]) {
        return PTAnnotationCreateFreeHighlighterToolKey;
    }
    else if (toolClass == [PTPanTool class]) {
        return PTPanToolKey;
    }
    else if (toolClass == [PTRubberStampCreate class]) {
        return PTAnnotationCreateRubberStampToolKey;
    }
    else if (toolClass == [PTRectangleRedactionCreate class]) {
        return PTAnnotationCreateRedactionToolKey;
    }
    else if (toolClass == [PTTextRedactionCreate class]) {
        return PTAnnotationCreateRedactionTextToolKey;
    }
    else if (toolClass == [PTSmartPen class]) {
        return PTAnnotationCreateSmartPenToolKey;
    }
    else if (toolClass == [PTDateTextCreate class]) {
        return PTAnnotationCreateFreeTextDateToolKey;
    }
    else if (toolClass == [PTLinkCreate class]) {
       return PTAnnotationCreateLinkToolKey;
    }
    else if (toolClass == [PTTextFieldCreate class]) {
        return PTFormCreateTextFieldToolKey;
    }
    else if (toolClass == [PTCheckBoxCreate class]) {
        return PTFormCreateCheckboxFieldToolKey;
    }
    else if (toolClass == [PTSignatureFieldCreate class]) {
        return PTFormCreateSignatureFieldToolKey;
    }
    else if (toolClass == [PTComboBoxCreate class]) {
        return PTFormCreateComboBoxFieldToolKey;
    }
    else if (toolClass == [PTListBoxCreate class]) {
        return PTFormCreateListBoxFieldToolKey;
    }
    else if (toolClass == [PTRadioButtonCreate class]) {
        return PTFormCreateRadioFieldToolKey;
    }
    else if (toolClass == [PTCheckMarkStampCreate class]) {
        return PTAnnotationCreateCheckMarkStampKey;
    }
    else if (toolClass == [PTCrossMarkStampCreate class]) {
        return PTAnnotationCreateCrossMarkStampKey;
    }
    else if (toolClass == [PTDotStampCreate class]) {
        return PTAnnotationCreateDotStampKey;
    }
    
    if (@available(iOS 13.1, *)) {
        if (toolClass == [PTPencilDrawingCreate class]) {
            return PTPencilKitDrawingToolKey;
        }
    }
    
    return Nil;
}

+ (NSString *)stringForAnnotType:(PTAnnot *)annot type:(PTAnnotType)type {
    if (type == e_ptText) {
        return PTAnnotationCreateStickyToolKey;
    } else if (type == e_ptLink) {
        return PTAnnotationCreateLinkToolKey;
    } else if (type == e_ptFreeText) {
        return PTAnnotationCreateFreeTextToolKey;
    } else if (type == e_ptLine) {
        return PTAnnotationCreateLineToolKey;
    } else if (type == e_ptSquare) {
        return PTAnnotationCreateRectangleToolKey;
    } else if (type == e_ptCircle) {
        return PTAnnotationCreateEllipseToolKey;
    } else if (type == e_ptPolygon) {
        return PTAnnotationCreatePolygonToolKey;
    } else if (type == e_ptPolyline) {
        return PTAnnotationCreatePolylineToolKey;
    } else if (type == e_ptHighlight) {
        return PTAnnotationCreateFreeHighlighterToolKey;
    } else if (type == e_ptUnderline) {
        return PTAnnotationCreateTextUnderlineToolKey;
    } else if (type == e_ptSquiggly) {
        return PTAnnotationCreateTextSquigglyToolKey;
    } else if (type == e_ptStrikeOut) {
        return PTAnnotationCreateTextStrikeoutToolKey;
    } else if (type == e_ptStamp) {
        return PTAnnotationCreateStampToolKey;
    } else if (type == e_ptCaret) {
        return @"";
    } else if (type == e_ptInk) {
        return PTAnnotationCreateFreeHandToolKey;
    } else if (type == e_ptPopup) {
        return @"";
    } else if (type == e_ptFileAttachment) {
        return PTAnnotationCreateFileAttachmentToolKey;
    } else if (type == e_ptSound) {
        return PTAnnotationCreateSoundToolKey;
    } else if (type == e_ptMovie) {
        return @"";
    } else if (type == e_ptWidget) {
        return [self getWidgetFieldType:annot];
    } else if (type == e_ptScreen) {
        return @"";
    } else if (type == e_ptPrinterMark) {
        return @"";
    } else if (type == e_ptTrapNet) {
        return @"";
    } else if (type == e_ptWatermark) {
        return @"";
    } else if (type == e_pt3D) {
        return @"";
    } else if (type == e_ptRedact) {
        return PTAnnotationCreateRedactionToolKey;
    } else if (type == e_ptProjection) {
        return @"";
    } else if (type == e_ptRichMedia) {
        return @"";
    } else if (type == e_ptUnknown) {
        return @"";
    }
    
    return @"";
}

+ (PTAnnotType)annotTypeForString:(NSString *)string {
    if ([string isEqualToString:PTAnnotationCreateStickyToolKey]) {
        return e_ptText;
    } else if ([string isEqualToString:PTAnnotationCreateLinkToolKey] ||
               [string isEqualToString:PTAnnotationCreateLinkTextToolKey]) {
        return e_ptLink;
    } else if ([string isEqualToString:PTAnnotationCreateFreeTextToolKey]) {
        return e_ptFreeText;
    } else if ([string isEqualToString:PTAnnotationCreateLineToolKey]) {
        return e_ptLine;
    } else if ([string isEqualToString:PTAnnotationCreateRectangleToolKey]) {
        return e_ptSquare;
    } else if ([string isEqualToString:PTAnnotationCreateEllipseToolKey]) {
        return e_ptCircle;
    } else if ([string isEqualToString:PTAnnotationCreatePolygonToolKey]) {
        return e_ptPolygon;
    } else if ([string isEqualToString:PTAnnotationCreatePolylineToolKey]) {
        return e_ptPolyline;
    } else if ([string isEqualToString:PTAnnotationCreateFreeHighlighterToolKey]) {
        return e_ptHighlight;
    } else if ([string isEqualToString:PTAnnotationCreateTextUnderlineToolKey]) {
        return e_ptUnderline;
    } else if ([string isEqualToString:PTAnnotationCreateTextSquigglyToolKey]) {
        return e_ptSquiggly;
    } else if ([string isEqualToString:PTAnnotationCreateTextStrikeoutToolKey]) {
        return e_ptStrikeOut;
    } else if ([string isEqualToString:PTAnnotationCreateStampToolKey]) {
        return e_ptStamp;
    } else if ([string isEqualToString:PTAnnotationCreateFreeHandToolKey]) {
        return e_ptInk;
    } else if ([string isEqualToString:PTAnnotationCreateFileAttachmentToolKey]) {
        return e_ptFileAttachment;
    } else if ([string isEqualToString:PTAnnotationCreateSoundToolKey]) {
        return e_ptSound;
    } else if ([string isEqualToString:PTFormCreateTextFieldToolKey]) {
        return e_ptWidget;
    } else if ([string isEqualToString:PTAnnotationCreateRedactionToolKey]) {
        return e_ptRedact;
//    } else if ([string isEqualToString:@"");
//        return e_ptCaret;
//    } else if ([string isEqualToString:@"");
//        return e_ptPopup;
//    } else if ([string isEqualToString:@"");
//        return e_ptMovie;
//    } else if ([string isEqualToString:@"");
//        return e_ptScreen;
//    } else if ([string isEqualToString:@"");
//        return e_ptPrinterMark;
//    } else if ([string isEqualToString:@"");
//        return e_ptTrapNet;
//    } else if ([string isEqualToString:@"");
//        return e_pt3D;
//    } else if ([string isEqualToString:@"");
//        return e_ptProjection;
//    } else if ([string isEqualToString:@"");
//        return e_ptRichMedia;
//    } else if ([string isEqualToString:@"");
//        return e_ptUnknown;
//    } else if ([string isEqualToString:@"");
//        return e_ptWatermark;
    }
    return e_ptUnknown;
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

- (nullable UIImage *)imageForImageName:(NSString *)imageName
{
    UIImage * const image = [UIImage imageNamed:imageName];
    if (image != nil) {
        return image;
    }else{
        // fallback to System Image
        if (@available(iOS 13.0, *)) {
            UIImage *systemIcon = [UIImage systemImageNamed:imageName];
            if (systemIcon != nil) {
                return systemIcon;
            }
        }
    }
    return nil;
}

+ (NSString *)getWidgetFieldType:(PTAnnot *)annot
{
    @try {
        PTWidget *widget = [[PTWidget alloc] initWithAnn:annot];
        PTField *field = [widget GetField];
        PTFieldType fieldType = [field GetType];
        
        if (fieldType == e_pttext) {
            return PTFormCreateTextFieldToolKey;
        } else if (fieldType == e_ptcheck) {
            return PTFormCreateCheckboxFieldToolKey;
        } else if (fieldType == e_ptradio) {
            return PTFormCreateRadioFieldToolKey;
        } else if (fieldType == e_ptchoice) {
            return PTFormCreateComboBoxFieldToolKey;
        } else if (fieldType == e_ptsignature) {
            return PTFormCreateSignatureFieldToolKey;
        }
    }
    @catch (NSException *e) {
        return @"";
    }
    
    return @"";
}

#pragma mark - Display Responsiveness

-(void)setShowNavigationListAsSidePanelOnLargeDevices:(BOOL)showNavigationListAsSidePanelOnLargeDevices
{
    _showNavigationListAsSidePanelOnLargeDevices = showNavigationListAsSidePanelOnLargeDevices;
    
    [self applyViewerSettings];
}

#pragma mark - Online Settings

-(void)setRestrictDownloadUsage:(BOOL)restrictDownloadUsage
{
    _restrictDownloadUsage = restrictDownloadUsage;
    
    [self applyViewerSettings];
}

#pragma mark - Outline

-(void)openOutlineList
{
    if (!self.currentDocumentViewController.outlineListHidden) {
        PTNavigationListsViewController *navigationListsViewController = self.currentDocumentViewController.navigationListsViewController;
        navigationListsViewController.selectedViewController = navigationListsViewController.outlineViewController;
        [self.currentDocumentViewController presentViewController:navigationListsViewController animated:YES completion:nil];
    }
}

#pragma mark - Layers

-(void)openLayersList
{
    if (!self.currentDocumentViewController.pdfLayerListHidden) {
        PTNavigationListsViewController *navigationListsViewController = self.currentDocumentViewController.navigationListsViewController;
        navigationListsViewController.selectedViewController = navigationListsViewController.pdfLayerViewController;
        [self.currentDocumentViewController presentViewController:navigationListsViewController animated:YES completion:nil];
    }
}

#pragma mark - Navigation

-(void)setShowQuickNavigationButton:(BOOL)showQuickNavigationButton
{
    _showQuickNavigationButton = showQuickNavigationButton;
    
    [self applyViewerSettings];
}

-(void)openNavigationLists
{
    PTNavigationListsViewController *navigationListsViewController = self.currentDocumentViewController.navigationListsViewController;
    if (navigationListsViewController) {
        [self.currentDocumentViewController showNavigationLists];
    }
}

#pragma mark - Thumbnails

- (void)openThumbnailsView
{
    [self.currentDocumentViewController showThumbnailsController];
}

#pragma mark - Hygen Generated Props/Methods

- (void)setStampImageData:(NSString *)annotationId pageNumber:(NSInteger)pageNumber stampImageDataUrl:(NSString *)stampImageDataUrl
{
    NSURL *imageUrl = [NSURL URLWithString: stampImageDataUrl];
        
        NSURLSessionDataTask* task = [NSURLSession.sharedSession dataTaskWithURL:imageUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                return;
            }
                        
            // Initialize the new image with downloaded file
            PTObjSet* hintSet = [[PTObjSet alloc] init];
            PTObj* encoderHints = [hintSet CreateArray];
            
            NSString *compressionAlgorithm = @"png";
            NSInteger compressionQuality = 50;
            [encoderHints PushBackName:compressionAlgorithm];
            [encoderHints PushBackName:@"Quality"];
            [encoderHints PushBackNumber:compressionQuality];
            PTPDFDoc* doc = [self.currentDocumentViewController.pdfViewCtrl GetDoc];
            PTImage* image = [PTImage CreateWithDataSimple:[doc GetSDFDoc] buf:data buf_size:data.length encoder_hints:encoderHints];
            
            PTAnnot *annot = [self findAnnotWithUniqueID:annotationId
                                            onPageNumber:(int)pageNumber
                                             pdfViewCtrl:self.currentDocumentViewController.pdfViewCtrl];
            [self setCustomImage:image OnAnnotation:annot onDoc:doc];
            [self.currentDocumentViewController.pdfViewCtrl UpdateWithAnnot:annot page_num:(int)pageNumber];
        }];
        
        [task resume];

}

- (void)setCustomImage:(PTImage*)image OnAnnotation:(PTAnnot*)annot onDoc:(PTPDFDoc*)doc
{
    // Initialize a new PTElementWriter and PTElementBuilder
    PTElementWriter* writer = [[PTElementWriter alloc] init];
    PTElementBuilder* builder = [[PTElementBuilder alloc] init];

    [writer WriterBeginWithSDFDoc:[doc GetSDFDoc] compress:YES];

    int w = [image GetImageWidth], h = [image GetImageHeight];

    // Initialize a new image element
    PTElement* img_element = [builder CreateImageWithCornerAndScale:image x:0 y:0 hscale:w vscale:h];

    // Write the element
    [writer WritePlacedElement:img_element];

    // Get the bounding box of the new element
    PTPDFRect* bbox = [img_element GetBBox];

    // Configure the appearance stream that will be written to the annotation
    PTObj* appearance_stream = [writer End];

    // Set the bounding box to be the rect of the new element
    [appearance_stream PutRect:@"BBox" x1:[bbox GetX1] y1:[bbox GetY1] x2:[bbox GetX2] y2:[bbox GetY2]];

    // Overwrite the annotation's appearance with the new appearance stream
    [annot SetAppearance:appearance_stream annot_state:e_ptnormal app_state:0];
}

- (void)setForceAppTheme:(NSString *)forcedAppTheme
{
    _forceAppTheme = forcedAppTheme;
    
    [self applyForcedAppTheme];
}

- (void)setSignatureColors:(NSArray *)signatureColors
{
    _signatureColors = [signatureColors copy];
    
    [self applyViewerSettings];
}

- (void)setFormFieldHighlightColor:(NSDictionary *)fieldHighlightColor
{
    PTPDFViewCtrl *pdfViewCtrl = _documentViewController.pdfViewCtrl;
    
    if (pdfViewCtrl) {
        UIColor *combinedColor = [self convertRGBAToUIColor:fieldHighlightColor];
        [pdfViewCtrl SetFieldHighlightColor:combinedColor];
        [pdfViewCtrl Update:YES];
    }
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

#pragma mark - RNTPTAnnotationManager

@implementation RNTPTAnnotationManager

@end

#pragma mark - RNTPTAnnotationReplyViewController

@implementation RNTPTAnnotationReplyViewController

- (BOOL)isAnnotationStateEnabled
{
    BOOL annotationStateEnabled = [super isAnnotationStateEnabled];
    BOOL replyReviewStateEnabled = YES;
    if ([self.annotationManager isKindOfClass:RNTPTAnnotationManager.class]) {
        RNTPTAnnotationManager *annotationManager = (RNTPTAnnotationManager*)self.annotationManager;
        replyReviewStateEnabled = annotationManager.replyReviewStateEnabled;
    }
    return annotationStateEnabled && replyReviewStateEnabled;
}

@end

#pragma mark - RNTPTDigitalSignatureTool

@implementation RNTPTDigitalSignatureTool

- (void)signaturesManagerNumberOfSignaturesDidChange:(PTSignaturesManager *)signaturesManager numberOfSignatures:(int)numberOfSignatures
{
    [super signaturesManagerNumberOfSignaturesDidChange:signaturesManager numberOfSignatures:numberOfSignatures];
    
    if ([self.toolManager.viewController isKindOfClass:[RNTPTDocumentViewController class]]) {
        RNTPTDocumentViewController *viewController = (RNTPTDocumentViewController *) self.toolManager.viewController;
        
        if ([viewController.delegate respondsToSelector:@selector(rnt_documentViewControllerSavedSignaturesChanged:)]) {
            [viewController.delegate rnt_documentViewControllerSavedSignaturesChanged:viewController];
        }
    } else if ([self.toolManager.viewController isKindOfClass:[RNTPTDocumentController class]]) {
        RNTPTDocumentController *viewController = (RNTPTDocumentController *) self.toolManager.viewController;
        
        if ([viewController.delegate respondsToSelector:@selector(rnt_documentViewControllerSavedSignaturesChanged:)]) {
            [viewController.delegate rnt_documentViewControllerSavedSignaturesChanged:viewController];
        }
    } else if ([self.toolManager.viewController isKindOfClass:[RNTPTCollaborationDocumentController class]]) {
        RNTPTCollaborationDocumentController *viewController = (RNTPTCollaborationDocumentController *) self.toolManager.viewController;
        
        if ([viewController.delegate respondsToSelector:@selector(rnt_documentViewControllerSavedSignaturesChanged:)]) {
            [viewController.delegate rnt_documentViewControllerSavedSignaturesChanged:viewController];
        }
    }
}

@end
