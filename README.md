# PDFTron React Native Wrapper

- [API](API.md)
- [Prerequisites](#prerequisites)
- [Preview](#preview)
- [Installation](#installation)
- [Usage Github](#usage-github)
- [Usage NPM](#usage-npm)
- [TypeScript](#typescript)
- [Contributing](#contributing)
- [License](#license)

## API

APIs are available on the [API page](API.md).

## Prerequisites

- No license key is required for trial. However, a valid commercial license key is required after trial.
- npm or yarn
- PDFTron SDK >= 9.0.0
- react-native >= 0.60.0
- TypeScript >= 3.4.1 (optional; see [TypeScript](#typescript))

## Preview

|                                                             **Android**                                                             |                                                           **iOS**                                                           |
| :---------------------------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------------------------------------: |
| <img alt='demo-android' src='https://pdftron.s3.amazonaws.com/custom/websitefiles/android/react-native-ui-demo.gif' height="800" /> | <img alt='demo-ios' src='https://pdftron.s3.amazonaws.com/custom/websitefiles/ios/react-native-ui-demo.gif' height="800" /> |

## Legacy UI

Version `2.0.2` is the last stable release for the legacy UI.

The release can be found here: https://github.com/PDFTron/pdftron-react-native/releases/tag/legacy-ui.

## Pre-Java 17

Version `3.0.3-38` is the last stable release for pre-Java 17.

The release can be found here: https://github.com/PDFTron/pdftron-react-native/releases/tag/pre-java17.

## Installation

1. First, follow the official getting started guide on [setting up the React Native environment](https://reactnative.dev/docs/environment-setup), [setting up the iOS and Android environment](https://reactnative.dev/docs/environment-setup), and [creating a React Native project](https://reactnative.dev/docs/environment-setup). The following steps will assume your app is created through `react-native init MyApp`. This guide also applies if you are using the [TypeScript template](https://reactnative.dev/docs/environment-setup#optional-using-a-specific-version-or-template).

2. There are two ways to integrate the SDK:

   - #### Through pdftron's github repo:

     In `MyApp` folder, install `react-native-pdftron` by calling:

     ```shell
     yarn add github:PDFTron/pdftron-react-native
     yarn install
     ```

     or

     ```shell
     npm install github:PDFTron/pdftron-react-native --save
     npm install
     ```

   - #### Through pdftron's npm package:

     In `MyApp` folder, install run the following commands:

     ```shell
     yarn add @pdftron/react-native-pdf
     yarn install
     ```

     or

     ```shell
     npm install @pdftron/react-native-pdf
     npm install
     ```

### Android

1. Add the following in your `android/app/build.gradle` file:

   ```diff
   android {
       ndkVersion rootProject.ext.ndkVersion
   
       compileSdkVersion rootProject.ext.compileSdkVersion

       defaultConfig {
           applicationId "com.reactnativesample"
           minSdkVersion rootProject.ext.minSdkVersion
           targetSdkVersion rootProject.ext.targetSdkVersion
           versionCode 1
           versionName "1.0"
           buildConfigField "boolean", "IS_NEW_ARCHITECTURE_ENABLED", isNewArchitectureEnabled().toString()
   +       multiDexEnabled true
   +       manifestPlaceholders = [pdftronLicenseKey:PDFTRON_LICENSE_KEY]
       }
       ...
   }
   ...

   dependencies {
   +   implementation "androidx.multidex:multidex:2.0.1"
       ...
   }
   ```
   
2. In your `android/gradle.properties` file, add the following line:
   ```diff
   # Add the PDFTRON_LICENSE_KEY variable here.
   # For trial purposes leave it blank.
   # For production add a valid commercial license key.
   PDFTRON_LICENSE_KEY=
   ```
3. Add the following to your `android/app/src/main/AndroidManifest.xml` file:

   ```diff
   <manifest xmlns:android="http://schemas.android.com/apk/res/android"
     package="com.myapp">

     <uses-permission android:name="android.permission.INTERNET" />
     <!-- Required to read and write documents from device storage -->
   + <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
     <!-- Required if you want to record audio annotations -->
   + <uses-permission android:name="android.permission.RECORD_AUDIO" />

     <application
       ...
   +   android:largeHeap="true"
   +   android:usesCleartextTraffic="true">

       <!-- Add license key in meta-data tag here. This should be inside the application tag. -->
   +   <meta-data
   +       android:name="pdftron_license_key"
   +       android:value="${pdftronLicenseKey}"/>

       <activity
         ...
   -     android:windowSoftInputMode="adjustResize"
   +     android:windowSoftInputMode="adjustPan"
   +     android:exported="true">
         <intent-filter>
             <action android:name="android.intent.action.MAIN" />
             <category android:name="android.intent.category.LAUNCHER" />
         </intent-filter>
       </activity>
       <activity android:name="com.facebook.react.devsupport.DevSettingsActivity" />
     </application>
   </manifest>
   ```

4. In your `android/app/src/main/java/com/myapp/MainApplication.java` file, change `Application` to `MultiDexApplication`:

   ```diff
   - import android.app.Application;
   + import androidx.multidex.MultiDexApplication;
   ...
   - public class MainApplication extends Application implements ReactApplication {
   + public class MainApplication extends MultiDexApplication implements ReactApplication {
   ```

5. Replace `App.js` (or `App.tsx`) with what is shown for [NPM](#Usage-NPM) or [GitHub](#Usage-Github)
6. Finally in the root project directory, run `react-native run-android`.

### iOS
#### Note — January 2022
**There is a new podspec file to use when integrating the PDFTron React Native Wrapper for iOS:**
**https://pdftron.com/downloads/ios/react-native/latest.podspec**

**Please update your `Podfile` accordingly.**

1. Open `Podfile` in the `ios` folder, add the following line to the `target 'MyApp' do ... end` block:

    ```
    target 'MyApp' do
        # ...
        pod 'PDFNet', podspec: 'https://pdftron.com/downloads/ios/react-native/latest.podspec'
        # ...
    end
    ```

2. In the `ios` folder, run `pod install`.
3. Replace `App.js` (or `App.tsx`) with what is shown for [NPM](#Usage-NPM) or [GitHub](#Usage-Github)
4. Finally in the root project directory, run `react-native run-ios`.
5. (Optional) If you need a close button icon, you will need to add the PNG resources to `MyApp` as well, i.e. `ic_close_black_24px`.

## Usage-Github

If you installed through GitHub, replace `App.js` (or `App.tsx` if you are [using TypeScript](#typescript)) with the code below.

If you set your path variable to point to a local storage file,
then the `PermissionsAndroid` component is required to ensure that storage permission is properly granted.

Within this example there are several sections of commented out code that work together to
handle storage permissions.

Below the example are the types of file paths that are native to iOS or Android and accepted
by the `DocumentView` component.

```javascript
import React, { Component } from "react";
import {
  Platform,
  StyleSheet,
  Text,
  View,
  PermissionsAndroid,
  BackHandler,
  NativeModules,
  Alert,
} from "react-native";

import { DocumentView, RNPdftron } from "react-native-pdftron";

type Props = {};
export default class App extends Component<Props> {
  // If you are using TypeScript, use `constructor(props: Props) {`
  // Otherwise, use:
  constructor(props) {
    super(props);

    // Uses the platform to determine if storage permisions have been automatically granted.
    // The result of this check is placed in the component's state.
    // this.state = {
    //   permissionGranted: Platform.OS === 'ios' ? true : false
    // };

    RNPdftron.initialize("Insert commercial license key here after purchase");
    RNPdftron.enableJavaScript(true);
  }

  // Uses the platform to determine if storage permissions need to be requested.
  // componentDidMount() {
  //   if (Platform.OS === 'android') {
  //     this.requestStoragePermission();
  //   }
  // }

  // Requests storage permissions for Android and updates the component's state using
  // the result.
  // async requestStoragePermission() {
  //   try {
  //     const granted = await PermissionsAndroid.request(
  //       PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE
  //     );
  //     if (granted === PermissionsAndroid.RESULTS.GRANTED) {
  //       this.setState({
  //         permissionGranted: true
  //       });
  //       console.log("Storage permission granted");
  //     } else {
  //       this.setState({
  //         permissionGranted: false
  //       });
  //       console.log("Storage permission denied");
  //     }
  //   } catch (err) {
  //     console.warn(err);
  //   }
  // }

  onLeadingNavButtonPressed = () => {
    console.log("leading nav button pressed");
    if (Platform.OS === "ios") {
      Alert.alert(
        "App",
        "onLeadingNavButtonPressed",
        [{ text: "OK", onPress: () => console.log("OK Pressed") }],
        { cancelable: true }
      );
    } else {
      BackHandler.exitApp();
    }
  };

  render() {
    // If the component's state indicates that storage permissions have not been granted,
    // a view is loaded prompting users to grant these permissions.
    // if (!this.state.permissionGranted) {
    //   return (
    //     <View style={styles.container}>
    //       <Text>
    //         Storage permission required.
    //       </Text>
    //     </View>
    //   )
    // }

    const path =
      "https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_mobile_about.pdf";

    return (
      <DocumentView
        document={path}
        showLeadingNavButton={true}
        leadingNavButtonIcon={
          Platform.OS === "ios"
            ? "ic_close_black_24px.png"
            : "ic_arrow_back_white_24dp"
        }
        onLeadingNavButtonPressed={this.onLeadingNavButtonPressed}
      />
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#F5FCFF",
  },
});
```

- (iOS) For app bundle file path:

  ```javascript
  document = "sample";
  ```

- (Android) For local storage file path:

  ```javascript
  document = "file:///storage/emulated/0/Download/sample.pdf";
  ```

- (Android) For raw resource path (include file extension):

  ```javascript
  document = "android.resource://mypackagename/raw/sample.pdf";
  ```

- (Android) For content Uri:

  ```javascript
  document = "content://...";
  ```
  
## Usage-NPM

If you installed through NPM package, Replace `App.js` (or `App.tsx` if you are [using TypeScript](#typescript)) with the code below.

If you set your path variable to point to a local storage file,
then the `PermissionsAndroid` component is required to ensure that storage permission is properly granted.

Within this example there are several sections of commented out code that work together to
handle storage permissions.

Below the example are the types of file paths that are native to iOS or Android and accepted
by the `DocumentView` component.

if you are using the npm package use this instead

```javascript
import React, { Component } from "react";
import {
  Platform,
  StyleSheet,
  Text,
  View,
  PermissionsAndroid,
  BackHandler,
  NativeModules,
  Alert,
} from "react-native";

import { DocumentView, RNPdftron } from "@pdftron/react-native-pdf";

type Props = {};
export default class App extends Component<Props> {
  // If you are using TypeScript, use `constructor(props: Props) {`
  // Otherwise, use:
  constructor(props) {
    super(props);

    // Uses the platform to determine if storage permisions have been automatically granted.
    // The result of this check is placed in the component's state.
    // this.state = {
    //   permissionGranted: Platform.OS === 'ios' ? true : false
    // };

    RNPdftron.initialize("Insert commercial license key here after purchase");
    RNPdftron.enableJavaScript(true);
  }

  // Uses the platform to determine if storage permissions need to be requested.
  // componentDidMount() {
  //   if (Platform.OS === 'android') {
  //     this.requestStoragePermission();
  //   }
  // }

  // Requests storage permissions for Android and updates the component's state using
  // the result.
  // async requestStoragePermission() {
  //   try {
  //     const granted = await PermissionsAndroid.request(
  //       PermissionsAndroid.PERMISSIONS.WRITE_EXTERNAL_STORAGE
  //     );
  //     if (granted === PermissionsAndroid.RESULTS.GRANTED) {
  //       this.setState({
  //         permissionGranted: true
  //       });
  //       console.log("Storage permission granted");
  //     } else {
  //       this.setState({
  //         permissionGranted: false
  //       });
  //       console.log("Storage permission denied");
  //     }
  //   } catch (err) {
  //     console.warn(err);
  //   }
  // }

  onLeadingNavButtonPressed = () => {
    console.log("leading nav button pressed");
    if (Platform.OS === "ios") {
      Alert.alert(
        "App",
        "onLeadingNavButtonPressed",
        [{ text: "OK", onPress: () => console.log("OK Pressed") }],
        { cancelable: true }
      );
    } else {
      BackHandler.exitApp();
    }
  };

  render() {
    // If the component's state indicates that storage permissions have not been granted,
    // a view is loaded prompting users to grant these permissions.
    // if (!this.state.permissionGranted) {
    //   return (
    //     <View style={styles.container}>
    //       <Text>
    //         Storage permission required.
    //       </Text>
    //     </View>
    //   )
    // }

    const path =
      "https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_mobile_about.pdf";

    return (
      <DocumentView
        document={path}
        showLeadingNavButton={true}
        leadingNavButtonIcon={
          Platform.OS === "ios"
            ? "ic_close_black_24px.png"
            : "ic_arrow_back_white_24dp"
        }
        onLeadingNavButtonPressed={this.onLeadingNavButtonPressed}
      />
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
    backgroundColor: "#F5FCFF",
  },
});
```

- (iOS) For app bundle file path:

  ```javascript
  document = "sample";
  ```

- (Android) For local storage file path:

  ```javascript
  document = "file:///storage/emulated/0/Download/sample.pdf";
  ```

- (Android) For raw resource path (include file extension):

  ```javascript
  document = "android.resource://mypackagename/raw/sample.pdf";
  ```

- (Android) For content Uri:

  ```javascript
  document = "content://...";
  ```
## TypeScript

PDFTron React Native introduced support for TypeScript in version 3.0.0. This update mainly benefits those who already use TypeScript in their applications. It also provides certain benefits to all customers, including those who use JavaScript without TypeScript.

To get access to TypeScript support, simply update your PDFTron React Native dependency to version 3.0.0 or higher.

### All Users

For non-TypeScript users, updating your PDFTron React Native dependency to version 3.0.0 or higher will not automatically install TypeScript itself, and you can continue to use the library as before (without TypeScript support). If you currently do not use TypeScript itself in your project and would like to, see [Adding TypeScript to an Existing Project](https://reactnative.dev/docs/typescript#adding-typescript-to-an-existing-project).

Regardless of whether you use TypeScript, the following benefits are available:

- Proper API typings which can be used in tools such as [IntelliSense](https://code.visualstudio.com/docs/editor/intellisense). This offers insight into the data being passed without referring to the [API documentation](API.md).
- Greater type safety and reliability due to the migration of source files from JavaScript to TypeScript.
- Updated Add an API guides for [Android](https://www.pdftron.com/documentation/android/get-started/react-native/add-an-api/) and [iOS](https://www.pdftron.com/documentation/ios/get-started/react-native/add-an-api) to offer step-by-step, TypeScript-supported examples on accessing properties, methods, and events. Contributors should be aware that PRs must now be made to the `dev` branch (see [Contributing](./CONTRIBUTING.md)).

If you have questions, head to the FAQ's Integration section for [Android](https://www.pdftron.com/documentation/android/faq) and [iOS](https://www.pdftron.com/documentation/ios/faq/).

### TypeScript Users

If you are an existing TypeScript user, then the custom typings will be available to you simply by updating your PDFTron React Native dependency to version 3.0.0 or higher.

Note:

- TypeScript version 3.4.1+ is recommended. Although compilation still works with lower versions, typings may degrade to `any`.
- Due to the introduction of proper typings to PDFTron's APIs, your compiler may now give warnings or errors about your usage of these APIs. In most cases these will not prevent your app from running but it is advised that you address them to take full advantage of TypeScript. It is particularly important to address them if you use TypeScript to emit files and have enabled `noEmitOnError` in your `tsconfig.json`.

## Contributing

See [Contributing](./CONTRIBUTING.md)

## License

See [License](./LICENSE)
![](https://onepixel.pdftron.com/pdftron-react-native)
