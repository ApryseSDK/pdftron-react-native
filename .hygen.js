module.exports = {
    helpers: {
        parameterize: params => {
            let arguments = ""
            params.split(',').forEach(param => {
                let splitParam = param.split(':')
                arguments +=  splitParam[1].trim() + ' ' + splitParam[0].trim() + ', '
            })
            arguments = arguments.substr(0, arguments.length - 2)
            return arguments
        },
        argumenterize: params => {
            let arguments = ""
            params.split(',').forEach(param => {
                arguments +=  param.split(':')[0].trim() + ', '
            })
            arguments = arguments.substr(0, arguments.length - 2)
            return arguments
        },
        finalize: params => {
            arguments = ""
            params.split(',').forEach(param => {
                let splitParam = param.split(':')
                arguments += 'final ' + splitParam[1].trim() + ' ' + splitParam[0].trim() + ', '
            })
            return arguments
        },
        getAndroidPropType: type => {
            if (type === 'bool') {
                return 'boolean'
            } else if (type === 'string' || type === 'oneOf') {
                return 'String'
            } else if (type === 'arrayOf') {
                return '@NonNull ReadableArray'
            } else {
                return type
            }
        }
    }
}
