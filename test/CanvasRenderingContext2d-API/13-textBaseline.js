//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/textBaseline

function main(canvas){
    var ctx = canvas.getContext('2d');

    ctx.strokeStyle = 'green';
    ctx.beginPath();
    ctx.moveTo(100,0);
    ctx.lineTo(100,canvas.width);
    ctx.stroke();

    ctx.font = "16px sans-serif";
    var alignment = ['top','hanging','middle','alphabetic','ideographic','bottom'];

    var text  = "Hello World";
    var width = ctx.measureText(text).width;

    for(var i = 0; i < alignment.length; ++i){
        ctx.textBaseline = alignment[i];
        ctx.fillText(text,10 + width * i,100);
    }
}

module.exports = main;
