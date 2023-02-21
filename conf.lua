
--Allows realtime console printing
io.stdout:setvbuf("no")
function love.conf(t)
	--t.console = true
	t.window.title = "Dark Domains"
	t.identity = "BGJ2023Dungeon"
end