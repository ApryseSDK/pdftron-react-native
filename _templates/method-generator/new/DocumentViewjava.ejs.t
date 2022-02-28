---
inject: true
to: android/src/main/java/com/pdftron/reactnative/views/DocumentView.java
after: // Hygen Generated Methods
---
<% parameter = "" -%>
<% arguments = "" -%>
<%  params.split(',').forEach((param)=> {  -%>
<% parameter +=  param.replace(':',' ')+ ', ' -%>
<% }) -%>
<% parameter = parameter.substr(0,parameter.length-2) -%>
    public getField(<%= parameter%>){

    }