do

local images_enabled = true;

local function get_sprite(path)
  local url = "http://pokeapi.co/"..path
  print(url)
  local b,c = http.request(url)
  local data = json:decode(b)
  local image = data.image
  return image
end

local function callback(extra)
  send_msg(extra.receiver, extra.text, ok_cb, false)
end

local function send_pokemon(query, receiver)
  local url = "http://pokeapi.co/api/v1/pokemon/" .. query .. "/"
  local b,c = http.request(url)
  local pokemon = json:decode(b)

  if pokemon == nil then
    return 'No pokémon found.'
  end
  
  local h = pokemon.height
  local w = pokemon.weight
  str:sub(1,pos-1), r, str:sub(pos+1, str:len())
  local text = 'Pokédex ID: ' .. pokemon.pkdx_id
    ..'\nName: ' .. pokemon.name
    ..'\nWeight: ' .. w:sub(1,h:len()-1) .. "." .. w:sub(w:len()-1, w:len()) .. " kg" --- api returns height and weight x10
    ..'\nHeight: ' .. h:sub(1,h:len()-1) .. "." .. h:sub(h:len()-1, h:len()) .. " m " --- need to change back to proper units
    ..'\nSpeed: ' .. pokemon.speed

  local image = nil

  if images_enabled and pokemon.sprites and pokemon.sprites[1] then
    local sprite = pokemon.sprites[1].resource_uri
    image = get_sprite(sprite)
  end

  if image then
    image = "http://pokeapi.co"..image
    local extra = {
      receiver = receiver,
      text = text
    }
    send_photo_from_url(receiver, image, callback, extra)
  else
    return text
  end
end

local function run(msg, matches)
  local receiver = get_receiver(msg)
  local query = URL.escape(matches[1])
  return send_pokemon(query, receiver)
end

return {
  description = "Pokedex searcher for Telegram",
  usage = "!pokedex [Name/ID]: Search the pokédex for Name/ID and get info of the pokémon!",
  patterns = {
    "^!pokedex (.*)$",
    "^!pokemon (.+)$"
  },
  run = run
}

end
