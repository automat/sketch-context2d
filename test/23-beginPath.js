//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/beginPath

function main(canvas){
    var ctx = canvas.getContext('2d');

    // First path
    ctx.beginPath();
    ctx.strokeStyle = 'blue';
    ctx.moveTo(20,20);
    ctx.lineTo(200,20);
    ctx.stroke();

    // Second path
    ctx.beginPath();
    ctx.strokeStyle = 'green';
    ctx.moveTo(20,20);
    ctx.lineTo(120,120);
    ctx.stroke();
}

module.exports = main;