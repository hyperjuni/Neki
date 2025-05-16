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

  status.addEphemeralEffect("invulnerable", self.stances.fire.duration + 0.01)
  self.tileDamageTimer = 0

  util.wait(self.stances.fire.duration, function()
    local damageArea = partDamageArea("swoosh")

    self.tileDamageTimer = math.max(0, self.tileDamageTimer - self.dt)
    if self.tileDamageTimer == 0 then
      self.tileDamageTimer = self.tileDamageRate
      self:damageTiles()
    end

    self.weapon:setDamage(self.damageConfig, damageArea, self.fireTime)
  end)

  self.cooldownTimer = self:cooldownTime()
end

-- Digging
function Punch:damageTiles()
  local pos = mcontroller.position()
  local clawPosition = vec2.add(pos, activeItem.handPosition(animator.partPoint("weapon", "digTip")))
  for i = 1, 3 do
    local sourcePosition = vec2.add(pos, activeItem.handPosition(animator.partPoint("weapon", "digSource" .. i)))
    local clawTiles = world.collisionBlocksAlongLine(sourcePosition, clawPosition, nil, self.damageTileDepth)
    if #clawTiles > 0 then
      world.damageTiles(clawTiles, "foreground", sourcePosition, "blockish", self.tileDamage, 99, activeItem.ownerEntityId())
    end
  end
end

function Punch:cooldownTime()
  return self.fireTime - self.stances.windup.duration - self.stances.fire.duration
end

function Punch:uninit()
  self.weapon:setDamage()
end
