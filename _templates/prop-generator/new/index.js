module.exports = {
    prompt: ({ inquirer }) => {
      // defining questions in arrays ensures all questions are asked before next prompt is executed
      const questions = [
        {
          type: 'input',
          name: 'name',
          message: 'Name of prop?',
        },
        {
          type: 'input',
          name: 'propType',
          message: 'Type of prop? Choose from: bool, string, int, double, oneOf, arrayOf\n',
        }
      ]

      return inquirer
        .prompt(questions)
        .then(answers => {
          const propType = answers.propType.trim()
          const questions = [
            {
              type: 'input',
              name: 'paramName',
              message: 'Name of parameter?',
              default: answers.name,
            }
          ]

          if (propType === 'oneOf' || propType === 'arrayOf') {
            questions.unshift({
              type: 'input',
              name: 'configType',
              message: 'Name of the Config constant type for the ' + propType + '? (ex: Config.LayoutMode)',
            })
          }

          return inquirer.prompt(questions).then(nextAnswers => Object.assign({}, answers, nextAnswers))
        })
    },
  }
