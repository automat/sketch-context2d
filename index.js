const argv = require('minimist')(process.argv.slice(2));
const fs   = require('fs');
const path = require('path');

if(argv['help']){
    console.log('--help    ','Show all argument options');
    console.log('--verbose ','Log js script line number and columns');
    console.log('--recreate','Don´t override target groups, create new ones.')
    console.log('');
}

//check if js script passed
var scriptSrc = argv._[0];
if(!scriptSrc){
    console.log('No js script path passed.');
    return;
}

//check if path exists
try{
    fs.accessSync(scriptSrc, fs.F_OK);
} catch (e) {
    console.log("Invalid script path.");
    return;
}

//build plugin
var scriptName = path.basename(scriptSrc);
    scriptName = scriptName.substr(0,scriptName.indexOf('.'));

const pluginPath = 'plugin/plugin.cocoascript';

var pluginCode = fs.readFileSync('./scripts/template.cocoascript','utf8')
    .replace('__dirname__',      __dirname)
    .replace('__dirname__',      __dirname)
    .replace('__scriptName__',   scriptName)
    .replace('__recreate__',     argv['recreate'])
    .replace('__verbose__',      argv['verbose'])
    .replace('__scriptContent__',fs.readFileSync(scriptSrc,'utf8'));

fs.writeFileSync(pluginPath,pluginCode);

//execute
