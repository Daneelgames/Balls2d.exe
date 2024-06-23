sounds = {}
sounds.ui = love.audio.newSource("audio/ui_1.mp3", "static")
sounds.rosePhrase_0 = love.audio.newSource("audio/rosePhrases/rosePhrase_0.mp3", "static")
sounds.rosePhrase_1 = love.audio.newSource("audio/rosePhrases/rosePhrase_1.mp3", "static")
sounds.rosePhrase_2 = love.audio.newSource("audio/rosePhrases/rosePhrase_2.mp3", "static")
sounds.rosePhrase_3 = love.audio.newSource("audio/rosePhrases/rosePhrase_3.mp3", "static")
sounds.rosePhrase_4 = love.audio.newSource("audio/rosePhrases/rosePhrase_4.mp3", "static")
sounds.rosePhrase_5 = love.audio.newSource("audio/rosePhrases/rosePhrase_5.mp3", "static")

sounds.defaultAmbient = love.audio.newSource("audio/Soul Food - Chris Haugen.mp3", "stream")
sounds.defaultAmbient:setVolume(0.5)
sounds.defaultAmbient:setLooping(true)

sounds.reaperAmbient = love.audio.newSource("audio/breathingAmbientMonsterMusic.wav", "stream")
sounds.reaperAmbient:setVolume(1)
sounds.reaperAmbient:setLooping(true)


sounds.textDungeonAmbient = love.audio.newSource("audio/ambient.mp3", "stream")
sounds.textDungeonAmbient:setVolume(0.5)
sounds.textDungeonAmbient:setLooping(true)

local currentMusicAu = sounds.defaultAmbient
currentMusicAu:play()


sounds.shot = love.audio.newSource("audio/stepSmoothReve.wav", "stream")


sounds.damage0 = love.audio.newSource("audio/damage0.wav", "static")
sounds.damage1 = love.audio.newSource("audio/damage1.wav", "static")
sounds.damage2 = love.audio.newSource("audio/damage2.wav", "static")
sounds.damage3 = love.audio.newSource("audio/damage3.wav", "static")
sounds.damage4 = love.audio.newSource("audio/damage4.wav", "static")
sounds.blood = love.audio.newSource("audio/BloodSfx.wav", "static")
sounds.pickup = love.audio.newSource("audio/coinPickup.wav", "static")
sounds.pickup:setVolume(0.3)


function playRosePhrase()
    local tempTable = {}
    table.insert(tempTable, sounds.rosePhrase_0)
    table.insert(tempTable, sounds.rosePhrase_1)
    table.insert(tempTable, sounds.rosePhrase_2)
    table.insert(tempTable, sounds.rosePhrase_3)
    table.insert(tempTable, sounds.rosePhrase_4)
    table.insert(tempTable, sounds.rosePhrase_5)
    local randomSource = tempTable[math.random(1,#tempTable)]
    randomSource:play()
end

function playUi()
    if sounds.ui:isPlaying() then
        sounds.ui:seek(0)
    end
    sounds.ui:play()
end

function playShot()
    if sounds.shot:isPlaying() then
        sounds.shot:seek(0)
    end
    sounds.shot:play()
end

function playPickup()
    if sounds.pickup:isPlaying() then
        sounds.pickup:seek(0)
    end
    sounds.pickup:play()
end


function playDamageSound()
    local tempTable = {}
    table.insert(tempTable, sounds.damage0)
    table.insert(tempTable, sounds.damage1)
    table.insert(tempTable, sounds.damage2)
    table.insert(tempTable, sounds.damage3)
    table.insert(tempTable, sounds.damage4)
    local randomSource = tempTable[math.random(1,#tempTable)]
    randomSource:setVolume(0.3)
    randomSource:play()
end

function playPlayerDamageSound()
    local tempTable = {}
    table.insert(tempTable, sounds.damage0)
    table.insert(tempTable, sounds.damage1)
    table.insert(tempTable, sounds.damage2)
    table.insert(tempTable, sounds.damage3)
    table.insert(tempTable, sounds.damage4)
    local randomSource = tempTable[math.random(1,#tempTable)]
    randomSource:setVolume(0.5)
    randomSource:play()
    sounds.blood:play()
end

function playMusic(music)
    currentMusicAu:stop()
    currentMusicAu = music
    currentMusicAu:play()
end

function resetSounds()
    playMusic(sounds.defaultAmbient)
    sounds.reaperAmbient:stop()
end

function startReaperSound()
    sounds.reaperAmbient:setVolume(0)
    sounds.reaperAmbient:play()
end

function setReaperSoundDistance(distance)
    
    local result = clamp(1 - (distance/love.graphics.getWidth()), 0.01, 1)
    print(result)
    sounds.reaperAmbient:setVolume(result)
    currentMusicAu:setVolume(1-result)
end