# PDFTron React Native Wrapper

- [Prerequisites](#prerequisites)
- [Preview](#preview)
- [Installation](#installation)
- [Usage](#usage)
- [Components](#components)
- [License](#license)

## Prerequisites
- No license key is requird for trial. However, a valid commercial license key is required after trial.
- npm
- PDFTron SDK >= 6.10.0
- react-native >= 0.59.0

## Preview

**Android** |  **iOS**
:--:|:--:
<img alt='demo' src='http://pdftron.s3.amazonaws.com/custom/websitefiles/react-native-pdftron-demo-android.gif' style='width:80%' /> | ![demo](./react-native-pdftron-demo-ios.gif)

## Installation

### Android

1. First, follow the official getting started guide on [setting up the React Native environment](https://facebook.github.io/react-native/docs/getting-started.html#the-react-native-cli-1), [setting up the Android environment](https://facebook.github.io/react-native/docs/getting-started.html#android-development-environment), and [creating a React Native project](https://facebook.github.io/react-native/docs/getting-started.html#creating-a-new-application-1), the following steps will assume your package ID is `com.myapp` (by calling `react-native init MyApp`)
2. In `MyApp` folder, install `react-native-pdftron` by calling:
    ```shell
    npm install git+https://github.com/PDFTron/pdftron-react-native.git --save
    ```
3. Then link the module by calling: 
    ```shell
    react-native link react-native-pdftron
    ```
4. In your root `android/build.gradle` file, add the following:

    ```diff
    buildscript {
        ext {
            buildToolsVersion = "28.0.3"
            minSdkVersion = 16
            compileSdkVersion = 28
            targetSdkVersion = 28
            supportLibVersion = "28.0.0"
        }
        repositories {
            google()
            jcenter()
        }
        dependencies {
            classpath 'com.android.tools.build:gradle:3.3.1'

            // NOTE: Do not place your application dependencies here; they belong
            // in the individual module build.gradle files
        }
    }

    allprojects {
        repositories {
            mavenLocal()
            google()
            jcenter()
            maven {
                // All of React Native (JS, Obj-C sources, Android binaries) is installed from npm
                url "$rootDir/../node_modules/react-native/android"
            }
    +       maven {
    +           url "https://pdftron-maven.s3.amazonaws.com/release"
    +       }
        }
    }
    ```

5. Add the following in your `android/app/build.gradle` file:

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
        }

    +   configurations.all {
    +       resolutionStrategy.force "com.android.support:appcompat-v7:28.0.0"
    +       resolutionStrategy.force "com.android.support:support-v4:28.0.0"
    +   }
        dependencies {
    +       implementation "com.android.support:multidex:1.0.3"
        }

        ...
    }
    ```

6. Add the following to your `android/app/src/main/AndroidManifest.xml` file:

    ```diff
    <manifest xmlns:android="http://schemas.android.com/apk/res/android"
        package="com.myapp">
    + <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

      <application
        ...
    +   android:largeHeap="true"
    +   android:usesCleartextTraffic="true">

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

7. In your `android\app\src\main\java\com\reactnativesample\MainApplication.java` file, change `Application` to `MultiDexApplication`:
    ```diff
    - import android.app.Application;
    + import android.support.multidex.MultiDexApplication;
    ...
    - public class MainApplication extends Application implements ReactApplication {
    + public class MainApplication extends MultiDexApplication implements ReactApplication {
    ```

8. Replace `App.js` with what is shown [here](#usage)
9. Finally in the root project directory, run `react-native run-android`.

### iOS

1. First, follow the official getting started guide on [setting up the React Native environment](https://facebook.github.io/react-native/docs/getting-started.html#the-react-native-cli-1), [setting up the iOS environment](https://facebook.github.io/react-native/docs/getting-started.html#xcode), and [creating a React Native project](https://facebook.github.io/react-native/docs/getting-started.html#creating-a-new-application-1). The following steps will assume your app is created through `react-native init MyApp`.
2. In `MyApp` folder, install `react-native-pdftron` by calling:
    ```
    npm install git+https://github.com/PDFTron/pdftron-react-native.git --save
    ```
3. Link the module by calling: 
    ```
    react-native link react-native-pdftron
    ```
4. Add a `Podfile` in the `ios` folder with the following:

    ```
    target 'MyApp' do
        use_frameworks!
        pod 'PDFNet', podspec: 'https://www.pdftron.com/downloads/ios/cocoapods/pdfnet/latest.podspec'
    end
    ```

5. In the `ios` folder, run `pod install`.
6. If you need a close button icon, you will need to add the PNG resources to `MyApp` as well, i.e. `ic_close_black_24px`.
7. Try building `MyApp`. If any error occurs, change the project settings as described [here](https://github.com/facebook/react-native/issues/7308#issuecomment-230198331).
8. Replace `App.js` with what is shown [here](#usage).
9. Finally in the root project directory, run `react-native run-ios`.

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

## Components

### DocumentView

A component for displaying documents of different types such as PDF, docx, pptx, xlsx and various image formats.

#### Props
- [document](#document)
- [password](#password)
- [leadingNavButtonIcon](#leadingnavbuttonicon)
- [onLeadingNavButtonPressed](#onleadingnavbuttonpressed)
- [showLeadingNavButton](#showleadingnavbutton)
- [disabledElements](#disabledelements)
- [disabledTools](#disabledtools)

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
##### disabledElements
array of string, optional
##### disabledTools
array of string, optional
##### customHeaders
object, optional

```js
import { DocumentView, Config } from 'react-native-pdftron';
<DocumentView
  document={path}
  showLeadingNavButton={true}
  leadingNavButtonIcon={Platform.OS === 'ios' ? 'ic_close_black_24px.png' : 'ic_arrow_back_white_24dp'}
  onLeadingNavButtonPressed={this.onLeadingNavButtonPressed}
  disabledElements={[Config.Buttons.searchButton, Config.Buttons.shareButton]}
  disabledTools={[Config.Tools.annotationCreateLine, Config.Tools.annotationCreateRectangle]}
  customHeaders={{Foo: bar}}
/>
```

## Contributing
See [Contributing](./CONTRIBUTING.md)

## License
See [License](./LICENSE)
