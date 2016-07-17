#!/usr/bin/env node
const argv = require('minimist')(process.argv.slice(2));
const path = require('path');

//help
if(argv['help']){
    console.log('--help     ',   'Show all argument options');
    console.log('--verbose  ',   'Log process');
    console.log('--log-verbose ','Log js script line number and columns');
    console.log('--recreate ',   'Don´t override target groups, create new ones')
    console.log('--flatten  ',   'Flattens resulting path group to image');
    console.log('--watch    ',   'Watch js script');
    console.log('');
}

if(!argv._.length){
    console.log('No js file passed.');
    console.log('sketch-context2d pathToJsFile --help');
    return;
}

const file = path.resolve(argv._[0]);
require('../index.js')([file],{
    verbose    : !!argv['verbose'],
    verboseLog : !!argv['verboseLog'],
    recreate   : !!argv['recreate'],
    flatten    : !!argv['flatten'],
    watch      : !!argv['watch']
});