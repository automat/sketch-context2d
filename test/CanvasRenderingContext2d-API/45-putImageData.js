//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/putImageData

function main(canvas){
    var ctx = canvas.getContext("2d");

    ctx.rect(10, 10, 100, 100);
    ctx.fill();

    var imageData = ctx.getImageData(0,0,100,100);
    console.log(imageData.data);

    ctx.putImageData(imageData,150,0,50,50,25,25)
}

module.exports = main;