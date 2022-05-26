---
inject: true
to: src/DocumentView/DocumentView.tsx
after: // Hygen Generated Event Listeners
---
<% args = ''
   if (params !== '') {
     args += '{'
     params.split(',').forEach(param => {
       argName = param.split(':')[0].trim()
       args += '\n          \'' + argName + '\': event.nativeEvent.' + argName + ','
     })
     args += '\n        }'
   }
-%>
    } else if (event.nativeEvent.<%= name %>) {
      if (this.props.<%= name %>) {
        this.props.<%= name %>(<%- args %>);
      }<% -%>
