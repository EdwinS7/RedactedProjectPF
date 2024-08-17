local Repository = "https://raw.githubusercontent.com/EdwinS7/RedactedProjectPF/main/"

local _SUPPORTED_GAMES = {
    [292439477] = Repository .. "PhantomForces.lua",    -- Phantom Forces
    [299659045] = Repository .. "PhantomForces.lua",    -- Phantom Forces Test Place
    [5938036553] = Repository .. "Frontlines.lua",        -- Frontlines
    [7796842481] = Repository .. "Riotfall.lua"           -- Riotfall
}

local our_game = _SUPPORTED_GAMES[PlaceId]

if not our_game then
    warn("[Loader] This game is currently unsupported!")
    return
end

loadstring(game:HttpGet(our_game))()