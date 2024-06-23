
function newGamePhrase(text, cutsceneTable)
    local newPhrase = {}

    newPhrase.text = text

    if r == nil then
        newPhrase.colorR = 1
    else
        newPhrase.colorR = r
    end
    if g == nil then
        newPhrase.colorG = 0
    else
        newPhrase.colorG = g
    end

    if b == nil then
        newPhrase.colorB = 0
    else
        newPhrase.colorB = b
    end

    if printSymbolCooldown == nil then
        newPhrase.printSymbolCooldown = 0.01
    else
        newPhrase.printSymbolCooldown = printSymbolCooldown
    end

    if cutsceneTable.choices then
        -- pass
    else
        cutsceneTable.choices = {}
    end
    table.insert(cutsceneTable, newPhrase)
end

function newPlayerChoice(text, cutsceneToAdd, cutsceneToPlayOnChoice, randomCutscenesOnChoice)
    local newChoice = {}
    newChoice.colorR = 1
    newChoice.colorG = 1
    newChoice.colorB = 1
    newChoice.text = text
    newChoice.printSymbolCooldown = 0.01
    newChoice.cutsceneToPlayOnChoice = cutsceneToPlayOnChoice
    newChoice.randomCutscenesOnChoice = randomCutscenesOnChoice
    newChoice.passTime = 1
    table.insert(cutsceneToAdd.choices, newChoice)
    return newChoice
end

cutscenes = {}
powerUpCutscenes = {}

local newTempChoice = nil

--  these cutscenes shouldn't be loaded all at once

introCutscene = {}
newGamePhrase("welcome to Balls2D.exe", introCutscene)
newGamePhrase("your job is to mine red balls", introCutscene)
newGamePhrase("red balls will drop yellow balls", introCutscene)
newGamePhrase("land on planets to repair and upgrade", introCutscene)
newGamePhrase("release the controls to land on a planet", introCutscene)
newGamePhrase("it all ends in 300 seconds", introCutscene)
newGamePhrase("good luck, ball", introCutscene)
cutscenes["introCutscene"] = introCutscene

escapeCutscene = {}
newGamePhrase("you want to escape?", escapeCutscene)
newPlayerChoice("yes", escapeCutscene, "exitCutscene")
newPlayerChoice("no", escapeCutscene)
cutscenes["escapeCutscene"] = escapeCutscene

exitCutscene = {}
newGamePhrase("good luck, ball", exitCutscene)
exitCutscene.exit = true
cutscenes["exitCutscene"] = exitCutscene

gameOverCutscene = {}
newGamePhrase("you are dead and red balls will conquer this system now", gameOverCutscene)
gameOverCutscene.showScore = true
cutscenes["gameOverCutscene"] = gameOverCutscene

landedOnPlanetCutscene = {}
newGamePhrase("you landed on a planet", landedOnPlanetCutscene)
newPlayerChoice("repair", landedOnPlanetCutscene, "repairCutscene")
newPlayerChoice("upgrade ship", landedOnPlanetCutscene, "upgradeShipCutscene")
newPlayerChoice("build on planet", landedOnPlanetCutscene, "buildOnPlanetCutscene")
newPlayerChoice("take off", landedOnPlanetCutscene, "takeOffCutscene")

cutscenes["landedOnPlanetCutscene"] = landedOnPlanetCutscene

notEnoughMoneyCutscene = {}
newGamePhrase("your $budget$ is too low", notEnoughMoneyCutscene)
newPlayerChoice("repair", notEnoughMoneyCutscene, "repairCutscene")
newPlayerChoice("upgrade ship", notEnoughMoneyCutscene, "upgradeShipCutscene")
newPlayerChoice("build on planet", notEnoughMoneyCutscene, "buildOnPlanetCutscene")
newPlayerChoice("take off", notEnoughMoneyCutscene, "takeOffCutscene")
cutscenes["notEnoughMoneyCutscene"] = notEnoughMoneyCutscene


repairCutscene = {}
repairCutscene.baseCost = 10
repairCutscene.repairPlayerShip = true
newGamePhrase("ship repaired", repairCutscene)
newPlayerChoice("upgrade ship", repairCutscene, "upgradeShipCutscene")
newPlayerChoice("build on planet", repairCutscene, "buildOnPlanetCutscene")
newPlayerChoice("take off", repairCutscene, "takeOffCutscene")
cutscenes["repairCutscene"] = repairCutscene

upgradeShipCutscene = {}
upgradeShipCutscene.baseCost = 150
upgradeShipCutscene.upgradeShip = true
newGamePhrase("ship upgraded", upgradeShipCutscene)
newPlayerChoice("repair", upgradeShipCutscene, "repairCutscene")
newPlayerChoice("upgrade ship", upgradeShipCutscene, "upgradeShipCutscene")
newPlayerChoice("build on planet", upgradeShipCutscene, "buildOnPlanetCutscene")
newPlayerChoice("take off", upgradeShipCutscene, "takeOffCutscene")
cutscenes["upgradeShipCutscene"] = upgradeShipCutscene

buildOnPlanetCutscene = {}
buildOnPlanetCutscene.baseCost = 50
buildOnPlanetCutscene.buildOnPlanet = true
newGamePhrase("construction started", buildOnPlanetCutscene)
newPlayerChoice("repair", buildOnPlanetCutscene, "repairCutscene")
newPlayerChoice("upgrade ship", buildOnPlanetCutscene, "upgradeShipCutscene")
newPlayerChoice("build on planet", buildOnPlanetCutscene, "buildOnPlanetCutscene")
newPlayerChoice("take off", buildOnPlanetCutscene, "takeOffCutscene")
cutscenes["buildOnPlanetCutscene"] = buildOnPlanetCutscene

takeOffCutscene = {}
takeOffCutscene.takeOff = true
newGamePhrase("good luck, ball", takeOffCutscene)
cutscenes["takeOffCutscene"] = takeOffCutscene

-- POWER UP CUTSCENES 
powerUpFoundCutscene1 = {}
newGamePhrase("you found antient tech", powerUpFoundCutscene1)
newPlayerChoice("improve attack", powerUpFoundCutscene1, nil, {"improveDamageCutscene","improveBulletSpeedCutscene","improveBulletLifetimeCutscene"}) -- отсюда с шансом включение другой катсцены 
newPlayerChoice("improve systems", powerUpFoundCutscene1, nil, {"improveHpCutscene","improveGrabRangeCutscene","improvePlanetPricesCutscene"}) -- отсюда с шансом включение другой катсцены 
cutscenes["powerUpFoundCutscene1"] = powerUpFoundCutscene1
table.insert(powerUpCutscenes, "powerUpFoundCutscene1")

powerUpFoundCutscene2 = {}
newGamePhrase("you found some balls", powerUpFoundCutscene2)
newPlayerChoice("balls", powerUpFoundCutscene2, nil, {"improveDamageCutscene","improveBulletSpeedCutscene","improveBulletLifetimeCutscene", "improveHpCutscene","improveGrabRangeCutscene","improvePlanetPricesCutscene"}) -- отсюда с шансом включение другой катсцены 
cutscenes["powerUpFoundCutscene2"] = powerUpFoundCutscene2
table.insert(powerUpCutscenes, "powerUpFoundCutscene2")

powerUpFoundCutscene3 = {}
newGamePhrase("you found an old dying ball", powerUpFoundCutscene3)
newGamePhrase("he's last will is to teach you something", powerUpFoundCutscene3)
newPlayerChoice("improve movement", powerUpFoundCutscene3, "improveMovementSpeedCutscene")
newPlayerChoice("improve planets guns damage", powerUpFoundCutscene3, "improvePlanetsGunsDamageCutscene")
newPlayerChoice("repair haul", powerUpFoundCutscene3, "repairSingleCutscene")
cutscenes["powerUpFoundCutscene3"] = powerUpFoundCutscene3
table.insert(powerUpCutscenes, "powerUpFoundCutscene3")

-- POWER UP RESULT CUTSCENES

improvePlanetsGunsDamageCutscene = {}
newGamePhrase("planets guns are more powerful now", improvePlanetsGunsDamageCutscene)
improvePlanetsGunsDamageCutscene.improvePlanetsGuns = true
cutscenes["improvePlanetsGunsDamageCutscene"] = improvePlanetsGunsDamageCutscene

repairSingleCutscene = {}
newGamePhrase("ship repaired", repairSingleCutscene)
repairSingleCutscene.repairSingle = true
cutscenes["repairSingleCutscene"] = repairSingleCutscene

improveMovementSpeedCutscene = {}
newGamePhrase("movement speed improved", improveMovementSpeedCutscene)
improveMovementSpeedCutscene.improveMovementSpeed = true
cutscenes["improveMovementSpeedCutscene"] = improveMovementSpeedCutscene


improveDamageCutscene = {}
newGamePhrase("guns damaged improved", improveDamageCutscene)
improveDamageCutscene.improveShipDamage = true
cutscenes["improveDamageCutscene"] = improveDamageCutscene

improveBulletSpeedCutscene = {}
newGamePhrase("bullets speed improved", improveBulletSpeedCutscene)
improveDamageCutscene.improveShipBulletSpeed = true
cutscenes["improveBulletSpeedCutscene"] = improveBulletSpeedCutscene

improveBulletLifetimeCutscene = {} 
newGamePhrase("bullets lifetime improved", improveBulletLifetimeCutscene)
improveDamageCutscene.improveShipBulletLifeTime = true
cutscenes["improveBulletLifetimeCutscene"] = improveBulletLifetimeCutscene

improveHpCutscene = {}
newGamePhrase("ship haul improved", improveHpCutscene)
improveDamageCutscene.improveShipHp = true
cutscenes["improveHpCutscene"] = improveHpCutscene

improveGrabRangeCutscene = {}
newGamePhrase("grab range improved", improveGrabRangeCutscene)
improveDamageCutscene.improveShipGrabRange = true
cutscenes["improveGrabRangeCutscene"] = improveGrabRangeCutscene

improvePlanetPricesCutscene = {} 
newGamePhrase("planets prices improved", improvePlanetPricesCutscene)
improvePlanetPricesCutscene.improvePlanetPrices = true
cutscenes["improvePlanetPricesCutscene"] = improvePlanetPricesCutscene

-- crawlRandomResultCutscene = {}
-- newGamePhrase("you crawl", crawlRandomResultCutscene)
-- newPlayerChoice("crawl", crawlRandomResultCutscene, nil, 
--     {"crawlRandomResultCutscene","crawlRandomResultCutscene","crawlRandomResultCutscene","crawlRandomResultCutscene",
--     "enterNewRoomFromCrawlingCutscene"}) -- отсюда с шансом включение другой катсцены 
-- cutscenes["crawlRandomResultCutscene"] = crawlRandomResultCutscene


-- TEXT  DUNGEON CUTSCENES


dungeonintroCutscene = {}
newGamePhrase("you awake in dark tight shaft", dungeonintroCutscene)
newGamePhrase("what you gonna do?", dungeonintroCutscene)
newPlayerChoice("play dead", dungeonintroCutscene, "playingDeadCutscene")
newPlayerChoice("try to stand up", dungeonintroCutscene, "tryToStandUpCutscene")
dungeonintroCutscene.playMusic = sounds.textDungeonAmbient
cutscenes["dungeonintroCutscene"] = dungeonintroCutscene

playingDeadCutscene ={}
newGamePhrase("all is silent", playingDeadCutscene)
newGamePhrase("you feel the air moving", playingDeadCutscene)
newPlayerChoice("keep playing dead", playingDeadCutscene, "playingDeadCutscene")
newPlayerChoice("try to stand up", playingDeadCutscene, "tryToStandUpCutscene")
cutscenes["playingDeadCutscene"] = playingDeadCutscene

tryToStandUpCutscene = {}
newGamePhrase("your body is a big bag of pain", tryToStandUpCutscene)
newGamePhrase("and you're in a tight shaft, remember?", tryToStandUpCutscene)
newGamePhrase("you can't get up", tryToStandUpCutscene)
newPlayerChoice("crawl", tryToStandUpCutscene, "crawlCutscene")
cutscenes["tryToStandUpCutscene"] = tryToStandUpCutscene

crawlCutscene = {}
newGamePhrase("you crawl", crawlCutscene)
newPlayerChoice("crawl", crawlCutscene, "crawlRandomResultCutscene")
cutscenes["crawlCutscene"] = crawlCutscene

crawlRandomResultCutscene = {}
newGamePhrase("you crawl", crawlRandomResultCutscene)
newPlayerChoice("crawl", crawlRandomResultCutscene, nil, 
    {"crawlRandomResultCutscene","crawlRandomResultCutscene","crawlRandomResultCutscene","crawlRandomResultCutscene",
    "enterNewRoomFromCrawlingCutscene"}) -- отсюда с шансом включение другой катсцены 
cutscenes["crawlRandomResultCutscene"] = crawlRandomResultCutscene

enterNewRoomFromCrawlingCutscene = {}
newGamePhrase("you entered a room", enterNewRoomFromCrawlingCutscene)
newGamePhrase("brown wallpaper looks unfamiliar", enterNewRoomFromCrawlingCutscene)
newGamePhrase("you crawl out from the vent", enterNewRoomFromCrawlingCutscene)
newPlayerChoice("stand up", enterNewRoomFromCrawlingCutscene, "exploredRoomWallsCutscene")
cutscenes["enterNewRoomFromCrawlingCutscene"] = enterNewRoomFromCrawlingCutscene

exploredRoomWallsCutscene = {}
newGamePhrase("now you're standing, barely", exploredRoomWallsCutscene)
newGamePhrase("a lone bulb shimmers hanging under your head", exploredRoomWallsCutscene)
newGamePhrase("the ceiling seems weirdly tall, you can't see it in darkness", exploredRoomWallsCutscene)
newGamePhrase("you feel a cold air coming above", exploredRoomWallsCutscene)
newGamePhrase("other than the vent shaft you came from, the room seems empty", exploredRoomWallsCutscene)
newTempChoice = newPlayerChoice("look around", exploredRoomWallsCutscene, "exploredButFoundNothingCutscene", nil)
newTempChoice.passTime = 3
cutscenes["exploredRoomWallsCutscene"] = exploredRoomWallsCutscene

exploredButFoundNothingCutscene = {}
newGamePhrase("you glazed over the room and found nothing of interest", exploredButFoundNothingCutscene)
newTempChoice = newPlayerChoice("keep searching", exploredButFoundNothingCutscene, nil, 
    {"exploredButFoundNothingCutscene","exploredButFoundNothingCutscene","exploredButFoundNothingCutscene","bodyFallsCutscene"}) -- отсюда с шансом включение другой катсцены 
newTempChoice.passTime = 2
newTempChoice = newPlayerChoice("cry", exploredButFoundNothingCutscene, "criedInEmptyRoomCutscene", nil)
newTempChoice.passTime = 3
newPlayerChoice("crawl back into the vent", exploredButFoundNothingCutscene, "crawlBackIntoVentCutscene")
cutscenes["exploredButFoundNothingCutscene"] = exploredButFoundNothingCutscene


criedInEmptyRoomCutscene = {}
newGamePhrase("you dropped some tears crying", criedInEmptyRoomCutscene)
newGamePhrase("lost some body liquid", criedInEmptyRoomCutscene)
newGamePhrase("you're still in an empty cold room", criedInEmptyRoomCutscene)
newTempChoice = newPlayerChoice("search for something", criedInEmptyRoomCutscene, nil, 
    {"exploredButFoundNothingCutscene","exploredButFoundNothingCutscene","exploredButFoundNothingCutscene","bodyFallsCutscene"}) -- отсюда с шансом включение другой катсцены 
newTempChoice.passTime = 3
newTempChoice = newPlayerChoice("keep crying", criedInEmptyRoomCutscene, nil, {"criedInEmptyRoomCutscene", "bodyFallsCutscene"})
newTempChoice.passTime = 4
newPlayerChoice("crawl back into the vent", criedInEmptyRoomCutscene, "crawlBackIntoVentCutscene")
cutscenes["criedInEmptyRoomCutscene"] = criedInEmptyRoomCutscene

bodyFallsCutscene = {}
newGamePhrase("suddenly a ball falls from darkness above down to your bare balls", bodyFallsCutscene)
newGamePhrase("his ball hard hits the tile floor spilling some blood drop on your ball", bodyFallsCutscene)
newGamePhrase("the dead ball is laying with it ball split producing no sound at all", bodyFallsCutscene)
newPlayerChoice("ask if he is alright", bodyFallsCutscene, "akIfBodyIsAlrightCutscene")
newPlayerChoice("crawl back into the vent", bodyFallsCutscene, nil, {"crawlBackIntoVentCutscene", "bodyGrabsWhileCrawlingBackIntoVentCutscene"})
cutscenes["bodyFallsCutscene"] = bodyFallsCutscene

akIfBodyIsAlrightCutscene = {}
newGamePhrase("you ask the dead ball if he's alright", akIfBodyIsAlrightCutscene)
newGamePhrase("he's dead, can't answer", akIfBodyIsAlrightCutscene)
newPlayerChoice("crawl back into the vent", akIfBodyIsAlrightCutscene, nil, {"crawlBackIntoVentCutscene", "bodyGrabsWhileCrawlingBackIntoVentCutscene"})
cutscenes["akIfBodyIsAlrightCutscene"] = akIfBodyIsAlrightCutscene


crawlBackIntoVentCutscene = {}
newGamePhrase("you assume it's safier to roll back into the shaft", crawlBackIntoVentCutscene)
newPlayerChoice("crawl", crawlBackIntoVentCutscene, nil, 
    {"crawlRandomResultCutscene","crawlRandomResultCutscene","crawlRandomResultCutscene","crawlRandomResultCutscene",
    "enterNewRoomFromCrawlingCutscene"})

cutscenes["crawlBackIntoVentCutscene"] = crawlBackIntoVentCutscene

bodyGrabsWhileCrawlingBackIntoVentCutscene = {}
newGamePhrase("you drop down on your ball knees trying to get into the vent", bodyGrabsWhileCrawlingBackIntoVentCutscene)
newGamePhrase("but ofcourse the dead ball reanimates and grabs your ball", bodyGrabsWhileCrawlingBackIntoVentCutscene)
newGamePhrase("he roars and moans trying to bite you", bodyGrabsWhileCrawlingBackIntoVentCutscene)
newGamePhrase("what you're gonna do?", bodyGrabsWhileCrawlingBackIntoVentCutscene)
newPlayerChoice("cry", bodyGrabsWhileCrawlingBackIntoVentCutscene, "finalCryCutscene")

cutscenes["bodyGrabsWhileCrawlingBackIntoVentCutscene"] = bodyGrabsWhileCrawlingBackIntoVentCutscene


finalCryCutscene = {}
newGamePhrase("you cried your final cry", finalCryCutscene)
newGamePhrase("cadaver rumbles: THANK YOU", finalCryCutscene)
newGamePhrase("THANK YOU FOR PLAYING Balls2D.exe by MRPINK GAMES", finalCryCutscene)
newPlayerChoice("wtf???", finalCryCutscene, "exitCutscene")

cutscenes["finalCryCutscene"] = finalCryCutscene