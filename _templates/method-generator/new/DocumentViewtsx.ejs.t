---
inject: true
to: src/DocumentView/DocumentView.tsx
after: // Hygen Generated Methods
---

<%= name %> = (: ): Promise<void | <%= reactType %> > => {
    const tag = findNodeHandle(this._viewerRef);
    if(tag != null) {
      return DocumentViewManager.<%= name %>(tag);
    }
    return Promise.resolve();
}
