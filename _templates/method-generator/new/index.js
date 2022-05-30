module.exports = {
  prompt: ({ inquirer }) => {
    // defining questions in arrays ensures all questions are asked before next prompt is executed
    const questions = [
      {
        type: 'input',
        name: 'name',
        message: 'Name of method?',
      },
      {
        type: 'input',
        name: 'params',
        message: 'Parameter list of React Native method (comma separated)? Use either int or double for number\n  (ex: flag: boolean, page: int, options: { annotList: Array<AnnotOptions.Annotation> }, ...)\n',
      },
      {
        type: 'input',
        name: 'returnType',
        message: 'Return type of React Native method? Use either int or double for number\n  (ex: void, boolean, int, { fieldName: string, fieldValue?: any }, ...)\n',
      }
    ]

    return inquirer
      .prompt(questions)
  },
}
