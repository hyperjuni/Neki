-- Masks/hides the entire character
-- The other 'nekihide' scripts apply object-specific masks

function init()
	local species = world.entitySpecies(entity.id()) or "default"
	if species ~= "neki" then
		return
	end
	effect.setParentDirectives("?multiply=ffffff00")
end
