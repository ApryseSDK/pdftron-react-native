#import "RNTPTDocumentViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNTPTDocumentViewController ()

@property (nonatomic) BOOL local;
@property (nonatomic) BOOL needsDocumentLoaded;
@property (nonatomic) BOOL needsRemoteDocumentLoaded;
@property (nonatomic) BOOL documentLoaded;

@end

NS_ASSUME_NONNULL_END

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

- (BOOL)isTopToolbarEnabled
{
    if ([self.delegate respondsToSelector:@selector(rnt_documentViewControllerIsTopToolbarEnabled:)]) {
        return [self.delegate rnt_documentViewControllerIsTopToolbarEnabled:self];
    }
    return YES;
}

- (void)setControlsHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (!hidden && ![self isTopToolbarEnabled]){
        return;
    }
    
    [super setControlsHidden:hidden animated:animated];
}

#pragma mark - <PTToolManagerDelegate>

- (void)toolManagerToolChanged:(PTToolManager *)toolManager
{
    [super toolManagerToolChanged:toolManager];
    
    // If the top toolbar is disabled...
    if (![self isTopToolbarEnabled] &&
        // ...and the annotation toolbar is visible now...
        ![self isAnnotationToolbarHidden]) {
        // ...hide the toolbar.
        self.annotationToolbar.hidden = YES;
    }
}

- (BOOL)toolManager:(PTToolManager *)toolManager shouldShowMenu:(UIMenuController *)menuController forAnnotation:(PTAnnot *)annotation onPageNumber:(unsigned long)pageNumber
{
    [self.pdfViewCtrl DocLockReadWithBlock:^(PTPDFDoc * _Nullable doc) {
        if (![annotation IsValid]) {
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(rnt_documentViewController:filterMenuItemsForAnnotationSelectionMenu:)]) {
            [self.delegate rnt_documentViewController:self filterMenuItemsForAnnotationSelectionMenu:menuController];
        }
    } error:nil];
    
    return [super toolManager:toolManager shouldShowMenu:menuController forAnnotation:annotation onPageNumber:pageNumber];
}

#pragma mark - <PTAnnotationToolbarDelegate>

- (BOOL)toolShouldGoBackToPan:(PTAnnotationToolbar *)annotationToolbar
{
    if ([self.delegate respondsToSelector:@selector(rnt_documentViewControllerShouldGoBackToPan:)]) {
        return [self.delegate rnt_documentViewControllerShouldGoBackToPan:self];
    }
    
    return [super toolShouldGoBackToPan:annotationToolbar];
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

- (void)pdfViewCtrl:(PTPDFViewCtrl *)pdfViewCtrl pdfScrollViewDidZoom:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(rnt_documentViewControllerDidZoom:)]) {
        [self.delegate rnt_documentViewControllerDidZoom:self];
    }
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
