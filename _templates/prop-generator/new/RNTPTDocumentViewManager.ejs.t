---
inject: true
to: ios/RNTPTDocumentViewManager.m
after: // Hygen Generated Props
---
<%# converting the React Native prop type into the corresponding iOS type as an argument to the RCTConvert function -%>
<% type = propType
   if (type === 'bool') {
     type = 'BOOL'
   } else if (type === 'string' || type === 'oneOf') {
     type = 'NSString'
   } else if (type === 'arrayOf') {
     type = 'NSArray'
   }
-%>
RCT_CUSTOM_VIEW_PROPERTY(<%= name %>, <%= type %>, RNTPTDocumentView)
{
    if (json) {
        view.<%= paramName %> = [RCTConvert <%= type %>:json];
    }
}
