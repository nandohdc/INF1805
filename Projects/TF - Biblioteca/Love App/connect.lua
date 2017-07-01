--Configuracoes do nodemcu para ser identificado numa rede
nodemcu = {
    ID = 0,
    wificonfig = {
        --Colocar em SSID a rede desejada para conectar
        ssid = "Valinor",
        pwd = "bateria123",
        save = false
    },
    MQTT_SERVER = "192.168.43.35",
    Status = "free"
}

--Definindo LEDS
LD1 = 6;
LD2 = 3;

function LED(led_pin)
    local pin = led_pin
    return {
        inicia = function()
                    gpio.mode(pin, gpio.OUTPUT)
                    gpio.write(pin, gpio.LOW)
                 end,
        liga = function()
                print("O NodeMCU #"..nodemcu.ID.." Led #"..pin.." Ligado")
                gpio.write(pin, gpio.HIGH)
               end,
        desliga = function()
                    gpio.write(pin, gpio.LOW)
                  end
    }
end

-- Conexao na rede Wifi
wifi.setmode(wifi.STATION)
--Nao alterar a linha de configurar wifi
wifi.sta.config(nodemcu.wificonfig)
wifi.sta.connect()

if(wifi.sta.status() == 5) then
    nodemcu.ID = wifi.sta.getip()
    print("O NodeMCU #"..nodemcu.ID.." is connected to "..nodemcu.wificonfig.ssid)
    local led_green = LED(LD1)
    local led_red = LED(LD2)
    led_green.inicia()
    led_red.inicia()
    led_red.desliga()
    led_green.liga()
end
