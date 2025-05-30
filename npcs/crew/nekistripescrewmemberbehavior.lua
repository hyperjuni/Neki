-- Made by Lofty for Juni <3

function neki_scriptedNekiStripesCrewMemberBehavior(args, board)
  message.setHandler
  (
    "npcSetNewUniqueId", 
    function(_, _, tbl)
      updateUniqueId(tbl)
    end
  )
  message.setHandler
  (
    "nekiStripesMultipleRecruitmentDisallowed", 
    function(_, _, tbl)
      denied()
    end
  )
  message.setHandler
  (
    "nekiStripesPlayEmote", 
    function(_, _, tbl)
      playEmote(tbl)
    end
  )
  neki_setNPCBehavior(args.behavior)
  return true
end

function playEmote(args)
  if args.emote then
	self.overrideEmote = args.emote
    self.shouldPlayEmote = 1.0
	--sb.logInfo(args.emote)
  end
end

function denied()
  npc.say
  (
  config.getParameter("nekiStripesMultipleRecruitmentDisallowedText"),
  {},
    {
      drawBorder = true,
      fontSize = 8,
      color = {255, 255, 255},
      sound = "/sfx/humanoid/neki_chatter_female1.ogg"
    }
  )
end

function neki_setNPCBehavior(b)
  -- copypasted from npcs/bmain.lua @ line 34
  self.behavior = behavior.behavior(b, config.getParameter("behaviorConfig", {}), _ENV)
  self.board = self.behavior:blackboard()
  self.board:setPosition("spawn", storage.spawnPosition)  
  return true
end

function updateUniqueId(args)
  if args then
    if args.uniqueId then
      npc.setUniqueId(args.uniqueId)
      world.sendEntityMessage(args.senderId,"npcSetNewUniqueIdSuccessful",{senderId = entity.id(), uniqueId = args.uniqueId})
      sb.logInfo("Set unique id successfully: " .. args.uniqueId)
    end
  end
end

local _update = update
function update(dt)
  _update(dt)
  local uid = config.getParameter("uniqueId")
  if uid then
    if entity.uniqueId() ~= uid then
      npc.setUniqueId(uid)
    end
  end

  -- when we receive an emote to play, spam it here for 1 second to make sure it overrides
  if self.shouldPlayEmote ~= nil then
    if self.shouldPlayEmote > 0 then
      if self.overrideEmote ~= nil then
        self.shouldPlayEmote = self.shouldPlayEmote - dt
        npc.emote(self.overrideEmote)
      end
    end
  end
end

local _init = init
function init()
  _init()
  self.shouldPlayEmote = 0
end
