print("hello node")
gpio.mode(7,gpio.OUTPUT)
gpio.mode(8,gpio.INT)
mytimer = tmr.create()
atimer = tmr.create()
time_start = 0
time_end = 0
count = 0
avg = {}
function trig_cb1()
    gpio.trig(8,"down",trig_cb2)
    print("call back 1")
    time_start= tmr.now()
end
function trig_cb2()
    gpio.trig(8,"up",trig_cb1)
    print("callback 2")
    time_end = tmr.now()
    local us = time_end - time_start
    local distance = us/58
   -- print("gap : "..us)
   -- print("distance(cm) : "..distance)
    --mytimer:unregister()
    table.insert(avg,distance)
end
function pulse ()
   -- print("pulsing")
    count = count + 1
    if(count > 20) then
        mytimer:stop()
        local sum = 0
        for i,v in ipairs(avg) do
           sum = sum + v
        end
        sum = sum/table.getn(avg)
        print("avg : "..sum)
        return
    end
    time_start = 0
    time_end = 0
    tmr.delay(100)
    gpio.write(7,gpio.HIGH)
    tmr.delay(10)
    gpio.write(7,gpio.LOW)
    tmr.delay(100)
end
gpio.trig(8,"up", trig_cb1)
mytimer:register(50, tmr.ALARM_AUTO, pulse)
atimer:register(5000,tmr.ALARM_AUTO,function() avg = {} count = 0 mytimer:start() end)
atimer:start()
