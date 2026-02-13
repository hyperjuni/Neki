-- Created by Bott and further refined with Lofty's help <3

local findPromise
function update(dt)
  if player.species() == "neki" 
  and player.introComplete() 
  and not player.hasCompletedQuest("nekitutorialbasic")
  and world.type() == "unknown" then
    if findPromise then
      if findPromise:finished() then
        script.setUpdateDelta(0)
        if not findPromise:succeeded()
        and not player.getProperty("completedNekiTutorial") then
          player.startQuest("nekitutorialbasicbyos")
          player.giveItem("nekitutorialbasic-codex")
          player.setProperty("completedNekiTutorial", true)
        end
      end
    else
      findPromise = world.findUniqueEntity("nekitutorialbasic")
    end
  end
end
