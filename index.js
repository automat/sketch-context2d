const fs   = require('fs');
const path = require('path');

const browserify = require('browserify');
const watchify   = require('watchify');
const brfs       = require('brfs');
const replace    = require('browserify-replace');

const exec = require('child_process').exec;
const validateOptions = require('validate-option');

const DEFAULT_OPTIONS = {
    verbose    : false,
    verboseLog : false,
    recreate   : false,
    flatten    : false,
    watch      : false
};

const PLUGIN_DIR    = path.resolve(__dirname,'./plugin');
const COSCRIPT_PATH = path.resolve(__dirname,'./lib/COScript/coscript');

function runScript(scriptPath, scriptSource, sourceMap, options){
    var name = path.basename(scriptPath);
        name = name.substr(0, name.indexOf('.'));

    var plugin = fs.readFileSync(path.resolve(__dirname,'./index.cocoascript'), 'utf8')
        .replace(new RegExp('__dirname__', 'g'), "'" + __dirname + "'")
        .replace(new RegExp('__scriptname__', 'g'), "'" + name + "'")
        .replace(new RegExp('__recreate__', 'g'),   options.recreate)
        .replace(new RegExp('__verbose__', 'g'),    options.verbose)
        .replace(new RegExp('__verboselog__', 'g'), options.verboseLog)
        .replace(new RegExp('__flatten__', 'g'),    options.flatten);

    try{
        fs.accessSync(PLUGIN_DIR, fs.F_OK)
    }catch(e){
        fs.mkdirSync(PLUGIN_DIR);
    }

    var pluginCOPath = path.join(PLUGIN_DIR, 'plugin.cocoascript');

    fs.writeFileSync(path.join(PLUGIN_DIR, 'plugin.cocoascript'), plugin);
    fs.writeFileSync(path.join(PLUGIN_DIR, 'plugin.js'), scriptSource);

    //http://mail.sketchplugins.com/pipermail/dev_sketchplugins.com/2014-August/000548.html
    //http://developer.sketchapp.com/code-examples/third-party-integrations/
    var cmd = COSCRIPT_PATH + ' -e "[[[COScript app:\\"Sketch\\"] delegate] runPluginAtURL:[NSURL fileURLWithPath:\\""' + pluginCOPath + '"\\"]]"';
    exec(cmd, function(err, stdout, stderr){
        if(err || stderr){
            throw new Error(err || stderr);
        }
        console.log(stdout);
    });
}

function SketchContext2d(files,options){
    if(!files || !files.length){
        throw new Error('No entry files passed.');
    }
    options = validateOptions(options,DEFAULT_OPTIONS);

    //validate file paths
    for(var i = 0; i < files.length; ++i){
        var entry = files[i] = path.resolve(__dirname,files[i]);
        try{
            fs.accessSync(entry,fs.F_OK);
        } catch(e){
            throw new Error('Invalid file path: ' + entry);
        }
    }

    //multiple files support will come, just use first atm
    var scriptPath = files[0];

    //gen sourcemaps, export as 'main'
    var optionsbi = {
        entries : [scriptPath],
        debug : true,
        standalone : 'main'
    };

    if(options.watch){
        optionsbi.cache = {};
        optionsbi.packageCache = {};
    }

    var browserifyi = browserify(optionsbi);

    var result = '';
    browserifyi
        .transform(replace,{
            replace:[{
                from:'__dirnamePlugin',
                to:"'" + path.resolve(path.dirname(scriptPath)) + "'"}]
        })
        .transform(brfs);

    function bundle(){
        browserifyi.bundle()
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

                runScript(scriptPath, scriptSource, sourceMap, options);
                result = '';
            })
            .on('error',function(err){
                throw new Error(err);
            });
    }
    bundle();

    if(options.watch){
        browserifyi
            .plugin(watchify)
            .on('update', function(){
                bundle();
            });
    }
}

module.exports = function(files,options){
    return new SketchContext2d(files,options);
};