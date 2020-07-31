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
    if (![self isTopToolbarEnabled]) {
        if ([self isBottomToolbarEnabled]) {
            [self setThumbnailSliderHidden:hidden animated:animated];
        }
        if (!hidden) {
            return;
        }
    }
    
    [super setControlsHidden:hidden animated:animated];
}

#pragma mark - <PTToolManagerDelegate>

- (void)toolManagerToolChanged:(PTToolManager *)toolManager
{
    PTTool *tool = toolManager.tool;
    
    const BOOL backToPan = tool.backToPanToolAfterUse;
    
    [super toolManagerToolChanged:toolManager];
    
    if (tool.backToPanToolAfterUse != backToPan) {
        tool.backToPanToolAfterUse = backToPan;
    }
    
    // If the top toolbar is disabled...
    if (![self isTopToolbarEnabled] &&
        // ...and the annotation toolbar is visible now...
        ![self isAnnotationToolbarHidden]) {
        // ...hide the toolbar.
        self.annotationToolbar.hidden = YES;
    }
}

- (void)toolManager:(PTToolManager *)toolManager didSelectAnnotation:(PTAnnot *)annotation onPageNumber:(unsigned long)pageNumber
{
    NSMutableArray<PTAnnot *> *annotations = [NSMutableArray array];
    if ([self.toolManager.tool isKindOfClass:[PTAnnotEditTool class]]) {
        PTAnnotEditTool *annotEdit = (PTAnnotEditTool *)self.toolManager.tool;
        if (annotEdit.selectedAnnotations.count > 0) {
            [annotations addObjectsFromArray:annotEdit.selectedAnnotations];
        }
    } else if (self.toolManager.tool.currentAnnotation) {
        [annotations addObject:self.toolManager.tool.currentAnnotation];
    }
    
    if ([self.delegate respondsToSelector:@selector(rnt_documentViewController:didSelectAnnotations:onPageNumber:)]) {
        [self.delegate rnt_documentViewController:self didSelectAnnotations:[annotations copy] onPageNumber:(int)pageNumber];
    }
}

- (BOOL)toolManager:(PTToolManager *)toolManager shouldShowMenu:(UIMenuController *)menuController forAnnotation:(PTAnnot *)annotation onPageNumber:(unsigned long)pageNumber
{
    BOOL result = [super toolManager:toolManager shouldShowMenu:menuController forAnnotation:annotation onPageNumber:pageNumber];
    if (!result) {
        return NO;
    }
    
    BOOL showMenu = YES;
    if (annotation) {
        if ([self.delegate respondsToSelector:@selector(rnt_documentViewController:
                                                        filterMenuItemsForAnnotationSelectionMenu:
                                                        forAnnotation:)]) {
            showMenu = [self.delegate rnt_documentViewController:self
                       filterMenuItemsForAnnotationSelectionMenu:menuController
                                                   forAnnotation:annotation];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(rnt_documentViewController:
                                                        filterMenuItemsForLongPressMenu:)]) {
            showMenu = [self.delegate rnt_documentViewController:self
                                 filterMenuItemsForLongPressMenu:menuController];
        }
    }
    
    return showMenu;
}

- (BOOL)toolManager:(PTToolManager *)toolManager shouldHandleLinkAnnotation:(PTAnnot *)annotation orLinkInfo:(PTLinkInfo *)linkInfo onPageNumber:(unsigned long)pageNumber
{
    BOOL result = [super toolManager:toolManager shouldHandleLinkAnnotation:annotation orLinkInfo:linkInfo onPageNumber:pageNumber];
    if (!result) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(toolManager:shouldHandleLinkAnnotation:orLinkInfo:onPageNumber:)]) {
        return [self.delegate toolManager:toolManager shouldHandleLinkAnnotation:annotation orLinkInfo:linkInfo onPageNumber:pageNumber];
    }
    
    return YES;
}

#pragma mark - <PTAnnotationToolbarDelegate>

- (BOOL)toolShouldGoBackToPan:(PTAnnotationToolbar *)annotationToolbar
{
    if ([self.delegate respondsToSelector:@selector(rnt_documentViewControllerShouldGoBackToPan:)]) {
        return [self.delegate rnt_documentViewControllerShouldGoBackToPan:self];
    }
    
    return [super toolShouldGoBackToPan:annotationToolbar];
}

- (void)annotationToolbarDidCancel:(PTAnnotationToolbar *)annotationToolbar
{
    [super annotationToolbarDidCancel:annotationToolbar];
    
    // If the top toolbar is disabled...
    if (![self isTopToolbarEnabled] &&
        // ...and the annotation toolbar is visible now...
        ![self isAnnotationToolbarHidden]) {
        // ...hide the toolbar.
        self.annotationToolbar.hidden = YES;
    }
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
    else if (!self.local && !self.documentLoaded && self.coordinatedDocument.fileURL) {
        self.needsDocumentLoaded = YES;
    }
}

- (void)pdfViewCtrl:(PTPDFViewCtrl *)pdfViewCtrl downloadEventType:(PTDownloadedType)type pageNumber:(int)pageNum message:(NSString *)message
{
    if (type == e_ptdownloadedtype_finished && !self.documentLoaded) {
        self.needsRemoteDocumentLoaded = YES;
    }
    
    [super pdfViewCtrl:pdfViewCtrl downloadEventType:type pageNumber:pageNum message:message];
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
