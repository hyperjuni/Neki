require "/scripts/rect.lua"

function init()
	material = status.statusProperty("targetMaterialKind", "organic")
	if ignoreMaterials(material) then
		animator.setParticleEmitterOffsetRegion("neki" .. material .. "drip", mcontroller.boundBox())
		animator.setParticleEmitterEmissionRate("neki" .. material .. "drip", config.getParameter("emissionRate", 3))
		animator.setParticleEmitterActive("neki" .. material .. "drip", true)

		script.setUpdateDelta(5)
		self.tickDamagePercentage = 0.01 + config.getParameter("bleedAmount", 0)
		self.tickTime = 0.85
		self.tickTimer = self.tickTime
		effect.duration()
	end
end

function update(dt)
	if ignoreMaterials(material) then
		self.tickTimer = self.tickTimer - dt
		if self.tickTimer <= 0 then
			self.tickTimer = self.tickTime
			local damageVal
			if status.statPositive("specialStatusImmunity") then
				damageVal = math.floor(world.threatLevel() * self.tickDamagePercentage * 100)
			else
				damageVal = math.floor(status.resourceMax("health") * self.tickDamagePercentage) + 1
			end
			status.applySelfDamageRequest(
				{
					damageType = "IgnoresDef",
					damage = damageVal,
					damageSourceKind = "nekibleed",
					sourceEntityId = entity.id()
				}
			)
			statusProjectile(material)
		end
	end
end

function statusProjectile(material)
	local id = entity.id()
	local pos = world.entityPosition(id)

	world.spawnProjectile("nekidrip", {pos[1], pos[2]}, nil, nil, nil, parameters(material))
end

function parameters(material)
	local statConf = effect.getParameter("materialEffects", {})
	return {
		actionOnReap = statConf[material]
	}
end

function ignoreMaterials(material)
	for i, mat in pairs(effect.getParameter("ignoreMaterials", {})) do
		if material == mat then
			return false
		end
	end
	return true
end

function uninit()

end
