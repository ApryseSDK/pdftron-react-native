---
inject: true
to: android/src/main/java/com/pdftron/reactnative/utils/Constants.java
after: // Hygen Generated Event Listeners
---
    public static final String <%= h.changeCase.constantCase(name) %> = "<%= name %>";<% -%>
