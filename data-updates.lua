-- Kessler Syndrome: Scrap Above Fulgora
-- data-updates.lua

-- ============================================================
-- TRANSIT ROUTES: sparse near origin, dense approaching Fulgora
-- ============================================================
local TRANSIT_CONNECTIONS = {
  "nauvis-fulgora",
  "vulcanus-fulgora",
  "gleba-fulgora",
}

local function patch_transit(conn_name)
  local conn = data.raw["space-connection"][conn_name]
  if not conn then return false end
  conn.asteroid_spawn_definitions = conn.asteroid_spawn_definitions or {}

  -- Sample speed from existing spawn points
  local spd = 0.1
  for _, def in pairs(conn.asteroid_spawn_definitions) do
    if def.spawn_points then
      for _, pt in pairs(def.spawn_points) do
        if pt.speed and pt.speed > 0 then spd = pt.speed; break end
      end
    end
  end

  -- Sparse at the start, building to a dense cluster right before Fulgora
  table.insert(conn.asteroid_spawn_definitions, {
    asteroid    = "scrap-asteroid",
    spawn_points = {
      { distance = 0.0, probability = 0.000, speed = spd },
      { distance = 0.3, probability = 0.008, speed = spd },
      { distance = 0.6, probability = 0.025, speed = spd },
      { distance = 0.8, probability = 0.060, speed = spd },
      { distance = 0.9, probability = 0.080, speed = spd },
      { distance = 1.0, probability = 0.040, speed = spd },
    },
  })

  log("[kessler-syndrome] patched transit: " .. conn_name)
  return true
end

local patched = 0
for _, name in ipairs(TRANSIT_CONNECTIONS) do
  if patch_transit(name) then patched = patched + 1 end
end

-- Fallback scan if none of the explicit names matched
if patched == 0 then
  for name, conn in pairs(data.raw["space-connection"] or {}) do
    if conn.from == "fulgora" or conn.to == "fulgora" then
      patch_transit(name)
      log("[kessler-syndrome] fallback transit patch: " .. name)
    end
  end
end

-- ============================================================
-- FULGORA ORBIT: overwhelming numbers of small scrap asteroids
-- ============================================================
local fulgora = data.raw["planet"]["fulgora"]
             or data.raw["space-location"]["fulgora"]

if fulgora then
  fulgora.asteroid_spawn_definitions = fulgora.asteroid_spawn_definitions or {}

  -- Sum existing orbit probabilities and sample a speed value
  local existing_total = 0
  local spd = 0.1
  for _, def in pairs(fulgora.asteroid_spawn_definitions) do
    if def.probability then existing_total = existing_total + def.probability end
    if def.speed and def.speed > 0 then spd = def.speed end
  end
  if existing_total == 0 then existing_total = 0.1 end

  -- 5x the existing total — almost all of it scrap
  local scrap_prob = existing_total * 5

  table.insert(fulgora.asteroid_spawn_definitions, {
    asteroid    = "scrap-asteroid",
    probability = scrap_prob,
    speed       = spd,
  })

  log(string.format("[kessler-syndrome] Fulgora orbit: existing=%.4f scrap=%.4f", existing_total, scrap_prob))
else
  log("[kessler-syndrome] WARNING: fulgora planet/space-location not found")
end
