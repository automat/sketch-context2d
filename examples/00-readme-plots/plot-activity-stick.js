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

            var r0 = colorA[0] + (colorB[0] - colorA[0]) * value;
            var g0 = colorA[1] + (colorB[1] - colorA[1]) * value;
            var b0 = colorA[2] + (colorB[2] - colorA[2]) * value;

            if(i < NUM_HOURS_PER_DAY - 1){
                var valuen = data[i+1];

                var r1 = colorA[0] + (colorB[0] - colorA[0]) * valuen;
                var g1 = colorA[1] + (colorB[1] - colorA[1]) * valuen;
                var b1 = colorA[2] + (colorB[2] - colorA[2]) * valuen;


                var steps = 5 ;
                for(var j = 0; j < steps; ++j){
                    var n =j / steps;

                    var r = r0 + (r1 - r0) * n;
                    var g = g0 + (g1 - g0) * n;
                    var b = b0 + (b1 - b0) * n;

                    ctx.fillStyle = 'rgb(' + Math.floor(r * 255) + ',' +
                                             Math.floor(g * 255) + ',' +
                                             Math.floor(b * 255) + ')';

                    var intensity = value + (valuen - value) * n;

                    ctx.beginPath();
                    ellipse(x + n * stepWidth,y,intensity * stepWidth * 0.5,intensity * stepWidth * 3);
                    ctx.fill();
                    ctx.lineWidth = 1.5;
                    ctx.stroke();

                }
            }
        }
    }

    ctx.strokeStyle = '#05060D';
    drawCandyStick(data[1]);

    ctx.restore();
}

module.exports = main;