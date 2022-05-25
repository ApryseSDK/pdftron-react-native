---
inject: true
to: ios/RNTPTDocumentViewManager.h
after: Hygen Generated Methods
---
- (<%= h.iOSReturnType(returnType) %>)<%= name %>ForDocumentViewTag:(NSNumber *)tag <%= h.iOSParams(params) %>;
