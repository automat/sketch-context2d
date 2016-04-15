//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/closePath

function main(canvas){
    var ctx = canvas.getContext('2d');

    ctx.beginPath();
    ctx.moveTo(20,20);
    ctx.lineTo(200,20);
    ctx.lineTo(120,120);
    ctx.closePath(); // draws last line of the triangle
    ctx.stroke();
}

module.exports = main;