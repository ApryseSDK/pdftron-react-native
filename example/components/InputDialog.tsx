import React from 'react';
import {StyleSheet, TouchableOpacity, Text, TextInput} from 'react-native';
import {Dialog, Portal} from 'react-native-paper';

type InputDialogProps = {
  title: string;
  visible: boolean;
  setVisible: (state: boolean) => void;
  handleInput: (input: string) => void;
  initialValue?: string;
};

const InputDialog = ({
  title,
  visible,
  setVisible,
  handleInput,
  initialValue,
}: InputDialogProps) => {
  const initialState = initialValue || '';
  const [input, setInput] = React.useState(initialState);

  return (
    <Portal>
      <Dialog visible={visible} onDismiss={() => setVisible(false)}>
        <Dialog.Title style={styles.title}>{title}</Dialog.Title>
        <Dialog.Content>
          <TextInput
            style={styles.input}
            value={input}
            onChangeText={text => setInput(text)}
          />
        </Dialog.Content>
        <Dialog.Actions>
          <TouchableOpacity
            style={styles.button}
            onPress={() => {
              setVisible(false);
              setInput('');
            }}>
            <Text>Cancel</Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={styles.button}
            onPress={() => {
              handleInput(input);
              setVisible(false);
              setInput('');
            }}>
            <Text>OK</Text>
          </TouchableOpacity>
        </Dialog.Actions>
      </Dialog>
    </Portal>
  );
};

export default InputDialog;

const styles = StyleSheet.create({
  title: {
    fontSize: 15,
  },
  input: {
    paddingVertical: 5,
    borderBottomWidth: 1,
  },
  button: {
    padding: 10,
  },
});
