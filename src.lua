-- Stop pasting my lua you fucking degenerate loser, Ts got no use to you and its dogshit cuz there is no use of hooking thanks to our favorite executor solara!
-- Script is not actually called redacted, We just didn't care enough to fuckin name it.

if game.PlaceId ~= 292439477 and game.PlaceId ~= 299659045 then
    error("Redacted-project is only supported by Phantom Forces!")
end

local Redacted = {
    Username = "user",
    Developer = false,
    Accent = Color3.fromRGB(140, 130, 255)
}

-- Modified Linoria-Lib (Literally only set the default menu key, Insert)
local Library = loadstring(game:HttpGet('https://pastebin.com/raw/9050wrS0'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua'))()

-- Set default keybind & accent color
Library.AccentColor = Redacted.Accent

-- Get Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Get/Create Game Vars
local Camera = Workspace.CurrentCamera
local ColorRGB = Color3.fromRGB
local ColorHSV = Color3.fromHSV
local ColorHex = Color3.fromHex
local Vec2 = Vector2.new
local Vec3 = Vector3.new

-- Config/Default Config
local Config = {
    Ragebot = {
        General = {
            Enabled = false,
            FieldOfView = 180,

            -- OPTIONS: {"Closest to crosshair", "Distance"}
            TargetSelection = 0,

            Autofire = false,
    
            Hitboxes = {}
        },

        Other = {}
    },

    AntiAim = {
        General = {
            Enabled = false,
        }
    },

    Visuals = {
        Players = {
            Boxes = {
                Enabled = false,
                Color = ColorRGB(255, 255, 255)
            },

            Chams = { 
                Enabled = false,
                FillColor = ColorRGB(0, 0, 0),
                OutlineColor = Redacted.Accent
            },
            
            WeaponChams = {
                Enabled = false,
                Color = Redacted.Accent,

                -- OPTIONS: Storage.PartMaterials
                Material = 22 -- ForceField Default
            },

            ArmChams = {
                Enabled = false,
                Color = Redacted.Accent,

                -- OPTIONS: Storage.PartMaterials
                Material = 22 -- ForceField Default
            }
        },

        World = {
            OverrideAmbient = {
                Enabled = false, 
                Color = Redacted.Accent
            },

            SkyboxChanger = {
                Enabled = false,
                Value = "Neptune"
            }
        },

        Throwables = {},

        Other = {
            Crosshair = {
                Enabled = false,
                Color = ColorRGB(255, 255, 255)
            },

            VisualizeFOV = {
                Enabled = false,
                ActiveColor = ColorRGB(25, 255, 25), -- Light green
                InactiveColor = ColorRGB(255, 25, 25) -- Light red
            }
        }
    },

    Misc = {
        Movement = {
            Bhop = false,
        
            FlyHack = {
                Enabled = false,
                Value = 40
            },

            SpeedHack = {
                Enabled = false,
                Value = 45
            }
        },

        Other = {
            OverrideHipheight = {
                Enabled = false,
                Height = 20
            },
        }
    }
}

-- Saved/Stored data, Used for mostly everything in our script requiring resetable data.
local Storage = {
    BodySizes = {
        ["Head"] = Vec3(1, 1, 1),
        ["Torso"] = Vec3(2, 2, 1),
        ["LeftArm"] = Vec3(1, 2, 1),
        ["RightArm"] = Vec3(1, 2, 1),
        ["LeftLeg"] = Vec3(1, 2, 1),
        ["RightLeg"] = Vec3(1, 2, 1)
    },

    Skyboxes = {
		["Purple Nebula"] = {
			["SkyboxBk"] = "rbxassetid://159454299",
			["SkyboxDn"] = "rbxassetid://159454296",
			["SkyboxFt"] = "rbxassetid://159454293",
			["SkyboxLf"] = "rbxassetid://159454286",
			["SkyboxRt"] = "rbxassetid://159454300",
			["SkyboxUp"] = "rbxassetid://159454288"
		},
		["Night Sky"] = {
			["SkyboxBk"] = "rbxassetid://12064107",
			["SkyboxDn"] = "rbxassetid://12064152",
			["SkyboxFt"] = "rbxassetid://12064121",
			["SkyboxLf"] = "rbxassetid://12063984",
			["SkyboxRt"] = "rbxassetid://12064115",
			["SkyboxUp"] = "rbxassetid://12064131"
		},
		["Pink Daylight"] = {
			["SkyboxBk"] = "rbxassetid://271042516",
			["SkyboxDn"] = "rbxassetid://271077243",
			["SkyboxFt"] = "rbxassetid://271042556",
			["SkyboxLf"] = "rbxassetid://271042310",
			["SkyboxRt"] = "rbxassetid://271042467",
			["SkyboxUp"] = "rbxassetid://271077958"
		},
		["Morning Glow"] = {
			["SkyboxBk"] = "rbxassetid://1417494030",
			["SkyboxDn"] = "rbxassetid://1417494146",
			["SkyboxFt"] = "rbxassetid://1417494253",
			["SkyboxLf"] = "rbxassetid://1417494402",
			["SkyboxRt"] = "rbxassetid://1417494499",
			["SkyboxUp"] = "rbxassetid://1417494643"
		},
		["Setting Sun"] = {
			["SkyboxBk"] = "rbxassetid://626460377",
			["SkyboxDn"] = "rbxassetid://626460216",
			["SkyboxFt"] = "rbxassetid://626460513",
			["SkyboxLf"] = "rbxassetid://626473032",
			["SkyboxRt"] = "rbxassetid://626458639",
			["SkyboxUp"] = "rbxassetid://626460625"
		},
		['Cache'] = {
			['SkyboxBk'] = 'rbxassetid://220513302';
			['SkyboxDn'] = 'rbxassetid://213221473';
			['SkyboxFt'] = 'rbxassetid://220513328';
			['SkyboxLf'] = 'rbxassetid://220513318';
			['SkyboxRt'] = 'rbxassetid://220513279';
			['SkyboxUp'] = 'rbxassetid://220513345';
		},
		["Fade Blue"] = {
			["SkyboxBk"] = "rbxassetid://153695414",
			["SkyboxDn"] = "rbxassetid://153695352",
			["SkyboxFt"] = "rbxassetid://153695452",
			["SkyboxLf"] = "rbxassetid://153695320",
			["SkyboxRt"] = "rbxassetid://153695383",
			["SkyboxUp"] = "rbxassetid://153695471"
		},
		["Elegant Morning"] = {
			["SkyboxBk"] = "rbxassetid://153767241",
			["SkyboxDn"] = "rbxassetid://153767216",
			["SkyboxFt"] = "rbxassetid://153767266",
			["SkyboxLf"] = "rbxassetid://153767200",
			["SkyboxRt"] = "rbxassetid://153767231",
			["SkyboxUp"] = "rbxassetid://153767288"
		},
		["Neptune"] = {
			["SkyboxBk"] = "rbxassetid://218955819",
			["SkyboxDn"] = "rbxassetid://218953419",
			["SkyboxFt"] = "rbxassetid://218954524",
			["SkyboxLf"] = "rbxassetid://218958493",
			["SkyboxRt"] = "rbxassetid://218957134",
			["SkyboxUp"] = "rbxassetid://218950090"
		},
		["Redshift"] = {
			["SkyboxBk"] = "rbxassetid://401664839",
			["SkyboxDn"] = "rbxassetid://401664862",
			["SkyboxFt"] = "rbxassetid://401664960",
			["SkyboxLf"] = "rbxassetid://401664881",
			["SkyboxRt"] = "rbxassetid://401664901",
			["SkyboxUp"] = "rbxassetid://401664936"
		},
		["Aesthetic Night"] = {
			["SkyboxBk"] = "rbxassetid://1045964490",
			["SkyboxDn"] = "rbxassetid://1045964368",
			["SkyboxFt"] = "rbxassetid://1045964655",
			["SkyboxLf"] = "rbxassetid://1045964655",
			["SkyboxRt"] = "rbxassetid://1045964655",
			["SkyboxUp"] = "rbxassetid://1045962969"
		}
	},

    Textures = {
		["Groove"] = "rbxassetid://10785404176",
		["Cloud"] = "rbxassetid://5176277457",
		["Sky"] = "rbxassetid://1494603972",
		["Smudge"] = "rbxassetid://6096634060",
		["Scrapes"] = "rbxassetid://6248583558",
		["Galaxy"] = "rbxassetid://1120738433",
		["Stars"] = "rbxassetid://598201818",
		["Rainbow"] = "rbxassetid://10037165803"
	},

    PartMaterials = {
        "Plastic", "Wood", "Slate",
        "Concrete", "CorrodedMetal", "DiamondPlate",
        "Foil", "Grass", "Ice",
        "Marble", "Granite", "Brick",
        "Pebble", "Sand", "Fabric",
        "SmoothPlastic", "Metal", "WoodPlanks",
        "Cobblestone", "Neon", "Glass",
        "ForceField"
    },

    WorldAmbientsOriginal = nil,
    SkyboxOriginal = nil,
    ArmsOriginal = {},
    GunOriginal = {},

    NextRagebotShot = tick(),
    TargetWithinFOV = false,

    DrawList = {}
}

local Renderer = {}

function Renderer:FindExistingShape(name)
    local Shape = Storage.DrawList[name]
    if Shape then
        return Shape
    else
        return nil
    end
end

function Renderer:Unrender(name)
    local Shape = self:FindExistingShape(name)
    
    if Shape then
        Shape.Visible = false
        Shape:Remove()
        Storage.DrawList[name] = nil
    end
end

function Renderer:UnrenderAll(excludes)
    for Name, Shape in pairs(Storage.DrawList) do
        local shouldExclude = false
        
        for _, Exclude in ipairs(excludes) do
            if Exclude == Name then
                shouldExclude = true
                break
            end
        end
        
        if not shouldExclude then
            Shape.Visible = false
            Shape:Remove()
        end
    end

    for _, Exclude in ipairs(excludes) do
        local shapeToKeep = Storage.DrawList[Exclude]
        Storage.DrawList = {}
        if shapeToKeep then
            Storage.DrawList[Exclude] = shapeToKeep
        end
    end
end

function Renderer:Rectangle(name, position, size, color)
    local Shape = self:FindExistingShape(name)
    
    if Shape then
        Shape.Visible = true
        Shape.Position = position
        Shape.Size = size
        Shape.Color = color
        Shape.Transparency = 1
        Shape.Filled = false
    else
        Shape = Drawing.new("Square")
        Shape.Visible = true
        Shape.Position = position
        Shape.Size = size
        Shape.Color = color
        Shape.Transparency = 1
        Shape.Filled = false
        
        Storage.DrawList[name] = Shape
    end
    
    return Shape
end

function Renderer:FilledRectangle(name, position, size, color)
    local Shape = self:FindExistingShape(name)
    
    if Shape then
        Shape.Visible = true
        Shape.Position = position
        Shape.Size = size
        Shape.Color = color
        Shape.Transparency = 1
    else
        Shape = Drawing.new("Square")
        Shape.Visible = true
        Shape.Position = position
        Shape.Size = size
        Shape.Color = color
        Shape.Transparency = 1
        
        Storage.DrawList[name] = Shape
    end
    
    return Shape
end

function Renderer:Circle(name, position, radius, color)
    local Shape = self:FindExistingShape(name)
    
    if Shape then
        Shape.Visible = true
        Shape.Position = position
        Shape.Radius = radius
        Shape.Color = color
        Shape.Transparency = 1
        Shape.Filled = false
    else
        Shape = Drawing.new("Circle")
        Shape.Visible = true
        Shape.Position = position
        Shape.Radius = radius
        Shape.Color = color
        Shape.Transparency = 1
        Shape.Filled = false
        
        Storage.DrawList[name] = Shape
    end
    
    return Shape
end

function Renderer:FilledCircle(name, position, radius, color)
    local Shape = self:FindExistingShape(name)
    
    if Shape then
        Shape.Visible = true
        Shape.Position = position
        Shape.Radius = radius
        Shape.Color = color
        Shape.Transparency = 1
    else
        Shape = Drawing.new("Circle")
        Shape.Visible = true
        Shape.Position = position
        Shape.Radius = radius
        Shape.Color = color
        Shape.Transparency = 1
        
        Storage.DrawList[name] = Shape
    end
    
    return Shape
end

function Renderer:Line(name, from, to, color, thickness)
    local Shape = self:FindExistingShape(name)
    
    if Shape then
        Shape.Visible = true
        Shape.From = from
        Shape.To = to
        Shape.Color = color
        Shape.Thickness = thickness
        Shape.Transparency = 1
    else
        Shape = Drawing.new("Line")
        Shape.Visible = true
        Shape.From = from
        Shape.To = to
        Shape.Color = color
        Shape.Thickness = thickness
        Shape.Transparency = 1
        
        Storage.DrawList[name] = Shape
    end
    
    return Shape
end

function Renderer:Text(name, position, text, color, size, font)
    local Shape = self:FindExistingShape(name)
    
    if Shape then
        Shape.Visible = true
        Shape.Position = position
        Shape.Text = text
        Shape.Color = color
        Shape.Size = size
        Shape.Font = font
        Shape.Transparency = 1
    else
        Shape = Drawing.new("Text")
        Shape.Visible = true
        Shape.Position = position
        Shape.Text = text
        Shape.Color = color
        Shape.Size = size
        Shape.Font = font
        Shape.Transparency = 1
        
        Storage.DrawList[name] = Shape
    end
    
    return Shape
end

-- Active developers: @fuckuneedthisfor & @distinguished_1

-- Script Info:
-- Script date, Project created (6/13/2024 : 5:18 PM)
-- Script name: Redacted-project (placeholder)
-- Script description: Phantom Forces Rage/Legit cheat

-- Additional Info:
-- This project is a script for Phantom Forces, designed to enhance gameplay with both legit and rage features
-- Performance based project in both framerate and capability to keep up with competitors like MoonLight, Eclipse.lol, DeleteMob

-- MENU-BEGIN -----------------------------------------------------------------------------------------
local Window = Library:CreateWindow({
    Title = 'Redacted-project ( ' .. Redacted.Username .. (Redacted.Developer and ', beta )' or ' )'),
    Center = true, AutoShow = true, TabPadding = 15, MenuFadeTime = 0.2, Size = Vec2(550, 450)
})

local Tabs = {
    RagebotTab = Window:AddTab('Ragebot'),
    AntiaimTab = Window:AddTab('Anti-aim'),
    VisualsTab = Window:AddTab('Visuals'),
    MiscTab = Window:AddTab('Miscellaneous'),
    SettingsTab = Window:AddTab('Settings')
}

local Groups = {
    Ragebot = {
        General = Tabs.RagebotTab:AddLeftGroupbox('General'),
        Other = Tabs.RagebotTab:AddRightGroupbox('Other')
    },

    AntiAim = {
        General = Tabs.AntiaimTab:AddLeftGroupbox('General'),
        FakeLag = Tabs.AntiaimTab:AddRightGroupbox('FakeLag'),
        Other = Tabs.AntiaimTab:AddRightGroupbox('Other')
    },

    Visuals = {
        Players = Tabs.VisualsTab:AddLeftGroupbox('Players'),
        World = Tabs.VisualsTab:AddRightGroupbox('World'),

        Throwables = Tabs.VisualsTab:AddLeftGroupbox('Throwables'),
        Other = Tabs.VisualsTab:AddRightGroupbox('Other')
    },

    Misc = {
        Movement = Tabs.MiscTab:AddLeftGroupbox('Movement'),
        Other = Tabs.MiscTab:AddRightGroupbox('Other')
    },

    Settings = {
        Menu = Tabs.SettingsTab:AddLeftGroupbox(Redacted.Developer and 'Menu / Developer' or 'Menu')
        -- Another is added by the SaveManager 'Configuration' later on.
    }
}

-- MENU VARIABLES (RAGEBOT)
Groups.Ragebot.General:AddToggle('RagebotEnabled', {
    Text = 'Aimbot', Tooltip = nil,
    Default = false,

    Callback = function(Value)
        Config.Ragebot.General.Enabled = Value
    end
})

Groups.Ragebot.General:AddSlider('RagebotFieldOfView', {
    Text = 'Field of view', Tooltip = 'Maximum angle the aimbot is allowed for activation',

    Default = 180, Min = 0, Max = 180, Rounding = 1,
    Compact = false,

    Callback = function(Value)
        Config.Ragebot.General.FieldOfView = Value
    end
})

Groups.Ragebot.General:AddDropdown('RagebotTargetSelection', {
    Text = 'Target selection', Tooltip = nil,

    Values = {'Crosshair', 'Distance'},
    Multi = false,
    Default = 1,

    Callback = function(Value)
        Config.Ragebot.General.TargetSelection = Value
    end
})

Groups.Ragebot.General:AddToggle('RagebotAutoShoot', {
    Text = 'Auto shoot', Tooltip = nil,
    Default = false,

    Callback = function(Value)
        Config.Ragebot.General.AutoFire = Value
    end
})

Groups.Ragebot.General:AddDropdown('RagebotHitboxes', {
    Text = 'Hitboxes', Tooltip = 'Which hitboxes the aimbot will target',

    Values = {'Head', 'Torso', 'LeftArm', 'RightArm', 'LeftLeg', 'RightLeg'},
    Multi = true,
    Default = 0,

    Callback = function(Value)
        Config.Ragebot.General.Hitboxes = Value
    end
})

-- MENU VARIABLES (ANTIAIM)
Groups.AntiAim.General:AddToggle('AntiAimEnabled', {
    Text = 'Enabled',
    Tooltip = nil,

    Default = false,

    Callback = function(Value)
        Config.AntiAim.General.Enabled = Value
    end
})

-- MENU VARIABLES (ESP)
Groups.Visuals.Players:AddToggle('Boxes', {
    Text = 'Boxes', Tooltip = nil,

    Default = false,

    Callback = function(Value)
        Config.Visuals.Players.Boxes.Enabled = Value
    end
}):AddColorPicker('BoxesColor', {
    Title = 'Boxes color',
    
    Default = ColorRGB(255, 255, 255),
    Transparency = 0,

    Callback = function(Value)
        Config.Visuals.Players.Boxes.Color = Value
    end
})

Groups.Visuals.Players:AddToggle('Chams', {
    Text = 'Chams', Tooltip = nil,
    Default = false,

    Callback = function(Value)
        Config.Visuals.Players.Chams.Enabled = Value
    end
}):AddColorPicker('ChamsOutlineColor', {
    Title = 'Outline color',

    Default = Redacted.Accent,
    Transparency = 0,

    Callback = function(Value)
        Config.Visuals.Players.Chams.OutlineColor = Value
    end
}):AddColorPicker('ChamsFillColor', {
    Title = 'Fill color',

    Default = ColorRGB(0, 0, 0),
    Transparency = 0,

    Callback = function(Value)
        Config.Visuals.Players.Chams.FillColor = Value
    end
})

Groups.Visuals.Players:AddToggle('WeaponChams', {
    Text = 'Weapon chams', Tooltip = nil,
    Default = false,

    Callback = function(Value)
        Config.Visuals.Players.WeaponChams.Enabled = Value
    end
}):AddColorPicker('WeaponChamsColor', {
    Title = 'Color',

    Default = Redacted.Accent,
    Transparency = 0,

    Callback = function(Value)
        Config.Visuals.Players.WeaponChams.Color = Value
    end
})

Groups.Visuals.Players:AddDropdown('WeaponChamsMaterial', {
    Text = 'Weapon material', Tooltip = nil,

    Values = Storage.PartMaterials,
    Multi = false,
    Default = 22,

    Callback = function(Value)
        Config.Visuals.Players.WeaponChams.Material = Value
    end
})

Groups.Visuals.Players:AddToggle('ArmChams', {
    Text = 'Arm chams',
    Tooltip = nil,

    Default = false,

    Callback = function(Value)
        Config.Visuals.Players.ArmChams.Enabled = Value
    end
}):AddColorPicker('ArmChamsColor', {
    Title = 'Color',
    Transparency = 0,

    Default = Redacted.Accent,
    
    Callback = function(Value)
        Config.Visuals.Players.ArmChams.Color = Value
    end
})

Groups.Visuals.Players:AddDropdown('ArmChamsMaterial', {
    Text = 'Arms material',
    Tooltip = nil,

    Values = Storage.PartMaterials,
    Multi = false,
    Default = 22, -- ForceField

    Callback = function(Value)
        Config.Visuals.Players.ArmChams.Material = Value
    end
})

Groups.Visuals.World:AddToggle('AmbientLighting', {
    Text = 'Ambient lighting', Tooltip = nil,
    Default = false,

    Callback = function(Value)
        Config.Visuals.World.OverrideAmbient.Enabled = Value
    end
}):AddColorPicker('AmbientLightingColor', {
    Title = 'Override ambient',

    Default = Redacted.Accent,
    Transparency = 0,

    Callback = function(Value)
        Config.Visuals.World.OverrideAmbient.Color = Value
    end
})

Groups.Visuals.World:AddToggle('SkyboxChanger', {
    Text = 'Skybox changer', Tooltip = nil,
    Default = false,

    Callback = function(Value)
        Config.Visuals.World.SkyboxChanger.Enabled = Value
    end
})

local SkyboxNames = {}
for name, _ in pairs(Storage.Skyboxes) do
    table.insert(SkyboxNames, name)
end

Groups.Visuals.World:AddDropdown('SkyboxChangerTexture', {
    Text = 'Texture', Tooltip = nil,

    Values = SkyboxNames,
    Multi = false,
    Default = 1, -- Nebula

    Callback = function(Value)
        Config.Visuals.World.SkyboxChanger.Value = Value
    end
})

Groups.Visuals.Other:AddToggle('Crosshair', {
    Text = 'Crosshair', Tooltip = nil,
    
    Default = false,
    
    Callback = function(Value)
        Config.Visuals.Other.Crosshair.Enabled = Value
    end
}):AddColorPicker('CrosshairColor', {
    Title = 'Crosshair color',

    Default = ColorRGB(255, 255, 255),
    Transparency = 0,

    Callback = function(Value)
        Config.Visuals.Other.Crosshair.Color = Value
    end
})

Groups.Visuals.Other:AddToggle('VisualizeFOV', {
    Text = 'Visualise fov', Tooltip = nil,
    
    Default = false,
    
    Callback = function(Value)
        Config.Visuals.Other.VisualizeFOV.Enabled = Value
    end
}):AddColorPicker('FovInactiveColor', {
    Title = 'Active color',

    Default = ColorRGB(255, 255, 255),
    Transparency = 0,

    Callback = function(Value)
        Config.Visuals.Other.VisualizeFOV.ActiveColor = Value
    end
}):AddColorPicker('FovActiveColor', {
    Title = 'Inactive color',

    Default = Redacted.Accent,
    Transparency = 0,

    Callback = function(Value)
        Config.Visuals.Other.VisualizeFOV.InactiveColor = Value
    end
})

-- MENU VARIABLES (MISCELLANEOUS)
Groups.Misc.Movement:AddToggle('Bhop', {
    Text = 'Bhop', Tooltip = nil,
    Default = false,

    Callback = function(Value)
        Config.Misc.Movement.Bhop = Value
    end
})

Groups.Misc.Movement:AddToggle('FlyHack', {
    Text = 'Flyhack', Tooltip = nil,
    Default = false,

    Callback = function(Value)
        Config.Misc.Movement.FlyHack.Enabled = Value
    end
})
Groups.Misc.Movement:AddSlider('FlyHackValue', {
    Text = 'Flyhack speed', Tooltip = nil,

    Default = 50,  Min = 0,  Max = 100, Rounding = 1,
    Compact = false,

    Callback = function(Value)
        Config.Misc.Movement.FlyHack.Value = Value
    end
})

Groups.Misc.Movement:AddToggle('SpeedHack', {
    Text = 'Speedhack', Tooltip = nil,
    Default = false,

    Callback = function(Value)
        Config.Misc.Movement.SpeedHack.Enabled = Value
    end
})
Groups.Misc.Movement:AddSlider('SpeedHackValue', {
    Text = 'Speedhack speed', Tooltip = nil,

    Default = 50,  Min = 0,  Max = 100, Rounding = 1,
    Compact = false,

    Callback = function(Value)
        Config.Misc.Movement.SpeedHack.Value = Value
    end
})

Groups.Misc.Other:AddToggle('Invisibility', {
    Text = 'Invisibility (server-side)', Tooltip = nil,
    Default = false,

    Callback = function(Value)
        Config.Misc.Other.Invisibility = Value
    end
})

Groups.Misc.Other:AddSlider('HipHeightValue', {
    Text = 'Hip height', Tooltip = nil,

    Default = 0,  Min = 0,  Max = 100, Rounding = 1,
    Compact = false,

    Callback = function(Value)
        Config.Misc.Other.HipHeight = Value
    end
})

if Redacted.Developer then
    Groups.Settings.Menu:AddButton('Load DarkDex', function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
    end)
end

-- Skip Misc->Configuration, Handled at EOF because of unload function.
-- Now lets get into the juicy part of this code mf, 1/2 of this was written while in a zaza induced coma, AND RN AHHH

local PhantomForces = {}

function PhantomForces:GetArms()
    if not (Camera and Camera:IsA("Camera")) then
        return nil
    end

    local LeftArm = Camera:FindFirstChild("Left Arm")
    local RightArm = Camera:FindFirstChild("Right Arm")

    if LeftArm and RightArm then
        return {LeftArm, RightArm}
    else
        return nil
    end
end

function PhantomForces:GetGun()
    if not (Camera and Camera:IsA("Camera")) then
        return nil
    end

    local GunModel = nil

    for i, Viewmodel in ipairs(Camera:GetChildren()) do
        if Viewmodel:IsA("Model") and not Viewmodel.Name:match("Arm") then
            GunModel = Viewmodel
            break
        end
    end
    
    return GunModel
end

-- Returns the tip of the muzzle for our weapon, used for silent aimbot & autowall
function PhantomForces:GetMuzzleParts(Gun)
    local Muzzle = {}

    for _, Part in pairs(Gun:GetChildren()) do
        if Part.Name == 'Flame' or Part.Name == 'SightMark' or Part.Name == 'FlameSUP' then
            table.insert(Muzzle, Part)
        end
    end

    return Muzzle
end

function PhantomForces:GetPlayerModels()
    local PlayerList = {}

    for i,Teams in Workspace.Players:GetChildren() do
        for i, Players in Teams:GetChildren() do
            table.insert(PlayerList, Players)
        end
    end

    return PlayerList
end

-- Please fucking redo this wtf? Checking for Helmet colors. All parts of Worspace.Players is str encrypted by pf faggy devs, go kys @litozinnamon & @Shay.
function PhantomForces:GetPlayerTeam(Player)
    local Helmet = Player:FindFirstChildWhichIsA("Folder"):FindFirstChildOfClass("MeshPart")
    
    if Helmet then
        if Helmet.BrickColor == BrickColor.new("Black") then
            return game.Teams.Phantoms
        else
            return game.Teams.Ghosts
        end
    end
end

function PhantomForces:FindPartBySize(Target, Size)
    for _, Child in ipairs(Target:GetChildren()) do
        if Child:IsA("BasePart") and Child.Size == Size then
            return Child
        end
    end

    return nil
end

-- Move 'CheckConfig' to Ragebot, ts dumb but also helps with not getting unnecessary parts in turn increasing performance.
function PhantomForces:GetPlayerParts(Target, CheckConfig)
    local Hitboxes = {}

    -- make it just read from storage.hitboxes or sum
    local IterationList = {'Head', 'Torso', 'LeftArm', 'RightArm', 'LeftLeg', 'RightLeg'}

    for _, v in pairs(IterationList) do
        if not CheckConfig or Config.Ragebot.General.Hitboxes[v] then
            local Part = PhantomForces:FindPartBySize(Target, Storage.BodySizes[v])

            if Part and Part:IsA("BasePart") then
                Hitboxes[v] = Part
            end
        end
    end

    return Hitboxes
end

function PhantomForces:IsAlive()
	return Workspace.Ignore:FindFirstChild("RefPlayer")
end

-- MISC
local Misc = {}

function Misc:Run()
    if not PhantomForces:IsAlive() then
        return
    end

    local PlayerModel = Workspace.Ignore:FindFirstChild("RefPlayer")

    if not PlayerModel then
        return
    end

    local Humanoid = PlayerModel:FindFirstChildOfClass("Humanoid")
    local RootPart = PlayerModel:FindFirstChild("HumanoidRootPart")

    if Config.Misc.Movement.FlyHack.Enabled then
        local LookVector = Camera.CFrame.LookVector
        local Direction = Vec3()

        local Directions = {
            [Enum.KeyCode.W] = LookVector,
            [Enum.KeyCode.A] = Vec3(LookVector.Z, 0, -LookVector.X),
            [Enum.KeyCode.S] = -LookVector,
            [Enum.KeyCode.D] = Vec3(-LookVector.Z, 0, LookVector.X),
            [Enum.KeyCode.LeftControl] = Vec3(0, -5, 0),
            [Enum.KeyCode.LeftShift] = Vec3(0, -5, 0),
            [Enum.KeyCode.Space] = Vec3(0, 5, 0)
        }

        for Key, Dir in pairs(Directions) do
            if UserInputService:IsKeyDown(Key) then
                Direction = Direction + Dir
            end
        end

        if Direction.Magnitude > 0 then
            RootPart.Velocity = Direction.Unit * Config.Misc.Movement.FlyHack.Value
            RootPart.Anchored = false
        else
            RootPart.Velocity = Vec3()
            RootPart.Anchored = true
        end
    end

    if PlayerModel ~= nil and Config.Misc.Movement.SpeedHack.Enabled and not Config.Misc.Movement.FlyHack.Enabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        local LookVector = Camera.CFrame.LookVector
        local Direction = Vec3()

        local Directions = {
            [Enum.KeyCode.W] = Vec3(LookVector.X, 0, LookVector.Z),
            [Enum.KeyCode.A] = Vec3(LookVector.Z, 0, -LookVector.X),
            [Enum.KeyCode.S] = -Vec3(LookVector.X, 0, LookVector.Z),
            [Enum.KeyCode.D] = Vec3(-LookVector.Z, 0, LookVector.X)
        }

        for Key, Dir in pairs(Directions) do
            if UserInputService:IsKeyDown(Key) then
                Direction = Direction + Dir
            end
        end

        if Direction.Magnitude > 0 then
            RootPart.Velocity = Direction.Unit * Config.Misc.Movement.SpeedHack.Value + Vec3(0, RootPart.Velocity.Y, 0)
        end
    end

    if Config.Misc.Movement.Bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
        Humanoid.Jump = true
    end

    Humanoid.HipHeight = Config.Misc.Other.HipHeight
end

-- VISUALS
local Visuals = {}

function Visuals:Run()
    local PlayerModels = PhantomForces:GetPlayerModels()

    if Config.Visuals.Players.Boxes.Enabled and PlayerModels then
        Renderer:UnrenderAll({'FOVCircle'})

        for _, Player in pairs(PlayerModels) do
            if not Player:FindFirstChild("Dead") then
                local PlayerParts = PhantomForces:GetPlayerParts(Player, false)
                
                if PlayerParts then
                    local Torso = PlayerParts['Torso']

                    local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Torso.Position)
    
                    if OnScreen and tostring(PhantomForces:GetPlayerTeam(Player)) ~= Players.LocalPlayer.Team.Name then
                        local Scale = 1000 / (Camera.CFrame.Position - Torso.Position).Magnitude * 80 / Camera.FieldOfView
                        
                        local BoundingBox, Size = Player:GetBoundingBox()

                        Renderer:Rectangle(
                            Player.Name .. "_Box",
                            ScreenPosition - (Size * (Scale / 2)),
                            Size * Scale,
                            Config.Visuals.Players.Boxes.Color
                        )
                    end
                end
            end
        end
    else
        Renderer:UnrenderAll({'FOVCircle'})
    end

    if Config.Visuals.Other.Crosshair.Enabled then
        Renderer:Line(
            "CrosshairVertical",
            Vec2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2 - 10),
            Vec2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2 + 10),
            Config.Visuals.Other.Crosshair.Color,
            2
        )
        Renderer:Line(
            "CrosshairHorizontal",
            Vec2(Camera.ViewportSize.X / 2 - 10, Camera.ViewportSize.Y / 2),
            Vec2(Camera.ViewportSize.X / 2 + 10, Camera.ViewportSize.Y / 2),
            Config.Visuals.Other.Crosshair.Color,
            2
        )
    else
        Renderer:Unrender("CrosshairVertical")
        Renderer:Unrender("CrosshairHorizontal")
    end

    if Config.Visuals.Other.VisualizeFOV.Enabled then
        local MousePosition = UserInputService:GetMouseLocation()

        Renderer:FilledCircle("FOVCircle",
            Vec2(MousePosition.X, MousePosition.Y), Config.Ragebot.General.FieldOfView,
            (Storage.TargetWithinFOV and Config.Visuals.Other.VisualizeFOV.ActiveColor or Config.Visuals.Other.VisualizeFOV.InactiveColor)
        )
    else
        Renderer:Unrender("FOVCircle")
    end

    if Config.Visuals.World.OverrideAmbient.Enabled and Lighting then
        if not Storage.WorldAmbientsOriginal then
            Storage.WorldAmbientsOriginal = {
                ['Ambient'] = Lighting['Ambient'],
                ['OutdoorAmbient'] = Lighting["OutdoorAmbient"],
                ['ColorShift_Top'] = Lighting["ColorShift_Top"],
                ['ColorShift_Bottom'] = Lighting["ColorShift_Bottom"]
            }
        end

        Lighting["Ambient"]           = Config.Visuals.World.OverrideAmbient.Color
        Lighting["OutdoorAmbient"]    = Config.Visuals.World.OverrideAmbient.Color
        Lighting["ColorShift_Top"]    = Config.Visuals.World.OverrideAmbient.Color
        Lighting["ColorShift_Bottom"] = Config.Visuals.World.OverrideAmbient.Color

    elseif Storage.WorldAmbientsOriginal then
        for name, v in pairs(Storage.WorldAmbientsOriginal) do
            Lighting[name] = v
        end
    end

    local Sky = Lighting:FindFirstChildOfClass("Sky")

    if Config.Visuals.World.SkyboxChanger.Enabled and Sky then
        if not Storage.SkyboxOriginal then
            Storage.SkyboxOriginal = Sky
        end

        for _, v in pairs(Storage.Skyboxes[Config.Visuals.World.SkyboxChanger.Value]) do
            if Sky[_] ~= v then
                Sky[_] = v
            end
        end
    elseif Storage.SkyboxOriginal then
        Sky = Storage.SkyboxOriginal
    end
end

-- CHAMS
local Chams = {}

function Chams:CreateBackup(Model, PartType)
    local Backup = {}

    for _, Part in ipairs(Model:GetChildren()) do
        if Part:IsA(PartType) then
            Backup[Part.Name] = {
                Transparency = Part.Transparency,
                Material = Part.Material,
                Color = Part.Color
            }
        end
    end
    
    return Backup
end

function Chams:RestoreChams(Model, Original)
    if not Model or not Original then
        return
    end

    for _, Part in ipairs(Model:GetChildren()) do
        local OriginalPart = Original[Part.Name]

        if OriginalPart then
            Part.Transparency = OriginalPart.Transparency
            Part.Material = OriginalPart.Material
            Part.Color = OriginalPart.Color
        end
    end
end

function Chams:ApplyChams(Model, ExcludeParts, DestroyParts, Material, Color)
    if not Model then
        return
    end

    for _, Part in ipairs(Model:GetChildren()) do
        if table.find(DestroyParts, Part.Name) then
            Part:Destroy()
        elseif not table.find(ExcludeParts, Part.Name) and Part:IsA("BasePart") then
            if Part.Transparency < 1 then
                Part.Transparency = 0
            end
            Part.Material = Material
            Part.Color = Color
        end
    end
end

function Chams:Run()
    local PlayerModels, Arms, Gun = PhantomForces:GetPlayerModels(), PhantomForces:GetArms(), PhantomForces:GetGun()

    if PlayerModels and #PlayerModels > 0 then
        for i, Player in PlayerModels do
            if Player then
                -- CHAMS
                local Highlight = Player:FindFirstChildOfClass("Highlight")

                -- LONGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG LINESSSSSSSSSSSSSSSSSSSSSSSS no, change lol, too high rn.
                if Config.Visuals.Players.Chams.Enabled and not tostring(Player:GetFullName()):find(tostring(Workspace.Ignore.DeadBody)) and tostring(PhantomForces:GetPlayerTeam(Player)) ~= Players.LocalPlayer.Team.Name then
                    if not Highlight then
                        Highlight = Instance.new("Highlight", Player)
                    end

                    Highlight.Enabled = true
                    Highlight.Adornee = Player
                    Highlight.FillColor = Config.Visuals.Players.Chams.FillColor
                    Highlight.OutlineColor = Config.Visuals.Players.Chams.OutlineColor
                    
                    Highlight.FillTransparency = nil
                    Highlight.OutlineTransparency = nil
                    Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                elseif not Config.Visuals.Players.Chams.Enabled and Highlight then
                    Highlight:Destroy()
                end
            end
        end
    end

    if Gun then
        if Config.Visuals.Players.WeaponChams.Enabled then
            if not Storage.GunOriginal[Gun.Name] then
                Storage.GunOriginal[Gun.Name] = Chams:CreateBackup(Gun, 'BasePart')
            end

            Chams:ApplyChams(
                Gun, {'Lens', 'SightMark'}, {'Texture'},
                Config.Visuals.Players.WeaponChams.Material,
                Config.Visuals.Players.WeaponChams.Color
            )
        elseif Storage.GunOriginal[Gun.Name] then
            Chams:RestoreChams(Gun, Storage.GunOriginal[Gun.Name])
            Storage.GunOriginal[Gun.Name] = nil
        end
    end 
    
    if Arms then
        if Config.Visuals.Players.ArmChams.Enabled then
            for _, Arm in ipairs(Arms) do
                if not Storage.ArmsOriginal[Arm.Name] then
                    Storage.ArmsOriginal[Arm.Name] = Chams:CreateBackup(Arm, 'MeshPart')
                end
    
                Chams:ApplyChams(
                    Arm, {}, {'Sleeves'},
                    Config.Visuals.Players.ArmChams.Material,
                    Config.Visuals.Players.ArmChams.Color
                )
            end
        else
            for _, Arm in ipairs(Arms) do
                if Storage.ArmsOriginal[Arm.Name] then
                    Chams:RestoreChams(Arm, Storage.ArmsOriginal[Arm.Name])
                    Storage.ArmsOriginal[Arm.Name] = nil
                end
            end
        end
    end
end

local Antiaim = {}

-- ANTIAIM
function Antiaim:Run()
    
end

local Autowall = {}

-- This will be removed in turn for actual AW, Waiting on a higher level executor.
function Autowall:PlayerVisible(Player, Origin, End)
    local Params = RaycastParams.new()

    Params.FilterDescendantsInstances = {Player:FindFirstChildOfClass("Folder"), Workspace.Ignore, Camera}
    Params.FilterType = Enum.RaycastFilterType.Exclude
    Params.IgnoreWater = true

    local CastRay = workspace:Raycast(Origin, End - Origin, Params)

    if CastRay and CastRay.Instance and CastRay.Instance:IsDescendantOf(Player) then
        return true
    end

    return false
end

function Autowall:CalculatePenetration(Target, Gun)
    local WeaponName = string.gsub(string.gsub(tostring(Gun.Name), "Main", ""), " ", "")
    local WeaponPenetratrion = Storage.PenetrationDepth[WeaponName]

    -- Fix for Knife, Grenades, Etc
    if not WeaponPenetratrion then
        WeaponPenetratrion = 0
    end

    local Ignore = {Camera, Workspace.Ignore}

    for _, Part in pairs(PhantomForces:GetMuzzleParts(Gun)) do
        local Direction = Target.Position - Part.Position
        
        local RayCastIgnore = Workspace:FindPartOnRayWithIgnoreList(
            Ray.new(Part.Position, Direction),
            Ignore, false, true
        )

        if not RayCastIgnore then
            return true
        end

        local Penetrated = 0

        for _, ObscuredPart in pairs(Camera:GetPartsObscuringTarget({Target.Position}, Ignore)) do
            if ObscuredPart.CanCollide and ObscuredPart.Transparency ~= 1 and ObscuredPart.Name ~= "Window" then
                local MaxRayLength = ObscuredPart.Size.Magnitude * Direction.Unit
                
                local _, Enter = game.Workspace:FindPartOnRayWithWhitelist(Ray.new(Part.Position, Direction), {ObscuredPart}, true)
                local _, Exit = game.Workspace:FindPartOnRayWithWhitelist(Ray.new(Enter + MaxRayLength, -MaxRayLength), {ObscuredPart}, true)
                
                local Depth = (Exit - Enter).Magnitude;
                
                if Depth > WeaponPenetratrion then
					Penetrated = Penetrated + Depth
                end
            else
                table.insert(Ignore, ObscuredPart)
            end
        end

        if Penetrated < WeaponPenetratrion then
            Storage.TargetWithinFOV = true
            return true
        end
    end
end

-- RAGEBOT
local Ragebot = {}

-- This is more of a utility than a ragebot specific feature, might wanna move it elsewhere for convience
function Ragebot:AimWeaponAt(Gun, HitboxPosition)
    for i, Part in ipairs(Gun:GetChildren()) do
        local Joints = Part:GetJoints()

        if Joints ~= nil then
            if Part.Name:find("SightMark") or Part.Name:find("FlameSUP") or Part.Name:find("Flame") then
                Joints[1].C0 = Joints[1].Part0.CFrame:ToObjectSpace(CFrame.lookAt(Joints[1].Part1.Position, HitboxPosition))
            end
        end
    end
end

function Ragebot:SetMuzzlePosition(Gun, HitboxPosition)
    for i, Part in ipairs(Gun:GetChildren()) do
        local Joints = Part:GetJoints()

        if Joints ~= nil then
            if Part.Name:find("SightMark") or Part.Name:find("FlameSUP") or Part.Name:find("Flame") then
                Joints[1].C0 = Joints[1].Part0.CFrame:ToObjectSpace(CFrame.lookAt(HitboxPosition - Vector3.new(0, 0, 1)), HitboxPosition)
            end
        end
    end
end

function Ragebot:GetTarget(Targets, Gun)
    local MinDistance, MinCrosshairDistance = math.huge, math.huge
    local BestTarget = {}

    for i, Target in ipairs(Targets) do
        if Target ~= nil and tostring(PhantomForces:GetPlayerTeam(Target)) ~= Players.LocalPlayer.Team.Name then
            local Parts = PhantomForces:GetPlayerParts(Target, true)

            if not Parts then 
                continue
            end

            for _, Part in pairs(Parts) do
                local Direction = (Part.Position - Camera.CFrame.Position).Unit
                local DotProduct = Camera.CFrame.LookVector:Dot(Direction)
                local Angle = math.deg(math.acos(DotProduct))

                -- Ts might be brokez a lil bit lol
                if Angle <= Config.Ragebot.General.FieldOfView then
                    if Config.Ragebot.General.AutoWall and not Autowall:CalculatePenetration(Part, Gun) then
                        continue
                    else
                        if not Autowall:PlayerVisible(Target, Camera.CFrame.Position, Part.Position) then
                            continue
                        end
                    end
                    
                    -- OPTIONS: 'Crosshair', 'Distance', 'Health', 'Damage'
                    -- Target selection: Very unattractive code I know, I will fix it.
                    
                    local TargetSelectionConfig = Config.Ragebot.General.TargetSelection

                    -- Add more in the future, Health & Damage.
                    if TargetSelectionConfig == 'Crosshair' then
                        local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                        local CrosshairDistance = (Vec2(ScreenPos.X, ScreenPos.Y) - UserInputService:GetMouseLocation()).Magnitude

                        if CrosshairDistance > MinCrosshairDistance then
                            continue
                        end

                        MinCrosshairDistance = CrosshairDistance
                    elseif TargetSelectionConfig == 'Distance' then
                        local Distance = (Part.Position - Camera.CFrame.Position).Magnitude

                        if Distance >= MinDistance then
                            continue
                        end

                        MinDistance = Distance
                    end

                    -- Update our target information, found a more optimal target
                    BestTarget = {
                        AimPoint = Part.Position,
                        Target = Target
                    }
                end
            end
        end
    end

    return BestTarget
end

-- IDGAF SUCK MY DICK IM NOT MAKING THIS LOOK CLEAN NOR DO I FUCKING CARE :)
local GhettoAutofire = false

task.spawn(function()
    while task.wait() do
        if Config.Ragebot.General.Enabled and PhantomForces:IsAlive() and GhettoAutofire then
            local ClickPosition = Vec2(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

            VirtualInputManager:SendMouseButtonEvent(ClickPosition.X, ClickPosition.Y, 0, true, game, 0)
            task.wait(0.06) -- 2x default task.wait speed (i think lmao, this so fucking stupid)
            VirtualInputManager:SendMouseButtonEvent(ClickPosition.X, ClickPosition.Y, 0, false, game, 0)
        end
    end
end)

function Ragebot:Run()
    Storage.TargetWithinFOV = false
    GhettoAutofire = false

    if not Config.Ragebot.General.Enabled or not PhantomForces:IsAlive() then
        return
    end

    local PlayerModels, Gun = PhantomForces:GetPlayerModels(), PhantomForces:GetGun()

    if not Storage.ArePacketsChoked and PlayerModels ~= nil and Gun ~= nil --[[and tick() > Storage.NextRagebotShot]] then
        local Target = Ragebot:GetTarget(PlayerModels, Gun)
        
        if next(Target) ~= nil then
            -- Ima tweak tf out fii  i HAVCE TO USE THIS ANYMORE omfg, QUI U A BITCH ADD HOOKS TO SOLARA
            Ragebot:AimWeaponAt( Gun, Target.AimPoint )

            if Config.Ragebot.General.AutoFire then
                GhettoAutofire = true
            end
        end

        -- Lock aimbot logic and prevent from running until we can fire another round again.
        --[[local FireRate = GetModuleIDFKHEHEHEHAHAHA():getWeaponStat("firerate")
        Storage.NextRagebotShot = tick() + (60 / FireRate)]]
    end
end

-- Me no wrike wtf is ts lmao, just gonna do dis for now cuz solara shit.
task.spawn(function()
    while task.wait() do
        Ragebot:Run()
        --Antiaim:Run() -- Irdgaf abt ts rn no scripts are even good enough for needing this rn.
        Visuals:Run()
        Chams:Run()
        Misc:Run()

        if Library.Unloaded then
            break
        end
    end
end)

Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local MousePosition = UserInputService:GetMouseLocation()

    Renderer:FindExistingShape("FOVCircle").Position = Vec2(MousePosition.X, MousePosition.Y)
end)

Lighting:GetPropertyChangedSignal("Ambient"):Connect(function()
    if Config.Visuals.World.OverrideAmbient.Enabled then
        Lighting["Ambient"] = Config.Visuals.World.OverrideAmbient.Color
    end
end)

Lighting:GetPropertyChangedSignal("OutdoorAmbient"):Connect(function()
    if Config.Visuals.World.OverrideAmbient.Enabled then
        Lighting["OutdoorAmbient"] = Config.Visuals.World.OverrideAmbient.Color
    end
end)

Lighting:GetPropertyChangedSignal("ColorShift_Top"):Connect(function()
    if Config.Visuals.World.OverrideAmbient.Enabled then
        Lighting["ColorShift_Top"] = Config.Visuals.World.OverrideAmbient.Color
    end
end)

Lighting:GetPropertyChangedSignal("ColorShift_Bottom"):Connect(function()
    if Config.Visuals.World.OverrideAmbient.Enabled then
        Lighting["ColorShift_Bottom"] = Config.Visuals.World.OverrideAmbient.Color
    end
end)

Groups.Settings.Menu:AddButton('Unload', function()
    -- Removed for now, I couldnt care enough cuz 1/2 the time you need to relauch anyways.
    -- Add back before public/private release, we havent decided either yet also.
end)

-- Load UI Library save manager / config manager
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

SaveManager:SetFolder('RedactedProject')

SaveManager:BuildConfigSection(Tabs.SettingsTab)

SaveManager:LoadAutoloadConfig()
