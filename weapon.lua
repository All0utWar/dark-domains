
--Classnames MUST match their respective textures, disregard spacing and capitals
weapon = {dagger = 			{id = 1, name = "Dagger", damage = 10, damageType = "stab", attackSpeed = .16, attackRange = 8, attackRoF = .33, attackSize = 48, texture = nil, xOffset = 35, yOffset = -100, xOffsetRun = 0, yOffsetRun = 8, rotationAngle = -80},
			broadsword = 	{id = 2, name = "Broad Sword", damage = 8, damageType = "slash", attackSpeed = .22, attackRange = 16, attackRoF = .66, attackSize = 92, texture = nil, xOffset = -44, yOffset = -20, xOffsetRun = 0, yOffsetRun = 12, rotationAngle = 30},
			katana = 		{id = 3, name = "Katana", damage = 6, damageType = "slash", attackSpeed = .44, attackRange = 32, attackRoF = .75, attackSize = 136, texture = nil, xOffset = -60, yOffset = 8, xOffsetRun = 0, yOffsetRun = 8, rotationAngle = 30},
			shortsword = 	{id = 4, name = "Short Sword", damage = 6, damageType = "stab", attackSpeed = .16, attackRange = 1, attackRoF = .44, attackSize = 64, texture = nil, xOffset = 0, yOffset = 0, xOffsetRun = 0, yOffsetRun = 8, rotationAngle = 30},
			battlestaff = 	{id = 5, name = "Battlestaff", damage = 25, damageType = "stab", attackSpeed = .44, attackRange = 1, attackRoF = .75, attackSize = 128, texture = nil, xOffset = 0, yOffset = 0, xOffsetRun = 0, yOffsetRun = 8, rotationAngle = 30}
			}

--This function will create an entry in the weapon table with all of its' relevant stats and gfx options
function weapon.spawn(class, x, y, initialSpawn, dmg)
	table.insert(weapon, {class = class, x = x, y = y, width = 0, height = 0, radius = 32, hitBox = {x = 0, y = 0, radius = 0}, damage = 0,
							rarity = "common", particleRarity = nil, hasFired = false, attackSpeed_timer = 0,
							rof_timer = 0, isHeld = false, inPickupRange = false, pickupRange = 64,
							relocateSpeed = 256, despawnTimer = 30})

	local wpn = weapon[#weapon]

	--Auto-fix for nil textures when loading classes
	local str = string.gsub(weapon[#weapon].class.name, "%s+", "")
	local str_complete_texture = string.lower("img_wpn_" .. str)
	weapon[#weapon].class.texture = _G[str_complete_texture]

	--Set width/height
	weapon[#weapon].width, weapon[#weapon].height = weapon[#weapon].class.texture:getWidth() * 1.5, weapon[#weapon].class.texture:getHeight() * 1.5

	--'Randomize' weapon stats on spawn1
	if not initialSpawn then
		--Set initial weapon damage randomized off of the class it derives from * current difficulty level
		weapon[#weapon].damage = love.math.random(3, weapon[#weapon].class.damage * (int_difficulty/2))
		--print(weapon[#weapon].damage, weapon[#weapon].class.damage * int_difficulty)

		--Set weapon damage again based on Player Damage Stat scalar
		--Math boils down to (DMG * 1.x + 1) -- x = dmg stat integer
		weapon[#weapon].damage = math.ceil(weapon[#weapon].damage * (float_stats_incr10 * int_stats_dmg + 1))


	elseif initialSpawn then
		--Initial weapon spawn uses passed-in dmg value
		weapon[#weapon].damage = dmg

	end

	if wpn.damage >= math.ceil(wpn.class.damage * (float_stats_incr10 * (int_stats_max) + 1)) then
		wpn.rarity = "legendary"
	elseif wpn.damage >= math.ceil(wpn.class.damage * (float_stats_incr10 * (int_stats_max-1) + 1)) then
		wpn.rarity = "ultra"
	elseif wpn.damage >= math.ceil(wpn.class.damage * (float_stats_incr10 * (int_stats_max-2) + 1)) then
		wpn.rarity = "rare"
	elseif wpn.damage >= math.ceil(wpn.class.damage * (float_stats_incr10 * (int_stats_max-3) + 1)) then
		wpn.rarity = "uncommon"
	end

	--[[
	if weapon[#weapon].damage >= 35 then
		weapon[#weapon].rarity = "legendary"
	elseif weapon[#weapon].damage >= 20 then
		weapon[#weapon].rarity = "ultra"
	elseif weapon[#weapon].damage >= 10 then
		weapon[#weapon].rarity = "rare"
	elseif weapon[#weapon].damage >= 5 then
		weapon[#weapon].rarity = "uncommon"
	end]]

	weapon[#weapon].particleRarity = particle_rarity:clone()
	weapon[#weapon].particleRarity:start()
	weapon[#weapon].particleRarity:setRadialAcceleration(1, 3)
	weapon[#weapon].particleRarity:setSpin(1, 3)
	weapon[#weapon].particleRarity:setTangentialAcceleration(1, 12)
end

function weapon.update(dt)
	local plr = player[1]
	for i,v in ipairs(weapon) do
		if v.isHeld then
			--Manipulate held position
			v.x, v.y = plr.handx - v.width / 2, plr.handy

			--hitBox(circle) for weapon is scaled to be slightly smaller than the actual effect
			v.hitBox.radius = v.class.attackSize / 2.5

			--If this is omitted, the hitbox will move with the player while they're attacking
			if not v.hasFired then
				v.hitBox.x = math.clamp(camMouseX, plr.x - v.class.attackRange - v.hitBox.radius, (plr.x + plr.width) + v.class.attackRange + v.hitBox.radius)
				v.hitBox.y = math.clamp(camMouseY, plr.y - v.class.attackRange - v.hitBox.radius, (plr.y + plr.height) + v.class.attackRange + v.hitBox.radius)
			end

			particle_attack:update(dt)

			if particle_attack:getCount() < 1 then
				particle_attack:reset()
				particle_attack:pause()
			end


			--Rate of Fire update cycle
			if v.hasFired then
				v.rof_timer = v.rof_timer + 1 * dt
				if v.rof_timer >= v.class.attackRoF then
					v.rof_timer = 0
					v.hasFired = false
				end
			end
		elseif not v.isHeld then
			weapon.despawnUpdate(dt, weapon[i], i)
			checkBoundaries(weapon[i])

			--Relocates weapons so they don't stack ontop of eachother
			for j = i + 1, #weapon do
				if checkCircularCollision(weapon[i].x, weapon[i].y, weapon[j].x, weapon[j].y, weapon[i].radius*2, weapon[j].radius*2) then
					weapon[j].x = weapon[j].x + weapon[j].relocateSpeed * dt
					weapon[j].y = weapon[j].y + weapon[j].relocateSpeed * dt
				end
			end
		end

		--Update rarity system particle effects for weapons on ground
		v.particleRarity:update(dt)

		if plr ~= nil then
			--Weapon Pickup Range check
			if math.dist(v.x, v.y + v.height, plr.x + plr.width / 2, plr.y + plr.height / 2) <= v.pickupRange and (not v.isHeld and not plr.isDead) then
				v.inPickupRange = true
			else
				v.inPickupRange = false
			end
		end
	end
end

function weapon.draw()
	local plr = player[1]
	local rotationAngle
	local xOffset, yOffset, yOffsetRun
	local dir

	for i,v in ipairs(weapon) do
		if v.class.texture then
			if v.isHeld then
				rotationAngle = math.rad(v.class.rotationAngle)
				xOffset = v.class.xOffset
				yOffset = v.class.yOffset
				xAnim = plr.animationTable[plr.current_frame]:getWidth() / 2
				yAnim = plr.animationTable[plr.current_frame]:getHeight() / 2
				dir = plr.dir
				if plr.xVel > 0 or plr.yVel > 0 then
					xOffsetRun = v.class.xOffsetRun
					yOffsetRun = v.class.yOffsetRun
				else
					xOffsetRun = 0
					yOffsetRun = 0
				end
			else
				rotationAngle = 0
				xOffset = 0
				yOffset = 0
				xOffsetRun = 0
				yOffsetRun = 0
				xAnim = 0
				yAnim = 0
				dir = 1
			end

			if not v.isHeld then
				if v.rarity == "common" then
					love.graphics.setColor(clr_efx_common)
				elseif v.rarity == "uncommon" then
					love.graphics.setColor(clr_efx_uncommon)
				elseif v.rarity == "rare" then
					love.graphics.setColor(clr_efx_rare)
				elseif v.rarity == "ultra" then
					love.graphics.setColor(clr_efx_ultra)
				elseif v.rarity == "legendary" then
					love.graphics.setColor(clr_efx_legendary)
				end

				--Get current particle colors
				--local particleColors = v.particleRarity:getColors()
				--local alphaDespawn = v.despawnTimerMax/(v.despawnTimer*v.despawnTimer)
				--Set alpha channel to match weapon's alpha for despawn
				--particleColors[4] = (v.despawnTimer/v.despawnTimer)
				--v.particleRarity:setColors(particleColors)
				
				love.graphics.draw(v.particleRarity, v.x + (v.class.texture:getWidth() + 4), v.y + (v.class.texture:getHeight() + 16), 0, .25, 1)
			end

			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(v.class.texture, v.x + (v.class.texture:getWidth() / 2) - (xOffset + xAnim) * dir, v.y + (v.class.texture:getHeight() / 2) - (yOffset - yAnim) - yOffsetRun, rotationAngle * dir, 1.5 * dir, 1.5)
		else
			love.graphics.setColor(.15, 1, .3)
			love.graphics.rectangle("fill", v.x, v.y, v.width, v.height)

		end

		if not bool_gamePaused then
			love.graphics.setColor(0, .5, 1)
			love.graphics.draw(img_ui_crosshair, camMouseX, camMouseY, 0, .75, .75, 32, 32)
		end

		if isDebug then
			--love.graphics.circle("line", v.x + v.width, v.y + v.height, v.radius)
		end

		if v.inPickupRange then
			--UI for weapon pickup
			love.graphics.setColor(1, 1, 1)
			love.graphics.setFont(font_gameText)
			love.graphics.print("Pickup (" .. v.class.name .. ")\nType: " .. tostring(v.class.damageType) .. "\nDMG: " .. tostring(v.damage) .. "\n", v.x, v.y - 64)
		end
	end
end

--Draws ontop of enemies
function weapon.attackEffects()
	for i,v in ipairs(weapon) do
		--Attack Particle Effects Draw
		if v.isHeld then
			love.graphics.setColor(1, 1, 1)
			love.graphics.draw(particle_attack, v.hitBox.x, v.hitBox.y, 0, v.class.attackSize / 100, v.class.attackSize / 100)
		end

		if isDebug then
			love.graphics.circle("line", v.hitBox.x, v.hitBox.y, v.hitBox.radius)
		end
	end
end

--Base attack functionality for all weapons
function weapon.attack(dt, attacker)
	--Get local instance of attackers current weapon
	local wpn = weapon[attacker.currentWeaponIndex]

	if wpn ~= nil and wpn.isHeld then
		if not wpn.hasFired then
			if attacker.isAttacking then
				wpn.attackSpeed_timer = wpn.attackSpeed_timer + 1 * dt
			else
				--Reset swing timer if let go of attack button
				wpn.attackSpeed_timer = 0
			end

			--particle_attack:reset()

			if wpn.attackSpeed_timer >= wpn.class.attackSpeed then
				if wpn.class.damageType == "stab" then
					playSound("snd_stab", love.math.random(1.45, 1.55))
					particle_attack:setTexture(img_efx_stab)
				elseif wpn.class.damageType == "slash" then
					playSound("snd_slash", love.math.random(1.47, 1.53))
					particle_attack:setTexture(img_efx_slash)
				end

				particle_attack:start()
				particle_attack:setRotation(math.rad(findRotation(wpn.hitBox.x, wpn.hitBox.y, attacker.x + (attacker.width / 2), attacker.y + (attacker.height / 2))))
				particle_attack:setDirection(math.rad(findRotation(wpn.hitBox.x, wpn.hitBox.y, attacker.x + (attacker.width / 2), attacker.y + (attacker.height / 2))))
				particle_attack:setLinearAcceleration(-(attacker.x - wpn.hitBox.x), -(attacker.y - wpn.hitBox.y))
				particle_attack:emit(1)

				--Objects that can be attacked
				weapon.checkHit(attacker, enemy, wpn, wpn.hitBox.x, wpn.hitBox.y, wpn.hitBox.radius)
				weapon.checkHit(attacker, artifact, wpn, wpn.hitBox.x, wpn.hitBox.y, wpn.hitBox.radius)
				
				wpn.attackSpeed_timer = 0
				wpn.hasFired = true --Removed so that attack moves with player?
			end
		end
	end
end

function weapon.checkHit(attacker, tbl, wpn, x, y, r)
	for i,v in ipairs(tbl) do
		if checkCircularCollision(x, y, v.x, v.y, r, v.class.hitBox.radius) then
			v.isHurt = true
			takeDamage(attacker, v, wpn.damage, wpn)
		end
	end
end

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

function weapon.spawnInitial(x, y)
	--weapon.spawn(weapon.dagger, x, y, true, love.math.random(3, 5))
	--Removed damage cap for initial weapon
	weapon.spawn(weapon.dagger, x, y)
end

function weapon.despawnUpdate(dt, wpn, index)
	wpn.despawnTimer = wpn.despawnTimer - 1 * dt
	if wpn.despawnTimer <= 0 then
		table.remove(weapon, index)
	end
end