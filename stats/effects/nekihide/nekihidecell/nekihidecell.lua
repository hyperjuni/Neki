function init()
	local species = world.entitySpecies(entity.id()) or "default"
	if species ~= "neki" then
		return
	end
	effect.setParentDirectives("?addmask=/stats/effects/nekihide/nekihidecell/nekihidecell.png")
end
