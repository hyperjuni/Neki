-- Made by Erina Sugino for Juni <3

local Original_Init = init

function init()
  xpcall(function()
    Original_Init()
    local species = player.species()
    if species ~= "neki" then
      return
    end
    player.makeTechAvailable("nekihops")
  end, sb.logError)
end
