---
inject: true
to: android/src/main/java/com/pdftron/reactnative/modules/DocumentViewModule.java
after: // Hygen Generated Methods
---

    @ReactMethod
    public void <%= name %>(<%- h.androidParams(params, true) %>, final Promise promise) {
        getReactApplicationContext().runOnUiQueueThread(new Runnable() {
            @Override
            public void run() {
                try {
                    WritableMap field = mDocumentViewInstance.<%= name %>(tag, <%= h.androidArgs(params) %>);
                    promise.resolve(field);
                } catch (Exception ex) {
                    promise.reject(ex);
                }
            }
        });
    }
