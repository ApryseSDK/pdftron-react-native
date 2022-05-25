module.exports = {
    helpers: {
        // 'flag: boolean, page: int' => 'boolean flag, int page' or 'final boolean flag, final int page'
        androidParams: (params, setFinal) => {
            let arguments = ''
            let finalWord = setFinal ? 'final ' : ''

            // assuming no nested maps, remove the params inside maps
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
        // 'flag: boolean, page: int' => 'flag:(BOOL)flag page:(NSInteger)page'
        iOSParams: (params, format) => {
            let arguments = ''
            let formatStr = format ? '\n                 ' : ' '

            // assumes no nested maps
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
        // 'flag: boolean, page: int' => 'flag, page'
        androidArgs: params => {
            let arguments = ''

            // assumes no nested maps
            params = params.replace(/((?<=\{)(.*?)(?=}))|((?<=Record<)(.*?)(?=>))/g, '')

            params.split(',').forEach(param => {
                arguments += param.substring(0, param.indexOf(':')).trim() + ', '
            })

            arguments = arguments.substring(0, arguments.length - 2)
            return arguments
        },
        // 'flag: boolean, page: int' => 'flag:flag page:page'
        iOSArgs: params => {
            let arguments = ''

            // assumes no nested maps
            params = params.replace(/((?<=\{)(.*?)(?=}))|((?<=Record<)(.*?)(?=>))/g, '')

            params.split(',').forEach(param => {
                let name = param.substring(0, param.indexOf(':')).trim()
                arguments += name + ':' + name + ' '
            })

            arguments = arguments.substring(0, arguments.length - 1)
            return arguments
        },
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
