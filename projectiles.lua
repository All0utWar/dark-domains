

projectiles = {}
function projectiles.spawn(x, y, width, height)
	table.insert(projectiles, {x = x, y = y, width = width, height = height})
end

function projectiles.update(dt)
	for i,v in ipairs(projectiles) do
	end
end

function projectiles.draw()
	for i,v in ipairs(projectiles) do
		love.graphics.setColor(0, 0, 1)
		love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)
	end
end