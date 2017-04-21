local lg=love.graphics
local WW, HH = love.graphics.getDimensions( )
tempDecorr = 0
function newObs (vel)
  local _x,_y = math.random(0,WW),math.random(0,HH)
  local direction = "left"
  if math.random(0,1) > 0 then
  	direction = "left"
  else
  	direction = "right"
  end
  return {
    update = coroutine.wrap(function (self)
        while true do
            local width, height = love.graphics.getDimensions( )
            local oldX, oldY = _x,_y
            if direction == "left" then
            	_x = _x+1
            else
            	_x = _x-1
            end
            --if isColliding(self) then
            --	if direction == "left" then
            --		direction = "right"
            --	else
            --		direction = "left"
            --	end
       		--	_x,_y = oldX,oldY
          --  end
            if _x > width then
        	   	direction = "right"
            	_x,_y = oldX,oldY
            end
            if _x < 0 then
            	direction = "left"
            	_x,_y = oldX,oldY
            end
            self.x = _x
            wait(vel,self)
        end
    end),
    draw = function ()
      love.graphics.draw(img_asteroid, _x - 16, _y - 16)
      lg.rectangle('fill', _x,_y,40,40)
    end,
    x = _x,
    y = _y,
    w = 40,
    h = 40,
    decorr = 0
  }
end
function love.load()
  love.window.setTitle("INF1805 - Felipe Vieira Côrtes e Fernando Homem da Costad")
  love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})
  img_bg = love.graphics.newImage('/images/background.jpg') -- dimensions 800 x 600
  img_spaceship = love.graphics.newImage('/images/spaceship.png') -- dimensions 64 x 64
  img_asteroid = love.graphics.newImage('/images/asteroid.png') -- dimensions 64 x 64
  track =  love.audio.newSource("/Assets/1-10 The Empire Strikes Back_ The Imperial March .mp3")
  track:play()

  W, H=lg.getWidth(), lg.getHeight()
  local w,h=32,32
  Obstacles={}
  for i=1,20 do
    Obstacles[i] = newObs(i*50/50000)
  end
  w,h=40,50
  Cursor={x=math.random(W-w), y=math.random(H-h), w=w, h=h}
  while isColliding(Cursor) do
    Cursor.x, Cursor.y=math.random(W-w), math.random(H-h)
  end
  collision=false
end

function love.draw()
  love.graphics.draw(img_bg, 0, 0)
  for i = 1,#Obstacles do
    Obstacles[i].draw()
  end
  love.graphics.draw(img_spaceship, Cursor.x - 12, Cursor.y - 5)
  if collision then
    lg.print('COLLISION!!!', W/2, 0)
  end

end

local isDown=love.keyboard.isDown
function love.update(dt)
  local dx,dy=0,0
  tempDecorr = tempDecorr + dt
  for i = 1,#Obstacles do
    if Obstacles[i].decorr <= tempDecorr then
        Obstacles[i]:update()
    end
  end
  if isDown('right') or isDown('d') then
    dx=1
  elseif isDown('left') or isDown('a') then
    dx=-1
  elseif isDown('up') or isDown('w') then
    dy=-1
  elseif isDown('down') or isDown('s') then
    dy=1
  end
  local currX, currY=Cursor.x, Cursor.y
  Cursor.x, Cursor.y=Cursor.x+dx, Cursor.y+dy
  collision=false
  if not isOnScreen() or isColliding(Cursor) then
    Cursor.x, Cursor.y=1,1
    collision=true
  end
end

function isOnScreen()
  if Cursor.x>0 and Cursor.x+Cursor.w<W and
     Cursor.y>0 and Cursor.y+Cursor.h<H then
    return true
  else
    return false
  end
end

function isCollidingWith(obj1,obj2)
  local o1x, o1y=obj1.x-obj2.x, obj1.y-obj2.y
  if o1x+obj1.w<0 or o1y+obj1.h<0 or
    o1x>obj2.w or o1y>obj2.h then
    return false
  else
    return true
  end
end

function isColliding(obj)
  for k,v in ipairs(Obstacles) do
    if isCollidingWith(obj,v) then
      return true
    end
  end
  return false
end

function wait(segundos, meuObs)
    meuObs.decorr = tempDecorr + segundos
    coroutine.yield()
end