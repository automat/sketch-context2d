//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/textAlign

function main(canvas){
    var ctx = canvas.getContext('2d');
    var width = canvas.width;

    ctx.strokeStyle = 'green';
    ctx.beginPath();
    ctx.moveTo(width * 0.5,0);
    ctx.lineTo(width * 0.5,canvas.width);
    ctx.stroke();

    ctx.font = "48px sans-serif";
    var alignment = ['left','right','center','start','end'];

    for(var i = 0; i < alignment.length; ++i){
        ctx.textAlign = alignment[i];
        ctx.fillText("Hello World",width * 0.5,100 + 40 * i);
    }
}

module.exports = main;
