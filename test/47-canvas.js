//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/canvas

function main(canvas){
    var ctx = canvas.getContext("2d");

    console.log(ctx.canvas); //ATSketchCanvas reference {width,height}
}

module.exports = main;