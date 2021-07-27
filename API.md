# PDFTron React Native API

## RNPdftron

RNPdftron contains static methods for global library initialization, configuration, and utility methods.

### initialize
Initializes PDFTron SDK with your PDFTron commercial license key. You can run PDFTron in demo mode by passing an empty string.

Parameters:

Name | Type | Description
--- | --- | ---
licenseKey | string | your PDFTron license key

```js
RNPdftron.initialize('your_license_key');
```

### enableJavaScript
Enables JavaScript for PDFTron SDK, by default it is enabled.

Parameters:

Name | Type | Description
--- | --- | ---
enabled | bool | whether to enable or disable JavaScript

```js
RNPdftron.enableJavaScript(true);
```

### getVersion
Gets the current PDFNet version.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
version | string | current PDFNet version

```js
RNPdftron.getVersion().then((version) => {
  console.log("Current PDFNet version:", version);
});
```

### getPlatformVersion
Gets the version of current platform (Android/iOS).

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
platformVersion | string | current platform version (Android/iOS)

```js
RNPdftron.getPlatformVersion().then((platformVersion) => {
  console.log("App currently running on:", platformVersion);
});
```

### getSystemFontList
Gets the font list available on the OS (Android only).
This is typically useful when you are mostly working with non-ascii characters in the viewer.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
fontList | string | the font list available on Android

```js
RNPdftron.getSystemFontList().then((fontList) => {
  console.log("OS font list:", fontList);
});
```

### clearRubberStampCache
Clear the information and bitmap cache for rubber stamps (Android only).
This is typically useful when the content of rubber stamps has been changed in the viewer.

Returns a promise.

```js
RNPdftron.clearRubberStampCache().then(() => {
  console.log("Rubber stamp cache cleared");
});
```

### encryptDocument
Encrypts (password-protect) a document. **Note**: This function does not lock the document it cannot be used it while the document is opened in the viewer.

Parameters:

Name | Type | Description
--- | --- | ---
file path | string | the local file path to the file
password | string | the password you would like to set
current password | string | the current password, use empty string if no password

Returns a promise.

Example:

```js
RNPdftron.encryptDocument("/sdcard/Download/new.pdf", "1111", "").then(() => {
  console.log("done password");
});
```

### pdfFromOfficeTemplate
Generates a PDF using a template in the form of an Office document and replacement data in the form of a JSON object.
For more information please see our [template guide](https://www.pdftron.com/documentation/core/guides/generate-via-template/).

Parameters:

Name | Type | Description
--- | --- | ---
docxPath | string | the local file path to the template file
json | object | the replacement data in the form of a JSON object

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
resultPdfPath | string | the local file path to the generated PDF 

The user is responsible for cleaning up the temporary file that is generated.

Example:

```js
RNPdftron.pdfFromOfficeTemplate("/sdcard/Download/red.docx", json).then((resultPdfPath) => {
  console.log(resultPdfPath);
});
```

## DocumentView - Props

A React component for displaying documents of different types such as PDF, docx, pptx, xlsx and various image formats.

### Open a Document

#### document
string, required

The path or url to the document.

Example:

```js
<DocumentView
  document={'https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_about.pdf'}
/>
```

#### password
string, optional

The password of the document, if any.

Example:

```js
<DocumentView
  password={'password'}
/>
```

#### isBase64String
bool, optional, defaults to false

If true, [`document`](#document) prop will be treated as a base64 string. If it is not the base64 string of a pdf file, [`base64FileExtension`](#base64FileExtension) is required. 

When viewing a document initialized with a base64 string (i.e. a memory buffer), a temporary file is created on Android and iOS.

```js
<DocumentView
  isBase64String={true}
  document={'...'} // base 64 string
/>
```

#### base64FileExtension
string, required if using base64 string of a non-pdf file, defaults to ".pdf"

The file extension for the base64 string in [`document`](#document), if [`isBase64String`](#isBase64String) is true.

```js
<DocumentView
  isBase64String={true}
  document={'...'} // base 64 string
  base64FileExtension={'.jpeg'}
/>
```

#### customHeaders
object, optional

Defines custom headers to use with HTTP/HTTPS requests.

```js
<DocumentView
  customHeaders={{headerKey: 'headerValue'}}
/>
```

#### readOnly
bool, optional, defaults to false

Defines whether the viewer is read-only. If true, the UI will not allow the user to change the document.

```js
<DocumentView
  readOnly={true}
/>
```
#### defaultEraserType
string, optional

Sets the default eraser tool type. Value only applied after a clean install. Android only.
Example:

```js
<DocumentView
  defaultEraserType={Config.EraserType.hybrideEraser}
/>
```

#### exportPath
string, optional

Sets the folder path for all save options, this defaults to the app cache path. Android only.
Example:

```js
<DocumentView
  exportPath="/data/data/com.example/cache/test"
/>
```

#### openUrlPath
string, optional

Sets the cache folder used to cache PDF files opened using a http/https link, this defaults to the app cache path. Android only.
Example:

```js
<DocumentView
  openUrlPath="/data/data/com.example/cache/test"
/>
```

#### saveStateEnabled
bool, optional, default to true

Sets whether to remember the last visited page and zoom for a document if it gets opened again.
Example:

```js
<DocumentView
  saveStateEnabled={false}
/>
```

#### openSavedCopyInNewTab
bool, optional, default to true, Android only.

Sets whether the new saved file should open after saving.
Example:

```js
<DocumentView
  openSavedCopyInNewTab={false}
/>
```

#### onDocumentLoaded
function, optional

This function is called when the document finishes loading.

```js
<DocumentView
  onDocumentLoaded = {(path) => { 
    console.log('The document has finished loading:', path); 
  }}
/>
```

#### onDocumentError
function, optional

This function is called when document opening encounters an error.

```js
<DocumentView
  onDocumentError = {(error) => { 
    console.log('Error occured during document opening:', error); 
  }}
/>
```

### UI Customization

#### disabledElements
array of string, optional, defaults to none

Defines buttons to be disabled for the viewer. Strings should be [`Config.Buttons`](./src/Config/Config.js) constants.

```js
<DocumentView
  disabledElements={[Config.Buttons.userBookmarkListButton]}
/>
```

#### disabledTools
array of string, optional, defaults to none

Defines tools to be disabled for the viewer. Strings should be [`Config.Tools`](./src/Config/Config.js) constants.

```js
<DocumentView
  disabledTools={[Config.Tools.annotationCreateLine, Config.Tools.annotationCreateRectangle]}
/>
```

#### onToolChanged
function, optional

This function is called when the current tool changes to a new tool

Parameters:

Name | Type | Description
--- | --- | ---
previousTool | string | the previous tool (one of the [`Config.Tools`](./src/Config/Config.js) constants or "unknown tool"), representing the tool before change
tool | string | the current tool (one of the [`Config.Tools`](./src/Config/Config.js) constants or "unknown tool"), representing the current tool

```js
<DocumentView
  onToolChanged = {({previousTool, tool}) => {
    console.log('Tool has been changed from', previousTool, 'to', tool);
  }}
/>
```

#### leadingNavButtonIcon
string, optional

The file name of the icon to be used for the leading navigation button. The button will use the specified icon if it is valid, and the default icon otherwise.

Example:

```js
<DocumentView
  leadingNavButtonIcon={Platform.OS === 'ios' ? 'ic_close_black_24px.png' : 'ic_arrow_back_white_24dp'}
/>
```

**Note**: to add the image file to your application, please follow the steps below:

##### Android
1. Add the image resource to the drawable directory in [`example/android/app/src/main/res`](./example/android/app/src/main/res). For details about supported file types and potential compression, check out [here](https://developer.android.com/guide/topics/graphics/drawables#drawables-from-images).

<img alt='demo-android' src='https://pdftron.s3.amazonaws.com/custom/websitefiles/react-native/android_add_resources.png'/>

2. Now you can use the image in the viewer. For example, if you add `button_close.png` to drawable, you could use `'button_close'` in leadingNavButtonIcon.

##### iOS
1. After pods has been installed, open the `.xcworkspace` file for this application in Xcode (in this case, it's [`example.xcworkspace`](./example/ios/example.xcworkspace)), and navigate through the list below. This would allow you to add resources, in this case, an image, to your project.
- "Project navigator"
- "example" (or the app name)
- "Build Phases"
- "Copy Bundle Resources"
- "+".

<img alt='demo-ios' src='https://pdftron.s3.amazonaws.com/custom/websitefiles/react-native/ios_add_resources.png'/>

2. Now you can use the image in the viewer. For example, if you add `button_open.png` to the bundle, you could use `'button_open.png'` in leadingNavButtonIcon.


#### showLeadingNavButton
bool, optional, defaults to true

Defines whether to show the leading navigation button.

```js
<DocumentView
  showLeadingNavButton={true}
/>
```

#### onLeadingNavButtonPressed
function, optional

This function is called when the leading navigation button is pressed.

```js
<DocumentView
  onLeadingNavButtonPressed = {() => {
    console.log('The leading nav has been pressed');
  }}
/>
```

#### documentSliderEnabled
bool, optional, defaults to true

Defines whether the document slider of the viewer is enabled.

```js
<DocumentView
  documentSliderEnabled={false}
/>
```

#### hideViewModeItems
array of string, optional, defaults to none.

Defines view mode items to be hidden in the view mode dialog. Strings should be [`Config.ViewModePickerItem`](./src/Config/Config.js) constants.

```js
<DocumentView
  hideViewModeItems={[
    Config.ViewModePickerItem.Crop,
    Config.ViewModePickerItem.Rotation,
    Config.ViewModePickerItem.ColorMode
  ]}
/>
```

#### tabletLayoutEnabled
bool, optional, defaults to true

Defines whether the tablet layout should be used on tablets. Otherwise uses the same layout as phones. Android only.

```js
<DocumentView
  tabletLayoutEnabled={true}
/>
```

### Toolbar Customization

#### topToolbarEnabled
bool, optional, defaults to true

Deprecated. Use [`hideTopAppNavBar`](#hideTopAppNavBar) prop instead.

#### bottomToolbarEnabled
bool, optional, defaults to true

Defines whether the bottom toolbar of the viewer is enabled.

```js
<DocumentView
  bottomToolbarEnabled={false}
/>
```

#### annotationToolbars
array of objects, options (one of [`Config.DefaultToolbars`](./src/Config/Config.js) constants or custom toolbar object)

Defines custom toolbars. If passed in, the default toolbars will no longer appear.
It is possible to mix and match with default toolbars. See example below:

```js
const myToolbar = {
  [Config.CustomToolbarKey.Id]: 'myToolbar',
  [Config.CustomToolbarKey.Name]: 'myToolbar',
  [Config.CustomToolbarKey.Icon]: Config.ToolbarIcons.FillAndSign,
  [Config.CustomToolbarKey.Items]: [Config.Tools.annotationCreateArrow, Config.Tools.annotationCreateCallout, Config.Buttons.undo]
};

...
<Documentview
  annotationToolbars={[Config.DefaultToolbars.Annotate, myToolbar]}
/>
```
#### hideDefaultAnnotationToolbars
array of strings, optional, defaults to none

Defines which default annotation toolbars should be hidden. Note that this prop should be used when [`annotationToolbars`](#annotationToolbars) is not defined. Strings should be [`Config.DefaultToolbars`](./src/Config/Config.js) constants

```js
<DocumentView
  hideDefaultAnnotationToolbars={[Config.DefaultToolbars.Annotate, Config.DefaultToolbars.Favorite]}
/>
```

#### hideAnnotationToolbarSwitcher
bool, optional, defaults to false

Defines whether to show the toolbar switcher in the top toolbar.

```js
<DocumentView
  hideAnnotationToolbarSwitcher={false}
/>
```

#### initialToolbar
string, optional, defaults to none

Defines which [`annotationToolbar`](#annotationToolbars) should be selected when the document is opened.

```js
<DocumentView
  initialToolbar={Config.DefaultToolbars.Draw}
/>
```

#### hideTopToolbars
bool, optional, defaults to false

Defines whether to hide both the top app nav bar and the annotation toolbar.

```js
<DocumentView
  hideTopToolbars={false}
/>
```

#### hideTopAppNavBar
bool, optional, defaults to false

Defines whether to hide the top navigation app bar.

```js
<DocumentView
  hideTopAppNavBar={true}
/>
```

#### hideToolbarsOnTap
bool, optional, defaults to true

Defines whether an unhandled tap in the viewer should toggle the visibility of the top and bottom toolbars. When false, the top and bottom toolbar visibility will not be toggled and the page content will fit between the bars, if any.

```js
<DocumentView
  hideToolbarsOnTap={false}
/>
```

#### topAppNavBarRightBar
array of strings, optional, iOS only

Customizes the right bar section of the top app nav bar. If passed in, the default right bar section will not be used. Strings should be [`Config.Buttons`](./src/Config/Config.js) constants.

```js
<Documentview
  topAppNavBarRightBar={[Config.Buttons.reflowButton, Config.Buttons.outlineListButton]}
/>
```

#### bottomToolbar
array of strings, optional, only the outline list, thumbnail list, share, view mode, search, and reflow buttons are supported on Android

Defines a custom bottom toolbar. If passed in, the default bottom toolbar will not be used. Strings should be [`Config.Buttons`](./src/Config/Config.js) constants.

```js
<Documentview
  bottomToolbar={[Config.Buttons.reflowButton, Config.Buttons.outlineListButton]}
/>
```

#### padStatusBar
bool, optional, defaults to false, android only

Defines whether the viewer will add padding to take account of the system status bar.

```js
<DocumentView
  padStatusBar={true}
/>
```

### Layout

#### fitMode
string, optional, default value is 'FitWidth'

Defines the fit mode (default zoom level) of the viewer. String should be one of [`Config.FitMode`](./src/Config/Config.js) constants.

```js
<DocumentView
  fitMode={Config.FitMode.FitPage}
/>
```

#### layoutMode
string, optional, default value is 'Continuous'

Defines the layout mode of the viewer. String should be one of [`Config.LayoutMode`](./src/Config/Config.js) constants.

```js
<DocumentView
  layoutMode={Config.LayoutMode.FacingContinuous}
/>
```

#### onLayoutChanged
function, optional

This function is called when the layout of the viewer has been changed.

```js
<DocumentView
  onLayoutChanged = {() => {
    console.log('Layout has been updated.');
  }}
/>
```

### Page

#### initialPageNumber
number, optional

Defines the initial page number that viewer displays when the document is opened. Note that page numbers are 1-indexed.

```js
<DocumentView
  initialPageNumber={5}
/>
```

#### pageNumber
number, optional

Defines the currently displayed page number. Different from [`initialPageNumber`](#initialPageNumber), changing this prop value at runtime will change the page accordingly.

```js
<DocumentView
  pageNumber={5}
/>
```

#### pageChangeOnTap
bool, optional, defaults to true

Defines whether the viewer should change pages when the user taps the edge of a page, when the viewer is in a horizontal viewing mode.

```js
<DocumentView
  pageChangeOnTap={true}
/>
```

#### pageIndicatorEnabled
bool, optional, defaults to true

Defines whether to show the page indicator for the viewer.

```js
<DocumentView
  pageIndicatorEnabled={true}
/>
```

#### keyboardShortcutsEnabled
bool, optional, defaults to true, iOS only

Defines whether the keyboard shortcuts of the viewer are enabled.

```js
<DocumentView
  keyboardShortcutsEnabled={false}
/>
```

#### onPageChanged
function, optional

This function is called when the page number has been changed.

Parameters:

Name | Type | Description
--- | --- | ---
previousPageNumber | int | the previous page number
pageNumber | int | the current page number

```js
<DocumentView
  onPageChanged = {({previousPageNumber, pageNumber}) => {
    console.log('Page number changes from', previousPageNumber, 'to', pageNumber);
  }}
/>
```

### Zoom

#### onZoomChanged
function, optional

This function is called when the zoom scale has been changed.

Parameters:

Name | Type | Description
--- | --- | ---
zoom | double | the current zoom ratio of the document

```js
<DocumentView
  onZoomChanged = {(zoom) => {
    console.log('Current zoom ratio is', zoom);
  }}
/>
```

#### onZoomFinished
function, optional

This function is called when a zooming has been finished. For example, if zoom via gesture, this is called on gesture release.

Parameters:

Name | Type | Description
--- | --- | ---
zoom | double | the current zoom ratio of the document

```js
<DocumentView
  onZoomFinished = {(zoom) => {
    console.log('Current zoom ratio is', zoom);
  }}
```

### Scroll

#### horizontalScrollPos
number, optional

Defines the horizontal scroll position in the current document viewer.

```js
<DocumentView
  horizontalScrollPos={50}
/>
```

#### verticalScrollPos
number, optional

Defines the vertical scroll position in the current document viewer.

```js
<DocumentView
  verticalScrollPos={50}
/>
```

#### onScrollChanged
function, optional

This function is called when the scroll position has been changed.

Parameters:

Name | Type | Description
--- | --- | ---
horizontal | number | the horizontal position of the scroll
vertical | number | the vertical position of the scroll

```js
<DocumentView
  onScrollChanged = {({horizontal, vertical}) => {
    console.log('Current scroll position is', horizontal, 'horizontally, and', vertical, 'vertically.');
  }}
```

#### hideScrollbars
bool, optional, iOS only, defaults to false

Determines whether scrollbars will be hidden on the viewer.

```js
<DocumentView
  hideScrollbars={true}
/>
```

### Reflow

#### imageInReflowEnabled
bool, optional, defaults to true

Whether to show images in reflow mode. 

```js
<DocumentView
  imageInReflowEnabled={false}
/>
```

#### reflowOrientation
string, optional, default value is 'Horizontal'. Android only.

Sets the scrolling direction of the reflow control. Strings should be [`Config.ReflowOrientation`](./src/Config/Config.js) constants.

```js
<DocumentView
  reflowOrientation={Config.ReflowOrientation.Vertical} 
/>
```

### Annotation Menu

#### hideAnnotationMenu
array of strings, optional, defaults to none

Defines annotation types that will not show in the annotation (long-press) menu. Strings should be [`Config.Tools`](./src/Config/Config.js) constants.

```js
<DocumentView
  hideAnnotationMenu={[Config.Tools.annotationCreateArrow, Config.Tools.annotationEraserTool]}
/>
```

#### annotationMenuItems
array of strings, optional, default contains all the items

Defines the menu items that can show when an annotation is selected. Strings should be [`Config.AnnotationMenu`](./src/Config/Config.js) constants.

```js
<DocumentView
  annotationMenuItems={[Config.AnnotationMenu.search, Config.AnnotationMenu.share]}
/>
```

#### overrideAnnotationMenuBehavior
array of strings, optional, defaults to none

Defines the menu items that will skip default behavior when pressed. Strings should be [`Config.AnnotationMenu`](./src/Config/Config.js) constants. They will still be displayed in the annotation menu, and the function [`onAnnotationMenuPress`](#onAnnotationMenuPress) will be called where custom behavior can be implemented.

```js
<DocumentView
  overrideAnnotationMenuBehavior={[Config.AnnotationMenu.copy]}
/>
```

#### onAnnotationMenuPress
function, optional

This function is called when an annotation menu item passed in to [`overrideAnnotationMenuBehavior`](#overrideAnnotationMenuBehavior) is pressed.

Parameters:

Name | Type | Description
--- | --- | ---
annotationMenu | string | One of [`Config.AnnotationMenu`](./src/Config/Config.js) constants, representing which item has been pressed
annotations | array | An array of `{id: string, pageNumber: number, type: string, rect: object}` objects, where `id` is the annotation identifier, `pageNumber` is the page number, type is one of the [`Config.Tools`](./src/Config/Config.js) constants and `rect={x1, y1, x2, y2}` specifies the annotation's screen rect

```js
<DocumentView
  onAnnotationMenuPress = {({annotationMenu, annotations}) => {
    console.log('Annotation menu item', annotationMenu, 'has been pressed');
    annotations.forEach(annotation => {
      console.log('The id of selected annotation is', annotation.id);
      console.log('The page number of selected annotation is', annotation.pageNumber);
      console.log('The type of selected annotation is', annotation.type);
      console.log('The lower left corner of selected annotation is', annotation.x1, annotation.y1);
    });
  }}
/>
```

### Long Press Menu

#### longPressMenuEnabled
bool, optional, defaults to true

Defines whether to show the popup menu of options when the user long presses on text or blank space on the document.

```js
<DocumentView
  longPressMenuEnabled={true}
/>
```

#### longPressMenuItems
array of strings, optional, default contains all the items

Defines menu items that can show when long press on text or blank space. Strings should be [`Config.LongPressMenu`](./src/Config/Config.js) constants.

```js
<DocumentView
  longPressMenuItems={[Config.LongPressMenu.copy, Config.LongPressMenu.read]}
/>
```

#### overrideLongPressMenuBehavior
array of strings, optional, defaults to none

Defines the menu items on long press that will skip default behavior when pressed. Strings should be [`Config.LongPressMenu`](./src/Config/Config.js) constants. They will still be displayed in the long press menu, and the function [`onLongPressMenuPress`](#onLongPressMenuPress) will be called where custom behavior can be implemented.

```js
<DocumentView
  overrideLongPressMenuBehavior={[Config.LongPressMenu.search]}
/>
```

#### onLongPressMenuPress
function, optional

This function is called if the pressed long press menu item is passed in to [`overrideLongPressMenuBehavior`](#overrideLongPressMenuBehavior)

Parameters:

Name | Type | Description
--- | --- | ---
longPressMenu | string | One of [`Config.LongPressMenu`](./src/Config/Config.js) constants, representing which item has been pressed
longPressText | string | the selected text if pressed on text, empty otherwise

```js
<DocumentView
  onLongPressMenuPress = {({longPressMenu, longPressText}) => {
    console.log('Long press menu item', longPressMenu, 'has been pressed');
    if (longPressText !== '') {
      console.log('The selected text is', longPressText);
    }
  }}
/>
```

### Custom Behavior

#### overrideBehavior
array of string, optional, defaults to none

Defines actions that will skip default behavior, such as external link click. Strings should be [`Config.Actions`](./src/Config/Config.js) constants. The function [`onBehaviorActivated`](#onBehaviorActivated) will be called where custom behavior can be implemented, whenever the defined actions occur.

```js
<DocumentView
  overrideBehavior={[Config.Actions.linkPress]}
/>
```

#### onBehaviorActivated
function, optional

This function is called if the activated behavior is passed in to [`overrideBehavior`](#overrideBehavior)

Parameters:

Name | Type | Description
--- | --- | ---
action | string | One of [`Config.Actions`](./src/Config/Config.js) constants, representing which action has been activated
data | object | A JSON object that varies depending on the action

Data param table:

Action | Data param
--- | ---
[`Config.Actions.linkPress`](./src/Config/Config.js) | `{url: string}`
[`Config.Actions.stickyNoteShowPopUp`](./src/Config/Config.js) | `{id: string, pageNumber: number, type: string, rect: {x1: number, y1: number, x2: number, y2: number}}`

```js
<DocumentView
  onBehaviorActivated = {({action, data}) => {
    console.log('Activated action is', action);
    if (action === Config.Actions.linkPress) {
      console.log('The external link pressed is', data.url);
    } else if (action === Config.Actions.stickyNoteShowPopUp) {
      console.log('Sticky note has been activated, but it would not show a pop up window.');
    }
  }}
/>
```

### Multi-tab

#### multiTabEnabled
bool, optional, defaults to false

Defines whether viewer will use tabs in order to have more than one document open simultaneously (like a web browser). Changing the [`document`](#document) prop value will cause a new tab to be opened with the associated file.

```js
<DocumentView
  multiTabEnabled={true}
/>
```

#### tabTitle
string, optional, default is the file name

Set the tab title if [`multiTabEnabled`](#multiTabEnabled) is true.

```js
<DocumentView
  multiTabEnabled={true} // requirement
  tabTitle={'tab1'}
/>
```

#### maxTabCount
number, optional, defaults to unlimited

Sets the limit on the maximum number of tabs that the viewer could have at a time. Open more documents after reaching this limit will overwrite the old tabs.

```js
<DocumentView
  multiTabEnabled={true} // requirement
  maxTabCount={5}
/>
```

### Collaboration

#### collabEnabled
bool, optional, defaults to false

Defines whether to enable realtime collaboration. If true then `currentUser` must be set as well for collaboration mode to work. Feature set may vary between local and collaboration mode.

```js
<DocumentView
  collabEnabled={true}
  currentUser={'Pdftron'}
/>
```

#### currentUser
string, required if [`collabEnabled`](#collabEnabled) is set to true

Defines the current user. Created annotations will have their title (author) set to this string.

```js
<DocumentView
  collabEnabled={true}
  currentUser={'Pdftron'}
/>
```

#### currentUserName
string, optional

Defines the current user name. Will set the user name only if [`collabEnabled`](#collabEnabled) is true and [`currentUser`](#currentUser) is defined. This should be used only if you want the user's display name to be different than the annotation's title/author (in the case that `currentUser` is an ID rather than a human-friendly name.)

```js
<DocumentView
  collabEnabled={true}
  currentUser={'Pdftron'}
  currentUserName={'Hello_World'}
/>
```

### Annotations

#### annotationPermissionCheckEnabled
bool, optional, defaults to false

Defines whether an annotation's permission flags will be respected when it is selected. For example, a locked annotation can not be resized or moved.

```js
<DocumentView
  annotationPermissionCheckEnabled={true}
/>
```

#### annotationAuthor
string, optional

Defines the author name for all annotations created on the current document. Exported xfdfCommand will include this piece of information.

```js
<DocumentView
  annotationAuthor={'PDFTron'}
/>
```

#### continuousAnnotationEditing
bool, optional, defaults to true

If true, the active annotation creation tool will remain in the current annotation creation tool. Otherwise, it will revert to the "pan tool" after an annotation is created.

```js
<DocumentView
  continuousAnnotationEditing={true}
/>
```

#### inkMultiStrokeEnabled
bool, optional, defaults to true

If true, ink tool will use multi-stroke mode. Otherwise, each stroke is a new ink annotation.

```js
<DocumentView
  inkMultiStrokeEnabled={true}
/>
```

#### selectAnnotationAfterCreation
bool, optional, defaults to true

Defines whether an annotation is selected after it is created. On iOS, this functions for shape and text markup annotations only.

```js
<DocumentView
  selectAnnotationAfterCreation={true}
/>
```

#### onExportAnnotationCommand
function, optional

This function is called if a change has been made to annotations in the current document. Unlike [`onAnnotationChanged`](#onAnnotationChanged), this function has an XFDF command string as its parameter. If you are modifying or deleting multiple annotations, then on Android the function is only called once, and on iOS it is called for each annotation.


Parameters:

Name | Type | Description
--- | --- | ---
action | string | the action that occurred (add, delete, modify)
xfdfCommand | string | an xfdf string containing info about the edit
annotations | array | an array of annotation data. When collaboration is enabled data comes in the format `{id: string}`, otherwise the format is `{id: string, pageNumber: number, type: string}`. In both cases, the data represents the annotations that have been changed. Type is one of the [`Config.Tools`](./src/Config/Config.js) constants 

**Known Issues** <br/> 
On iOS, there is currently a bug that prevents the last XFDF from being retrieved when modifying annotations while collaboration mode is enabled.

```js
<DocumentView
  onExportAnnotationCommand = {({action, xfdfCommand, annotations}) => {
    console.log('Annotation edit action is', action);
    console.log('The exported xfdfCommand is', xfdfCommand);
    annotations.forEach((annotation) => {
      console.log('Annotation id is', annotation.id);
      if (!this.state.collabEnabled) {
        console.log('Annotation pageNumber is', annotation.pageNumber);
        console.log('Annotation type is', annotation.type);
      }
    });
  }}
  collabEnabled={this.state.collabEnabled}
  currentUser={'Pdftron'}
/>
```

#### onAnnotationsSelected
function, optional

This function is called when an annotation(s) is selected.

Parameters:

Name | Type | Description
--- | --- | ---
annotations | array | array of annotation data in the format `{id: string, pageNumber: number, type: string, rect: {x1: number, y1: number, x2: number, y2: number}}`, representing the selected annotations. Type is one of the [`Config.Tools`](./src/Config/Config.js) constants

```js
<DocumentView
  onAnnotationsSelected = {({annotations}) => {
    annotations.forEach(annotation => {
      console.log('The id of selected annotation is', annotation.id);
      console.log('It is in page', annotation.pageNumber);
      console.log('Its type is', annotation.type);
      console.log('Its lower left corner has coordinate', annotation.rect.x1, annotation.rect.y1);
    });
  }}
/>
```

#### onAnnotationChanged
function, optional

This function is called if a change has been made to an annotation(s) in the current document.

Parameters:

Name | Type | Description
--- | --- | ---
action | string | the action that occurred (add, delete, modify)
annotations | array | array of annotation data in the format `{id: string, pageNumber: number, type: string}`, representing the annotations that have been changed. Type is one of the [`Config.Tools`](./src/Config/Config.js) constants

```js
<DocumentView
  onAnnotationChanged = {({action, annotations}) => {
    console.log('Annotation edit action is', action);
    annotations.forEach(annotation => {
      console.log('The id of changed annotation is', annotation.id);
      console.log('It is in page', annotation.pageNumber);
      console.log('Its type is', annotation.type);
    });
  }}
/>
```

#### onFormFieldValueChanged
function, optional

This function is called if a change has been made to form field values.

Parameters:

Name | Type | Description
--- | --- | ---
fields | array | array of field data in the format `{fieldName: string, fieldValue: string}`, representing the fields that have been changed

```js
<DocumentView
  onFormFieldValueChanged = {({fields}) => {
    console.log('Annotation edit action is', action);
    annotations.forEach(annotation => {
      console.log('The id of changed annotation is', annotation.id);
      console.log('It is in page', annotation.pageNumber);
    });
  }}
/>
```

#### annotationsListEditingEnabled
bool, optional, Android only, default value is true

If document editing is enabled, then this value determines if the annotation list is editable.

```js
<DocumentView
  annotationsListEditingEnabled={true}
/>
```

### Bookmark

#### onBookmarkChanged
function, optional

This function is called if a change has been made to user bookmarks.

Parameters:

Name | Type | Description
--- | --- | ---
bookmarkJson | string | the list of current bookmarks in JSON format

```js
<DocumentView
  onBookmarkChanged = {({bookmarkJson}) => {
    console.log('Bookmarks have been changed. Current bookmark collection is', bookmarkJson);
  }}
/>
```

#### userBookmarksListEditingEnabled
bool, optional, default value is true

Defines whether the bookmark list can be edited. If the viewer is readonly then bookmarks on Android are 
still editable but are saved to the device rather than the PDF.

```js
<DocumentView
  userBookmarksListEditingEnabled={true}
/>
```

### Signature

#### signSignatureFieldsWithStamps
bool, optional, defaults to false

Defines whether signature fields will be signed with image stamps.
This is useful if you are saving XFDF to remote source.

```js
<DocumentView
  signSignatureFieldsWithStamps={true}
/>
```

#### showSavedSignatures
bool, optional, defaults to true

Defines whether to show saved signatures for re-use when using the signing tool.

```js
<DocumentView
  showSavedSignatures={true}
/>
```

#### photoPickerEnabled
bool, optional, defaults to true. Android only.

Defines whether to show the option to pick images in the signature dialog.

```js
<DocumentView
  photoPickerEnabled={true}
/>
```

### Thumbnail Browser

#### hideThumbnailFilterModes
array of strings, optional

Defines filter modes that should be hidden in the thumbnails browser. Strings should be [`Config.ThumbnailFilterMode`](./src/Config/Config.js) constants

```js
<DocumentView
  hideThumbnailFilterModes={[Config.ThumbnailFilterMode.Annotated]}
/>
```

#### thumbnailViewEditingEnabled
bool, optional, defaults to true

Defines whether user can modify the document using the thumbnail view (eg add/remove/rotate pages).

```js
<DocumentView
  thumbnailViewEditingEnabled={true}
/>
```

### Text Selection

#### onTextSearchStart
function, optional

This function is called immediately before a text search begins, either through user actions, or function calls such as [`findText`](#findText).

```js
<DocumentView
  onTextSearchStart = {() => {
    console.log('Text search has started');
  }}
/>
```

#### onTextSearchResult
function, optional

This function is called after a text search is finished or canceled.

Parameters:

Name | Type | Description
--- | --- | ---
found | bool | whether a result is found. If no, it could be caused by not finding a matching result in the document, invalid text input, or action cancellation (user actions or [`cancelFindText`](#cancelFindText))
textSelection | object | the text selection, in the format `{html: string, unicode: string, pageNumber: number, quads: [[{x: number, y: number}, {x: number, y: number}, {x: number, y: number}, {x: number, y: number}], ...]}`. If no such selection could be found, this would be null

quads indicate the quad boundary boxes for the selection, which could have a size larger than 1 if selection spans across different lines. Each quad have 4 points with x, y coordinates specified in number, representing a boundary box. The 4 points are in counter-clockwise order, though the first point is not guaranteed to be on lower-left relatively to the box.

```js
<DocumentView
  onTextSearchResult = {({found, textSelection}) => {
    if (found) {
      console.log('Found selection on page', textSelection.pageNumber);
      for (let i = 0; i < textSelection.quads.length; i ++) {
        const quad = textSelection.quads[i];
        console.log('selection boundary quad', i);
        for (const quadPoint of quad) {
          console.log('A quad point has coordinates', quadPoint.x, quadPoint.y);
        }
      }
    }
  }}
/>
```

### Others

#### useStylusAsPen
bool, optional, defaults to true

Defines whether a stylus should act as a pen when in pan mode. If false, it will act as a finger.

```js
<DocumentView
  useStylusAsPen={true}
/>
```

#### followSystemDarkMode
bool, optional, Android and iOS 13+ only, defaults to true

Defines whether the UI will appear in a dark color when the system is dark mode. If false, it will use viewer setting instead.

```js
<DocumentView
  followSystemDarkMode={false}
/>
```

#### autoSaveEnabled
bool, optional, defaults to true

Defines whether document is automatically saved by the viewer.

```js
<DocumentView
  autoSaveEnabled={true}
/>
```

#### autoResizeFreeTextEnabled
bool, optional, defaults to false

Defines whether to automatically resize the bounding box of free text annotations when editing.

```js
<DocumentView
  autoResizeFreeTextEnabled={true}
/>
```

#### restrictDownloadUsage
bool, optional, defaults to false

Defines whether to restrict data usage when viewing online PDFs.

```js
<DocumentView
  restrictDownloadUsage={true}
/>
```

### Navigation

#### pageStackEnabled
bool, optional, defaults to true, Android only

Defines whether the page stack navigation buttons will appear in the viewer.

```js
<DocumentView
  pageStackEnabled={false}
/>
```

#### showQuickNavigationButton
bool, optional, defaults to true, Android only

Defines whether the quick navigation buttons will appear in the viewer.

```js
<DocumentView
  showQuickNavigationButton={false}
/>
```

#### showNavigationListAsSidePanelOnLargeDevices
bool, optional, defaults to true on Android and false on iOS

Defines whether the navigation list will be displayed as a side panel on large devices such as iPads and tablets.

```js
<DocumentView
  showNavigationListAsSidePanelOnLargeDevices={true}
/>
```

#### onUndoRedoStateChanged
function, optional

This function is called when the state of the current document's undo/redo stack has been changed.

```js
<DocumentView
  onUndoRedoStateChanged = {() => { 
    console.log("Undo/redo stack state changed");
  }}
/>
```

## DocumentView - Methods

### Document

#### getDocumentPath
Returns the path of the current document. If [`isBase64String`](#isBase64String) is true, this would be the path to the temporary pdf file converted from the base64 string in [`document`](#document).

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
path | string | the document path

```js
this._viewer.getDocumentPath().then((path) => {
  console.log('The path to current document is: ' + path);
});
```

#### saveDocument
Saves the current document. If [`isBase64String`](#isBase64String) is true, this would be the base64 string encoded from the temporary pdf file, which is created from the base64 string in [`document`](#document).

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
filePath | string | the location of the saved document, or the base64 string of the pdf in the case of base64

```js
this._viewer.saveDocument().then((filePath) => {
  console.log('saveDocument:', filePath);
});
```

### UI Customization

#### setColorPostProcessMode
Sets the color post processing transformation mode for the viewer.

Parameters:

Name | Type | Description
--- | --- | ---
colorPostProcessMode | string | color post processing transformation mode, should be a [`Config.ColorPostProcessMode`](./src/Config/Config.js) constant

```js
this._viewer.setColorPostProcessMode(Config.ColorPostProcessMode.NightMode);
```

#### setColorPostProcessColors
Sets the white and black color for the color post processing transformation.

Parameters:

Name | Type | Description
--- | --- | ---
whiteColor | object | the white color for the color post processing transformation, in the format `{red: number, green: number, blue: number}`. `alpha` could be optionally included (only Android would apply alpha), and all numbers should be in range [0, 255]
blackColor | object | the black color for the color post processing transformation, in the same format as whiteColor

```js
const whiteColor = {"red": 0, "green": 0, "blue": 255};
const blackColor = {"red": 255, "green": 0, "blue": 0};
this._viewer.setColorPostProcessColors(whiteColor, blackColor);
```

### Annotation Tools

#### setToolMode
Sets the current tool mode.

Returns a Promise.

Parameters:

Name | Type | Description
--- | --- | ---
toolMode | string | One of [`Config.Tools`](./src/Config/Config.js) string constants, representing to tool mode to set

```js
this._viewer.setToolMode(Config.Tools.annotationCreateFreeHand).then(() => {
  // done switching tools
});
```

#### commitTool
Commits the current tool, only available for multi-stroke ink and poly-shape.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
committed | bool | true if either ink or poly-shape tool is committed, false otherwise

```js
this._viewer.commitTool().then((committed) => {
  // committed: true if either ink or poly-shape tool is committed, false otherwise
});
```

### Page

#### getPageCount
Gets the current page count of the document.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
pageCount | int | the current page count of the document

```js
this._viewer.getPageCount().then((pageCount) => {
  console.log('pageCount', pageCount);
});
```

#### setCurrentPage
Sets current page of the document.

Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | integer | the page number to be set as the current page; 1-indexed

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
success | bool | whether the setting process was successful

```js
this._viewer.setCurrentPage(4).then((success) => {
  if (success) {
    console.log("Current page is set to 4.");
  }
});
```

#### gotoPreviousPage
Go to the previous page of the document. If on first page, it would stay on first page.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
success | bool | whether the setting process was successful (no change due to staying in first page counts as being successful)

```js
this._viewer.gotoPreviousPage().then((success) => {
  if (success) {
    console.log("Go to previous page.");
  }
});
```

#### gotoNextPage
Go to the next page of the document. If on last page, it would stay on last page.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
success | bool | whether the setting process was successful (no change due to staying in last page counts as being successful)

```js
this._viewer.gotoNextPage().then((success) => {
  if (success) {
    console.log("Go to next page.");
  }
});
```

#### gotoFirstPage
Go to the first page of the document.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
success | bool | whether the setting process was successful

```js
this._viewer.gotoFirstPage().then((success) => {
  if (success) {
    console.log("Go to first page.");
  }
});
```

#### gotoLastPage
Go to the last page of the document.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
success | bool | whether the setting process was successful

```js
this._viewer.gotoLastPage().then((success) => {
  if (success) {
    console.log("Go to last page.");
  }
});
```

#### showGoToPageView
Opens a go-to page dialog. If the user inputs a valid page number into the dialog, the viewer will go to that page.

Returns a Promise.

```js
this._viewer.showGoToPageView();
```

#### getPageCropBox
Gets the crop box for specified page as a JSON object.

Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | integer | the page number for the target crop box. It is 1-indexed

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
cropBox | object | an object with information about position (`x1`, `y1`, `x2` and `y2`) and size (`width` and `height`)

```js
this._viewer.getPageCropBox(1).then((cropBox) => {
  console.log('bottom-left coordinate:', cropBox.x1, cropBox.y1);
  console.log('top-right coordinate:', cropBox.x2, cropBox.y2);
  console.log('width and height:', cropBox.width, cropBox.height);
});
```

#### getVisiblePages
Gets the visible pages in the current viewer as an array.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
visiblePages | array | a list of visible pages in the current viewer

```js
this._viewer.getVisiblePages().then((visiblePages) => {
  for (const page of visiblePages) {
    console.log('page', page, 'is visible.')
  }
});
```

#### getPageRotation
Gets the rotation value of all pages in the current document.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
pageRotation | number | the rotation degree of all pages, one of 0, 90, 180 or 270 (clockwise).

```js
this._viewer.getPageRotation().then((pageRotation) => {
  console.log('The current page rotation degree is' + pageRotation);
});
```

#### rotateClockwise
Rotates all pages in the current document in clockwise direction (by 90 degrees).

Returns a Promise.

```js
this._viewer.rotateClockwise();
```

#### rotateCounterClockwise
Rotates all pages in the current document in counter-clockwise direction (by 90 degrees).

Returns a Promise.

```js
this._viewer.rotateCounterClockwise();
```

### Import/Export Annotations

#### importAnnotationCommand
Imports remote annotation command to local document.

Parameters:

Name | Type | Description
--- | --- | ---
xfdfCommand | string | the XFDF command string
initialLoad | bool | whether this is for initial load. Will be false by default

Returns a Promise.

```js
const xfdfCommand = '<?xml version="1.0" encoding="UTF-8"?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><add><circle style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20201218025606Z" flags="print" date="D:20201218025606Z" name="9d0f2d63-a0cc-4f06-b786-58178c4bd2b1" page="0" rect="56.4793,584.496,208.849,739.369" title="PDF" /></add><modify /><delete /><pdf-info import-version="3" version="2" xmlns="http://www.pdftron.com/pdfinfo" /></xfdf>';
this._viewer.importAnnotationCommand(xfdf);

```

#### importAnnotations
Imports XFDF annotation string to the current document.

Parameters:

Name | Type | Description
--- | --- | ---
xfdf | string | annotation string in XFDF format for import

Returns a Promise.

```js
const xfdf = '<?xml version="1.0" encoding="UTF-8"?>\n<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">\n\t<annots>\n\t\t<circle style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20190729202215Z" flags="print" date="D:20190729202215Z" page="0" rect="138.824,653.226,236.28,725.159" title="" /></annots>\n\t<pages>\n\t\t<defmtx matrix="1.333333,0.000000,0.000000,-1.333333,0.000000,1056.000000" />\n\t</pages>\n\t<pdf-info version="2" xmlns="http://www.pdftron.com/pdfinfo" />\n</xfdf>';
this._viewer.importAnnotations(xfdf);
```

#### exportAnnotations
Extracts XFDF from the current document.

Parameters:

Name | Type | Description
--- | --- | ---
options | object | key: annotList, type: array. If specified, annotations with the matching id and pageNumber will be exported; otherwise, all annotations in the current document will be exported.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
xfdf | string | annotation string in XFDF format

Without options:

```js
this._viewer.exportAnnotations().then((xfdf) => {
  console.log('XFDF for all annotations:', xfdf);
});
```

With options:

```js
// annotList is an array of annotation data in the format {id: string, pageNumber: int}
const annotations = [{id: 'annot1', pageNumber: 1}, {id: 'annot2', pageNumber: 3}];
this._viewer.exportAnnotations({annotList: annotations}).then((xfdf) => {
  console.log('XFDF for 2 specified annotations', xfdf);
});
```

### Annotations

#### flattenAnnotations
Flattens the forms and (optionally) annotations in the current document.

Parameters:

Name | Type | Description
--- | --- | ---
formsOnly | bool | Defines whether only forms are flattened. If false, all annotations will be flattened

Returns a Promise.

```js
// flatten forms and annotations in the current document.
this._viewer.flattenAnnotations(false);
```

#### deleteAnnotations
Deletes the specified annotations in the current document.

Parameters:

Name | Type | Description
--- | --- | ---
annotations | array | Defines which annotation to be deleted. Each element is in the format {id: string, pageNumber: int}

Returns a Promise.

```js
// delete annotations in the current document.
this._viewer.deleteAnnotations([
    {
        id: 'annotId1',
        pageNumber: 1,
    },
    {
        id: 'annotId2',
        pageNumber: 2,
    }
]);
```

#### selectAnnotation
Selects the specified annotation in the current document.

Parameters:

Name | Type | Description
--- | --- | ---
id | string | the id of the target annotation
pageNumber | integer | the page number where the targe annotation is located. It is 1-indexed

Returns a Promise.

```js
// select annotation in the current document.
this._viewer.selectAnnotation('annotId1', 1);
```

#### setFlagsForAnnotations
Sets flags for specified annotations in the current document. The `flagValue` controls whether a flag will be set to or removed from the annotation.

Note: the old function `setFlagForAnnotations` is deprecated. Please use this one.

Parameters:

Name | Type | Description
--- | --- | ---
annotationFlagList | array | A list of annotation flag operations. Each element is in the format {id: string, pageNumber: int, flag: [`Config.AnnotationFlags`](./src/Config/Config.js) constants, flagValue: bool}

Returns a Promise.

```js
//  Set flag for annotations in the current document.
this._viewer.setFlagsForAnnotations([
    {
        id: 'annotId1',
        pageNumber: 1,
        flag: Config.AnnotationFlags.noView,
        flagValue: true
    },
    {
        id: 'annotId2',
        pageNumber: 5,
        flag: Config.AnnotationFlags.lockedContents,
        flagValue: false
    }
]);
```

#### setPropertiesForAnnotation
Sets properties for specified annotation in the current document, if it is valid.

Note: the old function `setPropertyForAnnotation` is deprecated. Please use this one.

Parameters:

Name | Type | Description
--- | --- | ---
annotationId | string | the unique id of the annotation
pageNumber | integer | the page number where annotation is located. It is 1-indexed
propertyMap | object | an object containing properties to be set. Available properties are listed below

Properties in propertyMap:

Name | Type | Markup exclusive | Example
--- | --- | --- | ---
rect | object | no | {x1: 1, y1: 2, x2: 3, y2: 4}
contents | string | no | "contents"
subject | string | yes | "subject"
title | string | yes | "title"
contentRect | object | yes | {x1: 1, y1: 2, x2: 3, y2: 4}
customData | object | no | {key: value}
strokeColor | object | no | {red: 255, green: 0, blue: 0}

Returns a promise.

```js
// Set properties for annotation in the current document.
this._viewer.setPropertiesForAnnotation('Pdftron', 1, {
  rect: {
    x1: 1.1,    // left
    y1: 3,      // bottom
    x2: 100.9,  // right
    y2: 99.8    // top
  },
  contents: 'Hello World',
  subject: 'Sample',
  title: 'set-prop-for-annot',
  customData: {
    key1: 'value1',
    key2: 'value2',
    key3: 'value3'
  },
  strokeColor: {
    "red": 255,
    "green": 0,
    "blue": 0
  }
});
```

#### getPropertiesForAnnotation
Gets properties for specified annotation in the current document, if it is valid. 

Parameters:

Name | Type | Description
--- | --- | ---
annotationId | string | the unique id of the annotation
pageNumber | integer | the page number where annotation is located. It is 1-indexed

Available Properties:

Name | Type | Markup exclusive | Example
--- | --- | --- | ---
rect | object | no | {x1: 1, y1: 1, x2: 2, y2: 2, width: 1, height: 1}
contents | string | no | "Contents"
subject | string | yes | "Subject"
title | string | yes | "Title"
contentRect | object | yes | {x1: 1, y1: 1, x2: 2, y2: 2, width: 1, height: 1}
strokeColor | object | no | {red: 255, green: 0, blue: 0}

Returns a promise.

Promise Parameters:

Name | Type | Description | Example
--- | --- | --- | ---
propertyMap | object | the non-null properties of the annotation | `{contents: 'Contents', strokeColor: {red: 255, green: 0, blue: 0}, rect: {x1: 1, y1: 1, x2: 2, y2: 2, width: 1, height: 1}}`

```js
// Get properties for annotation in the current document.
this._viewer.getPropertiesForAnnotation('Pdftron', 1).then((properties) => {
  if (properties) {
    console.log('Properties for annotation: ', properties);
  }
})
```

#### setDrawAnnotations
Sets whether all annotations and forms should be rendered in the viewer.

Parameters:

Name | Type | Description
--- | --- | ---
drawAnnotations | bool | whether all annotations and forms should be rendered

Returns a promise.

```js
this._viewer.setDrawAnnotations(false);
```

#### setVisibilityForAnnotation
Sets visibility for specified annotation in the current document, if it is valid. Note that if [`drawAnnotations`](#drawAnnotations) is set to false in the viewer, this function would not render the annotation even if visibility is true.

Parameters:

Name | Type | Description
--- | --- | ---
annotationId | string | the unique id of the annotation
pageNumber | integer | the page number where annotation is located. It is 1-indexed
visibility | bool | whether the annotation should be visible

Returns a promise.

```js
this._viewer.setVisibilityForAnnotation('Pdftron', 1, true);
```

#### setHighlightFields
Enables or disables highlighting form fields. It is disabled by default.

Parameters:

Name | Type | Description
--- | --- | ---
highlightFields | bool | whether form fields should be highlighted

```js
this._viewer.setHighlightFields(true);
```


#### getAnnotationAt
Gets an annotation at the (x, y) position in screen coordinates, if any.

Parameters:

Name | Type | Description
--- | --- | ---
x | integer | the x-coordinate of the point
y | integer | the y-coordinate of the point
distanceThreshold | double | maximum distance from the point (x, y) to the annotation for it to be considered a hit (in dp)
minimumLineWeight | double | For very thin lines, it is almost impossible to hit the actual line. This specifies a minimum line thickness (in screen coordinates) for the purpose of calculating whether a point is inside the annotation or not (in dp)

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
annotation | object | the annotation found in the format of `{id: string, pageNumber: number, type: string, rect: {x1: number, y1: number, x2: number, y2: number}}`

```js
this._viewer.getAnnotationAt(167, 287, 100, 10).then((annotation) => {
  if (annotation) {
    console.log('Annotation found at point (167, 287) has id:', annotation.id);
  }
})
```

#### getAnnotationListAt
Gets the list of annotations at a given line in screen coordinates. Note that this is not an area selection. It should be used similar to [`getAnnotationAt`](#getAnnotationAt), except that this should be used when you want to get multiple annotations which are overlaying with each other.

Parameters:

Name | Type | Description
--- | --- | ---
x1 | integer | the x-coordinate of an endpoint on the line
y1 | integer | the y-coordinate of an endpoint on the line
x2 | integer | the x-coordinate of the other endpoint on the line, usually used as a threshold
y2 | integer | the y-coordinate of the other endpoint on the line, usually used as a threshold

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
annotations | array | list of annotations at the target line, each in the format of `{id: string, pageNumber: number, type: string, rect: {x1: number, y1: number, x2: number, y2: number}}`

```js
this._viewer.getAnnotationListAt(0, 0, 200, 200).then((annotations) => {
  for (const annotation of annotations) {
    console.log('Annotation found at line has id:', annotation.id);
  }
})
```

#### getAnnotationListOnPage
Gets the list of annotations on a given page.

Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | integer | the page number where annotations are located. It is 1-indexed

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
annotations | array | list of annotations on the target page, each in the format of `{id: string, pageNumber: number, type: string, rect: {x1: number, y1: number, x2: number, y2: number}}`

```js
this._viewer.getAnnotationListOnPage(2).then((annotations) => {
  for (const annotation of annotations) {
    console.log('Annotation found on page 2 has id:', annotation.id);
  }
})
```

#### getCustomDataForAnnotation
Gets an annotation's `customData` property.

Parameters:

Name | Type | Description
--- | --- | ---
annotationId | string | the unique id of the annotation
pageNumber | integer | the page number where annotation is located. It is 1-indexed
key | string | the unique key associated with the `customData` property

Returns a Promise.

Promise Parameters: 
Name | Type | Description
--- | --- | ---
value | string | the `customData` property associated with the given key

```js
this._viewer.setPropertiesForAnnotation("annotation1", 2, {
  customData: {
    data: "Nice annotation"
  }
}).then(() => {
  this._viewer.getCustomDataForAnnotation("annotation1", 2, "data").then((value) => {
    console.log(value === "Nice annotation");
  })
})
```

#### setFlagForFields
Sets a field flag value on one or more form fields.

Parameters:

Name | Type | Description
--- | --- | ---
fields | array | list of field names for which the flag should be set
flag | int | flag to be set. Number should be a [`Config.FieldFlags`](./src/Config/Config.js) constant
value | bool | value to set for flag

Returns a Promise.

```js
this._viewer.setFlagForFields(['First Name', 'Last Name'], Config.FieldFlags.ReadOnly, true);
```

#### setValuesForFields
Sets field values on one or more form fields.

Note: the old function `setValueForFields` is deprecated. Please use this one instead.

Parameters:

Name | Type | Description
--- | --- | ---
fieldsMap | object | map of field names and values which should be set

Returns a Promise.

```js
this._viewer.setValuesForFields({
  'textField1': 'Test',
  'textField2': 1234,
  'checkboxField1': true,
  'checkboxField2': false,
  'radioButton1': 'Yes',
  'radioButton2': 'No'
});
```

#### getField
Get type and value information of a field using its name.

Parameters:

Name | Type | Description
--- | --- | ---
fieldName | string | name of the field

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
field | object | an object with information key `fieldName`, `fieldValue` (undefined for fields with no values) and `fieldType`(one of button, checkbox, radio, text, choice, signature and unknown), or undefined if such field does not exist

```js
this._viewer.getField('someFieldName').then((field) => {
  if (field !== undefined) {
    console.log('field name:', field.fieldName);
    console.log('field value:', field.fieldValue);
    console.log('field type:', field.fieldType);
  }
});
```

#### openThumbnailsView
Display a page thumbnails view. 

This view allows users to navigate pages of a document. If [`thumbnailViewEditingEnabled`](#thumbnailViewEditingEnabled) is true, the user can also manipulate the document, including add, remove, re-arrange, rotate and duplicate pages.

Returns a Promise.

```js
this._viewer.openThumbnailsView();
```

### Toolbar

#### setCurrentToolbar
Sets the current [`annotationToolbar`](#annotationToolbars) for the viewer.

Returns a Promise.

Parameters:

Name | Type | Description
--- | --- | ---
toolbar | string | the toolbar to enable. Should be one of the [`Config.DefaultToolbars`](./src/Config/Config.js) constants or the `id` of a custom toolbar object.

```js
this._viewer.setCurrentToolbar(Config.DefaultToolbars.Insert).then(() => {
  // done switching toolbar
});
```

### Navigation

#### handleBackButton
Handles the back button in search mode. Android only.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
handled | bool | whether the back button is handled successfully

```js
this._viewer.handleBackButton().then((handled) => {
  if (!handled) {
    BackHandler.exitApp();
  }
});
```

### Bookmark

#### importBookmarkJson
Imports user bookmarks into the document. The input needs to be a valid bookmark JSON format.

Parameters:

Name | Type | Description
--- | --- | ---
bookmarkJson | String | needs to be in valid bookmark JSON format, for example {"0": "Page 1"}. The page numbers are 1-indexed

Returns a Promise.

```js
this._viewer.importBookmarkJson("{\"0\": \"Page 1\", \"3\": \"Page 4\"}");
```

### Multi-tab

#### closeAllTabs
Closes all tabs in multi-tab environment.

Returns a Promise.

```js
// Do this only when DocumentView has multiTabEnabled = true
this._viewer.closeAllTabs();
```

### Zoom

#### getZoom
Returns the current zoom scale of current document viewer.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
zoom | double | current zoom scale in the viewer

```js
this._viewer.getZoom().then((zoom) => {
  console.log('Zoom scale of the current document is:', zoom);
});
```

#### setZoomLimits
Sets the minimum and maximum zoom bounds of current viewer.

Parameters:

Name | Type | Description
--- | --- | ---
zoomLimitMode | String | one of the constants in `Config.ZoomLimitMode`, defines whether bounds are relative to the standard zoom scale in the current viewer or absolute
minimum | double | the lower bound of the zoom limit range
maximum | double | the upper bound of the zoom limit range

Returns a Promise.

```js
this._viewer.setZoomLimits(Config.ZoomLimitMode.Absolute, 1.0, 3.5);
```

#### zoomWithCenter
Sets the zoom scale in the current document viewer with a zoom center.

Parameters:

Name | Type | Description
--- | --- | ---
zoom | double | the zoom ratio to be set
x | int | the x-coordinate of the zoom center
y | int | the y-coordinate of the zoom center

Returns a Promise.

```js
this._viewer.zoomWithCenter(3.0, 100, 300);
```

#### zoomToRect
Zoom the viewer to a specific rectangular area in a page.

Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | int | the page number of the zooming area (1-indexed)
rect | map | The rectangular area with keys x1 (left), y1(bottom), y1(right), y2(top). Coordinates are in double

Returns a Promise.

```js
this._viewer.zoomToRect(3, {'x1': 1.0, 'y1': 2.0, 'x2': 3.0, 'y2': 4.0});
```

#### smartZoom
Zoom to a paragraph that contains the specified coordinate. If no paragraph contains the coordinate, the zooming would not happen.

Parameters:

Name | Type | Description
-- | -- | --
x | int | the x-coordinate of the target coordinate
y | int | the y-coordinate of the target coordinate
animated | bool | whether the transition is animated

Returns a Promise.

```js
this._viewer.smartZoom(100, 200, true);
```

### Scroll

#### getScrollPos
Returns the horizontal and vertical scroll position of current document viewer.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
horizontal | number | current horizontal scroll position
vertical | number | current vertical scroll position

```js
this._viewer.getScrollPos().then(({horizontal, vertical}) => {
  console.log('Current horizontal scroll position is:', horizontal);
  console.log('Current vertical scroll position is:', vertical);
});
```

### Canvas

#### getCanvasSize
Returns the canvas size of current document viewer.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
width | number | current width of canvas
height | number | current height of canvas

```js
this._viewer.getCanvasSize().then(({width, height}) => {
  console.log('Current canvas width is:', width);
  console.log('Current canvas height is:', height);
});
```

### Coordinate

#### convertPagePointsToScreenPoints
Converts points from page coordinates to screen coordinates in the viewer.

Parameters:

Name | Type | Description
--- | --- | ---
points | array | list of points, each in the format `{x: number, y: number}`. You could optionally have a `pageNumber: number` in the object. Without specifying, the page system is referring to the current page

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
convertedPoints | array | list of converted points in screen system, each in the format `{x: number, y: number}`. It would be empty if conversion is unsuccessful

```js
// convert (50, 50) on current page and (100, 100) on page 1 from page system to screen system
this._viewer.convertPagePointsToScreenPoints([{x: 50, y: 50}, {x: 100, y:100, pageNumber: 1}]).then((convertedPoints) => {
  convertedPoints.forEach(point => {
    console.log(point);
  })
});
```

#### convertScreenPointsToPagePoints
Converts points from screen coordinates to page coordinates in the viewer.

Parameters:

Name | Type | Description
--- | --- | ---
points | array | list of points, each in the format `{x: number, y: number}`. You could optionally have a `pageNumber: number` in the object. Without specifying, the page system is referring to the current page

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
convertedPoints | array | list of converted points in page system, each in the format `{x: number, y: number}`. It would be empty if conversion is unsuccessful

```js
// convert (50, 50) and (100, 100) from screen system to page system, on current page and page 1 respectively
this._viewer.convertScreenPointsToPagePoints([{x: 50, y: 50}, {x: 100, y:100, pageNumber: 1}]).then((convertedPoints) => {
  convertedPoints.forEach(point => {
    console.log(point);
  })
});
```

#### getPageNumberFromScreenPoint
Returns the page number that contains the point on screen.

Parameters:

Name | Type | Description
--- | --- | ---
x | number | the x-coordinate of the screen point
y | number | the y-coordinate of the screen point

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | number | the page number of the screen point

```js
this._viewer.getPageNumberFromScreenPoint(10.0,50.5).then((pageNumber) => {
  console.log('The page number of the screen point is', pageNumber);
});
```

### Rendering Options

#### setProgressiveRendering
Sets whether the control will render progressively or will just draw once the entire view has been rendered.

Parameters:

Name | Type | Description
--- | --- | ---
progressiveRendering | bool | whether to render progressively
initialDelay | number | delay before the progressive rendering timer is started, in milliseconds
interval | number | delay between refreshes, in milliseconds

Returns a Promise.

```js
// delay for 10s before start, and refresh every 1s
this._viewer.setProgressiveRendering(true, 10000, 1000);
```

#### setImageSmoothing
Enables or disables image smoothing. The rasterizer allows a trade-off between rendering quality and rendering speed. This function can be used to indicate the preference between rendering speed and quality.

Parameters:

Name | Type | Description
--- | --- | ---
imageSmoothing | bool | whether to enable image smoothing

Returns a Promise.

```js
this._viewer.setImageSmoothing(false);
```

#### setOverprint
Enables or disables support for overprint and overprint simulation. Overprint is a device dependent feature and the results will vary depending on the output color space and supported colorants (i.e. CMYK, CMYK+spot, RGB, etc).

Parameters:

Name | Type | Description
--- | --- | ---
overprint | string | the mode of overprint, should be a [`Config.OverprintMode`](./src/Config/Config.js) constant

Returns a Promise.

```js
this._viewer.setOverprint(Config.OverprintMode.Off);
```

### Viewer Options

#### setUrlExtraction
Sets whether to extract urls from the current document, which is disabled by default. It is recommended to set this value before document is opened.

Parameters:

Name | Type | Description
--- | --- | ---
urlExtraction | bool | whether to extract urls from the current document

```js
this._viewer.setUrlExtraction(true);
```

#### setPageBorderVisibility
Sets whether borders of each page are visible in the viewer, which is disabled by default.

Parameters:

Name | Type | Description
--- | --- | ---
pageBorderVisibility | bool | whether borders of each page are visible in the viewer

```js
this._viewer.setPageBorderVisibility(true);
```

#### setPageTransparencyGrid
Enables or disables transparency grid (check board pattern) to reflect page transparency, which is disabled by default.

Parameters:

Name | Type | Description
--- | --- | ---
pageTransparencyGrid | bool | whether to use the transpareny grid

```js
this._viewer.setPageTransparencyGrid(true);
```

#### setBackgroundColor
Sets the background color of the viewer.

Parameters:

Name | Type | Description
--- | --- | ---
backgroundColor | object | the background color, in the format `{red: number, green: number, blue: number}`, each number in range [0, 255]

```js
this._viewer.setBackgroundColor({red: 0, green: 0, blue: 255}); // blue color
```

#### setDefaultPageColor
Sets the default page color of the viewer.

Parameters:

Name | Type | Description
--- | --- | ---
defaultPageColor | object | the default page color, in the format `{red: number, green: number, blue: number}`, each number in range [0, 255]

```js
this._viewer.setDefaultPageColor({red: 0, green: 255, blue: 0}); // green color
```

### Text Selection

#### startSearchMode
Search for a term and all matching results will be highlighted.

Returns a Promise.

Parameters:

Name | Type | Description
--- | --- | ---
searchString | string | the text to search for
matchCase | bool | indicates if it is case sensitive
matchWholeWord | bool | indicates if it matches an entire word only

```js
this._viewer.startSearchMode('PDFTron', false, false);
```

#### exitSearchMode
Finishes the current text search and remove all the highlights.

Returns a Promise.

```js
this._viewer.exitSearchMode();
```

#### findText
Searches asynchronously, starting from the current page, for the given text. PDFViewCtrl automatically scrolls to the position so that the found text is visible.

Returns a Promise.

Parameters:

Name | Type | Description
--- | --- | ---
searchString | string | the text to search for
matchCase | bool | indicates if it is case sensitive
matchWholeWord | bool | indicates if it matches an entire word only
searchUp | bool | indicates if it searches upward
regExp | bool | indicates if searchString is a regular expression

```js
this._viewer.findText('PDFTron', false, false, true, false);
```

#### cancelFindText
Cancels the current text search thread, if exists.

Returns a Promise.

```js
this._viewer.cancelFindText();
```

#### getSelection
Returns the text selection on a given page, if any.

Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | number | the specified page number. It is 1-indexed

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
selection | object | the text selection, in the format `{html: string, unicode: string, pageNumber: number, quads: [[{x: number, y: number}, {x: number, y: number}, {x: number, y: number}, {x: number, y: number}], ...]}`. If no such selection could be found, this would be null

quads indicate the quad boundary boxes for the selection, which could have a size larger than 1 if selection spans across different lines. Each quad have 4 points with x, y coordinates specified in number, representing a boundary box. The 4 points are in counter-clockwise order, though the first point is not guaranteed to be on lower-left relatively to the box.

```js
this._viewer.getSelection(2).then((selection) => {
  if (selection) {
    console.log('Found selection on page', selection.pageNumber);
    for (let i = 0; i < selection.quads.length; i ++) {
      const quad = selection.quads[i];
      console.log('selection boundary quad', i);
      for (const quadPoint of quad) {
        console.log('A quad point has coordinates', quadPoint.x, quadPoint.y);
      }
    }
  }
});
```

#### hasSelection
Returns whether there is a text selection in the current document.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
hasSelection | bool | whether a text selection exists

```js
this._viewer.hasSelection().then((hasSelection) => {
  console.log('There is a selection in the document.');
});
```

#### clearSelection
Clears any text selection in the current document.

Returns a Promise.

```js
this._viewer.clearSelection();
```

#### getSelectionPageRange
Returns the page range (beginning and end) that has text selection on it.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
begin | number | the first page to have selection, -1 if there are no selections
end | number | the last page to have selection,  -1 if there are no selections

```js
this._viewer.getSelectionPageRange().then(({begin, end}) => {
  if (begin === -1) {
    console.log('There is no selection');
  } else {
    console.log('The selection range is from', begin, 'to', end);
  }
});
```

#### hasSelectionOnPage
Returns whether there is a text selection on the specified page in the current document.

Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | number | the specified page number. It is 1-indexed

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
hasSelection | bool | whether a text selection exists on the specified page

```js
this._viewer.hasSelectionOnPage(5).then((hasSelection) => {
  if (hasSelection) {
    console.log('There is a selection on page 5 in the document.');
  }
});
```

#### selectInRect
Selects the text within the given rectangle region.

Parameters:

Name | Type | Description
--- | --- | ---
rect | object | the rectangle region in the format of `x1: number, x2: number, y1: number, y2: number`

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
selected | bool | whether there is text selected

```js
this._viewer.selectInRect({x1: 0, y1: 0, x2: 200.5, y2: 200.5}).then((selected) => {
        console.log(selected);
});
```

#### isThereTextInRect
Returns whether there is text in given rectangle region.

Parameters:

Name | Type | Description
--- | --- | ---
rect | object | the rectangle region in the format of `x1: number, x2: number, y1: number, y2: number`

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
hasText | bool | whether there is text in the region

```js
this._viewer.isThereTextInRect({x1: 0, y1: 0, x2: 200, y2: 200}).then((hasText) => {
        console.log(hasText);
});
```

#### selectAll
Selects all text on the page.

Returns a Promise.

```js
this._viewer.selectAll();
```

### Undo/Redo

#### undo
Undo the last modification.

Returns a Promise.

```js
this._viewer.undo();
```

#### redo
Redo the last modification.

Returns a Promise.

```js
this._viewer.redo();
```

#### canUndo
Checks whether an undo operation can be performed from the current snapshot.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
canUndo | bool | whether it is possible to undo from the current snapshot

```js
this._viewer.canUndo().then((canUndo) => {
  console.log(canUndo ? 'undo possible' : 'no action to undo');
});
```

#### canRedo
Checks whether a redo operation can be perfromed from the current snapshot.

Returns a Promise.

Promise Parameters:

Name | Type | Description
--- | --- | ---
canRedo | bool | whether it is possible to redo from the current snapshot

```js
this._viewer.canRedo().then((canRedo) => {
  console.log(canRedo ? 'redo possible' : 'no action to redo');
});
```

### Others

#### exportAsImage
Export a PDF page to image format defined in `Config.ExportFormat`.

Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | int | the page to be converted
dpi | double | the output image resolution
exportFormat | string | one of `Config.ExportFormat`

Returns a Promise.

Name | Type | Description
--- | --- | ---
path | string | the temp path of the created image, user is responsible for clean up the cache

```js
this._viewer.exportToImage(1, 92, Config.ExportFormat.BMP).then((path) => {
  console.log('export', path);
});
```

#### showCrop
Displays the page crop option. Android only.

Returns a Promise.

```js
this._viewer.showCrop();
```
