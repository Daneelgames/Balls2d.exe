

function drawBackground()
	love.graphics.setColor(.01, .075, .125)
	love.graphics.rectangle("fill",-50, -50,arenaWidth + 100, arenaHeight + 100)
	
end

function drawVignette()
	love.graphics.setColor(.0, .0, .0)
	love.graphics.rectangle("fill",0, 0,arenaWidth, arenaHeight)
	
end

function updateBackground(dt)
end



