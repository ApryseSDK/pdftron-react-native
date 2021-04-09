# PDFTron React Native Wrapper

- [API](#API)
- [Prerequisites](#prerequisites)
- [Preview](#preview)
- [Installation](#installation)
- [Usage](#usage)
- [Components](#components)
- [License](#license)

## API
APIs are available on the [API page](API.md).

## Prerequisites
- No license key is required for trial. However, a valid commercial license key is required after trial.
- npm or yarn
- PDFTron SDK >= 6.10.0
- react-native >= 0.60.0

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
    +     android:theme="@style/PDFTronAppTheme">
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
3. Replace `App.js` with what is shown [here](#usage).
4. Finally in the root project directory, run `react-native run-ios`.

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

## Contributing
See [Contributing](./CONTRIBUTING.md)

## License
See [License](./LICENSE)
![](https://onepixel.pdftron.com/pdftron-react-native)
