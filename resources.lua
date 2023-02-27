function fontLoad()
	--UI Fonts
	font_default = love.graphics.newFont("resources/fonts/Biryani-Regular.ttf", 16)
	font_hudText = love.graphics.newFont("resources/fonts/NewRocker-Regular.ttf", 26)

	font_gameText = love.graphics.newFont("resources/fonts/NewRocker-Regular.ttf", 18)
	font_creditsText = love.graphics.newFont("resources/fonts/NewRocker-Regular.ttf", 28)
	font_buttonText = love.graphics.newFont("resources/fonts/NewRocker-Regular.ttf", 84)

	font_title = love.graphics.newFont("resources/fonts/DungeonFont.ttf", 128)
	font_subtitle = love.graphics.newFont("resources/fonts/DungeonFont.ttf", 96)
	font_subbertitle = love.graphics.newFont("resources/fonts/DungeonFont.ttf", 40)
	clr_menu_font = {232/255, 227/255, 70/255}
end

function cursorLoad()
	crsr_default = love.mouse.newCursor("resources/textures/ui/cursor_default.png", 0, 0)
	--crsr_crosshair = love.mouse.newCursor("resources/textures/ui/crosshair.png", 32, 32)
end

function imageLoad()
--Levels
	img_map_nature = love.graphics.newImage("resources/textures/maps/map_nature.png")
	img_map_dungeon = love.graphics.newImage("resources/textures/maps/map_dungeon.png")

--UI
	img_ui_menu_bg = love.graphics.newImage("resources/textures/ui/menu_bg.png")
	img_ui_buttons = love.graphics.newImage("resources/textures/ui/buttons/all_buttons.png")
		sb_ui_button = love.graphics.newSpriteBatch(img_ui_buttons)
	img_ui_shop_empty_slot = love.graphics.newImage("resources/textures/ui/shop/empty_slot.png")
	img_ui_shop_full_slot = love.graphics.newImage("resources/textures/ui/shop/full_slot.png")

	img_ui_crosshair = love.graphics.newImage("resources/textures/ui/crosshair.png")
	img_ui_wpn_slot_box = love.graphics.newImage("resources/textures/ui/hud/wpn_slot_box.png")

	img_ui_hp_bar_outline = love.graphics.newImage("resources/textures/ui/hud/hp_bar_outline.png")
	img_ui_hp_bar_empty = love.graphics.newImage("resources/textures/ui/hud/hp_bar_empty.png")
	img_ui_hp_bar_full = love.graphics.newImage("resources/textures/ui/hud/hp_bar_full.png")

	img_ui_mana_bar_outline = love.graphics.newImage("resources/textures/ui/hud/mana_bar_outline.png")
	img_ui_mana_bar_empty = love.graphics.newImage("resources/textures/ui/hud/mana_bar_empty.png")
	img_ui_mana_bar_full = love.graphics.newImage("resources/textures/ui/hud/mana_bar_full.png")

--Buttons
	img_ui_button_QD = love.graphics.newQuad(0, 0, 300, 125, img_ui_buttons)
	img_ui_button_QD_2 = love.graphics.newQuad(0, 126, 300, 125, img_ui_buttons)

	img_ui_shop_skull_QD = love.graphics.newQuad(0, 252, 258, 258, img_ui_buttons)
	img_ui_shop_skull_QD_2 = love.graphics.newQuad(0, 517, 258, 258, img_ui_buttons)

	img_ui_shop_boot_QD = love.graphics.newQuad(259, 252, 258, 258, img_ui_buttons)
	img_ui_shop_boot_QD_2 = love.graphics.newQuad(259, 517, 258, 258, img_ui_buttons)

	img_ui_shop_heart_QD = love.graphics.newQuad(518, 252, 258, 258, img_ui_buttons)
	img_ui_shop_heart_QD_2 = love.graphics.newQuad(518, 517, 258, 258, img_ui_buttons)

--Weapons
	img_wpn_dagger = love.graphics.newImage("resources/textures/weapons/dagger.png")
	img_wpn_broadsword = love.graphics.newImage("resources/textures/weapons/sword.png")
	img_wpn_katana = love.graphics.newImage("resources/textures/weapons/katana.png")
	img_wpn_shortsword = love.graphics.newImage("resources/textures/weapons/broadsword.png")
	img_wpn_battlestaff = love.graphics.newImage("resources/textures/weapons/broadsword.png")

--Artifacts
	img_art_chest = love.graphics.newImage("resources/textures/artifacts/chest_closed.png")

--Consumables
	img_con_coins = love.graphics.newImage("resources/textures/consumables/con_money.png")
	img_con_healthpotion = love.graphics.newImage("resources/textures/consumables/con_health.png")
	img_con_manapotion = love.graphics.newImage("resources/textures/consumables/con_mana.png")

--Effects
	img_efx_stab = love.graphics.newImage("resources/textures/weapons/effects/efx_stab.png")
	img_efx_slash = love.graphics.newImage("resources/textures/weapons/effects/efx_slash.png")
	img_efx_glow = love.graphics.newImage("resources/textures/weapons/effects/efx_glow.png")

	clr_efx_common = {161/255, 176/255, 177/255, .35}
	clr_efx_uncommon = {45/255, 127/255, 42/255, .35}
	clr_efx_rare = {0, 117/255, 223/255, .35}
	clr_efx_ultra = {255/255, 69/255, 223/255, .35}
	clr_efx_legendary = {255/255, 174/255, 16/255, .35}
	clr_efx_health = {237/255, 35/255, 35/255, .35}
	clr_efx_mana = {21/255, 88/255, 208/255, .35}

--Player
	img_plr_idle = {}
	img_plr_idle[1] = love.graphics.newImage("resources/textures/player/idle/3.png")
		img_plr_idle[2] = love.graphics.newImage("resources/textures/player/idle/4.png")
		img_plr_idle[3] = love.graphics.newImage("resources/textures/player/idle/5.png")
		img_plr_idle[4] = love.graphics.newImage("resources/textures/player/idle/6.png")
		img_plr_idle[5] = love.graphics.newImage("resources/textures/player/idle/7.png")
		img_plr_idle[6] = love.graphics.newImage("resources/textures/player/idle/8.png")

	img_plr_run = {}
	img_plr_run[1] = love.graphics.newImage("resources/textures/player/run/1.png")
		img_plr_run[2] = love.graphics.newImage("resources/textures/player/run/2.png")
		img_plr_run[3] = love.graphics.newImage("resources/textures/player/run/3.png")
		img_plr_run[4] = love.graphics.newImage("resources/textures/player/run/4.png")
		img_plr_run[5] = love.graphics.newImage("resources/textures/player/run/5.png")
		img_plr_run[6] = love.graphics.newImage("resources/textures/player/run/6.png")
		img_plr_run[7] = love.graphics.newImage("resources/textures/player/run/7.png")
		img_plr_run[8] = love.graphics.newImage("resources/textures/player/run/8.png")

--Gore
	img_gore_splat = {}
	img_gore_splat[1] = love.graphics.newImage("resources/textures/enemies/gore/1.png")
	img_gore_splat[2] = love.graphics.newImage("resources/textures/enemies/gore/2.png")
	img_gore_splat[3] = love.graphics.newImage("resources/textures/enemies/gore/3.png")
	img_gore_splat[4] = love.graphics.newImage("resources/textures/enemies/gore/4.png")
	img_gore_splat[5] = love.graphics.newImage("resources/textures/enemies/gore/5.png")
	img_gore_splat[6] = love.graphics.newImage("resources/textures/enemies/gore/6.png")
	img_gore_splat[7] = love.graphics.newImage("resources/textures/enemies/gore/7.png")
	img_gore_splat[8] = love.graphics.newImage("resources/textures/enemies/gore/8.png")
	img_gore_splat[9] = love.graphics.newImage("resources/textures/enemies/gore/9.png")
	img_gore_splat[10] = love.graphics.newImage("resources/textures/enemies/gore/10.png")
	img_gore_splat[11] = love.graphics.newImage("resources/textures/enemies/gore/11.png")
	img_gore_splat[12] = love.graphics.newImage("resources/textures/enemies/gore/12.png")
	img_gore_splat[13] = love.graphics.newImage("resources/textures/enemies/gore/13.png")
	img_gore_splat[14] = love.graphics.newImage("resources/textures/enemies/gore/14.png")
	img_gore_splat[15] = love.graphics.newImage("resources/textures/enemies/gore/15.png")

--Enemies
	img_foe_bat01_run = {}
	img_foe_bat01_run[1] = love.graphics.newImage("resources/textures/enemies/bat/01/1.png")
		img_foe_bat01_run[2] = love.graphics.newImage("resources/textures/enemies/bat/01/2.png")
		img_foe_bat01_run[3] = love.graphics.newImage("resources/textures/enemies/bat/01/3.png")
		img_foe_bat01_run[4] = love.graphics.newImage("resources/textures/enemies/bat/01/4.png")
		img_foe_bat01_run[5] = love.graphics.newImage("resources/textures/enemies/bat/01/5.png")
		img_foe_bat01_run[6] = love.graphics.newImage("resources/textures/enemies/bat/01/6.png")
		
	img_foe_bat02_run = {}
	img_foe_bat02_run[1] = love.graphics.newImage("resources/textures/enemies/bat/02/1.png")
		img_foe_bat02_run[2] = love.graphics.newImage("resources/textures/enemies/bat/02/2.png")
		img_foe_bat02_run[3] = love.graphics.newImage("resources/textures/enemies/bat/02/3.png")
		img_foe_bat02_run[4] = love.graphics.newImage("resources/textures/enemies/bat/02/4.png")
		img_foe_bat02_run[5] = love.graphics.newImage("resources/textures/enemies/bat/02/5.png")
		img_foe_bat02_run[6] = love.graphics.newImage("resources/textures/enemies/bat/02/6.png")

	img_foe_bat03_run = {}
	img_foe_bat03_run[1] = love.graphics.newImage("resources/textures/enemies/bat/03/1.png")
		img_foe_bat03_run[2] = love.graphics.newImage("resources/textures/enemies/bat/03/2.png")
		img_foe_bat03_run[3] = love.graphics.newImage("resources/textures/enemies/bat/03/3.png")
		img_foe_bat03_run[4] = love.graphics.newImage("resources/textures/enemies/bat/03/4.png")
		img_foe_bat03_run[5] = love.graphics.newImage("resources/textures/enemies/bat/03/5.png")
		img_foe_bat03_run[6] = love.graphics.newImage("resources/textures/enemies/bat/03/6.png")

	img_foe_zombie01_run = {}
	img_foe_zombie01_run[1] = love.graphics.newImage("resources/textures/enemies/zombie/run/01/1.png")
		img_foe_zombie01_run[2] = love.graphics.newImage("resources/textures/enemies/zombie/run/01/2.png")
		img_foe_zombie01_run[3] = love.graphics.newImage("resources/textures/enemies/zombie/run/01/3.png")
		img_foe_zombie01_run[4] = love.graphics.newImage("resources/textures/enemies/zombie/run/01/4.png")
		img_foe_zombie01_run[5] = love.graphics.newImage("resources/textures/enemies/zombie/run/01/5.png")
		img_foe_zombie01_run[6] = love.graphics.newImage("resources/textures/enemies/zombie/run/01/6.png")
		img_foe_zombie01_run[7] = love.graphics.newImage("resources/textures/enemies/zombie/run/01/7.png")
		img_foe_zombie01_run[8] = love.graphics.newImage("resources/textures/enemies/zombie/run/01/8.png")

	img_foe_zombie01_attack = {}
	img_foe_zombie01_attack[1] = love.graphics.newImage("resources/textures/enemies/zombie/attack/01/1.png")
		img_foe_zombie01_attack[2] = love.graphics.newImage("resources/textures/enemies/zombie/attack/01/2.png")
		img_foe_zombie01_attack[3] = love.graphics.newImage("resources/textures/enemies/zombie/attack/01/3.png")
		img_foe_zombie01_attack[4] = love.graphics.newImage("resources/textures/enemies/zombie/attack/01/4.png")
		img_foe_zombie01_attack[5] = love.graphics.newImage("resources/textures/enemies/zombie/attack/01/5.png")
		img_foe_zombie01_attack[6] = love.graphics.newImage("resources/textures/enemies/zombie/attack/01/6.png")
		img_foe_zombie01_attack[7] = love.graphics.newImage("resources/textures/enemies/zombie/attack/01/7.png")

	img_foe_zombie02_run = {}
	img_foe_zombie02_run[1] = love.graphics.newImage("resources/textures/enemies/zombie/run/02/1.png")
		img_foe_zombie02_run[2] = love.graphics.newImage("resources/textures/enemies/zombie/run/02/2.png")
		img_foe_zombie02_run[3] = love.graphics.newImage("resources/textures/enemies/zombie/run/02/3.png")
		img_foe_zombie02_run[4] = love.graphics.newImage("resources/textures/enemies/zombie/run/02/4.png")
		img_foe_zombie02_run[5] = love.graphics.newImage("resources/textures/enemies/zombie/run/02/5.png")
		img_foe_zombie02_run[6] = love.graphics.newImage("resources/textures/enemies/zombie/run/02/6.png")
		img_foe_zombie02_run[7] = love.graphics.newImage("resources/textures/enemies/zombie/run/02/7.png")
		img_foe_zombie02_run[8] = love.graphics.newImage("resources/textures/enemies/zombie/run/02/8.png")

	img_foe_zombie02_attack = {}
	img_foe_zombie02_attack[1] = love.graphics.newImage("resources/textures/enemies/zombie/attack/02/1.png")
		img_foe_zombie02_attack[2] = love.graphics.newImage("resources/textures/enemies/zombie/attack/02/2.png")
		img_foe_zombie02_attack[3] = love.graphics.newImage("resources/textures/enemies/zombie/attack/02/3.png")
		img_foe_zombie02_attack[4] = love.graphics.newImage("resources/textures/enemies/zombie/attack/02/4.png")
		img_foe_zombie02_attack[5] = love.graphics.newImage("resources/textures/enemies/zombie/attack/02/5.png")
		img_foe_zombie02_attack[6] = love.graphics.newImage("resources/textures/enemies/zombie/attack/02/6.png")
		img_foe_zombie02_attack[7] = love.graphics.newImage("resources/textures/enemies/zombie/attack/02/7.png")

	img_foe_zombie03_run = {}
	img_foe_zombie03_run[1] = love.graphics.newImage("resources/textures/enemies/zombie/run/03/1.png")
		img_foe_zombie03_run[2] = love.graphics.newImage("resources/textures/enemies/zombie/run/03/2.png")
		img_foe_zombie03_run[3] = love.graphics.newImage("resources/textures/enemies/zombie/run/03/3.png")
		img_foe_zombie03_run[4] = love.graphics.newImage("resources/textures/enemies/zombie/run/03/4.png")
		img_foe_zombie03_run[5] = love.graphics.newImage("resources/textures/enemies/zombie/run/03/5.png")
		img_foe_zombie03_run[6] = love.graphics.newImage("resources/textures/enemies/zombie/run/03/6.png")
		img_foe_zombie03_run[7] = love.graphics.newImage("resources/textures/enemies/zombie/run/03/7.png")
		img_foe_zombie03_run[8] = love.graphics.newImage("resources/textures/enemies/zombie/run/03/8.png")

	img_foe_zombie03_attack = {}
	img_foe_zombie03_attack[1] = love.graphics.newImage("resources/textures/enemies/zombie/attack/03/1.png")
		img_foe_zombie03_attack[2] = love.graphics.newImage("resources/textures/enemies/zombie/attack/03/2.png")
		img_foe_zombie03_attack[3] = love.graphics.newImage("resources/textures/enemies/zombie/attack/03/3.png")
		img_foe_zombie03_attack[4] = love.graphics.newImage("resources/textures/enemies/zombie/attack/03/4.png")
		img_foe_zombie03_attack[5] = love.graphics.newImage("resources/textures/enemies/zombie/attack/03/5.png")
		img_foe_zombie03_attack[6] = love.graphics.newImage("resources/textures/enemies/zombie/attack/03/6.png")
		img_foe_zombie03_attack[7] = love.graphics.newImage("resources/textures/enemies/zombie/attack/03/7.png")

	img_foe_ghoul01_run = {}
	img_foe_ghoul01_run[1] = love.graphics.newImage("resources/textures/enemies/ghoul/run/01/4.png")
		img_foe_ghoul01_run[2] = love.graphics.newImage("resources/textures/enemies/ghoul/run/01/5.png")

	img_foe_ghoul01_attack = {}
	img_foe_ghoul01_attack[1] = love.graphics.newImage("resources/textures/enemies/ghoul/run/01/1.png")
		img_foe_ghoul01_attack[2] = love.graphics.newImage("resources/textures/enemies/ghoul/run/01/2.png")
		img_foe_ghoul01_attack[3] = love.graphics.newImage("resources/textures/enemies/ghoul/run/01/3.png")
		img_foe_ghoul01_attack[4] = love.graphics.newImage("resources/textures/enemies/ghoul/run/01/4.png")
		img_foe_ghoul01_attack[5] = love.graphics.newImage("resources/textures/enemies/ghoul/run/01/5.png")
		img_foe_ghoul01_attack[6] = love.graphics.newImage("resources/textures/enemies/ghoul/run/01/6.png")

	img_foe_ghoul02_run = {}
	img_foe_ghoul02_run[1] = love.graphics.newImage("resources/textures/enemies/ghoul/run/02/4.png")
		img_foe_ghoul02_run[2] = love.graphics.newImage("resources/textures/enemies/ghoul/run/02/5.png")

	img_foe_ghoul02_attack = {}
	img_foe_ghoul02_attack[1] = love.graphics.newImage("resources/textures/enemies/ghoul/run/02/1.png")
		img_foe_ghoul02_attack[2] = love.graphics.newImage("resources/textures/enemies/ghoul/run/02/2.png")
		img_foe_ghoul02_attack[3] = love.graphics.newImage("resources/textures/enemies/ghoul/run/02/3.png")
		img_foe_ghoul02_attack[4] = love.graphics.newImage("resources/textures/enemies/ghoul/run/02/4.png")
		img_foe_ghoul02_attack[5] = love.graphics.newImage("resources/textures/enemies/ghoul/run/02/5.png")
		img_foe_ghoul02_attack[6] = love.graphics.newImage("resources/textures/enemies/ghoul/run/02/6.png")

	img_foe_ghoul03_run = {}
	img_foe_ghoul03_run[1] = love.graphics.newImage("resources/textures/enemies/ghoul/run/03/4.png")
		img_foe_ghoul03_run[2] = love.graphics.newImage("resources/textures/enemies/ghoul/run/03/5.png")

	img_foe_ghoul03_attack = {}
	img_foe_ghoul03_attack[1] = love.graphics.newImage("resources/textures/enemies/ghoul/run/03/1.png")
		img_foe_ghoul03_attack[2] = love.graphics.newImage("resources/textures/enemies/ghoul/run/03/2.png")
		img_foe_ghoul03_attack[3] = love.graphics.newImage("resources/textures/enemies/ghoul/run/03/3.png")
		img_foe_ghoul03_attack[4] = love.graphics.newImage("resources/textures/enemies/ghoul/run/03/4.png")
		img_foe_ghoul03_attack[5] = love.graphics.newImage("resources/textures/enemies/ghoul/run/03/5.png")
		img_foe_ghoul03_attack[6] = love.graphics.newImage("resources/textures/enemies/ghoul/run/03/6.png")

	img_foe_warrior01_run = {}
	img_foe_warrior01_run[1] = love.graphics.newImage("resources/textures/enemies/warrior/run/01/1.png")
		img_foe_warrior01_run[2] = love.graphics.newImage("resources/textures/enemies/warrior/run/01/2.png")
		img_foe_warrior01_run[3] = love.graphics.newImage("resources/textures/enemies/warrior/run/01/3.png")
		img_foe_warrior01_run[4] = love.graphics.newImage("resources/textures/enemies/warrior/run/01/4.png")
		img_foe_warrior01_run[5] = love.graphics.newImage("resources/textures/enemies/warrior/run/01/5.png")
		img_foe_warrior01_run[6] = love.graphics.newImage("resources/textures/enemies/warrior/run/01/6.png")
end

function particlesLoad()
	particle_attack = love.graphics.newParticleSystem(img_efx_stab, 32)
	particle_attack:setParticleLifetime(.16, .66)
	particle_attack:setSizeVariation(1)
	particle_attack:setColors(1, 1, 1, 1, 1, 1, 1, 0)


	particle_rarity = love.graphics.newParticleSystem(img_efx_glow, 32)
	particle_rarity:setParticleLifetime(2, 2)
	particle_rarity:setEmissionRate(2)
	particle_rarity:setSizes(.35, .65, 1, 1.15, 1, .65)
	particle_rarity:setSizeVariation(0)
end

function soundLoad()
	--Must loop over with PAIRS not ipairs
	snd_effects = {}
	snd_effects["snd_stab"] = love.audio.newSource("resources/sounds/effect_stab.ogg", "static")
	snd_effects["snd_slash"] = love.audio.newSource("resources/sounds/effect_slash.ogg", "static")
	snd_effects["snd_pickup_coins"] = love.audio.newSource("resources/sounds/effect_coin_pickup.ogg", "static")
	snd_effects["snd_pickup_consumable"] = love.audio.newSource("resources/sounds/effect_consumable_pickup.ogg", "static")
	snd_effects["snd_damage"] = love.audio.newSource("resources/sounds/effect_damage.ogg", "static")

	msc_effects = {}
	msc_effects["msc_menuscreen"] = love.audio.newSource("resources/sounds/music/menu_music.mp3", "stream")
	msc_effects["msc_gameplay"] = love.audio.newSource("resources/sounds/music/gameplay_music.mp3", "stream")
end

function resourceLoad()
	fontLoad()
	cursorLoad()
	imageLoad()
	particlesLoad()
	soundLoad()
end