//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/moveTo

function main(canvas){
    var ctx = canvas.getContext('2d');

    ctx.beginPath();
    ctx.moveTo(50,50);
    ctx.lineTo(200, 50);
    ctx.stroke();
}

module.exports = main;