local Repository = "https://raw.githubusercontent.com/EdwinS7/RedactedProjectPF/main/"

local SupportedGames = {
    [292439477] = Repository .. "PhantomForces.lua",    -- Phantom Forces
    [299659045] = Repository .. "PhantomForces.lua",    -- Phantom Forces Test Place
    [5938036553] = Repository .. "Frontlines.lua",        -- Frontlines
    [12615683183] = Repository .. "Riotfall.lua"           -- Riotfall
}

local OurGame = SupportedGames[game.PlaceId]

if not OurGame then
    warn("[Loader] Game unsupported!")
    return
end

loadstring(game:HttpGet(OurGame))()
