-- Add Colored Pipes
-- By robot256, 2024

local use_same_replace_group = settings.startup["rgbpipes-use-same-replace-group"].value

data:extend{
  {
    type = "item-subgroup",
    name = "colored-pipes",
    group = "logistics",
    order = "d[colored-pipes]"
  }
}
  
local techproto = 
{
  type = "technology",
  name = "colored-pipes",
  icons = {{icon = "__RGBPipes__/graphics/technology_transparent.png",
            icon_size = 1024,
            scale = 0.25 }},
  effects = {},
  prerequisites = {"fluid-handling"},
  unit =
  {
    count = 100,
    ingredients = {{"automation-science-pack", 1}, {"logistic-science-pack", 1}},
    time = 15
  }
}


local function addColoredPipe(proto, item, name, tint, order)
  -- Copy pipe entities
  local newpipe = table.deepcopy(proto)
  -- Apply new name and localised name
  newpipe.name = name.."-"..proto.name
  newpipe.order = "c[pipe]-d"..(order or "").."["..newpipe.name.."]"
  newpipe.placeable_by = {item=newpipe.name, count=1}
  newpipe.minable.result = newpipe.name
  if not use_same_replace_group then
    newpipe.fast_replaceable_group = "pipe-"..name
  end
  -- Tint entity icons
  if not newpipe.icons then
    newpipe.icons = {{icon=newpipe.icon, icon_size=newpipe.icon_size, tint=tint}}
  else
    newpipe.icons.tint = tint
  end
  newpipe.icon = nil
  -- Tint entity sprites
  for _,sprite in pairs(newpipe.pictures) do
    if sprite.layers then
      for _,layer in pairs(sprite.layers) do
        if not layer.draw_as_shadow then
          layer.tint = tint
        end
      end
    else
      sprite.tint = tint
    end
  end
  for _,sprite in pairs(newpipe.fluid_box.pipe_covers) do
    if sprite.layers then
      for _,layer in pairs(sprite.layers) do
        if not layer.draw_as_shadow then
          layer.tint = tint
        end
      end
    else
      sprite.tint = tint
    end
  end
  -- Set pipe connection categories
  for _,pcon in pairs(newpipe.fluid_box.pipe_connections) do
    pcon.connection_category = name.."-pipe"
  end
  
  -- Make item
  local newitem = table.deepcopy(item)
  newitem.name = newpipe.name
  newitem.order = newpipe.order
  newitem.subgroup = "colored-pipes"
  newitem.place_result = newpipe.name
  -- Tint item icons
  if not newitem.icons then
    newitem.icons = {{icon=newitem.icon, icon_size=newitem.icon_size, tint=tint}}
  else
    newitem.icons.tint = tint
  end
  newitem.icon = nil
  
  -- Make recipe
  local newrecipe = table.deepcopy(data.raw.recipe[proto.name])
  newrecipe.name = newpipe.name
  newrecipe.results[1].name = newpipe.name
  
  -- Add recipe to technology
  table.insert(techproto.effects, {type = "unlock-recipe", recipe = newpipe.name})
  
  data:extend{newpipe, newitem, newrecipe}
end

local pipe_types = {red={0.9,0.3,0.3,1}, green={0.3,0.9,0.3,1}, blue={0.3,0.3,0.9,1}}

local color_number = 1
for name,color in pairs(pipe_types) do
  addColoredPipe(data.raw.pipe.pipe, data.raw.item.pipe, name, color, string.format("%02d",color_number))
  color_number = color_number + 1
  addColoredPipe(data.raw["pipe-to-ground"]["pipe-to-ground"], data.raw.item["pipe-to-ground"], name, color, string.format("%02d",color_number))
  color_number = color_number + 1
end

data:extend{techproto}
