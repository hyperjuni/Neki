-- Made by Erina Sugino for Juni <3

function init()
  if status.isResource("energy") then
    status.setResourcePercentage("energy", 0)
  end
  effect.addStatModifierGroup({
    {stat = "powerMultiplier",  effectiveMultiplier = 0},
    {stat = "jumpModifier", amount = -1.0}
  })
  if status.isResource("stunned") then
    status.setResource("stunned", math.max(status.resource("stunned"), effect.duration()))
  end
  mcontroller.setXVelocity(0)
  status.setStatusProperty("nekistun", true)
end

function update()
  -- mcontroller.setXVelocity(0)
  mcontroller.controlModifiers({
    facingSuppressed = true,
    movementSuppressed = true,
    groundMovementModifier = 0.0,
    speedModifier = 0.0,
    airJumpModifier = 0.0
  })
end

function uninit()
  if status.isResource("stunned") then
    status.setResource("stunned", 0)
  end
  status.setStatusProperty("nekistun", false)
end
