
--Attack Range is essentially the size of their hitbox, set as base line and adjust accordingly
enemy = {bat01 = {name = "Bat", id = "01", enemyType = "bat", damage = 2, maxHealth = 7, attackSpeed = .1, attackRange = 60, attackRoF = .2, aggroRange = 6000, moveSpeed = 155, moveAcceleration = 95, width = 36, height = 36, hitBox = {radius = 24}, texture = nil},
		bat02 = {name = "Ice Bat", id = "02", enemyType = "bat", damage = 4, maxHealth = 16, attackSpeed = .1, attackRange = 60, attackRoF = .18, aggroRange = 6000, moveSpeed = 180, moveAcceleration = 120, width = 36, height = 36, hitBox = {radius = 24}, texture = nil},
		bat03 = {name = "Blood Bat", id = "03", enemyType = "bat", damage = 6, maxHealth = 34, attackSpeed = .1, attackRange = 60, attackRoF = .16, aggroRange = 6000, moveSpeed = 215, moveAcceleration = 160, width = 36, height = 36, hitBox = {radius = 24}, texture = nil},
		
		zombie01 = {name = "Zombie", id = "01", enemyType = "zombie", damage = 6, maxHealth = 17, attackSpeed = .22, attackRange = 70, attackRoF = .66, aggroRange = 6000, moveSpeed = 210, moveAcceleration = 105, width = 45, height = 90, scale = 3.2, hitBox = {radius = 45}, texture = nil},
		zombie02 = {name = "Rancid Zombie", id = "02", enemyType = "zombie", damage = 8, maxHealth = 29, attackSpeed = .22, attackRange = 70, attackRoF = .64, aggroRange = 6000, moveSpeed = 235, moveAcceleration = 135, width = 45, height = 90, scale = 3.2, hitBox = {radius = 45}, texture = nil},
		zombie03 = {name = "Vengeful Zombie", id = "03", enemyType = "zombie", damage = 14, maxHealth = 44, attackSpeed = .22, attackRange = 70, attackRoF = .62, aggroRange = 6000, moveSpeed = 275, moveAcceleration = 170, width = 45, height = 90, scale = 3.2, hitBox = {radius = 45}, texture = nil},
		
		ghoul01 = {name = "Spirit", id = "01", enemyType = "ghoul", damage = 9, maxHealth = 26, attackSpeed = .35, attackRange = 80, attackRoF = .88, aggroRange = 6000, moveSpeed = 290, moveAcceleration = 170, width = 50, height = 100, scale = 2, hitBox = {radius = 50}, texture = nil},
		ghoul02 = {name = "Unholy Spirit", id = "02", enemyType = "ghoul", damage = 16, maxHealth = 39, attackSpeed = .35, attackRange = 80, attackRoF = .86, aggroRange = 6000, moveSpeed = 310, moveAcceleration = 200, width = 50, height = 100, scale = 2, hitBox = {radius = 50}, texture = nil},
		ghoul03 = {name = "Tainted Spirit", id = "03", enemyType = "ghoul", damage = 26, maxHealth = 57, attackSpeed = .35, attackRange = 80, attackRoF = .84, aggroRange = 6000, moveSpeed = 335, moveAcceleration = 220, width = 50, height = 100, scale = 2, hitBox = {radius = 50}, texture = nil},

		warrior01 = {name = "Dark Warrior", id = "01", enemyType = "ghoul", damage = 12, maxHealth = 20, attackSpeed = .16, attackRange = 75, attackRoF = .44, aggroRange = 6000, moveSpeed = 300, moveAcceleration = 100, width = 50, height = 100, scale = 2, hitBox = {radius = 50}, texture = nil},
		warrior02 = {name = "Blighted Warrior", id = "02", enemyType = "ghoul", damage = 24, maxHealth = 30, attackSpeed = .16, attackRange = 75, attackRoF = .44, aggroRange = 6000, moveSpeed = 300, moveAcceleration = 150, width = 50, height = 100, scale = 2, hitBox = {radius = 50}, texture = nil},
		warrior03 = {name = "Demonic Warrior", id = "03", enemyType = "ghoul", damage = 32, maxHealth = 40, attackSpeed = .16, attackRange = 75, attackRoF = .44, aggroRange = 6000, moveSpeed = 300, moveAcceleration = 200, width = 50, height = 100, scale = 2, hitBox = {radius = 50}, texture = nil}
		}

function enemy.spawn(class, x, y)
	table.insert(enemy, {archetype = "enemy", class = class, x = x, y = y, xVel = 0, yVel = 0, health = 0, isAttacking = false, isAggro = false, hasFired = false,
						isAttacking_timer = 0, rof_timer = 0, xDir = -1, yDir = -1, pxDir = 0, pyDir = 0, handx = 0, handy = 0, isDead = false, isHurt = false,
						isHurt_timer = 0, isHurt_timer_max = .75, state = "run", animationTable = anim, current_frame = 1,
						anim_timescale = 8, tick = 0})

	enemy[#enemy].health = enemy[#enemy].class.maxHealth
	int_total_enemies = #enemy

	local str_type = enemy[#enemy].class.enemyType
	if str_type == "bat" then
		int_batCount = int_batCount + 1
	elseif str_type == "zombie" then
		int_zombieCount = int_zombieCount + 1
	elseif str_type == "ghoul" then
		int_ghoulCount = int_ghoulCount + 1
	elseif str_type == "beetle" then
		int_beetleCount = int_beetleCount + 1
	elseif str_type == "warrior" then
		int_warriorCount = int_warriorCount + 1
	end

	if isDebug then
		print(int_batCount, int_zombieCount, int_ghoulCount, int_beetleCount, int_warriorCount)
	end
end

function enemy.update(dt)
	for i,v in ipairs(enemy) do
		if v.isDead then
			dropLoot(enemy[i])
			table.remove(enemy, i)

		elseif not v.isDead then
			animationStateController(dt, enemy[i])
			AIMoveController(dt, enemy[i])
			enemy.attack(dt, enemy[i])

			--Prevents enemies from moving after attacking
			if not v.hasFired then
				if bool_isAIEnabled then
					v.x = v.x + v.xDir * (v.xVel * dt)
					v.y = v.y + v.yDir * (v.yVel * dt)
				end
			end

			enemy.collisionResolve(dt)
		end

		if v.isHurt then
			v.isHurt_timer = v.isHurt_timer + 1 * dt
			if v.isHurt_timer >= v.isHurt_timer_max then
				v.isHurt_timer = 0
				v.isHurt = false
			end
		end

		--Rate of Fire update cycle
		if v.hasFired then
			v.rof_timer = v.rof_timer + 1 * dt
			if v.rof_timer >= v.class.attackRoF then
				v.rof_timer = 0
				v.hasFired = false
			end
		end
	end
end

function enemy.draw()
	for i,v in ipairs(enemy) do
		if v.animationTable then
			love.graphics.setColor(1, 1, 1)
			if v.isHurt then
				love.graphics.setColor(1, 0, 0)
			else
				love.graphics.setColor(1, 1, 1)
			end

			love.graphics.draw(v.animationTable[v.current_frame], v.x, v.y - (v.class.height / 2), 0, -v.xDir * (v.class.scale or 2), (v.class.scale or 2), v.animationTable[v.current_frame]:getWidth() / 2)

		else
			love.graphics.setColor(1, .2, .2)
			love.graphics.rectangle("fill", v.x, v.y, v.class.width, v.class.height)
		end

		--Health Bar
		if v.isHurt then
			love.graphics.setColor(1, 1, 1)
			love.graphics.rectangle("fill", v.x - (v.class.width / 2) - 1, v.y - (v.class.height / 2) - 17, 47, 8)
			love.graphics.setColor(1, 0, 0)
			love.graphics.rectangle("fill", v.x - (v.class.width / 2), v.y - (v.class.height / 2) - 16,  math.floor((v.health/v.class.maxHealth) * 45), 6)
			love.graphics.setColor(1, 1, 1)
			love.graphics.print(v.health .. " / " .. v.class.maxHealth, v.x - (v.class.width / 2), v.y - (v.class.height / 2) - 36)
		end

		if isDebug then
			love.graphics.circle("line", v.x, v.y, v.class.hitBox.radius)
		end
	end
end

function enemy.attack(dt, attacker)
	local plr = player[1]

	if plr ~= nil then
		if not attacker.hasFired then
			if math.dist(attacker.x, attacker.y, plr.x + plr.width / 2, plr.y + plr.height / 2) <= attacker.class.attackRange then
				attacker.isAttacking_timer = attacker.isAttacking_timer + 1 * dt
			else
				attacker.isAttacking_timer = 0
			end

			if attacker.isAttacking_timer >= attacker.class.attackSpeed then
				if checkCircularCollision(attacker.x, attacker.y, plr.x + plr.width / 2, plr.y + plr.height / 2, attacker.class.hitBox.radius, plr.radius ) then
					takeDamage(attacker, plr, attacker.class.damage)

					if attacker.class.enemyType == "bat" then
						attacker.xVel = attacker.xVel + 180000 * dt
						
					elseif attacker.class.enemyType == "zombie" then
						stateChange(attacker, "attack")
						attacker.xVel = 0
						attacker.yVel = 0

					elseif attacker.class.enemyType == "ghoul" then
						stateChange(attacker, "attack")
						attacker.xVel = attacker.xVel + 250000 * dt
						attacker.yVel = attacker.yVel + 250000 * dt
					end

					attacker.isAttacking_timer = 0
					attacker.hasFired = true
				end
			end
		end
	end
end

function enemy.collisionResolve(dt)
	for i = 1, #enemy-1 do
		local partA = enemy[i]
		for j = i + 1, #enemy do
			local partB = enemy[j]
			if partA.class.name == partB.class.name then
				if checkCircularCollision(partA.x, partA.y, partB.x, partB.y, partA.class.hitBox.radius, partB.class.hitBox.radius) then
					if partA.xVel <= partA.class.moveSpeed then
						partA.xVel = partA.xVel - (partB.class.hitBox.radius/2) * (dt/10)--12
					end
					if partA.yVel <= partA.class.moveSpeed then
						partA.yVel = partA.yVel - (partB.class.hitBox.radius/2) * (dt/10)
					end
				end
			end
		end
	end
end

function enemy.spawnManager(dt)
	--Initialize starting variables
	local plr = player[1]
	local isSpawning = false
	local spawnSetPosition = {x = 0, y = 0}
	if plr ~= nil then
		spawnSetPosition.x, spawnSetPosition.y = plr.x + plr.width / 2, plr.y + plr.height / 2
	end
	local spawnRadius = 1500 - (int_difficulty * 50)
	local spawnDirection = love.math.random(1, 8)
	--local spawnRate = (int_difficulty/100) / int_difficulty) + 1
	local spawnRate = .88
	local spawnConditions = {roll1 = 0, roll2 = 0, roll3 = 0, result = 0}
	local creatureSuffix = 1
	local creatureToSpawn = nil

	--Enemy limits per category
	local batLimit = 16
	local batSpawnCondition = 65

	local zombieLimit = 12
	local zombieSpawnCondition = 115

	local ghoulLimit = 8
	local ghoulSpawnCondition = 145

	local beetleLimit = 6
	local beetleSpawnCondition = 150

	local warriorLimit = 3
	local warriorSpawnCondition = 150

	--Calculate a random number for spawn condition
	--If it matches a spawn condition or is lower, spawn the monster
	spawnConditions.roll1 = love.math.random(1, 50)
	spawnConditions.roll2 = love.math.random(1, 55)
	spawnConditions.roll3 = love.math.random(1, 75)
	spawnConditions.result = spawnConditions.roll1 + spawnConditions.roll2 + spawnConditions.roll3

	--Controls which tier of enemy will spawn on each difficulty
	if int_difficulty == 1 then
		creatureSuffix = 1
	elseif int_difficulty == 2 then
		creatureSuffix = 1
	elseif int_difficulty == 3 then
		creatureSuffix = love.math.random(1, 2)
	elseif int_difficulty == 4 then
		creatureSuffix = 2
	elseif int_difficulty == 5 then
		creatureSuffix = 2
	elseif int_difficulty == 6 then
		creatureSuffix = love.math.random(2, 3)
	elseif int_difficulty == 7 then
		creatureSuffix = 3
	end

	if spawnConditions.result >= ghoulSpawnCondition then
		if int_ghoulCount < ghoulLimit and canSpawnGhouls then
			local str_class = ("ghoul0" .. creatureSuffix)
			creatureToSpawn = enemy[str_class]
			--creatureToSpawn = enemy.ghoul01
		end

	elseif spawnConditions.result >= zombieSpawnCondition then
		if int_zombieCount < zombieLimit and canSpawnZombies then
			local str_class = ("zombie0" .. creatureSuffix)
			creatureToSpawn = enemy[str_class]
			--creatureToSpawn = enemy.zombie01
		end
	elseif spawnConditions.result >= batSpawnCondition then
		if int_batCount < batLimit then
			local str_class = ("bat0" .. creatureSuffix)
			creatureToSpawn = enemy[str_class]
			--creatureToSpawn = enemy.bat01
		end
	else
		--If can't spawn anything else, spawn this
		creatureToSpawn = nil
	end

	--Randomly chooses a side of the player to spawn on
	if spawnDirection == 1 then
		spawnSetPosition.x = spawnSetPosition.x + spawnRadius
	elseif spawnDirection == 2 then
		spawnSetPosition.x = spawnSetPosition.x - spawnRadius
	elseif spawnDirection == 3 then
		spawnSetPosition.y = spawnSetPosition.y + spawnRadius
	elseif spawnDirection == 4 then
		spawnSetPosition.y = spawnSetPosition.y - spawnRadius
	elseif spawnDirection == 5 then
		spawnSetPosition.x = spawnSetPosition.x + spawnRadius
		spawnSetPosition.y = spawnSetPosition.y + spawnRadius
	elseif spawnDirection == 6 then
		spawnSetPosition.x = spawnSetPosition.x - spawnRadius
		spawnSetPosition.y = spawnSetPosition.y - spawnRadius
	elseif spawnDirection == 7 then
		spawnSetPosition.x = spawnSetPosition.x + spawnRadius
		spawnSetPosition.y = spawnSetPosition.y - spawnRadius
	elseif spawnDirection == 8 then
		spawnSetPosition.x = spawnSetPosition.x - spawnRadius
		spawnSetPosition.y = spawnSetPosition.y + spawnRadius
	end

	--Spawn enemies according to spawnrate interval
	if bool_isSpawnerEnabled and int_total_enemies <= int_max_enemies then
		if isSpawning == false then
			int_spawnRate_timer = int_spawnRate_timer + 1 * dt

			if int_spawnRate_timer >= spawnRate then
				if creatureToSpawn then
					enemy.spawn(creatureToSpawn, spawnSetPosition.x, spawnSetPosition.y)
				end

				int_spawnRate_timer = 0
				isSpawning = true
			end
		end
	end
end