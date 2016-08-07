module.exports = function main(canvas){
    var ctx = canvas.getContext('2d');

    var fillStyles = [null,undefined,0,'string'];

    for(var i = 0; i < fillStyles.length; ++i){
        ctx.fillStyle = fillStyles[i];
        ctx.fillRect(0,i * 100,100,100);
    }
};