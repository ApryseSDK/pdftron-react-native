module.exports = {
  prompt: ({ inquirer }) => {
    // defining questions in arrays ensures all questions are asked before next prompt is executed
    const questions = [
      {
        type: 'input',
        name: 'name',
        message: 'Name of event listener? (ex: onLayoutChanged)',
      }
    ]

    return inquirer
      .prompt(questions)
  },
}
