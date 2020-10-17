Ball = Class{}

function Ball:init(x, y, width, height)

  self.x = x
  self.y = y
  self.width = width
  self.height = height

  self.dx = math.random(2) == 1 and -100 or 100 -- if math.random(2) equals to 1, so ballDX will be -100 and if math.random(2) equals to 1, so ballDX will be 100
  self.dy = math.random(-50, 50)

end

function Ball:collides(box)

  if self.x > box.x + box.width or self.x + self.width < box.x then
    return false
  end

  if self.y > box.y + box.height or self.y + self.height < box.y then
    return false
  end

  return true

end

function Ball:reset()

  self.x = VIRTUAL_WIDTH / 2 - 2
  self.y = VIRTUAL_HEIGHT / 2 - 2

  self.dx = math.random(2) == 1 and -100 or 100
  self.dy = math.random(-50, 50) * 1.5

end


function Ball:update(dt)

  self.x = self.x + self.dx * dt * 1.3
  self.y = self.y + self.dy * dt * 1.3

end

function Ball:render()
  love.graphics.rectangle('fill', self.x, self.y, 4, 4) -- renders the ball
end

function Ball:position()
  love.graphics.print("Ball Y position: " .. tostring(self.y), 40, 30)
  love.graphics.print("Ball DX value: " .. tostring(self.dx), 40, 40)
  love.graphics.print("Ball DY value: " .. tostring(self.dy), 40, 50)
end