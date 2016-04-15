//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/fillStyle

function main(canvas){
    var ctx = canvas.getContext('2d');

    for (var i=0;i<6;i++){
        for (var j=0;j<6;j++){
            ctx.fillStyle = 'rgb(' + Math.floor(255-42.5*i) + ',' +
                Math.floor(255-42.5*j) + ',0)';
            ctx.fillRect(j*25,i*25,25,25);
        }
    }
}

module.exports = main;
