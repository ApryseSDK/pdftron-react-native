---
inject: true
to: ios/RNTPTDocumentViewManager.m
at_line: 36
---

RCT_CUSTOM_VIEW_PROPERTY(<%= name %>, <%= type %>, RNTPTDocumentView)
{
    if (json) {
        view.<%= name %> = [RCTConvert <%= type %>:json];
    }
}
