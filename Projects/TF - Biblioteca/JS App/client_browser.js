var clientID = Math.floor((Math.random() * 10 ) + 1);
var hostname = 'mqtt://test.mosca.io';
var client = mqtt.connect(hostname);

var table_head = ["QTDA", "MINTEMP", "MAXTEMP", "AVGTEMP", "FD", "OD"];
table_head["QTDA"] = 0;
table_head["MINTEMP"] = 0;
table_head["MAXTEMP"] = 0;
table_head["AVGTEMP"] = 0;
table_head["FD"] = 0;
table_head["OD"] = 0;
var table_main=["id", "temp", "status"];

var array_NodeClients = [];

function insertTextTable(ID_TAG, info){
	var element = document.getElementById(ID_TAG);
	element.innerHTML = info;
	element.classList ? element.classList.add('text-center') : element.className += ' text-center';
}

function updateFreeDevices(){
	var tempFD = 0;

	for(var index = 0; index < array_NodeClients.length; index++){
		if(array_NodeClients[index]["status"] === "Free"){
			tempFD = tempFD + 1;
		}
	}
	table_head["FD"] = tempFD;
}

function updateOccupiedDevices(){
	var tempOD = 0;

	for(var index = 0; index < array_NodeClients.length; index++){
		if(array_NodeClients[index]["status"] === "Occupied"){
			tempOD = tempOD + 1;
		}
	}
	table_head["OD"] = tempOD;
}

function updateAvgTemp(){
	if(((table_head["MAXTEMP"] + table_head["MINTEMP"])/2) != table_head["AVGTEMP"]){
		table_head["AVGTEMP"] = ((table_head["MAXTEMP"] + table_head["MINTEMP"])/2);
	}
}

function updateMinTemp(){
	var tempMinTemp = 100;

	for(var index = 0; index < array_NodeClients.length; index++){
		if(tempMinTemp > array_NodeClients[index]["temp"]){
			tempMinTemp = array_NodeClients[index]["temp"];
		}
	}

	table_head["MINTEMP"] = tempMinTemp;
}

function updateMaxTemp(){
	var tempMaxTemp = 0;

	for(var index = 0; index < array_NodeClients.length; index++){
		if(tempMaxTemp < array_NodeClients[index]["temp"]){
			tempMaxTemp = array_NodeClients[index]["temp"];
		}
	}

	table_head["MAXTEMP"] = tempMaxTemp;
}

function trataTopico(topic, message){
	console.log("Topico eh: " + topic);
	if(topic.toString() === "nandohdc/connect"){
		trataMensagemConnect(message.toString());
	} else if(topic.toString() === "nandohdc/infos"){
		trataMensagemInfos(message.toString());
	} else if(topic.toString() === "nandohdc/test"){

	} else{
		alert("MQTT - Tópico escolhido não está configurado!");
		window.close();
	}
}

function insertTableHead(table_name){
	if(table_name === "table_head"){
		insertTextTable("td_QTDA", table_head["QTDA"]);
		insertTextTable("td_MINTEMP", table_head["MINTEMP"]);
		insertTextTable("td_MAXTEMP", table_head["MAXTEMP"]);
		insertTextTable("td_AVGTEMP", table_head["AVGTEMP"]);
		insertTextTable("td_FD", table_head["FD"]);
		insertTextTable("td_OD", table_head["OD"]);
	}
}

function insertTableMain(table_name, index_of_array_node_clients){
 if(table_name === "table_main"){
		var element = document.getElementById("table_main_body");
		if(element.rows.length < 1){	
			var newRow = element.insertRow(element.rows.length);
			newRow.id = "id_" + array_NodeClients[index_of_array_node_clients]["id"].toString(); 
			var cell01 = newRow.insertCell(0);
			var cell02 = newRow.insertCell(0);
			var cell03 = newRow.insertCell(0);
			cell03.innerHTML = array_NodeClients[index_of_array_node_clients]["id"];
			cell02.innerHTML = array_NodeClients[index_of_array_node_clients]["temp"];
			cell01.innerHTML = array_NodeClients[index_of_array_node_clients]["status"];
		} else if(element.rows.length != array_NodeClients.length){
			var newRow = element.insertRow(element.rows.length);
			newRow.id = "id_" + array_NodeClients[index_of_array_node_clients]["id"].toString(); 
			var cell01 = newRow.insertCell(0);
			var cell02 = newRow.insertCell(0);
			var cell03 = newRow.insertCell(0);
			cell03.innerHTML = array_NodeClients[index_of_array_node_clients]["id"];
			cell02.innerHTML = array_NodeClients[index_of_array_node_clients]["temp"];
			cell01.innerHTML = array_NodeClients[index_of_array_node_clients]["status"];
		} else if(element.rows.length == array_NodeClients.length){
			for(var index = 0; index < element.rows.length; index++){
				if(element.rows[index].id === "id_" + array_NodeClients[index_of_array_node_clients]["id"]){
					element.rows[index].cells.item(0).innerHTML = array_NodeClients[index_of_array_node_clients]["id"].toString();
					element.rows[index].cells.item(1).innerHTML = array_NodeClients[index_of_array_node_clients]["temp"].toString();
					element.rows[index].cells.item(2).innerHTML = array_NodeClients[index_of_array_node_clients]["status"].toString();
				}
			}
		} else{
			alert("Porra");
		}

	} else {
		alert("InsertTable: Tabela não existe!");
		window.close();
	}
}

function trataMensagemConnect(message){
	console.log("Mensgem eh: " + message);
	var nodeClient = ["id", "temp", "status"];
	nodeClient["id"] = message.toString(0);
	nodeClient["temp"] = "0";
	nodeClient["status"]= "INDISPONIVEL";
	if(array_NodeClients.length < 1){
		array_NodeClients.push(nodeClient);
		table_head["QTDA"] = array_NodeClients.length;
		insertTableHead("table_head");
	} else{
		array_NodeClients.push(nodeClient);
		console.log(array_NodeClients.length);
		table_head["QTDA"] = array_NodeClients.length;
		insertTableHead("table_head");
	}
}

function trataMensagemInfos(message){
	console.log("Mensgem eh: " + message);
	splittedMsg = message.split(" ");
	if(array_NodeClients.length == 0){
		alert("trataMensagemInfos: Tentou enviou infos antes de connect!");
		window.close();
	}
	for(var index = 0;  index < array_NodeClients.length; index++){
		if(array_NodeClients[index]["id"].toString() === splittedMsg[0].toString()){
			console.log(array_NodeClients[index]["id"].toString());
			console.log(splittedMsg[0].toString());
			array_NodeClients[index]["temp"] = splittedMsg[1].toString();
			array_NodeClients[index]["status"] = splittedMsg[2].toString();
			insertTableMain("table_main", index);
		} 
	}
	updateFreeDevices();
	updateOccupiedDevices();
	updateAvgTemp();
	updateMinTemp();
	updateMaxTemp();
	insertTableHead();
}

client.on('connect', function(){
	console.log("Client - ID: " + clientID + " conectado");
	client.subscribe('nandohdc/connect');
	client.subscribe('nandohdc/infos');
})

client.on('message', function (topic, message){
	var msg = message.toString();
	trataTopico(topic, message);
})