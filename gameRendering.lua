
reaperMobSprite = love.graphics.newImage('sprites/reaper.png')

textFont = love.graphics.newFont(30)
landingFont = love.graphics.newFont(16)
outlineFont = love.graphics.newFont(35)

damageEffects = {}

function renderGame()
    backgroundShaderStart()
    drawBackground()
    textShaderStart()

    for y = -1, 1 do
        for x = -1, 1 do
            love.graphics.origin()
            love.graphics.translate(x * arenaWidth, y * arenaHeight)

            for i, planet in ipairs(planets) do
                love.graphics.setColor(0, .05, .1)
                love.graphics.circle('fill', planet.x, planet.y,planetStages[planet.stage].radius * 1.1)
                love.graphics.setColor(0, .2, .3)
                love.graphics.circle('fill', planet.x, planet.y,planetStages[planet.stage].radius)
                love.graphics.setColor(0.0, .3, .5)
                love.graphics.printf("LVL " .. planet.level, planet.x - planetStages[planet.stage].radius, planet.y, 128, 'center')
            end

            if playerLandingOnPlanet then
                love.graphics.setColor(1.0, 1, 1)
                love.graphics.setFont(landingFont)
                love.graphics.printf("LANDING: " .. math.floor((landingTimeCurrent / (landingTime * difficultyScaler)) * 10)/10, shipX - 64, shipY + 16, 128, 'center')
            end

            love.graphics.setColor(1, 1, 0)
            for i, pickup in ipairs(pickups) do
                love.graphics.circle('fill', pickup.x, pickup.y, pickupRadius)
            end

            if spawnedPowerUp then
                love.graphics.setFont(outlineFont)
                love.graphics.print("?", spawnedPowerUp.x - 8, spawnedPowerUp.y - 8)
            end


            for asteroidIndex, asteroid in ipairs(asteroids) do
                love.graphics.setColor(0.5, 0, 0)
                love.graphics.circle('fill', asteroid.x, asteroid.y,asteroidStages[asteroid.stage].radius)
                love.graphics.setColor(0, 0, 0)
                love.graphics.setFont(landingFont)
                love.graphics.print(math.ceil(asteroid.hp), asteroid.x - asteroidStages[asteroid.stage].radius * 0.5, asteroid.y - asteroidStages[asteroid.stage].radius * 0.5)
            end

            love.graphics.setColor(1, 1, 1)
            for bulletIndex, bullet in ipairs(bullets) do
                love.graphics.circle('fill', bullet.x, bullet.y, bulletRadius)
            end

            if reaperMob then
                if reaperMob.x < shipX then
                    love.graphics.draw(reaperMobSprite, reaperMob.x - 16, reaperMob.y - 16)
                else
                    love.graphics.draw(reaperMobSprite, reaperMob.x - -8, reaperMob.y- 16,  nil, -1, 1)
                end
            end

            love.graphics.setColor(1, 0, 0)
            for i, asteroid in ipairs(targetedAsteroids) do
                love.graphics.circle('line', asteroid.x , asteroid.y, asteroidStages[asteroid.stage].radius*1.2)
            end
            -- love.graphics.print(love.timer.getFPS(), 5, 50)
            love.graphics.print(math.ceil(gameTimer * 100) / 100, 5, 20)
                        
            love.graphics.setColor(0, 0, 0)
            love.graphics.setFont(outlineFont)
            love.graphics.print("$"..gold, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.1)
            
            love.graphics.setColor(1, 1, 0)
            love.graphics.setFont(textFont)
            love.graphics.print("$"..gold, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.1)

            if touchmove and targetX and targetY then
                love.graphics.setColor(1, 1, 1)
                love.graphics.circle("fill", targetX, targetY, 5)
                if #targetedAsteroids > 0 then
                    love.graphics.setColor(1,0,0)
                else
                    love.graphics.setColor(1,1,1)
                end
                love.graphics.line(shipX, shipY, targetX, targetY)
            end


            love.graphics.setColor(1, 1, 1)
            love.graphics.circle('fill', shipX, shipY, shipRadius)

            local shipCircleDistance = 15
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle('fill',shipX + math.cos(shipAngle) * shipCircleDistance,shipY + math.sin(shipAngle) * shipCircleDistance,5)

            love.graphics.setColor(1, 0, 0)
            love.graphics.setFont(landingFont)
            love.graphics.print(playerHpCurrent, shipX - shipRadius/2, shipY - shipRadius)

            drawDamageEffects()

            drawTextBox()
        end
    end
    textShaderEnd()
end

function updateEffects(dt)
    for i = #damageEffects, 1, -1 do
        local effect = damageEffects[i]
        if effect.lifetime > 0 then
            effect.lifetime = effect.lifetime - dt
        else
            table.remove(damageEffects, i)
        end
    end
end

function newDamageEffect(x,y, sizeOverride)
    local newEffect = {}
    newEffect.x = x
    newEffect.y = y
    newEffect.lifetime = 0.1
    if sizeOverride == nil then
        newEffect.sizeOverride = 16
    else
        newEffect.sizeOverride = sizeOverride
    end
    table.insert(damageEffects, newEffect)
end

function drawDamageEffects()
    love.graphics.setColor(1, 1,1)
    for i = #damageEffects, 1, -1 do
        local effect = damageEffects[i]
        love.graphics.circle("fill", effect.x, effect.y, effect.sizeOverride, 16)
    end
end