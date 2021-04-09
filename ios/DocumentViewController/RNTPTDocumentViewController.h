#import <Tools/Tools.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RNTPTDocumentBaseViewControllerDelegate <PTToolManagerDelegate>
@required

- (void)rnt_documentViewControllerDocumentLoaded:(PTDocumentBaseViewController *)documentViewController;

- (void)rnt_documentViewControllerDidScroll:(PTDocumentBaseViewController *)documentViewController;

- (void)rnt_documentViewControllerDidZoom:(PTDocumentBaseViewController *)documentViewController;

- (void)rnt_documentViewControllerDidFinishZoom:(PTDocumentBaseViewController *)documentViewController;

- (void)rnt_documentViewControllerLayoutDidChange:(PTDocumentBaseViewController *)documentViewController;

- (BOOL)rnt_documentViewControllerIsTopToolbarEnabled:(PTDocumentBaseViewController *)documentViewController;

- (BOOL)rnt_documentViewControllerAreTopToolbarsEnabled:(PTDocumentBaseViewController *)documentViewController;

- (BOOL)rnt_documentViewControllerIsNavigationBarEnabled:(PTDocumentBaseViewController *)documentViewController;

- (BOOL)rnt_documentViewController:(PTDocumentBaseViewController *)documentViewController filterMenuItemsForAnnotationSelectionMenu:(UIMenuController *)menuController forAnnotation:(PTAnnot *)annot;

- (BOOL)rnt_documentViewController:(PTDocumentBaseViewController *)documentViewController filterMenuItemsForLongPressMenu:(UIMenuController *)menuController;

- (void)rnt_documentViewController:(PTDocumentBaseViewController *)documentViewController didSelectAnnotations:(NSArray<PTAnnot *> *)annotations onPageNumber:(int)pageNumber;

- (void)rnt_documentViewControllerTextSearchDidStart:(PTDocumentBaseViewController *)documentViewController;

- (void)rnt_documentViewControllerTextSearchDidFindResult:(PTDocumentBaseViewController *)documentViewController selection:(PTSelection *)selection;

@end

@class RNTPTDocumentViewController;

@protocol RNTPTDocumentViewControllerDelegate <PTDocumentViewControllerDelegate, RNTPTDocumentBaseViewControllerDelegate>
@required

- (BOOL)rnt_documentViewControllerShouldGoBackToPan:(PTDocumentViewController *)documentViewController;

@end

@interface RNTPTDocumentViewController : PTDocumentViewController

@property (nonatomic, weak, nullable) id<RNTPTDocumentViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
