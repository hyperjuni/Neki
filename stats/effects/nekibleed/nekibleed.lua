-- modified by Kherae to add bleed stacks

require "/scripts/rect.lua"

function init()
  material = status.statusProperty("targetMaterialKind", "organic")
  self.source=effect.sourceEntity()
  if validMaterials(material) then
    animator.setParticleEmitterOffsetRegion("neki" .. material .. "drip", mcontroller.boundBox())
    animator.setParticleEmitterEmissionRate("neki" .. material .. "drip", config.getParameter("emissionRate", 3))
    animator.setParticleEmitterActive("neki" .. material .. "drip", true)

    script.setUpdateDelta(1)
    self.tickDamagePercentage = 0.01 + config.getParameter("bleedAmount", 0)
    self.stackMult=effect.getParameter("stackMult", 0.15)
    self.baseMult=effect.getParameter("baseMult", 1.0)
    self.tickTime = 0.85
    self.tickTimer = self.tickTime
    self.duration=effect.duration()
    self.damageInstances = {self.duration}
    self.maxDrips=5
  end
  didInit=true
end

function update(dt)
  if didInit then
    if (not failedMaterials) and validMaterials(material) then
      local dur=effect.duration()
      local buffer={}
    
      if (self.duration~=dur) and (math.abs(self.duration-dur)>(1.1*dt)) then
        table.insert(buffer,dur)
      end
      self.duration=dur
    
      for i=1,#self.damageInstances do
        local instance=self.damageInstances[i]-dt
        if (instance>0) then
          table.insert(buffer,instance)
        end
      end

      self.damageInstances=buffer
      self.tickTimer = self.tickTimer - dt
      if self.tickTimer <= 0 then
        self.tickTimer = self.tickTime

        local damageVal = (status.statPositive("specialStatusImmunity") and (world.threatLevel() * self.tickDamagePercentage * 100)) or (status.resourceMax("health") * self.tickDamagePercentage)

        damageVal = 1 + (damageVal*self.baseMult) + (#self.damageInstances*damageVal*self.stackMult)
        status.applySelfDamageRequest(
          {
            damageType = "IgnoresDef",
            damage = damageVal,
            damageSourceKind = "nekibowbleed",
            sourceEntityId = self.source
          }
        )
        statusProjectile(material)
      end
    else
      failedMaterials=true
    end
  else
    init()
  end
end

function statusProjectile(material)
  local id = entity.id()
  local pos = world.entityPosition(id)

  world.spawnProjectile("nekidrip", {pos[1], pos[2]}, nil, nil, nil, parameters(material))

  local count=math.min(self.maxDrips,#self.damageInstances-1)
  if count>0 then
    for _=1,count do
      world.spawnProjectile("nekidrip", {pos[1], pos[2]}, nil, nil, nil, parameters(material))
    end
  end
end

function parameters(material)
  if not stafConf then
    statConf=effect.getParameter("materialEffects", {}) end
  return {
    actionOnReap = statConf[material]
  }
end

function validMaterials(material)
  if not matlist then
    matlist=effect.getParameter("ignoreMaterials", {}) end
  for _, mat in pairs(matlist) do
    if material == mat then
      return false
    end
  end
  return true
end

function uninit()

end
