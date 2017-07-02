local m = mqtt.Client(nodemcu.ID, 120)
local deb_old,deb_new = 0,0;
local button1, button2 = 1,2
gpio.mode(button1,gpio.INT,gpio.PULLUP)
gpio.mode(button2,gpio.INT,gpio.PULLUP)
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

function publica(c)
    return{
      message = function()
              print("publicando..")
              nodemcu.ID = wifi.sta.getmac()
              c:publish("nandohdc/connect", nodemcu.ID,0,0, 
                function(c) print("ip enviado") end)
            end
    }
end

function inscreve(c)

    return{
      novaInscricao = function()
                            local msgsrec = 0
                            function novamsg (c, t, m)
                              print ("mensagem ".. msgsrec .. ", topico: ".. t .. ", dados: " .. m)
                                    msgsrec = msgsrec + 1
                            end
                            c:on("message", novamsg)
                        end  
    }
end

function recebeControle(c)
    c:subscribe("test/topic",0,novaInscricao)
    --c:subscribe("connect",0,function() print("recebi um connect") end)
   -- c:subscribe("infos",0,novaInscricao)
    
end

function reageBotao(pin,c)
        led_livre.desliga()
        led_ocupado.desliga()
       -- readtemp()
        print("reacting...")
       if(pin == button1) then
            c:publish("nandohdc/infos",nodemcu.ID.." occupied "..TEMP,0,0, 
                function(c) print("done") end)
            led_ocupado.liga()
            nodemcu.Status = "occupied"
       else
            c:publish("nandohdc/infos",nodemcu.ID.." free "..TEMP,0,0, 
                function(c) print("done") end)
            led_livre.liga()
            nodemcu.Status = "free"
       end
end
------------------------------------------------------------------
function trig_cb1(c)
    gpio.trig(8,"down",function() trig_cb2(c) end)
   -- print("call back 1")
    time_start= tmr.now()
end
function trig_cb2(c)
    gpio.trig(8,"up",function() trig_cb1(c) end)
  --  print("callback 2")
    time_end = tmr.now()
    local us = time_end - time_start
	local distance = us/58
   -- print("gap : "..us)
   -- print("distance(cm) : "..distance)

    table.insert(avg,distance)
	--c:publish("infos",nodemcu.ID.." "..nodemcu.Status.." "..TEMP,0,0,function() print("sent from alarm")  end)

end
function pulse (c)
   -- print("pusling")
    --time_start = tmr.now()
    count = count + 1
    if(count > 10) then
        timer:stop()
        local sum = 0
        for i,v in ipairs(avg) do
           sum = sum + v
        end
        sum = sum/table.getn(avg)
        if(sum > 1000) then
              nodemcu.Status = "occupied"
        else
              nodemcu.Status = "free"
        end
        print("avg : "..sum)
        c:publish("nandohdc/infos",nodemcu.ID.." "..nodemcu.Status.." "..TEMP,0,0,function() print("sent from alarm")  end)
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
    local envia = publica(client)
    local inscrito = inscreve(client)
    print("Conectado")
    inscrito.novaInscricao()
    recebeControle(client)   
    envia.message()
    gpio.trig(8,"up", function() trig_cb1(client) end)
    timer:register(100,tmr.ALARM_AUTO,function() pulse(client) end)
    atimer:register(15000,tmr.ALARM_AUTO,function() avg = {} count = 0 timer:start() end)
    atimer:start()
    gpio.trig(button1,"down", function () reageBotao(button1,client) end)
    gpio.trig(button2,"down", function () reageBotao(button2,client) end)
end 

    --timer:register(15000,tmr.ALARM_AUTO,function()
    --                                        client:publish("infos",nodemcu.ID.." "..nodemcu.Status.." "..TEMP,0,0,function()
    --                                                                                                                print("sent from alarm")  
    --                                                                                                             end)
    --                                    end)
---------------------------------------------------------------


---------------------------------------------------------------
m:connect(nodemcu.MQTT_SERVER, 1883, 0,
             conectado,
function(client, reason) print("failed reason: "..reason) end)
