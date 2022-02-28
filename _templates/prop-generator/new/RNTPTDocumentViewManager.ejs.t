---
inject: true
to: ios/RNTPTDocumentViewManager.m
after: // Hygen Generated Props
---

RCT_CUSTOM_VIEW_PROPERTY(<%= name %>, <%= type %>, RNTPTDocumentView)
{
    if (json) {
        view.<%= name %> = [RCTConvert <%= type %>:json];
    }
}
