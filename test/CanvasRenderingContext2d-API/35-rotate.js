//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/rotate

function main(canvas){
    var ctx = canvas.getContext("2d");

    ctx.rotate(45 * Math.PI / 180);
    ctx.fillRect(70,0,100,30);

    // reset current transformation matrix to the identity matrix
    ctx.setTransform(1, 0, 0, 1, 0, 0);

    ctx.strokeStyle = '#00ff00';
    ctx.strokeRect(0,0,100,100);
}

module.exports = main;