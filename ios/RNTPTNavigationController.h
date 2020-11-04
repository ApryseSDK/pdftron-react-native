#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RNTPTNavigationController;

@protocol RNTPTNavigationControllerDelegate <UINavigationControllerDelegate>
@required

- (BOOL)navigationController:(RNTPTNavigationController *)navigationController shouldSetNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated;

- (BOOL)navigationController:(RNTPTNavigationController *)navigationController shouldSetToolbarHidden:(BOOL)toolbarHidden animated:(BOOL)animated;

@end

@interface RNTPTNavigationController : UINavigationController

@property (nonatomic, weak, nullable) id<RNTPTNavigationControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
