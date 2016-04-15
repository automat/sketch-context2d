//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/stroke

function main(canvas){
    var ctx = canvas.getContext("2d");

    ctx.rect(10, 10, 100, 100);
    ctx.stroke();
}

module.exports = main;