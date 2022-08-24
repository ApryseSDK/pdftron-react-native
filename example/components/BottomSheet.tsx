import React from 'react';
import {
  Animated,
  StyleSheet,
  TouchableOpacity,
  TouchableWithoutFeedback,
  View,
  Text,
  FlatList,
  Dimensions,
  Platform,
} from 'react-native';
import Modal from 'react-native-modal';

import {MaterialCommunityIcons} from '@expo/vector-icons';
import {useSafeAreaInsets} from 'react-native-safe-area-context';

type BottomSheetProps = {
  visible: boolean;
  onClose: () => void;
  items: string[];
  itemIcons: React.ComponentProps<typeof MaterialCommunityIcons>['name'][];
  onItemPress: Array<() => void>;
  title?: string;
};

type BottomSheetItemProps = {
  item: string;
  icon: React.ComponentProps<typeof MaterialCommunityIcons>['name'];
  onPress: () => void;
};

const BottomSheetItem = ({item, icon, onPress}: BottomSheetItemProps) => {
  return (
    <TouchableOpacity style={styles.itemStyle} onPress={onPress}>
      <View style={styles.iconContainer}>
        <MaterialCommunityIcons name={icon} size={24} />
      </View>
      <Text style={styles.itemText}>{item}</Text>
    </TouchableOpacity>
  );
};

const BottomSheet = ({
  visible,
  onClose,
  items,
  itemIcons,
  onItemPress,
  title,
}: BottomSheetProps) => {
  const insets = useSafeAreaInsets();

  return (
    <Modal
      style={styles.modal}
      isVisible={visible}
      backdropOpacity={0.5}
      onBackdropPress={onClose}>
      <View
        style={[
          styles.modalBody,
          {paddingBottom: Platform.OS === 'android' ? 20 : insets.bottom},
        ]}>
        {title && (
          <View style={styles.titleContainer}>
            <Text style={styles.titleText}>{title}</Text>
          </View>
        )}
        <FlatList
          data={items}
          keyExtractor={item => item}
          renderItem={({item, index}) => (
            <BottomSheetItem
              item={item}
              icon={itemIcons[index]}
              onPress={() => {
                onItemPress[index]();
                onClose();
              }}
            />
          )}
        />
      </View>
    </Modal>
  );
};

export default BottomSheet;

const styles = StyleSheet.create({
  modal: {
    margin: 0,
  },
  modalBody: {
    width: Dimensions.get('window').width,
    backgroundColor: 'white',
    position: 'absolute',
    bottom: 0,
    padding: 10,
    borderTopLeftRadius: 10,
    borderTopEndRadius: 10,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.2,
    shadowRadius: 8,
  },
  titleContainer: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    paddingBottom: 15,
  },
  titleText: {
    color: 'black',
    fontSize: 16,
    textAlign: 'center',
  },
  itemStyle: {
    height: 45,
    display: 'flex',
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'flex-start',
  },
  itemText: {
    color: 'black',
    fontSize: 15,
  },
  iconContainer: {
    marginLeft: 5,
    marginRight: 10,
  },
});
