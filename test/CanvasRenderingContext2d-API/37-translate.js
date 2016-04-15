//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/translate

function main(canvas){
    var ctx = canvas.getContext("2d");

    ctx.translate(50, 50);
    ctx.fillRect(0,0,100,100);

    // reset current transformation matrix to the identity matrix
    ctx.setTransform(1, 0, 0, 1, 0, 0);

    ctx.strokeStyle = '#00ff00';
    ctx.strokeRect(0,0,100,100);
}

module.exports = main;