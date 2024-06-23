require 'shader'
require 'utils'
require 'gameRendering'
require 'background'
require 'textBox'
require 'audio'
require 'cutscenes'

targetedAsteroids = {}
gameTimer = 0 

difficultyScaler = 0.33

shipRadius = 15
aimRadius = 30
grabDistance = 128
pickupsGrabSpeed = 100
playerHp = 5
playerHpCurrent = playerHp
playerDamageCooldown = 1
playerDamageCooldownCurrent = playerDamageCooldown

planetPricesScaler = 1
shipSpeedDefault = 40
shipSpeedClampScalerDefault = 5
shipSpeedClampScaler = shipSpeedClampScalerDefault
shipSpeed = shipSpeedDefault

landingTime = 3
landingTimeCurrent = 0
playerIsLandedOnPlanet = false
reaperMob = nil
vignette = nil

local asteroidSpawnCooldown = 5
local asteroidSpawnCooldownCurrent = asteroidSpawnCooldown

local powerupsSpawnCooldown = 1
local powerupsSpawnCooldownCurrent = powerupsSpawnCooldown

local repairsInMinute = 0
local repairsInMinuteCooldown = 0

asteroids = {}
function onResize(w,h)
    arenaWidth = w
    arenaHeight = h
end

function love.resize(w, h)
    onResize(w,h)
end

function love.load()
	love.window.setMode(1280, 720, {resizable=true, vsync=0, minwidth=400, minheight=300})
    onResize(love.graphics.getWidth(), love.graphics.getHeight())
    
    local targetX = nil
    local targetY = nil 
    local touchmove = false

	love.graphics.setDefaultFilter( "nearest", "nearest", 1 )


    bulletTimerLimit = 0.2
    bulletRadius = 5

    pickupRadius = 7

    asteroidStages = {
        {
            speed = 80,
            radius = 10,
        },
        {
            speed = 60,
            radius = 15,
        },
        {
            speed = 40,
            radius = 20,
        },
        {
            speed = 20,
            radius = 30,
        },
    }


    planetStages = {
        {
            speed = 10,
            radius = 60,
        },
        {
            speed = 7,
            radius = 70,
        },
        {
            speed = 4,
            radius = 80,
        },
        {
            speed = 2,
            radius = 90,
        },
    }

    reset()
    fillPowerupCutscenes()
end

function love.update(dt)
    updateBackground(dt)
    updateShader(dt)

    updateEffects(dt)

    if playerIsLandedOnPlanet or isTextBoxVisible then
        updateTextBox(dt)
        return
    end
    if repairsInMinuteCooldown < 60 then
        repairsInMinuteCooldown = repairsInMinuteCooldown + dt
    else
        repairsInMinute = 0
        repairsInMinuteCooldown = 0
    end

    gameTimer = gameTimer + dt
    if reaperMob == nil and gameTimer > 100 then
        spawnReaper()
    end

    if vignette == nil and gameTimer > .1 then
        vignette = true
    end
    if spawnedPowerUp == nil then
        powerupsSpawnCooldownCurrent = powerupsSpawnCooldownCurrent - dt
        if powerupsSpawnCooldownCurrent < 0 then
            powerupsSpawnCooldownCurrent = powerupsSpawnCooldown
            spawnNewPowerUp()
        end
    end

    asteroidSpawnCooldownCurrent = asteroidSpawnCooldownCurrent - dt * ((playerLevel + planetsLevel)* (difficultyScaler))
    if asteroidSpawnCooldownCurrent < 0 then
        asteroidSpawnCooldownCurrent = asteroidSpawnCooldown
        spawnNewAsteroid()
    end

    if playerDamageCooldownCurrent > 0 then
        playerDamageCooldownCurrent = playerDamageCooldownCurrent - dt
    end

    local turnSpeed = 10

    targetedAsteroids = {}
    touchmove = false 

    if love.mouse.isDown(1) or  love.mouse.isDown(2) then
        touchmove = true
        targetX, targetY = love.mouse.getPosition()
    end


    for g, gun in ipairs(playerGuns) do
        if gun.shotCooldownCurrent > 0 then
            gun.shotCooldownCurrent = gun.shotCooldownCurrent - dt
        end
    end

    local touches = love.touch.getTouches()
    for i, id in ipairs(touches) do
        local x, y = love.touch.getPosition(id)
        if i ==1 then 
            targetX = x
            targetY = y
            touchmove = true
        end 
    end

    -- PLAYER MOVEMENT SPEED CHANGE
    if touchmove then
        angle = math.atan2(targetY -shipY , targetX- shipX )
        cos = math.cos(angle)
        sin = math.sin(angle)

        shipAngle = angle

        local distance = distance(shipX, shipY, targetX, targetY)
        local resultShipSpeed = shipSpeed * (distance / (shipRadius * 5))

        shipSpeedX = clamp(shipSpeedX + math.cos(shipAngle) * resultShipSpeed * dt, -shipSpeed * shipSpeedClampScaler, shipSpeed * shipSpeedClampScaler)
        shipSpeedY = clamp(shipSpeedY + math.sin(shipAngle) * resultShipSpeed * dt, -shipSpeed * shipSpeedClampScaler, shipSpeed * shipSpeedClampScaler)
    end

    -- PLANETS
    playerLandingOnPlanet = nil
    local planetsBouncedOff = {}
    for i, planet in ipairs(planets) do
        planet.x = (planet.x + math.cos(planet.angle) * planetStages[planet.stage].speed * dt) % arenaWidth
        planet.y = (planet.y + math.sin(planet.angle) * planetStages[planet.stage].speed * dt) % arenaHeight
        
        if touchmove == false and playerLandingOnPlanet == null then
            if areCirclesIntersecting(shipX, shipY, shipRadius, planet.x, planet.y, planetStages[planet.stage].radius) then
                -- LANDING ON PLANET
                playerLandingOnPlanet = planet
            end
        end

        for p, planetB in ipairs(planets) do
            if planetb ~= planet then
                local didBounced = false
                for b, bounced in ipairs(planetsBouncedOff) do
                    if bounced == planet or bounced == planetB then
                        didBounced = true
                        break
                    end
                end
                if didBounced == false then
                    if areCirclesIntersecting(planet.x, planet.y, planetStages[planet.stage].radius, planetB.x, planetB.y, planetStages[planetB.stage].radius) then
                        table.insert(planetsBouncedOff, planet)
                        planet.angle = planet.angle * -1
                        planetB.angle = planetB.angle * -1
                        table.insert(planetsBouncedOff, planet)
                        table.insert(planetsBouncedOff, planetB)
                    end
                end
            end
        end

        -- PLANET GUNS
        if planet.guns then
            for g, gun in ipairs(planet.guns) do
                if gun.shotCooldownCurrent < 0 then 
                    -- PLANET GUN TRY SHOOT
                    gun.shotCooldownCurrent = gun.shotCooldown

                    local tmp = {}
                    for i, asteroid in ipairs(asteroids) do
                        if areCirclesIntersecting(asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius, planet.x, planet.y, gun.shotDistance) then
                            table.insert(tmp, asteroid)
                        end
                    end
                    
                    if #tmp > 0 then
                        local randomTarget = tmp[love.math.random(1,#tmp)]
                        planetTryShot(randomTarget.x, randomTarget.y, planet, gun)
                    end
                else
                    gun.shotCooldownCurrent = gun.shotCooldownCurrent - dt
                end
            end
        end
    end

    if playerLandingOnPlanet then
        landingTimeCurrent = landingTimeCurrent + dt 
        if landingTimeCurrent >= landingTime * difficultyScaler then
            -- LANDED ON PLANET
            playerIsLandedOnPlanet = true
            landingTimeCurrent = 0
            playCutscene("landedOnPlanetCutscene")
        end

        -- PLAYER MOVEMENT LAND ON PLANET MAGNIT
        local dx, dy = directionTo(playerLandingOnPlanet.x, playerLandingOnPlanet.y, shipX, shipY)
        if shipSpeedX > shipSpeed * 0.1 then 
            shipSpeedX = shipSpeedX - shipSpeed * dt * 10
        elseif shipSpeedX < shipSpeed * 0.1 then 
            shipSpeedX = shipSpeedX + shipSpeed * dt * 10
        end
        if shipSpeedY > shipSpeed * 0.1 then 
            shipSpeedY = shipSpeedY - shipSpeed * dt * 10
        elseif shipSpeedY < shipSpeed * 0.1 then 
            shipSpeedY = shipSpeedY + shipSpeed * dt * 10
        end

        shipX = (shipX + dx * shipSpeed * dt) % arenaWidth
        shipY = (shipY  + dy * shipSpeed * dt) % arenaHeight
    else
        -- PLAYER MOVEMENT
        landingTimeCurrent = 0

        shipX = (shipX + shipSpeedX * dt) % arenaWidth
        shipY = (shipY + shipSpeedY * dt) % arenaHeight
    end

    -- REAPER MOB
    if reaperMob then
        local dx, dy = directionTo(shipX, shipY, reaperMob.x, reaperMob.y)
        reaperMob.x = reaperMob.x + dx * reaperMob.speed * dt
        reaperMob.y = reaperMob.y + dy * reaperMob.speed * dt
        
        if areCirclesIntersecting(reaperMob.x, reaperMob.y, 32, shipX, shipY, shipRadius) then
            damagePlayer()
        end

        setReaperSoundDistance(distance(reaperMob.x, reaperMob.y, shipX, shipY))
    end


    for bulletIndex = #bullets, 1, -1 do
        local bullet = bullets[bulletIndex]

        bullet.timeLeft = bullet.timeLeft - dt
        if bullet.timeLeft <= 0 then
            table.remove(bullets, bulletIndex)
        else
            bullet.x = (bullet.x + math.cos(bullet.angle) * bullet.speed * dt)
                % arenaWidth
            bullet.y = (bullet.y + math.sin(bullet.angle) * bullet.speed * dt)
                % arenaHeight

            for asteroidIndex = #asteroids, 1, -1 do
                local asteroid = asteroids[asteroidIndex]
                
                --  IF BULLET HIT
                if areCirclesIntersecting(
                    bullet.x, bullet.y, bulletRadius,
                    asteroid.x, asteroid.y,
                    asteroidStages[asteroid.stage].radius
                ) then
                    asteroid.hp = asteroid.hp - 1
                    newDamageEffect(bullet.x, bullet.y)
                    playDamageSound()
                    table.remove(bullets, bulletIndex)

                    if asteroid.hp <= 0 then
                        --  KILL ASTEROID
                        -- destroy asteroid
                        if asteroid.stage > 1 then
                            local angle1 = love.math.random() * (2 * math.pi)
                            local angle2 = (angle1 - math.pi) % (2 * math.pi)
                            spawnNewAsteroid(asteroid.x,asteroid.y, angle1, asteroid.stage-1)
                            spawnNewAsteroid(asteroid.x,asteroid.y, angle2, asteroid.stage-1)
                        end

                        spawnPickup(asteroid.x, asteroid.y)
                        table.remove(asteroids, asteroidIndex)
                    end
                    break
                end
            end
        end
    end

    bulletTimer = bulletTimer + dt

    currentBigAsteroids = {}
    
    -- ASTEROIDS
    for asteroidIndex, asteroid in ipairs(asteroids) do
        asteroid.x = (asteroid.x + math.cos(asteroid.angle) * asteroidStages[asteroid.stage].speed * dt) % arenaWidth
        asteroid.y = (asteroid.y + math.sin(asteroid.angle) * asteroidStages[asteroid.stage].speed * dt) % arenaHeight
				
        if asteroid.stage == #asteroidStages then -- biggest
            table.insert(currentBigAsteroids, asteroid)
            for p = #pickups, 1, -1 do
                local pickup = pickups[p]
                if areCirclesIntersecting(asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius, pickup.x, pickup.y, pickupRadius) then
                    table.remove(pickups, p)
                end
            end
        end

        -- SHOOTING ASTEROIDS
        if touchmove and areCirclesIntersecting(
            targetX, targetY, aimRadius,
            asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius)
        then
            table.insert(targetedAsteroids,asteroid)
            for g, gun in ipairs(playerGuns) do
                if gun.shotCooldownCurrent <= 0 then
                    gun.shotCooldownCurrent = gun.shotCooldown
                    tryShot(targetX, targetY, gun)
                end
            end
            shotSelectedManual = true
        end
        if asteroid.hp > 5 then
            if asteroid.shootCooldown == nil then
                asteroid.shootCooldown = asteroid.hp
                asteroid.shootCooldownCurrent = asteroid.shootCooldown
            end
            if asteroid.shootCooldownCurrent > 0 then
                asteroid.shootCooldownCurrent = asteroid.shootCooldownCurrent - dt
            else
                asteroid.shootCooldownCurrent = asteroid.shootCooldown
                spawnNewAsteroid(asteroid.x, asteroid.y, nil, clamp(asteroid.stage - 1, 1, #asteroidStages))
            end

        end
        
        --  PLAYER CRASHED INTO ASTEROID, BREAK
        if areCirclesIntersecting(shipX, shipY, shipRadius,asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius) then
            -- DONT DAMAGE IF ASTEROID IS TARGETED
            -- local isTargeted = false
            -- for t, targeted in ipairs(targetedAsteroids) do
            --     if targeted == asteroid then
            --         isTargeted = true
            --         break
            --     end
            -- end

            if isTargeted then
                shipSpeedX = shipSpeedX * -0.9
                shipSpeedY = shipSpeedY * -0.9
                playerDamageCooldownCurrent = playerDamageCooldown * 0.3

            else
                damagePlayer()
            end
        end
    end



    -- PICKUPS
    for i = #pickups, 1, -1 do
        --  PICKUP INTO GRAB RADIUS
        local pickup = pickups[i]
        if areCirclesIntersecting(shipX, shipY, grabDistance ,pickup.x, pickup.y, pickupRadius) then
            local dx, dy = directionTo(shipX, shipY, pickup.x, pickup.y)
            if distance(shipX, shipY, pickup.x, pickup.y) < pickupRadius then
                -- PICK UP PICKUP
                addPickupToPlayer()
                playPickup()
                table.remove(pickups, i)
            else
                pickup.x = (pickup.x + dx * pickupsGrabSpeed * dt) % arenaWidth
                pickup.y = (pickup.y + dy * pickupsGrabSpeed * dt) % arenaHeight
            end
        else
            pickup.x = (pickup.x + math.cos(pickup.angle) * pickup.speed * dt) % arenaWidth
            pickup.y = (pickup.y + math.sin(pickup.angle) * pickup.speed * dt) % arenaHeight
        end
    end

    if spawnedPowerUp then
        if areCirclesIntersecting(shipX, shipY, shipRadius, spawnedPowerUp.x, spawnedPowerUp.y, shipRadius) then
            spawnedPowerUp = nil
            getRandomPowerUp()
        end
    end


    -- if #asteroids == 0 then
    --     reset()
    -- end
end

function love.draw()
    renderGame()
end

function reset()
    shipX = arenaWidth / 2
    shipY = arenaHeight / 2
    shipAngle = 0
    shipSpeedX = love.math.random(-1, 1) * 50
    shipSpeedY = love.math.random(-1, 1) * 50

    vignette = nil

    playerLevel = 1
    playerGuns = {}
    reaperMob = nil
    -- STARTING GUN
    local startGun = {}
    startGun.bulletLifeTime = 2
    startGun.shotCooldown = 0.2
    startGun.shotCooldownCurrent = startGun.shotCooldown
    startGun.bulletSpeed = 400
    startGun.damage = 1
    table.insert(playerGuns, startGun)
    powerupsSpawnCooldownCurrent = 0
    gold = 0
    pickups = {}
    bullets = {}
    bulletTimer = bulletTimerLimit
    grabDistance = 128
    planetPricesScaler = 1
    shiSpeedClampScaler = shipSpeedClampScalerDefault
    repairsInMinute = 0
    reaperMob = nil
    shipSpeed = shipSpeedDefault
    playerHp = 5
    playerHpCurrent = playerHp
    playerDamageCooldownCurrent = playerDamageCooldown
    currentBigAsteroids = {}
    fillPowerupCutscenes()
    asteroids = {}
    spawnNewAsteroid()
    spawnNewAsteroid()
    spawnNewAsteroid()
    resetSounds()

    planets = {
        {
            x = math.random(1,arenaWidth),
            y = math.random(1,arenaHeight),
            angle = love.math.random() * (2 * math.pi),
            stage = love.math.random(1, #planetStages),
            level = 1,
        },
        {
            x = math.random(1,arenaWidth),
            y = math.random(1,arenaHeight),
            angle = love.math.random() * (2 * math.pi),
            stage = love.math.random(1, #planetStages),
            level = 1,
        },
        {
            x = math.random(1,arenaWidth),
            y = math.random(1,arenaHeight),
            angle = love.math.random() * (2 * math.pi),
            stage = love.math.random(1, #planetStages),
            level = 1,
        }
    }
    planetsLevel = #planets
    for p, planet in ipairs(planets) do
        buildOnPlanet(planet)
    end
    
    targetedAsteroids = {}
    gameTimer = 0
    playCutscene("introCutscene")
end

function spawnNewAsteroid(_x, _y, angle, stage)
    if #asteroids > clamp(gameTimer, 10, 300) then
        return
    end
    local x = 0
    local y = 0

    if _x then
        x = _x
    else
        if shipX < arenaWidth/2 then
            x = love.math.random(arenaWidth * 0.6, arenaWidth * 0.8)
        else
            x = love.math.random(arenaWidth * 0.2, arenaWidth * 0.4)
        end
    end

    if _y then
        y = _y
    else
        if shipY < arenaHeight/2 then
            y = love.math.random(arenaHeight * 0.6, arenaHeight * 0.8)
        else
            y = love.math.random(arenaHeight * 0.2, arenaHeight * 0.4)
        end
    end
    
    local newAsteroid = {}
    newAsteroid.x = x
    newAsteroid.y = y

    if angle then
        newAsteroid.angle = angle
    else
        newAsteroid.angle = love.math.random() * (2 * math.pi)
    end
    if stage then
        newAsteroid.stage = stage
    else
        newAsteroid.stage = #asteroidStages
    end
    
    local timerHp = (1 + math.ceil(gameTimer / 10) )* difficultyScaler
    local stageFromLast = clamp(#asteroidStages - newAsteroid.stage, 1, #asteroidStages)
    newAsteroid.hp = timerHp / stageFromLast

    table.insert(asteroids, newAsteroid)

end

function spawnPickup(x,y)
    local newPickup = {}
    newPickup.x = x
    newPickup.y = y
    newPickup.angle = love.math.random() * (2 * math.pi)
    newPickup.speed = love.math.random(5,20)
    table.insert(pickups, newPickup)
end

-- spawn Shot
function tryShot(_x, _y, gun)
    -- if bulletTimer >= bulletTimerLimit then
        -- bulletTimer = 0
        playShot()
        _x = _x + love.math.random(-8,8)
        _y = _y + love.math.random(-8,8)

        table.insert(bullets, {x = shipX + math.cos(shipAngle) * shipRadius, y = shipY + math.sin(shipAngle) * shipRadius, angle = math.atan2(_y -shipY , _x - shipX ),
          speed = gun.bulletSpeed,
            timeLeft = gun.bulletLifeTime,
        })
    -- end
end

function planetTryShot(_x, _y, planet, gun)
    -- if bulletTimer >= bulletTimerLimit then
        -- bulletTimer = 0
        table.insert(bullets, {x = planet.x, y = planet.y, angle = math.atan2(_y - planet.y , _x - planet.x ),
           speed = gun.bulletSpeed,
            timeLeft = gun.bulletLifeTime,
        })
    -- end
end

function addPickupToPlayer()
    gold = gold + 1
end


function love.touchpressed(id,x,y,dx,dy,pres)
	textBoxTouched(id,x,y)
--   playerInventoryKeyPressed('return')
end

function love.mousepressed(x, y, button, isTouch)
	textBoxTouched(button,x,y)
--   playerInventoryKeyPressed('return')т 
end

function love.keypressed(key)
    if key == "escape" and isTextBoxVisible == false then
        playCutscene("escapeCutscene")
    end
end

function buildOnPlanet(planet)
    if planet.guns == nil then
        planet.guns = {}
    end
    planetsLevel = planetsLevel + 1

    local newGun = {}
    newGun.damage = 1
    newGun.bulletLifeTime = love.math.random(0.75, 4)
    newGun.shotCooldown = love.math.random(0.3, 0.75)
    newGun.shotCooldownCurrent = newGun.shotCooldown
    newGun.bulletSpeed = love.math.random(300,900)
    newGun.shotDistance = love.math.random(planetStages[planet.stage].radius * 2, planetStages[planet.stage].radius * 8.0)
    table.insert(planet.guns, newGun)
end

function upgradePlayerShip()
    playerLevel = playerLevel + 1

    if playerGuns == nil then
        playerGuns = {}
    end

    local newGun = {}
    newGun.damage = 1
    newGun.bulletLifeTime = love.math.random(1, 4)
    newGun.shotCooldown = love.math.random(0.2, 0.6)
    newGun.shotCooldownCurrent = newGun.shotCooldown
    newGun.bulletSpeed = love.math.random(300,1000)
    table.insert(playerGuns, newGun)
end

function damagePlayer()
    if playerDamageCooldownCurrent <= 0 then
        shipSpeedX = shipSpeedX * -0.9
        shipSpeedY = shipSpeedY * -0.9
        playerDamageCooldownCurrent = playerDamageCooldown
        playerHpCurrent = playerHpCurrent - 1

        newDamageEffect(shipX, shipY, 32)
        playPlayerDamageSound()
        if playerHpCurrent < 1 then

            if gameTimer < 300 then
                playCutscene("gameOverCutscene")
            else
                playCutscene("dungeonintroCutscene")
                -- playCutscene("finalCryCutscene")
                
            end
        end
    end
end
function spawnNewPowerUp()
    spawnedPowerUp = {}
    
    if shipX < arenaWidth/2 then
        spawnedPowerUp.x = love.math.random(arenaWidth * 0.55, arenaWidth * 0.9)
    else
        spawnedPowerUp.x = love.math.random(arenaWidth * 0.1, arenaWidth * 0.45)
    end

    if shipY < arenaHeight/2 then
        spawnedPowerUp.y = love.math.random(arenaHeight * 0.55, arenaHeight * 0.9)
    else
        spawnedPowerUp.y = love.math.random(arenaHeight * 0.1, arenaHeight * 0.45)
    end
    
    spawnedPowerUp.angle = love.math.random() * (2 * math.pi)
    spawnedPowerUp.speed = love.math.random(5,20)
end

function fillPowerupCutscenes()
    currentPowerUpCutscenesList = {}
    for i = 1, #powerUpCutscenes, 1 do
        local cutscene = powerUpCutscenes[i]
        table.insert(currentPowerUpCutscenesList, cutscene)
    end
    -- print("fill ".. #currentPowerUpCutscenesList)
end

function getRandomPowerUp()
    local ccc = currentPowerUpCutscenesList[math.random(1, #currentPowerUpCutscenesList)]
    -- print("powerup " .. ccc)

    local playingCutscene = playCutscene(ccc)
    
    for cs, cutscene in ipairs(currentPowerUpCutscenesList) do
        if cutscene == playingCutscene then
            table.remove(currentPowerUpCutscenesList, cs)
            break
        end
    end

    if #currentPowerUpCutscenesList < 1 then
        fillPowerupCutscenes()
    end
end


function playerRepairedOnPlanet()
    -- repairsInMinute = repairsInMinute + 1
    -- print("playerRepairedOnPlanet " .. repairsInMinute .. "; time " .. repairsInMinuteCooldown)
    -- if repairsInMinute > 3 then
    --     spawnReaper()
    -- end
end

function spawnReaper() 
    if reaperMob == nil then
        startReaperSound()
        reaperMob = {}
        if shipX < arenaWidth/2 then
            reaperMob.x = love.math.random(arenaWidth * 0.6, arenaWidth * 0.8)
        else
            reaperMob.x = love.math.random(arenaWidth * 0.2, arenaWidth * 0.4)
        end
        if shipY < arenaHeight/2 then
            reaperMob.y = love.math.random(arenaHeight * 0.6, arenaHeight * 0.8)
        else
            reaperMob.y = love.math.random(arenaHeight * 0.2, arenaHeight * 0.4)
        end
        reaperMob.speed = 20
    end
end