local m = mqtt.Client("clientid", 120)

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
                        end,
      novaInscricao2 = function()
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
    }
end

function recebeControle(c)
    c:subscribe("test/topic",0,novaInscricao)
end

function conectado (client)
    local envia = publica(client)
    local inscrito = inscreve(client)
    print("Conectado")
    inscrito.novaInscricao()
    recebeControle(client)   
    envia.message()
end 

m:connect("10.80.70.115", 1883, 0,
             conectado,
function(client, reason) print("failed reason: "..reason) end)