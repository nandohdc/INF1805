--Configuracoes do nodemcu para ser identificado numa rede
nodemcu = {
    ID = math.random(15),
    wificonfig = {
        --Colocar em SSID a rede desejada para conectar
        ssid = "Homem's Wi-Fi",
        pwd = "02051993",
        save = false
    }
}

--Definindo LEDS
LD1 = 6;
LD2 = 3;

function LED(pin_num)
    return {
        inicia = function()
                    gpio.mode(pin_num, gpio.OUTPUT)
                    gpio.write(pin_num, gpio.LOW)
                 end,
        liga = function()
                print("O NodeMCU #"..nodemcu.ID.." Ligando Led #"..pin_num)
                gpio.write(pin_num, gpio.HIGH)
               end,
        desliga = function()
                    gpio.write(pin_num, gpio.LOW)
                  end       
    }
end

-- Conexao na rede Wifi
wifi.setmode(wifi.STATION)
--Nao alterar a linha de configurar wifi
wifi.sta.config(nodemcu.wificonfig)

wifi.sta.connect()


if(wifi.sta.status() == 5) then
    Led = LED(LD1)
    Led.inicia(LD1)
    Led.inicia(LD2)
    Led.desliga(LD2)
    Led.liga(LD1)
    print("O NodeMCU #"..nodemcu.ID.." is connected to "..nodemcu.wificonfig.ssid)
    print(wifi.sta.getip())
end

print(wifi.sta.getip())
