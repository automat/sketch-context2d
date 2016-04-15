//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/createRadialGradient

function main(canvas){
    var ctx = canvas.getContext('2d');

    var gradient = ctx.createRadialGradient(100,100,100,100,100,0);
    gradient.addColorStop(0,"white");
    gradient.addColorStop(1,"green");
    ctx.fillStyle = gradient;
    ctx.fillRect(0,0,200,200);
}

module.exports = main;
