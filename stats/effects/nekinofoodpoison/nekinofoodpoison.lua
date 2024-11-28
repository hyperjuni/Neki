function init()
  local species = world.entitySpecies(entity.id()) or "default"
  if species == "neki" then
    status.removeEphemeralEffect("foodpoison")
    world.sendEntityMessage(entity.id(), "queueRadioMessage", "nekinofoodpoisontutorial")
    world.sendEntityMessage(entity.id(), "queueRadioMessage", "nekinofoodpoisontutorial2")
  end
  effect.expire()
end
