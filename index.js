const fs = require('fs');
const path = require('path');
const exec = require('child_process').exec;

const browserify = require('browserify');
const watchify = require('watchify');
const brfs = require('brfs');
const replace = require('browserify-replace');
const validateOptions = require('validate-option');

const PLUGIN_DIR = path.resolve(__dirname,'./plugin');
const COSCRIPT_PATH = path.resolve(__dirname,'./lib/COScript/coscript');

const noop = ()=>{};

/*--------------------------------------------------------------------------------------------------------------------*/
// Default Config
/*--------------------------------------------------------------------------------------------------------------------*/

/**
 * Default Config
 * @type {object}
 * @property {boolean} autoStart
 * @property {boolean} autoArtboard
 * @property {boolean} autoCreate
 * @property {boolean} verbose
 * @property {boolean} verboseLog
 * @property {boolean} recreate
 * @property {boolean} flatten
 * @property {boolean} watch
 * @property {number} maxBuffer
 */
const DefaultConfig = Object.freeze({
    autoStart : true,
    autoArtboard : false,
    autoCreate : false,
    verbose : false,
    verboseLog : false,
    recreate : false,
    flatten : false,
    watch : false,
    maxBuffer : 200 * 1024
});

/*--------------------------------------------------------------------------------------------------------------------*/
// COScript
/*--------------------------------------------------------------------------------------------------------------------*/

const COSCRIPT_DELEGATE_START = '[[COScript app:\\"Sketch\\"] delegate]';
const COSCRIPT_DELEGATE_RUNNING = '[[COScript applicationOnPort:[NSString stringWithFormat:@\\"%@.JSTalk\\", @\\"com.bohemiancoding.sketch3\\"]] delegate]';

/**
 * Runs CO script
 * @param scriptPath
 * @param scriptSource
 * @param sourceMap
 * @param options
 * @param callback
 */
function runCOScript(scriptPath, scriptSource, sourceMap, options, callback = noop){
    //fetch script name
    let name = path.basename(scriptPath);
    name = name.substr(0, name.indexOf('.'));

    //load master cocoascript plugin string, inject options
    const plugin = fs.readFileSync(path.resolve(__dirname,'./index.cocoascript'), 'utf8')
        .replace(new RegExp('__dirname__', 'g'),     "'" + __dirname + "'")
        .replace(new RegExp('__scriptname__', 'g'),  "'" + name + "'")
        .replace(new RegExp('__artboard_auto_select__','g'), options.autoArtboard)
        .replace(new RegExp('__artboard_auto_create__','g'),   options.autoCreate)
        .replace(new RegExp('__recreate__', 'g'),    options.recreate)
        .replace(new RegExp('__verbose__', 'g'),     options.verbose)
        .replace(new RegExp('__verboselog__', 'g'),  options.verboseLog)
        .replace(new RegExp('__flatten__', 'g'),     options.flatten);

    //create temporary cocoascript plugin folder
    try{
        fs.accessSync(PLUGIN_DIR, fs.F_OK)
    }catch(e){
        fs.mkdirSync(PLUGIN_DIR);
    }

    //create temporary cocoascrips plugin
    const pluginCOPath = path.join(PLUGIN_DIR, 'plugin.cocoascript');

    fs.writeFileSync(path.join(PLUGIN_DIR, 'plugin.cocoascript'), plugin);
    fs.writeFileSync(path.join(PLUGIN_DIR, 'plugin.js'), scriptSource);

    //create coscript cmd
    //http://mail.sketchplugins.com/pipermail/dev_sketchplugins.com/2014-August/000548.html
    //http://developer.sketchapp.com/code-examples/third-party-integrations/
    const delegate = options.autoStart ? COSCRIPT_DELEGATE_START : COSCRIPT_DELEGATE_RUNNING;
    const cmd = `${COSCRIPT_PATH} -e "[${delegate} runPluginAtURL:[NSURL fileURLWithPath:\\""${pluginCOPath}"\\"]]"`;

    //execute temp cocoascript
    exec(cmd, {maxBuffer: options.maxBuffer},(err, stdout, stderr)=>{
        if(err || stderr){
            callback(new Error(err || stderr),null);
            return;
        }
        console.log(stdout);
        callback(null,null);
    });
}

/*--------------------------------------------------------------------------------------------------------------------*/
// SketchContext2d
/*--------------------------------------------------------------------------------------------------------------------*/

/**
 * Creates a sketch 2d context
 * @param filePath
 * @param config
 * @param callback
 */
function createSketchContext2d(filePath,config,callback = noop){
    if(!filePath){
        callback(new Error('No entry file passed.'),null);
        return;
    }

    try{
        fs.accessSync(filePath,fs.F_OK);
    } catch(e) {
        callback(new Error(`Invalid file path: ${filePath}`),null);
        return;
    }

    config = validateOptions(config,DefaultConfig);

    const browserifi = browserify((()=>{
        let _config = {
            entries : [filePath],
            debug : true,
            standalone: 'main'
        };
        if(config.watch){
            _config.cache = {};
            _config.packageCache = {};
        }
        return _config;
    })());

    browserifi
        .transform(replace,{
            replace : [{
                from : '__dirnamePlugin',
                to : `"${path.resolve(path.dirname(filePath))}"`
            }]
        })
        .transform(brfs);

    function bundle(){
        let result = '';
        browserifi.bundle()
            .on('data',(data)=>{
                result += data;
            })
            .on('end',()=>{
                const sourceMapIndex = result.indexOf('//# sourceMappingURL');
                let sourceMap = result.substr(sourceMapIndex);
                let scriptSource = result.substr(0,sourceMapIndex);

                scriptSource = scriptSource.substr(0,scriptSource.length - 1);
                //appended exported method call with canvas instance
                scriptSource = scriptSource + 'main(__ATSketchCanvasInstance);';
                sourceMap = sourceMap.split('\n')[0];

                runCOScript(filePath,scriptSource,sourceMap,config,callback);
            })
            .on('error',(err)=>{
                callback(err,null);
            });
    }
    bundle();

    if(config.watch){
        browserifi.plugin(watchify).on('update', bundle);
    }
}

module.exports = createSketchContext2d;