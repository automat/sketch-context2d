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
    const centerX = Math.floor(width * 0.5) + 0.5;
    const centerY = Math.floor(height * 0.5) + 0.5;

    ctx.save();
    ctx.translate(padding,padding);

    // dashed radial grid background
    ctx.strokeStyle = '#252525';
    ctx.beginPath();
    ctx.setLineDash([2,2]);

    var maxSize   = Math.max(width,height);
    var minSize   = Math.min(width,height);
    var scaleSize = 2;
    var maxRadius = minSize * 0.5 * 0.9;

    var step, x, y;

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

    var stepAngle = Math.PI * 2 / NUM_HOURS_PER_DAY;
    for(var i = 0; i < NUM_HOURS_PER_DAY + 1; ++i){
        step = stepAngle * i;
        x = centerX + Math.floor(Math.cos(step) * maxSize * scaleSize);
        y = centerY + Math.floor(Math.sin(step) * maxSize);
        ctx.moveTo(centerX,centerY);
        ctx.lineTo(x,y);
    }

    var stepRadius = maxRadius / 6;
    for(var i = 0; i < 6 + 1;++i){
        var radius = stepRadius * (i+1);
        ellipse(centerX,centerY, radius * scaleSize, radius);
    }
    ctx.stroke();
    ctx.setLineDash([]);

    function drawCircles(data,radiusCircle){
        radiusCircle = radiusCircle || 2;
        for(var i = 0; i < NUM_HOURS_PER_DAY; ++i){
            step = i / NUM_HOURS_PER_DAY * Math.PI * 2 + stepAngle * 0.5;

            var value  = data[i];
            var radius = value * maxRadius;
            x = centerX + Math.floor(Math.cos(step) * radius * scaleSize);
            y = centerY + Math.floor(Math.sin(step) * radius);

            circle(x,y,Math.max(radiusCircle * 0.25,value * radiusCircle));
        }
    }

    for(var i = data.length - 1; i > -1; i--){
        ctx.fillStyle = '#05060D';
        ctx.beginPath();
        drawCircles(data[i],12);
        ctx.fill();

        ctx.fillStyle = i === 0 ?  '#CCCCCC' : '#D94B4B';
        drawCircles(data[i],8);
        ctx.fill();
    }

    ctx.restore();
}

module.exports = main;