module.exports = {
    prompt: ({ inquirer }) => {
      // defining questions in arrays ensures all questions are asked before next prompt is executed
      const questions = [
        {
          type: 'input',
          name: 'name',
          message: 'Name of method?',
        },
        // {
        //   type: 'input',
        //   name: 'numberOfParams',
        //   message: 'Number of params? (ex: 1)',
        // },
        {
          type: 'input',
          name: 'params',
          message: 'Parameter list for the React Native function? Use either int or double for number (ex: flag: boolean, page: int, ...)\n',
        },
        {
          type: 'input',
          name: 'returnType',
          message: 'Return type for the React Native function? Use either int or double for number (ex: boolean, int, ...)\n',
        }
      ]

      return inquirer
        .prompt(questions)
    },
  }
