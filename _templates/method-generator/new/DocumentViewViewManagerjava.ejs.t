---
inject: true
to: android/src/main/java/com/pdftron/reactnative/viewmanagers/DocumentViewViewManager.java
after: // Hygen Generated Methods
---

    public <%- h.androidReturnType(returnType) %> <%= name %>(int tag, <%- h.androidParams(params, false) %>) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.<%= name %>(<%= h.androidArgs(params) %>);
        } else {
            throw new PDFNetException("", 0L, getName(), "<%= name %>", "Unable to find DocumentView.");
        }
    }
