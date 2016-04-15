//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/textAlign

function main(canvas){
    var ctx = canvas.getContext('2d');

    ctx.strokeStyle = 'green';
    ctx.beginPath();
    ctx.moveTo(100,0);
    ctx.lineTo(100,canvas.width);
    ctx.stroke();

    ctx.font = "48px sans-serif";
    var alignment = ['left','right','center','start','end'];

    for(var i = 0; i < alignment.length; ++i){
        ctx.textAlign = alignment[i];
        ctx.fillText("Hello World",100,100 + 40 * i);
    }
}

module.exports = main;
