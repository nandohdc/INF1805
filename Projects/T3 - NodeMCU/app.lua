local m = mqtt.Client("clientid", 120)
local deb_old,deb_new = 0,0;
local button1, button2 = 1,2
gpio.mode(button1,gpio.INT,gpio.PULLUP)
gpio.mode(button2,gpio.INT,gpio.PULLUP)
led_livre = LED(6)
led_ocupado = LED(3)
led_livre.inicia()
led_ocupado.inicia()

local function readtemp()
  lasttemp = adc.read(0)*(3.3/10.24)
end

function publica(c)
    return{
      message = function()
              print("publicando..")
              c:publish("connect", nodemcu.ID,0,0, 
                function(c) print("ip enviado") end)
            end,
      temp = function ()
              print("publicando..")
              c:publish("temperatura","F&F : "..TEMP,0,0, 
                function(c) print("mandei temp!") end)
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
end

function reageBotao(pin,c)
        led_livre.desliga()
        led_ocupado.desliga()
        print("reacting...")
       if(pin == button1) then
            c:publish("infos",nodemcu.ID.." ocupado ".."31",0,0, 
                function(c) print("done") end)
            led_ocupado.liga()
       else
            c:publish("infos",nodemcu.ID.." livre ".."31",0,0, 
                function(c) print("done") end)
            led_livre.liga()
       end
end
function conectado (client)    
    local envia = publica(client)
    local inscrito = inscreve(client)
    print("Conectado")
    inscrito.novaInscricao()
    recebeControle(client)   
    envia.message()
    gpio.trig(button1,"down", function () reageBotao(button1,client) end)
    gpio.trig(button2,"down", function () reageBotao(button2,client) end)
end 

m:connect("192.168.1.12", 1883, 0,
             conectado,
function(client, reason) print("failed reason: "..reason) end)