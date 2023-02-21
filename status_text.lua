local status_text = {
	_VERSION		= "1.0.1",
	_DESCRIPTION	= "Library for printing system messages",
	_URL			= "N/A",
	_LICENSE		= "N/A"
}

local gameFont
local textFont = love.graphics.newFont(14)
local gameWindowWidth = love.window.getMode()

status_text.print = function(text)
	table.insert(status_text, {x = 6, y = 12, text = text, alpha = 1, speed = 9})
end

status_text.update = function(dt)
	for i,v in ipairs(status_text) do

		--Removes objects from table when no longer visible
		if v.y <= -textFont:getHeight() then
			table.remove(status_text, i)
		end

		--Increase speed when large amount of messages exist
		if #status_text > 50 then
			v.speed = 112
		end

		--Allows each object to fade away at a specific distance from the top of screen
		if math.dist(v.x, v.y, 0, 0) <= textFont:getHeight() then
			v.alpha = v.alpha - .45 * dt
		end	

		for j = i + 1, #status_text do
			if math.dist(status_text[j].x, status_text[j].y, v.x, v.y) <= textFont:getHeight() then
				status_text[j].y = status_text[j].y + textFont:getHeight()
			end
		end

		v.y = v.y - v.speed * dt
	end
end

status_text.draw = function()
	gameFont = love.graphics.getFont()

	for i,v in ipairs(status_text) do
		love.graphics.setFont(textFont)
		love.graphics.setColor(1, 1, 1, v.alpha)
		love.graphics.printf(v.text, v.x, v.y, gameWindowWidth / 1.5, "left")

		love.graphics.setFont(gameFont)
	end
end

return status_text