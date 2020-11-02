#import "RNTPTDocumentViewController.h"

#import <Tools/Tools.h>

NS_ASSUME_NONNULL_BEGIN

@class RNTPTDocumentController;

@protocol RNTPTDocumentControllerDelegate <PTDocumentControllerDelegate, RNTPTDocumentBaseViewControllerDelegate>
@required

@end

@interface RNTPTDocumentController : PTDocumentController

@property (nonatomic, weak, nullable) id<RNTPTDocumentControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
