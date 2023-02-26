local gameOverTimer = 0

player = {}
function player.spawn(x, y)
	table.insert(player, {archetype = "player", id = 1 + #player, x = x, y = y, width = 45, height = 90, radius = 30, xVel = 0, yVel = 0, inputx = 0,
							inputy = 0, moveSpeed = 230, moveAcceleration = 2500, isAttacking = false, isDead = false, currentWeapon = 0, currentWeaponIndex = 0,
							handx = 0, handy = 0, dir = -1, state = "idle", prevState = "", animationTable = img_plr_idle, current_frame = 1,
							anim_timescale = 5, tick = 0, maxHealth = 100, health = 100, lastHurtBy = nil})

	local newMaxHealth = 0
	local newSpeed = 0

	if int_stats_hp == 0 then
		newMaxHealth = 100
	elseif int_stats_hp == 1 then
		newMaxHealth = 100
	elseif int_stats_hp == 2 then
		newMaxHealth = 110
	elseif int_stats_hp == 3 then
		newMaxHealth = 132
	elseif int_stats_hp == 4 then
		newMaxHealth = 172
	elseif int_stats_hp == 5 then
		newMaxHealth = 241
	end

	if int_stats_speed == 0 then
		newSpeed = 230
	elseif int_stats_speed == 1 then
		newSpeed = 230
	elseif int_stats_speed == 2 then
		newSpeed = 242
	elseif int_stats_speed == 3 then
		newSpeed = 267
	elseif int_stats_speed == 4 then
		newSpeed = 308
	elseif int_stats_speed == 5 then
		newSpeed = 370
	end

	player[#player].maxHealth = math.ceil(newMaxHealth * (float_stats_incr10 * int_stats_hp + 1))
	--player[#player].health = player[#player].maxHealth
	player[#player].health = 9999

	player[#player].moveSpeed = math.ceil(newSpeed * (float_stats_incr5 * int_stats_speed + 1))
end

function player.update(dt)
	for i,v in ipairs(player) do
		if v.isDead then
			player.kill(dt, player[i], 3)

		elseif not v.isDead then
			animationStateController(dt, player[i])
			playerMovementController(dt, player[i])
			pickupConsumable(player[i])
			attackController(dt, player[i])

			v.x = v.x + v.inputx * (v.xVel * dt)
			v.y = v.y + v.inputy * (v.yVel * dt)

			checkBoundaries(player[i])

			if v.health >= v.maxHealth then
				v.health = v.maxHealth
			end
		end

		--This may need to be moved to the weapon script to be set for each weapon
		v.handx, v.handy = (v.x + v.width / 2), v.y - 96

		--update our cameras position
		cam:setPosition(v.x, v.y)
	end
end

function player.draw()
	for i,v in ipairs(player) do
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(v.animationTable[v.current_frame], v.x + (v.width / 2), v.y - 10, 0, -v.dir * 2, 2, v.animationTable[v.current_frame]:getWidth() / 2)
		
		if v.currentWeapon > 0 then
			local plrWep = weapon.getWeapon(v.currentWeapon)
			
			if v.isAttacking then
				--Attack Charge bar
				love.graphics.setColor(0, 0, 0, .7)
				love.graphics.rectangle("fill", v.x - v.width / 2, v.y + v.height + 12, 100, 7)

				love.graphics.setColor(.9, .9, .9, .7)
				love.graphics.draw(plrWep.class.texture, v.x - v.width / 2 - 16, v.y + v.height, 0, .65, .65)
				love.graphics.rectangle("fill", v.x - v.width / 2, v.y + v.height + 12, math.clamp(((plrWep.attackSpeed_timer*100) / (plrWep.class.attackSpeed)), 0, (plrWep.class.attackSpeed*100000)), 7)
			end
		end

		if isDebug then
			love.graphics.circle("line", v.x + v.width / 2, v.y + v.height / 2, v.radius)
			--love.graphics.print("Frame: " .. v.current_frame, v.x - 12, v.y - 24)
		end
	end
end

function player.kill(dt, user, transitionTime)
	if user.health > 0 then
		takeDamage(str_FoN, user, 9999)
	end

	dropWeapon(user)

	gameOverTimer = gameOverTimer + 1 * dt
	if gameOverTimer >= transitionTime then
		switchGameState("gameOver")
		playMusic("msc_menuscreen")
		gameOverTimer = 0
	end
end

function player.hud(user)
	local xPos, yPos  = 128, 32
	local scale = 6
	local wpnImg = nil
	local wpn = nil

	--Get the player's current weapon to draw to screen
	if user.currentWeapon > 0 then
		wpn = weapon.getWeapon(player[1].currentWeapon)
		wpnImg = wpn.class.texture
	end

	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(font_hudText)
	love.graphics.draw(img_ui_wpn_slot_box, xPos - 114, yPos, 0, scale, scale)

	if wpnImg ~= nil then
		love.graphics.draw(wpnImg, xPos + wpnImg:getWidth() / 2 - 48, yPos + wpnImg:getHeight() / 2 - 16, math.rad(30), scale/3, scale/3)
	end

	love.graphics.draw(img_ui_hp_bar_outline, xPos, yPos, 0, scale, scale)
	love.graphics.draw(img_ui_hp_bar_empty, xPos + 48, yPos + 12, 0, scale, scale)
	love.graphics.draw(img_ui_hp_bar_full, xPos + 48, yPos + 12, 0, math.clamp(scale * (user.health / user.maxHealth), 0, user.maxHealth), scale)
	love.graphics.printf(user.health .. "/" .. user.maxHealth, xPos, yPos + 14, img_ui_hp_bar_outline:getWidth() * scale, "center")

	--love.graphics.draw(img_ui_mana_bar_outline, xPos, yPos + 64, 0, scale, scale)
	--love.graphics.draw(img_ui_mana_bar_empty, xPos + 48, yPos + 76, 0, scale, scale)
	--love.graphics.draw(img_ui_mana_bar_full, xPos + 48, yPos + 76, 0, scale, scale)
end