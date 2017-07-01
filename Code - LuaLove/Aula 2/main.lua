function newblip (vel)
  local x, y = 0, 0
  return {
    update = coroutine.wrap(function (self)
      while true do
        local width, height = love.graphics.getDimensions( )
        x = x + 1
        if x > width then
        -- volta Ã  esquerda da janela
          x = 0
        end
        wait(vel, self)
      end
    end),
    affected = function (pos)
      if pos>x and pos<x+10 then
      -- "pegou" o blip
        return true
      else
        return false
      end
    end,
    draw = function ()
      love.graphics.rectangle("line", x, y, 10, 10)
    end,
    ativo = true,
    tiempoDecorrido = 0
  }
end

function newplayer ()
  local x, y = 0, 200
  local width, height = love.graphics.getDimensions( )
  return {
  try = function ()
    return x
  end,
  update = function (dt)
    x = x + 0.5
    if x > width then
      x = 0
    end
  end,
  draw = function ()
    love.graphics.rectangle("line", x, y, 30, 10)
  end
  }
end

function love.keypressed(key)
  if key == 'space' then
    pos = player.try()
    for i in ipairs(listabls) do
      local hit = listabls[i].affected(pos)
      if hit then
        table.remove(listabls, i) -- esse blip "morre" 
        return -- assumo que sÃ³ vai pegar um blip
      end
    end
  end
end

function love.load()
  tiempo = 0
  player =  newplayer()
  listabls = {}
  for i = 1, 5 do
    listabls[i] = newblip(i/20)
  end
end

function love.draw()
  player.draw()
  for i = 1,#listabls do
    listabls[i].draw()
  end
end

function love.update(dt)
  tiempo = tiempo + dt
  player.update(dt)
  for i = 1,#listabls do
    if(listabls[i].tiempoDecorrido <= tiempo) then
      listabls[i]:update()
    end   
  end
end

function wait(seconds, myblip)
  myblip.tiempoDecorrido = tiempo + seconds
  coroutine.yield()
end
  