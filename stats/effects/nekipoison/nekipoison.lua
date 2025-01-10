function init()
  local species = world.entitySpecies(entity.id()) or "default"
  if species ~= "neki" then
    return
  end
  status.addEphemeralEffect("nekipoisoneffect")
  world.sendEntityMessage(entity.id(), "queueRadioMessage", "nekipoisontutorial")
  effect.expire()
end