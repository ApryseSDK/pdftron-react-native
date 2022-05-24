---
inject: true
to: android/src/main/java/com/pdftron/reactnative/views/DocumentView.java
after: // Hygen Generated Props
---

    public void set<%= h.changeCase.pascalCase(name) %>(<%= h.getAndroidPropType(propType) %> <%= paramName %>) {

    }
