module.exports = function main(canvas){
    var width  = canvas.width;
    var height = canvas.height;
    var ctx = canvas.getContext('2d');

    var num = 20;

    for(var i = 0; i < num; ++i){
        var n = i / (num - 1);
        var x = n * width;
        ctx.lineWidth = i;
        ctx.strokeStyle = 'rgb(' + Math.floor(n * 255) + ',0,0)';
        ctx.beginPath();
        ctx.moveTo(x,0);
        ctx.lineTo(x,height);
        ctx.stroke();
    }
};