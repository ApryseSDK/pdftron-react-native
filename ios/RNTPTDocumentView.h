#import <Tools/Tools.h>
#import <React/RCTComponent.h>

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RNTPTDocumentView;

@protocol RNTPTDocumentViewDelegate <NSObject>
@optional
- (void)documentViewAttachedToWindow:(RNTPTDocumentView *)documentView;
- (void)documentViewDetachedFromWindow:(RNTPTDocumentView *)documentView;

- (void)navButtonClicked:(RNTPTDocumentView *)sender;
- (void)documentLoaded:(RNTPTDocumentView *)sender;
- (void)documentError:(RNTPTDocumentView *)sender error:(nullable NSString *)error;
- (void)pageChanged:(RNTPTDocumentView *)sender previousPageNumber:(int)previousPageNumber;
- (void)zoomChanged:(RNTPTDocumentView *)sender zoom:(double)zoom;

- (void)annotationsSelected:(RNTPTDocumentView *)sender annotations:(NSArray<NSDictionary<NSString *, id> *> *)annotations;

- (void)annotationChanged:(RNTPTDocumentView *)sender annotation:(NSDictionary *)annotation action:(NSString *)action;

- (void)exportAnnotationCommand:(RNTPTDocumentView *)sender action:(NSString *)action xfdfCommand:(NSString *)xfdfCommand;

- (void)annotationMenuPressed:(RNTPTDocumentView *)sender annotationMenu:(NSString *)annotationMenu annotations:(NSArray<NSDictionary<NSString *, id> *> *)annotations;

- (void)longPressMenuPressed:(RNTPTDocumentView *)sender longPressMenu:(NSString *)longPressMenu longPressText:(NSString *)longPressText;

@end

@interface RNTPTDocumentView : UIView

@property (nonatomic, copy, nullable) NSArray<NSString *> *disabledElements;
@property (nonatomic, copy, nullable) NSArray<NSString *> *disabledTools;


// annotation selection menu customization
@property (nonatomic, copy, nullable) NSArray<NSString *> *overrideAnnotationMenuBehavior;
@property (nonatomic, copy, nullable) NSArray<NSString *> *overrideBehavior;
@property (nonatomic, copy, nullable) NSArray<NSString *> *hideAnnotMenuTools;

// long-press menu customization

@property (nonatomic, copy, nullable) NSArray<NSString *> *overrideLongPressMenuBehavior;
@property (nonatomic, copy, nullable) NSArray<NSString *> *longPressMenuItems;

// viewer options
@property (nonatomic, assign) BOOL nightModeEnabled;
@property (nonatomic, assign) BOOL topToolbarEnabled;
@property (nonatomic, assign) BOOL bottomToolbarEnabled;
@property (nonatomic, assign) BOOL pageIndicatorEnabled;
@property (nonatomic, assign) BOOL pageIndicatorShowsOnPageChange;
@property (nonatomic, assign) BOOL pageIndicatorShowsWithControls;
@property (nonatomic, assign) BOOL autoSaveEnabled;

@property (nonatomic, copy, nullable) NSString *password;
@property (nonatomic, copy, nullable) NSString *document;
@property (nonatomic, getter=isBase64String) BOOL base64String;
@property (nonatomic) int initialPageNumber;
@property (nonatomic) int pageNumber;
@property (nonatomic, assign) BOOL showNavButton;
@property (nonatomic, copy, nullable) NSString *navButtonPath;
@property (nonatomic, copy, nullable) NSDictionary<NSString *, NSString *> *customHeaders;
@property (nonatomic, assign, getter=isReadOnly) BOOL readOnly;

@property (nonatomic, copy) NSString *fitMode;
@property (nonatomic, copy) NSString *layoutMode;

@property (nonatomic, copy, nullable) NSArray<NSString *> *annotationMenuItems;

@property (nonatomic, assign) BOOL pageChangeOnTap;

@property (nonatomic, assign, getter=isThumbnailViewEditingEnabled) BOOL thumbnailViewEditingEnabled;

@property (nonatomic, copy) NSString *annotationAuthor;

@property (nonatomic) BOOL continuousAnnotationEditing;

@property (nonatomic) BOOL showSavedSignatures;

@property (nonatomic, assign, getter=isCollabEnabled) BOOL collabEnabled;

@property (nonatomic, copy, nullable) NSString *currentUser;

@property (nonatomic, copy, nullable) NSString *currentUserName;

@property (nonatomic, assign) BOOL selectAnnotationAfterCreation;

@property (nonatomic, strong, nullable) PTCollaborationManager *collaborationManager;

@property (nonatomic, copy, nullable) RCTBubblingEventBlock onChange;

@property (nonatomic, weak, nullable) id <RNTPTDocumentViewDelegate> delegate;

#pragma mark - Methods

- (void)setToolMode:(NSString *)toolMode;

- (BOOL)commitTool;

- (int)getPageCount;

- (nullable NSString *)exportAnnotationsWithOptions:(NSDictionary *)options;
- (void)importAnnotations:(NSString *)xfdfString;

- (void)flattenAnnotations:(BOOL)formsOnly;

- (void)deleteAnnotations:(NSArray *)annotations;

- (void)saveDocumentWithCompletionHandler:(void (^)(NSString * _Nullable filePath))completionHandler;

- (void)setFlagForFields:(NSArray<NSString *> *)fields setFlag:(PTFieldFlag)flag toValue:(BOOL)value;

- (void)setValueForFields:(NSDictionary<NSString *, id> *)map;

- (void)importAnnotationCommand:(NSString *)xfdfCommand initialLoad:(BOOL)initialLoad;

@end

NS_ASSUME_NONNULL_END
