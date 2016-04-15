//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/shadowBlur

function main(canvas){
    var ctx = canvas.getContext('2d');

    ctx.shadowColor = "black";
    ctx.shadowBlur = 10;

    ctx.fillStyle = "white";
    ctx.fillRect(10, 10, 100, 100);
}

module.exports = main;
