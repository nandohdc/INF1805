var canvas;
var context;
var images = {};
var totalResources = 5;
var numResourcesLoaded = 0;
var fps = 30;
var charX = 0;
var charY = 0;

loadImage("background");
loadImage("character01");
loadImage("character02");
loadImage("character03");
loadImage("character04");

function loadImage(name){

	images[name] = new Image();
	images[name].onload = function(){
	canvas = document.getElementById("canvas");
		resourceLoaded();
	}

	images[name].src = "images/" + name + ".png";
}

function resourceLoaded(){
	numResourcesLoaded = numResourcesLoaded + 1;

	if(numResourcesLoaded === totalResources){
		setInterval(redraw, 100/fps);
	}
}

function redraw(){

	if(canvas.getContext){
		context = canvas.getContext("2d");
		var x = charX;
		var y = charY;
		var randomImage;

		canvas.width = canvas.width;

		context.drawImage(images["background"], x, y);
		if(array_NodeClients.length > 1 ){
			for(var index = 0; index < array_NodeClients.length; index++){
				randomImage = Math.random()*(3) + 1;
				context.drawImage(images["character01"], array_NodeClients[index].x, array_NodeClients[index].y);
			}
		}
	}
}