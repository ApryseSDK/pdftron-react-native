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

RCT_REMAP_METHOD(encryptDocument,
                 encryptDocumentForFilePath:(NSString *)filePath
                 password:(NSString *)password
                 currentPassword:(NSString *)currentPassword
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSString *oldPassword = currentPassword;
        if (!oldPassword) {
            oldPassword = @"";
        }
        
        PTPDFDoc *pdfDoc = [[PTPDFDoc alloc] initWithFilepath:filePath];
        if ([pdfDoc InitStdSecurityHandler:oldPassword]) {
            [self setPassword:password onPDFDoc:pdfDoc];
            [pdfDoc Lock];
            [pdfDoc SaveToFile:filePath flags:e_ptremove_unused];
            [pdfDoc Unlock];
            resolve(nil);
        }
        else {
            reject(@"password", @"Current password is incorrect.", nil);
        }
    }
    @catch (NSException *exception) {
        reject(@"encrypt_failed", @"Failed to encrypt document", [self errorFromException:exception]);
    }
}

RCT_EXPORT_METHOD(getVersion:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        resolve([@"PDFNet " stringByAppendingFormat:@"%f", [PTPDFNet GetVersion]]);
    }
    @catch (NSException *exception) {
        reject(@"get_failed", @"Failed to get PDFNet version", [self errorFromException:exception]);
    }
}

RCT_EXPORT_METHOD(getPlatformVersion:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        resolve([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }
    @catch (NSException *exception) {
        reject(@"get_failed", @"Failed to get platform version", [self errorFromException:exception]);
    }
}

- (void)setPassword:(NSString *)password onPDFDoc:(PTPDFDoc *)pdfDoc
{
    if (!pdfDoc) {
        return;
    }
    
    BOOL shouldUnlock = NO;
    @try {
        [pdfDoc Lock];
        shouldUnlock = YES;
        
        // remove all security on the document
        [pdfDoc RemoveSecurity];
        if (password.length > 0) {
            // Set a new password required to open a document
            PTSecurityHandler *newHandler = [[PTSecurityHandler alloc] initWithCrypt_type:e_ptAES];
            [newHandler ChangeUserPassword:password];
            
            // Set Permissions
            [newHandler SetPermission:e_ptprint value:YES];
            
            // Note: document takes ownership of newHandler
            [pdfDoc SetSecurityHandler:newHandler];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@, %@", exception.name, exception.reason);
    }
    @finally {
        if (shouldUnlock) {
            [pdfDoc Unlock];
        }
    }
}

- (NSError *)errorFromException:(NSException *)exception
{
    return [NSError errorWithDomain:@"com.pdftron.react-native" code:0 userInfo:
            @{
                NSLocalizedDescriptionKey: exception.name,
                NSLocalizedFailureReasonErrorKey: exception.reason,
            }];
}

@end
  
