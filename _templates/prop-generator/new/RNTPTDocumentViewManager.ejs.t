---
inject: true
to: ios/RNTPTDocumentViewManager.m
after: // Hygen Generated Props
---


RCT_CUSTOM_VIEW_PROPERTY(<%= name %>, <%= iOSParam %>, RNTPTDocumentView)
{
    if (json) {
        view.<%= paramName %> = [RCTConvert <%= iOSParam %>:json];
    }
}
