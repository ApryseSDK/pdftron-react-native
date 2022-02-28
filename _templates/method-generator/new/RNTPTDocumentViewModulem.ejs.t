---
inject: true
to: ios/RNTPTDocumentViewModule.m
after: Hygen Generated Methods
---
<% parameter = "" -%>
<% arguments = "" -%>
<%  params.split(',').forEach((param)=> {  -%>
<% paramName = param.split(':')[1] %>
<% parameter +=  paramName + ':' + '('+param.split(':')[0] + '*)' + paramName + '\n\t\t\t\t'-%>
<% arguments +=  paramName+ ':' + paramName + ' '-%>
<% }) -%>
<% parameter = parameter.substr(0,parameter.length-5) -%>
RCT_REMAP_METHOD(<%= name %>,
                 <%= name %>ForDocumentViewTag:(nonnull NSNumber *)tag
                 <%= parameter %>
                 resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    @try {
        NSDictionary *result = [[self documentViewManager]  <%= name %>ForDocumentViewTag:tag <%= arguments %>];
        resolve(result);
    }
    @catch (NSException *exception) {
        reject(@"set_value_for_fields", @"Failed to set value on fields", [self errorFromException:exception]);
    }
}