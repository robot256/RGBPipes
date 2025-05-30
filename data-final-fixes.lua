----------------------
-- Change the connection categories of all the other entities with default pipe connections


local default_categories = {"default"}
for _,effect in pairs(data.raw.technology["colored-pipes"].effects) do
  local name = effect.recipe
  if data.raw.pipe[name] and name ~= "black-pipe" then
    default_categories[#default_categories+1] = name
  end
end

local function makeFluidBoxUniversal(fluidbox)
  local changed = false
  for _,pcon in pairs(fluidbox.pipe_connections) do
    if not pcon.connection_type or pcon.connection_type == "normal" then
      -- Only change entities that have default connection category
      if (not pcon.connection_category) or (type(pcon.connection_category) == "string" and pcon.connection_category == "default") or 
         (type(pcon.connection_category) == "table" and #pcon.connection_category == 1 and pcon.connection_category[1] == "default") then
        --local old = table.deepcopy(pcon.connection_category)
        pcon.connection_category = table.deepcopy(default_categories)
        --log("Changed "..serpent.line(old).." to "..serpent.line(pcon.connection_category))
        changed = true
      end
    end
  end
  return changed
end

-- Make every *default* pipe connection of these connect to every color
-- This is every prototype that has a fluid_box or can accept a FluidEnergySource
local change_types = {
  "pipe",
  "pipe-to-ground",
  "pump",
  "infinity-pipe",
  "storage-tank",
  "assembling-machine",
  "furnace",
  "boiler",
  "fluid-turret",
  "mining-drill",
  "offshore-pump",
  "generator",
  "fusion-generator",
  "fusion-reactor",
  "thruster",
  "inserter",
  "agricultural-tower",
  "lab",
  "radar",
  "reactor",
  "loader"
}

for _,rawtype in pairs(change_types) do
  if data.raw[rawtype] then
    for _,proto in pairs(data.raw[rawtype]) do
      local changed = false
      if proto.fluid_boxes then
        for _,fb in pairs(proto.fluid_boxes) do
          changed = makeFluidBoxUniversal(fb) or changed
        end
      end
      if proto.fluid_box then
        changed = makeFluidBoxUniversal(proto.fluid_box) or changed
      end
      if proto.input_fluid_box then
        changed = makeFluidBoxUniversal(proto.input_fluid_box) or changed
      end
      if proto.output_fluid_box then
        changed = makeFluidBoxUniversal(proto.output_fluid_box) or changed
      end
      if proto.fuel_fluid_box then
        changed = makeFluidBoxUniversal(proto.fuel_fluid_box) or changed
      end
      if proto.oxidizer_fluid_box then
        changed = makeFluidBoxUniversal(proto.oxidizer_fluid_box) or changed
      end
      if proto.energy_source and proto.energy_source.fluid_box then
        changed = makeFluidBoxUniversal(proto.energy_source.fluid_box) or changed
      end
      if changed then
        log("Added colored pipes to one or more pipe connection on "..rawtype.."."..proto.name)
      end
    end
  end
end
