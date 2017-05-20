local m = mqtt.Client("clientid", 120)
local deb_old,deb_new = 0,0;
local button1, button2 = 1,2
gpio.mode(button1,gpio.INT,gpio.PULLUP)
gpio.mode(button2,gpio.INT,gpio.PULLUP)
--gpio.mode(button1,gpio.INT)
--gpio.mode(button2,gpio.INT)
local function readtemp()
  lasttemp = adc.read(0)*(3.3/10.24)
end

function publica(c)
local msg = math.random(15)
    return{
      message = function()
              print("publicando..")
              c:publish("test/topic", msg,0,0, 
                function(c) print("mandei temp!") end)
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
        print("reacting...")
        c:publish("test/topic", "publishing from button "..pin,0,0, 
                function(c) print("done") end)
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
