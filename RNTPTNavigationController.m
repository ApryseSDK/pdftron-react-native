#import "RNTPTNavigationController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNTPTNavigationController ()

@end

NS_ASSUME_NONNULL_END


@implementation RNTPTNavigationController

@dynamic delegate;

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
    BOOL allowed = YES;
    
    if ([self.delegate respondsToSelector:@selector(navigationController:
                                                    shouldSetToolbarHidden:
                                                    animated:)]) {
        allowed = [self.delegate navigationController:self
                               shouldSetToolbarHidden:hidden
                                             animated:animated];
    }

    if (allowed) {
        [super setToolbarHidden:hidden animated:animated];
    }
}

@end
