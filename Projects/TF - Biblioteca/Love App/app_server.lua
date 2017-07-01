srv = net.createServer(net.TCP, 30)
local m = mqtt.Client("clientid1", 120)

client_table = {}
list_Clients = {}

AvgTemp = 0
FreeSpaces = 0
OccupiedSpaces = 0

hotSpot = 0
coldSpot = 0
vals = {
    QtdDevices = 0,
    MinTemp = 100,
    MaxTemp = 0,
    AvgTemp = 0,
    FreeDevices = 0,
    OccupiedDevices = 0,
  }

function updateStatus()
    local freesum, occsum = 0,0
    local tmpS
    for i in pairs(client_table) do
        tmpS = client_table[i].Status
        if(tmpS == "occupied") then
            occsum = occsum + 1
        elseif(tmpS == "free") then
            freesum = freesum + 1
        else
            print("UPDATE ERROR: Not free nor occupied")
        end
    end
    vals.FreeDevices = freesum
    vals.OccupiedDevices = occsum
end
function updateMaxMinTemp()
local mintemp = 9999
local maxtemp = 0
local avgtemp = 0
local c = 0
local temp = 0
    for i in pairs(client_table) do
        c = c + 1
        temp = tonumber(client_table[i].Temp)
        if (temp < mintemp) then
            mintemp = temp
            coldSpot = client_table[i].ID
        end
        if(temp > maxtemp) then
            maxtemp = temp
            hotSpot = client_table[i].ID
        end
        avgtemp = avgtemp + temp
     
    end
    if c ~= 0 then
        vals.AvgTemp = avgtemp/c
    end
    vals.MinTemp = mintemp
    vals.MaxTemp = maxtemp
end

function splitString(newString)
    -- IP(xxx.xxx.xxx.xxx)-STATUS -TEMP
     splittedString = {}
     for i in string.gmatch(newString, "%S+") do
       table.insert(splittedString, i)
    end
    return splittedString
end

msgsConnect = 0
msgsInfos = 0
  
function trataTopico(c, t, m)
    print("topico : "..t)
    if(t == "connect") then
       print ("mensagem ".. msgsConnect .. ", topico: ".. t .. ", dados: " .. m)
       list_Clients[m] = {ID= m, Temp= nil, Status= nil}
       table.insert(client_table, list_Clients[m])
       msgsConnect = msgsConnect + 1
       vals.QtdDevices = msgsConnect
    elseif(t == "infos") then
       print ("mensagem ".. msgsInfos .. ", topico: ".. t .. ", dados: " .. m)
       local split = splitString(m)
       list_Clients[split[1]].Status = split[2]
       list_Clients[split[1]].Temp = split[3]
       updateMaxMinTemp()
       updateStatus()
       msgsInfos = msgsInfos + 1
    elseif(t == "disconnect") then
        print ("mensagem ".. msgsInfos .. ", topico: ".. t .. ", dados: " .. m)
        for i in pairs(client_table) do
            local id = client_table[i].ID
            if (id == m) then
                table.remove(client_table, i)
                print("Node '"..id.."' removed from client_table")
                print("new size : "..#client_table)
                updateMaxMinTemp()
                updateStatus()
                vals.QtdDevices = vals.QtdDevices - 1
            end
        end
    elseif(t == "commands") then
        if(m == "list ip") then
            for i in pairs(client_table) do
                print("> "..client_table[i].ID)
            end
        elseif(m == "list free") then
            for i in pairs(client_table) do
                if(client_table[i].Status == "free") then    
                    print("> "..client_table[i].ID)
                end
            end
        elseif(m == "list occ") then
            for i in pairs(client_table) do
                if(client_table[i].Status == "occupied") then 
                    print("> "..client_table[i].ID)
                end
            end
        elseif(m == "hot spot") then
            print("> "..hotSpot)
        elseif(m == "cold spot") then
            print("> "..coldSpot)
        else
            print("Command '"..m.."' not recognized")
        end
    end
end


function inscreve(c)
    return{
      Inscricao = function()
                       c:on("message", trataTopico)
                  end   
    }
end

function recebeInfos(c)
    c:subscribe("infos", 0, Inscricao)
    c:subscribe("commands", 0, Inscricao)
    
end

function recebeConexao(c)
    c:subscribe("connect", 0, Inscricao)
    c:subscribe("disconnect", 0, Inscricao)
end

function receiver(sck, request)
local buf = [[
<!DOCTYPE html>
<html lang="pt-br">
<head>
<meta charset="utf-8">
<meta http-equiv="Cache-control" content="no-cache">
<meta name="description" content="INF1805 - Sistemas Reativos">
<meta name="keywords" content="React systems, Computer Engineering, INF1805">
<meta name="author" content="Felipe Vieira Côrtes e Fernando Homem da Costa">
<meta http-equiv="X-UA-Compatible" content="IE=edge">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>INF1805 - Project 3</title>
<!-- Latest compiled and minified CSS -->
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
</head>
<body>
  <div class="container-fluid">
    <div class="row">
      <h1 class="text-center">INF1805 - Projeto NodeMCU</h1>
      <h2 class="text-center">Biblioteca</h2>
    </div>
  </div>
  <hr style="height: 1px; background-color: black;">
  <div class="container">
    <div class="row">
        <table class="table" style = "margin-top: 10%">
          <thead>
            <tr>
              <th>Quantidade de Dispositivos Ativos: </th>
              <th>Menor Temperatura (C): </th>
              <th>Maior Temperatura (C): </th>
              <th>Temperatura Media(C): </th>
              <th>Dispositivos Livres: </th>
              <th>Dispositivos Ocupados: </th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>$QtdDevices</td>
              <td>$MinTemp</td>
              <td>$MaxTemp</td>
              <td>$AvgTemp</td>
              <td>$FreeDevices</td>
              <td>$OccupiedDevices</td>
            </tr>
          </tbody>
        </table>
    </div>
  </div>
  <hr style="margin-top: 20%; height: 1px; background-color: black;">
  <div class="row">
    <div class="text-center">
      <div class="row" id="contact-me">
        <h4><strong>Authors</strong></h4>
        <div class="row">
          <p class="text-center">Felipe Vieira Cortes and Fernando Homem da Costa</p>
          <p class="text-center"><a href="https://github.com/nandohdc/INF1805/tree/master/Projects/T3%20-%20NodeMCU">GitHub</a></p>
        </div>
      </div>
    </div>
  </div>
  <hr>
</body>
</html>
]]
  buf = string.gsub(buf, "$(%w+)", vals)
  sck:send(buf, function() print("respondeu") sck:close() end)
end

if srv then
nodemcu.ID = wifi.sta.getip()
  srv:listen(80,nodemcu.ID, function(conn)
      print("estabeleceu conexÃ£o")
      conn:on("receive", receiver)
    end)
end

function conectado (client)
    local inscrito = inscreve(client)
    print("Conectado")
    inscrito.Inscricao()
    recebeConexao(client)
    recebeInfos(client)
end 

m:connect(nodemcu.MQTT_SERVER, 1883, 0,
             conectado,
function(client, reason) print("failed reason: "..reason) end)

addr, port = srv:getaddr()
print(addr, port)
print("servidor inicializado.")
