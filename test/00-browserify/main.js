var a = require('./module');

module.exports = function(canvas){
    console.log('test');
    console.log(canvas.width);
    var ctx = canvas.getContext('2d');

    ctx.fillStyle = 'rgb(15,15,15)';
    ctx.fillRect(0,0,canvas.width,canvas.height);

    var l = 7500;
    for(var i = 0; i < l; ++i){
        var n = i / l;
        var a = Math.PI * 0.125 + n * Math.PI * 1.75;
        var d = Math.random() * 200;
        var x = canvas.width * 0.5 + Math.cos(a) * d;
        var y = canvas.height * 0.5 + Math.sin(a) * d;
        var r = Math.random() * 4.5;
        var c = Math.floor(Math.random() * 255);

        ctx.fillStyle = 'rgb(' + c + ',' + c + ',' + c + ')';
        ctx.beginPath();
        ctx.arc(x,y,r,0,2*Math.PI);
        ctx.fill();
    }
};