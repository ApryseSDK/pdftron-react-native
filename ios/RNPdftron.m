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

RCT_EXPORT_METHOD(pdfFromOffice:(NSString *)docxPath options:(NSDictionary*)options resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        PTPDFDoc* pdfDoc = [[PTPDFDoc alloc] init];
        PTOfficeToPDFOptions* conversionOptions = [[PTOfficeToPDFOptions alloc] init];
        
        if (options != Nil) {
            if (options[@"applyPageBreaksToSheet"]) {
                [conversionOptions SetApplyPageBreaksToSheet:[[options objectForKey:@"applyPageBreaksToSheet"] boolValue]];
            }
            
            if (options[@"displayChangeTracking"]) {
                [conversionOptions SetDisplayChangeTracking:[[options objectForKey:@"displayChangeTracking"] boolValue]];
            }
            
            if (options[@"excelDefaultCellBorderWidth"]) {
                [conversionOptions SetExcelDefaultCellBorderWidth:[[options objectForKey:@"excelDefaultCellBorderWidth"] doubleValue]];
            }
            
            if (options[@"excelMaxAllowedCellCount"]) {
                [conversionOptions SetExcelMaxAllowedCellCount:[[options objectForKey:@"excelMaxAllowedCellCount"] doubleValue]];
            }
            
            if (options[@"locale"]) {
                [conversionOptions SetLocale:[[options objectForKey:@"locale"] stringValue]];
            }

        }
        
        [PTConvert OfficeToPDF:pdfDoc in_filename:docxPath options:conversionOptions];
        
        NSString* fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"pdf"];
        NSString* resultPdfPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        
        BOOL shouldUnlock = NO;
        @try {
            [pdfDoc Lock];
            shouldUnlock = YES;
            
            [pdfDoc SaveToFile:resultPdfPath flags:0];
        } @catch (NSException* exception) {
            NSLog(@"Exception: %@: %@", exception.name, exception.reason);
        } @finally {
            if (shouldUnlock) {
                [pdfDoc Unlock];
            }
        }

        resolve(resultPdfPath);
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@, %@", exception.name, exception.reason);
        reject(@"generation_failed", @"Failed to generate document from Office doc", [self errorFromException:exception]);
    }    
}

RCT_EXPORT_METHOD(pdfFromOfficeTemplate:(NSString *)docxPath json:(NSDictionary *)json resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        PTPDFDoc* pdfDoc = [[PTPDFDoc alloc] init];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        PTOfficeToPDFOptions* options = [[PTOfficeToPDFOptions alloc] init];
        [options SetTemplateParamsJson:jsonString];
        [PTConvert OfficeToPDF:pdfDoc in_filename:docxPath options:options];
        
        NSString* fileName = [[NSUUID UUID].UUIDString stringByAppendingPathExtension:@"pdf"];
        NSString* resultPdfPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        
        BOOL shouldUnlock = NO;
        @try {
            [pdfDoc Lock];
            shouldUnlock = YES;
            
            [pdfDoc SaveToFile:resultPdfPath flags:0];
        } @catch (NSException* exception) {
            NSLog(@"Exception: %@: %@", exception.name, exception.reason);
        } @finally {
            if (shouldUnlock) {
                [pdfDoc Unlock];
            }
        }

        resolve(resultPdfPath);
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@, %@", exception.name, exception.reason);
        reject(@"generation_failed", @"Failed to generate document from template", [self errorFromException:exception]);
    }    
}

RCT_EXPORT_METHOD(exportAsImage:(int)pageNumber dpi:(int)dpi exportFormat:(NSString*)exportFormat filePath:(NSString*)filePath resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        PTPDFDoc * doc = [[PTPDFDoc alloc] initWithFilepath:filePath];
        NSString * resultImagePath = [RNPdftron exportAsImageHelper:doc pageNumber:pageNumber dpi:dpi exportFormat:exportFormat];
        
        resolve(resultImagePath);
    }
    @catch (NSException* exception) {
        NSLog(@"Exception: %@, %@", exception.name, exception.reason);
        reject(@"generation_failed", @"Failed to generate image from file", [self errorFromException:exception]);
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

+(NSString*)exportAsImageHelper:(PTPDFDoc*)doc pageNumber:(int)pageNumber dpi:(int)dpi exportFormat:(NSString*)exportFormat
{
    NSString * resultImagePath = nil;
    BOOL shouldUnlock = NO;
    @try {
        [doc LockRead];
        shouldUnlock = YES;

        if (pageNumber <= [doc GetPageCount] && pageNumber >= 1) {
            PTPDFDraw *draw = [[PTPDFDraw alloc] initWithDpi:dpi];
            NSString* tempDir = NSTemporaryDirectory();
            NSString* fileName = [NSUUID UUID].UUIDString;
            resultImagePath = [tempDir stringByAppendingPathComponent:fileName];
            resultImagePath = [resultImagePath stringByAppendingPathExtension:exportFormat];
            PTPage * exportPage = [doc GetPage:pageNumber];
            [draw Export:exportPage filename:resultImagePath format:exportFormat];
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception: %@: %@", exception.name, exception.reason);
    } @finally {
        if (shouldUnlock) {
            [doc UnlockRead];
        }
    }
    return resultImagePath;
}



@end
  
