

enemy = {bat01 = {name = "Bat", id = "01", enemyType = "bat", damage = 2, maxHealth = 7, attackSpeed = .1, attackRange = 60, attackRoF = .2, aggroRange = 6000, moveSpeed = 100, moveAcceleration = 45, width = 36, height = 36, hitBox = {radius = 24}, texture = nil},
		bat02 = {name = "Ice Bat", id = "02", enemyType = "bat", damage = 3, maxHealth = 15, attackSpeed = .1, attackRange = 60, attackRoF = .16, aggroRange = 6000, moveSpeed = 100, moveAcceleration = 85, width = 36, height = 36, hitBox = {radius = 24}, texture = nil},
		bat03 = {name = "Blood Bat", id = "03", enemyType = "bat", damage = 5, maxHealth = 22, attackSpeed = .1, attackRange = 60, attackRoF = .16, aggroRange = 6000, moveSpeed = 100, moveAcceleration = 100, width = 36, height = 36, hitBox = {radius = 24}, texture = nil},
		
		zombie01 = {name = "Zombie", id = "01", enemyType = "zombie", damage = 6, maxHealth = 17, attackSpeed = .16, attackRange = 70, attackRoF = .66, aggroRange = 6000, moveSpeed = 200, moveAcceleration = 65, width = 45, height = 90, scale = 3.2, hitBox = {radius = 45}, texture = nil},
		zombie02 = {name = "Rancid Zombie", id = "02", enemyType = "zombie", damage = 8, maxHealth = 25, attackSpeed = .16, attackRange = 70, attackRoF = 1.25, aggroRange = 6000, moveSpeed = 200, moveAcceleration = 100, width = 45, height = 90, scale = 3.2, hitBox = {radius = 45}, texture = nil},
		zombie03 = {name = "Vengeful Zombie", id = "03", enemyType = "zombie", damage = 16, maxHealth = 35, attackSpeed = .16, attackRange = 70, attackRoF = 1.25, aggroRange = 6000, moveSpeed = 200, moveAcceleration = 125, width = 45, height = 90, scale = 3.2, hitBox = {radius = 45}, texture = nil},
		
		ghoul01 = {name = "Spirit", id = "01", enemyType = "ghoul", damage = 8, maxHealth = 25, attackSpeed = .3, attackRange = 80, attackRoF = .66, aggroRange = 6000, moveSpeed = 300, moveAcceleration = 85, width = 50, height = 100, scale = 2, hitBox = {radius = 50}, texture = nil},
		ghoul02 = {name = "Unholy Spirit", id = "02", enemyType = "ghoul", damage = 24, maxHealth = 30, attackSpeed = .16, attackRange = 75, attackRoF = .44, aggroRange = 6000, moveSpeed = 300, moveAcceleration = 150, width = 50, height = 100, scale = 2, hitBox = {radius = 50}, texture = nil},
		ghoul03 = {name = "Tainted Spirit", id = "03", enemyType = "ghoul", damage = 32, maxHealth = 40, attackSpeed = .16, attackRange = 75, attackRoF = .44, aggroRange = 6000, moveSpeed = 300, moveAcceleration = 200, width = 50, height = 100, scale = 2, hitBox = {radius = 50}, texture = nil},

		warrior01 = {name = "Dark Warrior", id = "01", enemyType = "ghoul", damage = 12, maxHealth = 20, attackSpeed = .16, attackRange = 75, attackRoF = .44, aggroRange = 6000, moveSpeed = 300, moveAcceleration = 100, width = 50, height = 100, scale = 2, hitBox = {radius = 50}, texture = nil},
		warrior02 = {name = "Blighted Warrior", id = "02", enemyType = "ghoul", damage = 24, maxHealth = 30, attackSpeed = .16, attackRange = 75, attackRoF = .44, aggroRange = 6000, moveSpeed = 300, moveAcceleration = 150, width = 50, height = 100, scale = 2, hitBox = {radius = 50}, texture = nil},
		warrior03 = {name = "Demonic Warrior", id = "03", enemyType = "ghoul", damage = 32, maxHealth = 40, attackSpeed = .16, attackRange = 75, attackRoF = .44, aggroRange = 6000, moveSpeed = 300, moveAcceleration = 200, width = 50, height = 100, scale = 2, hitBox = {radius = 50}, texture = nil}
		}

function enemy.spawn(class, x, y)
	table.insert(enemy, {archetype = "enemy", class = class, x = x, y = y, xVel = 0, yVel = 0, health = 0, isAttacking = false, isAggro = false, hasFired = false,
						isAttacking_timer = 0, rof_timer = 0, xDir = -1, yDir = -1, pxDir = 0, pyDir = 0, handx = 0, handy = 0, isDead = false, isHurt = false,
						isHurt_timer = 0, isHurt_timer_max = .75, state = "idle", animationTable = anim, current_frame = 1,
						anim_timescale = 8, tick = 0, moveSpeedCap = 0})

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
				v.x = v.x + v.xDir * (v.xVel * dt)
				v.y = v.y + v.yDir * (v.yVel * dt)
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
			if math.dist(attacker.x + attacker.class.width / 2, attacker.y + attacker.class.height / 2, plr.x + plr.width / 2, plr.y + plr.height / 2) <= attacker.class.attackRange then
				attacker.isAttacking_timer = attacker.isAttacking_timer + 1 * dt
			else
				attacker.isAttacking_timer = 0
			end

			if attacker.isAttacking_timer >= attacker.class.attackSpeed then
				if checkCircularCollision(attacker.x + attacker.class.width / 2, attacker.y + attacker.class.height / 2, plr.x + plr.width / 2, plr.y + plr.height / 2, attacker.class.hitBox.radius, plr.radius ) then
					takeDamage(attacker, plr, attacker.class.damage)

					if attacker.class.enemyType == "bat" then
						attacker.xVel = attacker.xVel + 170000 * dt
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

--Looping over enemies an extra time without it being necessary because of update()
function enemy.collisionResolve(dt)
	for i = 1, #enemy-1 do
		local partA = enemy[i]
		for j = i + 1, #enemy do
			local partB = enemy[j]
			if checkCircularCollision(partA.x, partA.y, partB.x, partB.y, partA.class.hitBox.radius, partB.class.hitBox.radius) then
				partB.xVel = partB.xVel + (partA.class.hitBox.radius / 2) * (dt/3)
				partB.yVel = partB.yVel + (partA.class.hitBox.radius / 2) * (dt/3)
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
	local spawnRadius = 1250 --possibly increase?
	local spawnDirection = love.math.random(1, 4)
	local spawnRate = (.25 / int_difficulty) + 1
	local spawnConditions = {roll1 = 0, roll2 = 0, roll3 = 0, result = 0}
	local creatureToSpawn = nil

	--Enemy limits per category
	local batLimit = 16
	local batSpawnCondition = 80

	local zombieLimit = 10
	local zombieSpawnCondition = 120

	local ghoulLimit = 4
	local ghoulSpawnCondition = 155

	local beetleLimit = 6
	local beetleSpawnCondition = 150

	local warriorLimit = 3
	local warriorSpawnCondition = 150

	--Calculate a random number for spawn condition * difficulty
	--If it matches a spawn condition or is lower, spawn the monster
	spawnConditions.roll1 = love.math.random(1, 50)
	spawnConditions.roll2 = love.math.random(1, 50)
	spawnConditions.roll3 = love.math.random(1, 50) * int_difficulty
	spawnConditions.result = spawnConditions.roll1 + spawnConditions.roll2 + spawnConditions.roll3

	if spawnConditions.result >= ghoulSpawnCondition then
		if int_ghoulCount < ghoulLimit and canSpawnGhouls then
			creatureToSpawn = enemy.ghoul01
		end

	elseif spawnConditions.result >= zombieSpawnCondition then
		if int_zombieCount < zombieLimit and canSpawnZombies then
			creatureToSpawn = enemy.zombie01
		end

	elseif spawnConditions.result >= batSpawnCondition then
		if int_batCount < batLimit then
			creatureToSpawn = enemy.bat01
		end
	else
		--If can't spawn anything else, spawn this
		creatureToSpawn = enemy.bat01
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
	end

	--Spawn enemies according to spawnrate interval
	if int_total_enemies <= int_max_enemies then
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