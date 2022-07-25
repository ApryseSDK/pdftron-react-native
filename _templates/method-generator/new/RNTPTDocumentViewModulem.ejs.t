---
inject: true
to: ios/RNTPTDocumentViewModule.m
after: Hygen Generated Methods
---
<% returnVar = h.iOSReturnType(returnType)
   if (returnVar === 'void') {
     returnVar = ''
   } else if (!returnVar.endsWith('*')) {
     returnVar = returnVar + ' result = '
   } else {
     returnVar = returnVar + 'result = '
   }
-%>
RCT_REMAP_METHOD(<%= name %>,
                 <%= name %>ForDocumentViewTag:(nonnull NSNumber *)tag<%= params === '' ? '' : '\n                 ' + h.iOSParams(params, true) %>
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        <%= returnVar %>[[self documentViewManager] <%= name %>ForDocumentViewTag:tag<%= params === '' ? '' : ' ' + h.iOSArgs(params) %>];
        resolve(<%= returnType === 'void' ? 'nil' : 'result' %>);
    }
    @catch (NSException *exception) {
        reject(@"<%= h.changeCase.snakeCase(name) %>", @"Failed to <%= h.changeCase.noCase(name) %>", [self errorFromException:exception]);
    }
}
