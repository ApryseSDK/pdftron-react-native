---
inject: true
to: ios/RNTPTDocumentViewManager.m
after: Hygen Generated Methods
---
<% args = h.iOSArgs(params) -%>
- (<%= h.iOSReturnType(returnType) %>)<%= name %>ForDocumentViewTag:(NSNumber *)tag<%= params === '' ? '' : ' ' + h.iOSParams(params) %>
{
    RNTPTDocumentView *documentView = self.documentViews[tag];
    if (documentView) {
        <%= returnType === 'void' ? '' : 'return ' %>[documentView <%= name %><%= params === '' ? '' : ':' + args.substring(args.indexOf(':') + 1) %>];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unable to get field for tag" userInfo:nil];<%= returnType === 'void' ? '' : '\n        return nil;' %>
    }
}
