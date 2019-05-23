//
//  RNTPTDocumentView.m
//  RNPdftron
//
//  Copyright © 2018 PDFTron. All rights reserved.
//

#import "RNTPTDocumentView.h"

@implementation RNTPTDocumentView
@synthesize delegate;

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _documentViewController = [[PTDocumentViewController alloc] init];
    }
    return self;
}

- (void)didMoveToWindow
{
    if (_documentViewController.navigationController ) {
        return;
    }
    
    UIViewController *parentController = self.findParentViewController;
    if (parentController == nil || self.window == nil) {
        return;
    }


    if (_showNavButton) {
        UIImage *navImage = [UIImage imageNamed:_navButtonPath];
        UIBarButtonItem *navButton = [[UIBarButtonItem alloc] initWithImage:navImage style:UIBarButtonItemStylePlain target:self action:@selector(navButtonClicked)];
        _documentViewController.navigationItem.leftBarButtonItem = navButton;
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_documentViewController];
    
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
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:_document withExtension:@"pdf"];
    if ([_document containsString:@"://"]) {
        fileURL = [NSURL URLWithString:_document];
    } else if ([_document hasPrefix:@"/"]) {
        fileURL = [NSURL fileURLWithPath:_document];
    }
    
    
    
    [_documentViewController openDocumentWithURL:fileURL];
}

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


- (void)navButtonClicked
{
    if([self.delegate respondsToSelector:@selector(navButtonClicked:)]) {
        [self.delegate navButtonClicked:self];
    }
}

- (UIViewController *)findParentViewController {
    UIResponder *parentResponder = self;
    while ((parentResponder = parentResponder.nextResponder)) {
        if ([parentResponder isKindOfClass:UIViewController.class]) {
            return (UIViewController *)parentResponder;
        }
    }
    return nil;
}

- (void)dealloc
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
