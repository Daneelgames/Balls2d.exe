isTextBoxVisible = false

showingDot = false
dotSwitchCooldown = 0.5
currentPrintSymbolCooldown = 0
currentPlayingCutscene = nil
currentCutscenePhraseIndex = 1

gameTextVerticalScaler = 0.48

textBox = {}
textBox.text = ""
textBox.x = 0
textBox.y = 0
textBox.colorR = 1
textBox.colorG = 1
textBox.colorB = 1
textBox.visibleSymbols = 0
textBox.printSymbolCooldown = 0.1

selectedChoiceIndex = 1
isShowingChoices = false


function updateTextBox(dt)
    if dotSwitchCooldown > 0 then
        dotSwitchCooldown = dotSwitchCooldown - dt
    end
    if dotSwitchCooldown < 0 then
        dotSwitchCooldown = 0.5
        if showingDot then
            showingDot = false
        else
            showingDot = true
        end
    end

    if currentPrintSymbolCooldown > 0 then
        currentPrintSymbolCooldown = currentPrintSymbolCooldown - dt
    elseif isTextBoxVisible and textBox.visibleSymbols < #textBox.text + 1 then
        textBox.visibleSymbols =  textBox.visibleSymbols + dt * 200
        currentPrintSymbolCooldown = textBox.printSymbolCooldown
        playRosePhrase()
    end
end

function tryAdvancingTextBox(closestChoiceIndex)
    if textBox.visibleSymbols < #textBox.text + 1 then
        textBox.visibleSymbols = #textBox.text 
        return
    end
    currentCutscenePhraseIndex = currentCutscenePhraseIndex + 1


    if currentPlayingCutscene == nil or currentCutscenePhraseIndex > #currentPlayingCutscene then
				
        hideTextBox()
        
        -- CHOICE
        if closestChoiceIndex and isShowingChoices and #currentPlayingCutscene.choices > 0 then
            local resultCutscene = randomCs
            if currentPlayingCutscene.choices[closestChoiceIndex].cutsceneToPlayOnChoice then
                -- passTime(currentPlayingCutscene.choices[closestChoiceIndex].passTime)
                resultCutscene = currentPlayingCutscene.choices[closestChoiceIndex].cutsceneToPlayOnChoice
            elseif currentPlayingCutscene.choices[closestChoiceIndex].randomCutscenesOnChoice then
                local finalChoice = currentPlayingCutscene.choices[closestChoiceIndex]
                local randomCs = finalChoice.randomCutscenesOnChoice[love.math.random(1, #currentPlayingCutscene.choices[closestChoiceIndex].randomCutscenesOnChoice)]
                
                -- passTime(finalChoice.passTime)
                resultCutscene = randomCs
            end
            if resultCutscene then
                if cutscenes[resultCutscene].baseCost and playerLandingOnPlanet then
                    if math.ceil(cutscenes[resultCutscene].baseCost * planetPricesScaler * (playerLandingOnPlanet.level * difficultyScaler)) > gold then
                        resultCutscene = "notEnoughMoneyCutscene"
                    else
                        gold = gold - math.ceil(cutscenes[resultCutscene].baseCost * planetPricesScaler * (playerLandingOnPlanet.level * difficultyScaler))
                    end
                end
                
                playCutscene(resultCutscene)
            end
        else
            currentPlayingCutscene = nil
            currentCutscenePhraseIndex = 1
        end
    else    
        local phrase = currentPlayingCutscene[currentCutscenePhraseIndex]
        showTextBox(phrase.text, 10 , love.graphics.getHeight()*gameTextVerticalScaler, phrase.colorR,phrase.colorG,phrase.colorB, phrase.printSymbolCooldown)
    end
end

function playCutsceneDirect(cutscene)
	choices = {}
	currentPlayingCutscene = cutscene
	currentCutscenePhraseIndex = 1
	local phrase = currentPlayingCutscene[currentCutscenePhraseIndex]
	selectedChoiceIndex = 1
    local resultPhrase = phrase.text

    if currentPlayingCutscene then
        -- CUTSCENE RESULTS
        if currentPlayingCutscene.exit then
            love.event.quit()
        elseif currentPlayingCutscene.showScore then
            resultPhrase = resultPhrase .. ". Time survived:" .. math.ceil(gameTimer * 100) / 100 .. ". Ship Level: " .. playerLevel .. ". Planets level: " .. planetsLevel
            reset()
        elseif currentPlayingCutscene.improveManuverability then
            shipSpeedClampScaler = clamp(shipSpeedClampScaler - 0.3, 1, shipSpeedClampScalerDefault)
            playerLevel = playerLevel + 1
        elseif currentPlayingCutscene.improveMovementSpeed then
            shipSpeed = shipSpeed + shipSpeed * 0.25
            playerLevel = playerLevel + 1
        elseif currentPlayingCutscene.improveShipDamage then
            for g, gun in ipairs(playerGuns) do
                gun.damage = gun.damage + gun.damage * 0.5
            end
            playerLevel = playerLevel + 1
        elseif currentPlayingCutscene.improveShipBulletSpeed then
            for g, gun in ipairs(playerGuns) do
                gun.bulletSpeed = gun.bulletSpeed + gun.bulletSpeed * 0.5
            end
            playerLevel = playerLevel + 1
        elseif currentPlayingCutscene.improveShipBulletLifeTime then
            for g, gun in ipairs(playerGuns) do
                gun.bulletLifeTime = gun.bulletLifeTime + gun.bulletLifeTime * 0.5
            end
            playerLevel = playerLevel + 1
        elseif currentPlayingCutscene.improveShipHp then
            playerHp = playerHp + 1
            playerLevel = playerLevel + 1
        elseif currentPlayingCutscene.improveShipGrabRange then
            grabDistance = grabDistance + grabDistance * 0.5
            playerLevel = playerLevel + 1
        elseif currentPlayingCutscene.improvePlanetPrices then
            planetPricesScaler = clamp(planetPricesScaler - planetPricesScaler * 0.1, 0.1, 1)
            print("planetPricesScaler", lanetPricesScaler)
        elseif currentPlayingCutscene.improvePlanetsGuns then
            for p, planet in ipairs(planets) do
                for g, gun in ipairs(planet.guns) do
                    gun.damage = gun.damage + gun.damage * 0.5
                end
            end
        elseif currentPlayingCutscene.buildOnPlanet then
            playerLandingOnPlanet.level = playerLandingOnPlanet.level + 1
            resultPhrase = "Planet Level : " .. playerLandingOnPlanet.level .. ". ".. phrase.text
            buildOnPlanet(playerLandingOnPlanet)
        elseif currentPlayingCutscene.upgradeShip then
            playerLandingOnPlanet.level = playerLandingOnPlanet.level + 1
            resultPhrase = "Ship Level : " .. playerLevel .. ". ".. phrase.text
            upgradePlayerShip()
        elseif currentPlayingCutscene.repairPlayerShip then

            playerLandingOnPlanet.level = playerLandingOnPlanet.level + 1
            if playerHpCurrent >= playerHp + playerLevel then
                playerHpCurrent = playerHpCurrent + 1
            else
                playerHpCurrent = playerHp + playerLevel
            end
            playerRepairedOnPlanet()
        elseif currentPlayingCutscene.repairSingle then
            playerHpCurrent = playerHpCurrent + 1
        elseif currentPlayingCutscene.takeOff then
            playerLandingOnPlanet = nil
            playerIsLandedOnPlanet = false
            landingTimeCurrent = 0
        end

        if currentPlayingCutscene.playMusic then
            playMusic(currentPlayingCutscene.playMusic)
        end
    end

	showTextBox(resultPhrase, 10 , love.graphics.getHeight()*gameTextVerticalScaler, phrase.colorR,phrase.colorG,phrase.colorB, phrase.printSymbolCooldown)
    return currentPlayingCutscene
end

function playCutscene(cutsceneName)
    return playCutsceneDirect(cutscenes[cutsceneName])
end


function drawTextBox()
    if isTextBoxVisible == false then
        return
    end

    love.graphics.setColor(0., 0, 0.05, 0.5)
    love.graphics.rectangle("fill", -50, -50 , love.graphics.getWidth() + 100, love.graphics.getHeight() + 100)

    love.graphics.setFont(pixelFont)
    
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("HP: "..playerHpCurrent, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.2)

    
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("$"..gold, love.graphics.getWidth() * 0.5, love.graphics.getHeight() * 0.1)


    local stringTable = tablify(textBox.text)
    local resultText = ""
    for i = 1, #stringTable, 1 do
        if i < textBox.visibleSymbols then
            resultText = resultText .. stringTable[i]
        end
    end

    if showingDot then 
        resultText = resultText .. "."
    end
    love.graphics.setColor(textBox.colorR, textBox.colorG, textBox.colorB, 1)

    love.graphics.printf(resultText, textBox.x, textBox.y, love.graphics.getWidth()-30, 'center')

    love.graphics.setColor(1,1,1)

    if currentCutscenePhraseIndex >= #currentPlayingCutscene then
				isShowingChoices =true
        drawChoices()
		else
				isShowingChoices = false
    end
end

function drawChoices()
    love.graphics.setColor(1,1,1)
    for c, choice in ipairs(currentPlayingCutscene.choices) do
        local stringTable = tablify(choice.text)
        local resultText = ""
        if choice.cutsceneToPlayOnChoice and cutscenes[choice.cutsceneToPlayOnChoice].baseCost  and playerLandingOnPlanet then
            resultText = "$" .. math.ceil(cutscenes[choice.cutsceneToPlayOnChoice].baseCost * planetPricesScaler * (playerLandingOnPlanet.level * difficultyScaler)) .. " " .. resultText
        end
        for i = 1, #stringTable, 1 do
            if i < textBox.visibleSymbols and textBox.visibleSymbols < #textBox.text + 1 then
                resultText = resultText .. stringTable[i]
            elseif  textBox.visibleSymbols >= #textBox.text - 1 then
                resultText = resultText .. choice.text
                
                break
            end
        end

        if selectedChoiceIndex == c then
            resultText = "> " .. resultText .. " <"
        end
				local x = textBox.x
				local y = love.graphics.getHeight() * 0.5 + (love.graphics.getHeight() * 0.075) * c 
				choice.x =x
				choice.y = y
        love.graphics.printf(resultText, x, y, love.graphics.getWidth()-10, 'center')
    end
end

function showTextBox(text, x, y, colorR, colorG, colorB, printSymbolCooldown)
    isTextBoxVisible = true
    textBox.text = text
    textBox.x = x
    textBox.y = y
    textBox.colorR = colorR
    textBox.colorG = colorG
    textBox.colorB = colorB
    textBox.visibleSymbols = 0
    textBox.printSymbolCooldown = printSymbolCooldown
end




function hideTextBox()
    isTextBoxVisible = false
    shipSpeedX = 0
    shipSpeedY = 0
end

function tetxBoxKeyPressed(key)
    if isTextBoxVisible == false then
        return
    end

    if key == 'return' or key == 'space' then
        if isShowingChoices then
            tryAdvancingTextBox(selectedChoiceIndex)
        else
            tryAdvancingTextBox()
        end
		playUi()	
    elseif key == 'up' or key == 'w' then
        playUi()
        selectedChoiceIndex = selectedChoiceIndex - 1
        if selectedChoiceIndex < 1 then
            selectedChoiceIndex = #currentPlayingCutscene.choices
        end
    elseif key == 'down' or key == 's' then
        playUi()
        selectedChoiceIndex = selectedChoiceIndex + 1
        if selectedChoiceIndex > #currentPlayingCutscene.choices then
            selectedChoiceIndex = 1
        end
    end

end

function textBoxTouched(id,x,y)
    if isTextBoxVisible == false then
        return
    end
    if currentPlayingCutscene == nil then
        hideTextBox()
        return
    end
	if isShowingChoices then
		playUi()
		selectClosestChoice(x,y) 
	else
		tryAdvancingTextBox()
	end
end

function selectClosestChoice(x,y)
	local dist = 99999999
	local closest = 1
	for c, choice in ipairs(currentPlayingCutscene.choices) do
		local newDist = distance(x,y,choice.x,choice.y)
		if newDist < dist then 
			dist = newDist
			closest =c
		end
	end
	if selectedChoiceIndex == closest then
			tryAdvancingTextBox(closest)
	end
	selectedChoiceIndex = closest
end

function tablify(str)
    local tbl = {}
    for char in str:gmatch(".") do -- matches every character
        tbl[#tbl+1] = char
    end
    return tbl
end

function showTextBoxCustomRoseText(customText)
    showTextBox(customText, 0 , love.graphics.getHeight()*gameTextVerticalScaler, 1,0,0, 0.1)
end