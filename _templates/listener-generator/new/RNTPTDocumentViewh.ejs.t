---
inject: true
to: ios/RNTPTDocumentView.h
after: // Hygen Generated Event Listeners
---
- (void)<%= name %>:(RNTPTDocumentView *)sender<%- params === '' ? '' : ' ' + h.iOSParams(params, false) %>;
