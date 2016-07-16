const data = require('./data/sketch-logo');
const segments = [0,1, 1,2, 2,3, 3,4, 4,5, 5,6, 6,0, 6,7, 7,8, 8,2, 5,9, 9,10, 10,3, 7,9, 8,10, 9,4, 10,4];

function main(canvas){
    var ctx = canvas.getContext('2d');

    var size = canvas.width * 0.5;

    var positions = new Array(data.length);
    for(var i = 0; i < positions.length; ++i){
        positions[i] = (data[i] - 0.5) * size;
    }

    function circle(x,y,radius){
        ctx.moveTo(x + radius,y);
        ctx.arc(x,y,radius, 0, Math.PI * 2);
    }

    ctx.save();
    ctx.translate(canvas.width * 0.5, canvas.height * 0.5);

    ctx.lineCap = 'round';
    ctx.strokeStyle = '#000';
    ctx.lineWidth = 14;
    ctx.beginPath();
    for(var i = 0; i < segments.length; i+=2){
        var s0 = segments[i  ] * 2;
        var s1 = segments[i+1] * 2;

        ctx.moveTo(positions[s0],positions[s0+1]);
        ctx.lineTo(positions[s1],positions[s1+1]);
    }
    ctx.stroke();
    ctx.strokeStyle = '#fff';
    ctx.lineWidth = 6;
    ctx.stroke();

    ctx.beginPath();
    for(var i = 0; i < data.length; i+=2){
        circle(positions[i],positions[i+1],6);
    }
    ctx.fill();


    ctx.restore();
}

module.exports = main;