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
            if _x > width then
        	   	direction = "right"
            	_x,_y = oldX,oldY
            end
            if _x < 0 then
            	direction = "left"
            	_x,_y = oldX,oldY
            end
            if _x <= 80 and _y <= 80 then
            	direction = "left"
            	_x,_y = oldX,oldY
            end
            self.x = _x
            wait(vel,self)
        end
    end),
    draw = function ()
      
      love.graphics.draw(img.asteroid, _x - 16, _y - 16)
    end,
    x = _x,
    y = _y,
    w = 40,
    h = 40,
    decorr = 0,
    hit = 0
  }
end
function newPlayer (vel)
  local _x, _y = 1, 1
  local oldZ, newZ = 0,0
  return {
    update = coroutine.wrap(function (self)
        while true do
            local width, height = love.graphics.getDimensions( )
           	local direction = "up"
         	local isDown=love.keyboard.isDown
			if isDown('right') or isDown('d') then
				_x = _x+1
				direction = "right"
			elseif isDown('left') or isDown('a') then
				_x = _x-1
				direction = "left"
			elseif isDown('up') or isDown('w') then
				_y = _y-1
				direction = "up"
			elseif isDown('down') or isDown('s') then
				_y = _y+1
				direction = "down"
			end
			if isDown('z') and (direction ~= "up" and direction ~= "down") then
				newZ = 1
				if(oldZ == 0 and newZ == 1) then
					oldZ = newZ
					table.insert(listaShot,newShot(1/500, direction))
					local newSource = love.audio.newSource("/Assets/LaserGun.mp3")
					table.insert(track.lasers,newSource)
					newSource:setVolume(0.1)
					newSource:play()
				end
				if(oldZ == 1 and newZ == 0) then
					oldZ = newZ
				end
			else
				newZ = 0
				oldZ = newZ
			end
  			self.x = _x
  			self.y = _y
  			
  			collision = false
			if not isOnScreen(self) or isColliding(self) then
				_x, _y=1,1
   				collision=true
   				track.explosion:setVolume(0.6)
   				track.explosion:play()
			end
			self.x = _x
  			self.y = _y
            wait(vel,self)
        end
    end),
    draw = function ()
      	love.graphics.draw(img.spaceship, _x-16, _y-16)
    end,
    x = _x,
    y = _y,
    w = 20,
    h = 20,
    decorr = 0
  }
end

function newObjective ()
  local _x,_y = math.random(0,WW),math.random(0,HH)
  return {
    update = function (self)
    	self.x = _x
    	self.y = _y
    end,
    draw = function ()
      love.graphics.draw(img.objective, _x-16, _y-16)
    end,
    x = _x,
    y = _y,
    w = 50,
    h = 50
  }
end

function newShot (vel,dir)
  local _x,_y,w,h = Player.x, Player.y+8,20,5
  local direction = dir
  return {
    update = coroutine.wrap(function (self)
        while true do
			if direction == "right" then
				_x = _x+1
			elseif direction == "left" then
				_x = _x-1
			elseif direction == "up" then
				_y = _y-1
			elseif direction == "down" then
				_y = _y+1
			elseif true then
				_x = _x+1
			end
			self.x,self.y = _x,_y
			if shotHit(self) or not isOnScreen(self) then
				self.hit = 1
			end
        	wait(vel,self)
        end
    end),
    draw = function ()
      lg.setColor(255,0,0,255)
      lg.rectangle('fill',_x,_y,w,h)
      lg.setColor(255,255,255,255)
    end,
    x = _x,
    y = _y,
    w = 20,
    h = 5,
    hit = 0,
    decorr = 0
  }
end

function love.load()
  love.window.setTitle("INF1805 - Felipe Vieira Côrtes e Fernando Homem da Costa")
  love.window.setMode(800, 600, {resizable=true, vsync=false, minwidth=400, minheight=300})
  img = {}
  img.background = love.graphics.newImage('/images/background.jpg') -- dimensions 800 x 600
  img.spaceship = love.graphics.newImage('/images/ufo.png') -- dimensions 64 x 64
  img.asteroid = love.graphics.newImage('/images/asteroid.png') -- dimensions 64 x 64
  img.objective = love.graphics.newImage('/images/rebels.png') -- dimensions 64 x 64
  
  track = {}
  track.soundtrack =  love.audio.newSource("/Assets/1-10 The Empire Strikes Back_ The Imperial March .mp3")
  track.explosion =  love.audio.newSource("/Assets/Explosion.mp3")
  track.lasers = {}
  track.soundtrack:play()
  score = 0
  W, H=lg.getWidth(), lg.getHeight()
  Obstacles={}
  for i=1,20 do
    Obstacles[i] = newObs(i*50/50000)
  end
  Player = newPlayer(5/1000)
  Objective = newObjective()
  listaShot = {}
end

function love.draw()
  love.graphics.draw(img.background, 0, 0)
  lg.setColor(255,255,255,255)
  lg.rectangle('line', 0,0,40,40)
  for i = 1,#Obstacles do
    Obstacles[i].draw()
  end
  Player.draw()
  
  lg.setColor(255,0,0,255)
  font = love.graphics.newFont(20)
  font = love.graphics.setFont(font)
  lg.print("Score : "..score,0,HH - 20)
  lg.setColor(255,255,255,255)
  if collision then
  	lg.setColor(255,255,255,255)
    score = 0
  end
  Objective.draw()
  for i=1,#listaShot do
  	listaShot[i].draw()
  end
end

function love.update(dt)

  tempDecorr = tempDecorr + dt
  for i = 1,#Obstacles do
    if Obstacles[i].decorr <= tempDecorr then
        Obstacles[i]:update()
    end
  end
  if Player.decorr <= tempDecorr then
      Player:update()
  end
  Objective:update()
  for i = 1,#listaShot do
  	listaShot[i]:update()
  end
  newL = {}
  for i = 1,#listaShot do
  	if listaShot[i].hit == 0 then
  		table.insert(newL,listaShot[i])
  	end
  end
  listaShot = newL
  
  newL = {}
  for i = 1,#Obstacles do
  	if Obstacles[i].hit == 0 then
  		table.insert(newL,Obstacles[i])
  	end
  end
  Obstacles = newL
  for i = #Obstacles+1,20 do
  	table.insert(Obstacles,newObs(math.random(1,50)*50/50000))
  end
  
  newL = {}
  for i = 1,#track.lasers do
  	if not track.lasers[i]:isStopped() then
  		table.insert(newL,track.lasers[i])
  	end
  end
  track.lasers = newL
  
  getScore()
end

function isOnScreen(obj)
  if obj.x>0 and obj.x+obj.w<W and
     obj.y>0 and obj.y+obj.h<H then
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

function shotHitAsteroid(obj1,obj2)
  local o1x, o1y=obj1.x-obj2.x, obj1.y-obj2.y
  if o1x+obj1.w<0 or o1y+obj1.h<0 or
    o1x>obj2.w or o1y>obj2.h then
    return false
  else
  	obj2.hit = 1
  	obj1.hit = 1
    return true
  end
end
function shotHit(obj)
  for k,v in ipairs(Obstacles) do
    if shotHitAsteroid(obj,v) then
      return true
    end
  end
  return false
end

function isColliding(obj)
  for k,v in ipairs(Obstacles) do
    if isCollidingWith(obj,v) then
      return true
    end
  end
  return false
end

function getScore()
	if isCollidingWith(Player,Objective) then
		Objective = newObjective()
		score = score + 1
	end
end

function wait(segundos, meuObs)
    meuObs.decorr = tempDecorr + segundos
    coroutine.yield()
end