---
inject: true
to: src/DocumentView/DocumentView.tsx
at_line: 409
---

<%= name %> = (: ): Promise<void | {}> => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.<%= name %>(tag);
    }
    return Promise.resolve();
}
