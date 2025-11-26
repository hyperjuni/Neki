-- Made by Erina Sugino for Juni <3

neki_hasItemTag = hasItemTag

function hasItemTag(args, board)
  if npc.species() == "neki" and args.tag == "captainschair" then
    return false
  end
  return neki_hasItemTag(args, board)
end

function npcInteract(args, board) -- luacheck: ignore 212/board
  r,err = pcall(function() world.callScriptedEntity(args.entity, "onNpcInteract", {sourceId = entity.id()}) end)
  if not r then
    sb.logError(err)
  end
  local objectName = world.entityName(args.entity) or "default"
  if string.match(objectName, "^.+captainschair$") and math.random() < 0.2 then
    local chatSounds = config.getParameter("chatSounds", {})
    local sound = "/sfx/humanoid/human_chatter_male1.ogg"
  
    local speciesSounds = chatSounds[npc.species()] or chatSounds.default
    local genderSounds = speciesSounds[npc.gender()] or speciesSounds.default
    if type(genderSounds) ~= "table" and genderSounds ~= nil then
      sound = genderSounds
      elseif #genderSounds > 0 then
        sound = genderSounds[math.random(#genderSounds)]
      end
      npc.say("I'm the captain now.", nil, {sound = sound})
    end
  return true
end
