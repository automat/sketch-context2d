//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/shadowColor

function main(canvas){
    var ctx = canvas.getContext('2d');

    ctx.shadowColor = "black";
    ctx.shadowOffsetY = 10;
    ctx.shadowOffsetX = 10;

    ctx.fillStyle = "green";
    ctx.fillRect(10, 10, 100, 100);
}

module.exports = main;
