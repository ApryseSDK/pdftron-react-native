---
inject: true
to: ios/RNTPTDocumentView.h
after: // Hygen Generated Props
---
<%# converting the React Native prop type into the corresponding iOS type, along with appropriate keywords -%>
<% type = propType
   if (type === 'bool') {
     type = '(nonatomic, assign) BOOL '
   } else if (type === 'string' || type === 'oneOf') {
     type = '(nonatomic, copy, nullable) NSString *'
   } else if (type === 'arrayOf') {
     type = '(nonatomic, copy, nullable) NSArray<NSString *> '
   } else {
     type = '(nonatomic, assign) ' + type + ' '
   }
-%>
@property <%- type %><%= name %>; <% -%>
