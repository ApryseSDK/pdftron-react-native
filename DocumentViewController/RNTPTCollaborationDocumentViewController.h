#import <Tools/Tools.h>

#import "RNTPTDocumentViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RNTPTCollaborationDocumentViewController : PTCollaborationDocumentViewController

@property (nonatomic, weak, nullable) id<RNTPTDocumentViewControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
