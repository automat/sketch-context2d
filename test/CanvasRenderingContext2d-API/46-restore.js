//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/restore

function main(canvas){
    var ctx = canvas.getContext("2d");

    ctx.save(); // save the default state

    ctx.fillStyle = "green";
    ctx.fillRect(10, 10, 100, 100);

    ctx.restore(); // restore to the default state
    ctx.fillRect(150, 75, 100, 100);
}

module.exports = main;