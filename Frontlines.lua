-- This was coded in litteral minutes idgaf, not meant to look nice or be nice.

local Config = {
    ["EnemyColor"] = Color3.fromRGB(0, 0, 0),
    ["EnemyOutlineColor"] = Color3.fromRGB(255, 0, 120),
    ["WeaponColor"] = Color3.fromRGB(255, 255, 255),
    ["ArmsColor"] = Color3.fromRGB(255, 0, 120)
}

-- Get localplayer viewmodel arms
local function UpdateArms()
    for i, v in pairs(workspace:GetChildren()) do
        if not (v and v.Name == "soldier_model" and v:IsA("Model")) then
            continue
        end
    
        local ArmsObject = v:FindFirstChildWhichIsA("Model")
    
        if not ArmsObject then
            continue
        end
    
        for _, part in pairs(ArmsObject:GetChildren()) do
            if not (part and part:IsA("MeshPart") and part.Transparency < 1) then
                continue
            end
    
            if part:FindFirstChild("SurfaceAppearance") then
                part.SurfaceAppearance:Destroy()
            end
    
            part.TextureID = "rbxassetid://3232760968"
            part.Color = Config["ArmsColor"]
            part.Material = "ForceField"
        end
    end
end

-- Get players
local function UpdatePlayers()
    for i, v in pairs(Workspace:GetChildren()) do
        if not (v and v.Name == "soldier_model" and v:IsA("Model")) then
            continue
        end

        if v:FindFirstChild("friendly_marker") then
            continue
        end

        local Highlight = v:FindFirstChildOfClass("Highlight")

        if v:FindFirstChildWhichIsA("Model") then
            if Highlight then --Fix for spawning in, doesnt detect local arms.
                Highlight:Destroy()
            end

            continue
        end

        if not Highlight then
            Highlight = Instance.new("Highlight", v)
        end

        Highlight.Enabled = true
        Highlight.Adornee = v

        Highlight.FillColor = Config["EnemyColor"]
        Highlight.OutlineColor = Config["EnemyOutlineColor"]
        
        Highlight.FillTransparency = nil
        Highlight.OutlineTransparency = nil

        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
end

-- Update loop
game:GetService("RunService").Heartbeat:Connect(function()
    UpdatePlayers()
    UpdateArms()
end)
