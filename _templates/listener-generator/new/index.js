module.exports = {
  prompt: ({ inquirer }) => {
    // defining questions in arrays ensures all questions are asked before next prompt is executed
    const questions = [
      {
        type: 'input',
        name: 'name',
        message: 'Name of event listener? (ex: onLayoutChanged)',
      },
      {
        type: 'input',
        name: 'params',
        message: 'Parameter list of React Native listener (comma separated)? Use either int or double for number\n  (ex: previousPageNumber: int, pageNumber: int, ...)\n',
      }
    ]

    // returning the answers to the prompt
    return inquirer
      .prompt(questions)
  },
}
