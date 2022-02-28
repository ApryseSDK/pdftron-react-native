module.exports = {
    prompt: ({ inquirer }) => {
      // defining questions in arrays ensures all questions are asked before next prompt is executed
      const questions = [{
        type: 'input',
        name: 'numberOfParams',
        message: 'Number of params? (ex: 1)',
      },
      {
        type: 'input',
        name: 'params',
        message: 'Params? (seperate by comma, ex: boolean:flag,int:page,.. )',
      }]
  
      return inquirer
        .prompt(questions)
    },
  }