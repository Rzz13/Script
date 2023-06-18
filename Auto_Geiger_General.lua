bot = getBot()
geiger_worlds = "coliclear" 
storage_worlds = {
  { name = "coliclear", x = 7, y = 54, id = "GEIGER" }
}

webhook_enabled = true
webhook_url = "https://discord.com/api/webhooks/1119611818227290195/x000EfRjRrL4fFgV6PiJMvPAar3NTyQ2w1n7_ysXzzfj4FsgqpzQ5oLBk2TkGR3jclhY"
warp_interval = 5000
storage = storage_worlds[(script_id % #storage_worlds)+1]

items = { 6416, 3196, 1500, 1498, 2806, 2804, 8270, 8272, 8274, 4676, 4678, 4680, 4682, 4652, 4650, 4648, 4646, 11186, 10086, 10084, 2206, 2244, 2246, 2242, 2248, 2250, 3792, 3306, 4654, 3204 }

wh = Webhook.new(webhook_url)
wh.embed1.use = true
wh.embed1.color = 0xFFFFFF
wh.embed1.title = "Lucifer Geiger Logs"

if script_id > #geiger_worlds then
  error("Sorry, reached geiger world limit.")
end

geiger_world = geiger_worlds[script_id]

function log_msg(message)
  bot:getLog():append(string.format("[AutoGeiger]: %s\n", message))
  if webhook_enabled then
    wh.embed1.description = string.format("%s: %s", bot.name, message)
    wh:send()
  end
end

function is_in_world(geiger_world)
  return bot:getWorld().name:upper(geiger_world)
end

function is_in_tile(x, y)
  player = bot:getWorld():getLocal()
  if not player then 
    return false 
  end
  return math.floor(player.posx / 32) == x - 1 and math.floor(player.posy / 32) == y - 1
end

function drop_item(item)
  if not is_in_world(storage.name) then
    log_msg(string.format("Warping to storage world %s.", storage.name))
    bot:warp(storage.name)
    sleep(warp_interval)
    return
  end

  player = bot:getWorld():getLocal()
  if not player then
    log_msg("NetAvatar is not initialized yet.")
    sleep(200)
    return
  end

  if not is_in_tile(storage.x, storage.y) then
    log_msg(string.format("Entering Door at world position(%i:%i)", storage.x, storage.y))
    bot:warp(storage.name, storage.id)
    sleep(2000)
    return
  end

  item_count = bot:getInventory():findItem(item)
  if item_count > 0 then
    log_msg(string.format("Dropping Reward: %ix %s", item_count, getInfo(item).name))
    bot:drop(item, item_count)
    sleep(3000) -- Required for now.
  end
end

function checkinventory()
  inventory = bot:getInventory()
  for i, item in pairs(items) do
    if inventory:findItem(item) > 0 then
      return item
    end
  end

  return 0
end

function go_back()
  if not is_in_world(geiger_world) then
    log_msg(string.format("Warping back to geiger world(%s)", geiger_world))
    bot:warp(geiger_world)
    sleep(warp_interval)
    return false
  end

  return true
end

function process_auto_geiger()
  item = checkinventory()
  if item > 0 then
    bot.auto_geiger.enabled = false
    drop_item(item)
  else
    bot.auto_geiger.enabled = go_back()
  end
    sleep(500)
end

function contains(table, value)
    for i, element in pairs(table) do
        if element == value then
            return true
        end
    end
    return false
end

function is_valid()
    local valid_status_list = {
        BotStatus.offline,
        BotStatus.online,
        BotStatus.version_update,
        BotStatus.server_overload,
        BotStatus.server_busy,
        BotStatus.too_many_login,
        BotStatus.error_connecting,
        BotStatus.logon_fail
    }

    return contains(valid_status_list, bot.status)
end

function connect()
    while bot.status ~= BotStatus.online do
        bot:connect()
        sleep(30000)
        if not is_valid() then
            break
        end
    end
end

function main()
  log_msg("Started")
  while is_valid() do
    if bot.status == BotStatus.online then
      process_auto_geiger()
    else
      log_msg("Connecting Bot.")
      connect()
    end
  end
end

main()
