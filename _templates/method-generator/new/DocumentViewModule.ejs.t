---
inject: true
to: android/src/main/java/com/pdftron/reactnative/modules/DocumentViewModule.java
after: // Hygen Generated Methods
---
<% parameter = "" -%>
<% arguments = "" -%>
<%  params.split(',').forEach((param)=> {  -%>
<% parameter +=  'final ' +param.replace(':',' ')+ ', ' -%>
<% arguments +=  param.split(':')[1]+ ', ' -%>
<% }) -%>
<% arguments = arguments.substr(0,arguments.length-2) -%>
    @ReactMethod
    public void <%= name %>(<%= parameter %>final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    WritableMap field = mDocumentViewInstance.<%= name %>(tag, <%= arguments %>);
                    promise.resolve(field);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }
