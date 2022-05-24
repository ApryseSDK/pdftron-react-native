---
inject: true
to: src/DocumentView/DocumentView.tsx
after: // Hygen Generated Methods
---

  <%= name %> = (<%= params %>): Promise<void | <%= returnType %>> => {
    const tag = findNodeHandle(this._viewerRef);
    if (tag != null) {
      return DocumentViewManager.<%= name %>(tag);
    }
    return Promise.resolve();
  }
