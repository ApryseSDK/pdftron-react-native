---
inject: true
to: src/DocumentView/DocumentView.tsx
after: // Hygen Generated Props
---

<% type = propType.trim()
   if (type === 'oneOf' || type === 'arrayOf') {
     type = type + '<' + configType + '>(' + configType + ')'
   } else if (type === 'int' || type === 'double') {
     type = 'PropTypes.number'
   } else {
     type = 'PropTypes.' + type
   }
-%>
  <%= name %>: <%- type %>, <% -%>
