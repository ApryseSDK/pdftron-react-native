import React, {useState} from 'react';
import {
  StyleSheet,
  View,
  Text,
  Image,
  TouchableOpacity,
  Alert,
} from 'react-native';
import {useNavigation} from '@react-navigation/native';
import {StackNavigationProp} from '@react-navigation/stack';

import * as FileSystem from 'expo-file-system';
import * as Sharing from 'expo-sharing';
import FileViewer from 'react-native-file-viewer';

import * as mime from 'react-native-mime-types';
import {DateTime} from 'luxon';
import {RNPdftron} from 'react-native-pdftron';

import BottomSheet from './BottomSheet';
import InputDialog from './InputDialog';

import {MaterialCommunityIcons} from '@expo/vector-icons';

export type FileInfo = {
  name: string;
  selected?: boolean;
  exists: true;
  uri: string;
  size: number;
  isDirectory: boolean;
  modificationTime: number;
  md5?: string;
};

const fileIcons: {
  [key: string]: React.ComponentProps<typeof MaterialCommunityIcons>['name'];
} = {
  json: 'code-json',
  pdf: 'file-pdf-box',
  msword: 'file-word-outline',
  'vnd.openxmlformats-officedocument.wordprocessingml.document':
    'file-word-outline',
  'vnd.ms-excel': 'file-excel-outline',
  'vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'file-excel-outline',
  'vnd.ms-powerpoint': 'file-powerpoint-outline',
  'vnd.openxmlformats-officedocument.presentationml.presentation':
    'file-powerpoint-outline',
  zip: 'folder-zip-outline',
  'vnd.rar': 'folder-zip-outline',
  'x-7z-compressed': 'folder-zip-outline',
  xml: 'xml',
  css: 'language-css3',
  csv: 'file-delimited-outline',
  html: 'language-html5',
  javascript: 'language-javascript',
  plain: 'text-box-outline',
};

type FileItemProps = {
  file: FileInfo;
  currentDir: string;
  refreshFiles: () => void;
  setSnack: (msg: string) => void;
};

type FileThumbnailProps = {
  type: string;
  format: string;
  uri: string;
};

const FileThumbnail = ({type, format, uri}: FileThumbnailProps) => {
  switch (type) {
    case 'dir':
      return <MaterialCommunityIcons name="folder-outline" size={35} />;
    case 'image':
    case 'video':
      return <Image style={styles.image} source={{uri}} />;
    case 'audio':
      return <MaterialCommunityIcons name="volume-high" size={35} />;
    case 'font':
      return <MaterialCommunityIcons name="format-font" size={35} />;
    case 'application':
      return (
        <MaterialCommunityIcons
          name={fileIcons[format] || 'file-outline'}
          size={35}
        />
      );
    case 'text':
      return (
        <MaterialCommunityIcons
          name={fileIcons[format] || 'file-outline'}
          size={35}
        />
      );
    default:
      return <MaterialCommunityIcons name="file-outline" size={35} />;
  }
};

const FileItem = ({
  file,
  currentDir,
  refreshFiles,
  setSnack,
}: FileItemProps) => {
  const navigation = useNavigation<StackNavigationProp<any>>();

  const [itemActionsVisible, setItemActionsVisible] = useState(false);
  const [renameDialogVisible, setRenameDialogVisible] = useState(false);

  // splitting the file name from its extension; fileName is empty if there is no extension
  const fileName = file.name.substring(0, file.name.indexOf('.'));
  const fileExt = file.name.substring(file.name.indexOf('.') + 1);

  const fileMime = mime.lookup(file.uri) || '';
  const fileType: string = file.isDirectory ? 'dir' : fileMime.split('/')[0];
  const fileFormat: string = file.isDirectory ? 'dir' : fileMime.split('/')[1];

  const onItemPress = () => {
    if (file.isDirectory) {
      navigation.push('Browser', {
        currDir: file.name,
        path: currentDir,
      });
    } else if (fileFormat === 'pdf') {
      navigation.push('PDFViewer', {
        currDir: file.name,
        path: currentDir,
      });
    } else {
      FileViewer.open(file.uri).catch(() => {
        setSnack('Could not open file. File format may be unsupported.');
      });
    }
  };

  const humanFileSize = (bytes: number) => {
    const threshold = 1000;
    const dp = 1;
    const r = 10 ** dp;
    const units = ['kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];

    if (Math.abs(bytes) < threshold) {
      return bytes + ' B';
    }

    let u = -1;
    do {
      bytes /= threshold;
      ++u;
    } while (
      Math.round(Math.abs(bytes) * r) / r >= threshold &&
      u < units.length - 1
    );

    return bytes.toFixed(dp) + ' ' + units[u];
  };

  const rename = (input: string) => {
    const path = currentDir.substring(0, currentDir.lastIndexOf('/'));
    const name = fileName === '' ? input : input + '.' + fileExt;

    FileSystem.getInfoAsync(path + '/' + name).then(res => {
      if (res.exists) {
        setSnack('A folder or file with the same name already exists.');
      } else
        FileSystem.moveAsync({
          from: file.uri,
          to: path + '/' + name,
        })
          .then(() => {
            setRenameDialogVisible(false);
            refreshFiles();
          })
          .catch(e => {
            console.log(e);
            setSnack(
              `Error renaming the ${file.isDirectory ? 'folder' : 'file'}.`,
            );
          });
    });
  };

  const share = () => {
    Sharing.isAvailableAsync().then(canShare => {
      if (canShare) {
        Sharing.shareAsync(file.uri).catch(() =>
          setSnack('Error opening sharing options.'),
        );
      }
    });
  };

  const deleteFile = () => {
    Alert.alert(
      'Confirm Delete',
      'Are you sure you want to delete this file?',
      [
        {
          text: 'Cancel',
          onPress: () => {},
          style: 'cancel',
        },
        {
          text: 'Delete',
          onPress: () => {
            FileSystem.deleteAsync(file.uri)
              .catch(err => {
                setSnack(
                  `Error deleting the ${file.isDirectory ? 'folder' : 'file'}.`,
                );
                console.log(err);
              })
              .finally(refreshFiles);
          },
        },
      ],
    );
  };

  const officeFileTypes = [
    'vnd.openxmlformats-officedocument.wordprocessingml.document',
    'vnd.ms-excel',
    'vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'vnd.ms-powerpoint',
    'vnd.openxmlformats-officedocument.presentationml.presentation',
  ];

  let items = ['Rename', 'Share', 'Delete'];
  let itemIcons: React.ComponentProps<typeof MaterialCommunityIcons>['name'][] =
    ['pencil', 'share', 'delete'];
  let itemActions = [
    () => {
      setItemActionsVisible(false);
      setRenameDialogVisible(true);
    },
    share,
    deleteFile,
  ];

  if (officeFileTypes.includes(fileFormat)) {
    items.splice(1, 0, 'Export to PDF');
    itemIcons.splice(1, 0, 'file-pdf-box');

    itemActions.splice(1, 0, async () => {
      const prefix = 'file://';
      let path = null;

      try {
        path = await RNPdftron.pdfFromOffice(
          file.uri.substring(prefix.length),
          {
            applyPageBreaksToSheet: true,
            displayChangeTracking: true,
            excelDefaultCellBorderWidth: 1,
            excelMaxAllowedCellCount: 250000,
            locale: 'en-US',
          },
        );

        await FileSystem.copyAsync({
          from: prefix + path,
          to:
            file.uri.substring(0, file.uri.lastIndexOf('/') + 1) +
            fileName +
            '.pdf',
        });
      } catch (e) {
        console.log(e);
        setSnack('Error converting selected file to PDF.');
      }

      if (path) {
        FileSystem.deleteAsync(prefix + path)
          .catch(e => {
            console.log(e);
            setSnack('Error deleting the temporary file.');
          })
          .finally(refreshFiles);
      }
    });
  }

  return (
    <View style={styles.container}>
      <BottomSheet
        title={file.name}
        visible={itemActionsVisible}
        items={items}
        itemIcons={itemIcons}
        onItemPress={itemActions}
        onClose={() => setItemActionsVisible(false)}
      />
      <InputDialog
        title={'Enter a new name:'}
        initialValue={fileName !== '' ? fileName : file.name}
        visible={renameDialogVisible}
        setVisible={setRenameDialogVisible}
        handleInput={rename}
      />
      <View style={styles.itemContainer}>
        <TouchableOpacity style={styles.itemLeft} onPress={onItemPress}>
          <View style={styles.itemThumbnail}>
            <FileThumbnail type={fileType} format={fileFormat} uri={file.uri} />
          </View>
          <View style={styles.itemDetails}>
            <Text style={styles.fileName} numberOfLines={1}>
              {file.name}
            </Text>
            <Text style={styles.fileDetailText}>
              {humanFileSize(file.size)}
            </Text>
            {file.modificationTime && (
              <Text style={styles.fileDetailText}>
                {DateTime.fromSeconds(file.modificationTime).toRelative()}
              </Text>
            )}
          </View>
        </TouchableOpacity>
        <TouchableOpacity onPress={() => setItemActionsVisible(true)}>
          <View style={styles.fileMenu}>
            {!file.selected ? (
              <MaterialCommunityIcons name="dots-vertical" size={24} />
            ) : (
              <MaterialCommunityIcons name="checkbox-marked" size={24} />
            )}
          </View>
        </TouchableOpacity>
      </View>
    </View>
  );
};

export default FileItem;

const styles = StyleSheet.create({
  container: {
    display: 'flex',
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    height: 75,
  },
  itemContainer: {
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    width: '100%',
    height: '100%',
  },
  itemLeft: {
    height: '100%',
    width: '83%',
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  itemThumbnail: {
    height: '100%',
    marginLeft: 8,
    width: '17%',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
  },
  itemDetails: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'flex-start',
    justifyContent: 'center',
    height: '100%',
    width: '83%',
    overflow: 'hidden',
  },
  itemActionButton: {
    width: '8%',
    height: '100%',
  },
  image: {
    margin: 1,
    width: 40,
    height: 50,
    resizeMode: 'cover',
    borderRadius: 5,
  },
  fileMenu: {
    marginRight: 5,
    height: 60,
    display: 'flex',
    justifyContent: 'center',
  },
  fileName: {
    fontSize: 15,
  },
  fileDetailText: {
    fontSize: 10,
  },
});
