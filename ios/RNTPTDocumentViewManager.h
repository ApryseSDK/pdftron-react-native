//
//  RNTPTDocumentViewManager.h
//  RNPdftron
//
//  Copyright © 2018 PDFTron. All rights reserved.
//

#import "RNTPTDocumentView.h"

#import <React/RCTViewManager.h>

@interface RNTPTDocumentViewManager : RCTViewManager <RNTPTDocumentViewDelegate>

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, RNTPTDocumentView *> *documentViews;

- (NSString *)exportAnnotationsForDocumentViewTag:(NSNumber *)tag;
- (void)importAnnotationsForDocumentViewTag:(NSNumber *)tag xfdf:(NSString *)xfdfString;

@end
