require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

Punch = WeaponAbility:new()

function Punch:init()
  self.damageConfig.baseDamage = self.baseDps * self.fireTime
  self.weapon:setStance(self.stances.idle)
  self.cooldownTimer = self:cooldownTime()
  self.freezesLeft = self.freezeLimit
  self.freezeTimer = 0
  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

function Punch:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)
  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
  self.freezeTimer = math.max(0, self.freezeTimer - dt)
  if self.freezeTimer > 0 and not mcontroller.onGround() and math.abs(world.gravity(mcontroller.position())) > 0 then
    mcontroller.controlApproachVelocity({0, 0}, 1000)
  end
end

function Punch:canStartAttack()
  return not self.weapon.currentAbility and self.cooldownTimer == 0
end

function Punch:startAttack()
  self:setState(self.windup)
  if self.weapon.freezesLeft > 0 then
    self.weapon.freezesLeft = self.weapon.freezesLeft - 1
    self.freezeTimer = self.freezeTime or 0
  end
end

function Punch:windup()
  self.weapon:setStance(self.stances.windup)
  util.wait(self.stances.windup.duration)
  self:setState(self.windup2)
end

function Punch:windup2()
  self.weapon:setStance(self.stances.windup2)
  util.wait(self.stances.windup2.duration)
  self:setState(self.fire)
end

function Punch:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()
  animator.setAnimationState("attack", "fire")
  animator.playSound("fire")
  status.addEphemeralEffect("invulnerable", self.stances.fire.duration + 0.01) -- Neki-specific change
  util.wait(self.stances.fire.duration, function()
    local damageArea = partDamageArea("swoosh")
    
    self.weapon:setDamage(self.damageConfig, damageArea, self.fireTime)
  end)

  self.cooldownTimer = self:cooldownTime()
end

function Punch:cooldownTime()
  return self.fireTime - self.stances.windup.duration - self.stances.fire.duration
end

function Punch:uninit()
  self.weapon:setDamage()
end
