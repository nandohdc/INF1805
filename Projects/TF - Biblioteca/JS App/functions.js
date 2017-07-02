/**
* Essa função receber dois parametros, ID_TAG e info. Insere o valor info no elemento em que o ID_TAG faz referencia do arquivo index.php.
* @method insertTextTable
* @param {String} ID_TAG
* @param {String} info 
* @return void
*/
function insertTextTable(ID_TAG, info){
	var element = document.getElementById(ID_TAG);
	element.innerHTML = info;
	element.classList ? element.classList.add('text-center') : element.className += ' text-center';
}

/**
* Essa função atualiza o numero total de dispositivos.
* E atribui o calculo uma variavel global (table_head)
* @method updateQTDA
* @param {String} - nElements
* @GLOBAL {Array} - table_head 
* @return void
*/

function updateQTDA(nElements){
	table_head["QTDA"] = array_NodeClients.length;

	if(nElements < 1){
		table_head["QTDA"] = 0;
		table_head["MINTEMP"] = 0;
		table_head["MAXTEMP"] = 0;
		table_head["AVGTEMP"] = 0;
		table_head["FD"] = 0;
		table_head["OD"] = 0;
	}

	insertTextTable("td_QTDA", table_head["QTDA"]);
}

/**
* Essa função calcula/atualiza o numero de dispositivos em uso.
* E atribui o calculo uma variavel global (table_head)
* @method updateOccupiedDevices
* @GLOBAL {Array{Array}}  - array_NodeClients
* @GLOBAL {Array} - table_head 
* @return void
*/
function updateOccupiedDevices(){
	var tempOD = 0;

	for(var index = 0; index < array_NodeClients.length; index++){
		if(array_NodeClients[index]["status"].toString() === "occupied"){
			tempOD = tempOD + 1;
		}
	}
	table_head["OD"] = tempOD;
	insertTextTable("td_OD", table_head["OD"]);
}

/**
* Essa função calcula/atualiza o numero de dispositivos em livres.
* E atribui o calculo uma variavel global (table_head)
* @method updateFreeDevices
* @GLOBAL {Array} - table_head 
* @return void
*/
function updateFreeDevices(){
	var tempFD = 0;

	tempFD = table_head["QTDA"] - table_head["OD"];

	table_head["FD"] = tempFD;

	insertTextTable("td_FD", table_head["FD"]);
}

/**
* Essa função procura no array de arrays(array_NodeClients) e atualiza menor temperatura em outro array (table_head).
* E atribui o valor a uma variavel global (table_head)
* @method updateMinTemp
* @GLOBAL {Array{Array}}  - array_NodeClients
* @GLOBAL {Array} - table_head 
* @return void
*/
function updateMinTemp(){
	var tempMinTemp = 100;

	for(var index = 0; index < array_NodeClients.length; index++){
		if(tempMinTemp > array_NodeClients[index]["temp"]){
			tempMinTemp = array_NodeClients[index]["temp"];
		}
	}

	table_head["MINTEMP"] = tempMinTemp;
	insertTextTable("td_MINTEMP", table_head["MINTEMP"]);
}

/**
* Essa função procura no array de arrays(array_NodeClients) e atualiza maior temperatura em outro array (table_head).
* E atribui o valor a uma variavel global (table_head)
* @method updateMaxTemp
* @GLOBAL {Array{Array}}  - array_NodeClients
* @GLOBAL {Array} - table_head 
* @return void
*/
function updateMaxTemp(){
	var tempMaxTemp = 0;

	for(var index = 0; index < array_NodeClients.length; index++){
		if(tempMaxTemp < array_NodeClients[index]["temp"]){
			tempMaxTemp = array_NodeClients[index]["temp"];
		}
	}

	table_head["MAXTEMP"] = tempMaxTemp;
	insertTextTable("td_MAXTEMP", table_head["MAXTEMP"]);
}

/**
* Essa função calcula e atualiza temperatura media.
* E atribui o valor a uma variavel global (table_head)
* @method updateAvgTemp
* @GLOBAL {Array} - table_head 
* @return void
*/
function updateAvgTemp(){
	var tempAvgTemp = 0;
	if(((table_head["MAXTEMP"] + table_head["MINTEMP"])/2) != table_head["AVGTEMP"]){
		tempAvgTemp = ((parseFloat(table_head["MAXTEMP"]) + parseFloat(table_head["MINTEMP"]))/2);
		table_head["AVGTEMP"] = tempAvgTemp;
		insertTextTable("td_AVGTEMP", table_head["AVGTEMP"]);
	}
}


function insertTableMain(table_name, index_of_array_node_clients){
 if(table_name === "table_main"){
		var element = document.getElementById("table_main_body");
		if(element.rows.length < 1 || element.rows.length != array_NodeClients.length){	
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
			alert("Error: insert_Table_Main - Array_NodeClients ");
		}

	} else {
		alert("InsertTable: Tabela não existe!");
		window.close();
	}
}

function updateTableHead(){
	updateQTDA();
	updateOccupiedDevices();
	updateFreeDevices();
	updateMinTemp();
	updateMaxTemp();
	updateAvgTemp();

}

/**
* Essa função receber dois parametros, topic e message.
* A função avalia se o topic recebido é válido, caso seja, chamará a função que cuidadará daquele topic.
* @method trataTopico
* @param {Object} - topic
* @param {Object} - message 
* @return void
*/
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

function trataMensagemConnect(message){
	console.log("Mensgem eh: " + message);
	var nodeClient = ["id", "temp", "status", "posX", "posY"];
	
	nodeClient["id"] = message.toString(0);
	nodeClient["temp"] = "0";
	nodeClient["status"]= "free";
	
	if(array_NodeClients.length < 1){
		nodeClient["posX"] = table_points[0].x;
		nodeClient["posY"] = table_points[0].y;
	} else{
		nodeClient["posX"] = table_points[array_NodeClients.length].x;
		nodeClient["posY"] = table_points[array_NodeClients.length].y;
	}
	
	array_NodeClients.push(nodeClient);
	updateTableHead(array_NodeClients.length);
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
			array_NodeClients[index]["status"] = splittedMsg[1].toString();
			array_NodeClients[index]["temp"] = splittedMsg[2].toString();
			insertTableMain("table_main", index);
		} 
	}

	updateTableHead();
}