local m = mqtt.Client("clientid99", 120)
timer = tmr.create()
sw1 = 1
sw2 = 2
--gpio.mode(sw1, gpio.INPUT)
--gpio.mode(sw2, gpio.INPUT)
TEMP = string.format("%2.1f",adc.read(0)*(3.3/10.24))

function publica(c)
  c:publish("alos","alo do nodemcu! Felipe&Fernando",0,0, 
            function(client) print("mandou!") end)
end
function publicaTemp(c)
    print("publicando..")
    c:publish("temperatura","F&F : "..TEMP,0,0, 
            function(client) print("mandei temp!") end)
end

function recebeControle(c)
    c:subscribe("controle",0,novaInscricao2)
end
local function readtemp()
  lasttemp = adc.read(0)*(3.3/10.24)
end

function novaInscricao (c)
  local msgsrec = 0
  function novamsg (c, t, m)
    print ("mensagem ".. msgsrec .. ", topico: ".. t .. ", dados: " .. m)
    msgsrec = msgsrec + 1
  end
  c:on("message", novamsg)
end

function novaInscricao2 (c)
  local msgsrec = 0
  function novamsg (c, t, m)
    print ("mensagem ".. msgsrec .. ", topico: ".. t .. ", dados: " .. m)
    timer:unregister()
    timer:register(tonumber(m)*1000, tmr.ALARM_AUTO, function() publicaTemp(c) end)
    timer:start()
    msgsrec = msgsrec + 1
  end
  c:on("message", novamsg)
end
function conectado (client)
  --publica(client)
  --publicaTemp(client)
 -- timer:register(5000, tmr.ALARM_AUTO, function() publicaTemp(client) end)
 -- timer:start()
  --client:subscribe("alos", 0, novaInscricao)
  --recebeControle(client)
--  local pin, pulse1, du, now, trig = 1, 0, 0, tmr.now, gpio.trig
 --- gpio.mode(sw1,gpio.INT)
 -- local function pin1cb(level, pulse2)
   -- print( level, pulse2 - pulse1 )
   -- pulse1 = pulse2
   -- trig(sw1, level == gpio.HIGH  and "down" or "up")
   -- publicaTemp(client)
 -- end
 -- trig(sw1, "down", pin1cb)
  gpio.trig(sw1,"down",function() publicaTemp(client) end)
end 

m:connect("192.168.43.136", 1883, 0, 
             conectado,
             function(client, reason) print("failed reason: "..reason) end)