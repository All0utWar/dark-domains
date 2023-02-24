
--Classnames MUST match their respective textures, disregard spacing and capitals
artifact = {chest = 		{id = 1, name = "Chest", maxHealth = 10, width = 72, height = 48, scale = 3.5, hitBox = {radius = 42}, texture = nil},
				}

--This function will create an entry in the artifact table with all of its' relevant stats and gfx options
function artifact.spawn(class, x, y)
	table.insert(artifact, {archetype = "artifact", class = class, x = x, y = y, health = 0,
							isDead = false, inPickupRange = false, pickupRange = 72})

	--Auto-fix for nil textures when loading classes
	local str = string.gsub(artifact[#artifact].class.name, "%s+", "")
	local str_complete_texture = string.lower("img_art_" .. str)
	artifact[#artifact].class.texture = _G[str_complete_texture]

	artifact[#artifact].health = artifact[#artifact].class.maxHealth
end

function artifact.update(dt)
	local plr = player[1]

	for i,v in ipairs(artifact) do
		if v.isDead then
			dropLoot(artifact[i])
			table.remove(artifact, i)

		elseif not v.isDead then
			checkBoundaries(artifact[i], v.class.width, v.class.height)

			if plr ~= nil then
				--Weapon Pickup Range check
				if math.dist(v.x, v.y, plr.x + plr.width / 2, plr.y + plr.height / 2) <= v.pickupRange and (not v.isHeld and not plr.isDead) then
					v.inPickupRange = true
				else
					v.inPickupRange = false
				end
			end
		end
	end
end

function artifact.draw()
	local plr = player[1]
	local scale = 1.3

	for i,v in ipairs(artifact) do
		if v.class.texture then
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(v.class.texture, v.x, v.y, 0, (v.class.scale or 2), (v.class.scale or 2), v.class.texture:getWidth()/2, v.class.texture:getHeight()/2)

		else
			love.graphics.setColor(138/255, 78/255, 76/255)
			--love.graphics.rectangle("fill", v.x, v.y, v.class.width, v.class.height)
			love.graphics.rectangle("line", v.x - v.class.width/2, v.y - v.class.height/2, v.class.width, v.class.height)
		end

		if isDebug then
			love.graphics.circle("line", v.x, v.y, v.class.hitBox.radius)
		end

		if v.inPickupRange then
			--UI for weapon pickup
			love.graphics.setColor(1, 1, 1)
			love.graphics.setFont(font_gameText)
			love.graphics.print("Open (" .. v.class.name .. ")", v.x - 48, v.y - 64)
		end
	end
end