---
inject: true
to: src/DocumentView/DocumentView.tsx
after: // Hygen Generated Methods
---
<% promiseType = returnType
   if (promiseType === 'void') {
     promiseType = 'Promise<void>'
   } else {
     promiseType = 'Promise<void | ' + promiseType + '>'
   }
   promiseType = promiseType.replace(/\bint\b|\bdouble\b/g, 'number');
   parameters = params.replace(/\bint\b|\bdouble\b/g, 'number');
-%>
  <%= name %> = (<%- parameters %>): <%- promiseType %> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.<%= name %>(tag<%= params === '' ? '' : ', ' + h.androidArgs(params) %>);
    }
    return Promise.resolve();
  }
