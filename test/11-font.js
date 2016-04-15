//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/font

function main(canvas){
    var ctx = canvas.getContext('2d');

    ctx.font = "48px serif";
    ctx.strokeText("Hello world", 50, 100);
}

module.exports = main;
