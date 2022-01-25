push = require "push"
Class = require "class"

require "assets.Ball"
require "assets.Paddle"

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE1_X = 5
PADDLE2_X = VIRTUAL_WIDTH - 10
PADDLE_Y = VIRTUAL_HEIGHT / 2 -13

PADDLE_WIDTH = 5
PADDLE_HEIGHT = 26

PADDLE_SPEED = 200

BALLX = VIRTUAL_WIDTH / 2 - 2
BALLY = VIRTUAL_HEIGHT / 2 - 2
BALL_WIDTH = 4
BALL_HEIGHT = 4

PLAYER1_SCORE = 0
PLAYER2_SCORE = 0

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    header_font8px = love.graphics.newFont("font.ttf", 8)
    header_font14px = love.graphics.newFont("font.ttf", 14)
    header_font20px = love.graphics.newFont("font.ttf", 20)
    love.graphics.setFont(header_font8px)
    love.graphics.setColor(1, 1, 1, 1)

    love.window.setTitle("Pong!")

    math.randomseed(os.time())

    sounds = {}
    sounds.paddle_hit = love.audio.newSource("sounds/paddle_hit.wav", "static")
    sounds.wall_hit = love.audio.newSource("sounds/paddle_hit.wav", "static")
    sounds.score = love.audio.newSource("sounds/score.wav", "static")
    sounds.game_over = love.audio.newSource("sounds/game_over.wav", "static")

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        full = false, resizable = false, vsync = true, canvas = false
    })

    ball = Ball(BALLX, BALLY, BALL_WIDTH, BALL_HEIGHT)

    player1 = Paddle(PADDLE1_X, PADDLE_Y, PADDLE_WIDTH, PADDLE_HEIGHT)
    player2 = Paddle(PADDLE2_X, PADDLE_Y, PADDLE_WIDTH, PADDLE_HEIGHT)

    ball_dX = math.random(2) == 1 and -80 or 80
    ball_dY = math.random(-50, 50)

    servingState = math.random(2)
    winningPlayer = 0
    gameState = "start"
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    if key == "enter" or key == "return" and gameState ~= "playing" then
        if gameState == "start" then
            gameState = "serve"
        elseif gameState == "serve" then
            gameState = "playing"
        elseif winningPlayer == 1 or winningPlayer == 2 then
            gameState = "finish"
        else
            gameState = "start"
            ball:reset()
        end
    end
end

function love.update(dt)
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if love.keyboard.isDown("up") then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("down") then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == "serve" then
        ball.dy = math.random(-50, 50)
        if servingState == 1 then
            ball.dx = math.random(140, 220)
        else
            ball.dx = -math.random(140, 220)
        end
    end

    if gameState == "playing" then
        if ball:collision(player1) then
            ball.dx = -ball.dx * 1.04
            ball.x = player1.x + 5

            sounds.paddle_hit:play()

            if ball.dy > 0 then
                ball.dy = math.random(25, 175)
            elseif ball.dy < 0 then
                ball.dy = -math.random(25, 175)
            end
        end

        if ball:collision(player2) then
            ball.dx = -ball.dx * 1.04
            ball.x = player2.x - 5
            
            sounds.paddle_hit:play()

            if ball.dy > 0 then
                ball.dy = math.random(25, 175)
            elseif ball.dy < 0 then
                ball.dy = -math.random(25, 175)
            end
        end

        if ball.y <= 0 then
            ball.y = 0
            sounds.wall_hit:play()
            ball.dy = -ball.dy    
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            sounds.wall_hit:play()
            ball.dy = -ball.dy
        end

        if ball.x <= 0 then
            PLAYER2_SCORE = PLAYER2_SCORE + 1
            sounds.score:play()
            ball:reset()
            servingState = 1
            gameState = "start"
        end

        if ball.x >= VIRTUAL_WIDTH then
            PLAYER1_SCORE = PLAYER1_SCORE + 1
            sounds.score:play()
            ball:reset()
            servingState = 2
            gameState = "start"
        end

        ball:update(dt)
    end

    if PLAYER1_SCORE == 10 then
        winningPlayer = 1
        sounds.game_over:play()
        gameState = "finish"
    elseif PLAYER2_SCORE == 10 then
        winningPlayer = 2
        sounds.game_over:play()
        gameState = "finish"
    else
        winningPlayer = 0
    end

    if gameState == "finish" then
        love.graphics.printf("Get 10 points to win!", 0, 10, VIRTUAL_WIDTH, "center")
        ball:reset()
        PLAYER1_SCORE = 0
        PLAYER2_SCORE = 0
    end

    player1:update(dt)
    player2:update(dt)
end

function love.draw()
    push:start()

    love.graphics.clear(40/255, 45/255, 52/255, 1)

    displayScores()

    love.graphics.setFont(header_font8px)
    love.graphics.setColor(1, 1, 1, 1)
    
    if gameState == "start" then
        love.graphics.printf("Hello, Welcome to Pong! Press Enter to Play.", 0, 10, VIRTUAL_WIDTH, "center")
    elseif gameState == "playing" then
        love.graphics.printf("Get 10 points to win!", 0, 10, VIRTUAL_WIDTH, "center")
    elseif gameState == "serve" then
        love.graphics.setFont(header_font14px)
        love.graphics.printf("Serving turn player: " .. tostring(servingState) .. ". Press Enter!", 0, 10, VIRTUAL_WIDTH, "center")
    else
        love.graphics.printf("Player " .. tostring(winningPlayer) .. " won the match. Press Enter to Restart", 0, 10, VIRTUAL_WIDTH, "center")
    end

    ball:render()
    player1:render()
    player2:render()

    showFPS()
    push:finish()
end

function displayScores()
    love.graphics.setFont(header_font14px)
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.printf("Player 1", 2, VIRTUAL_HEIGHT / 5, VIRTUAL_WIDTH, "left")
    love.graphics.printf("Player 2", 0, VIRTUAL_HEIGHT / 5, VIRTUAL_WIDTH, "right")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(tostring(PLAYER1_SCORE) .. " pts", VIRTUAL_WIDTH / 2 - 80, VIRTUAL_WIDTH / 9)
    love.graphics.print(tostring(PLAYER2_SCORE) .. " pts", VIRTUAL_WIDTH / 2 + 40, VIRTUAL_WIDTH / 9)
end


function showFPS()
    love.graphics.setFont(header_font14px)
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end
