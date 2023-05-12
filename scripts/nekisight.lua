-- created by TeksFox

local oldUpdate = update
local upateparent = update

function update(...)
	if oldUpdate ~= nil then
		oldUpdate(...)
	end
	localAnimator.clearLightSources()
	if player.species() == "neki" then
		localAnimator.addLightSource(
			{
				color = {125, 125, 125},
				position = entity.position(),
				PointLight = true
			}
		)
	end
end