local Juego = require("juego")

function love.load()
    if Juego and Juego.enter then
        Juego:enter()
    end
end

function love.update(dt)
    if Juego and Juego.update then
        Juego:update(dt)
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    if Juego and Juego.mousepressed then
        Juego:mousepressed(x, y, button)
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if Juego and Juego.keypressed then
        Juego:keypressed(key)
    end
end

function love.draw()
    if Juego and Juego.draw then
        Juego:draw()
    end
end