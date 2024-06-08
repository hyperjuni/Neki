-- Masks/hides the entire character

function init()
	local species = world.entitySpecies(entity.id()) or "default"
	if species ~= "neki" then
		return
	end
	effect.setParentDirectives("?multiply=ffffff00")
end
