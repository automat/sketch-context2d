const fs   = require('fs');
const path = require('path');

const NUM_HOURS_PER_DAY = 24;

var data = (function parse(){
    var src = fs.readFileSync(
        __dirnamePlugin +  '/data/data-activity-top-5.txt',
        'utf8'
    ).split(',');

    var out = new Array(src.length/NUM_HOURS_PER_DAY);
    for(var i = 0; i < out.length; ++i){
        out[i] = new Array(NUM_HOURS_PER_DAY);
        for(var j = 0; j < NUM_HOURS_PER_DAY; ++j){
            out[i][j] = +src[i * NUM_HOURS_PER_DAY + j];
        }
    }

    return out;
})();

function main(canvas){
    var ctx = canvas.getContext('2d');

    const padding = 20;
    const width   = canvas.width - padding * 2;
    const height  = canvas.height - padding * 2;
    const centerY = Math.floor(height * 0.5) + 0.5;

    ctx.save();
    ctx.translate(padding,padding);

    // dashed grid background
    ctx.strokeStyle = '#202020';
    ctx.beginPath();
    ctx.setLineDash([2,2]);

    var stepWidth = width / NUM_HOURS_PER_DAY;
    for(var i = 0; i < NUM_HOURS_PER_DAY + 1; ++i){
        var x = Math.floor(stepWidth * i) + 0.5;
        ctx.moveTo(x, 0);
        ctx.lineTo(x, height);
    }
    ctx.stroke();
    ctx.setLineDash([]);

    function circle(x,y,radius){
        ctx.moveTo(x + radius,y);
        ctx.arc(x,y,radius, 0, Math.PI * 2);
    }

    function ellipse(x,y,radiusx,radiusy){
        ctx.moveTo(x, y - radiusy);

        ctx.bezierCurveTo(
            x + radiusx, y - radiusy,
            x + radiusx, y + radiusy,
            x, y + radiusy
        );

        ctx.bezierCurveTo(
            x - radiusx, y + radiusy,
            x - radiusx, y - radiusy,
            x, y - radiusy
        );
    }

    function drawCandyStick(data){
        var colorA = [217/255,75/255,75/255];
        var colorB = [1,1,1];

        for(var i = 0; i < NUM_HOURS_PER_DAY; ++i){
            var x = stepWidth * 0.5 + stepWidth * i;
            var y = centerY;

            var value = data[i];

            var r = colorA[0] + (colorB[0] - colorA[0]) * value;
            var g = colorA[1] + (colorB[1] - colorA[1]) * value;
            var b = colorA[2] + (colorB[2] - colorA[2]) * value;

            ctx.fillStyle = 'rgb(' + Math.floor(r * 255) + ',' +
                                     Math.floor(g * 255) + ',' +
                                     Math.floor(b * 255) + ')';

            ctx.beginPath();
            circle(x ,y,value * stepWidth * 0.45);
            ctx.fill();
        }
    }

    ctx.strokeStyle = '#05060D';
    ctx.translate(0,- ((data.length+1) * stepWidth * 2 ) * 0.5);
    for(var i = 0; i < data.length; ++i){
        ctx.translate(0,stepWidth * 2);
        drawCandyStick(data[i]);
    }


    ctx.restore();
}

module.exports = main;