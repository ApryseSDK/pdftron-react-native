---
inject: true
to: src/DocumentView/DocumentView.tsx
after: // Hygen Generated Event Listeners
---
<% args = ''
   if (params !== '') {
     args += '{\n          '
     params.split(',').forEach(param => {
       argName = param.split(':')[0].trim()
       args += '\'' + argName + '\': event.nativeEvent.' + argName + '\n'
     })
     args += '        }'
   }
-%>
    } else if (event.nativeEvent.<%= name %>) {
      if (this.props.<%= name %>) {
        this.props.<%= name %>(<%= args %>);
      }<% -%>
