---
inject: true
to: android/src/main/java/com/pdftron/reactnative/modules/DocumentViewModule.java
after: // Hygen Generated Methods
---
<% parameters = params === '' ? '' : h.androidParams(params, true) + ', '
   args = params === '' ? '' : ', ' + h.androidArgs(params)
   returnVar = returnType === 'void' ? '' : h.androidReturnType(returnType) + ' field = '
-%>

    @ReactMethod
    public void <%= name %>(<%- parameters %>final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    <%= returnVar %>mDocumentViewInstance.<%= name %>(tag<%= args %>);
                    promise.resolve(<%= returnType === 'void' ? 'null' : 'field' %>);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }
