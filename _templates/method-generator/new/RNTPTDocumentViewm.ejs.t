---
inject: true
to: ios/RNTPTDocumentView.m
after: Hygen Generated Props/Methods
---
<% parameters = ''
   if (params !== '') {
     parameters = h.iOSParams(params)
     // chopping off the parameter name of the first parameter to follow proper syntax
     parameters = ':' + parameters.substring(parameters.indexOf(':') + 1)
   }
-%>

- (<%= h.iOSReturnType(returnType) %>)<%= name %><%= parameters %>
{

}<% -%>
