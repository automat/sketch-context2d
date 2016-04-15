//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/createLinearGradient

function main(canvas){
    var ctx = canvas.getContext('2d');

    var gradient = ctx.createLinearGradient(0,0,200,0);
    gradient.addColorStop(0,"green");
    gradient.addColorStop(1,"white");
    ctx.fillStyle = gradient;
    ctx.fillRect(10,10,200,100);
}

module.exports = main;
