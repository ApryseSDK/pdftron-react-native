---
inject: true
to: android/src/main/java/com/pdftron/reactnative/viewmanagers/DocumentViewViewManager.java
after: // Hygen Generated Props
---

    @ReactProp(name = "<%= name %>")
    public void set<%= h.changeCase.pascalCase(name) %>(DocumentView documentView, <%= androidParam %> <%= paramName %>) {
        documentView.set<%= h.changeCase.pascalCase(name) %>(<%= paramName %>);
    }