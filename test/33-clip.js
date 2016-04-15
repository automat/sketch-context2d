//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/stroke

function main(canvas){
    var ctx = canvas.getContext("2d");

    ctx.beginPath(); //skip
    // Create clipping region
    ctx.arc(100, 100, 75, 0, Math.PI*2);
    ctx.fill();
    ctx.clip();

    ctx.fillRect(0, 0, 100,100);
}

module.exports = main;