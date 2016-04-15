//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/scale

function main(canvas){
    var ctx = canvas.getContext("2d");

    ctx.scale(10, 3);
    ctx.fillRect(10,10,10,10);

    // reset current transformation matrix to the identity matrix
    ctx.setTransform(1, 0, 0, 1, 0, 0);

    ctx.strokeStyle = '#00ff00';
    ctx.strokeRect(0,0,100,100);
}

module.exports = main;