
button = {}
function button.spawn(quad, action, activeState, x, y, w, h, text, held)
	table.insert(button, {id = #button + 1, type = "button", action = action, activeState = activeState, text = text or nil, enabled = enabled, quad = quad, quad_overlay = nil, x = x, y = y, width = w or 193, height = h or 49, highlight = false, held = held or false, heldTimer = {current_time = 0, trigger_time = .1}})
	--Center our button according to our width, height
	button[#button].x, button[#button].y = button[#button].x - (button[#button].width / 2), button[#button].y - (button[#button].height / 2)
	--Concatenate quad extension
	button[#button].quad = tostring(button[#button].quad)
end

function button.update(dt)
	for i = 1, #button do
		button.detectVisibility(button[i])

		--Prevents buttons from being selectable if they aren't enabled(drawn+active)
		if button[i].enabled then
			button.highlight(button[i])

			if (button[i].highlight and button[i].held and love.mouse.isDown(1)) then
				button[i].heldTimer.current_time = button[i].heldTimer.current_time + 1 * dt
				if button[i].heldTimer.current_time >= button[i].heldTimer.trigger_time then
					button.clickAction(1)
					button[i].heldTimer.current_time = 0
				end
			end

			if not love.mouse.isDown(1) then
				button[i].heldTimer.current_time = 0
			end
		end
	end
end

function button.draw()
	--Force clear spritebatch to prevent render errors
	if bool_gameFocus then
		--Clears our spritebatch draw call
		sb_ui_button:clear()
	end
	
	for i = 1, #button do
		if button[i].enabled then
			local sx, sy, sw, sh = _G[button[i].quad]:getViewport() --getViewport() grabs the Quad's dimensions
			--Turn string back into Global and add our button to the spritebatch
			sb_ui_button:add(_G[button[i].quad], button[i].x, button[i].y, 0, button[i].width / sw, button[i].height / sh)
		end
	end

	--Draws our spritebatch
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(sb_ui_button)

	--Loop over table twice to render highlight visual effect*
	for i = 1, #button do
		if button[i].enabled then
			if button[i].quad_overlay ~= nil then
				local sx, sy, sw, sh = _G[button[i].quad]:getViewport()
				love.graphics.setColor(1, 1, 1)
				love.graphics.draw(img_ui_buttons, button[i].quad_overlay, button[i].x, button[i].y, 0, button[i].width / sw, button[i].height / sh)
			end

			--Edge case correction for various buttons
			if button[i].text ~= nil then
				local yoffset = 0
				local scaleX = 1
				if button[i].text == "Delete" then
					yoffset = 4
				elseif #button[i].text >= 5 then
					love.graphics.setFont(font_subtitle)
					yoffset = 12
					if button[i].text == "Fullscreen" then
						love.graphics.setFont(font_subbertitle)
						yoffset = 18
					end
				elseif #button[i].text <= 1 then
					love.graphics.setFont(font_title)
					yoffset = -45
				else
					love.graphics.setFont(font_title)
					yoffset = -6
				end

				if button[i].text == "Credits" or button[i].text == "Stats" or (button[i].text == "Options" and str_gameState == "menu") or button[i].text == "Delete" then
					love.graphics.setFont(font_subbertitle)
				end

				love.graphics.setColor(clr_menu_font)

				--draws button text if available
				love.graphics.printf(button[i].text, button[i].x, button[i].y + yoffset, button[i].width, "center", 0, scaleX)
			end
		end
	end
end

function button.detectVisibility(me)
	--Checks to make sure buttons are only usable/rendered when they need to be.
	--CHECKS: PAUSE MENU -> PANEL BUTTONS -> EDITOR BUTTONS + MENU BUTTONS
	if (me.activeState == "pause" and bool_gamePaused and not bool_optionsOpen) or (me.activeState == str_panelOpen) or (me.activeState == str_gameState and not bool_gamePaused and not bool_optionsOpen) then
		me.enabled = true
	else
		me.enabled = false
		--if a button is selected and then it becomes disabled, this ensures that it is unselected
		me.highlight = false
	end
end

function button.highlight(me)
	if int_mouseX >= me.x and
	int_mouseX <= me.x + me.width and
	int_mouseY >= me.y and
	int_mouseY <= me.y + me.height then
		me.highlight = true
		local quad_string = tostring(me.quad) .. "_2"
		me.quad_overlay = _G[quad_string]
		LET_BUTTON_SELECTED = me.highlight
	else
		me.highlight = false
		me.quad_overlay = nil
	end
end

function button.clickAction(mButton)
	if mButton == 1 then
		for i = 1, #button do
			if button[i].highlight then
				local action = button[i].action

--MAIN MENU ACTIONS
				if action == "play" then
					switchGameState("ingame")
					startNewGame()
				elseif action == "shop" then
					switchGameState("shop")
				elseif action == "back" then
					switchGameState(str_prevGameState)
				elseif action == "quit" then
					love.event.quit()
				elseif action == "credits" then
					switchGameState("credits")
				elseif action == "options" then
					button.openPanel(action)

--PAUSE MENU ACTIONS
				elseif action == "resume" then
					--Will unpause game
					pauseGame()
				elseif action == "quitSesh" then
					button.openPanel(action)
				elseif action == "quitConfirm" then
					button.closePanel()
					switchGameState("menu")
					finishCurrentGame()

--SHOP MENU ACTIONS
				elseif action == "upgrade1" then
					upgradeStat(action)
				elseif action == "upgrade2" then
					upgradeStat(action)
				elseif action == "upgrade3" then
					upgradeStat(action)

--GAME OVER ACTIONS
				elseif action == "returnMenu" then
					switchGameState("menu")
					finishCurrentGame()

--STATS SCREEN ACTIONS
				elseif action == "stats" then
					switchGameState("stats")

--OPTIONS ACTIONS
				elseif action == "master_vol_up" then
					float_masterVolume = changeVolume(float_masterVolume, "+")
					setNewVolume()
					saveGame()

				elseif action == "master_vol_down" then
					float_masterVolume = changeVolume(float_masterVolume, "-")
					setNewVolume()
					saveGame()

				elseif action == "msc_vol_up" then
					float_mscVolume = changeVolume(float_mscVolume, "+")
					setNewVolume()
					saveGame()

				elseif action == "msc_vol_down" then
					float_mscVolume = changeVolume(float_mscVolume, "-")
					setNewVolume()
					saveGame()

				elseif action == "snd_vol_up" then
					float_sndVolume = changeVolume(float_sndVolume, "+")
					setNewVolume()
					saveGame()

				elseif action == "snd_vol_down" then
					float_sndVolume = changeVolume(float_sndVolume, "-")
					setNewVolume()
					saveGame()

				elseif action == "fullscreen" then
					fullscreenToggle()
					
				elseif action == "delete_save" then
					if str_gameState == "menu" then
						button.openPanel(action)
					else
						button.openPanel("error")
					end
				elseif action == "deleteConfirm" then
					button.openPanel("options")
					deleteSave()
				elseif action == "deleteRefuse" then
					button.openPanel("options")
				elseif action == "okay" then
					button.openPanel("options")

				elseif action == "options_keybinds_moveLeft" then
					start_keybind_change("moveLeft", button[i])
				elseif action == "options_keybinds_moveRight" then
					start_keybind_change("moveRight", button[i])
				elseif action == "options_keybinds_moveJump" then
					start_keybind_change("moveJump", button[i])
				elseif action == "options_keybinds_moveCrouch" then
					start_keybind_change("moveCrouch", button[i])
				elseif action == "backPanel" then
					button.closePanel()
				end
			end
		end
	end
end

function button.backButtonReset()
	love.keyboard.setTextInput(false)
	love.keyboard.setKeyRepeat(false)
	LET_OPTIONS_MENU = false
end

function button.openPanel(panel)
	str_panelOpen = panel
	bool_optionsOpen = true
end

function button.closePanel()
	str_panelOpen = ""
	bool_optionsOpen = false
end