---
inject: true
to: android/src/main/java/com/pdftron/reactnative/viewmanagers/DocumentViewViewManager.java
after: // Hygen Generated Methods
---
<% parameters = params === '' ? '' : ', ' + h.androidParams(params, false)
-%>

    public <%- h.androidReturnType(returnType) %> <%= name %>(int tag<%- parameters %>) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.<%= name %>(<%= h.androidArgs(params) %>);
        } else {
            throw new PDFNetException("", 0L, getName(), "<%= name %>", "Unable to find DocumentView.");
        }
    }
