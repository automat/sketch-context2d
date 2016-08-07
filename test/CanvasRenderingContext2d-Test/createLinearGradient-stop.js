module.exports = function main(canvas){
    var width = canvas.width;
    var height = canvas.height;
    var ctx = canvas.getContext('2d');

    var numGradients = 8;
    var numColorStops = 8;

    var colorStep = 1.0 / (numColorStops - 1);
    var heightStep = height / numGradients;

    for(var i = 0; i < numGradients; ++i){
        var gradient = ctx.createLinearGradient(0,0,width / (i + 1), 0);
        for(var j = 0 ; j < numColorStops; ++j){
            var step = colorStep * j;
            var k = Math.floor(step * 255);
            var color = 'rgb(' + k + ',' + k + ',' + k + ')';
            gradient.addColorStop(step,color);
        }
        ctx.fillStyle = gradient;
        ctx.fillRect(0,heightStep * i,width,heightStep);
    }
};