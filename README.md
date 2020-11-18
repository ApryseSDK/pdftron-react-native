# PDFTron React Native Wrapper

- [Prerequisites](#prerequisites)
- [Preview](#preview)
- [Installation](#installation)
- [Usage](#usage)
- [Components](#components)
- [License](#license)

## Prerequisites
- No license key is required for trial. However, a valid commercial license key is required after trial.
- npm or yarn
- PDFTron SDK >= 6.10.0
- react-native >= 0.60.0 (for versions before 0.60.0, use branch `rn553`)

## Preview

**Android** |  **iOS**
:--:|:--:
<img alt='demo-android' src='https://pdftron.s3.amazonaws.com/custom/websitefiles/android/react-native-ui-demo.gif' height="800" /> | <img alt='demo-ios' src='https://pdftron.s3.amazonaws.com/custom/websitefiles/ios/react-native-ui-demo.gif' height="800" />

## Legacy UI

Version `2.0.2` is the last stable release for the legacy UI.

The release can be found here: https://github.com/PDFTron/pdftron-react-native/releases/tag/legacy-ui.

## Installation

0. If using yarn, do: `yarn global add react-native-cli`

1. First, follow the official getting started guide on [setting up the React Native environment](https://reactnative.dev/docs/environment-setup), [setting up the iOS and Android environment](https://reactnative.dev/docs/environment-setup), and [creating a React Native project](https://reactnative.dev/docs/environment-setup), the following steps will assume your app is created through `react-native init MyApp`.

2. In `MyApp` folder, install `react-native-pdftron` by calling:
    ```shell
    yarn add github:PDFTron/pdftron-react-native
    yarn add @react-native-community/cli --dev
    yarn add @react-native-community/cli-platform-android --dev
    yarn add @react-native-community/cli-platform-ios --dev
    yarn install
    ```
    or
    ```shell
    npm install github:PDFTron/pdftron-react-native --save
    npm install @react-native-community/cli --save-dev
    npm install @react-native-community/cli-platform-android --save-dev
    npm install @react-native-community/cli-platform-ios --save-dev
    ```

### Android

1. Add the following in your `android/app/build.gradle` file:

    ```diff
    android {
        compileSdkVersion rootProject.ext.compileSdkVersion

        compileOptions {
            sourceCompatibility JavaVersion.VERSION_1_8
            targetCompatibility JavaVersion.VERSION_1_8
        }

        defaultConfig {
            applicationId "com.reactnativesample"
            minSdkVersion rootProject.ext.minSdkVersion
            targetSdkVersion rootProject.ext.targetSdkVersion
            versionCode 1
            versionName "1.0"
    +       multiDexEnabled true
    +       manifestPlaceholders = [pdftronLicenseKey:PDFTRON_LICENSE_KEY]
        }

        dependencies {
    +       implementation "androidx.multidex:multidex:2.0.1"
        }

        ...
    }
    ```

2. Add the following to your `android/build.gradle` file:
	```diff
	buildscript {
	    ext {
		buildToolsVersion = "28.0.3"
	+	minSdkVersion = 21
		compileSdkVersion = 28
		targetSdkVersion = 28
	    }
	    // ...
	}
	```
3. In your `android/gradle.properties` file. Add the following line to it:
    ``` diff
    # Add the PDFTRON_LICENSE_KEY variable here. 
    # For trial purposes leave it blank.
    # For production add a valid commercial license key.
    PDFTRON_LICENSE_KEY=
    ```
4. Add the following to your `android/app/src/main/AndroidManifest.xml` file:

    ```diff
    <manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="com.myapp">
        
		<uses-permission android:name="android.permission.INTERNET" />
		<!-- Required to read and write documents from device storage -->
	+	<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
		<!-- Required if you want to record audio annotations -->
	+	<uses-permission android:name="android.permission.RECORD_AUDIO" />

      <application
        ...
    +   android:largeHeap="true"
    +   android:usesCleartextTraffic="true">

        <!-- Add license key in meta-data tag here. This should be inside the application tag. -->
    +   <meta-data
    +       android:name="pdftron_license_key"
    +       android:value="${pdftronLicenseKey}"/>

        <activity
          android:name=".MainActivity"
          android:label="@string/app_name"
          android:configChanges="keyboard|keyboardHidden|orientation|screenSize"
    -     android:windowSoftInputMode="adjustResize"
    +     android:windowSoftInputMode="adjustPan"
    +     android:theme="@style/CustomAppTheme">
          <intent-filter>
              <action android:name="android.intent.action.MAIN" />
              <category android:name="android.intent.category.LAUNCHER" />
          </intent-filter>
        </activity>
        <activity android:name="com.facebook.react.devsupport.DevSettingsActivity" />
      </application>
    </manifest>
    ```

5. In your `android\app\src\main\java\com\myapp\MainApplication.java` file, change `Application` to `MultiDexApplication`:
    ```diff
    - import android.app.Application;
    + import androidx.multidex.MultiDexApplication;
    ...
    - public class MainApplication extends Application implements ReactApplication {
    + public class MainApplication extends MultiDexApplication implements ReactApplication {
    ```

6. Replace `App.js` with what is shown [here](#usage)
7. Finally in the root project directory, run `react-native run-android`.

### iOS

1. Open `Podfile` in the `ios` folder, add the followng line to the `target 'MyApp' do ... end` block:

    ```
    target 'MyApp' do
        # ...
        pod 'PDFNet', podspec: 'https://www.pdftron.com/downloads/ios/cocoapods/pdfnet/latest.podspec'
        # ...
    end
    ```

2. In the `ios` folder, run `pod install`.
3. (Optional) If you need a close button icon, you will need to add the PNG resources to `MyApp` as well, i.e. `ic_close_black_24px`.
4. Replace `App.js` with what is shown [here](#usage).
5. Finally in the root project directory, run `react-native run-ios`.

## Usage

Replace `App.js` with the following:

```javascript
import React, { Component } from 'react';
import {
  Platform,
  StyleSheet,
  Text,
  View,
  PermissionsAndroid,
  BackHandler,
  NativeModules,
  Alert
} from 'react-native';

import { DocumentView, RNPdftron } from 'react-native-pdftron';

type Props = {};
export default class App extends Component<Props> {

  constructor(props) {
    super(props);

    this.state = {
      permissionGranted: Platform.OS === 'ios' ? true : false
    };

    RNPdftron.initialize("Insert commercial license key here after purchase");
    RNPdftron.enableJavaScript(true);
  }

  componentDidMount() {
    if (Platform.OS === 'android') {
      this.requestStoragePermission();
    }
  }

  async requestStoragePermission() {
    try {
      const granted = await PermissionsAndroid.request(
        PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE
      );
      if (granted === PermissionsAndroid.RESULTS.GRANTED) {
        this.setState({
          permissionGranted: true
        });
        console.log("Storage permission granted");
      } else {
        this.setState({
          permissionGranted: false
        });
        console.log("Storage permission denied");
      }
    } catch (err) {
      console.warn(err);
    }
  }

  onLeadingNavButtonPressed = () => {
    console.log('leading nav button pressed');
    if (Platform.OS === 'ios') {
      Alert.alert(
        'App',
        'onLeadingNavButtonPressed',
        [
          {text: 'OK', onPress: () => console.log('OK Pressed')},
        ],
        { cancelable: true }
      )
    } else {
      BackHandler.exitApp();
    }
  }

  render() {
    if (!this.state.permissionGranted) {
      return (
        <View style={styles.container}>
          <Text>
            Storage permission required.
          </Text>
        </View>
      )
    }

    const path = "https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_mobile_about.pdf";

    return (
      <DocumentView
        document={path}
        showLeadingNavButton={true}
        leadingNavButtonIcon={Platform.OS === 'ios' ? 'ic_close_black_24px.png' : 'ic_arrow_back_white_24dp'}
        onLeadingNavButtonPressed={this.onLeadingNavButtonPressed}
      />
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  }
});
```

- (iOS) For app bundle file path:

```javascript
document="sample"
```

- (Android) For local storage file path:

```javascript
document="file:///storage/emulated/0/Download/sample.pdf"
```

- (Android) For raw resource path (include file extension):

```javascript
document="android.resource://mypackagename/raw/sample.pdf"
```

- (Android) For content Uri:

```javascript
document="content://..."
```

## API

### RNPdftron

#### initialize
initialize(string)

#### enableJavaScript
enableJavaScript(bool)

#### getVersion
getVersion()

Return a promise with the version of the PDFNet version used.

#### getPlatformVersion
getPlatformVersion()

Return a promise with the version of current platform (Android/iOS).

#### encryptDocument
encryptDocument(string, string, string)

This function does not lock around the document so be sure to not use it while the document is opened in the viewer.

Return a promise.

Example:

```js
RNPdftron.encryptDocument("/sdcard/Download/new.pdf", "1111", "").then(() => {
  console.log("done password");
});
```

Parameters:

Name | Type | Description
--- | --- | ---
file path | string | the local file path to the file
password | string | the password
current password | string | the current password, use empty string if no password
## Components

### DocumentView

A component for displaying documents of different types such as PDF, docx, pptx, xlsx and various image formats.

#### Props

##### document
string, required
##### password
string, optional
##### leadingNavButtonIcon
string, optional
##### onLeadingNavButtonPressed
function, optional
##### showLeadingNavButton
bool, optional
##### onDocumentLoaded
function, optional
##### onDocumentError
function, optional
##### disabledElements
array of string, optional
##### disabledTools
array of string, optional
##### customHeaders
object, optional
##### readOnly
bool, optional, default to false
##### thumbnailViewEditingEnabled
bool, optional, default to true
##### annotationAuthor
string, optional
##### continuousAnnotationEditing
bool, optional
##### selectAnnotationAfterCreation
bool, optional, default to true
##### fitMode
string, optional
##### layoutMode
string, optional
##### initialPageNumber
number, optional
##### pageNumber
number, optional
##### onPageChanged
function, optional
##### onZoomChanged
function, optional

Perameters:

Name | Type | Description
--- | --- | ---
previousPageNumber | int | the previous page number
pageNumber | int | the current page number

##### topToolbarEnabled
Deprecated. Use `hideTopAppNavBar` prop instead.

bool, optional
##### bottomToolbarEnabled
bool, optional
##### annotationToolbars
array of object, options

Defines custom toolbars. If passed in, default toolbars will no longer appear.
It is possible to mix and match with default toolbars. See example below:

```js
const myToolbar = {
  [Config.CustomToolbarKey.Id]: 'myToolbar',
  [Config.CustomToolbarKey.Name]: 'myToolbar', 
  [Config.CustomToolbarKey.Icon]: Config.ToolbarIcons.FillAndSign,
  [Config.CustomToolbarKey.Items]: [Config.Tools.annotationCreateArrow, Config.Tools.annotationCreateCallout, Config.Buttons.undo]
};

annotationToolbars={[Config.DefaultToolbars.Annotate, myToolbar]}
```
##### hideDefaultAnnotationToolbars
array of `Config.DefaultToolbars` tags, optional

Defines which default toolbars should be hidden. Default to none.
##### hideAnnotationToolbarSwitcher
bool, optional

Defines whether to show the toolbar switcher in the top toolbar. Default to false.
##### hideTopToolbars
bool, optional

Defines whether to show both the top nav app bar and the annotation toolbar. Default to false.
##### hideTopAppNavBar
bool, optional

Defines whether to show the top nav app bar. Default to false.
##### hideToolbarsOnTap
bool, optional

Whether an unhandled tap in the viewer should toggle the visibility of the top and bottom toolbars. The default value is `true`. When `false`, the top and bottom toolbar visibility will not be toggled and the page content will fit between the bars, if any.

##### pageIndicatorEnabled
bool, optional
##### showSavedSignatures
bool, optional
##### isBase64String
bool, optional

If true, `document` prop will be treated as a base64 string. 

When viewing a document initialized with a base64 string (ie a memory buffer), a temporary file is created on Android, and no temporary path is created on iOS.
##### padStatusBar
bool, optional, android only

If true, the viewer will add padding to take account of status bar. Default to false.
##### autoSaveEnabled
bool, optional
##### hideAnnotationMenu
array of `Config.Tools` string constants, optional

Defines annotation types that will not show the default annotation menu
##### annotationMenuItems
array of `Config.AnnotationMenu` string constants, optional

Defines menu items that can show when an annotation is selected.
##### overrideAnnotationMenuBehavior
array of `Config.AnnotationMenu` string constants, optional

Defines menu items that should skip default behavior.
##### onAnnotationMenuPress
function, optional

Defines what happens on annotation menu press if it is passed in to `overrideAnnotationMenuBehavior`

Parameters:

Name | Type | Description
--- | --- | ---
annotationMenu | string | One of `Config.AnnotationMenu` string constants
annotations | array | An array of `{id, rect}` objects, where `id` is the annotation identifier and `rect={x1, y1, x2, y2}` specifies the annotation's screen rect.

##### longPressMenuEnabled
bool, optional, default to true

If true, the viewer will show the default menu on long press.

##### longPressMenuItems
array of `Config.LongPressMenu` string constants, optional

Defines menu items that can show when long press on text or blank space.
##### overrideLongPressMenuBehavior
array of `Config.LongPressMenu` string constants, optional

Defines menu items that should skip default behavior.
##### onLongPressMenuPress
function, optional

Defines what happens on long press menu press if it is passed in to `overrideLongPressMenuBehavior`

Parameters:

Name | Type | Description
--- | --- | ---
longPressMenu | string | One of `Config.LongPressMenu` string constants
longPressText | string | the selected text if pressed on text, empty otherwise

##### overrideBehavior
array of `Config.Actions` string constants, optional

Defines actions that should skip default behavior, such as external link click.
##### onBehaviorActivated
function, optional

Defines what happens on certain behavior if it is passed in to `overrideBehavior`

Parameters:

Name | Type | Description
--- | --- | ---
action | string | One of `Config.Actions` string constants
data | object | A JSON object that varies depending on the action

data param table:

Action | Param
--- | ---
`Config.Actions.linkPress` | key: `url`, value: the link pressed

##### pageChangeOnTap
bool, optional, default to true
##### useStylusAsPen
bool, optional, default to true

If true, stylus will act as a pen in pan mode, otherwise it will act as finger

##### signSignatureFieldsWithStamps
bool, optional, default to false

If true, signature field will be signed with image stamp.
This is useful if you are saving XFDF to remote source.

##### followSystemDarkMode
bool, optional, Android only, default to true

If true, UI will appear in dark color when System is dark mode. Otherwise it will use viewer setting instead.
##### collabEnabled
bool, optional, if set to true then `currentUser` must be set as well for collaboration mode to work
##### currentUser
string, required if `collabEnabled` is set to true
##### currentUserName
string, optional
##### onExportAnnotationCommand
function, optional, annotation command will be given on each edit
##### onAnnotationsSelected
function, optional

Parameters:

Name | Type | Description
--- | --- | ---
annotations | array | array of annotation data in the format `{id: string, pageNumber: number, rect: {x1: number, y1: number, x2: number, y2: number}}`

##### onAnnotationChanged
function, optional

Parameters:

Name | Type | Description
--- | --- | ---
action | string | the action that occurred (add, delete, modify)
annotations | array | array of annotation data in the format `{id: string, pageNumber: number}`

##### annotationPermissionCheckEnabled
bool, optional, default to false

If true, annotation's flags will be taken into account when it is selected, for example, a locked annotation can not be resized or moved.

##### onFormFieldValueChanged
function, optional

Parameters:

Name | Type | Description
--- | --- | ---
fields | array | array of field data in the format `{fieldName: string, fieldValue: string}`

##### onBookmarkChanged
function, optional

Defines what happens if a change has been made to bookmarks

Parameters:

Name | Type | Description
--- | --- | ---
bookmarkJson | string | the list of current bookmarks in JSON format

Example:

```js
import { DocumentView, Config } from 'react-native-pdftron';
<DocumentView
  ref={(c) => this._viewer = c}
  document={path}
  showLeadingNavButton={true}
  leadingNavButtonIcon={Platform.OS === 'ios' ? 'ic_close_black_24px.png' : 'ic_arrow_back_white_24dp'}
  onLeadingNavButtonPressed={() => {}}
  onDocumentLoaded={() => {}}
  onDocumentError={() => {}}
  disabledElements={[Config.Buttons.searchButton, Config.Buttons.shareButton]}
  disabledTools={[Config.Tools.annotationCreateLine, Config.Tools.annotationCreateRectangle]}
  customHeaders={{Foo: bar}}
  initialPageNumber={11}
  readOnly={false}
  annotationAuthor={'PDFTron'}
  continuousAnnotationEditing={true}
  fitMode={Config.FitMode.FitPage}
  layoutMode={Config.LayoutMode.Continuous}
  onPageChanged={({previousPageNumber, pageNumber}) => { console.log('page changed'); }}
  onAnnotationChanged={({action, annotations}) => { console.log('annotations changed'); }}
  annotationPermissionCheckEnabled={false}
  onBookmarkChanged={({bookmarkJson}) => { console.log('bookmark changed'); }}
/>
```

#### Methods
- [setToolMode](#settoolmode)
- [commitTool](#committool)
- [getPageCount](#getpagecount)
- [importAnnotations](#importannotations)
- [exportAnnotations](#exportannotations)
- [flattenAnnotations](#flattenannotations)
- [deleteAnnotations](#deleteannotations)
- [saveDocument](#savedocument)
- [setFlagForFields](#setFlagForFields)
- [setValuesForFields](#setValuesForFields)
- [importAnnotationCommand](#importannotationcommand)
- [handleBackButton](#handlebackbutton)
- [selectAnnotation](#selectAnnotation)
- [setFlagsForAnnotations](#setFlagsForAnnotations)
- [setPropertiesForAnnotation](#setPropertiesForAnnotation)
- [getPageCropBox](#getPageCropBox)
- [importBookmarkJson](#importBookmarkJson)
- [setCurrentPage](#setCurrentPage)
- [getDocumentPath](#getDocumentPath)

##### setToolMode
To set the current tool mode (`Config.Tools` constants).

```js
this._viewer.setToolMode(Config.Tools.annotationCreateFreeHand);
```

##### commitTool
Commits the current tool, only available for multi-stroke ink and poly-shape.

Returns a Promise.

```js
this._viewer.commitTool().then((committed) => {
  // committed: true if either ink or poly-shape tool is committed, false otherwise
});
```

##### getPageCount
To get the current page count of the document.

Returns a Promise.

```js
this._viewer.getPageCount().then((pageCount) => {
  console.log('pageCount', pageCount);
});
```

##### importAnnotations
To import XFDF string to the current document.

Returns a Promise.

```js
const xfdf = '<?xml version="1.0" encoding="UTF-8"?>\n<xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">...</xfdf>';
this._viewer.importAnnotations(xfdf);
```

##### exportAnnotations
To extract XFDF from the current document.

Perameters:

Name | Type | Description
--- | --- | ---
options | object | key: annotList, type: array

Returns a Promise.

```js
this._viewer.exportAnnotations().then((xfdf) => {
  console.log('xfdf', xfdf);
});
```

With options:

```js
// annotList is an array of annotation data in the format {id: string, pageNumber: int}
this._viewer.exportAnnotations({annotList: annotations}).then((xfdf) => {
  console.log('xfdf for annotations', xfdf);
});
```

##### flattenAnnotations
To flatten the forms and (optionally) annotations in the current document. The `formsOnly` parameter controls whether only forms are flattened.

Returns a Promise.

```js
// flatten forms and annotations in the current document.
this._viewer.flattenAnnotations(false);
```

##### deleteAnnotations
To delete the specified annotations in the current document.

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

##### saveDocument
To save the current document.

Returns a Promise.

```js
this._viewer.saveDocument().then((filePath) => {
  console.log('saveDocument:', filePath);
});
```

##### setFlagForFields
Set a field flag value on one or more form fields.

Parameters:

Name | Type | Description
--- | --- | ---
fields | array | list of field names for which the flag should be set
flag | integer | flag to be set (see https://www.pdftron.com/api/ios/Enums/PTFieldFlag.html)
value | bool | value to set for flag

Returns a Promise.

```js
this._viewer.setFlagForFields(['First Name', 'Last Name'], Config.FieldFlags.ReadOnly, true);
```

##### setValuesForFields
Set field values on one or more form fields.

Note: the old function `setValueForFields` is deprecated. Please use this one.

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

##### importAnnotationCommand
Import remote annotation command to local document.

Parameters:

Name | Type | Description
--- | --- | ---
xfdfCommand | string | the XFDF command string
initialLoad | bool | whether this is for initial load

Returns a Promise.

##### handleBackButton
Android only.

```js
this._viewer.handleBackButton().then((handled) => {
  if (!handled) {
    BackHandler.exitApp();
  }
});
```

##### selectAnnotation
To select the specified annotation in the current document.

Parameters:

Name | Type | Description
--- | --- | ---
id | string | the id of the target annotation
pageNumber | integer | the page number where the targe annotation is located. It is 1-indexed

Return a Promise.

```js
// select annotation in the current document.
this._viewer.selectAnnotation('annotId1', 1);
```

##### setFlagsForAnnotations
To set flags for specified annotations in the current document. The `flagValue` controls whether a flag will be set to or removed from the annotation.

Note: the old function `setFlagForAnnotations` is deprecated. Please use this one.

Parameters:

Name | Type | Description
--- | --- | ---
annotationFlagList | array | A list of annotation flag operations

Return a Promise.

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
##### setPropertiesForAnnotation
To set properties for specified annotation in the current document, if it is valid. 

Note: the old function `setPropertyForAnnotation` is deprecated. Please use this one.

Parameters:

Name | Type | Description
--- | --- | ---
annotationId | string | the unique id of the annotation
pageNumber | integer | the page number where annotation is located. It is 1-indexed
propertyMap | object | an object containing properties to be set. Available properties are listed below

Properties:

Name | Type | Markup exclusive | Example
--- | --- | --- | ---
rect | object | no | {x1: 1, y1: 2, x2: 3, y2: 4}
contents | string | no | "contents"
subject | string | yes | "subject"
title | string | yes | "title"
contentRect | object | yes | {x1: 1, y1: 2, x2: 3, y2: 4}

Return a promise.

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


##### getPageCropBox
Return a JSON object with properties for position (`x1`, `y1`, `x2` and `y2`) and size (`width` and `height`) of the crop box for specified page.

Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | integer | the page number for the target crop box. It is 1-indexed

Return a Promise.

```js
this._viewer.getPageCropBox(1).then((cropBox) => {
  console.log('bottom-left coordinate:', cropBox.x1, cropBox.y1);
  console.log('top-right coordinate:', cropBox.x2, cropBox.y2);
  console.log('width and height:', cropBox.width, cropBox.height);
});
```

##### importBookmarkJson
Imports user bookmarks to the document. The input needs to be a valid bookmark JSON format, for example {"0":"Page 1"}.

Parameters:

Name | Type | Description
--- | --- | ---
bookmarkJson | String | needs to be in valid bookmark JSON format, for example {"0": "Page 1"}. The page numbers are 1-indexed

Return a Promise.

```js
this._viewer.importBookmarkJson("{\"0\": \"Page 1\", \"3\": \"Page 4\"}");
```

##### setCurrentPage
Set current page of the document.

Parameters:

Name | Type | Description
--- | --- | ---
pageNumber | integer | the page number for the target crop box. It is 1-indexed

Return a Promise (with a boolean that tells whether the setting process is successful).

```js
this._viewer.setCurrentPage(4).then((success) => {
  if (success) {
    console.log("Current page is set to 4.");
  }
});
```

##### getDocumentPath
Return the path of the current document.

Return a Promise.

```js
this._viewer.getDocumentPath().then((path) => {
  console.log('The path to current document is: ' + path);
});
```

## Contributing
See [Contributing](./CONTRIBUTING.md)

## License
See [License](./LICENSE)
![](https://onepixel.pdftron.com/pdftron-react-native)
