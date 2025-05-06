require "/scripts/util.lua"
require "/items/active/weapons/weapon.lua"

-- fist weapon primary attack
Punch = WeaponAbility:new()

function Punch:init()
  self.damageConfig.baseDamage = self.baseDps * self.fireTime
  self.weapon:setStance(self.stances.idle)
  self.cooldownTimer = self:cooldownTime()
  self.weapon.onLeaveAbility = function()
    self.weapon:setStance(self.stances.idle)
  end
end

-- Ticks on every update regardless if this is the active ability
function Punch:update(dt, fireMode, shiftHeld)
  WeaponAbility.update(self, dt, fireMode, shiftHeld)
  self.cooldownTimer = math.max(0, self.cooldownTimer - self.dt)
end

function Punch:canStartAttack()
  return not self.weapon.currentAbility and self.cooldownTimer == 0
end

function Punch:startAttack()
  self:setState(self.windup)
end

-- State: windup
function Punch:windup()
  self.weapon:setStance(self.stances.windup)
  util.wait(self.stances.windup.duration)
  self:setState(self.windup2)
end

-- State: windup2
function Punch:windup2()
  self.weapon:setStance(self.stances.windup2)
  util.wait(self.stances.windup2.duration)
  self:setState(self.fire)
end

-- State: fire
function Punch:fire()
  self.weapon:setStance(self.stances.fire)
  self.weapon:updateAim()
  animator.setAnimationState("attack", "fire")
  animator.playSound("fire")
  -- Neki change
  status.addEphemeralEffect("invulnerable", self.stances.fire.duration + 0.05)

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
