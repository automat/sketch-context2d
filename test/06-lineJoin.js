//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/lineJoin

function main(canvas){
    var ctx = canvas.getContext('2d');

    var lineJoin = ['round','bevel','miter'];
    ctx.lineWidth = 10;

    for (var i = 0; i < lineJoin.length; i++) {
        ctx.lineJoin = lineJoin[i];
        ctx.beginPath();
        ctx.moveTo(-5,5+i*40);
        ctx.lineTo(35,45+i*40);
        ctx.lineTo(75,5+i*40);
        ctx.lineTo(115,45+i*40);
        ctx.lineTo(155,5+i*40);
        ctx.stroke();
    }
}

module.exports = main;
