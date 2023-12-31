-- Created with the direct assistance of Kherae and TeksFox

local oldUpdate = update
local oldInit = init

function init(...)
	if not world.entityExists(entity.id()) then
		return
	end
	if player.species() == "neki" then
		setParticleConfig(0)
	else
		particleConfig = {}
	end
	if oldInit then
		oldInit(...)
	end
end

function update(dt,...)
	if not particleConfig then
		init()
	end
	if player.species() == "neki" then
		setParticleConfig(dt)
		localAnimator.spawnParticle(particleConfig)
	end
	if oldUpdate then
		oldUpdate(dt,...)
	end
end

function setParticleConfig(dt)
	if not particleConfig then
		particleConfig = {
			light = {125,125,125},
			type = "textured",
			image = "/projectiles/invisibleprojectile/invisibleprojectile.png"
		}
	end
	local lightval = math.min(125*status.resourcePercentage("health"),255)
	particleConfig.light = {lightval,lightval,lightval}
	particleConfig.position = entity.position()
	particleConfig.timeToLive = dt
end
