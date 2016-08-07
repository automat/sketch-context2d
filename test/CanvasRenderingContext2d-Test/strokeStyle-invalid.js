module.exports = function main(canvas){
    var ctx = canvas.getContext('2d');

    var strokeStyles = [null,undefined,0,'string'];

    for(var i = 0; i < strokeStyles.length; ++i){
        ctx.strokeStyle = strokeStyles[i];
        ctx.strokeRect(0,i * 100,100,100);
    }
};