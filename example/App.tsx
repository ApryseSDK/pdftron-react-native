import 'react-native-gesture-handler';

import React from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createStackNavigator} from '@react-navigation/stack';
import {SafeAreaProvider} from 'react-native-safe-area-context';

import * as FileSystem from 'expo-file-system';

import Browser from './components/Browser';
import PDFViewer from './components/PDFViewer';

if (typeof Intl === 'undefined') {
  require('intl');
  require('intl/locale-data/jsonp/en');
}

type StackParams = {
  Browser: {currDir: string; path: string};
  PDFViewer: {currDir: string; path: string};
  MiscFileViewer: {currDir: string; path: string};
};

const Stack = createStackNavigator<StackParams>();

export default function App() {
  const root: string = FileSystem.documentDirectory || '';
  const path = root.endsWith('/') ? root.substring(0, root.length - 1) : root;

  return (
    <SafeAreaProvider>
      <NavigationContainer>
        <Stack.Navigator
          initialRouteName="Browser"
          screenOptions={{
            headerShown: false,
          }}>
          <Stack.Screen
            name="Browser"
            component={Browser}
            initialParams={{
              path: path,
              currDir: 'Browser',
            }}
            options={({route}) => ({
              title: route?.params?.currDir || 'Browser',
            })}
          />
          <Stack.Screen
            name="PDFViewer"
            component={PDFViewer}
            options={({route}) => ({
              title: route?.params?.currDir || 'PDFViewer',
            })}
          />
        </Stack.Navigator>
      </NavigationContainer>
    </SafeAreaProvider>
  );
}
