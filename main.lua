
--External Libaries
gamera = require "resources/libraries/gamera"
require "resources/libraries/TSerial"
rs = require("resources/libraries/resolution_solution")

--My Libaries
status = require "status_text"

--Load in necessary lua files
require "resources"
require "utility"
require "button"
require "player"
require "enemy"
require "weapon"
require "projectiles"
require "consumable"

--Required to use certain character types
local utf8 = require("utf8")

function love.load()
	str_BUILD_VERSION = "0.2b"
	str_BUILD_DATE = "02/20/2023"
	str_LOVE_VERSION = "11.3"
	str_GAME_NAME = "Dark\nDomains"
	str_FoN = "Dungeon Keepers"
	isDebug = false

	love.graphics.setDefaultFilter("nearest", "nearest")
	love.keyboard.setTextInput(false)
	love.keyboard.setKeyRepeat(false)

	--Load our textures, sounds, etc
	resourceLoad()

	float_masterVolume = 0.6
	float_mscVolume = 0.1
	float_sndVolume = 0.1
	--changeVolume("music", int_mscVolume)
	--changeVolume("effects", int_sndVolume)

	love.graphics.setFont(font_gameText)
	love.graphics.setBackgroundColor(0, 0, 0)
	int_window_width, int_window_height = 1920, 1080
	--int_user_window_width, int_user_window_height = love.window.getDesktopDimensions()
	int_user_window_width, int_user_window_height = 1280, 720
	int_world_width, int_world_height = 4096, 4096

	rs.init({width = int_window_width, height = int_window_height, mode = 2})
	rs.nearestFilter(true)

	--Sets actual window resolution
	rs.setMode(int_user_window_width, int_user_window_height, {resizable = true})
	love.window.setFullscreen(false)

	love.mouse.setCursor(crsr_default)

	--initialize camera
	cam = gamera.new(0, 0, 64, 64)
	cam:setScale(1)
	cam:setWindow(0, 0, int_window_width, int_window_height)
	cam:setWorld(0, 0, int_world_width, int_world_height)

	--initialize gameplay variables
	str_gameState = "menu"
	str_prevGameState = ""
	str_panelOpen = ""
	bool_gamePaused = false
	bool_gameFocus = false
	bool_optionsOpen = false

	input_moveLeft, input_moveRight, input_moveForward, input_moveBackward, input_interact, input_pause = "a", "d", "w", "s", "f", "escape"
	input_total_keys_pressed = {}

	initialGameSettings()
	reloadGameSettings()

--Load Save Game (if available)
	loadGame()

--Menu Buttons
	button.spawn("img_ui_button_QD", "play", "menu", int_window_width/2, int_window_height/2, 300, 125, "Play")
	button.spawn("img_ui_button_QD", "shop", "menu", int_window_width/2, int_window_height/2 + 150, 300, 125, "Shop")
	button.spawn("img_ui_button_QD", "quit", "menu", int_window_width/2, int_window_height/2 + 300, 300, 125, "Quit")
	button.spawn("img_ui_button_QD", "credits", "menu", int_window_width/2 + 75, int_window_height/2 + 410, 135, 65, "Credits")
	button.spawn("img_ui_button_QD", "stats", "menu", int_window_width/2 - 75, int_window_height/2 + 410, 135, 65, "Stats")
	button.spawn("img_ui_button_QD", "options", "menu", int_window_width/2 + 225, int_window_height/2 + 410, 135, 65, "Options")
--Shop Buttons
	button.spawn("img_ui_shop_skull_QD", "upgrade1", "shop", int_window_width/2 - 300, int_window_height/2, 258, 258)
	button.spawn("img_ui_shop_boot_QD", "upgrade2", "shop", int_window_width/2, int_window_height/2, 258, 258)
	button.spawn("img_ui_shop_heart_QD", "upgrade3", "shop", int_window_width/2 + 300, int_window_height/2, 258, 258)
	button.spawn("img_ui_button_QD", "back", "shop", int_window_width/2, int_window_height/2 + 450, 300, 125, "Back")
--Pause Buttons
	button.spawn("img_ui_button_QD", "resume", "pause", int_window_width/2, int_window_height/2, 300, 125, "Resume")
	button.spawn("img_ui_button_QD", "quitSession", "pause", int_window_width/2, int_window_height/2 + 300, 300, 125, "Quit")
--Credits Buttons
	button.spawn("img_ui_button_QD", "back", "credits", int_window_width/2 + 300, int_window_height/2 + 430, 300, 125, "Back")
--GameOver Buttons
	button.spawn("img_ui_button_QD", "returnMenu", "gameOver", int_window_width/2, int_window_height/2 + 400, 300, 125, "Menu")
--Stats Buttons
	button.spawn("img_ui_button_QD", "back", "stats", int_window_width/2 + 300, int_window_height/2 + 430, 300, 125, "Back")
--Options Buttons
	button.spawn("img_ui_button_QD", "master_vol_up", "options", int_window_width/2+32, int_window_height/2-92, 64, 64, "+")
	button.spawn("img_ui_button_QD", "master_vol_down", "options", int_window_width/2-40, int_window_height/2-92, 64, 64, "-")
	button.spawn("img_ui_button_QD", "msc_vol_up", "options", int_window_width/2+32, int_window_height/2+12, 64, 64, "+")
	button.spawn("img_ui_button_QD", "msc_vol_down", "options", int_window_width/2-40, int_window_height/2+12, 64, 64, "-")
	button.spawn("img_ui_button_QD", "snd_vol_up", "options", int_window_width/2+32, int_window_height/2+124, 64, 64, "+")
	button.spawn("img_ui_button_QD", "snd_vol_down", "options", int_window_width/2-40, int_window_height/2+124, 64, 64, "-")
	button.spawn("img_ui_button_QD", "backPanel", "options", int_window_width/2 + 300, int_window_height/2 + 430, 300, 125, "Back")

	playMusic("msc_menuscreen", .06)
end

function love.update(dt)
	--int_mouseX, int_mouseY = love.mouse.getPosition()
	--camMouseX, camMouseY = cam:toWorld(int_mouseX, int_mouseY)

	--Gets relevant mouse position according to scaled window
	int_mouseX, int_mouseY = rs.toGame(love.mouse.getPosition())
	--Gets mouse position according to the camera's position
	camMouseX, camMouseY = cam:toWorld(int_mouseX, int_mouseY)

	if str_gameState == "ingame" then
		if not bool_gamePaused then
			player.update(dt)
			weapon.update(dt)
			consumable.update(dt)
			enemy.update(dt)
			enemy.spawnManager(dt)
			totalTimeUpdate(dt)

			if love.keyboard.isDown("y") then
				player.kill(dt, player[1], .5)
			end
		end
	end

	button.update(dt)
	status.update(dt)
	
	--Destroys all objects when this bool is flipped true
	if bool_cleanup then
		destroyAllObjects()
	end
end

function love.draw()
	rs.start()

	love.graphics.setFont(font_gameText)

	if str_gameState == "menu" then
		menuDraw()
		optionsDraw()

	elseif str_gameState == "shop" then
		shopDraw()

	elseif str_gameState == "ingame" then
		--Draws to worldspace
		cam:draw(function()

		--Map drawing
		love.graphics.draw(img_map_dungeon, 0, 0)

		player.draw()
		weapon.draw()
		consumable.draw()
		enemy.draw()
		end)

		hudDraw()
		optionsDraw()

	elseif str_gameState == "gameOver" then
		gameOverDraw()

	elseif str_gameState == "credits" then
		creditsDraw()
	elseif str_gameState == "stats" then
		gameStatsDraw()
	end

	status.draw()
	button.draw()

	rs.stop()
end

function love.resize(w, h)
	rs.resize(w, h)
end

function love.keypressed(key)
	--Gathers any key pressed
	input_total_keys_pressed[key] = true

	if str_gameState == "ingame" then
		if key == (input_pause) then
			pauseGame()
		end
	end

	if key == (input_interact) then
		if not bool_gamePaused then
			playerInteractController(dt)
		end
	end

	if key == "`" then
		if isDebug then
			isDebug = false
		else
			isDebug = true
		end

		love.mouse.setVisible(isDebug)
	end
end

function love.keyreleased(key)
	--Resets keys pressed
	input_total_keys_pressed[key] = nil
end

function love.mousepressed(button, x, y)
end

function love.mousereleased(x, y, mButton)
	button.clickAction(mButton)
end

function love.focus(focus)
	if focus then
		bool_gameFocus = true
	else
		bool_gameFocus = false
	end
end

function totalTimeUpdate(dt)
	int_totalTime = int_totalTime + 1 * dt

	--Checks when the timer reaches the 45 second mark
	--if math.floor(int_totalTime+1) % 44 == 0 then
	if math.floor(math.mod(int_totalTime,60)) == 45 then
		if not canSpawnZombies then
			canSpawnZombies = true
			--print(tostring(canSpawnZombies))

		end

	--Checks when the timer reaches the 2 minute mark
	--elseif math.floor(int_totalTime+1) % 59 == 0 then
	elseif math.floor(math.mod(int_totalTime, 3600)/60) == 2 then
		if not canSpawnGhouls then
			canSpawnGhouls = true
			--print(tostring(canSpawnGhouls))

		end

	--Checks when timer reaches the minute mark
	elseif math.floor(math.mod(int_totalTime,60)) == 59 then
		if not bool_difficultyChanged and int_difficulty < 5 then
			bool_difficultyChanged = true
			int_difficulty = int_difficulty + 1
			--print(tostring(int_difficulty))

		end
	else
		bool_difficultyChanged = false
	end
end

function menuDraw()
	local title_main_scale = 1.5
	local title_outline_scale = 1.51

	love.graphics.setColor(1,1,1)
	love.graphics.draw(img_ui_menu_bg, 0, 0)

	love.graphics.setFont(font_title)
	love.graphics.setColor(0,0,0)
	love.graphics.printf(str_GAME_NAME, 32 - (font_title:getWidth("Dark Domains")/2)*title_outline_scale, 64, int_window_width, "center", 0, title_outline_scale)
	
	love.graphics.setColor(clr_menu_font)
	love.graphics.printf(str_GAME_NAME, 32 - (font_title:getWidth("Dark Domains")/2)*title_main_scale, 64, int_window_width, "center", 0, title_main_scale)

	love.graphics.setColor(1,1,1)
	love.graphics.setFont(font_hudText)
	love.graphics.printf("Total Coins: " .. int_totalCoins, 0, int_window_height - 75, int_window_width, "center")

	gameInfoDraw()
end

function shopDraw()
	local title_main_scale = 1.5
	local title_outline_scale = 1.51

	love.graphics.setColor(1,1,1)
	love.graphics.draw(img_ui_menu_bg, 0, 0)

	love.graphics.setFont(font_title)
	love.graphics.setColor(0,0,0)
	love.graphics.printf("Forge your Destiny", 256 - (font_title:getWidth("Forge your Destiny")/2)*title_outline_scale, 64, int_window_width, "center", 0, title_outline_scale)

	love.graphics.setColor(clr_menu_font)
	love.graphics.printf("Forge your Destiny", 256 - (font_title:getWidth("Forge your Destiny")/2)*title_main_scale, 64, int_window_width, "center", 0, title_main_scale)

	love.graphics.setColor(1,1,1)
	love.graphics.setFont(font_hudText)
	love.graphics.printf("Total Coins: " .. int_totalCoins, 0, int_window_height-190, int_window_width, "center")

	love.graphics.draw(img_ui_hp_bar_empty, 532, int_window_height - 730, 0, 4, 12)
	love.graphics.draw(img_ui_hp_bar_empty, 832, int_window_height - 730, 0, 4, 12)
	love.graphics.draw(img_ui_hp_bar_empty, 1132, int_window_height - 730, 0, 4, 12)
	love.graphics.printf("Damage Increase (5%)\nCost: " .. tostring((int_stats_dmg + 1) * 500), -300, int_window_height - 732, int_window_width, "center")
	love.graphics.printf("Speed Increase (5%)\nCost: " .. tostring((int_stats_speed + 1) * 500), 0, int_window_height - 732, int_window_width, "center")
	love.graphics.printf("HP Increase (10%)\nCost: " .. tostring((int_stats_hp + 1) * 500), 300, int_window_height - 732, int_window_width, "center")

	for i = 1, int_stats_max do
		love.graphics.draw(img_ui_shop_empty_slot, (int_window_width/2 - 423) + 36 * i, int_window_height - 380)
		--love.graphics.rectangle("line", (int_window_width/2 -380) + 24 * i, int_window_height - 300, 16, 16)
	end
	for i = 1, int_stats_max do
		love.graphics.draw(img_ui_shop_empty_slot, (int_window_width/2 - 123) + 36 * i, int_window_height - 380)
		--love.graphics.rectangle("line", (int_window_width/2-80) + 24 * i, int_window_height - 300, 16, 16)
	end
	for i = 1, int_stats_max do
		love.graphics.draw(img_ui_shop_empty_slot, (int_window_width/2 + 178) + 36 * i, int_window_height - 380)
		--love.graphics.rectangle("line", (int_window_width/2+220) + 24 * i, int_window_height - 300, 16, 16)
	end
	for i = 1, int_stats_dmg do
		love.graphics.draw(img_ui_shop_full_slot, (int_window_width/2 - 423) + 36 * i, int_window_height - 380)
		--love.graphics.rectangle("fill", (int_window_width/2 -380) + 24 * i, int_window_height - 300, 16, 16)
	end
	for i = 1, int_stats_speed do
		love.graphics.draw(img_ui_shop_full_slot, (int_window_width/2 - 123) + 36 * i, int_window_height - 380)
		--love.graphics.rectangle("fill", (int_window_width/2-80) + 24 * i, int_window_height - 300, 16, 16)
	end
	for i = 1, int_stats_hp do
		love.graphics.draw(img_ui_shop_full_slot, (int_window_width/2 + 178) + 36 * i, int_window_height - 380)
		--love.graphics.rectangle("fill", (int_window_width/2+220) + 24 * i, int_window_height - 300, 16, 16)
	end

	gameInfoDraw()
end

function hudDraw()
	local plr = player[1]
	local seconds_zero = "0"
	local minutes_zero = seconds_zero

	--Extra formating for seconds timer
	if math.floor(math.mod(int_totalTime,60)) > 9 then
		seconds_zero = ""
	end
	--Extra formating for minutes timer
	if math.floor(math.mod(int_totalTime, 3600)/60) > 9 then
		minutes_zero = ""
	end

	love.graphics.setColor(1, 1, 1, .7)
	love.graphics.setFont(font_hudText)
	love.graphics.print("FPS: " .. love.timer.getFPS(), 0, int_window_height-26)
	love.graphics.printf("Current Time: " .. minutes_zero .. math.floor(math.mod(int_totalTime, 3600)/60) .. ":" .. seconds_zero .. math.floor(math.mod(int_totalTime,60)), 0, 12, int_window_width, "center")
	love.graphics.printf("Kills: " .. int_totalKills, -24, int_window_height - 128, int_window_width, "right")
	love.graphics.printf("Total Enemies: " .. int_total_enemies, -24, int_window_height - 96, int_window_width, "right")
	love.graphics.printf("Total Coins: " .. int_totalCoins, -24, int_window_height - 64, int_window_width, "right")

	player.hud(plr)
end

function gameOverDraw()
	local plr = player[1]
	local lastKilledBy = str_FoN
	--love.graphics.setColor(1,1,1)
	--love.graphics.draw(img_ui_menu_bg, 0, 0)

	love.graphics.setColor(1, .1, .1, .7)
	love.graphics.setFont(font_title)
	love.graphics.printf("Oh Dear,\nYou've Been Slain...", 0, 96, int_window_width, "center")

	love.graphics.setColor(clr_menu_font)
	love.graphics.printf("Stats:", 0, 350, int_window_width, "center")
	love.graphics.setFont(font_creditsText)
	love.graphics.printf("Bat Kills: " .. int_batKills, 0, 470, int_window_width, "center")
	love.graphics.printf("Zombie Kills: " .. int_zombieKills, 0, 500, int_window_width, "center")
	love.graphics.printf("Spirit Kills: " .. int_ghoulKills, 0, 530, int_window_width, "center")
	--love.graphics.printf("Beetle Kills:", 0, 460, int_window_width, "center")
	--love.graphics.printf("Warrior Kills:", 0, 460, int_window_width, "center")

	if plr.lastHurtBy ~= (str_FoN or nil) then
		lastKilledBy = plr.lastHurtBy.class.name
	end
	love.graphics.printf("You were killed by a " .. lastKilledBy, 0, 620, int_window_width, "center")

	gameInfoDraw()
end

function creditsDraw()

	--[[	local creditsTextL = "Created By:\nThe Righteous Ringos\n\nGame Design:\nAlex Calvelage\nGunner Braun\n\nProgramming:\nAlex Calvelage\n\nArtwork, Animations, Textures:\nGunner Braun\nAlex Calvelage\n\n"
	local creditsTextL2 = "------------\nPowered By:\nLove2D 11.3\n\nFonts Used:\nDungeon Font - vrtxrry\nEvil Empire - Tup Wanders\nNew Rocker - Pablo Impallari, Brenda Gallo, Rodrigo Fuenzalida\n\n"
	local creditsTextR = "Music Used:\nNight Vigil\nKevin MacLeod (incompetech.com)\nLicensed under Creative Commons: By Attribution 3.0\nhttp://creativecommons.org/licenses/by/3.0/\n\nCruising for Goblins\nKevin MacLeod (incompetech.com)\nLicensed under Creative Commons: By Attribution 3.0\nhttp://creativecommons.org/licenses/by/3.0/\n"
	local creditsTextR2 = "\n------------\nSound Effects By:\n GameBurp.com"
	local creditsTextC = "Libraries:\nGamera - Enrique García Cota\nTSerial - Taehl\nResolution Solution - Vovkiv"
	]]
	local creditsTextL = "Created By:\nThe Righteous Ringos\n\nGame Design:\nAlex Calvelage\nGunner Braun\n\nProgramming:\nAlex Calvelage\n\nArtwork, Animations, Textures:\nGunner Braun\nAlex Calvelage\n\n"
	local creditsTextL2 = "------------\nPowered By:\nLove2D 11.3\n\nLibraries Used:\nGamera - Enrique García Cota\nTSerial - Taehl\nResolution Solution - Vovkiv\n\n"
	local creditsTextR = "Music Used:\nNight Vigil\nKevin MacLeod (incompetech.com)\nLicensed under Creative Commons: By Attribution 3.0\nhttp://creativecommons.org/licenses/by/3.0/\n\nCruising for Goblins\nKevin MacLeod (incompetech.com)\nLicensed under Creative Commons: By Attribution 3.0\nhttp://creativecommons.org/licenses/by/3.0/\n"
	local creditsTextR2 = "\nSound Effects By:\n GameBurp.com\n\n"
	local creditsTextC = "------------\nFonts Used:\nDungeon Font - vrtxrry\nEvil Empire - Tup Wanders\nNew Rocker - Pablo Impallari, Brenda Gallo, Rodrigo Fuenzalida"

	love.graphics.setColor(clr_menu_font)
	love.graphics.setFont(font_title)
	love.graphics.printf("Credits:", 0, 72, int_window_width, "center")
	love.graphics.setFont(font_creditsText)
	love.graphics.printf(creditsTextL .. creditsTextL2, -400, 216, int_window_width, "center")
	love.graphics.printf(creditsTextR .. creditsTextR2 .. creditsTextC, 300, 216, int_window_width, "center")

	gameInfoDraw()
end

function gameInfoDraw()
	love.graphics.setColor(1,1,1)
	love.graphics.setFont(font_hudText)
	love.graphics.print("VER: " .. str_BUILD_VERSION .. "\nBuild Date: " .. str_BUILD_DATE, 0, 0)
end

function gameStatsDraw()
	local statsText1 = ("# of Runs: " .. int_totalRuns .. "\n# of Deaths: " .. int_totalDeaths)
	local statsText2 = ("\n------------\nBats Killed: " .. int_totalBatKills .. "\nZombies Killed: " .. int_totalZombieKills .. "\nSpirits Killed: " .. int_totalGhoulKills)
	local statsText3 = ("\n------------\nAll Time Kills: " .. int_allTimeKills .. "\nTotal Damage Dealt: " .. int_totalDamageDealt .. "\nStab Weapon Kills: " .. int_totalStabKills .. "\nSlash Weapon Kills: " .. int_totalSlashKills)

	love.graphics.setColor(1,1,1)
	love.graphics.setFont(font_title)
	love.graphics.printf("Stats:", 0, 72, int_window_width, "center")
	love.graphics.setFont(font_creditsText)
	love.graphics.printf(statsText1 .. statsText3 .. statsText2, 0, int_window_height/2-200, int_window_width, "center")
end

function optionsDraw()
	if str_panelOpen == "options" then
		love.graphics.setColor(1,1,1)
		love.graphics.draw(img_ui_hp_bar_empty, int_window_width/2-(img_ui_hp_bar_empty:getWidth()*4), int_window_height - 820, 0, 8, 128)
		love.graphics.setColor(clr_menu_font)
		love.graphics.setFont(font_title)
		love.graphics.printf("Options:", 0, 256, int_window_width, "center")

		love.graphics.setFont(font_creditsText)
		love.graphics.printf("Master Volume: " .. float_masterVolume, 0, int_window_height/2-162, int_window_width, "center")
		love.graphics.printf("Music Volume: " .. float_mscVolume, 0, int_window_height/2-55, int_window_width, "center")
		love.graphics.printf("Effects Volume: " .. float_sndVolume, 0, int_window_height/2+55, int_window_width, "center")
	end
end