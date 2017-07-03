local m = mqtt.Client(nodemcu.ID, 120)
gpio.mode(7,gpio.OUTPUT)
gpio.mode(8,gpio.INT)

time_start = 0
time_end = 0

led_livre = LED(6)
led_ocupado = LED(3)
led_livre.inicia()
led_ocupado.inicia()

TEMP = string.format("%2.1f", adc.read(0)*(3.3/10.24))

timer = tmr.create()
atimer = tmr.create()
count = 0
avg = {}
local function readtemp()
  lasttemp = adc.read(0)*(3.3/10.24)
end

function sndConnect(c)
    return{
      message = function()
              print("publicando..")
              nodemcu.ID = wifi.sta.getip()
              c:publish("connect", nodemcu.ID,0,0, 
                function(c) print("ip enviado") end)
            end
    }
end
------------------------------------------------------------------
function trig_cb1(c)
    gpio.trig(8,"down",function() trig_cb2(c) end)
    time_start= tmr.now()
end
function trig_cb2(c)
    gpio.trig(8,"up",function() trig_cb1(c) end)
    time_end = tmr.now()
    local us = time_end - time_start
	local distance = us/58
    table.insert(avg,distance)
end
function pulse (c)
    count = count + 1
    if(count > 10) then
        timer:stop()
        local sum = 0
        for i,v in ipairs(avg) do
           sum = sum + v
        end
        sum = sum/table.getn(avg)
        led_ocupado.desliga()
        led_livre.desliga()
        if(sum > 1000) then
              nodemcu.Status = "occupied"
              led_ocupado.liga()
        else
              nodemcu.Status = "free"
              led_livre.liga()
        end
        print("avg : "..sum)
        c:publish("infos",nodemcu.ID.." "..nodemcu.Status.." "..TEMP,0,0,function() print("sent from alarm")  end)
        return
    end
    gpio.write(7,gpio.LOW)
    tmr.delay(2)
    gpio.write(7,gpio.HIGH)
    tmr.delay(10)
    gpio.write(7,gpio.LOW)
    tmr.delay(2)
end
---------------------------------------------------------------------
function conectado (client)    
    local con = sndConnect(client)
    print("Conectado") 
    con.message()
    gpio.trig(8,"up", function() trig_cb1(client) end)
    timer:register(100,tmr.ALARM_AUTO,function() pulse(client) end)
    atimer:register(10000,tmr.ALARM_AUTO,function() avg = {} count = 0 timer:start() end)
    atimer:start()
end 
---------------------------------------------------------------


---------------------------------------------------------------
m:connect(nodemcu.MQTT_SERVER, 1883, 0,
           conectado,
function(client, reason) print("failed reason: "..reason) end)
