#import "RNTPTDocumentController.h"

#import <Tools/Tools.h>

NS_ASSUME_NONNULL_BEGIN

@interface RNTPTCollaborationDocumentController : PTCollaborationDocumentController

@property (nonatomic, weak, nullable) id<RNTPTDocumentControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
