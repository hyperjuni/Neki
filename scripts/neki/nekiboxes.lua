function onInteraction(args)
  local species = world.entitySpecies(args.sourceId)
  local canUse = config.getParameter("canUse")
  if not canUse[species] then
    return {"Message", {messageType = "queueRadioMessage", messageArgs = {{messageId = "nekiboxes", unique = false, text = config.getParameter("emptyText", "There's nothing useful in there.")}}}}
  end
end

function onNpcInteract(args)
  onInteraction(args)
end
