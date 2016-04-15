//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/rect

function main(canvas){
    var ctx = canvas.getContext("2d");

    ctx.rect(10, 10, 100, 100);
    ctx.fill();
}

module.exports = main;