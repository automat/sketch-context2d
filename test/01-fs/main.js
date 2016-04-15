const fs   = require('fs');
const path = require('path');
const ease = require('./ease');

/*--------------------------------------------------------------------------------------------------------------------*/
// data prep
/*--------------------------------------------------------------------------------------------------------------------*/

const data = fs.readFileSync(path.join(__dirnamePlugin,'data'),'utf8').split(',');
const SAMPLE_LENGTH    = Math.min(1024,data.length / 2 - 2);

function normalize(value,start,end){
    return (value - start) / (end - start);
}

var dataLinear = (function(data){
    var out = new Array(SAMPLE_LENGTH);

    var minLinear = data[0];
    var maxLinear = data[SAMPLE_LENGTH * 2];
    var minWeight = Number.MAX_VALUE;
    var maxWeight =-Number.MAX_VALUE;

    for(var i = 0; i < SAMPLE_LENGTH; ++i){
        var weight = data[i*2+1];
        minWeight = Math.min(weight,minWeight);
        maxWeight = Math.max(weight,maxWeight);

        out[i] = {
            d: normalize(data[i*2],minLinear,maxLinear),
            w: weight
        };
    }
    for(var i = 0; i < SAMPLE_LENGTH; ++i){
        out[i].w = normalize(out[i].w, minWeight, maxWeight);
    }
    return out;
})(data);


/*--------------------------------------------------------------------------------------------------------------------*/
// draw
/*--------------------------------------------------------------------------------------------------------------------*/

function main(canvas){
    const padding = 60;
    const width   = canvas.width - padding * 2;
    const height  = 100;

    const ctx = canvas.getContext('2d');
    var entry;
    var x,y;

    function fillCircle(x,y,r){
        ctx.beginPath();
        circle(x,y,r);
        ctx.fill();
    }

    function circle(x,y,r){
        ctx.moveTo(x + r, y);
        ctx.arc(x,y,r,0,Math.PI*2);
    }

    function lineH(x0,x1,y){
        ctx.moveTo(x0,y);
        ctx.lineTo(x1,y);
    }

    function lineV(x,y0,y1){
        ctx.moveTo(x,y0);
        ctx.lineTo(x,y1);
    }

    function strokeLineH(x0,x1,y){
        ctx.beginPath();
        lineH(x0,x1,y);
        ctx.stroke();
    }

    function strokeLineV(x,y0,y1){
        ctx.beginPath();
        lineV(x,y0,y1);
        ctx.stroke();
    }

    function line(x0,y0,x1,y1){
        ctx.moveTo(x0,y0);
        ctx.lineTo(x1,y1);
    }

    function strokeLine(x0,y0,x1,y1){
        ctx.beginPath();
        line(x0,y0,x1,y1);
        ctx.stroke();
    }

    function rgbk(k){
        return 'rgb(' + k + ',' + k + ',' + k + ')';
    }

    function rgb(r,g,b){
        return 'rgb(' + r + ',' + g + ',' + b + ')';
    }


    //linear
    ctx.translate(padding,padding * 1.25);

    ctx.lineWidth = 1;
    ctx.strokeStyle = rgbk(35);
    ctx.beginPath();
    for(var i = 0, l = 4; i < l; ++i){
        var r = (i+1) / l * width * 0.5;
        circle(width * 0.5, width * 0.5, r);
    }
    ctx.stroke();

    ctx.strokeStyle = rgbk(20);
    ctx.beginPath();
    lineH(0,width,width * 0.5);
    lineV(width * 0.5,0,width);
    ctx.stroke();

    ctx.strokeStyle = 'orange';
    for(var i = 0; i < SAMPLE_LENGTH; ++i){
        entry = dataLinear[i];
        var a = entry.d * Math.PI * 2;
        var r = entry.w * width * 0.45;
        x  = width * 0.5 + Math.cos(a) * r;
        y  = width * 0.5 + Math.sin(a) * r;

        ctx.strokeStyle = rgbk(Math.floor(50 + (1.0 - entry.w) * 205));
        strokeLine(
            width * 0.5 + Math.cos(a) * (r*0.75),
            width * 0.5 + Math.sin(a) * (r*0.75),
            x,y
        );

        ctx.fillStyle = '#fff';
        fillCircle(x,y, ease.stepSmooth(1.0 - entry.w) * 8);
        ctx.fillText('ab',x,y);
    }

    //step
    ctx.translate(0,width + padding * 3);

    ctx.lineWidth = 3;
    ctx.strokeStyle = '#fff';
    for(var i = 0; i < SAMPLE_LENGTH; ++i){
        entry = dataLinear[i];
        x = entry.d * width;
        y = entry.w * 80 * -1;

        var nx;
        if(i < SAMPLE_LENGTH-1){
            var nentry = dataLinear[i+1];
            nx = x + (nentry.d - entry.d) * width;
        } else {
            nx = width;
        }

        strokeLineH(x,nx,y);

    }

    //something
    ctx.translate(0,50);

    ctx.lineWidth = 1;
    ctx.strokeStyle = 'rgb(50,50,50)';
    strokeLineH(0,width,0);

    ctx.fillStyle = '#fff';
    for(var i = 0; i < SAMPLE_LENGTH; ++i){
        fillCircle(dataLinear[i].d * width,0,ease.stepCubed(dataLinear[i].w) * 5);
    }
}

module.exports = main;