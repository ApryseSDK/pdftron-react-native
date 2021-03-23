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

Defines buttons to be disabled for the viewer. Strings should be [Config.Buttons](./src/Config/Config.js) constants.

```js
<DocumentView
  disabledElements={[Config.Buttons.userBookmarkListButton]}
/>
```

#### disabledTools
array of string, optional, defaults to none

Defines tools to be disabled for the viewer. Strings should be [Config.Tools](./src/Config/Config.js) constants.

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
previousTool | string | the previous tool (one of the [Config.Tools](./src/Config/Config.js) constants or "unknown tool"), representing the tool before change
tool | string | the current tool (one of the [Config.Tools](./src/Config/Config.js) constants or "unknown tool"), representing the current tool

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
1. Add the image resource to the drawable directory in [example/android/app/src/main/res](./example/android/app/src/main/res). For details about supported file types and potential compression, check out [here](https://developer.android.com/guide/topics/graphics/drawables#drawables-from-images).

<img alt='demo-android' src='https://pdftron.s3.amazonaws.com/custom/websitefiles/react-native/android_add_resources.png'/>

2. Now you can use the image in the viewer. For example, if you add `button_close.png` to drawable, you could use `'button_close'` in leadingNavButtonIcon.

##### iOS
1. After pods has been installed, open the .xcworkspace file for this application in Xcode (in this case, it's [example.xcworkspace](./example/ios/example.xcworkspace)), and navigate through the list below. This would allow you to add resources, in this case, an image, to your project.
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
array of objects, options (one of [Config.DefaultToolbars](./src/Config/Config.js) constants or custom toolbar object)

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

Defines which default annotation toolbars should be hidden. Note that this prop should be used when [`annotationToolbars`](#annotationToolbars) is not defined. Strings should be [Config.DefaultToolbars](./src/Config/Config.js) constants

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
  hideAnnotationToolbarSwitcher={false}
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

Defines the fit mode (default zoom level) of the viewer. String should be one of [Config.FitMode](./src/Config/Config.js) constants.

```js
<DocumentView
  fitMode={Config.FitMode.FitPage}
/>
```

#### layoutMode
string, optional, default value is 'Continuous'

Defines the layout mode of the viewer. String should be one of [Config.LayoutMode](./src/Config/Config.js) constants.

```js
<DocumentView
  layoutMode={Config.LayoutMode.FacingContinuous}
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

### Annotation Menu

#### hideAnnotationMenu
array of strings, optional, defaults to none

Defines annotation types that will not show in the annotation (long-press) menu. Strings should be [Config.Tools](./src/Config/Config.js) constants.

```js
<DocumentView
  hideAnnotationMenu={[Config.Tools.annotationCreateArrow, Config.Tools.annotationEraserTool]}
/>
```

#### annotationMenuItems
array of strings, optional, default contains all the items

Defines the menu items that can show when an annotation is selected. Strings should be [Config.AnnotationMenu](./src/Config/Config.js) constants.

```js
<DocumentView
  annotationMenuItems={[Config.AnnotationMenu.search, Config.AnnotationMenu.share]}
/>
```

#### overrideAnnotationMenuBehavior
array of strings, optional, defaults to none

Defines the menu items that will skip default behavior when pressed. Strings should be [Config.AnnotationMenu](./src/Config/Config.js) constants. They will still be displayed in the annotation menu, and the function [`onAnnotationMenuPress`](#onAnnotationMenuPress) will be called where custom behavior can be implemented.

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
annotationMenu | string | One of [Config.AnnotationMenu](./src/Config/Config.js) constants, representing which item has been pressed
annotations | array | An array of `{id: string, pageNumber: number, type: string, rect: object}` objects, where `id` is the annotation identifier, `pageNumber` is the page number, type is one of the [Config.Tools](./src/Config/Config.js) constants and `rect={x1, y1, x2, y2}` specifies the annotation's screen rect

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

Defines menu items that can show when long press on text or blank space. Strings should be [Config.LongPressMenu](./src/Config/Config.js) constants.

```js
<DocumentView
  longPressMenuItems={[Config.LongPressMenu.copy, Config.LongPressMenu.read]}
/>
```

#### overrideLongPressMenuBehavior
array of strings, optional, defaults to none

Defines the menu items on long press that will skip default behavior when pressed. Strings should be [Config.LongPressMenu](./src/Config/Config.js) constants. They will still be displayed in the long press menu, and the function [`onLongPressMenuPress`](#onLongPressMenuPress) will be called where custom behavior can be implemented.

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
longPressMenu | string | One of [Config.LongPressMenu](./src/Config/Config.js) constants, representing which item has been pressed
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

Defines actions that will skip default behavior, such as external link click. Strings should be [Config.Actions](./src/Config/Config.js) constants. The function [`onBehaviorActivated`](#onBehaviorActivated) will be called where custom behavior can be implemented, whenever the defined actions occur.

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
action | string | One of [Config.Actions](./src/Config/Config.js) constants, representing which action has been activated
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

Defines whether to enable realtime collaboration. If true then `currentUser` must be set as well for collaboration mode to work.

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

This function is called if a change has been made to annotations in the current document. Unlike [`onAnnotationChanged`](#onAnnotationChanged), this function has an XFDF command string as its parameter.

Parameters:

Name | Type | Description
--- | --- | ---
action | string | the action that occurred (add, delete, modify)
xfdfCommand | string | an xfdf string containing info about the edit

```js
<DocumentView
  onExportAnnotationCommand = {({action, xfdfCommand}) => {
    console.log('Annotation edit action is', action);
    console.log('The exported xfdfCommand is', xfdfCommand);
  }}
/>
```

#### onAnnotationsSelected
function, optional

This function is called when an annotation(s) is selected.

Parameters:

Name | Type | Description
--- | --- | ---
annotations | array | array of annotation data in the format `{id: string, pageNumber: number, type: string, rect: {x1: number, y1: number, x2: number, y2: number}}`, representing the selected annotations. Type is one of the [Config.Tools](./src/Config/Config.js) constants

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

This function is called if a change has been made to an annotation(s) in the current document. Unlike `onExportXfdfCommand`, this function has readable annotation objects as its parameter.

Parameters:

Name | Type | Description
--- | --- | ---
action | string | the action that occurred (add, delete, modify)
annotations | array | array of annotation data in the format `{id: string, pageNumber: number, type: string}`, representing the annotations that have been changed. Type is one of the [Config.Tools](./src/Config/Config.js) constants

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

### Thumbnail Browser

#### hideThumbnailFilterModes
array of strings, optional

Defines filter modes that should be hidden in the thumbnails browser. Strings should be [Config.ThumbnailFilterMode](./src/Config/Config.js) constants

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
bool, optional, Android only, defaults to true

Defines whether the UI will appear in a dark color when the system is dark mode. If false, it will use viewer setting instead.

```js
<DocumentView
  signSignatureFieldsWithStamps={false}
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

#### Example:

```js
import { DocumentView, Config } from 'react-native-pdftron';
<DocumentView
  ref={(c) => this._viewer = c}
  document={path}
  showLeadingNavButton={true}
  leadingNavButtonIcon={Platform.OS === 'ios' ? 'ic_close_black_24px.png' : 'ic_arrow_back_white_24dp'}
  onLeadingNavButtonPressed={() => {}}
  onDocumentLoaded={(path) => { console.log('Document is loaded at', path); }}
  disabledElements={[Config.Buttons.searchButton, Config.Buttons.shareButton]}
  disabledTools={[Config.Tools.annotationCreateLine, Config.Tools.annotationCreateRectangle]}
  customHeaders={{Foo: bar}}
  onPageChanged={({previousPageNumber, pageNumber}) => { console.log('page changed'); }}
  onAnnotationChanged={({action, annotations}) => { console.log('annotations changed'); }}
  annotationPermissionCheckEnabled={false}
  onBookmarkChanged={({bookmarkJson}) => { console.log('bookmark changed'); }}
  hideThumbnailFilterModes={[Config.ThumbnailFilterMode.Annotated]}
  onToolChanged={({previousTool,tool}) => { console.log('tool changed'); }}
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

### Annotation Tools

#### setToolMode
Sets the current tool mode.

Parameters:

Name | Type | Description
--- | --- | ---
toolMode | string | One of [Config.Tools](./src/Config/Config.js) string constants, representing to tool mode to set

```js
this._viewer.setToolMode(Config.Tools.annotationCreateFreeHand);
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
pageNumber | integer | the page number for the target crop box. It is 1-indexed

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
const xfdfCommand = 'xfdfCommand <?xml version="1.0" encoding="UTF-8"?><xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve"><add><circle style="solid" width="5" color="#E44234" opacity="1" creationdate="D:20201218025606Z" flags="print" date="D:20201218025606Z" name="9d0f2d63-a0cc-4f06-b786-58178c4bd2b1" page="0" rect="56.4793,584.496,208.849,739.369" title="PDF" /></add><modify /><delete /><pdf-info import-version="3" version="2" xmlns="http://www.pdftron.com/pdfinfo" /></xfdf>';
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
annotationFlagList | array | A list of annotation flag operations. Each element is in the format {id: string, pageNumber: int, flag: [Config.AnnotationFlags](./src/Config/Config.js) constants, flagValue: bool}

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
  title: 'set-prop-for-annot'
});
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
