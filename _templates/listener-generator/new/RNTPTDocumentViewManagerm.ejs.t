---
inject: true
to: ios/RNTPTDocumentViewManager.m
after: // Hygen Generated Event Listeners
---
<% args = ''
   if (params !== '') {
     params.split(',').forEach(param => {
       argName = param.substring(0, param.indexOf(':')).trim()
       argType = param.substring(param.indexOf(':') + 1).trim()

       if (argType.match(/int|double|boolean/) {
         args += '\n            @"' + argName + '": @(' + argName + '),'
       } else {
         args += '\n            @"' + argName + '": ' + argName + ','
       }
     })
   }
-%>
- (void)<%= name %>:(RNTPTDocumentView *)sender<%- params === '' ? '' : ' ' + h.iOSParams(params, false) %>
{
    if (sender.onChange) {
        sender.onChange(@{
            @"<%= name %>": @"<%= name %>",<%- args %>
        });
    }
}
