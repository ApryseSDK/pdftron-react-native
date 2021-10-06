
#if __has_include(<React/RCTBridgeModule.h>)
#import <React/RCTBridgeModule.h>
#else
#import "RCTBridgeModule.h"
#endif

@class PTPDFDoc;
@interface RNPdftron : NSObject <RCTBridgeModule>

+(NSString*)exportAsImageHelper:(PTPDFDoc*)doc pageNumber:(int)pageNumber dpi:(int)dpi exportFormat:(NSString*)imageFormat;

@end
  
