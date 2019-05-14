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
    return [super initWithFrame:frame];
}

- (void)didMoveToWindow
{
    if (_documentController) {
        return;
    }
    
    UIViewController *controller = self.findParentViewController;
    if (controller == nil || self.window == nil) {
        return;
    }

    
    _documentController = [[PTDocumentViewController alloc] init];

    if (_showNavButton) {
        UIImage *navImage = [UIImage imageNamed:_navButtonPath];
        UIBarButtonItem *navButton = [[UIBarButtonItem alloc] initWithImage:navImage style:UIBarButtonItemStylePlain target:self action:@selector(navButtonClicked)];
        _documentController.navigationItem.leftBarButtonItem = navButton;
    }
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:_documentController];
    
    UIView *controllerView = navigationController.view;
    
    [controller addChildViewController:navigationController];
    [self addSubview:controllerView];
    
    controllerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:
     @[[controllerView.topAnchor constraintEqualToAnchor:self.topAnchor],
       [controllerView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
       [controllerView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
       [controllerView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
       ]];
    
    [navigationController didMoveToParentViewController:controller];
    
    // Open a file URL.
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:_document withExtension:@"pdf"];
    if ([_document containsString:@"://"]) {
        fileURL = [NSURL URLWithString:_document];
    } else if ([_document hasPrefix:@"/"]) {
        fileURL = [NSURL fileURLWithPath:_document];
    }

    // these all already default to NO so we can take them directly
    _documentController.shareButtonHidden = self.shareButtonHidden;
    _documentController.searchButtonHidden = self.searchButtonHidden;
    _documentController.annotationToolbarButtonHidden = self.annotationToolbarButtonHidden;
    _documentController.thumbnailBrowserButtonHidden = self.thumbnailBrowserButtonHidden;
    _documentController.navigationListsButtonHidden = self.navigationListsButtonHidden;
    
    _documentController.nightModeEnabled = self.nightModeEnabled;
    _documentController.bottomToolbarEnabled = self.bottomToolbarEnabled;
    _documentController.pageIndicatorEnabled = self.pageIndicatorEnabled;
    _documentController.pageIndicatorShowsOnPageChange = self.pageIndicatorShowsOnPageChange;
    _documentController.pageIndicatorShowsWithControls = self.pageIndicatorShowsWithControls;
    
    [_documentController openDocumentWithURL:fileURL];
}

#pragma mark - Button visibility

-(void)setShareButtonHidden:(BOOL)shareButtonHidden
{
    _documentController.shareButtonHidden = shareButtonHidden;
    _shareButtonHidden = shareButtonHidden;
}

-(void)setSearchButtonHidden:(BOOL)searchButtonHidden
{
    _documentController.searchButtonHidden = searchButtonHidden;
    _searchButtonHidden = searchButtonHidden;
}

-(void)setAnnotationToolbarButtonHidden:(BOOL)annotationToolbarButtonHidden
{
    _documentController.annotationToolbarButtonHidden = annotationToolbarButtonHidden;
    _annotationToolbarButtonHidden = annotationToolbarButtonHidden;
}

-(void)setThumbnailBrowserButtonHidden:(BOOL)thumbnailBrowserButtonHidden
{
    _documentController.thumbnailBrowserButtonHidden = thumbnailBrowserButtonHidden;
    _thumbnailBrowserButtonHidden = thumbnailBrowserButtonHidden;
}

-(void)setNavigationListsButtonHidden:(BOOL)navigationListsButtonHidden
{
    _documentController.navigationListsButtonHidden = navigationListsButtonHidden;
    _navigationListsButtonHidden = navigationListsButtonHidden;
}

-(void)setViewerSettingsButtonHidden:(BOOL)viewerSettingsButtonHidden
{
    _documentController.viewerSettingsButtonHidden = viewerSettingsButtonHidden;
    _viewerSettingsButtonHidden = viewerSettingsButtonHidden;
}

#pragma mark - Viewer options

-(void)setNightModeEnabled:(BOOL)nightModeEnabled
{
    _documentController.nightModeEnabled = nightModeEnabled;
    _nightModeEnabled = nightModeEnabled;
}

-(void)setBottomToolbarEnabled:(BOOL)bottomToolbarEnabled
{
    _documentController.bottomToolbarEnabled = bottomToolbarEnabled;
    _bottomToolbarEnabled = bottomToolbarEnabled;
}

-(void)setPageIndicatorEnabled:(BOOL)pageIndicatorEnabled
{
    _documentController.pageIndicatorEnabled = pageIndicatorEnabled;
    _pageIndicatorEnabled = pageIndicatorEnabled;
}

-(void)setPageIndicatorShowsOnPageChange:(BOOL)pageIndicatorShowsOnPageChange
{
    _documentController.pageIndicatorShowsOnPageChange = pageIndicatorShowsOnPageChange;
    _pageIndicatorShowsOnPageChange = pageIndicatorShowsOnPageChange;
}

-(void)setPageIndicatorShowsWithControls:(BOOL)pageIndicatorShowsWithControls
{
    _documentController.pageIndicatorShowsWithControls = pageIndicatorShowsWithControls;
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
