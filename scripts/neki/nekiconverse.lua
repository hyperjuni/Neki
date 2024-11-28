-- Created by Erina Sugino for Juni <3

neki_speciesDialog = speciesDialog

function speciesDialog(dialog, targetId)
  if not targetId then
    return neki_speciesDialog(dialog, targetId)
  end
  local otherSpecies = world.entitySpecies(targetId) or "default"
  if otherSpecies ~= "neki" then
    return neki_speciesDialog(dialog, targetId)
  end

  local species = context().species and context().species() or "default"
  dialog = dialog[species] or dialog.default

  local targetDialog = dialog[otherSpecies] or dialog.default
  return targetDialog
end
