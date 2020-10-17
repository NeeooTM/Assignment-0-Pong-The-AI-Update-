WINDOW_WIDTH = 1280 -- Constants bcs name of variable capitalized
WINDOW_HEIGHT = 720 -- Constants bcs name of variable capitalized

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

Class = require 'class'
push = require 'push'

require 'Paddle'
require 'Ball'

function love.load()

  math.randomseed(os.time())

  love.window.setTitle("Pong")

  sounds = {
    ['paddle_hit'] = love.audio.newSource('paddle_hit.wav', 'static'),
    ['point_scored'] = love.audio.newSource('point_scored.wav', 'static'),
    ['wall_hit'] = love.audio.newSource('wall_hit.wav', 'static')
  }

  gameStates = {
    ['serve'] = 'serve',
    ['start'] = 'start',
    ['victory'] = 'victory',
    ['play'] = 'play'
  }

  love.graphics.setDefaultFilter('nearest', 'nearest')

  -- sets player1 score value to 0 on start
  player1Score = 0
  -- sets player2 score value to 0 on start
  player2Score = 0
  -- whitch player win
  winner = 0
  -- sets max score
  maxScore = 3
  -- sets ball acceleration modifier
  ballAcceleration = 1.1 
  -- sets bots speed
  computersSpeed = 40

  loadFonts()

  paddle1 = Paddle(5, 20, 5, 20)
  paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {fullscreen = false, vsync = true, resizable = true})

  -- decide which players will serve
  servingPlayer = math.random(2) == 1 and 1 or 2

  if servingPlayer == 1 then
    ball.dx = 100
  else
    ball.dx = -100
  end

  gameState = 'start'

end

function love.update(dt)

  paddle1:update(dt)
  paddle2:update(dt)

  if gameState == 'play' then
    ball:update(dt)
  end

  -- scored to player2, adds to player1 +1 and resets to serve or victory state
  if ball.x >= VIRTUAL_WIDTH - 4 then
    goalScored(1)
    ball:reset()
    ball.dx = -100
    sounds['point_scored']:play()

    if isAnyWinner() == false then
      changeGameState(gameStates['serve'])
    end
  end

  -- scored to player1, adds to player2 +1 and resets to serve or victory state
  if ball.x <= 0 then 
    goalScored(2)
    ball:reset()
    ball.dx = 100
    sounds['point_scored']:play()

    if isAnyWinner() == false then
      changeGameState(gameStates['serve'])
    end
  end

  -- actors(paddle1 or paddle2) overlap the ball, bounce the ball
  if ball:collides(paddle1) then
    actorOverlap(1)
    sounds['paddle_hit']:play()
  elseif ball:collides(paddle2) then
    actorOverlap(2)
    sounds['paddle_hit']:play()
  end

  -- ball hits upper or lower boundary, when bounce the ball
  if ball.y <= 0 then
    ball.dy = -ball.dy
    ball.y = 0
    sounds['wall_hit']:play()
  elseif ball.y >= VIRTUAL_HEIGHT - 4 then
    ball.dy = -ball.dy 
    ball.y = VIRTUAL_HEIGHT -4
    sounds['wall_hit']:play()
  end

  -- player1 control
  if love.keyboard.isDown('w') then
    paddle1.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown('s') then
    paddle1.dy = PADDLE_SPEED
  else
    paddle1.dy = 0 
  end

  -- computer control
  if ball.dx > 0 and ball.y < paddle2.y and gameState == gameStates['play'] then
    paddle2.dy = -PADDLE_SPEED + 42
  elseif ball.dx > 0 and ball.y > paddle2.y and gameState == gameStates['play'] then
    paddle2.dy = PADDLE_SPEED - 42
  else
    paddle2.dy = 0 
  end

  -- player2 control
  --
  --if love.keyboard.isDown('up') then
  --  paddle2.dy = -PADDLE_SPEED
  --elseif love.keyboard.isDown('down') then
  --  paddle2.dy = PADDLE_SPEED
  --else
  --  paddle2.dy = 0 
  --end

end

function love.keypressed(key)

    if key == 'escape' then
      love.event.quit()
    end

    if key == 'enter' or key == 'return' then
      if gameState == 'start' then
        changeGameState(gameStates['serve'])
      elseif gameState == 'victory' then
        changeGameState(gameStates['start'])
        player1Score = 0
        player2Score = 0
      elseif gameState == 'serve' then
        changeGameState(gameStates['play'])
      end
    end

end 

function love.draw()

  push:apply('start') -- begin rendering at virtual resolution

  love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 1) -- sets background color

  love.graphics.setFont(smallFont) -- sets font to font.ttf with size 8
  printGameStateMessage()

  love.graphics.setFont(scoreFont) -- sets font to font.ttf with size 32
  printPlayersScores()

  ball:render()
  paddle1:render()
  paddle2:render()

  displayLogMessages()

  push:apply('end') -- end rendering at virtual resolution

end

function love.resize(w, h)
  push:resize(w, h)
end

function displayLogMessages()

  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.setFont(smallFont)
  love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 40, 20)
  love.graphics.setColor(1, 1, 1, 1)

end

function printPlayersScores()

  -- prints score of player1 and player2
  love.graphics.print(player1Score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
  love.graphics.print(player2Score, VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)

end

function printGameStateMessage()

  if gameState == 'start' then
    love.graphics.printf("Welcome to Pong!", 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press Enter to Play!", 0, 20, VIRTUAL_WIDTH, 'center')

  elseif gameState == 'serve' then
    love.graphics.printf("Player " .. tostring(servingPlayer) .. "'s turn!", 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("Press Enter to Serve!", 0, 20, VIRTUAL_WIDTH, 'center')

  elseif gameState == 'victory' then
    love.graphics.setFont(victoryFont)
    love.graphics.printf("Player " .. tostring(winner) .. " wins!", 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(smallFont)
    love.graphics.printf("Press Enter to Serve!", 0, 42, VIRTUAL_WIDTH, 'center')
  end

end

function goalScored(whoseGoal)

  if whoseGoal == 2 then
    player2Score = player2Score + 1
    servingPlayer = 1
  elseif whoseGoal == 1 then
    player1Score = player1Score + 1
    servingPlayer = 2 
  end
    
end

function isAnyWinner()

  if player1Score == maxScore then
    changeGameState(gameStates['victory'])
    winner = 1
    return true
  elseif player2Score == maxScore then
    changeGameState(gameStates['victory'])
    winner = 2
    return true
  end

  return false

end

function actorOverlap(whatPlayerOverlap)

    ball.dx = -ball.dx * ballAcceleration

    if whatPlayerOverlap == 1 then
      ball.x = paddle1.x + 5
    elseif whatPlayerOverlap == 2 then 
      ball.x = paddle2.x - 4
    end

    if ball.dy < 0 then
      ball.dy = -math.random(10, 150)
    else
      ball.dy = math.random(10, 150)
    end

end

function changeGameState(state)
  gameState = state
end

function loadFonts()
  smallFont = love.graphics.newFont('font.ttf', 8)
  scoreFont = love.graphics.newFont('font.ttf', 32)
  victoryFont = love.graphics.newFont('font.ttf', 24)
end
