Ball = Class{}

function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dx = math.random(2) == 1 and math.random(-80, -120) or math.random(80, 120)
    self.dy = math.random(2) == 1 and -80 or 80
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:reset()
    self.x = BALLX
    self.y = BALLY
    self.dx = math.random(-50, 50)
    self.dy = math.random(2) == 1 and -80 or 80
end

function Ball:collision(paddle)
    if self.x > paddle.x + paddle.width or paddle.x > self.x + self.width then
        return false
    end

    if self.y > paddle.y + paddle.height or paddle.y > self.y + self.height then
        return false
    end

    return true
end

function Ball:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end