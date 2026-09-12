require "/scripts/messageutil.lua"

local old = init;

function init()
  if old then old() end
  message.setHandler("interact", localHandler(player.interact))
end
