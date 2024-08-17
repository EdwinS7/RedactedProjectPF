-- Coded while on the shroomies 🤤

local Color = {} Color.__index = nil

function Color.new(r, g, b, a)
    local self = setmetatable({}, Color)

    self.r = r
    self.g = g
    self.b = b
    self.a = a or 255

    return self
end

-- Config lolllz
    getgenv().Config = {
        ["Trigger Bot"] = true,

        ["Enemy Chams"] = true,
        ["Enemy Chams Fill Color"] = Color.new(0, 0, 0, 255),
        ["Enemy Chams Outline Color"] = Color.new(255, 140, 255, 255),

        ["Arm Chams"] = true,
        ["Arm Chams Material"] = "ForceField",
        ["Arm Chams Color"] = Color.new(255, 140, 255),

        ["Weapon Chams"] = true,
        ["Weapon Chams Material"] = "ForceField",
        ["Weapon Chams Color"] = Color.new(0, 140, 255)
    }
--

-- Connections system
    getgenv().ScriptConnections = getgenv().ScriptConnections or {}

    if next(getgenv().ScriptConnections) then
        for Name, Connection in getgenv().ScriptConnections do
            Connection:Disconnect()
            print("Disconnected", Name, "connection!")
        end
    end

    local function Connect(id, service, func)
        local Connection = getgenv().ScriptConnections[id]

        if Connection then
            Connection:Disconnect()
        end

        getgenv().ScriptConnections[id] = service:Connect(func)
        print("Connected function to", id, "connection!")
    end
--

-- GameWorkspace Table
    local GameWorkspace = {Viewmodel = {}} GameWorkspace.__index = nil

    function GameWorkspace:GetPlayerParts(player)
        local PlayerParts = {}

        for _, part in ipairs(player:GetChildren()) do
            if not (part and part:IsA("BasePart")) then
                continue
            end

            if not table.find(self.PlayerPartsToGet, part.Name) then
                continue
            end

            table.insert(PlayerParts, part)
        end

        return PlayerParts
    end

    function GameWorkspace.Viewmodel:GetArmParts()
        local ArmsObject = workspace:FindFirstChild("WeaponRigs")
    
        if not (ArmsObject and ArmsObject.arms) then
            return {}
        end

        local ArmParts = {}
    
        for _, part in ipairs(ArmsObject.arms:GetChildren()) do
            if not (part and part.Name:find("FirstPerson")) then
                continue
            end
    
            if not (part:IsA("MeshPart") and part.Transparency < 1) then
                continue
            end

            table.insert(ArmParts, part)
        end

        return ArmParts
    end

    function GameWorkspace.Viewmodel:GetWeaponParts()
        local WeaponObject = workspace:FindFirstChild("WeaponRigs")
    
        if not (WeaponObject and WeaponObject.arms) then
            return {}
        end
    
        local WeaponParts = {}
    
        for _, part in ipairs(WeaponObject.arms:GetChildren()) do
            if not (part and not part.Name:find("FirstPerson")) then
                continue
            end
    
            if not (part:IsA("MeshPart") and part.Transparency < 1) then
                continue
            end

            table.insert(WeaponParts, part)
        end

        return WeaponParts
    end
--

-- Aimbot Table (no work L, i think they got ts patched or its based off camera and not barrel, looks like its from barrel tho)
    local Aimbot = {} Aimbot.__index = nil

    function Aimbot:RunTriggerBot()
        
    end
--

-- Chams Table
    local Chams = {} Chams.__index = nil

    function Chams:UpdateArms()
        for _, part in ipairs(GameWorkspace.Viewmodel:GetArmParts()) do
            if part:FindFirstChildOfClass("SurfaceAppearance") then
                -- pcall to prevent weird crashes in some games.

                pcall(function()
                    part:FindFirstChildOfClass("SurfaceAppearance"):Destroy()
                end)
            end
    
            local Color = Config["Arm Chams Color"]

            part.Transparency = 1 - (Color.a / 255)
            part.Color = Color3.fromRGB(Color.r, Color.g, Color.b)
            part.Material = Config["Arm Chams Material"]
        end
    end
    
    function Chams:UpdateWeapon()
        for _, part in ipairs(GameWorkspace.Viewmodel:GetWeaponParts()) do
            if part.Name:find("Scope") then
                continue
            end

            if part:FindFirstChildOfClass("SurfaceAppearance") then
                -- pcall to prevent weird crashes in some games.

                pcall(function()
                    part:FindFirstChildOfClass("SurfaceAppearance"):Destroy()
                end)
            end
    
            local Color = Config["Weapon Chams Color"]

            part.Transparency = 1 - (Color.a / 255)
            part.Color = Color3.fromRGB(Color.r, Color.g, Color.b)
            part.Material = Config["Weapon Chams Material"]
        end
    end

    function Chams:UpdatePlayers()
        local FillColor = Config["Enemy Chams Fill Color"]
        local OutlineColor = Config["Enemy Chams Outline Color"]
    
        local FillColor3 = Color3.fromRGB(FillColor.r, FillColor.g, FillColor.b)
        local OutlineColor3 = Color3.fromRGB(OutlineColor.r, OutlineColor.g, OutlineColor.b)

        for i, highlight in workspace.PlayerHighlights:GetChildren() do
            highlight.Enabled = true
            
            highlight.FillColor = FillColor3
            highlight.OutlineColor = OutlineColor3
            
            highlight.FillTransparency = 1 - (FillColor.a / 255)
            highlight.OutlineTransparency = 1 - (OutlineColor.a / 255)

            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        end
    end
--

local LocalPlayer = nil

Connect("Main", game:GetService("RunService").Heartbeat, function()
    --[[if Config["Trigger Bot"] then
        Aimbot:RunTriggerBot()
    end]]

    if Config["Enemy Chams"] then
        Chams:UpdatePlayers()
    end

    if Config["Arm Chams"] then
        Chams:UpdateArms()
    end

    if Config["Weapon Chams"] then
        Chams:UpdateWeapon()
    end

    local LocalPlayer = workspace:FindFirstChild("Characters"):FindFirstChild(game.Players.LocalPlayer.Name)

    if not LocalPlayer then
        return
    end

    local LookVector = workspace.Camera.CFrame.LookVector
    local Direction = Vector3.new()

    local Directions = {
        [Enum.KeyCode.W] = LookVector,
        [Enum.KeyCode.A] = Vector3.new(LookVector.Z, 0, -LookVector.X),
        [Enum.KeyCode.S] = -LookVector,
        [Enum.KeyCode.D] = Vector3.new(-LookVector.Z, 0, LookVector.X),
        [Enum.KeyCode.LeftControl] = Vector3.new(0, -5, 0),
        [Enum.KeyCode.LeftShift] = Vector3.new(0, -5, 0),
        [Enum.KeyCode.Space] = Vector3.new(0, 5, 0)
    }

    for Key, Dir in pairs(Directions) do
        if game:GetService("UserInputService"):IsKeyDown(Key) then
            Direction = Direction + Dir
        end
    end

    if Direction.Magnitude > 0 then
        LocalPlayer.Top.Position = LocalPlayer.Top.Position + Direction.Unit
        LocalPlayer.Center.Position = LocalPlayer.Center.Position + Direction.Unit
        LocalPlayer.Bottom.Position = LocalPlayer.Bottom.Position + Direction.Unit

        LocalPlayer.Top.Anchored = true
        LocalPlayer.Center.Anchored = true
        LocalPlayer.Bottom.Anchored = true
    else
        LocalPlayer.Top.Anchored = true
        LocalPlayer.Center.Anchored = true
        LocalPlayer.Bottom.Anchored = true
    end
end)

print("[Redacted Project] Script loaded!")