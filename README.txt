KESSLER SYNDROME: Scrapsteroids Above Fulgora — Factorio Space Age Mod
======================================================================

CONCEPT
-------
Centuries of industrial activity have left Fulgora's orbit choked with
debris. The routes to the planet are littered with radioactive junk, growing
denser as you close in. In orbit itself the belt is overwhelmed — a true
Kessler Syndrome event frozen in time.


WHAT THIS MOD ADDS
------------------
TWO ASTEROID ENTITIES:
  • Scrapsteroid (small)  — glows faintly green, same toughness as base
                            game small metallic asteroids
  • Medium Scrapsteroid   — larger variant found only in Fulgora's orbit,
                            yields more chunks per hit

ONE CHUNK ITEM:
  • Scrapsteroid Chunk — subtle green-tinted metallic icon

TWO CRUSHER RECIPES:
  Basic Scrapsteroid Processing (unlocked from the start):
    • Scrap (5) — always

  Geiger Scrapsteroid Processing (unlocked via Nuclear Power research):
    • Scrap (3)                       — always
    • Depleted Uranium Fuel Cell (1)  — 10% chance
    • Nuclear Fuel (1)                — 0.5% chance

SPAWNING:
  • Transit routes (Nauvis, Vulcanus, Gleba ↔ Fulgora):
    Nothing until within 40% of the distance to Fulgora, then building
    to a dense cluster right at arrival. Direction-aware — the sparse
    zone always faces the non-Fulgora end of each route.

  • Fulgora orbit:
    10× the combined probability of all other asteroid types in orbit.
    Overwhelmingly scrap. Medium Scrapsteroids also appear at the same
    rate as medium metallic asteroids. Build extra crushers before you arrive.

SETTINGS:
  • Scrapsteroid Spawn Rate Multiplier (startup, default 1.0, range 0.1–10.0)
    Scales all Scrapsteroid spawn rates up or down to taste.


HOW TO INSTALL
--------------
1. Press Win+R → type %appdata%\Factorio\mods → Enter
2. Copy the Kessler-Syndrome-Factorio-Mod_0.1.0 folder in there
3. Launch Factorio → Mods → enable Kessler Syndrome
4. Requires Space Age DLC


TIPS
----
- The green glow makes Scrapsteroids easy to spot at a distance.
- With orbital volume, even the 10% and 0.5% chances add up fast.
  Run Geiger processing if you have Nuclear Power research.
- Scrap pairs naturally with Fulgora's recycler production chains.
- Use the spawn multiplier in mod settings if the orbit feels too
  overwhelming or not overwhelming enough.


COMPATIBILITY
-------------
Orbit patch scales dynamically to whatever asteroid probabilities
Fulgora already has, so other mods adding Fulgora asteroids are fine.
Transit connections are patched by explicit name with a full fallback scan,
and are direction-aware so they work regardless of how a connection is
oriented in the base game or other mods.
