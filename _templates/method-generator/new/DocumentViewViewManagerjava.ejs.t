---
inject: true
to: android/src/main/java/com/pdftron/reactnative/viewmanagers/DocumentViewViewManager.java
after: // Hygen Generated Methods
---

    public <%= name %>(int tag, <%= h.parameterize %>) throws PDFNetException {
        DocumentView documentView = mDocumentViews.get(tag);
        if (documentView != null) {
            return documentView.<%= name %>(<%= h.argumenterize(params) %>);
        } else {
            throw new PDFNetException("", 0L, getName(), "<%= name %>", "Unable to find DocumentView.");
        }
    }