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
    
    _documentController = [[PTTabbedDocumentViewController alloc] init];
    _documentController.tabsEnabled = NO;
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

    [_documentController openDocumentWithURL:fileURL];
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
