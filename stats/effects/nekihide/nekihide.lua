-- Hides the tail or the entire character while lounging

function init()
  local species = world.entitySpecies(entity.id()) or "default"
  local nekiOnly = config.getParameter("nekiOnly", false)
  local mask = config.getParameter("nekihideMask")
  if nekiOnly and species ~= "neki" then
    return
  end
  if mask then
    effect.setParentDirectives("?addmask="..mask)
  else
    effect.setParentDirectives("?multiply=ffffff00")
  end
end
