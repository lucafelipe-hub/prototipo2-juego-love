local Juego = {}

function Juego:enter()
    self.jugador = { x = 400, y = 300, ancho = 32, alto = 32, velocidad = 250 }
    self.enemigo = { x = 100, y = 100, ancho = 30, alto = 30, velocidad = 90 }
    self.coleccionable = { x = math.random(100, 700), y = math.random(100, 500), radio = 10 }
    self.balas = {}
    self.puntuacion = 0
    self.objetivoPuntos = 5
    self.estadoJuego = "jugando" -- Puede ser "jugando", "ganado", "perdido"

    -- Cargar imágenes y sonidos
    self.imagenAvion = love.graphics.newImage("avion.png")
    self.imagenEnemigo = love.graphics.newImage("enemigo.png")
    self.sonidoCoin = love.audio.newSource("moneda.mp3", "static")
    self.sonidoDisparo = love.audio.newSource("disparo.mp3", "static")
end

function Juego:update(dt)
    if self.estadoJuego ~= "jugando" then return end

    -- Movimiento del jugador
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then self.jugador.x = self.jugador.x + (self.jugador.velocidad * dt) end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then self.jugador.x = self.jugador.x - (self.jugador.velocidad * dt) end
    if love.keyboard.isDown("down") or love.keyboard.isDown("s") then self.jugador.y = self.jugador.y + (self.jugador.velocidad * dt) end
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then self.jugador.y = self.jugador.y - (self.jugador.velocidad * dt) end

    -- Límites de la pantalla
    if self.jugador.x < 0 then self.jugador.x = 0 end
    if self.jugador.x > 800 - self.jugador.ancho then self.jugador.x = 800 - self.jugador.ancho end
    if self.jugador.y < 0 then self.jugador.y = 0 end
    if self.jugador.y > 600 - self.jugador.alto then self.jugador.y = 600 - self.jugador.alto end

    -- Persecución del enemigo
    if self.enemigo.x < self.jugador.x then self.enemigo.x = self.enemigo.x + (self.enemigo.velocidad * dt)
    elseif self.enemigo.x > self.jugador.x then self.enemigo.x = self.enemigo.x - (self.enemigo.velocidad * dt) end

    if self.enemigo.y < self.jugador.y then self.enemigo.y = self.enemigo.y + (self.enemigo.velocidad * dt)
    elseif self.enemigo.y > self.jugador.y then self.enemigo.y = self.enemigo.y - (self.enemigo.velocidad * dt) end

    -- Actualizar balas
    for i = #self.balas, 1, -1 do
        local b = self.balas[i]
        b.x = b.x + b.vx * dt
        b.y = b.y + b.vy * dt

        if b.x < 0 or b.x > 800 or b.y < 0 or b.y > 600 then
            table.remove(self.balas, i)
        else
            local colisionBalaEnemigo = b.x < self.enemigo.x + self.enemigo.ancho and
                                        b.x + b.radio > self.enemigo.x and
                                        b.y < self.enemigo.y + self.enemigo.alto and
                                        b.y + b.radio > self.enemigo.y
            if colisionBalaEnemigo then
                table.remove(self.balas, i)
                self.enemigo.x = math.random(50, 750)
                self.enemigo.y = math.random(50, 550)
            end
        end
    end

    -- Colisión con coleccionable (Moneda)
    local colisionColeccionable = self.jugador.x < self.coleccionable.x + self.coleccionable.radio and
                                  self.jugador.x + self.jugador.ancho > self.coleccionable.x - self.coleccionable.radio and
                                  self.jugador.y < self.coleccionable.y + self.coleccionable.radio and
                                  self.jugador.y + self.jugador.alto > self.coleccionable.y - self.coleccionable.radio
    if colisionColeccionable then
        self.puntuacion = self.puntuacion + 1
        if self.sonidoCoin then self.sonidoCoin:play() end
        
        if self.puntuacion >= self.objetivoPuntos then
            self.estadoJuego = "ganado"
        else
            self.coleccionable.x = math.random(50, 750)
            self.coleccionable.y = math.random(50, 550)
        end
    end

    -- Colisión con enemigo (Derrota)
    local colisionEnemigo = self.jugador.x < self.enemigo.x + self.enemigo.ancho and
                            self.jugador.x + self.jugador.ancho > self.enemigo.x and
                            self.jugador.y < self.enemigo.y + self.enemigo.alto and
                            self.jugador.y + self.jugador.alto > self.enemigo.y
    if colisionEnemigo then
        self.estadoJuego = "perdido"
    end
end

function Juego:mousepressed(x, y, button)
    if self.estadoJuego == "jugando" and button == 1 then
        if self.sonidoDisparo then
            self.sonidoDisparo:stop()
            self.sonidoDisparo:play()
        end
        local centroX = self.jugador.x + self.jugador.ancho / 2
        local centroY = self.jugador.y + self.jugador.alto / 2
        local angulo = math.atan2(y - centroY, x - centroX)
        table.insert(self.balas, {
            x = centroX, y = centroY,
            vx = math.cos(angulo) * 500,
            vy = math.sin(angulo) * 500,
            radio = 4
        })
    end
end

function Juego:keypressed(key)
    if self.estadoJuego ~= "jugando" and key == "r" then
        self:enter() -- Reinicia el juego si presionas 'R' en pantalla de victoria/derrota
    end
end

function Juego:draw()
    if self.estadoJuego == "jugando" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Puntuación: " .. self.puntuacion .. " / " .. self.objetivoPuntos, 20, 20)

        -- Dibujar jugador
        local escalaX = self.jugador.ancho / self.imagenAvion:getWidth()
        local escalaY = self.jugador.alto / self.imagenAvion:getHeight()
        love.graphics.draw(self.imagenAvion, self.jugador.x, self.jugador.y, 0, escalaX, escalaY)

        -- Dibujar enemigo
        local escalaEnemigoX = self.enemigo.ancho / self.imagenEnemigo:getWidth()
        local escalaEnemigoY = self.enemigo.alto / self.imagenEnemigo:getHeight()
        love.graphics.draw(self.imagenEnemigo, self.enemigo.x, self.enemigo.y, 0, escalaEnemigoX, escalaEnemigoY)

        -- Dibujar balas
        love.graphics.setColor(1, 0, 0)
        for _, b in ipairs(self.balas) do
            love.graphics.circle("fill", b.x, b.y, b.radio)
        end

        -- Dibujar coleccionable
        love.graphics.setColor(0.2, 0.9, 0.3)
        love.graphics.circle("fill", self.coleccionable.x, self.coleccionable.y, self.coleccionable.radio)
        love.graphics.setColor(1, 1, 1)

    elseif self.estadoJuego == "ganado" then
        love.graphics.setColor(0, 1, 0)
        love.graphics.printf("¡HAS GANADO!", 0, 250, 800, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Presiona 'R' para volver a jugar", 0, 300, 800, "center")

    elseif self.estadoJuego == "perdido" then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("¡GAME OVER (DERROTA)!", 0, 250, 800, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Presiona 'R' para reiniciar", 0, 300, 800, "center")
    end
end

return Juego