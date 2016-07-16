function normalize(value, start, end){
    return (value - start) / (end - start);
}

function main(canvas){
    var ctx = canvas.getContext('2d');

    ctx.save();
    ctx.translate(canvas.width * 0.5,canvas.height * 0.5);

    var logoWidth = 125;
    var logoHeight = 115;

    ctx.translate(-logoWidth * 0.5, -logoHeight * 0.5);

    ctx.strokeStyle = '#ff0000';
    //ctx.strokeRect(0,0,logoWidth,logoHeight);

    function lines(positions,segments){
        if(!segments){
            for(var i = 0; i < positions.length; i+=2){
                ctx[i === 0 ? 'moveTo' : 'lineTo'](positions[i],positions[i+1]);
            }
            return;
        }
    }
    function lineSegments(positions, segments){
        for(var i = 0; i < segments.length; i+=2){
            var x0 = positions[segments[i  ] * 2];
            var y0 = positions[segments[i  ] * 2 + 1];
            var x1 = positions[segments[i+1] * 2];
            var y1 = positions[segments[i+1] * 2 + 1];

            ctx.moveTo(x0,y0);
            ctx.lineTo(x1,y1);
        }
    }



    function points(positions,radius){
        for(var i = 0; i < positions.length; i+=2){
            ctx.moveTo(positions[i]+radius,positions[i+1]);
            ctx.arc(positions[i],positions[i+1],radius,0,Math.PI * 2);
        }
    }

    ctx.strokeStyle = '#00ff00';
    var positions  = [40,0, 85,0, 107,10, 125,31, 62.5,114, 0,31, 18,10,
                      39,19, 86,19, 23,50, 102,50];
    var segments = [0,1, 1,2, 2,3, 3,4, 4,5, 5,6, 6,0, 6,7, 7,8, 8,2, 5,9, 9,10, 10,3, 7,9, 8,10, 9,4, 10,4];
    //
    //var min = Number.MAX_VALUE;
    //var max = -Number.MAX_VALUE;
    //
    //for(var i = 0; i < positions.length; ++i){
    //    min = Math.min(positions[i],min);
    //    max = Math.max(positions[i],max);
    //}
    //
    //for(var i = 0; i < positions.length; ++i){
    //    positions[i] = normalize(positions[i],min,max);
    //}


    ctx.lineCap = 'round';
    ctx.lineWidth = 2;
    //ctx.beginPath();
    ctx.strokeStyle = '#ff0000';
    //for(var i = 0; i < 3000; ++i){
    //    ctx.save();
    //    ctx.translate(Math.random() * canvas.width, Math.random() * canvas.height);
    //    var scale = 1 + Math.random();
    //    //ctx.scale(scale,scale);
    //    lineSegments(positions,segments);
    //    ctx.restore();
    //}

    ctx.save();


    ctx.lineWidth = 4;
    ctx.beginPath();
    lineSegments(positions,segments);
    ctx.stroke();
    ctx.lineWidth = 2;
    ctx.strokeStyle = '#fff';
    ctx.stroke();

    ctx.setLineDash([3,3]);

    ctx.fillStyle = '#0000ff';
    ctx.beginPath();
    points(positions,2.5);
    ctx.closePath();
    ctx.fill();

    ctx.font = '10px TrioGrotesk-Medium';

    ctx.strokeStyle = '#0000ff';
    ctx.lineWidth = 1.0;


    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillStyle = '#0000ff';

    for(var i = 0; i < positions.length; i+=2){
        var x = positions[i  ];
        var y = positions[i+1];
        var dx = x - logoWidth * 0.5;
        var dy = y - logoHeight * 0.5;
        var d  = Math.sqrt(dx * dx + dy * dy);
        dx /= d;
        dy /= d;
        ctx.beginPath();
        ctx.moveTo(x,y);
        ctx.lineTo(x + dx * 80, y + dy * 80);
        ctx.stroke();

        ctx.fillText(''+i/2,x + dx * 90, y + dy * 90);
    }


    ctx.restore();

    //ctx.stroke();
    ctx.restore();
}

module.exports = main;