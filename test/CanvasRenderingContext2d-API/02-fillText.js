//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/fillText

function main(canvas){
    var ctx = canvas.getContext('2d');
    ctx.font = "48px sans-serif";

    ctx.fillText("Hello world", 50, 100);
    ctx.font = "48px serif";
    ctx.fillText("Hello world", 50, 150);
    ctx.font = "48px monospace";
    ctx.fillText("Hello world", 50, 200);
}

module.exports = main;
