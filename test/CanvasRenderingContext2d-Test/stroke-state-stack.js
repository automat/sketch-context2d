module.exports = function main(canvas){
    var width  = canvas.width;
    var height = canvas.height;
    var ctx = canvas.getContext('2d');

    var lineWidth = 4;
    var num = 10;
    var size = Math.min(width,height) / (num-1);
    var sizeInset = size - lineWidth * 2;

    ctx.lineWidth = lineWidth;

    for(var x = 0; x < num; ++x){
        var xn = x / num;
        for(var y = 0; y < num; ++y){
            var yn = y / num;
            ctx.save();
            ctx.strokeStyle = 'rgba(' + Math.floor(xn * 255) + ',0,' + Math.floor(yn * 255) + ')';
            ctx.strokeRect(
                x * size + lineWidth,
                y * size + lineWidth,
                sizeInset,
                sizeInset
            );
            ctx.restore();
        }
    }
};