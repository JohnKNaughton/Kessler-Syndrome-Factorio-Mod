-- Kessler Syndrome: Scrap Above Fulgora
-- data-final-fixes.lua — guarantee dying_trigger_effect is correct after all mods load

local ast = data.raw["asteroid"]["scrap-asteroid"]
if not ast then
  log("[kessler-syndrome] FINAL: scrap-asteroid not found!")
  return
end

-- Force the dying_trigger_effect so Space Age can't overwrite us
local fixed = false
if ast.dying_trigger_effect then
  for _, effect in pairs(ast.dying_trigger_effect) do
    if effect.type == "create-asteroid-chunk" then
      log("[kessler-syndrome] FINAL: was asteroid_name=" .. tostring(effect.asteroid_name))
      effect.asteroid_name = "scrap-asteroid-chunk"
      fixed = true
    end
  end
end

if not fixed then
  ast.dying_trigger_effect = {
    { type = "create-asteroid-chunk", asteroid_name = "scrap-asteroid-chunk" }
  }
  log("[kessler-syndrome] FINAL: created dying_trigger_effect from scratch")
else
  log("[kessler-syndrome] FINAL: dying_trigger_effect fixed -> scrap-asteroid-chunk")
end

-- Also fix minable on the chunk entity in case it was reset
local chunk_entity = data.raw["asteroid-chunk"]["scrap-asteroid-chunk"]
if chunk_entity and chunk_entity.minable then
  chunk_entity.minable.result = "scrap-asteroid-chunk"
  log("[kessler-syndrome] FINAL: chunk minable.result fixed")
end
