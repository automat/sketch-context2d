module.exports = function main(canvas){
    var width  = canvas.width;
    var height = canvas.height;
    var ctx = canvas.getContext('2d');

    var num = 10;
    var size = Math.min(width,height) / (num-1);

    for(var x = 0; x < num; ++x){
        var xn = x / num;
        for(var y = 0; y < num; ++y){
            var yn = y / num;
            ctx.save();
            ctx.fillStyle = 'rgba(' + Math.floor(xn * 255) + ',0,' + Math.floor(yn * 255) + ')';
            ctx.fillRect(x * size, y * size, size, size);
            ctx.restore();
        }
    }
};