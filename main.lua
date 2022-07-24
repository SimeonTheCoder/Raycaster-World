function love.load ()
  map = {}
  
  lights = {}
  
  local sun = {}
  local torch = {}
  
  sun.x, sun.y = 50, 50
  torch.x, torch.y = 50, 50
  
  sun.isSun, torch.isSun = true, false
  sun.o_aff, torch.o_aff = true, false
  sun.int, torch.int = 100, 1
  
  table.insert(lights, sun)
  table.insert(lights, torch)
  
  samples = 200
  
  x_offset = 0
  y_offset = 0
  
  lx_offset = 0
  ly_offset = 0
  
  offset_lamp = false
  
  generate_map (map)
end

function love.keypressed (key)
  if key == "t" then
    offset_lamp = not offset_lamp
  end
end

function gen_pixel (i, j)
  local t_height = love.math.noise((j+x_offset) / 100.) * 50 + 50 + y_offset
  
  local val = nil
      
  if (100 - i) < t_height then
    val = 1
  else
    val = 0
  end
  
  --val = val - love.math.noise((j+x_offset) / 30., (i+y_offset) / 30.) * (love.math.noise((j+x_offset) / 70., (i+y_offset) / 70.) + (math.sin((j+x_offset)/2 * math.pi / 180.) + 1) / 4.)
  val = val * love.math.noise((j+x_offset) / 30., (i+y_offset) / 30.) * 1
  
  val = math.max(0, math.min(1, val))
  
  return val
end

function generate_map (map)
  for i = 0, 100, 1
  do
    map[i] = {}
    
    for j = 0, 100, 1
    do
      map[i][j] = gen_pixel(i, j)
      
      if i > 0 and map[i][j] > .5 and map[i-1][j] < .5 then
        map[i][j] = .6
      end
      
      if map[i][j] > .5 and i + y_offset > 50 then
      --  map[i][j] = .7
      end
      
      --map[i][j] = --TODO
    end
  end
end

function love.update (dt)
  if love.keyboard.isDown("left") then
    x_offset = x_offset - 60 * dt
  end
  
  if offset_lamp and (love.keyboard.isDown("left") or love.keyboard.isDown("d")) then
    lx_offset = lx_offset - 60 * dt
  end
  
  if love.keyboard.isDown("right") then
    x_offset = x_offset + 60 * dt
  end
  
  if offset_lamp and (love.keyboard.isDown("right") or love.keyboard.isDown("a")) then
    lx_offset = lx_offset + 60 * dt
  end
  
  if love.keyboard.isDown("up") then
    y_offset = y_offset - 60 * dt
  end
  
  if offset_lamp and (love.keyboard.isDown("up") or love.keyboard.isDown("s")) then
    ly_offset = ly_offset - 60 * dt
  end
  
  if love.keyboard.isDown("down") then
    y_offset = y_offset + 60 * dt
  end
  
  if offset_lamp and (love.keyboard.isDown("down") or love.keyboard.isDown("w")) then
    ly_offset = ly_offset + 60 * dt
  end
  
  if love.keyboard.isDown("]") then
    samples = math.floor(samples + 60 * dt)
  end
  
  if love.keyboard.isDown("[") then
    samples = math.floor(samples - 10 * dt)
  end
  
  samples = math.max(1, samples)
  
  generate_map (map)
end

function love.draw (dt)
  for i = 0, 100, 1
  do
    for j = 0, 100, 1
    do
      if map[i][j] > .5 then
        love.graphics.setColor(0, 1, 0)
      else
        love.graphics.setColor(0, 0, 0)
      end
      
      love.graphics.rectangle("fill", j * 5, i * 5, 5, 5)
    end
  end
  
  for i = 0, 100, 1
  do
    for j = 0, 100, 1
    do
      local lvl = 0
      
      for l, v in ipairs(lights)
      do
        local dx = v.x - j
        local dy = v.y - i
        
        if v.o_aff then
          dx = v.x - lx_offset - j
          dy = v.y - ly_offset - i
        end
          
        local dis = math.sqrt(dx * dx + dy * dy)
        
        if map[i][j] > .5 then
          
        else
          dx, dy = dx / (samples + .0), dy / (samples +.0)
          
          for k = 0, samples, 1
          do
            local val_there = nil
            
            if math.floor(j + dx * k) >= 0 and math.floor(j + dx * k) < 100 and math.floor(i + dy * k) >= 0 and math.floor(i + dy * k) < 100 then
              val_there = map[math.floor(i + dy * k)][math.floor(j + dx * k)]
            else
              val_there = gen_pixel(math.floor(i + dy * k), math.floor(j + dx * k))
            end
                
            if val_there > .5 then
              break
            end
            
            if k == samples then
              --love.graphics.setColor(1 - dis / 50, 1 - dis / 25, 1 - dis / 12)
              
              if v.isSun then
                lvl = lvl + v.int
              else
                lvl = lvl + (1 - dis / 50 * v.int) * v.int
              end
            end
          end
        end
      end
      
      love.graphics.setColor(0, lvl, lvl)
              
      love.graphics.rectangle("fill", j*5, i*5, 5, 5)
      
      if map[i][j] > .5 then
        --love.graphics.setColor(.5 * (1 - dis / 50), .25 * (1 - dis / 50), 0)
        love.graphics.setColor(.5, .25, 0)
        
        if map[i][j] == .6 then
          love.graphics.setColor(0, 1, 0)
        end
        
        love.graphics.rectangle("fill", j*5, i*5, 5, 5)
      end
    end
  end
  
  love.graphics.setColor(1, 0, 0)
  
  love.graphics.rectangle("fill", 250, 250, 5, 5)
end