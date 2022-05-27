---
inject: true
to: android/src/main/java/com/pdftron/reactnative/views/DocumentView.java
after: // Hygen Generated Event Listeners
---
<% putArgs = ''
   if (params !== '') {
     params.split(',').forEach(param => {
       argName = param.substring(0, param.indexOf(':')).trim()
       argType = param.substring(param.indexOf(':') + 1).trim()

       if (argType.startsWith('AnnotOptions.')) {
         argType = 'Map'
       } else if (argType.startsWith('Config.') || argType === 'string') {
         argType = 'String'
       } else if (argType.startsWith('Array<') && argType.endsWith('>')) {
         argType = 'Array'
       } else {
         argType = h.changeCase.upperCaseFirst(argType)
       }

       putArgs += '\n    // params.put' + argType + '(KEY_' + h.changeCase.constantCase(argName) + ', );'
     })
  }
-%>
    // uncomment and use to implement <%= name %>
    // WritableMap params = Arguments.createMap();
    // params.putString(<%= h.changeCase.constantCase(name) %>, <%= h.changeCase.constantCase(name) %>);<%- putArgs %>

    // onReceiveNativeEvent(params);
