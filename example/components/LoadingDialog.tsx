import React from 'react';
import {StyleSheet, Modal, View, Text, ActivityIndicator} from 'react-native';

const LoadingDialog = ({visible}: {visible: boolean}) => {
  return (
    <Modal
      animationType="fade"
      transparent={true}
      onRequestClose={() => {}}
      visible={visible}>
      <View style={styles.container}>
        <View style={styles.modal}>
          <ActivityIndicator size="large" />
        </View>
      </View>
    </Modal>
  );
};

export default LoadingDialog;

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  modal: {
    backgroundColor: 'black',
    opacity: 0.5,
    borderRadius: 10,
    padding: 20,
  },
});
