//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/quadraticCurveTo

function main(canvas){
    var ctx = canvas.getContext('2d');

    ctx.beginPath();
    ctx.moveTo(50,20);
    ctx.quadraticCurveTo(230, 30, 50, 100);
    ctx.stroke();

    ctx.fillStyle = 'blue';
    // start point
    ctx.fillRect(50, 20, 10, 10);
    // end point
    ctx.fillRect(50, 100, 10, 10);

    ctx.fillStyle = 'red';
    // control point
    ctx.fillRect(230, 30, 10, 10);
}

module.exports = main;