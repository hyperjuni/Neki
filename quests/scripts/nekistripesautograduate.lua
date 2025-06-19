-- Made by Lofty for Juni <3

_404_STRIPES_NOT_FOUND_ = "404StripesNotFound"

require "/scripts/util.lua"
require "/quests/scripts/questutil.lua"
require("/quests/scripts/portraits.lua")

function init()
  setPortraits()

  -- set up a listener to verify that the npc successfully graduated to crew member
  message.setHandler
  (
    "nekiStripesRecruited", 
    function(_, _, tbl)
      recruitmentSuccessfulCallback(tbl)
    end
  )

  message.setHandler
  (
    "npcGraduationSuccessful", 
    function(_, _, tbl)
      graduationSuccessfulCallback(tbl)
    end
  )

  message.setHandler
  (
    "npcGraduationFailed", 
    function(_, _, tbl)
      graduationFailedCallback(tbl)
    end
  )

  self.lastKnownStripesPosition = nil

  self.stripesUid = storage.stripesUid
  if not self.stripesUid then
    self.stripesUid = _404_STRIPES_NOT_FOUND_
  end

  self.compassUpdate = config.getParameter("compassUpdate", 0.5)
  self.startScanning = storage.startScanning
  if self.startScanning == nil then
    self.startScanning = false
  end
end

function setStripesUid(id)
  if id then
    self.stripesUid = id
    storage.stripesUid = id
  end
end

function questStart()
  self.startScanning = true
  storage.startScanning = true
end

function graduationSuccessfulCallback(args)
  if args.senderId == expectedNPCId then
    setStripesUid(args.crewMemberUuid)
  end
end

function recruitmentSuccessfulCallback(args)
  quest.complete()
end

function graduationFailedCallback(args)
  if args.senderId == expectedNPCId then
    quest.fail()
  end
end

function questComplete()
  setPortraits()
  questutil.questCompleteActions()
end

expectedNPCId = 0
timeSinceLastScan = 999.0

function update(dt)

  if status.statusProperty("nekiHasStripesCrew") then
    quest.setFailureText( config.getParameter("descriptions.alreadyHaveStripes") or "" )
    quest.fail()
    return
  end

  --  when the player accepts the quest, we can begin scanning
  if self.startScanning == true then

    --  update the scan timer
    timeSinceLastScan = timeSinceLastScan + dt

    --  every second, try to scan for nearby npcs that match our desired type
    if timeSinceLastScan > 1 then

      --  reset the scan timer each time we scan
      timeSinceLastScan = 0

      --  search all npcs within 500 blocks for the type we want
      local nearbyNPCs = world.npcQuery(mcontroller.position(),500)

      --  loop through results
      for _, v in pairs(nearbyNPCs) do

        --  check to see if it's the right type of npc
        local npcType = world.npcType(v)
        if npcType then
          if npcType == "nekistripesvisitor" then

            --  set our expected npc id value to prevent situations where 2 or more different graduating npcs could cause crosstalk
            expectedNPCId = v

            --  tell the npc to graduate, it will send us a notification if it succeeds
            world.sendEntityMessage(v, "npcForceGraduate", { senderId = entity.id() } )

            --  we're done with this loop
            break
          end

          if npcType == "nekistripescrewmember" then
            --  update tracker if we find a new Stripes instance
            local uid = world.entityUniqueId(v)
            if uid then
              setStripesUid(uid)
            end

            --  we probably only care about the closest instance of Stripes, which should be the first result
            break
          end
        end
      end
    end
  end

  quest.setIndicators({})
  quest.setObjectiveList({{config.getParameter("descriptions.findStripes"), false}})
  questutil.pointCompassAt(self.lastKnownStripesPosition)

  if not self.stripesTracker then
    self.stripesTracker = coroutine.create(trackStripes)
  else
    coroutine.resume(self.stripesTracker)
  end
end

function trackStripes()
  while true do
    if self.stripesUid ~= _404_STRIPES_NOT_FOUND_ then
      local result = world.findUniqueEntity(self.stripesUid)
      while not result:finished() do
        coroutine.yield()
      end
      if result:succeeded() then
        self.lastKnownStripesPosition = result:result()
        -- sb.logInfo("Found @ " .. tostring(result:result()[1]) .. ", " .. tostring(result:result()[2]))
      else
        --  if we can't find Stripes, scan again
        self.lastKnownStripesPosition = nil
        setStripesUid(_404_STRIPES_NOT_FOUND_)
      end
    end
    coroutine.yield()
  end
end
