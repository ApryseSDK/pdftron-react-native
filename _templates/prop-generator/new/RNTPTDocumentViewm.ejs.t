---
inject: true
to: ios/RNTPTDocumentView.m
after: Hygen Generated Props/Methods
---
<%# converting the React Native prop type into the corresponding iOS type -%>
<% type = propType
   if (type === 'bool') {
     type = 'BOOL'
   } else if (type === 'string' || type === 'oneOf') {
     type = 'NSString *'
   } else if (type === 'arrayOf') {
     type = 'NSArray *'
   }
-%>

- (void)set<%= h.changeCase.pascalCase(name) %>:(<%= type %>)<%= paramName %>
{

}<% -%>
