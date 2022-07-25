---
inject: true
to: android/src/main/java/com/pdftron/reactnative/utils/Constants.java
after: // Hygen Generated Keys
---
<% keys = ''
   if (params !== '') {
     params.split(',').forEach(param => {
       argName = param.split(':')[0].trim()
       keys += '    public static final String KEY_' + h.changeCase.constantCase(argName) + ' = "' + argName + '";\n'
     })
     keys = keys.substring(0, keys.length - 1)
  }
-%>
<%- keys %><% -%>
