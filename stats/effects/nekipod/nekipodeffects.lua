-- Created with Erina Sugino's help <3

function init()
	status.setStatusProperty('inPod', true)

	-- Determine species and store on player
	local species = world.entitySpecies(entity.id()) or "default"
	self._species = species

	-- If occupant neither Human nor Neki, apply nothing
	if species ~= "human" and species ~= "neki" then
		return
	end

	-- Don't starve
	effect.addStatModifierGroup({{stat = "foodDelta", effectiveMultiplier = 0}})
	if status.isResource("food") and not status.resourcePositive("food") then
		status.setResource("food", 0.01)
	end

	-- Health regen
	animator.setParticleEmitterOffsetRegion("healing", mcontroller.boundBox())
	animator.setParticleEmitterActive("healing", config.getParameter("particles", true))
	self.healingRate = 1.0 / config.getParameter("healTime", 10)

	-- Resistances
	effect.addStatModifierGroup({{stat = "fireResistance", amount = 0.25}, {stat = "fireStatusImmunity", amount = 1}})
	effect.addStatModifierGroup({{stat = "iceResistance", amount = 0.25}, {stat = "iceStatusImmunity", amount = 1}})
	effect.addStatModifierGroup({{stat = "poisonResistance", amount = 0.25}, {stat = "poisonStatusImmunity", amount = 1}})	

	-- Fake statuseffects to display icons
	status.addEphemeralEffect("nekipodregeneration", math.huge)
	status.addEphemeralEffect("nekipodfireblock", math.huge)
	status.addEphemeralEffect("nekipodiceblock", math.huge)
	status.addEphemeralEffect("nekipodpoisonblock", math.huge)

	script.setUpdateDelta(5)
end

function update(dt)
	-- If neither Human or Neki, only apply fireblock (for 2s)
	if self._species ~= "human" and self._species ~= "neki" then
		status.removeEphemeralEffect("wet")
		status.addEphemeralEffect("fireblock", 2)
		return
	end

	status.modifyResourcePercentage("health", self.healingRate * dt)
	status.removeEphemeralEffect("wet")
end

function onExpire()
	status.setStatusProperty('inPod', nil)

	-- For consistency, apply fireblock to Human/Neki when leaving pod
	if self._species == "human" or self._species == "neki" then
		status.addEphemeralEffect("fireblock", 2)
	end
	status.addEphemeralEffect("wet")
end
