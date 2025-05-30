-- Made by Lofty for Juni <3

function neki_scriptedOutpostVisitorBehavior(args, board)
  message.setHandler
    (
      "npcForceGraduate", 
      function(_, _, tbl)
          graduate(tbl)
      end
    )

  neki_setNPCBehavior(args.behavior)

  if npc.npcType() == "nekistripesvisitor" then
    npc.setOfferedQuests({"nekistripesquest"})
  end

  return true
end

function neki_setNPCBehavior(b)
  -- copypasted from npcs/bmain.lua @ line 34
  self.behavior = behavior.behavior(b, config.getParameter("behaviorConfig", {}), _ENV)
  self.board = self.behavior:blackboard()
  self.board:setPosition("spawn", storage.spawnPosition)  
  return true
end

-- slimmed down version of the npc graduation code from tenant.lua
function graduate(args)

  --  if the npc can graduate
  local questGenerator = config.getParameter("questGenerator")
  if questGenerator then
    local graduation = questGenerator.graduation
    if graduation then
      if #graduation.nextNpcType > 0 then
        -- sb.logInfo("Graduating...")

        --  choose a graduation type
        local nextNpcType = util.weightedRandom(graduation.nextNpcType)

        --  unsit current npc if necessary
        npc.resetLounging()

        --  set up the replacement npc
        local newUniqueId = sb.makeUuid()
        local newEntityId = 
        world.spawnNpc
        (
          entity.position(), 
          npc.species(), 
          nextNpcType, 
          npc.level(), 
          npc.seed(), 
          {
            identity = npc.humanoidIdentity(),
            scriptConfig = 
            {
              personality = personality(),
              initialStorage = preservedStorage(),
              uniqueId = newUniqueId
            }
          }
        )

        --  send a status update
        world.sendEntityMessage( args.senderId, "npcGraduationSuccessful", { senderId = entity.id(), crewMemberUuid = newUniqueId } )

        --  kill the old npc
        npc.setDeathParticleBurst(nil)
        npc.setDropPools({})
        self.forceDie = true

      --  no graduation types are set up for the npc type
      else
        sb.logInfo("Graduation failed - no nextNpcType data in graduation params")
        world.sendEntityMessage( args.senderId, "npcGraduationFailed", { senderId = entity.id() } )
      end

    --  if the npc cannot graduate, inform the requester that graduation failed
    else
      sb.logInfo("Graduation failed - no graduation data in npctype")
      for k, v in pairs(questGenerator) do
        sb.logInfo( tostring(k) .. " -> " .. tostring(v) )
      end
      world.sendEntityMessage( args.senderId, "npcGraduationFailed", { senderId = entity.id() } )
    end

  --  if there isn't any questGenerator data, something has gone very wrong
  else
    sb.logInfo("Graduation failed - no questGenerator data in npctype")
    world.sendEntityMessage( args.senderId, "npcGraduationFailed", { senderId = entity.id() } )
  end
end

local _update = update
function update(dt)
  _update(dt)
end
