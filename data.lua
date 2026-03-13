-- Kessler Syndrome: Scrap Above Fulgora
-- data.lua

local GREEN_TINT = { r = 0.6, g = 1.0, b = 0.6, a = 1.0 }

-- ============================================================
-- HELPER: recursively apply tint to a sprite/animation set
-- ============================================================
local function tint_sprite(s)
  if not s then return end
  if s.layers  then for _, l in pairs(s.layers)  do tint_sprite(l) end
  elseif s.sheets then for _, sh in pairs(s.sheets) do sh.tint = GREEN_TINT end
  elseif s.sheet  then s.sheet.tint = GREEN_TINT
  else s.tint = GREEN_TINT end
end

-- ============================================================
-- CHUNK ITEM: Scrap Asteroid Chunk
-- Deep-copy the metallic chunk. Key fixes:
--   1. Green-tinted icons array for visual distinction
--   2. Update minable.result so the collector arm yields OUR chunk item
--   3. results = crusher output (crusher reads this directly)
-- ============================================================
local chunk = table.deepcopy(data.raw["asteroid-chunk"]["metallic-asteroid-chunk"])
chunk.name  = "scrap-asteroid-chunk"
chunk.order = "z[scrap-asteroid-chunk]"

-- Green-tinted icon (two-layer: base sprite + green overlay)
chunk.icon  = nil
chunk.icons = {
  { icon = "__space-age__/graphics/icons/metallic-asteroid-chunk.png", icon_size = 64 },
  { icon = "__space-age__/graphics/icons/metallic-asteroid-chunk.png", icon_size = 64,
    tint = { r = 0.0, g = 0.85, b = 0.0, a = 0.5 } },
}

-- Fix minable so the collector arm produces the right item
if chunk.minable then
  chunk.minable.result = "scrap-asteroid-chunk"
end

-- Crusher output
chunk.results = {
  { type = "item", name = "scrap",                     amount_min = 4, amount_max = 9, probability = 1.0  },
  { type = "item", name = "depleted-uranium-fuel-cell", amount_min = 1, amount_max = 2, probability = 0.55 },
  { type = "item", name = "uranium-235",               amount = 1,                     probability = 0.02 },
}

-- Also define a matching ITEM prototype — this is what recipe ingredients
-- reference with type="item". The base game defines both an asteroid-chunk
-- entity AND a separate item prototype with the same name.
local chunk_item = table.deepcopy(data.raw["item"]["metallic-asteroid-chunk"])
chunk_item.name  = "scrap-asteroid-chunk"
chunk_item.order = "z[scrap-asteroid-chunk]"
chunk_item.icon  = nil
chunk_item.icons = {
  { icon = "__space-age__/graphics/icons/metallic-asteroid-chunk.png", icon_size = 64 },
  { icon = "__space-age__/graphics/icons/metallic-asteroid-chunk.png", icon_size = 64,
    tint = { r = 0.0, g = 0.85, b = 0.0, a = 0.5 } },
}

data:extend({ chunk, chunk_item })

-- ============================================================
-- CRUSHER RECIPES
-- Base game uses type="item" for asteroid chunk ingredients.
-- Subgroup "space-crushing" confirmed from Space Age source.
-- ============================================================
data:extend({
  {
    type            = "recipe",
    name            = "scrap-asteroid-chunk-basic",
    category        = "crushing",
    subgroup        = "space-crushing",
    order           = "z[scrap-asteroid-chunk]-a",
    enabled         = true,
    auto_recycle    = false,
    energy_required = 2,
    icons = {
      { icon = "__space-age__/graphics/icons/metallic-asteroid-chunk.png", icon_size = 64 },
      { icon = "__space-age__/graphics/icons/metallic-asteroid-chunk.png", icon_size = 64,
        tint = { r = 0.0, g = 0.85, b = 0.0, a = 0.5 } },
    },
    ingredients = { { type = "item", name = "scrap-asteroid-chunk", amount = 1 } },
    results     = {
      { type = "item", name = "scrap", amount_min = 4, amount_max = 9 },
    },
  },
  {
    type            = "recipe",
    name            = "scrap-asteroid-chunk-advanced",
    category        = "crushing",
    subgroup        = "space-crushing",
    order           = "z[scrap-asteroid-chunk]-b",
    enabled         = false,
    auto_recycle    = false,
    energy_required = 5,
    icons = {
      { icon = "__space-age__/graphics/icons/metallic-asteroid-chunk.png", icon_size = 64 },
      { icon = "__space-age__/graphics/icons/metallic-asteroid-chunk.png", icon_size = 64,
        tint = { r = 0.0, g = 0.85, b = 0.0, a = 0.5 } },
    },
    ingredients = { { type = "item", name = "scrap-asteroid-chunk", amount = 1 } },
    results     = {
      { type = "item", name = "scrap",                     amount_min = 3, amount_max = 6                     },
      { type = "item", name = "depleted-uranium-fuel-cell", amount_min = 1, amount_max = 2, probability = 0.55 },
      { type = "item", name = "uranium-235",               amount = 1,                     probability = 0.02 },
    },
  },
})

-- Unlock advanced recipe via Nuclear Power (fallback: Uranium Processing)
local function add_unlock(tech_name)
  local tech = data.raw["technology"][tech_name]
  if not tech then return false end
  tech.effects = tech.effects or {}
  table.insert(tech.effects, { type = "unlock-recipe", recipe = "scrap-asteroid-chunk-advanced" })
  return true
end
if not add_unlock("nuclear-power") then add_unlock("uranium-processing") end

-- ============================================================
-- ASTEROID ENTITY: small scrap asteroid
-- Key fix: override dying_trigger_effect so the "create-asteroid-chunk"
-- action names OUR chunk, not metallic-asteroid-chunk.
-- ============================================================
local function find_source(names, pattern)
  for _, n in ipairs(names) do
    if data.raw["asteroid"][n] then
      log("[kessler-syndrome] source: " .. n); return data.raw["asteroid"][n]
    end
  end
  for n in pairs(data.raw["asteroid"] or {}) do
    if n:find(pattern) then
      log("[kessler-syndrome] pattern source: " .. n); return data.raw["asteroid"][n]
    end
  end
  log("[kessler-syndrome] WARNING: fallback big-metallic"); return data.raw["asteroid"]["big-metallic-asteroid"]
end

local src = find_source(
  { "small-metallic-asteroid", "small-carbonic-asteroid", "small-oxide-asteroid" }, "small"
)

local ast = table.deepcopy(src)
ast.name           = "scrap-asteroid"
ast.localised_name = { "entity-name.scrap-asteroid" }
tint_sprite(ast.graphics_set)

-- THE ACTUAL FIX: override dying_trigger_effect to drop our chunk
if ast.dying_trigger_effect then
  for _, effect in pairs(ast.dying_trigger_effect) do
    if effect.type == "create-asteroid-chunk" then
      effect.asteroid_name = "scrap-asteroid-chunk"
      log("[kessler-syndrome] Fixed dying_trigger_effect asteroid_name -> scrap-asteroid-chunk")
    end
  end
else
  -- Safety net: define a minimal trigger if source had none
  ast.dying_trigger_effect = {
    { type = "create-asteroid-chunk", asteroid_name = "scrap-asteroid-chunk" }
  }
  log("[kessler-syndrome] Created dying_trigger_effect from scratch")
end

ast.light = { intensity = 0.8, size = 20, color = { r = 0.2, g = 1.0, b = 0.2 } }

data:extend({ ast })
