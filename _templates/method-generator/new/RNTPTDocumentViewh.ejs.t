---
inject: true
to: ios/RNTPTDocumentView.h
after: Hygen Generated Methods
---
<% parameters = h.iOSParams(params) -%>
- (<%= h.iOSReturnType(returnType) %>)<%= name %>:<%= parameters.substring(parameters.indexOf(':') + 1) %>;
