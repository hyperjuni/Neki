-- Created with the help of Apple's ketamine addiction <3

function init()
	local species = world.entitySpecies(entity.id())
	local drownImmunity = root.itemConfig("nekipod").config.drownImmunity

	self.groupId = effect.addStatModifierGroup({})
	if not drownImmunity[species] then
		effect.setStatModifierGroup(self.groupId, {
			{stat = "breathRegenerationRate", amount =	-(status.stat("breathRegenerationRate") + status.stat("breathDepletionRate"))}
		})
	end
end

function uninit()
	if self.groupId then
		effect.removeStatModifierGroup(self.groupId)
	end
end
