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
    for(var i = 0; i < 6 + 1;++i){
        var y = Math.floor(height - i / 6 * height) + 0.5;
        ctx.moveTo(0,y);
        ctx.lineTo(width,y);
    }
    ctx.stroke();
    ctx.setLineDash([]);

    function drawLine(data,begin){
        var paddingTop = height * 0.45;
        var height_ = height - paddingTop;
        for(var i = 0; i < NUM_HOURS_PER_DAY; ++i){
            var xbegin = Math.floor(stepWidth * i) + 0.5;
            var xend   = Math.floor(xbegin + stepWidth);
            var xwidth = xend - xbegin;
            var xmid   = xbegin + Math.floor(xwidth * 0.5);
            var x = xmid - stepWidth * 0.25;
            var y = height - data[i] * height_;


            ctx[i === 0 && begin ? 'moveTo' : 'lineTo'](x,y);

            ctx.lineTo(xmid + stepWidth * 0.25, y);

            if(i > NUM_HOURS_PER_DAY - 2){
                continue;
            }

            var xbeginn = Math.floor(stepWidth * (i+1)) + 0.5;
            var xendn   = Math.floor(xbeginn + stepWidth);
            var xwidthn = xendn - xbeginn;
            var xmidn   = xbeginn + Math.floor(xwidthn * 0.5);
            var yn      = height- data[i+1] * (height - paddingTop);

            ctx.bezierCurveTo(
                xmid  + stepWidth * 0.5, y,
                xmidn - stepWidth * 0.57, yn,
                xmidn - stepWidth * 0.25, yn
            );
        }
    }

    ctx.lineJoin = 'bevel';
    ctx.lineCap = 'round';
    for(var i = data.length - 1; i > -1; i--){
        var outerWidth = 5;

        ctx.strokeStyle = '#05060D';
        ctx.lineWidth =  (data.length - i) + outerWidth;
        ctx.beginPath();
        drawLine(data[i],true);
        ctx.stroke();

        ctx.strokeStyle = i === 0 ?  '#CCCCCC' : '#D94B4B';
        ctx.lineWidth =  ctx.lineWidth - outerWidth;
        ctx.stroke();
    }

    ctx.restore();

}

module.exports = main;