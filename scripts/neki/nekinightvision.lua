-- Made by Kherae for Juni <3
-- Refined by Bottinator22 <3

local oldUpdate = update

function update(...)
  localAnimator.clearLightSources()
  if oldUpdate ~= nil then
      oldUpdate(...)
  end
  if player.species() == "neki" then
    local lightval = math.min(125*status.resourcePercentage("health"),255)
    localAnimator.addLightSource(
      {
        color = {lightval, lightval, lightval},
        position = entity.position()
      }
    )
  end
end
