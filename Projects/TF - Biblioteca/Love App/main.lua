tempDecorr = 0
mqtt_client = {}
nodemcu = {
    ID = "love",
    wificonfig = {
        --Colocar em SSID a rede desejada para conectar
        ssid = "Valinor",
        pwd = "bateria123",
        save = false
    },
    MQTT_SERVER = "192.168.43.35",
    PORT = 1883,

}


AvgTemp = 0
FreeSpaces = 0
OccupiedSpaces = 0
hotSpot  = {x = 0, y = 0, temp = 0 } 
coldSpot = {x = 0, y = 0, temp = 100 } 


Table = {}
tables = {}
table_points = {{x = 73, y = 324},{x = 74, y = 445},{x = 74, y =577},{x = 206, y = 445}, {x = 206, y = 577},{x = 342, y = 312}, {x = 341,y = 445},{x = 536, y = 577},{x = 668, y = 314}, {x = 668, y = 445}, {x = 668, y = 577}}

function ack(M,N)
    if M == 0 then return N + 1 end
    if N == 0 then return ack(M-1,1) end
    return ack(M-1,ack(M, N-1))
end

function splitString(newString,pattern)
    local splittedString = {}
    local ptt = string.upper(tostring(pattern))
     for i in string.gmatch(newString, "%"..ptt.."+") do
	table.insert(splittedString, i)
    end
    return splittedString
end

function callback(topic, payload)

	if(topic == "connect") then

		local k = math.random(#table_points)
		local pop = table.remove(table_points,k) -- pop a random guy from table
		
		--mqtt_client:publish("test", "pop.x = "..pop.x)
		--mqtt_client:publish("test", "pop.y = "..pop.y)

		if(pop == nil) then
			mqtt_client:publish("test", "we ran out of tables")
		end
		
		--mqtt_client:publish("test", "payload on connect = "..payload)
		tables[payload] = {ID = payload, Temp = nil, Status = "free", x = pop.x, y = pop.y}
		table.insert(Table, tables[payload]) 
	elseif(topic == "infos") then
		local split_space = splitString(payload,"S") -- 192.168.33.1 "free" 30.2
		local split_ip = splitString(split_space[1],"P") -- 192.168.33.1

		local plTmp = tonumber(split_space[3]) -- payload new temp
		local plId = split_space[1] -- payload ID
		local plStat = split_space[2] -- payload new status

		if(tables[plId] == nil) then
			mqtt_client:publish("test", "tables[ip] is nil")
		end
		local t = tables[plId]
		t.Status = plStat
		t.Temp = plTmp
		--mqtt_client:publish("test", "table["..plId.."].Status = "..plStat)
		--mqtt_client:publish("test", "table["..plId.."].plTmp = "..plTmp)
		updateHotAndColdSpot(plTmp) -- n sei se funciona ainda
	end
	
	
	
end

function updateHotAndColdSpot(new_temp)
	
		if(new_temp > hotSpot.temp) then
			hotSpot.temp = plTmp
			hotspot.x = t.x
			hotspot.y = t.y
		end
		if(new_temp < coldSpot.temp) then
			coldSpot = plTmp
			coldSpot.temp = plTmp
			coldSpot.x = t.x
			coldSpot.y = t.y
		end
end

function newButton (bx,by,text)
  local _x,_y,_w,_h = bx, by, 120,50
  local direction = dir
  return {
    draw = function ()
      love.graphics.setColor(255, 255, 255)
      love.graphics.rectangle('line',_x,_y,_w,_h)
	  love.graphics.print(text,_x+10,_y+10)
      --love.graphics.setColor(255,255,255,255)
    end,
    x = _x,
    y = _y,
    w = _w,
    h = _h,
	active = false
  }
end

function love.load()

  love.window.setTitle("INF1805 - Felipe Vieira Côrtes e Fernando Homem da Costa")
  love.window.setMode(925, 700, {resizable=true, vsync=false, minwidth=400, minheight=300})
  img = {}
  img.background = love.graphics.newImage('/images/8195meu.png')
  table.insert(img,love.graphics.newImage('/images/8329(sitted4).png'))
  table.insert(img,love.graphics.newImage('/images/8329(sitted3).png'))
  table.insert(img,love.graphics.newImage('/images/8329(sitted2).png'))
  table.insert(img,love.graphics.newImage('/images/8329(sitted1).png'))

	-- connect procedure
	local MQTT = require("mqtt_library")
	mqtt_client = MQTT.client.create(nodemcu.MQTT_SERVER, nodemcu.PORT, callback) --(host,port,callback)
	mqtt_client:connect(nodemcu.ID)
	mqtt_client:subscribe({ "connect","infos" })

	-- new buttons here	
	hs_button = newButton(800,10,"Hot Spot")
	cs_button = newButton(800,75, "Cold Spot")
end

function love.draw()

  love.graphics.draw(img.background, 0, 0)
  -- Draws only the occupied tables
  for i,v in ipairs(Table) do
	if(v.Status == "occupied") then
		love.graphics.draw(img.s1, v.x, v.y)
	end
  end
	-- draw buttons
	cs_button.draw()
	hs_button.draw()
end

function love.update(dt)

	tempDecorr = tempDecorr + dt
	error_message = mqtt_client:handler() -- this needs to happen, don't remove
	
end
