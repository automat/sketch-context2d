//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/globalAlpha

function main(canvas){
    var ctx = canvas.getContext("2d");

    ctx.globalAlpha = 0.5;

    ctx.fillStyle = "blue";
    ctx.fillRect(10, 10, 100, 100);

    ctx.fillStyle = "red";
    ctx.fillRect(50, 50, 100, 100);
}

module.exports = main;