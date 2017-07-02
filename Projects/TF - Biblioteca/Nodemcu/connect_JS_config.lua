--Configuracoes do nodemcu para ser identificado numa rede
nodemcu = {
    ID = 0,
    wificonfig = {
        --Colocar em SSID a rede desejada para conectar
        ssid = "Homem's Wi-Fi",
        pwd = "02051993",
        save = false
    },
    MQTT_SERVER = 'test.mosca.io',
    Status = "free"
}