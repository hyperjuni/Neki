require "/scripts/util.lua"
require "/scripts/vec2.lua"
require "/scripts/status.lua"
require "/items/active/weapons/weapon.lua"

function init()
  self.weapon = Weapon:new()
  self.weapon:addTransformationGroup("weapon", {0,0}, 0)
  self.primaryAbility = getPrimaryAbility()
  self.weapon:addAbility(self.primaryAbility)
  local comboFinisherConfig = config.getParameter("comboFinisher")
  self.comboFinisher = getAbility("comboFinisher", comboFinisherConfig)
  self.weapon:addAbility(self.comboFinisher)
  self.weapon:init()
  self.needsEdgeTrigger = config.getParameter("needsEdgeTrigger", false)
  self.edgeTriggerGrace = config.getParameter("edgeTriggerGrace", 0)
  self.edgeTriggerTimer = 0
  self.comboStep = 0
  self.comboSteps = config.getParameter("comboSteps")
  self.comboTiming = config.getParameter("comboTiming")
  self.comboCooldown = config.getParameter("comboCooldown")
  self.weapon.freezeLimit = config.getParameter("freezeLimit", 2)
  self.weapon.freezesLeft = self.weapon.freezeLimit
  updateHand()
end

function update(dt, fireMode, shiftHeld)
  if mcontroller.onGround() then
    self.weapon.freezesLeft = self.weapon.freezeLimit
  end

  if self.comboStep > 0 then
    self.comboTimer = self.comboTimer + dt
    if self.comboTimer > self.comboTiming[2] then
      resetFistCombo()
    end
  end

  self.edgeTriggerTimer = math.max(0, self.edgeTriggerTimer - dt)
  if self.lastFireMode ~= "primary" and fireMode == "primary" then
    self.edgeTriggerTimer = self.edgeTriggerGrace
  end
  self.lastFireMode = fireMode

  if fireMode == "primary" and (not self.needsEdgeTrigger or self.edgeTriggerTimer > 0) then
    if self.comboStep > 0 then
      if self.comboTimer >= self.comboTiming[1] then
        if self.comboStep % 2 == 0 then
          if self.primaryAbility:canStartAttack() then
            if self.comboStep == self.comboSteps then
              self.comboFinisher:startAttack()
            else
              self.primaryAbility:startAttack()
              advanceFistCombo()
            end
          end
        elseif activeItem.callOtherHandScript("triggerComboAttack", self.comboStep) then
          advanceFistCombo()
        end
      end
    else
      if self.primaryAbility:canStartAttack() then
        self.primaryAbility:startAttack()
        if activeItem.callOtherHandScript("resetFistCombo") then
          advanceFistCombo()
        end
      end
    end
  end

  self.weapon:update(dt, fireMode, shiftHeld)
  updateHand()
end

function uninit()
  if unloaded then
    activeItem.callOtherHandScript("resetFistCombo")
  end
  self.weapon:uninit()
end

function updateHand()
  local isFrontHand = self.weapon:isFrontHand()
  animator.setGlobalTag("hand", isFrontHand and "front" or "back")
  animator.resetTransformationGroup("swoosh")
  animator.scaleTransformationGroup("swoosh", isFrontHand and {1, 1} or {1, -1})
  -- activeItem.setOutsideOfHand(isFrontHand) -- Neki-specific change
end

function triggerComboAttack(comboStep)
  if self.primaryAbility:canStartAttack() then
    if comboStep == self.comboSteps then
      self.comboFinisher:startAttack()
    else
      self.primaryAbility:startAttack()
    end
    return true
  else
    return false
  end
end

function advanceFistCombo()
  self.comboTimer = 0
  if self.comboStep < self.comboSteps then
    self.comboStep = self.comboStep + 1
  end
end

function resetFistCombo()
  self.comboStep = 0
  self.comboTimer = nil
  return true
end

function finishFistCombo()
  resetFistCombo()
  self.primaryAbility.cooldownTimer = self.comboCooldown
end
