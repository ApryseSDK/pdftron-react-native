---
inject: true
to: android/src/main/java/com/pdftron/reactnative/viewmanagers/DocumentViewViewManager.java
after: // Hygen Generated Methods
---
<% parameter = "" -%>
<% arguments = "" -%>
<%  params.split(',').forEach((param)=> {  -%>
<% parameter +=  param.replace(':',' ')+ ', ' -%>
<% arguments +=  param.split(':')[1]+ ', ' -%>
<% }) -%>
<% arguments = arguments.substr(0,arguments.length-2) -%>
<% parameter = parameter.substr(0,parameter.length-2) -%>
    public <%= name %>(int tag, <%= parameter %>) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.<%= name %>(<%= arguments %>);
        } else {
            throw new PDFNetException("", 0L, getName(), "<%= name %>", "Unable to find DocumentView.");
        }
    }