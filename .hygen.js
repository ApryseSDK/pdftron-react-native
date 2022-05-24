module.exports = {
    helpers: {
        androidParameters: (params, setFinal) => {
            let arguments = ''
            let finalWord = setFinal ? 'final ' : ''

            let delim = ''
            let skip = false
            params.split(',').forEach(param => {
                if (skip) {
                    if (param.trim().endsWith(delim))
                        skip = false
                    return
                }

                let name = param.substring(0, param.indexOf(':')).trim()
                let type = param.substring(param.indexOf(':') + 1).trim()

                if (type.startsWith('{') || type.startsWith('Record<')) {
                    type = 'ReadableMap'
                    delim = type.startsWith('{') ? '}' : '>'
                    skip = true
                } else if (type.startsWith('AnnotOptions.')) {
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
        // 'flag: boolean, page: int' => 'flag, page'
        argumenterize: params => {
            let arguments = ''

            let delim = ''
            let skip = false
            params.split(',').forEach(param => {
                if (skip) {
                    if (param.trim().endsWith(delim))
                        skip = false
                    return
                }

                let name = param.substring(0, param.indexOf(':')).trim()
                let type = param.substring(param.indexOf(':') + 1).trim()

                if (type.startsWith('{') || type.startsWith('Record<')) {
                    delim = type.startsWith('{') ? '}' : '>'
                    skip = true
                    return
                }

                arguments += name + ', '
            })

            arguments = arguments.substring(0, arguments.length - 2)
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
            }
        }
    }
}
