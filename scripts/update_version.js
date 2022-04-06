const fs = require('fs');

function jsonReader(filePath, cb) {
    fs.readFile(filePath, 'utf-8', (err, fileData) => {
        if(err) {
            return cb && cb(err);
        }
        try {
            const object = JSON.parse(fileData);
            return cb && cb(null, object);
        } catch (err) {
            return cb && cb(err);
        }
    });
}

jsonReader('./package.json', (err, data) => {
    if(err){
        console.log(err);
    } else {
        let version = data.version.split('.');
        version[3] =(parseInt(version[3])+1);
        data.version = version.join('.'); 
        fs.writeFile('./package.json', JSON.stringify(data), err => {
            if(err) {
                console.log(err);
            }
        })
    }
})