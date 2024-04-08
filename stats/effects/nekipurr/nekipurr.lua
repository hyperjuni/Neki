function init()
	local species = world.entitySpecies(entity.id()) or "default"
	if species ~= "neki" then
		return
	end
	animator.playSound("nekipurr", -1)
end
