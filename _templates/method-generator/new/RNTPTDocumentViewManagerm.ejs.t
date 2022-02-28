---
inject: true
to: ios/RNTPTDocumentViewManager.m
after: Hygen Generated Methods
---
<% parameter = "" -%>
<% arguments = "" -%>
<%  params.split(',').forEach((param)=> {  -%>
<% paramName = param.split(':')[1] %>
<% parameter +=  paramName + ':' + '('+param.split(':')[0] + '*)' + paramName + ' '-%>
<% arguments +=  paramName+ ':' + paramName + ' '-%>
<% }) -%>
<% parameter = parameter.substr(0,parameter.length-5) -%>
- ( *)<%= name %>ForDocumentViewTag:(NSNumber *)tag <%=parameter%>
{
    RNTPTDocumentView *documentView = self.documentViews[tag];
    if (documentView) {
        return [documentView getField:<%= arguments%>];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Unable to get field for tag" userInfo:nil];
        return nil;
    }
}