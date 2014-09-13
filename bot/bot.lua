http = require("socket.http")
json = (loadfile "./bot/JSON.lua")()

VERSION = 'v0.2'


function on_msg_receive (msg)

  if msg_valid(msg) == false then
    return
  end
  -- Check if command starts with ! eg !echo
  if msg.text:sub(0,1) == '!' then
    do_action(msg)
  else
  if is_image_url(msg.text) then
      send_image_from_url (msg)
    end
  end

  print('mark_read: '..get_receiver(msg))
  mark_read(get_receiver(msg), ok_cb, false)
  -- write_log_file(msg)
end


function ok_cb(extra, success, result)
end

function msg_valid(msg)
   if msg.out then
      return false
   end
   if msg.date < now then
     return false
   end
   if msg.text == nil then
      return false
   end
   if msg.unread == 0 then
      return false
   end
end

function send_image_from_url (msg)
  last = string.get_last_word(msg.text)
  last = last:match("[%w_:/.%%&-]+") -- Lets sanitize!
  extension = string.get_extension_from_filename(last)

  file_name = string.random(5)
  file = "/tmp/"..file_name.."."..extension
  sh = "curl --insecure -o '"..file.."' "..last
  run_bash(sh)
  send_photo(get_receiver(msg), file, ok_cb, false)
end

function is_image_url(text)
  print ('IS image ' .. text ..'?')
  last = string.get_last_word(text)
  extension = string.get_extension_from_filename(last)
  if extension == 'jpg' or extension == 'png' then
    return true
  end
  return false
end

-- Where magic happens
function do_action(msg)
   local receiver = get_receiver(msg)

   if string.starts(msg.text, '!sh') then
      text = run_sh(msg)
      send_msg(receiver, text, ok_cb, false)
      return
   end
  
   if string.starts(msg.text, '!uc3m') then
      text = get_fortunes_uc3m()
      send_msg(receiver, text, ok_cb, false)
      return
   end 

   if string.starts(msg.text, '!9gag') then
      url, title = get_9GAG()
      file_name = url:match("([^/]+)$")
      file = "/tmp/"..file_name
      sh = "curl -o '"..file.."' "..url
      run_bash(sh)
      send_photo(receiver, file, ok_cb, false)
      send_msg(receiver, title, ok_cb, false)
      return
   end 

   if string.starts(msg.text, '!fortune') then
      text = run_bash('fortune')
      send_msg(receiver, text, ok_cb, false)
      return
   end 

   if string.starts(msg.text, '!forni') then
      text = msg.text:sub(8,-1)
      send_msg('Fornicio_2.0', text, ok_cb, false)
      return
   end 

   if string.starts(msg.text, '!fwd') then
      fwd_msg (receiver, msg.id, ok_cb, false)
      return
   end 

   if string.starts(msg.text, '!cpu') then
      text = run_bash('uname -snr') .. ' ' .. run_bash('whoami')
      text = text .. '\n' .. run_bash('top -b |head -2')
      send_msg(receiver, text, ok_cb, false)
      return
   end

   if string.starts(msg.text, '!ping') then
      print('receiver: '..receiver)
      send_msg (receiver, 'pong', ok_cb, false)
      return
   end

   if string.starts(msg.text, '!weather') then
      if string.len(msg.text) <= 9 then
         city = 'Madrid,ES'
      else  
         city = msg.text:sub(10,-1)
      end    
      text = get_weather(city)
      send_msg(receiver, text, ok_cb, false)
      return
   end

   if string.starts(msg.text, '!echo') then
      echo = msg.text:sub(7,-1)
      send_msg(receiver, echo, ok_cb, false)
      return
   end

   if string.starts(msg.text, '!version') then
      text = 'James Bot '.. VERSION
      send_msg(receiver, text, ok_cb, false)
      return
   end

   if string.starts(msg.text, '!help') then
      text = [[!help : print this help 
!ping : bot sends pong 
!sh (text) : send commands to bash (only privileged users)
!echo (text) : echo the msg 
!version : version info
!cpu : status (uname + top)
!fwd : forward msg
!forni : send text to group Fornicio
!fortune : print a random adage
!weather [city] : weather in that city (Madrid if not city)
!9gag : send random url image from 9gag
!uc3m : fortunes from Universidad Carlos III]]
      send_msg(receiver, text, ok_cb, false)
      return
   end

end

function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function load_config()
   local f = assert(io.open('./bot/config.json', "r"))
   local c = f:read "*a"
   local config = json:decode(c)
   if config.torrent_path then 
      print ("!sh command is enabled")
      for v,user in pairs(config.sudo_users) do
         print("Allowed user: " .. user)
      end
   end
   -- print("Torrent path: " .. config.torrent_path)
   f:close()
   return config
end

function is_sudo(msg)
   local var = false
   -- Check users id in config 
   for v,user in pairs(config.sudo_users) do 
      if user == msg.from.id then 
         var = true 
      end
   end
   return var
end

function write_log_file(msg)
  name = get_name(msg)
  ret = name .. ' > ' .. msg.text
  write_to_file(config.log_file, ret)
end

-- Saves a string to file
function write_to_file(filename, value)
  if (value) then
    local file = io.open(filename,"a")
    file:write(value, "\n")
    file:close()
  end
end

function get_name(msg)
   local name = msg.from.first_name
   if name == nil then
      name = msg.from.id
   end
   return name
end

function run_sh(msg)
   name = get_name(msg)
   text = ''
   if config.sh_enabled == false then 
      text = '!sh command is disabled'
   else
      if is_sudo(msg) then
         bash = msg.text:sub(4,-1)
         text = run_bash(bash)
      else
         text = name .. ' you have no power here!'
      end
   end
   return text
end

function run_bash(str)
  local cmd = io.popen(str)
  local result = cmd:read('*all')
  cmd:close()
  return result
end

function get_fortunes_uc3m()
   math.randomseed(os.time())
   local i = math.random(0,178) -- max 178
   local web = "http://www.gul.es/fortunes/f"..i 
   b, c, h = http.request(web)
   return b
end

function get_9GAG()
   b = http.request("http://api-9gag.herokuapp.com/")
   local gag = json:decode(b)
   math.randomseed(os.time())
   i = math.random(#gag) -- random max json table size (# is an operator o.O)
   local link_image = gag[i].src
   local title = gag[i].title
   if link_image:sub(0,2) == '//' then
      link_image = msg.text:sub(3,-1)
   end
   return link_image, title
end

function get_weather(location)
   b, c, h = http.request("http://api.openweathermap.org/data/2.5/weather?q=" .. location .. "&units=metric")
   weather = json:decode(b)
   local city = weather.name
   local country = weather.sys.country
   temp = 'The temperature in ' .. city .. ' (' .. country .. ')'
   temp = temp .. ' is ' .. weather.main.temp .. '°C'
   conditions = 'Current conditions are: ' .. weather.weather[1].description
   if weather.weather[1].main == 'Clear' then
	  conditions = conditions .. ' ☀'
   elseif weather.weather[1].main == 'Clouds' then
	  conditions = conditions .. ' ☁☁'
   elseif weather.weather[1].main == 'Rain' then
	  conditions = conditions .. ' ☔'
   elseif weather.weather[1].main == 'Thunderstorm' then
	  conditions = conditions .. ' ☔☔☔☔'
   end
   return temp .. '\n' .. conditions
end

function string.random(length)
   math.randomseed(os.time())
   local str = "";
   for i = 1, length do
      math.random(97, 122)
      str = str..string.char(math.random(97, 122));
   end
   return str;
end

function string.get_extension_from_filename( filename )
  return filename:match( "%.([^%.]+)$" )
end

function string.get_last_word( words )
  print ('Last word of: ' .. words)
  local splitted = split_by_space ( words )
  return splitted[#splitted]
end

function split_by_space ( text )
  print ('Split: ' .. text)
  words = {}
  for word in string.gmatch(text, "[^%s]+") do
     table.insert(words, word) 
  end
  return words
end

function vardump(value, depth, key)
  local linePrefix = ""
  local spaces = ""
  
  if key ~= nil then
    linePrefix = "["..key.."] = "
  end
  
  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do spaces = spaces .. "  " end
  end
  
  if type(value) == 'table' then
    mTable = getmetatable(value)
    if mTable == nil then
      print(spaces ..linePrefix.."(table) ")
    else
      print(spaces .."(metatable) ")
        value = mTable
    end		
    for tableKey, tableValue in pairs(value) do
      vardump(tableValue, depth, tableKey)
    end
  elseif type(value)	== 'function' or 
      type(value)	== 'thread' or 
      type(value)	== 'userdata' or
      value		== nil
  then
    print(spaces..tostring(value))
  else
    print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
  end
end

-- Start and load values
config = load_config()
our_id = 0
now = os.time()

function get_receiver(msg)
  if msg.to.type == 'user' then
    return 'user#id'..msg.from.id
  end
  if msg.to.type == 'chat' then
    return 'chat#id'..msg.to.id
  end
end


function on_our_id (id)
  our_id = id
end

function on_user_update (user, what)
  --vardump (user)
end

function on_chat_update (chat, what)
  --vardump (chat)
end

function on_secret_chat_update (schat, what)
  --vardump (schat)
end

function on_get_difference_end ()
end

function on_binlog_replay_end ()
  started = 1
end