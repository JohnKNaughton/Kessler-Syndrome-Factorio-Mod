-- Kessler Syndrome: Scrap Above Fulgora
-- data-updates.lua

local MULTIPLIER = settings.startup["kessler-syndrome-spawn-multiplier"].value

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

  -- Spawn only within 40% of Fulgora. Direction matters: distance=0 is conn.from,
  -- distance=1 is conn.to, so flip points if Fulgora is the origin end.
  local m = MULTIPLIER
  local spawn_points
  if conn.to == "fulgora" then
    spawn_points = {
      { distance = 0.0, probability = 0.000,      speed = spd },
      { distance = 0.6, probability = 0.000,      speed = spd },
      { distance = 0.8, probability = 0.060 * m,  speed = spd },
      { distance = 0.9, probability = 0.080 * m,  speed = spd },
      { distance = 1.0, probability = 0.080 * m,  speed = spd },
    }
  else
    spawn_points = {
      { distance = 0.0, probability = 0.080 * m,  speed = spd },
      { distance = 0.1, probability = 0.080 * m,  speed = spd },
      { distance = 0.2, probability = 0.060 * m,  speed = spd },
      { distance = 0.4, probability = 0.000,      speed = spd },
      { distance = 1.0, probability = 0.000,      speed = spd },
    }
  end

  table.insert(conn.asteroid_spawn_definitions, {
    asteroid     = "scrap-asteroid",
    spawn_points = spawn_points,
  })

  log("[kessler-syndrome] patched transit: " .. conn_name .. " (fulgora is " .. (conn.to == "fulgora" and "to" or "from") .. ")")
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
-- FULGORA ORBIT: overwhelming small scrap + medium scrap at
--                the same rate as medium metallic asteroids
-- ============================================================
local fulgora = data.raw["planet"]["fulgora"]
             or data.raw["space-location"]["fulgora"]

if fulgora then
  fulgora.asteroid_spawn_definitions = fulgora.asteroid_spawn_definitions or {}

  -- Sum existing orbit probabilities, sample speed, and find medium metallic rate
  local existing_total = 0
  local medium_metallic_prob = 0
  local spd = 0.1
  for _, def in pairs(fulgora.asteroid_spawn_definitions) do
    if def.probability then existing_total = existing_total + def.probability end
    if def.speed and def.speed > 0 then spd = def.speed end
    if def.asteroid == "medium-metallic-asteroid" and def.probability then
      medium_metallic_prob = def.probability
    end
  end
  if existing_total == 0 then existing_total = 0.1 end

  -- 10x the existing total for small scrap asteroids
  local scrap_prob = existing_total * 10 * MULTIPLIER

  table.insert(fulgora.asteroid_spawn_definitions, {
    asteroid    = "scrap-asteroid",
    probability = scrap_prob,
    speed       = spd,
  })

  -- Medium scrapsteroids at the same rate as medium metallic (if found)
  if medium_metallic_prob > 0 and data.raw["asteroid"]["medium-scrap-asteroid"] then
    table.insert(fulgora.asteroid_spawn_definitions, {
      asteroid    = "medium-scrap-asteroid",
      probability = medium_metallic_prob * MULTIPLIER,
      speed       = spd,
    })
    log(string.format("[kessler-syndrome] Fulgora orbit: medium-scrap=%.4f", medium_metallic_prob * MULTIPLIER))
  else
    log("[kessler-syndrome] Fulgora orbit: medium-metallic not found or entity missing, skipping medium scrap")
  end

  log(string.format("[kessler-syndrome] Fulgora orbit: existing=%.4f small-scrap=%.4f multiplier=%.2f",
    existing_total, scrap_prob, MULTIPLIER))
else
  log("[kessler-syndrome] WARNING: fulgora planet/space-location not found")
end
