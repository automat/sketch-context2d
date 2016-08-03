//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/stroke

function main(canvas){
    var ctx = canvas.getContext("2d");

    // Create clipping region
    ctx.arc(100, 100, 75, 0, Math.PI*2);
    //TODO: Clip without fill
    ctx.fillStyle = 'rgba(0,0,0,0)';
    ctx.fill();
    ctx.clip();

    ctx.fillStyle = '#fff000';
    ctx.fillRect(0, 0, 100,100);
}

module.exports = main;