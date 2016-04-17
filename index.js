const argv = require('minimist')(process.argv.slice(2));
const fs   = require('fs');
const path = require('path');

// Help

if(argv['help']){
    console.log('--help     ',   'Show all argument options');
    console.log('--verbose  ',   'Log process');
    console.log('--log-verbose ','Log js script line number and columns');
    console.log('--recreate ',   'Don´t override target groups, create new ones')
    console.log('--flatten  ',   'Flattens resulting path group to image');
    console.log('--watch    ',   'Watch js script');
    console.log('');
}

/*--------------------------------------------------------------------------------------------------------------------*/
// Input script path validation
/*--------------------------------------------------------------------------------------------------------------------*/

// Validate script input
var scriptPath = argv._[0];
if(!scriptPath){
    console.log('No js script path passed.');
    return;
}

// validate script path
try{
    fs.accessSync(scriptPath, fs.F_OK);
} catch (e) {
    console.log("Invalid script path.");
    return;
}

/*--------------------------------------------------------------------------------------------------------------------*/
// run
/*--------------------------------------------------------------------------------------------------------------------*/

const exec = require('child_process').exec;

const PLUGIN_DIR    = './plugin';
const COSCRIPT_PATH = './lib/COScript/coscript';

function runScript(scriptPath, scriptSource, sourceMap){
    var name = path.basename(scriptPath);
        name = name.substr(0,name.indexOf('.'));

    var plugin = fs.readFileSync('./index.cocoascript','utf8')
        .replace(new RegExp('__dirname__','g'),    "'" + __dirname + "'")
        .replace(new RegExp('__scriptname__','g'), "'" + name + "'")
        .replace(new RegExp('__recreate__', 'g'),  !!argv['recreate'])
        .replace(new RegExp('__verbose__', 'g'),   !!argv['verbose'])
        .replace(new RegExp('__verboselog__','g'), !!argv['verbose-log'])
        .replace(new RegExp('__flatten__', 'g'),   !!argv['flatten']);

    try{
        fs.accessSync(PLUGIN_DIR, fs.F_OK)
    } catch (e){
        fs.mkdirSync(PLUGIN_DIR);
    }

    var pluginCOPath = path.join(PLUGIN_DIR,'plugin.cocoascript');

    fs.writeFileSync(path.join(PLUGIN_DIR,'plugin.cocoascript'),plugin);
    fs.writeFileSync(path.join(PLUGIN_DIR,'plugin.js'),scriptSource);

    //http://mail.sketchplugins.com/pipermail/dev_sketchplugins.com/2014-August/000548.html
    //http://developer.sketchapp.com/code-examples/third-party-integrations/
    var cmd = COSCRIPT_PATH + ' -e "[[[COScript app:\\"Sketch\\"] delegate] runPluginAtURL:[NSURL fileURLWithPath:\\""' + pluginCOPath + '"\\"]]"';
    exec(cmd, function (err, stdout, stderr) {
        if(err || stderr){
            throw new Error(err || stderr);
        }
        console.log(stdout);
    });
}

/*--------------------------------------------------------------------------------------------------------------------*/
// Browserify
/*--------------------------------------------------------------------------------------------------------------------*/
if(!!argv['verbose']){
    console.log('Preparing script...');
}

const brfs    = require('brfs');
const replace = require('browserify-replace');


var options = {
    entries : [scriptPath],
    debug: true,
    standalone: 'main'
};

var isWatching = !!argv['watch'];
var watchify;
if(isWatching){
    watchify = require('watchify');

    options.cache = {};
    options.packageCache = {};
}

const browserify = require('browserify')(options);

var result = '';
browserify
    .transform(replace,{
        replace:[{
            from:'__dirnamePlugin',
            to:"'" + path.resolve(path.dirname(scriptPath)) + "'"}]
    })
    .transform(brfs);

function bundle(){
    browserify.bundle()
        .on('data',function(data){
            result += data;
        })
        .on('end',function(){
            var sourceMapIndex = result.indexOf('//# sourceMappingURL');
            var sourceMap      = result.substr(sourceMapIndex);
            var scriptSource   = result.substr(0,sourceMapIndex);

            scriptSource = scriptSource.substr(0,scriptSource.length-1);
            //appended exported method call with canvas instance
            scriptSource = scriptSource + 'main(__ATSketchCanvasInstance);';
            sourceMap    = sourceMap.split('\n')[0];

            runScript(scriptPath, scriptSource, sourceMap);
            result = '';
        })
        .on('error',function(err){
            throw new Error(err);
        });
}
bundle();

if(isWatching){
    browserify
        .plugin(watchify)
        .on('update',function(){
            bundle()
        });
}





