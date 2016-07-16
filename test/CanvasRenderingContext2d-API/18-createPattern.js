//https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/createPattern

const PATH_IMAGE = 'assets/test-image.png';

function main(canvas){
    var img = new Image();
    function draw(){
        var ctx = canvas.getContext('2d');

        ctx.drawImage(img,0,0);
    }

    if(sketch){
        img.src = __dirnamePlugin + '/' + PATH_IMAGE;
        draw();
    } else {
        img.onload = draw;
        img.src = './' + PATH_IMAGE;
    }
}

module.exports = main;

