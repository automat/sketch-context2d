//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/createImageData//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/globalCompositeOperation

function main(canvas){
    var ctx = canvas.getContext("2d");

    ctx.rect(10, 10, 100, 100);
    ctx.fill();

    console.log(ctx.createImageData(100, 100));
}

module.exports = main;