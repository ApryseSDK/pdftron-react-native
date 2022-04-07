module.exports = {
    helpers: {
        parameterize: (params) => {
             arguments = "" 
             params.split(',').forEach((param)=> {  
             arguments +=  param.replace(':',' ')+ ', ' 
             })
             arguments = arguments.substr(0,arguments.length-2)
             return arguments
        }
    }
}