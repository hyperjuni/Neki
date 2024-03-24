-- Created by Erina Sugino for Juni

neki_speciesDialog = speciesDialog

function speciesDialog(dialog, targetId)
	local otherSpecies = world.entitySpecies(targetId) or "default"
	if otherSpecies ~= "neki" then
		return neki_speciesDialog(dialog, targetId)
	end

	local species = context().species and context().species() or "default"
	dialog = dialog[species] or dialog.default

	local targetDialog
	if targetId then
		targetDialog = dialog[otherSpecies] or dialog.default
	else
		targetDialog = dialog.default
	end

	return targetDialog
end
