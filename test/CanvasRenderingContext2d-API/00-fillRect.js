//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/fillRect

function main(canvas){
    var ctx = canvas.getContext('2d');
    ctx.fillStyle = "green";
    ctx.fillRect(10, 10, 100, 100);
    ctx.fillStyle = 'red';
    ctx.fillRect(10,10,50,50);
    ctx.fillStyle = 'black';
    ctx.fillRect(10,10,25,25);
    ctx.fillStyle = '#fff';
    ctx.fillRect(10,10,12.5,12.5);
    ctx.fillStyle = '#00ff00';
    ctx.fillRect(10,10,30,30);

}

module.exports = main;
