import React, {useEffect, useState} from 'react';
import {
  FlatList,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  Alert,
  Platform,
} from 'react-native';
import {Snackbar, Menu, Provider} from 'react-native-paper';
import * as FileSystem from 'expo-file-system';
import * as DocumentPicker from 'expo-document-picker';
import {StatusBar} from 'expo-status-bar';

import {StackScreenProps} from '@react-navigation/stack';
import {useSafeAreaInsets} from 'react-native-safe-area-context';

import {MaterialCommunityIcons, MaterialIcons} from '@expo/vector-icons';
import mime from 'react-native-mime-types';
import {DateTime} from 'luxon';

import BottomSheet from './BottomSheet';
import FileItem, {FileInfo} from './FileItem';
import InputDialog from './InputDialog';
import LoadingDialog from './LoadingDialog';
import {pdfUrls} from '../utils/Utils';

type BrowserParams = {
  Browser: {currDir: string; path: string};
};

type BrowserProps = StackScreenProps<BrowserParams, 'Browser'>;

const Browser = ({navigation, route}: BrowserProps) => {
  const [plusVisible, setPlusVisible] = useState(false);

  const [newFileBottomSheet, setNewFileBottomSheet] = useState(false);
  const [downloadDialogVisible, setDownloadDialogVisible] = useState(false);
  const [folderDialogVisible, setFolderDialogVisible] = useState(false);
  const [loadingDialogVisible, setLoadingDialogVisible] = useState(false);

  const [snackMessage, setSnackMessage] = useState('');
  const [snackVisible, setSnackVisible] = useState(false);

  const [files, setFiles] = useState<FileInfo[]>([]);

  const [currentDir] = useState(route.params.path + '/' + route.params.currDir);

  const insets = useSafeAreaInsets();

  const getFiles = React.useCallback(() => {
    FileSystem.readDirectoryAsync(currentDir).then(names => {
      const fileInfos = names.map(name =>
        FileSystem.getInfoAsync(currentDir + '/' + name),
      );
      Promise.all(fileInfos).then(results => {
        let tempFiles: FileInfo[] = results.map((file, index) => {
          return Object({
            ...file,
            name: names[index],
            selected: false,
          });
        });
        setFiles(tempFiles);
      });
    });
  }, [currentDir]);

  const renderFile = ({item}: {item: FileInfo}) => (
    <FileItem
      file={item}
      currentDir={currentDir}
      refreshFiles={getFiles}
      setSnack={setSnack}
    />
  );

  const handleDownload = async (url: string) => {
    setLoadingDialogVisible(true);

    const res = await fetch(url);
    const fileExt = mime.extension(res.headers.get('Content-Type'));
    const fileName =
      '/DL_' + DateTime.now().toFormat('yyyyMMddHHmmss') + '.' + fileExt;

    FileSystem.downloadAsync(url, currentDir + fileName)
      .catch(e => console.log(e))
      .finally(() => {
        getFiles();
        setLoadingDialogVisible(false);
      });
  };

  const createDirectory = (name: string) => {
    FileSystem.makeDirectoryAsync(currentDir + '/' + name)
      .then(() => {
        getFiles();
      })
      .catch(() => {
        setSnack('Folder could not be created or already exists.');
      });
  };

  const pickFromStorage = () => {
    setPlusVisible(false);

    const pick = () => {
      DocumentPicker.getDocumentAsync({
        copyToCacheDirectory: false,
      })
        .then(result => {
          if (result.type === 'success') {
            FileSystem.getInfoAsync(currentDir + '/' + result.name).then(
              res => {
                const copy = () => {
                  FileSystem.copyAsync({
                    from: result.uri,
                    to: currentDir + '/' + result.name,
                  })
                    .then(() => {
                      getFiles();
                    })
                    .catch(() => {
                      setSnack('File could not be copied successfully.');
                    });
                };

                if (res.exists) {
                  Alert.alert(
                    'Conflicting File',
                    `The destination has a file with the same name ${result.name}.`,
                    [
                      {text: 'Cancel', style: 'cancel'},
                      {text: 'Replace', style: 'default', onPress: copy},
                    ],
                  );
                } else copy();
              },
            );
          }
        })
        .catch(() => {
          setSnack('Failed opening the document picker.');
        });
    };

    if (Platform.OS === 'ios') setTimeout(pick, 500);
    else pick();
  };

  const setSnack = (msg: string) => {
    setSnackMessage(msg);
    setSnackVisible(true);
  };

  // effect to automatically download sample PDF files to the root folder
  React.useEffect(() => {
    const root: string = FileSystem.documentDirectory || '';
    const path = root.endsWith('/') ? root + 'Browser' : root + '/' + 'Browser';
    if (currentDir !== path) return;

    FileSystem.makeDirectoryAsync(path)
      .then(() => {
        // browser root folder newly created, therefore download sample files
        setLoadingDialogVisible(true);
        const download = pdfUrls.map(url =>
          FileSystem.downloadAsync(
            url,
            path + '/' + url.substring(url.lastIndexOf('/') + 1),
          ),
        );

        Promise.all(download)
          .catch(e => console.log(e))
          .finally(() => {
            getFiles();
            setLoadingDialogVisible(false);
          });
      })
      .catch(() => {
        // browser root folder already exists, do nothing
      });
  }, [currentDir, getFiles]);

  // load in files when currentDir is set
  useEffect(() => {
    getFiles();
  }, [getFiles]);

  // reload files when this screen comes back in focus (i.e. when user navigates back to it)
  useEffect(() => {
    return navigation.addListener('focus', () => {
      getFiles();
    });
  }, [getFiles, navigation]);

  return (
    <Provider>
      <View style={styles.container}>
        <Snackbar
          visible={snackVisible}
          onDismiss={() => setSnackVisible(false)}>
          {snackMessage}
        </Snackbar>
        <BottomSheet
          title="Add a new file"
          visible={newFileBottomSheet}
          items={['Import from storage', 'Download from link']}
          itemIcons={['folder-upload-outline', 'download']}
          onItemPress={[
            () => {
              pickFromStorage();
              setNewFileBottomSheet(false);
            },
            () => {
              // https://pdftron.s3.amazonaws.com/downloads/pl/PDFTRON_mobile_about.pdf
              setDownloadDialogVisible(true);
              setNewFileBottomSheet(false);
            },
          ]}
          onClose={() => setNewFileBottomSheet(false)}
        />
        <InputDialog
          title={'Enter URL:'}
          visible={downloadDialogVisible}
          setVisible={setDownloadDialogVisible}
          handleInput={handleDownload}
        />
        <InputDialog
          title={'Enter folder name:'}
          visible={folderDialogVisible}
          setVisible={setFolderDialogVisible}
          handleInput={createDirectory}
        />
        <LoadingDialog visible={loadingDialogVisible} />
        <View style={[styles.topRow, {paddingTop: insets.top}]}>
          {route.params.currDir === 'Browser' ? (
            <View style={styles.topRowLeft} />
          ) : (
            <TouchableOpacity
              onPress={() => navigation.goBack()}
              style={styles.topRowLeft}>
              <MaterialIcons name="arrow-back-ios" size={25} />
              <Text numberOfLines={1} style={styles.topRowBackText}>
                {route.params.path.split('/').pop()}
              </Text>
            </TouchableOpacity>
          )}
          <Text style={styles.topRowText} numberOfLines={1}>
            {route?.params?.currDir}
          </Text>
          <View style={styles.topRowRight}>
            <Menu
              visible={plusVisible}
              anchor={
                <TouchableOpacity onPress={() => setPlusVisible(true)}>
                  <MaterialCommunityIcons
                    name="plus"
                    size={30}
                    style={styles.topRowButton}
                  />
                </TouchableOpacity>
              }
              onDismiss={() => setPlusVisible(false)}>
              <Menu.Item
                icon="note-plus-outline"
                onPress={() => {
                  setPlusVisible(false);
                  setNewFileBottomSheet(true);
                }}
                title="Add File..."
              />
              <Menu.Item
                icon="folder-plus-outline"
                onPress={() => {
                  setPlusVisible(false);
                  setFolderDialogVisible(true);
                }}
                title="Add Folder"
              />
            </Menu>
          </View>
        </View>
        <View style={[styles.fileList, {paddingBottom: insets.bottom}]}>
          <FlatList
            data={files}
            showsVerticalScrollIndicator={false}
            renderItem={renderFile}
            keyExtractor={(item: FileInfo) => item.name}
          />
        </View>
      </View>
      <StatusBar style={'auto'} />
    </Provider>
  );
};

export default Browser;

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  topRow: {
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginVertical: 10,
    marginHorizontal: 15,
  },
  topRowLeft: {
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'flex-start',
    alignItems: 'center',
    width: '33%',
  },
  topRowBackText: {
    marginLeft: -3,
    width: '70%',
  },
  topRowText: {
    textAlign: 'center',
    width: '33%',
  },
  topRowRight: {
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'flex-end',
    alignItems: 'center',
    width: '33%',
  },
  topRowButton: {
    paddingHorizontal: 3,
  },
  fileList: {
    flex: 1,
    marginHorizontal: 15,
    marginVertical: 5,
  },
});
