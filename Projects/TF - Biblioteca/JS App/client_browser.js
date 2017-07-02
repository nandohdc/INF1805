var table_points = [{x : 73, y : 324},{x : 74, y : 445},{x : 74, y :577},{x : 206, y : 445}, {x : 206, y : 577},{x : 342, y : 312}, {x : 341,y : 445},{x : 536, y : 577},{x : 668, y : 314}, {x : 668, y : 445}, {x : 668, y : 577}];
var table_head = ["QTDA", "MINTEMP", "MAXTEMP", "AVGTEMP", "FD", "OD"];
table_head["QTDA"] = 0;
table_head["MINTEMP"] = 0;
table_head["MAXTEMP"] = 0;
table_head["AVGTEMP"] = 0;
table_head["FD"] = 0;
table_head["OD"] = 0;
var table_main=["id", "temp", "status", "posX", "posY"];

var array_NodeClients = [];

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

var clientID = Math.floor((Math.random() * 10 ) + 1);
var hostname = 'mqtt://test.mosca.io';
var client = mqtt.connect(hostname);

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
		client.on('message', function (topic, message){
			var msg = message.toString();
			trataTopico(topic, message);
			redraw();
		})
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
		for(var index = 0;  index < array_NodeClients.length; index++){
			if(array_NodeClients[index].status.toString() === "occupied"){
				randomImage = Math.floor(Math.random()*(3) + 1);
				context.drawImage(images["character0"+randomImage.toString()], array_NodeClients[index].posX, array_NodeClients[index].posY);
			}
		}
	}
}


client.on('connect', function(){
	console.log("Client - ID: " + clientID + " conectado");
				
	client.subscribe('nandohdc/connect');
				
	client.subscribe('nandohdc/infos');
})
