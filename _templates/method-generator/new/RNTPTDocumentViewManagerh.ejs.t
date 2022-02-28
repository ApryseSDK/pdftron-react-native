---
inject: true
to: ios/RNTPTDocumentViewManager.h
after: Hygen Generated Methods
---
<% parameter = "" -%>
<%  params.split(',').forEach((param)=> {  -%>
<% paramName = param.split(':')[1] %>
<% parameter +=  paramName + ':' + '('+param.split(':')[0] + '*)' + paramName + ' '-%>
<% }) -%>
<% parameter = parameter.substr(0,parameter.length-5) -%>
- ( *)<%= name %>ForDocumentViewTag:(NSNumber *)tag <%=parameter%>;