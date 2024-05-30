import * as React from 'react';
import {Button, Image, View} from 'react-native';
import {NavigationContainer} from '@react-navigation/native';
import {createNativeStackNavigator} from '@react-navigation/native-stack';
import DocumentPicker from 'react-native-document-picker';
import RNFS from 'react-native-fs';
import DocumentViewExample from './DocumentView';

const workingImageAssetPath = require('./assets/images/image.png');
const failingImageAssetPath = require('./assets/images/D42373CA-56D6-40CC-9382-C5AEDBDD82E3.jpg');

function HomeScreen({navigation}) {
  const copyAssetImage = async (isWorkingImage = false) => {
    const imageAssetPath = isWorkingImage
      ? workingImageAssetPath
      : failingImageAssetPath;
    const imageName = isWorkingImage
      ? 'image.png'
      : 'D42373CA-56D6-40CC-9382-C5AEDBDD82E3.jpg';
    const destPath = `${RNFS.DocumentDirectoryPath}/${imageName}`;

    try {
      const sourcePath = Image.resolveAssetSource(imageAssetPath).uri;

      // Download the image to the document directory
      const downloadResumable = RNFS.downloadFile({
        fromUrl: sourcePath,
        toFile: destPath,
      });

      await downloadResumable.promise;
    } catch (error) {
      console.error('Failed to copy/download image:', error);
    }

    return destPath;
  };

  return (
    <View
      style={{flex: 1, alignItems: 'center', justifyContent: 'space-evenly'}}>
      <Button
        title={'Open File (file system)'}
        onPress={() => {
          DocumentPicker.pickSingle({
            mode: 'open',
            presentationStyle: 'fullScreen',
            copyToCacheDirectory: false,
          }).then(f => {
            navigation.navigate('DocumentView', {
              path: f.uri,
            });
          });
        }}
      />
      <Button
        title={'Open Image (with issue)'}
        onPress={async () => {
          const imagePath = await copyAssetImage();
          navigation.navigate('DocumentView', {
            path: imagePath,
          });
        }}
      />
      <Button
        title={'Open Image (without issue)'}
        onPress={async () => {
          const imagePath = await copyAssetImage(true);
          navigation.navigate('DocumentView', {
            path: imagePath,
          });
        }}
      />
    </View>
  );
}

const Stack = createNativeStackNavigator();

function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="DocumentView" component={DocumentViewExample} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default App;
