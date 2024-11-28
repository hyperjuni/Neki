require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/status.lua"
require "/items/active/weapons/weapon.lua"

function init()
  self.weapon = Weapon:new()
  self.weapon:addTransformationGroup("weapon", {0,0}, 0)
  self.primaryAbility = getPrimaryAbility()
  self.weapon:addAbility(self.primaryAbility)
  self.weapon:init()
  self.needsEdgeTrigger = config.getParameter("needsEdgeTrigger", false)
  self.edgeTriggerGrace = config.getParameter("edgeTriggerGrace", 0)
  self.edgeTriggerTimer = 0
  updateHand()
end

function update(dt, fireMode, shiftHeld)
  self.edgeTriggerTimer = math.max(0, self.edgeTriggerTimer - dt)
  if self.lastFireMode ~= "primary" and fireMode == "primary" then
    self.edgeTriggerTimer = self.edgeTriggerGrace
  end
  self.lastFireMode = fireMode

  if fireMode == "primary" and (not self.needsEdgeTrigger or self.edgeTriggerTimer > 0) then
    if self.primaryAbility:canStartAttack() then
      self.primaryAbility:startAttack()
    end
  end

  self.weapon:update(dt, fireMode, shiftHeld)
  updateHand()
end

function uninit()
  self.weapon:uninit()
end

-- update which image we're using and keep the weapon visually in front of the hand
function updateHand()
  local isFrontHand = self.weapon:isFrontHand()
  animator.setGlobalTag("hand", isFrontHand and "front" or "back")
  animator.resetTransformationGroup("swoosh")
  animator.scaleTransformationGroup("swoosh", isFrontHand and {1, 1} or {1, -1})

  -- Neki change
  -- activeItem.setOutsideOfHand(isFrontHand)
end
