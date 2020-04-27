#import <Tools/Tools.h>

NS_ASSUME_NONNULL_BEGIN

@class RNTPTDocumentViewController;

@protocol RNTPTDocumentViewControllerDelegate <PTDocumentViewControllerDelegate>
@required

- (void)rnt_documentViewControllerDocumentLoaded:(PTDocumentViewController *)documentViewController;

- (void)rnt_documentViewControllerDidZoom:(PTDocumentViewController *)documentViewController;

- (BOOL)rnt_documentViewControllerIsTopToolbarEnabled:(PTDocumentViewController *)documentViewController;

- (BOOL)rnt_documentViewControllerShouldGoBackToPan:(PTDocumentViewController *)documentViewController;

- (void)rnt_documentViewController:(PTDocumentViewController *)documentViewController filterMenuItemsForAnnotationSelectionMenu:(UIMenuController *)menuController;

@end

@interface RNTPTDocumentViewController : PTDocumentViewController

@property (nonatomic, weak, nullable) id<RNTPTDocumentViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
