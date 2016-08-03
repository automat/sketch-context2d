module.exports = function main(canvas){
    var width  = canvas.width;
    var height = canvas.height;
    var ctx = canvas.getContext('2d');

    var num = 100;

    var areaWidth = width / 3;
    var areas = [
        [0,0,areaWidth,height],
        [areaWidth,0,areaWidth,height],
        [areaWidth*2,0,areaWidth,height]
    ];

    var fonts = [
        '16px sans-serif',
        '32px serif',
        '12px monospace'
    ];

    function drawText(font,bounds){
        ctx.font = font;
        var x = bounds[0];
        var y = bounds[1];
        var w = bounds[2];
        var h = bounds[3];
        for(var i = 0; i < num; ++i){
            var n = i / (num - 1);
            ctx.fillText(n.toFixed(2),x + Math.random() * w, y + Math.random() * h);
        }
    }

    for(var i = 0; i < areas.length; ++i){
        drawText(fonts[i],areas[i]);
    }
};