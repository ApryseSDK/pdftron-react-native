#import "RNPdftron.h"
#import <React/RCTLog.h>

#import <PDFNet/PDFNet.h>

@implementation RNPdftron

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(initialize:(nonnull NSString *)key)
{
    [PTPDFNet Initialize:key];
    RCTLogInfo(@"PDFNet version: %f", [PTPDFNet GetVersion]);
}

RCT_EXPORT_METHOD(enableJavaScript:(BOOL)enabled)
{
    [PTPDFNet EnableJavaScript:enabled];
}

@end
  
