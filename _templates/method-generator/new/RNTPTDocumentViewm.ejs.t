---
inject: true
to: ios/RNTPTDocumentView.m
after: Hygen Generated Props/Methods
---
<% parameters = h.iOSParams(params) -%>

- (<%= h.iOSReturnType(returnType) %>)<%= name %>:<%= parameters.substring(parameters.indexOf(':') + 1) %>
{

}<% -%>
