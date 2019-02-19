//
//  RNTPTPDFViewCtrlManager.m
//  RNPdftron
//
//  Copyright © 2018 PDFTron. All rights reserved.
//

#import "RNTPTPDFViewCtrlManager.h"
#import "RNTPTPDFViewCtrl.h"

@implementation RNTPTPDFViewCtrlManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    // Create a new PDFViewCtrl
    RNTPTPDFViewCtrl* pdfViewCtrl = [[RNTPTPDFViewCtrl alloc] init];
    
    _toolManager = [[PTToolManager alloc] initWithPDFViewCtrl:pdfViewCtrl];
    [pdfViewCtrl setToolDelegate:_toolManager];
    [_toolManager changeTool:[PTPanTool class]];
    
    return pdfViewCtrl;
}

RCT_CUSTOM_VIEW_PROPERTY(document, NSString, RNTPTPDFViewCtrl)
{
    if (json && [RCTConvert NSString:json]) {
        // Get the path to document in the app bundle.
        NSString* pdfPath = [[NSBundle mainBundle] pathForResource:json ofType:@"pdf"];
        // Instantiate a new PDFDoc with the path to the file.
        PTPDFDoc* docToOpen = [[PTPDFDoc alloc] initWithFilepath:pdfPath];
        // Set the document to display
        [view SetDoc:docToOpen];
    }
}

@end
