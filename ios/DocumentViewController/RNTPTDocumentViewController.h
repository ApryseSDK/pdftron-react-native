#import <Tools/Tools.h>

NS_ASSUME_NONNULL_BEGIN

@class RNTPTDocumentViewController;

@protocol RNTPTDocumentViewControllerDelegate <PTDocumentViewControllerDelegate, PTToolManagerDelegate>
@required

- (void)rnt_documentViewControllerDocumentLoaded:(PTDocumentViewController *)documentViewController;

- (void)rnt_documentViewControllerDidZoom:(PTDocumentViewController *)documentViewController;

- (BOOL)rnt_documentViewControllerIsTopToolbarEnabled:(PTDocumentViewController *)documentViewController;

- (BOOL)rnt_documentViewControllerShouldGoBackToPan:(PTDocumentViewController *)documentViewController;

- (BOOL)rnt_documentViewController:(PTDocumentViewController *)documentViewController filterMenuItemsForAnnotationSelectionMenu:(UIMenuController *)menuController forAnnotation:(PTAnnot *)annot;

- (BOOL)rnt_documentViewController:(PTDocumentViewController *)documentViewController filterMenuItemsForLongPressMenu:(UIMenuController *)menuController;

- (void)rnt_documentViewController:(PTDocumentViewController *)documentViewController didSelectAnnotations:(NSArray<PTAnnot *> *)annotations onPageNumber:(int)pageNumber;

@end

@interface RNTPTDocumentViewController : PTDocumentViewController

@property (nonatomic, weak, nullable) id<RNTPTDocumentViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
