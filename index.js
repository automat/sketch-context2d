const argv = require('minimist')(process.argv.slice(2));
const fs   = require('fs');
const path = require('path');

// Help

if(argv['help']){
    console.log('--help     ','Show all argument options');
    console.log('--verbose  ','Log js script line number and columns');
    console.log('--recreate ','Don´t override target groups, create new ones')
    console.log('--flatten  ','Flattens resulting path group to image');
    console.log('--watch    ','Watch js script');
    console.log('');
}

/*--------------------------------------------------------------------------------------------------------------------*/
// Input script path validation
/*--------------------------------------------------------------------------------------------------------------------*/

// Validate script input
var scriptSrc = argv._[0];
if(!scriptSrc){
    console.log('No js script path passed.');
    return;
}


// validate script path
try{
    fs.accessSync(scriptSrc, fs.F_OK);
} catch (e) {
    console.log("Invalid script path.");
    return;
}


/*--------------------------------------------------------------------------------------------------------------------*/
// Build plugin
/*--------------------------------------------------------------------------------------------------------------------*/

const pluginScriptPath = 'plugin/plugin.cocoascript';
const pluginJsPath     = 'plugin/plugin.js';

function build(code,sourceMap){
    var scriptName = path.basename(scriptSrc);
    scriptName = scriptName.substr(0,scriptName.indexOf('.'));

    var pluginScriptCode = fs.readFileSync('./scripts/template.cocoascript','utf8')
        .replace(new RegExp('__dirname__','g'),      __dirname)
        .replace(new RegExp('__scriptName__','g'),   scriptName)
        .replace(new RegExp('__recreate__','g'),     !!argv['recreate'])
        .replace(new RegExp('__verbose__','g'),      !!argv['verbose'])
        .replace(new RegExp('__flatten__','g'),      !!argv['flatten'])
        .replace(new RegExp('__scriptContent__','g'),code)
        .replace(new RegExp('__sourceMap__','g'),    sourceMap);

    fs.writeFileSync(pluginScriptPath,pluginScriptCode);

    code = '(function(){' + code + 'main(__canvasWrap__);})();' + sourceMap;

    fs.writeFileSync(pluginJsPath,code);

}

function execute(){}

/*--------------------------------------------------------------------------------------------------------------------*/
// Browserify
/*--------------------------------------------------------------------------------------------------------------------*/

console.log('Preparing script...');

const browserify = require('browserify')({
    debug : true,
    standalone : 'main'
});

var result = '';
browserify.add(scriptSrc);
browserify.bundle()
    .on('data',function(data){
        result += data;
    })
    .on('end',function(){
        var sourceMapIndex = result.indexOf('//# sourceMappingURL');
        var sourceMap = result.substr(sourceMapIndex);
        var code = result.substr(0,sourceMapIndex);

        build(code.substr(0,code.length-1), sourceMap.split('\n')[0]);
        execute();
    })
    .on('error',function(err){
       throw new Error(err);
    });



