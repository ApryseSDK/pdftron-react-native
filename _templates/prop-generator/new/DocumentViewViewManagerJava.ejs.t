---
inject: true
to: android/src/main/java/com/pdftron/reactnative/viewmanagers/DocumentViewViewManager.java
at_line: 62
---

    @ReactProp(name = "<%= name %>")
    public void set<%= h.changeCase.pascalCase(name) %>(DocumentView documentView, <%= type %> pageChangeOnTap) {
        documentView.set<%= h.changeCase.pascalCase(name) %>(pageChangeOnTap);
    }
