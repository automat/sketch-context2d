//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/fillRect

function main(canvas){
    var ctx = canvas.getContext('2d');
    ctx.fillStyle = "green";
    ctx.fillRect(10, 10, 100, 100);
}

module.exports = main;
