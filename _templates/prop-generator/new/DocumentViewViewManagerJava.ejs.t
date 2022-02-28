---
inject: true
to: android/src/main/java/com/pdftron/reactnative/viewmanagers/DocumentViewViewManager.java
after: // Hygen Generated Props
---

    @ReactProp(name = "<%= name %>")
    public void set<%= h.changeCase.pascalCase(name) %>(DocumentView documentView, <%= type %> <%= name %>) {
        documentView.set<%= h.changeCase.pascalCase(name) %>(<%= name %>);
    }