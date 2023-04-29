local oldinit = init

function init()
	if oldinit ~= nil then
		oldinit()
	end
	local customImages = config.getParameter("customBorder")
	local race = player.species()
	local gender = player.gender()
	local path = customImages.path or "/interface/scripted/techupgrade/parts/"

	if customImages and customImages[race] then
		widget.setImage("imgBackingImage", path .. race .. "Back.png:" .. gender)
		widget.setImage("imgSelectedHead", path .. race .. "Line_" .. gender .. ".png:head")
		widget.setImage("imgSelectedBody", path .. race .. "Line_" .. gender .. ".png:body")
		widget.setImage("imgSelectedLegs", path .. race .. "Line_" .. gender .. ".png:legs")
	end
end