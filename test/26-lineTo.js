//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/lineTo

function main(canvas){
    var ctx = canvas.getContext('2d');

    ctx.beginPath();
    ctx.moveTo(0,0);
    ctx.lineTo(100, 100);
    ctx.stroke();
}

module.exports = main;