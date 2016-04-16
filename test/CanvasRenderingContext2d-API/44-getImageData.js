//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/getImageData

function main(canvas){
    var ctx = canvas.getContext("2d");

    ctx.rect(10, 10, 100, 100);
    ctx.fill();

    console.log(ctx.getImageData(100, 100));
}

module.exports = main;