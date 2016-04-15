//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/getLineDash

function main(canvas){
    var ctx = canvas.getContext('2d');

    ctx.setLineDash([5, 15]);
    console.log(ctx.getLineDash()); // [5, 15]

    ctx.beginPath();
    ctx.moveTo(0,100);
    ctx.lineTo(400, 100);
    ctx.stroke();
}

module.exports = main;
