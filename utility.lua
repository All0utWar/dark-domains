

function switchGameState(newState) --Used for button.lua actions
	if str_gameState ~= newState then
		str_prevGameState = str_gameState
		str_gameState = newState
		--force unpausing
		bool_gamePaused = false
		love.mouse.setVisible(true)

		--Stop menu music from interferring with ingame music and vice-versa
		if (newState == "ingame" and str_prevGameState == "menu") or (newState == "gameOver" and str_prevGameState == "ingame") or (newState == "menu" and str_prevGameState == "ingame") then
			stopMusic()
		end
	end
end

function playerMovementController(dt, plr)
	local keyDown = love.keyboard.isDown(input_moveLeft, input_moveRight, input_moveForward, input_moveBackward)
	plr.inputx, plr.inputy = 0, 0

	--if not plr.isAttacking then
		if love.keyboard.isDown(input_moveLeft) then
			if playerCheckDirectionChange() then
				plr.xVel = 0
			end

			plr.dir = 1
			plr.inputx = plr.inputx - 1
		end
		if love.keyboard.isDown(input_moveRight) then
			if playerCheckDirectionChange() then
				plr.xVel = 0
			end

			plr.dir = -1
			plr.inputx = plr.inputx + 1
		end
		if love.keyboard.isDown(input_moveForward) then
			if playerCheckDirectionChange() then
				plr.yVel = 0
			end

			plr.inputy = plr.inputy - 1
		end
		if love.keyboard.isDown(input_moveBackward) then
			if playerCheckDirectionChange() then
				plr.yVel = 0
			end

			plr.inputy = plr.inputy + 1
		end
--	end

	if keyDown then
		stateChange(plr, "run")

		if plr.xVel <= plr.moveSpeed then
			plr.xVel = plr.xVel + plr.moveAcceleration * dt
		end
		if plr.yVel <= plr.moveSpeed then
			plr.yVel = plr.yVel + plr.moveAcceleration * dt
		end
	else
		plr.xVel, plr.yVel = 0, 0
		stateChange(plr, "idle")
	end

end

function playerCheckDirectionChange()
	local keys = input_total_keys_pressed
	if keys[input_moveLeft] then
		if keys[input_moveRight] then
			return true
		end
	elseif keys[input_moveRight] then
		if keys[input_moveLeft] then
			return true
		end
	elseif keys[input_moveForward] then
		if keys[input_moveBackward] then
			return true
		end
	elseif keys[input_moveBackward] then
		if keys[input_moveForward] then
			return true
		end
	else
		return false
	end
end

function AICheckDirectionChange(user)
	local xDir, yDir = user.xDir, user.yDir
	local pxDir, pyDir = user.pxDir, user.pyDir
	if xDir > 0 then
		if pxDir < 0 then
			print(xDir, pxDir)
			return true
		end
	elseif xDir < 0 then
		if pxDir > 0 then
			print(xDir, pxDir)
			return true
		end
	end
end

function changeXDirection(user, val)
	if user.xDir ~= val then
		user.pxDir = user.xDir
		user.xDir = val
		user.xVel = 0
	end
end

function changeYDirection(user, val)
	if user.yDir ~= val then
		user.pyDir = user.yDir
		user.yDir = val
		user.yVel = 0
	end
end

function AIMoveController(dt, user)
	local plr = player[1]
	if plr ~= nil then
		if math.dist(user.x, user.y, plr.x, plr.y) <= user.class.aggroRange then
			user.isAggro = true
		else
			user.isAggro = false
		end

		if user.isAggro then
			if not user.hasFired then
				--Player is on right side, enemy is on left
				if plr.x + (plr.width / 2) >= user.x + user.class.attackRange then
					changeXDirection(user, 1)

				--Player is on left side, enemy is on right
				elseif plr.x - (plr.width / 2) <= user.x - user.class.attackRange then
					changeXDirection(user, -1)
				end

				--Player is under enemies
				if plr.y >= user.y then
					changeYDirection(user, 1)

				--Player is above enemies
				elseif plr.y + plr.height <= user.y then
					changeYDirection(user, -1)
				end

				stateChange(user, "run")
			end

			if user.xVel <= user.class.moveSpeed then
				user.xVel = user.xVel + user.class.moveAcceleration * dt
			end
			if user.yVel <= user.class.moveSpeed then
				user.yVel = user.yVel + user.class.moveAcceleration * dt
			end

		elseif not user.isAggro then
			user.xVel, user.yVel = 0, 0
		end
	end
end

function attackController(dt, attacker)
	--Handles how objects use weapons
	if love.mouse.isDown(1) then
		weapon.attack(dt, attacker)
		attacker.isAttacking = true
	else
		attacker.isAttacking = false
	end
end

function takeDamage(attacker, victims, dmg)
	victims.health = victims.health - dmg
	victims.lastHurtBy = attacker

	local atkr = attacker.archetype

	if atkr == "player" then
		int_totalDamageDealt = statTrack(int_totalDamageDealt, dmg)
	end

	if victims.health <= 0 then
		if attacker.archetype == "enemy" then
			atkr = attacker.class.name
			if not victims.isDead then
				int_totalDeaths = statTrack(int_totalDeaths, 1)
			end
		elseif attacker.archetype == "player" then
			atkr = "player"
			int_totalKills = statTrack(int_totalKills, 1)

			if attacker.currentWeaponIndex > 0 then
				local wpn = weapon[attacker.currentWeaponIndex]

				if wpn.class.damageType == "stab" then
					int_totalStabKills = statTrack(int_totalStabKills, 1)
				elseif wpn.class.damageType == "slash" then
					int_totalSlashKills = statTrack(int_totalSlashKills, 1)
				end
			end
		end

		victims.isDead = true

		if victims.archetype == "enemy" then
			int_total_enemies = int_total_enemies - 1

			if victims.class.enemyType == "bat" then
				int_batCount = int_batCount - 1
				int_batKills = int_batKills + 1 --End of Run Stat Track
				int_totalBatKills = statTrack(int_totalBatKills, 1)
			elseif victims.class.enemyType == "zombie" then
				int_zombieCount = int_zombieCount - 1
				int_zombieKills = int_zombieKills + 1 --End of Run Stat Track
				int_totalZombieKills = statTrack(int_totalZombieKills, 1)
			elseif victims.class.enemyType == "ghoul" then
				int_ghoulCount = int_ghoulCount - 1
				int_ghoulKills = int_ghoulKills + 1 --End of Run Stat Track
				int_totalGhoulKills = statTrack(int_totalGhoulKills, 1)
			end
		end
	end

	playSound("snd_damage")

	if isDebug then
		print("ATKR: " .. atkr .. " DAMAGE TO: " .. victims.archetype .. ", DMG: " .. dmg)
	end
end

function playerInteractController(dt)
	local plr = player[1]

	pickupWeapon(plr)
end

function pickupWeapon(user)
	for i,v in ipairs(weapon) do
		if v.inPickupRange then
			love.mouse.setVisible(false)

			--Drop Weapon before picking up new one
			dropWeapon(user)

			--Pickup new weapon and stop+reset rarity effects
			user.currentWeapon = v.class.id
			if v.class.id == user.currentWeapon then
				user.currentWeaponIndex = i
				v.particleRarity:stop()
				v.particleRarity:reset()
				v.isHeld = true
			end
		end
	end
end

function dropWeapon(user)
	--Drop Held weapon and kickstart rarity effects again
	if user.currentWeapon > 0 then
		weapon[user.currentWeaponIndex].x = user.x
		weapon[user.currentWeaponIndex].y = user.y

		weapon[user.currentWeaponIndex].isHeld = false
		weapon[user.currentWeaponIndex].particleRarity:start()
	end
end

function pickupConsumable(user)
	for i,v in ipairs(consumable) do
		if v.inPickupRange then
			consumable.affect(user, i)
		end
	end
end

function stateChange(user, state, startFrame)
	--Changes player state only if a new action has occured.
	--Checks if the new incoming state is different from the current state
	if user.state ~= state then
		--Checks if we need to change the starting animation frame..otherwise defaults to 1
		user.current_frame = startFrame or 1

		user.prevState = user.state
		user.state = state
	end
end

function dropLoot(user)
	local chance = love.math.random(1, 100)
	local x, y = user.x, user.y

	if chance >= 98 then
		weapon.spawnRandom(x, y)
	elseif chance >= 92 then
		consumable.spawn(consumable.health, x, y)
	elseif chance >= 70 then
		consumable.spawn(consumable.coins, x, y)
	end
end

function upgradeStat(action)
	local cost = 0
	local willCharge = true

	if action == "upgrade1" then
		cost = (int_stats_dmg + 1) * 500
	elseif action == "upgrade2" then
		cost = (int_stats_speed + 1) * 500
	elseif action == "upgrade3" then
		cost = (int_stats_hp + 1) * 500
	end

	if int_totalCoins >= cost then
		if action == "upgrade1" then
			if int_stats_dmg < int_stats_max then
				int_stats_dmg = int_stats_dmg + 1
			else
				willCharge = false
			end
		end 
		if action == "upgrade2" then
			if int_stats_speed < int_stats_max then
				int_stats_speed = int_stats_speed + 1
			else
				willCharge = false
			end
		end
		if action == "upgrade3" then
			if int_stats_hp < int_stats_max then
				int_stats_hp = int_stats_hp + 1
			else
				willCharge = false
			end
		end

		if willCharge then
			int_totalCoins = int_totalCoins - cost
			saveGame()
		end
	end
end

function checkBoundaries(user, w, h)
	--Gets supplied width and height if available, otherwise defaults to user values
	local w = w or user.width
	local h = h or user.height
	local wall_width, wall_top, wall_bottom = 72, 32, 116

	if user.x <= wall_width then
		user.x = wall_width
	elseif (user.x + w) + wall_width >= int_world_width then
		user.x = int_world_width - w - wall_width
	end

	if user.y <= wall_top then
		user.y = wall_top
	elseif (user.y + h) + wall_bottom >= int_world_height then
		user.y = int_world_height - h - wall_bottom
	end
end

function startNewGame()
	int_totalRuns = statTrack(int_totalRuns, 1)
	stopSound("msc_menuscreen")
	playMusic("msc_gameplay")
	player.spawn(int_world_width / 2, int_world_height / 2)

	weapon.spawnInitial(int_world_width / 2, int_world_height / 2)

	--[[weapon.spawn(weapon.dagger, int_world_width / 2, int_world_height / 2)
	weapon.spawn(weapon.broadsword, int_world_width / 2 + 100, int_world_height / 2)
	weapon.spawn(weapon.katana, int_world_width / 2, int_world_height / 2 + 100)

	consumable.spawn(consumable.coins, int_world_width / 2, int_world_height / 2 - 100)
	consumable.spawn(consumable.coins, int_world_width / 2, int_world_height / 2 - 200)
	consumable.spawn(consumable.coins, int_world_width / 2, int_world_height / 2 - 300)
	consumable.spawn(consumable.health, int_world_width / 2 + 100, int_world_height / 2 - 100)
	consumable.spawn(consumable.mana, int_world_width / 2 - 100, int_world_height / 2 - 100)
	--]]
end

function finishCurrentGame()
	--switchGameState("menu")
	love.mouse.setVisible(true)
	stopSound("msc_gameplay")
	playMusic("msc_menuscreen")

	saveGame()

	--Reset all gameplay variables
	reloadGameSettings()
end

function initialGameSettings()
	float_masterVolume = 1		--Audio Settings
	float_mscVolume = 0.5		--Audio Settings
	float_sndVolume = 0.5		--Audio Settings
	setNewVolume()

	int_stats_max = 5			--STATIC
	float_stats_incr10 = .1		--STATIC
	float_stats_incr5 = .05		--STATIC
	int_max_enemies = 64		--STATIC

	int_allTimeKills = 0		--All time total monster kills
	int_totalBatKills = 0		--All time total bat kills
	int_totalZombieKills = 0	--All time total zombie kills
	int_totalGhoulKills = 0		--All time total spirit kills
	int_totalDamageDealt = 0	--All time total damage
	int_totalStabKills = 0		--All time total stab kills
	int_totalSlashKills = 0		--All time total slash kills
	int_totalDeaths = 0			--All time total deaths
	int_totalRuns = 0			--All time total runs
	int_totalCoins = 0			--All time total coins
	-----------------Player Stat Upgrades-----------------
	int_stats_dmg = 0
	int_stats_speed = 0
	int_stats_hp = 0
end

function reloadGameSettings()

	----------------------Run Stats----------------------
	int_totalTime = 0			--Current Run Timer

	int_totalKills = 0			--Total Kills in Run
	int_batKills = 0			--Total Bat Kills in Run
	int_zombieKills = 0			--Total Zombie Kills in Run
	int_ghoulKills = 0			--Total Ghoul Kills in Run
	int_beetleKills = 0			--Total Beetle Kills in Run
	int_warriorKills = 0		--Total Warrior Kills in Run

	--------------------Run Information------------------
	int_difficulty = 1			--Difficulty of Run scalar
	int_total_enemies = 0		--Total Spawned in Enemies
		int_batCount = 0
		int_zombieCount = 0
		int_ghoulCount = 0
		int_beetleCount = 0
		int_warriorCount = 0
	--Prevents these mobs from spawning at start of Run--
	canSpawnZombies = false
	canSpawnGhouls = false
	canSpawnBeetles = false
	canSpawnWarriors = false
	-----------------------------------------------------
	int_spawnRate_timer = 0		--Initialize/reset spawn timer

	bool_difficultyChanged = false
	bool_cleanup = true			--Starts logic that resides in love.update()
end

--Resets all gameplay variables and cleans up all entities
function destroyAllObjects()
	for i = 1, #weapon do
		table.remove(weapon, i)
	end

	for i = 1, #player do
		table.remove(player, i)
	end

	for i = 1, #enemy do
		table.remove(enemy, i)
	end

	for i = 1, #consumable do
		table.remove(consumable, i)
	end

	--Ensure that all tables are empty sets before flipping back to false
	if #weapon <= 0 and #player <= 0 and #enemy <= 0 and #consumable <= 0 then
		bool_cleanup = false
	end
end

function statTrack(stat, val)
	return stat + val
end

function pauseGame()
	if bool_gamePaused then
		love.audio.play(msc_effects["msc_gameplay"])
		bool_gamePaused = false
	else

		love.audio.pause(msc_effects["msc_gameplay"])
		bool_gamePaused = true
	end

	local plr = player[1]
	if plr.currentWeaponIndex > 0 then
		love.mouse.setVisible(bool_gamePaused)
	else
		love.mouse.setVisible(true)
	end
end

function saveGame()
	local plr = player[1]
	local data = {masterVolume = float_masterVolume,
					musicVolume = float_mscVolume,
					soundVolume = float_sndVolume,
					stats_dmg = int_stats_dmg,
					stats_speed = int_stats_speed,
					stats_hp = int_stats_hp,
					allTimeKills = int_allTimeKills,
					allBatKills = int_totalBatKills,
					allZombieKills = int_totalZombieKills,
					allGhoulKills = int_totalGhoulKills,
					allDamageDealt = int_totalDamageDealt,
					allStabKills = int_totalStabKills,
					allSlashKills = int_totalSlashKills,
					allDeaths = int_totalDeaths,
					allRuns = int_totalRuns,
					totalCoins = int_totalCoins
					}

	local success, message = love.filesystem.write("save.ini", TSerial.pack(data))
end

function loadGame()
	local file = love.filesystem.getInfo("save.ini")

	if file then
		local data = love.filesystem.read("save.ini")

		--Unpacks the table data into a data table
		data = TSerial.unpack(data)

		--Assign each variable to its data value or if it can't find the value it resets to 0
		float_masterVolume = data.masterVolume or float_masterVolume
		float_mscVolume = data.musicVolume or float_mscVolume
		float_sndVolume = data.soundVolume or float_sndVolume

		int_stats_dmg = data.stats_dmg or 0
		int_stats_speed = data.stats_speed or 0
		int_stats_hp = data.stats_hp or 0

		int_allTimeKills = data.allTimeKills or 0
		int_totalBatKills = data.allBatKills or 0
		int_totalZombieKills = data.allZombieKills or 0
		int_totalGhoulKills = data.allGhoulKills or 0
		int_totalDamageDealt = data.allDamageDealt or 0
		int_totalStabKills = data.allStabKills or 0
		int_totalSlashKills = data.allSlashKills or 0
		int_totalDeaths = data.allDeaths or 0
		int_totalRuns = data.allRuns or 0
		int_totalCoins = data.totalCoins or 0
	end
end

function changeVolume(sndType, sign)
	local maxVolume = 0.8
	local minVolume = 0.2

	if sign == "+" then
		if sndType < maxVolume then
			sndType = sndType + 0.1
		else
			sndType = 1
		end
	elseif sign == "-" then
		if sndType > minVolume then
			sndType = sndType - 0.1
		else
			sndType = 0
		end
	end

	return sndType
end

function setNewVolume()
	for i,v in pairs(msc_effects) do
		v:setVolume(float_masterVolume * float_mscVolume)
	end

	for i,v in pairs(snd_effects) do
		v:setVolume(float_masterVolume * float_sndVolume)
	end
end

--Accepts string value
function playSound(snd, pitch)
	local hasPlayed = false
	snd_effects[snd]:setPitch(pitch or 1)

	snd_effects[snd]:setVolume(float_masterVolume * float_sndVolume)

	if snd_effects[snd]:isPlaying() then
		if not hasPlayed then
			hasPlayed = true
			tempsnd = snd_effects[snd]:clone()
			love.audio.play(tempsnd)
		end
	end

	if not hasPlayed then
		hasPlayed = true
		love.audio.play(snd_effects[snd])
	end
end

function playMusic(snd)
	msc_effects[snd]:setVolume(float_masterVolume * float_mscVolume)
	msc_effects[snd]:setLooping(true)

	love.audio.play(msc_effects[snd])
end

function stopMusic()
	--Loop over table and stop all music
	for i,v in pairs(msc_effects) do
		love.audio.stop(v)
	end
end

function stopSound(snd)
	--Loop over table and stop all music
	for i,v in pairs(snd_effects) do
		if i == snd then
			love.audio.stop(v)
			print(i,v)
		end
	end
end

--Takes state data from the Movement Controller and sets the animations accordingly
function animationStateController(dt, user)
	--Resets animation timing
	animationTimeScale(user, 12)
	--Change player's animation + timing based on his current state
	--Checks if we're dealing with an actual character or an object
	character_animation_change(user)
	--else
	--	object_animation_change(user)
	--end

	--Changes our animation tick rate based on timescale
	user.tick = user.tick + dt * user.anim_timescale

	--Checks if the current anim tick is greater than .9(seems to prevent footstep sound dupe)
	if user.tick > 0.9 then
		user.current_frame = user.current_frame + 1

		if user.current_frame >= #user.animationTable then
			--Instead of just resetting our current animation frame we instead switch
			--player states to falling so that the jump and flip anims don't loop
			--if user.state == "jump" or user.state == "front_flip" then
				--overrides any previous animation changes
				--stateChange(user, "fall")
			--elseif user.state == "interact" then
				--user.isInteracting = false
				--status.print(tostring(user.current_frame) .. " frame")
			--end
			--Once we reach the end of the animation data table, start back at the beginning
			--Lua indices start at 1 instead of 0
			user.current_frame = 1
		end
		--reset our timing ticks when reaching end of frames
		user.tick = 0
	end
end

--Allows ease of animation changes
function character_animation_change(user)
	if user.archetype == "player" then
		if user.state == "idle" then
			animationTimeScale(user, 6)
		elseif user.state == "run" then
			animationTimeScale(user, 16)
		end

		local player_state = ("img_plr_" .. user.state)
		--converts concatenated string back to name of Global table
		--EG: "player_" .. "idle" == "player_idle" converted to player_idle
		user.animationTable = _G[player_state]

	elseif user.archetype == "enemy" then
		if user.class.enemyType == "bat" then
			if user.state == "run" then
				animationTimeScale(user, 6)
			elseif user.state == "attack" then
				animationTimeScale(user, 6)
			end

		elseif user.class.enemyType == "zombie" then
			if user.state == "run" then
				animationTimeScale(user, 4)
			elseif user.state == "attack" then
				animationTimeScale(user, 6)
			end

		elseif user.class.enemyType == "ghoul" then
			if user.state == "run" then
				animationTimeScale(user, 6)
			elseif user.state == "attack" then
				animationTimeScale(user, 4)
			end
		end

		local enemy_state = ("img_foe_" .. user.class.enemyType .. user.class.id .. "_" .. user.state)
		user.animationTable = _G[enemy_state]
	end
end

--Changes timescale of animations(anim speed)
function animationTimeScale(user, time)
	user.anim_timescale = time
end

function getNearbyObjects(source, nearby, dist)
	if (math.dist(source.x, source.y, nearby.x, nearby.y)) < dist then
		return nearby
	end
end

function math.dist(x1,y1, x2,y2)
	return ((x2-x1)^2+(y2-y1)^2)^0.5
end

function findRotation(x1,y1,x2,y2)
	local t = -math.deg(math.atan2(x2-x1,y2-y1))
	if t < 0 then t = t + 360 end;
	return t;
end

function math.clamp(x, min, max)
    return math.max(math.min(x, max), min)
end

function checkCircularCollision(ax, ay, bx, by, ar, br)
	local dx = bx - ax
	local dy = by - ay
	local dist = math.sqrt(dx * dx + dy * dy)
	return dist < ar + br
end