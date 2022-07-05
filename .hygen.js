module.exports = {
    helpers: {
        /**
         * Converts the parameter list of a React Native function into a parameter list of an Android function.
         * e.g. 'flag: boolean, page: int' => 'boolean flag, int page' or 'final boolean flag, final int page'
         * @param params React Native parameter list string
         * @param setFinal Whether to add the 'final' keyword in front of each parameter
         * @returns {string} Android parameter list string
         */
        androidParams: (params, setFinal) => {
            let arguments = ''
            let finalWord = setFinal ? 'final ' : ''

            // assuming no nested maps, remove the params inside maps (in between {} or Record<>)
            // so that the top level parameters can be properly split by commas
            params = params.replace(/((?<=\{)(.*?)(?=}))|((?<=Record<)(.*?)(?=>))/g, '')

            params.split(',').forEach(param => {
                let name = param.substring(0, param.indexOf(':')).trim()
                let type = param.substring(param.indexOf(':') + 1).trim()

                if ((type.startsWith('{') && type.endsWith('}')) ||
                    (type.startsWith('Record<') && type.endsWith('>')) ||
                    type.startsWith('AnnotOptions.')) {
                    type = 'ReadableMap'
                } else if (type.startsWith('Config.') || type === 'string') {
                    type = 'String'
                } else if (type.startsWith('Array<') && type.endsWith('>')) {
                    type = 'ReadableArray'
                }

                arguments += finalWord + type + ' ' + name + ', '
            })

            arguments = arguments.substring(0, arguments.length - 2)
            return arguments
        },
        /**
         * Converts the parameter list of a React Native function into a parameter list of an iOS function.
         * e.g. 'flag: boolean, page: int' => 'flag:(BOOL)flag page:(NSInteger)page'
         * @param params React Native parameter list string
         * @param format Whether to separate each parameter by newlines
         * @returns {string} iOS parameter list string
         */
        iOSParams: (params, format) => {
            let arguments = ''
            let formatStr = format ? '\n                 ' : ' '

            params = params.replace(/((?<=\{)(.*?)(?=}))|((?<=Record<)(.*?)(?=>))/g, '')

            params.split(',').forEach(param => {
                let name = param.substring(0, param.indexOf(':')).trim()
                let type = param.substring(param.indexOf(':') + 1).trim()

                if ((type.startsWith('{') && type.endsWith('}')) ||
                    (type.startsWith('Record<') && type.endsWith('>')) ||
                    type.startsWith('AnnotOptions.')) {
                    type = 'NSDictionary *'
                } else if (type === 'boolean') {
                    type = 'BOOL'
                } else if (type === 'int') {
                    type = 'NSInteger'
                } else if (type.startsWith('Config.') || type === 'string') {
                    type = 'NSString *'
                } else if (type.startsWith('Array<') && type.endsWith('>')) {
                    type = 'NSArray *'
                }

                arguments += name + ':(' + type + ')' + name + formatStr
            })

            arguments = arguments.substring(0, arguments.length - formatStr.length)
            return arguments
        },
        /**
         * Converts the parameter list of a React Native function into arguments when calling an Android function.
         * e.g. 'flag: boolean, page: int' => 'flag, page'
         * @param params React Native parameter list string
         * @returns {string} Android arguments string
         */
        androidArgs: params => {
            let arguments = ''

            params = params.replace(/((?<=\{)(.*?)(?=}))|((?<=Record<)(.*?)(?=>))/g, '')

            params.split(',').forEach(param => {
                arguments += param.substring(0, param.indexOf(':')).trim() + ', '
            })

            arguments = arguments.substring(0, arguments.length - 2)
            return arguments
        },
        /**
         * Converts the parameter list of a React Native function into arguments when calling an iOS function.
         * e.g. 'flag: boolean, page: int' => 'flag:flag page:page'
         * @param params React Native parameter list string
         * @returns {string} iOS arguments string
         */
        iOSArgs: params => {
            let arguments = ''

            params = params.replace(/((?<=\{)(.*?)(?=}))|((?<=Record<)(.*?)(?=>))/g, '')

            params.split(',').forEach(param => {
                let name = param.substring(0, param.indexOf(':')).trim()
                arguments += name + ':' + name + ' '
            })

            arguments = arguments.substring(0, arguments.length - 1)
            return arguments
        },
        /**
         * Converts the React Native prop type into a corresponding Android type.
         * @param type React Native prop type
         * @returns {string|*} Android prop type; returns given param if no match is found
         */
        androidPropType: type => {
            if (type === 'bool') {
                return 'boolean'
            } else if (type === 'string' || type === 'oneOf') {
                return 'String'
            } else if (type === 'arrayOf') {
                return '@NonNull ReadableArray'
            } else {
                return type
            }
        },
        /**
         * Converts the React Native function return type into a corresponding Android type.
         * @param type React Native function return type
         * @returns {string|*} Android return type; returns given param if no match is found
         */
        androidReturnType: type => {
            if (type.startsWith('Config.') || type === 'string') {
                return 'String'
            } else if ((type.startsWith('{') && type.endsWith('}')) ||
                       (type.startsWith('Record<') && type.endsWith('>')) ||
                        type.startsWith('AnnotOptions.')) {
                return 'WritableMap'
            } else if (type.startsWith('Array<') && type.endsWith('>')) {
                return 'WritableArray'
            } else {
                return type
            }
        },
        /**
         * Converts the React Native function return type into a corresponding iOS type.
         * @param type React Native function return type
         * @returns {string|*} iOS return type; returns given param if no match is found
         */
        iOSReturnType: type => {
            if (type === 'boolean') {
                return 'BOOL'
            } else if (type === 'int') {
                return 'NSInteger'
            } else if (type.startsWith('Config.') || type === 'string') {
                return 'NSString *'
            } else if ((type.startsWith('{') && type.endsWith('}')) ||
                       (type.startsWith('Record<') && type.endsWith('>')) ||
                        type.startsWith('AnnotOptions.')) {
                return 'NSDictionary *'
            } else if (type.startsWith('Array<') && type.endsWith('>')) {
                return 'NSArray *'
            } else {
                return type
            }
        }
    }
}
