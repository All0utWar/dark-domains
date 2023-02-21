
--Classnames MUST match their respective textures, disregard spacing and capitals
consumable = {coins = 		{id = 1, name = "Coins", amounts = {5, 50, 100}, amountType = "money", width = 32, height = 32, yOffset = 4, texture = nil},
				health = 	{id = 2, name = "Health Potion", amount = 50, amountType = "health", width = 32, height = 56, yOffset = -8, texture = nil},
				mana = 		{id = 3, name = "Mana Potion", amount = 25, amountType = "magic", width = 32, height = 56, yOffset = -8, texture = nil}
				}

--This function will create an entry in the consumable table with all of its' relevant stats and gfx options
function consumable.spawn(class, x, y)
	table.insert(consumable, {class = class, x = x, y = y, radius = 32, amount = 0,
							rarity = "common", particleRarity = nil, isHeld = false,
							inPickupRange = false, pickupRange = 64, isDead = false})

	--Auto-fix for nil textures when loading classes
	local str = string.gsub(consumable[#consumable].class.name, "%s+", "")
	local str_complete_texture = string.lower("img_con_" .. str)
	consumable[#consumable].class.texture = _G[str_complete_texture]

	if consumable[#consumable].class.id == 1 then
		--Generates a random number of coins per drop
		consumable[#consumable].amount = consumable[#consumable].class.amounts[love.math.random(1,3)]

		if consumable[#consumable].amount == 5 then
			consumable[#consumable].rarity = "common"
		elseif consumable[#consumable].amount == 50 then
			consumable[#consumable].rarity = "uncommon"
		elseif consumable[#consumable].amount == 100 then
			consumable[#consumable].rarity = "legendary"
		end
		
	elseif consumable[#consumable].class.id == 2 then
		consumable[#consumable].amount = consumable[#consumable].class.amount
		consumable[#consumable].rarity = "health"

	elseif consumable[#consumable].class.id == 3 then
		consumable[#consumable].amount = consumable[#consumable].class.amount
		consumable[#consumable].rarity = "mana"

	end

	consumable[#consumable].particleRarity = particle_rarity:clone()
	consumable[#consumable].particleRarity:start()
	consumable[#consumable].particleRarity:setRadialAcceleration(1, 3)
	consumable[#consumable].particleRarity:setSpin(1, 3)
	consumable[#consumable].particleRarity:setTangentialAcceleration(1, 12)
end

function consumable.update(dt)
	local plr = player[1]

	for i,v in ipairs(consumable) do
		--Update rarity system particle effects for weapons on ground
		v.particleRarity:update(dt)

		checkBoundaries(consumable[i], v.class.width, v.class.height)

		if plr ~= nil then
			--Consumable Pickup Range check
			if math.dist(v.x + v.class.width / 2, v.y + v.class.height / 2, plr.x + plr.width / 2, plr.y + plr.height / 2) <= v.pickupRange then
				v.inPickupRange = true
			else
				v.inPickupRange = false
			end
		end
	end
end

function consumable.draw()
	local plr = player[1]
	local scale = 1.3

	for i,v in ipairs(consumable) do
		if v.rarity == "common" then
			love.graphics.setColor(clr_efx_common)
		elseif v.rarity == "uncommon" then
			love.graphics.setColor(clr_efx_uncommon)
		elseif v.rarity == "mana" then
			love.graphics.setColor(clr_efx_mana)
		elseif v.rarity == "health" then
			love.graphics.setColor(clr_efx_health)
		elseif v.rarity == "legendary" then
			love.graphics.setColor(clr_efx_legendary)
		end

		love.graphics.draw(v.particleRarity, v.x + v.class.width / 2, v.y + v.class.height / 2, 0, .5, .5)

		if v.class.texture then
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(v.class.texture, v.x + v.class.texture:getWidth()/2, v.y + v.class.texture:getHeight()/2, 0, scale, scale, v.class.texture:getWidth()/2, v.class.texture:getHeight()/2 + v.class.yOffset)

		else
			love.graphics.setColor(.15, 1, .3)
			love.graphics.rectangle("fill", v.x, v.y, v.class.width, v.class.height)
		end

		if isDebug then
			love.graphics.circle("line", v.x + v.class.width / 2, v.y + v.class.height / 2, v.radius)
		end

		--[[if v.inPickupRange then
			love.graphics.print(v.class.name, v.x - v.class.width, v.y - v.class.height/2)
		end--]]
	end
end

function consumable.affect(user, con_index)
	local conType = consumable[con_index].class.amountType
	local conAmount = consumable[con_index].amount
	local willConsume = false

	if conType == "money" then
		willConsume = true
		int_totalCoins = int_totalCoins + conAmount
		playSound("snd_pickup_coins")
	elseif conType == "health" then
		if user.health >= user.maxHealth then
			willConsume = false
		else
			willConsume = true
			user.health = user.health + conAmount
			playSound("snd_pickup_consumable")
		end
	elseif conType == "magic" then
		willConsume = true
	end

	if willConsume then
		table.remove(consumable, con_index)
	end
end

--[[
function weapon.spawnRandom(x, y)
	local wpnToSpawn = nil
	local random = 0

	random = love.math.random(1, 3)

	--This part can be cleaned up later..
	--We only have 3 weapons as of now 2/18/2023
	if random == 1 then
		wpnToSpawn = weapon.dagger
	elseif random == 2 then
		wpnToSpawn = weapon.broadsword
	elseif random == 3 then
		wpnToSpawn = weapon.katana
	end

	weapon.spawn(wpnToSpawn, x, y)
end
--]]