---
inject: true
to: android/src/main/java/com/pdftron/reactnative/modules/DocumentViewModule.java
after: // Hygen Generated Methods
---
<% parameter = "" %>
<%  params.split(',').forEach((param)=> {  %> 
<% parameter +=  'final ' +param.replace(':',' ')+ ', ' %> 
<% })%>
@ReactMethod
public void <%= name %>(<%= parameter %>final Promise promise) {
    getReactApplicationContext().runOnUiQueueThread(new Runnable() {
        @Override
        public void run() {
            try {
                WritableMap field = mDocumentViewInstance.<%= name %>(tag, fieldName);
                promise.resolve(field);
            } catch (Exception ex) {
                promise.reject(ex);
            }
        }
    });
}
