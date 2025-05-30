-- Made by Lofty for Juni <3

recruitSpawner._addCrew = recruitSpawner.addCrew
function recruitSpawner:addCrew(recruitUuid, recruitInfo)

    --  if the crew member is Stripes
  if recruitInfo.config.type == "nekistripescrewmember" then

    --  situation where multiple Stripes crew members were spawned at the same time
    if status.statusProperty("nekiHasStripesCrew") then
      --  add a helpful line of debug to the log
      sb.logInfo("Only one copy of Stripes may be recruited at a time.")

      --  deny recruitment
      return
    end

    --  complete the quest and set status for having Stripes in party
    world.sendEntityMessage(player.id(), "nekiStripesRecruited", {} )
    status.setStatusProperty("nekiHasStripesCrew", true)
  end

  --  finish with any other normal recruiting behavior
  self:_addCrew(recruitUuid, recruitInfo)
end

recruitSpawner._dismiss = recruitSpawner.dismiss
function recruitSpawner:dismiss(recruitUuid)

  --  grab recruit info from followers or ship crew as appropriate
  local recruitInfo = recruitSpawner:getRecruit(recruitUuid)

  --  when dismissing Stripes, remove the status property from the player so they can recruit her again
  if recruitInfo.spawnConfig.type == "nekistripescrewmember" then
    status.setStatusProperty("nekiHasStripesCrew", false)
  end

  --  finish with any other normal dismissal behavior
  self:_dismiss(recruitUuid)
end

local _offerRecruit = offerRecruit
function offerRecruit(uniqueId, position, recruitInfo, entityId)
  if recruitInfo.config.type == "nekistripescrewmember" then
    if status.statusProperty("nekiHasStripesCrew") then
      world.sendEntityMessage(uniqueId, "nekiStripesMultipleRecruitmentDisallowed")
      sb.logInfo("Only one copy of Stripes may be recruited at a time.")
      return
    end
  end
  return _offerRecruit(uniqueId, position, recruitInfo, entityId, "/interface/confirmation/recruitconfirmation.config", {})
end

recruitSpawner._recruitUnfollowing = recruitSpawner.recruitUnfollowing
function recruitSpawner:recruitUnfollowing(onShip, recruitUuid)
  --  when unfollowing Stripes, tell her to play the sad emote
  local recruitInfo = recruitSpawner:getRecruit(recruitUuid)
  if recruitInfo.spawnConfig.type == "nekistripescrewmember" then
    world.sendEntityMessage(recruitInfo.uniqueId, "nekiStripesPlayEmote", { emote = "sad" })
  end
  
  --  finish with any other normal unfollow behavior
  self:_recruitUnfollowing(onShip,recruitUuid)
end