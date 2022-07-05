---
inject: true
to: src/DocumentView/DocumentView.tsx
after: // Hygen Generated Props
---
<% args = params.trim()
   if (args !== '') {
     args = 'event: { ' + args.replace(/\bint\b|\bdouble\b/g, 'number') + ' }'
   }
-%>
  <%= name %>: func<(<%- args %>) => void>(),<% -%>
