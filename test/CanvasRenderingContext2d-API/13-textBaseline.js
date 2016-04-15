//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/textBaseline

function main(canvas){
    var ctx = canvas.getContext('2d');

    ctx.strokeStyle = 'green';
    ctx.beginPath();
    ctx.moveTo(0,100);
    ctx.lineTo(canvas.width,100);
    ctx.stroke();

    ctx.font = "20px serif";
    var alignment = ['top','hanging','middle','alphabetic','ideographic','bottom'];

    var offset = 10;
    for(var i = 0; i < alignment.length; ++i){
        var align = alignment[i];
        var width = ctx.measureText(align).width;

        ctx.textBaseline = align;
        ctx.fillText(align,offset,100);

        offset += width + 20;
    }
}

module.exports = main;
