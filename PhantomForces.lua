if game.PlaceId == 5938036553 then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdwinS7/RedactedProjectPF/main/Frontlines.lua"))()
    return
end

-- Developers only, extra debugging options.
local OverrideUserSettings = true

-- Active developers: @fuckuneedthisfor

-- Script Info:
-- Script date, Project created (6/13/2024 : 5:18 PM)
-- Script name: Redacted-project (placeholder)
-- Script description: Phantom Forces Rage/Legit cheat

-- Removed PlaceID Check due to Celery breaking with it, I don't even know...

-- Script settings
local Redacted = {
    Username = OverrideUserSettings and "admin" or "user1",
    Build = OverrideUserSettings and 'developer' or 'live',

    Accent = Color3.fromRGB(140, 130, 255)
}

-- Override Drawing Library so celery works (Using Solara's library) I should probably add a executor check but haha IDGAF YALL ALL USE THIS ANYWAYS (i think, except electron)
loadstring(game:HttpGet("https://raw.githubusercontent.com/EdwinS7/SolaraLua/main/Drawing.lua"))()

-- UI Library
    local InputService = game:GetService('UserInputService');
    local TextService = game:GetService('TextService');
    local CoreGui = game:GetService('CoreGui');
    local Teams = game:GetService('Teams');
    local Players = game:GetService('Players');
    local RunService = game:GetService('RunService')
    local TweenService = game:GetService('TweenService');
    local RenderStepped = RunService.RenderStepped;
    local LocalPlayer = Players.LocalPlayer;
    local Mouse = LocalPlayer:GetMouse();

    local ProtectGui = protectgui or (syn and syn.protect_gui) or (function() end);

    local ScreenGui = Instance.new('ScreenGui');
    ProtectGui(ScreenGui);

    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global;
    ScreenGui.Parent = CoreGui;

    local Toggles = {};
    local Options = {};

    getgenv().Toggles = Toggles;
    getgenv().Options = Options;

    local Library = {
        Registry = {};
        RegistryMap = {};

        HudRegistry = {};

        AccentColor = Redacted.Accent;
        FontColor = Color3.fromRGB(255, 255, 255);
        MainColor = Color3.fromRGB(28, 28, 28);
        BackgroundColor = Color3.fromRGB(20, 20, 20);
        OutlineColor = Color3.fromRGB(50, 50, 50);
        RiskColor = Color3.fromRGB(255, 50, 50),

        Black = Color3.new(0, 0, 0);
        Font = Enum.Font.Code,

        OpenedFrames = {};
        DependencyBoxes = {};

        Signals = {};
        ScreenGui = ScreenGui;
    };

    local RainbowStep = 0
    local Hue = 0

    table.insert(Library.Signals, RenderStepped:Connect(function(Delta)
        RainbowStep = RainbowStep + Delta

        if RainbowStep >= (1 / 60) then
            RainbowStep = 0

            Hue = Hue + (1 / 400);

            if Hue > 1 then
                Hue = 0;
            end;

            Library.CurrentRainbowHue = Hue;
            Library.CurrentRainbowColor = Color3.fromHSV(Hue, 0.8, 1);
        end
    end))

    local function GetPlayersString()
        local PlayerList = Players:GetPlayers();

        for i = 1, #PlayerList do
            PlayerList[i] = PlayerList[i].Name;
        end;

        table.sort(PlayerList, function(str1, str2) return str1 < str2 end);

        return PlayerList;
    end;

    local function GetTeamsString()
        local TeamList = Teams:GetTeams();

        for i = 1, #TeamList do
            TeamList[i] = TeamList[i].Name;
        end;

        table.sort(TeamList, function(str1, str2) return str1 < str2 end);
        
        return TeamList;
    end;

    function Library:SafeCallback(f, ...)
        if (not f) then
            return;
        end;

        if not Library.NotifyOnError then
            return f(...);
        end;

        local success, event = pcall(f, ...);

        if not success then
            local _, i = event:find(":%d+: ");

            if not i then
                return Library:Notify(event);
            end;

            return Library:Notify(event:sub(i + 1), 3);
        end;
    end;

    function Library:AttemptSave()
        if Library.SaveManager then
            Library.SaveManager:Save();
        end;
    end;

    function Library:Create(Class, Properties)
        local _Instance = Class;

        if type(Class) == 'string' then
            _Instance = Instance.new(Class);
        end;

        for Property, Value in next, Properties do
            _Instance[Property] = Value;
        end;

        return _Instance;
    end;

    function Library:ApplyTextStroke(Inst)
        Inst.TextStrokeTransparency = 1;

        Library:Create('UIStroke', {
            Color = Color3.new(0, 0, 0);
            Thickness = 1;
            LineJoinMode = Enum.LineJoinMode.Miter;
            Parent = Inst;
        });
    end;

    function Library:CreateLabel(Properties, IsHud)
        local _Instance = Library:Create('TextLabel', {
            BackgroundTransparency = 1;
            Font = Library.Font;
            TextColor3 = Library.FontColor;
            TextSize = 16;
            TextStrokeTransparency = 0;
        });

        Library:ApplyTextStroke(_Instance);

        Library:AddToRegistry(_Instance, {
            TextColor3 = 'FontColor';
        }, IsHud);

        return Library:Create(_Instance, Properties);
    end;

    function Library:MakeDraggable(Instance, Cutoff)
        Instance.Active = true;

        Instance.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                local ObjPos = Vector2.new(
                    Mouse.X - Instance.AbsolutePosition.X,
                    Mouse.Y - Instance.AbsolutePosition.Y
                );

                if ObjPos.Y > (Cutoff or 40) then
                    return;
                end;

                while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                    Instance.Position = UDim2.new(
                        0,
                        Mouse.X - ObjPos.X + (Instance.Size.X.Offset * Instance.AnchorPoint.X),
                        0,
                        Mouse.Y - ObjPos.Y + (Instance.Size.Y.Offset * Instance.AnchorPoint.Y)
                    );

                    RenderStepped:Wait();
                end;
            end;
        end)
    end;

    function Library:AddToolTip(InfoStr, HoverInstance)
        local X, Y = Library:GetTextBounds(InfoStr, Library.Font, 14);
        local Tooltip = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor,
            BorderColor3 = Library.OutlineColor,

            Size = UDim2.fromOffset(X + 5, Y + 4),
            ZIndex = 100,
            Parent = Library.ScreenGui,

            Visible = false,
        })

        local Label = Library:CreateLabel({
            Position = UDim2.fromOffset(3, 1),
            Size = UDim2.fromOffset(X, Y);
            TextSize = 14;
            Text = InfoStr,
            TextColor3 = Library.FontColor,
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = Tooltip.ZIndex + 1,

            Parent = Tooltip;
        });

        Library:AddToRegistry(Tooltip, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        Library:AddToRegistry(Label, {
            TextColor3 = 'FontColor',
        });

        local IsHovering = false

        HoverInstance.MouseEnter:Connect(function()
            if Library:MouseIsOverOpenedFrame() then
                return
            end

            IsHovering = true

            Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
            Tooltip.Visible = true

            while IsHovering do
                RunService.Heartbeat:Wait()
                Tooltip.Position = UDim2.fromOffset(Mouse.X + 15, Mouse.Y + 12)
            end
        end)

        HoverInstance.MouseLeave:Connect(function()
            IsHovering = false
            Tooltip.Visible = false
        end)
    end

    function Library:OnHighlight(HighlightInstance, Instance, Properties, PropertiesDefault)
        HighlightInstance.MouseEnter:Connect(function()
            local Reg = Library.RegistryMap[Instance];

            for Property, ColorIdx in next, Properties do
                Instance[Property] = Library[ColorIdx] or ColorIdx;

                if Reg and Reg.Properties[Property] then
                    Reg.Properties[Property] = ColorIdx;
                end;
            end;
        end)

        HighlightInstance.MouseLeave:Connect(function()
            local Reg = Library.RegistryMap[Instance];

            for Property, ColorIdx in next, PropertiesDefault do
                Instance[Property] = Library[ColorIdx] or ColorIdx;

                if Reg and Reg.Properties[Property] then
                    Reg.Properties[Property] = ColorIdx;
                end;
            end;
        end)
    end;

    function Library:MouseIsOverOpenedFrame()
        for Frame, _ in next, Library.OpenedFrames do
            local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

            if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
                and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then

                return true;
            end;
        end;
    end;

    function Library:IsMouseOverFrame(Frame)
        local AbsPos, AbsSize = Frame.AbsolutePosition, Frame.AbsoluteSize;

        if Mouse.X >= AbsPos.X and Mouse.X <= AbsPos.X + AbsSize.X
            and Mouse.Y >= AbsPos.Y and Mouse.Y <= AbsPos.Y + AbsSize.Y then

            return true;
        end;
    end;

    function Library:UpdateDependencyBoxes()
        for _, Depbox in next, Library.DependencyBoxes do
            Depbox:Update();
        end;
    end;

    function Library:MapValue(Value, MinA, MaxA, MinB, MaxB)
        return (1 - ((Value - MinA) / (MaxA - MinA))) * MinB + ((Value - MinA) / (MaxA - MinA)) * MaxB;
    end;

    function Library:GetTextBounds(Text, Font, Size, Resolution)
        local Bounds = TextService:GetTextSize(Text, Size, Font, Resolution or Vector2.new(1920, 1080))
        return Bounds.X, Bounds.Y
    end;

    function Library:GetDarkerColor(Color)
        local H, S, V = Color3.toHSV(Color);
        return Color3.fromHSV(H, S, V / 1.5);
    end;
    Library.AccentColorDark = Library:GetDarkerColor(Library.AccentColor);

    function Library:AddToRegistry(Instance, Properties, IsHud)
        local Idx = #Library.Registry + 1;
        local Data = {
            Instance = Instance;
            Properties = Properties;
            Idx = Idx;
        };

        table.insert(Library.Registry, Data);
        Library.RegistryMap[Instance] = Data;

        if IsHud then
            table.insert(Library.HudRegistry, Data);
        end;
    end;

    function Library:RemoveFromRegistry(Instance)
        local Data = Library.RegistryMap[Instance];

        if Data then
            for Idx = #Library.Registry, 1, -1 do
                if Library.Registry[Idx] == Data then
                    table.remove(Library.Registry, Idx);
                end;
            end;

            for Idx = #Library.HudRegistry, 1, -1 do
                if Library.HudRegistry[Idx] == Data then
                    table.remove(Library.HudRegistry, Idx);
                end;
            end;

            Library.RegistryMap[Instance] = nil;
        end;
    end;

    function Library:UpdateColorsUsingRegistry()
        -- TODO: Could have an 'active' list of objects
        -- where the active list only contains Visible objects.

        -- IMPL: Could setup .Changed events on the AddToRegistry function
        -- that listens for the 'Visible' propert being changed.
        -- Visible: true => Add to active list, and call UpdateColors function
        -- Visible: false => Remove from active list.

        -- The above would be especially efficient for a rainbow menu color or live color-changing.

        for Idx, Object in next, Library.Registry do
            for Property, ColorIdx in next, Object.Properties do
                if type(ColorIdx) == 'string' then
                    Object.Instance[Property] = Library[ColorIdx];
                elseif type(ColorIdx) == 'function' then
                    Object.Instance[Property] = ColorIdx()
                end
            end;
        end;
    end;

    function Library:GiveSignal(Signal)
        -- Only used for signals not attached to library instances, as those should be cleaned up on object destruction by Roblox
        table.insert(Library.Signals, Signal)
    end

    function Library:Unload()
        -- Unload all of the signals
        for Idx = #Library.Signals, 1, -1 do
            local Connection = table.remove(Library.Signals, Idx)
            Connection:Disconnect()
        end

        -- Call our unload callback, maybe to undo some hooks etc
        if Library.OnUnload then
            Library.OnUnload()
        end

        ScreenGui:Destroy()
    end

    function Library:OnUnload(Callback)
        Library.OnUnload = Callback
    end

    Library:GiveSignal(ScreenGui.DescendantRemoving:Connect(function(Instance)
        if Library.RegistryMap[Instance] then
            Library:RemoveFromRegistry(Instance);
        end;
    end))

    local BaseAddons = {};

    do
        local Funcs = {};

        function Funcs:AddColorPicker(Idx, Info)
            local ToggleLabel = self.TextLabel;
            -- local Container = self.Container;

            assert(Info.Default, 'AddColorPicker: Missing default value.');

            local ColorPicker = {
                Value = Info.Default;
                Transparency = Info.Transparency or 0;
                Type = 'ColorPicker';
                Title = type(Info.Title) == 'string' and Info.Title or 'Color picker',
                Callback = Info.Callback or function(Color) end;
            };

            function ColorPicker:SetHSVFromRGB(Color)
                local H, S, V = Color3.toHSV(Color);

                ColorPicker.Hue = H;
                ColorPicker.Sat = S;
                ColorPicker.Vib = V;
            end;

            ColorPicker:SetHSVFromRGB(ColorPicker.Value);

            local DisplayFrame = Library:Create('Frame', {
                BackgroundColor3 = ColorPicker.Value;
                BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(0, 28, 0, 14);
                ZIndex = 6;
                Parent = ToggleLabel;
            });

            -- Transparency image taken from https://github.com/matas3535/SplixPrivateDrawingLibrary/blob/main/Library.lua cus i'm lazy
            local CheckerFrame = Library:Create('ImageLabel', {
                BorderSizePixel = 0;
                Size = UDim2.new(0, 27, 0, 13);
                ZIndex = 5;
                Image = 'http://www.roblox.com/asset/?id=12977615774';
                Visible = Info.Transparency;
                Parent = DisplayFrame;
            });

            -- 1/16/23
            -- Rewrote this to be placed inside the Library ScreenGui
            -- There was some issue which caused RelativeOffset to be way off
            -- Thus the color picker would never show

            local PickerFrameOuter = Library:Create('Frame', {
                Name = 'Color';
                BackgroundColor3 = Color3.new(1, 1, 1);
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18),
                Size = UDim2.fromOffset(230, Info.Transparency and 271 or 253);
                Visible = false;
                ZIndex = 15;
                Parent = ScreenGui,
            });

            DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
                PickerFrameOuter.Position = UDim2.fromOffset(DisplayFrame.AbsolutePosition.X, DisplayFrame.AbsolutePosition.Y + 18);
            end)

            local PickerFrameInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 16;
                Parent = PickerFrameOuter;
            });

            local Highlight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 0, 2);
                ZIndex = 17;
                Parent = PickerFrameInner;
            });

            local SatVibMapOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.new(0, 4, 0, 25);
                Size = UDim2.new(0, 200, 0, 200);
                ZIndex = 17;
                Parent = PickerFrameInner;
            });

            local SatVibMapInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 18;
                Parent = SatVibMapOuter;
            });

            local SatVibMap = Library:Create('ImageLabel', {
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 18;
                Image = 'rbxassetid://4155801252';
                Parent = SatVibMapInner;
            });

            local CursorOuter = Library:Create('ImageLabel', {
                AnchorPoint = Vector2.new(0.5, 0.5);
                Size = UDim2.new(0, 6, 0, 6);
                BackgroundTransparency = 1;
                Image = 'http://www.roblox.com/asset/?id=9619665977';
                ImageColor3 = Color3.new(0, 0, 0);
                ZIndex = 19;
                Parent = SatVibMap;
            });

            local CursorInner = Library:Create('ImageLabel', {
                Size = UDim2.new(0, CursorOuter.Size.X.Offset - 2, 0, CursorOuter.Size.Y.Offset - 2);
                Position = UDim2.new(0, 1, 0, 1);
                BackgroundTransparency = 1;
                Image = 'http://www.roblox.com/asset/?id=9619665977';
                ZIndex = 20;
                Parent = CursorOuter;
            })

            local HueSelectorOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.new(0, 208, 0, 25);
                Size = UDim2.new(0, 15, 0, 200);
                ZIndex = 17;
                Parent = PickerFrameInner;
            });

            local HueSelectorInner = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(1, 1, 1);
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 18;
                Parent = HueSelectorOuter;
            });

            local HueCursor = Library:Create('Frame', { 
                BackgroundColor3 = Color3.new(1, 1, 1);
                AnchorPoint = Vector2.new(0, 0.5);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, 0, 0, 1);
                ZIndex = 18;
                Parent = HueSelectorInner;
            });

            local HueBoxOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromOffset(4, 228),
                Size = UDim2.new(0.5, -6, 0, 20),
                ZIndex = 18,
                Parent = PickerFrameInner;
            });

            local HueBoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 18,
                Parent = HueBoxOuter;
            });

            Library:Create('UIGradient', {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
                });
                Rotation = 90;
                Parent = HueBoxInner;
            });

            local HueBox = Library:Create('TextBox', {
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 5, 0, 0);
                Size = UDim2.new(1, -5, 1, 0);
                Font = Library.Font;
                PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
                PlaceholderText = 'Hex color',
                Text = '#FFFFFF',
                TextColor3 = Library.FontColor;
                TextSize = 14;
                TextStrokeTransparency = 0;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 20,
                Parent = HueBoxInner;
            });

            Library:ApplyTextStroke(HueBox);

            local RgbBoxBase = Library:Create(HueBoxOuter:Clone(), {
                Position = UDim2.new(0.5, 2, 0, 228),
                Size = UDim2.new(0.5, -6, 0, 20),
                Parent = PickerFrameInner
            });

            local RgbBox = Library:Create(RgbBoxBase.Frame:FindFirstChild('TextBox'), {
                Text = '255, 255, 255',
                PlaceholderText = 'RGB color',
                TextColor3 = Library.FontColor
            });

            local TransparencyBoxOuter, TransparencyBoxInner, TransparencyCursor;
            
            if Info.Transparency then 
                TransparencyBoxOuter = Library:Create('Frame', {
                    BorderColor3 = Color3.new(0, 0, 0);
                    Position = UDim2.fromOffset(4, 251);
                    Size = UDim2.new(1, -8, 0, 15);
                    ZIndex = 19;
                    Parent = PickerFrameInner;
                });

                TransparencyBoxInner = Library:Create('Frame', {
                    BackgroundColor3 = ColorPicker.Value;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Inset;
                    Size = UDim2.new(1, 0, 1, 0);
                    ZIndex = 19;
                    Parent = TransparencyBoxOuter;
                });

                Library:AddToRegistry(TransparencyBoxInner, { BorderColor3 = 'OutlineColor' });

                Library:Create('ImageLabel', {
                    BackgroundTransparency = 1;
                    Size = UDim2.new(1, 0, 1, 0);
                    Image = 'http://www.roblox.com/asset/?id=12978095818';
                    ZIndex = 20;
                    Parent = TransparencyBoxInner;
                });

                TransparencyCursor = Library:Create('Frame', { 
                    BackgroundColor3 = Color3.new(1, 1, 1);
                    AnchorPoint = Vector2.new(0.5, 0);
                    BorderColor3 = Color3.new(0, 0, 0);
                    Size = UDim2.new(0, 1, 1, 0);
                    ZIndex = 21;
                    Parent = TransparencyBoxInner;
                });
            end;

            local DisplayLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 14);
                Position = UDim2.fromOffset(5, 5);
                TextXAlignment = Enum.TextXAlignment.Left;
                TextSize = 14;
                Text = ColorPicker.Title,--Info.Default;
                TextWrapped = false;
                ZIndex = 16;
                Parent = PickerFrameInner;
            });


            local ContextMenu = {}
            do
                ContextMenu.Options = {}
                ContextMenu.Container = Library:Create('Frame', {
                    BorderColor3 = Color3.new(),
                    ZIndex = 14,

                    Visible = false,
                    Parent = ScreenGui
                })

                ContextMenu.Inner = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Inset;
                    Size = UDim2.fromScale(1, 1);
                    ZIndex = 15;
                    Parent = ContextMenu.Container;
                });

                Library:Create('UIListLayout', {
                    Name = 'Layout',
                    FillDirection = Enum.FillDirection.Vertical;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Parent = ContextMenu.Inner;
                });

                Library:Create('UIPadding', {
                    Name = 'Padding',
                    PaddingLeft = UDim.new(0, 4),
                    Parent = ContextMenu.Inner,
                });

                local function updateMenuPosition()
                    ContextMenu.Container.Position = UDim2.fromOffset(
                        (DisplayFrame.AbsolutePosition.X + DisplayFrame.AbsoluteSize.X) + 4,
                        DisplayFrame.AbsolutePosition.Y + 1
                    )
                end

                local function updateMenuSize()
                    local menuWidth = 60
                    for i, label in next, ContextMenu.Inner:GetChildren() do
                        if label:IsA('TextLabel') then
                            menuWidth = math.max(menuWidth, label.TextBounds.X)
                        end
                    end

                    ContextMenu.Container.Size = UDim2.fromOffset(
                        menuWidth + 8,
                        ContextMenu.Inner.Layout.AbsoluteContentSize.Y + 4
                    )
                end

                DisplayFrame:GetPropertyChangedSignal('AbsolutePosition'):Connect(updateMenuPosition)
                ContextMenu.Inner.Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(updateMenuSize)

                task.spawn(updateMenuPosition)
                task.spawn(updateMenuSize)

                Library:AddToRegistry(ContextMenu.Inner, {
                    BackgroundColor3 = 'BackgroundColor';
                    BorderColor3 = 'OutlineColor';
                });

                function ContextMenu:Show()
                    self.Container.Visible = true
                end

                function ContextMenu:Hide()
                    self.Container.Visible = false
                end

                function ContextMenu:AddOption(Str, Callback)
                    if type(Callback) ~= 'function' then
                        Callback = function() end
                    end

                    local Button = Library:CreateLabel({
                        Active = false;
                        Size = UDim2.new(1, 0, 0, 15);
                        TextSize = 13;
                        Text = Str;
                        ZIndex = 16;
                        Parent = self.Inner;
                        TextXAlignment = Enum.TextXAlignment.Left,
                    });

                    Library:OnHighlight(Button, Button, 
                        { TextColor3 = 'AccentColor' },
                        { TextColor3 = 'FontColor' }
                    );

                    Button.InputBegan:Connect(function(Input)
                        if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                            return
                        end

                        Callback()
                    end)
                end

                ContextMenu:AddOption('Copy color', function()
                    Library.ColorClipboard = ColorPicker.Value
                    Library:Notify('Copied color!', 2)
                end)

                ContextMenu:AddOption('Paste color', function()
                    if not Library.ColorClipboard then
                        return Library:Notify('You have not copied a color!', 2)
                    end
                    ColorPicker:SetValueRGB(Library.ColorClipboard)
                end)


                ContextMenu:AddOption('Copy HEX', function()
                    pcall(setclipboard, ColorPicker.Value:ToHex())
                    Library:Notify('Copied hex code to clipboard!', 2)
                end)

                ContextMenu:AddOption('Copy RGB', function()
                    pcall(setclipboard, table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', '))
                    Library:Notify('Copied RGB values to clipboard!', 2)
                end)

            end

            Library:AddToRegistry(PickerFrameInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });
            Library:AddToRegistry(Highlight, { BackgroundColor3 = 'AccentColor'; });
            Library:AddToRegistry(SatVibMapInner, { BackgroundColor3 = 'BackgroundColor'; BorderColor3 = 'OutlineColor'; });

            Library:AddToRegistry(HueBoxInner, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
            Library:AddToRegistry(RgbBoxBase.Frame, { BackgroundColor3 = 'MainColor'; BorderColor3 = 'OutlineColor'; });
            Library:AddToRegistry(RgbBox, { TextColor3 = 'FontColor', });
            Library:AddToRegistry(HueBox, { TextColor3 = 'FontColor', });

            local SequenceTable = {};

            for Hue = 0, 1, 0.1 do
                table.insert(SequenceTable, ColorSequenceKeypoint.new(Hue, Color3.fromHSV(Hue, 1, 1)));
            end;

            local HueSelectorGradient = Library:Create('UIGradient', {
                Color = ColorSequence.new(SequenceTable);
                Rotation = 90;
                Parent = HueSelectorInner;
            });

            HueBox.FocusLost:Connect(function(enter)
                if enter then
                    local success, result = pcall(Color3.fromHex, HueBox.Text)
                    if success and typeof(result) == 'Color3' then
                        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(result)
                    end
                end

                ColorPicker:Display()
            end)

            RgbBox.FocusLost:Connect(function(enter)
                if enter then
                    local r, g, b = RgbBox.Text:match('(%d+),%s*(%d+),%s*(%d+)')
                    if r and g and b then
                        ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib = Color3.toHSV(Color3.fromRGB(r, g, b))
                    end
                end

                ColorPicker:Display()
            end)

            function ColorPicker:Display()
                ColorPicker.Value = Color3.fromHSV(ColorPicker.Hue, ColorPicker.Sat, ColorPicker.Vib);
                SatVibMap.BackgroundColor3 = Color3.fromHSV(ColorPicker.Hue, 1, 1);

                Library:Create(DisplayFrame, {
                    BackgroundColor3 = ColorPicker.Value;
                    BackgroundTransparency = ColorPicker.Transparency;
                    BorderColor3 = Library:GetDarkerColor(ColorPicker.Value);
                });

                if TransparencyBoxInner then
                    TransparencyBoxInner.BackgroundColor3 = ColorPicker.Value;
                    TransparencyCursor.Position = UDim2.new(1 - ColorPicker.Transparency, 0, 0, 0);
                end;

                CursorOuter.Position = UDim2.new(ColorPicker.Sat, 0, 1 - ColorPicker.Vib, 0);
                HueCursor.Position = UDim2.new(0, 0, ColorPicker.Hue, 0);

                HueBox.Text = '#' .. ColorPicker.Value:ToHex()
                RgbBox.Text = table.concat({ math.floor(ColorPicker.Value.R * 255), math.floor(ColorPicker.Value.G * 255), math.floor(ColorPicker.Value.B * 255) }, ', ')

                Library:SafeCallback(ColorPicker.Callback, ColorPicker.Value, ColorPicker.Transparency);
                Library:SafeCallback(ColorPicker.Changed, ColorPicker.Value, ColorPicker.Transparency);
            end;

            function ColorPicker:OnChanged(Func)
                ColorPicker.Changed = Func;
                Func(ColorPicker.Value)
            end;

            function ColorPicker:Show()
                for Frame, Val in next, Library.OpenedFrames do
                    if Frame.Name == 'Color' then
                        Frame.Visible = false;
                        Library.OpenedFrames[Frame] = nil;
                    end;
                end;

                PickerFrameOuter.Visible = true;
                Library.OpenedFrames[PickerFrameOuter] = true;
            end;

            function ColorPicker:Hide()
                PickerFrameOuter.Visible = false;
                Library.OpenedFrames[PickerFrameOuter] = nil;
            end;

            function ColorPicker:SetValue(HSV, Transparency)
                local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3]);

                ColorPicker.Transparency = Transparency or 0;
                ColorPicker:SetHSVFromRGB(Color);
                ColorPicker:Display();
            end;

            function ColorPicker:SetValueRGB(Color, Transparency)
                ColorPicker.Transparency = Transparency or 0;
                ColorPicker:SetHSVFromRGB(Color);
                ColorPicker:Display();
            end;

            SatVibMap.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        local MinX = SatVibMap.AbsolutePosition.X;
                        local MaxX = MinX + SatVibMap.AbsoluteSize.X;
                        local MouseX = math.clamp(Mouse.X, MinX, MaxX);

                        local MinY = SatVibMap.AbsolutePosition.Y;
                        local MaxY = MinY + SatVibMap.AbsoluteSize.Y;
                        local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

                        ColorPicker.Sat = (MouseX - MinX) / (MaxX - MinX);
                        ColorPicker.Vib = 1 - ((MouseY - MinY) / (MaxY - MinY));
                        ColorPicker:Display();

                        RenderStepped:Wait();
                    end;

                    Library:AttemptSave();
                end;
            end);

            HueSelectorInner.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        local MinY = HueSelectorInner.AbsolutePosition.Y;
                        local MaxY = MinY + HueSelectorInner.AbsoluteSize.Y;
                        local MouseY = math.clamp(Mouse.Y, MinY, MaxY);

                        ColorPicker.Hue = ((MouseY - MinY) / (MaxY - MinY));
                        ColorPicker:Display();

                        RenderStepped:Wait();
                    end;

                    Library:AttemptSave();
                end;
            end);

            DisplayFrame.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                    if PickerFrameOuter.Visible then
                        ColorPicker:Hide()
                    else
                        ContextMenu:Hide()
                        ColorPicker:Show()
                    end;
                elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                    ContextMenu:Show()
                    ColorPicker:Hide()
                end
            end);

            if TransparencyBoxInner then
                TransparencyBoxInner.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                            local MinX = TransparencyBoxInner.AbsolutePosition.X;
                            local MaxX = MinX + TransparencyBoxInner.AbsoluteSize.X;
                            local MouseX = math.clamp(Mouse.X, MinX, MaxX);

                            ColorPicker.Transparency = 1 - ((MouseX - MinX) / (MaxX - MinX));

                            ColorPicker:Display();

                            RenderStepped:Wait();
                        end;

                        Library:AttemptSave();
                    end;
                end);
            end;

            Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local AbsPos, AbsSize = PickerFrameOuter.AbsolutePosition, PickerFrameOuter.AbsoluteSize;

                    if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                        or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                        ColorPicker:Hide();
                    end;

                    if not Library:IsMouseOverFrame(ContextMenu.Container) then
                        ContextMenu:Hide()
                    end
                end;

                if Input.UserInputType == Enum.UserInputType.MouseButton2 and ContextMenu.Container.Visible then
                    if not Library:IsMouseOverFrame(ContextMenu.Container) and not Library:IsMouseOverFrame(DisplayFrame) then
                        ContextMenu:Hide()
                    end
                end
            end))

            ColorPicker:Display();
            ColorPicker.DisplayFrame = DisplayFrame

            Options[Idx] = ColorPicker;

            return self;
        end;

        function Funcs:AddKeyPicker(Idx, Info)
            local ParentObj = self;
            local ToggleLabel = self.TextLabel;
            local Container = self.Container;

            assert(Info.Default, 'AddKeyPicker: Missing default value.');

            local KeyPicker = {
                Value = Info.Default;
                Toggled = false;
                Mode = Info.Mode or 'Toggle'; -- Always, Toggle, Hold
                Type = 'KeyPicker';
                Callback = Info.Callback or function(Value) end;
                ChangedCallback = Info.ChangedCallback or function(New) end;

                SyncToggleState = Info.SyncToggleState or false;
            };

            if KeyPicker.SyncToggleState then
                Info.Modes = { 'Toggle' }
                Info.Mode = 'Toggle'
            end

            local PickOuter = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(0, 28, 0, 15);
                ZIndex = 6;
                Parent = ToggleLabel;
            });

            local PickInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 7;
                Parent = PickOuter;
            });

            Library:AddToRegistry(PickInner, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            local DisplayLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 1, 0);
                TextSize = 13;
                Text = Info.Default;
                TextWrapped = true;
                ZIndex = 8;
                Parent = PickInner;
            });

            local ModeSelectOuter = Library:Create('Frame', {
                BorderColor3 = Color3.new(0, 0, 0);
                Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
                Size = UDim2.new(0, 60, 0, 45 + 2);
                Visible = false;
                ZIndex = 14;
                Parent = ScreenGui;
            });

            ToggleLabel:GetPropertyChangedSignal('AbsolutePosition'):Connect(function()
                ModeSelectOuter.Position = UDim2.fromOffset(ToggleLabel.AbsolutePosition.X + ToggleLabel.AbsoluteSize.X + 4, ToggleLabel.AbsolutePosition.Y + 1);
            end);

            local ModeSelectInner = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 15;
                Parent = ModeSelectOuter;
            });

            Library:AddToRegistry(ModeSelectInner, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = ModeSelectInner;
            });

            local ContainerLabel = Library:CreateLabel({
                TextXAlignment = Enum.TextXAlignment.Left;
                Size = UDim2.new(1, 0, 0, 18);
                TextSize = 13;
                Visible = false;
                ZIndex = 110;
                Parent = Library.KeybindContainer;
            },  true);

            local Modes = Info.Modes or { 'Always', 'Toggle', 'Hold' };
            local ModeButtons = {};

            for Idx, Mode in next, Modes do
                local ModeButton = {};

                local Label = Library:CreateLabel({
                    Active = false;
                    Size = UDim2.new(1, 0, 0, 15);
                    TextSize = 13;
                    Text = Mode;
                    ZIndex = 16;
                    Parent = ModeSelectInner;
                });

                function ModeButton:Select()
                    for _, Button in next, ModeButtons do
                        Button:Deselect();
                    end;

                    KeyPicker.Mode = Mode;

                    Label.TextColor3 = Library.AccentColor;
                    Library.RegistryMap[Label].Properties.TextColor3 = 'AccentColor';

                    ModeSelectOuter.Visible = false;
                end;

                function ModeButton:Deselect()
                    KeyPicker.Mode = nil;

                    Label.TextColor3 = Library.FontColor;
                    Library.RegistryMap[Label].Properties.TextColor3 = 'FontColor';
                end;

                Label.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        ModeButton:Select();
                        Library:AttemptSave();
                    end;
                end);

                if Mode == KeyPicker.Mode then
                    ModeButton:Select();
                end;

                ModeButtons[Mode] = ModeButton;
            end;

            function KeyPicker:Update()
                if Info.NoUI then
                    return;
                end;

                local State = KeyPicker:GetState();

                ContainerLabel.Text = string.format('[%s] %s (%s)', KeyPicker.Value, Info.Text, KeyPicker.Mode);

                ContainerLabel.Visible = true;
                ContainerLabel.TextColor3 = State and Library.AccentColor or Library.FontColor;

                Library.RegistryMap[ContainerLabel].Properties.TextColor3 = State and 'AccentColor' or 'FontColor';

                local YSize = 0
                local XSize = 0

                for _, Label in next, Library.KeybindContainer:GetChildren() do
                    if Label:IsA('TextLabel') and Label.Visible then
                        YSize = YSize + 18;
                        if (Label.TextBounds.X > XSize) then
                            XSize = Label.TextBounds.X
                        end
                    end;
                end;

                Library.KeybindFrame.Size = UDim2.new(0, math.max(XSize + 10, 210), 0, YSize + 23)
            end;

            function KeyPicker:GetState()
                if KeyPicker.Mode == 'Always' then
                    return true;
                elseif KeyPicker.Mode == 'Hold' then
                    if KeyPicker.Value == 'None' then
                        return false;
                    end

                    local Key = KeyPicker.Value;

                    if Key == 'MB1' or Key == 'MB2' then
                        return Key == 'MB1' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                            or Key == 'MB2' and InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2);
                    else
                        return InputService:IsKeyDown(Enum.KeyCode[KeyPicker.Value]);
                    end;
                else
                    return KeyPicker.Toggled;
                end;
            end;

            function KeyPicker:SetValue(Data)
                local Key, Mode = Data[1], Data[2];
                DisplayLabel.Text = Key;
                KeyPicker.Value = Key;
                ModeButtons[Mode]:Select();
                KeyPicker:Update();
            end;

            function KeyPicker:OnClick(Callback)
                KeyPicker.Clicked = Callback
            end

            function KeyPicker:OnChanged(Callback)
                KeyPicker.Changed = Callback
                Callback(KeyPicker.Value)
            end

            if ParentObj.Addons then
                table.insert(ParentObj.Addons, KeyPicker)
            end

            function KeyPicker:DoClick()
                if ParentObj.Type == 'Toggle' and KeyPicker.SyncToggleState then
                    ParentObj:SetValue(not ParentObj.Value)
                end

                Library:SafeCallback(KeyPicker.Callback, KeyPicker.Toggled)
                Library:SafeCallback(KeyPicker.Clicked, KeyPicker.Toggled)
            end

            local Picking = false;

            PickOuter.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                    Picking = true;

                    DisplayLabel.Text = '';

                    local Break;
                    local Text = '';

                    task.spawn(function()
                        while (not Break) do
                            if Text == '...' then
                                Text = '';
                            end;

                            Text = Text .. '.';
                            DisplayLabel.Text = Text;

                            wait(0.4);
                        end;
                    end);

                    wait(0.2);

                    local Event;
                    Event = InputService.InputBegan:Connect(function(Input)
                        local Key;

                        if Input.UserInputType == Enum.UserInputType.Keyboard then
                            Key = Input.KeyCode.Name;
                        elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                            Key = 'MB1';
                        elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                            Key = 'MB2';
                        end;

                        Break = true;
                        Picking = false;

                        DisplayLabel.Text = Key;
                        KeyPicker.Value = Key;

                        Library:SafeCallback(KeyPicker.ChangedCallback, Input.KeyCode or Input.UserInputType)
                        Library:SafeCallback(KeyPicker.Changed, Input.KeyCode or Input.UserInputType)

                        Library:AttemptSave();

                        Event:Disconnect();
                    end);
                elseif Input.UserInputType == Enum.UserInputType.MouseButton2 and not Library:MouseIsOverOpenedFrame() then
                    ModeSelectOuter.Visible = true;
                end;
            end);

            Library:GiveSignal(InputService.InputBegan:Connect(function(Input)
                if (not Picking) then
                    if KeyPicker.Mode == 'Toggle' then
                        local Key = KeyPicker.Value;

                        if Key == 'MB1' or Key == 'MB2' then
                            if Key == 'MB1' and Input.UserInputType == Enum.UserInputType.MouseButton1
                            or Key == 'MB2' and Input.UserInputType == Enum.UserInputType.MouseButton2 then
                                KeyPicker.Toggled = not KeyPicker.Toggled
                                KeyPicker:DoClick()
                            end;
                        elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                            if Input.KeyCode.Name == Key then
                                KeyPicker.Toggled = not KeyPicker.Toggled;
                                KeyPicker:DoClick()
                            end;
                        end;
                    end;

                    KeyPicker:Update();
                end;

                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local AbsPos, AbsSize = ModeSelectOuter.AbsolutePosition, ModeSelectOuter.AbsoluteSize;

                    if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                        or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                        ModeSelectOuter.Visible = false;
                    end;
                end;
            end))

            Library:GiveSignal(InputService.InputEnded:Connect(function(Input)
                if (not Picking) then
                    KeyPicker:Update();
                end;
            end))

            KeyPicker:Update();

            Options[Idx] = KeyPicker;

            return self;
        end;

        BaseAddons.__index = Funcs;
        BaseAddons.__namecall = function(Table, Key, ...)
            return Funcs[Key](...);
        end;
    end;

    local BaseGroupbox = {};

    do
        local Funcs = {};

        function Funcs:AddBlank(Size)
            local Groupbox = self;
            local Container = Groupbox.Container;

            Library:Create('Frame', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, Size);
                ZIndex = 1;
                Parent = Container;
            });
        end;

        function Funcs:AddLabel(Text, DoesWrap)
            local Label = {};

            local Groupbox = self;
            local Container = Groupbox.Container;

            local TextLabel = Library:CreateLabel({
                Size = UDim2.new(1, -4, 0, 15);
                TextSize = 14;
                Text = Text;
                TextWrapped = DoesWrap or false,
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 5;
                Parent = Container;
            });

            if DoesWrap then
                local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
                TextLabel.Size = UDim2.new(1, -4, 0, Y)
            else
                Library:Create('UIListLayout', {
                    Padding = UDim.new(0, 4);
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalAlignment = Enum.HorizontalAlignment.Right;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Parent = TextLabel;
                });
            end

            Label.TextLabel = TextLabel;
            Label.Container = Container;

            function Label:SetText(Text)
                TextLabel.Text = Text

                if DoesWrap then
                    local Y = select(2, Library:GetTextBounds(Text, Library.Font, 14, Vector2.new(TextLabel.AbsoluteSize.X, math.huge)))
                    TextLabel.Size = UDim2.new(1, -4, 0, Y)
                end

                Groupbox:Resize();
            end

            if (not DoesWrap) then
                setmetatable(Label, BaseAddons);
            end

            Groupbox:AddBlank(5);
            Groupbox:Resize();

            return Label;
        end;

        function Funcs:AddButton(...)
            -- TODO: Eventually redo this
            local Button = {};
            local function ProcessButtonParams(Class, Obj, ...)
                local Props = select(1, ...)
                if type(Props) == 'table' then
                    Obj.Text = Props.Text
                    Obj.Func = Props.Func
                    Obj.DoubleClick = Props.DoubleClick
                    Obj.Tooltip = Props.Tooltip
                else
                    Obj.Text = select(1, ...)
                    Obj.Func = select(2, ...)
                end

                assert(type(Obj.Func) == 'function', 'AddButton: `Func` callback is missing.');
            end

            ProcessButtonParams('Button', Button, ...)

            local Groupbox = self;
            local Container = Groupbox.Container;

            local function CreateBaseButton(Button)
                local Outer = Library:Create('Frame', {
                    BackgroundColor3 = Color3.new(0, 0, 0);
                    BorderColor3 = Color3.new(0, 0, 0);
                    Size = UDim2.new(1, -4, 0, 20);
                    ZIndex = 5;
                });

                local Inner = Library:Create('Frame', {
                    BackgroundColor3 = Library.MainColor;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Inset;
                    Size = UDim2.new(1, 0, 1, 0);
                    ZIndex = 6;
                    Parent = Outer;
                });

                local Label = Library:CreateLabel({
                    Size = UDim2.new(1, 0, 1, 0);
                    TextSize = 14;
                    Text = Button.Text;
                    ZIndex = 6;
                    Parent = Inner;
                });

                Library:Create('UIGradient', {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
                    });
                    Rotation = 90;
                    Parent = Inner;
                });

                Library:AddToRegistry(Outer, {
                    BorderColor3 = 'Black';
                });

                Library:AddToRegistry(Inner, {
                    BackgroundColor3 = 'MainColor';
                    BorderColor3 = 'OutlineColor';
                });

                Library:OnHighlight(Outer, Outer,
                    { BorderColor3 = 'AccentColor' },
                    { BorderColor3 = 'Black' }
                );

                return Outer, Inner, Label
            end

            local function InitEvents(Button)
                local function WaitForEvent(event, timeout, validator)
                    local bindable = Instance.new('BindableEvent')
                    local connection = event:Once(function(...)

                        if type(validator) == 'function' and validator(...) then
                            bindable:Fire(true)
                        else
                            bindable:Fire(false)
                        end
                    end)
                    task.delay(timeout, function()
                        connection:disconnect()
                        bindable:Fire(false)
                    end)
                    return bindable.Event:Wait()
                end

                local function ValidateClick(Input)
                    if Library:MouseIsOverOpenedFrame() then
                        return false
                    end

                    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                        return false
                    end

                    return true
                end

                Button.Outer.InputBegan:Connect(function(Input)
                    if not ValidateClick(Input) then return end
                    if Button.Locked then return end

                    if Button.DoubleClick then
                        Library:RemoveFromRegistry(Button.Label)
                        Library:AddToRegistry(Button.Label, { TextColor3 = 'AccentColor' })

                        Button.Label.TextColor3 = Library.AccentColor
                        Button.Label.Text = 'Are you sure?'
                        Button.Locked = true

                        local clicked = WaitForEvent(Button.Outer.InputBegan, 0.5, ValidateClick)

                        Library:RemoveFromRegistry(Button.Label)
                        Library:AddToRegistry(Button.Label, { TextColor3 = 'FontColor' })

                        Button.Label.TextColor3 = Library.FontColor
                        Button.Label.Text = Button.Text
                        task.defer(rawset, Button, 'Locked', false)

                        if clicked then
                            Library:SafeCallback(Button.Func)
                        end

                        return
                    end

                    Library:SafeCallback(Button.Func);
                end)
            end

            Button.Outer, Button.Inner, Button.Label = CreateBaseButton(Button)
            Button.Outer.Parent = Container

            InitEvents(Button)

            function Button:AddTooltip(tooltip)
                if type(tooltip) == 'string' then
                    Library:AddToolTip(tooltip, self.Outer)
                end
                return self
            end


            function Button:AddButton(...)
                local SubButton = {}

                ProcessButtonParams('SubButton', SubButton, ...)

                self.Outer.Size = UDim2.new(0.5, -2, 0, 20)

                SubButton.Outer, SubButton.Inner, SubButton.Label = CreateBaseButton(SubButton)

                SubButton.Outer.Position = UDim2.new(1, 3, 0, 0)
                SubButton.Outer.Size = UDim2.fromOffset(self.Outer.AbsoluteSize.X - 2, self.Outer.AbsoluteSize.Y)
                SubButton.Outer.Parent = self.Outer

                function SubButton:AddTooltip(tooltip)
                    if type(tooltip) == 'string' then
                        Library:AddToolTip(tooltip, self.Outer)
                    end
                    return SubButton
                end

                if type(SubButton.Tooltip) == 'string' then
                    SubButton:AddTooltip(SubButton.Tooltip)
                end

                InitEvents(SubButton)
                return SubButton
            end

            if type(Button.Tooltip) == 'string' then
                Button:AddTooltip(Button.Tooltip)
            end

            Groupbox:AddBlank(5);
            Groupbox:Resize();

            return Button;
        end;

        function Funcs:AddDivider()
            local Groupbox = self;
            local Container = self.Container

            local Divider = {
                Type = 'Divider',
            }

            Groupbox:AddBlank(2);
            local DividerOuter = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -4, 0, 5);
                ZIndex = 5;
                Parent = Container;
            });

            local DividerInner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = DividerOuter;
            });

            Library:AddToRegistry(DividerOuter, {
                BorderColor3 = 'Black';
            });

            Library:AddToRegistry(DividerInner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            });

            Groupbox:AddBlank(9);
            Groupbox:Resize();
        end

        function Funcs:AddInput(Idx, Info)
            assert(Info.Text, 'AddInput: Missing `Text` string.')

            local Textbox = {
                Value = Info.Default or '';
                Numeric = Info.Numeric or false;
                Finished = Info.Finished or false;
                Type = 'Input';
                Callback = Info.Callback or function(Value) end;
            };

            local Groupbox = self;
            local Container = Groupbox.Container;

            local InputLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 0, 15);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 5;
                Parent = Container;
            });

            Groupbox:AddBlank(1);

            local TextBoxOuter = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -4, 0, 20);
                ZIndex = 5;
                Parent = Container;
            });

            local TextBoxInner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = TextBoxOuter;
            });

            Library:AddToRegistry(TextBoxInner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            });

            Library:OnHighlight(TextBoxOuter, TextBoxOuter,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'Black' }
            );

            if type(Info.Tooltip) == 'string' then
                Library:AddToolTip(Info.Tooltip, TextBoxOuter)
            end

            Library:Create('UIGradient', {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
                });
                Rotation = 90;
                Parent = TextBoxInner;
            });

            local Container = Library:Create('Frame', {
                BackgroundTransparency = 1;
                ClipsDescendants = true;

                Position = UDim2.new(0, 5, 0, 0);
                Size = UDim2.new(1, -5, 1, 0);

                ZIndex = 7;
                Parent = TextBoxInner;
            })

            local Box = Library:Create('TextBox', {
                BackgroundTransparency = 1;

                Position = UDim2.fromOffset(0, 0),
                Size = UDim2.fromScale(5, 1),

                Font = Library.Font;
                PlaceholderColor3 = Color3.fromRGB(190, 190, 190);
                PlaceholderText = Info.Placeholder or '';

                Text = Info.Default or '';
                TextColor3 = Library.FontColor;
                TextSize = 14;
                TextStrokeTransparency = 0;
                TextXAlignment = Enum.TextXAlignment.Left;

                ZIndex = 7;
                Parent = Container;
            });

            Library:ApplyTextStroke(Box);

            function Textbox:SetValue(Text)
                if Info.MaxLength and #Text > Info.MaxLength then
                    Text = Text:sub(1, Info.MaxLength);
                end;

                if Textbox.Numeric then
                    if (not tonumber(Text)) and Text:len() > 0 then
                        Text = Textbox.Value
                    end
                end

                Textbox.Value = Text;
                Box.Text = Text;

                Library:SafeCallback(Textbox.Callback, Textbox.Value);
                Library:SafeCallback(Textbox.Changed, Textbox.Value);
            end;

            if Textbox.Finished then
                Box.FocusLost:Connect(function(enter)
                    if not enter then return end

                    Textbox:SetValue(Box.Text);
                    Library:AttemptSave();
                end)
            else
                Box:GetPropertyChangedSignal('Text'):Connect(function()
                    Textbox:SetValue(Box.Text);
                    Library:AttemptSave();
                end);
            end

            -- https://devforum.roblox.com/t/how-to-make-textboxes-follow-current-cursor-position/1368429/6
            -- thank you nicemike40 :)

            local function Update()
                local PADDING = 2
                local reveal = Container.AbsoluteSize.X

                if not Box:IsFocused() or Box.TextBounds.X <= reveal - 2 * PADDING then
                    -- we aren't focused, or we fit so be normal
                    Box.Position = UDim2.new(0, PADDING, 0, 0)
                else
                    -- we are focused and don't fit, so adjust position
                    local cursor = Box.CursorPosition
                    if cursor ~= -1 then
                        -- calculate pixel width of text from start to cursor
                        local subtext = string.sub(Box.Text, 1, cursor-1)
                        local width = TextService:GetTextSize(subtext, Box.TextSize, Box.Font, Vector2.new(math.huge, math.huge)).X

                        -- check if we're inside the box with the cursor
                        local currentCursorPos = Box.Position.X.Offset + width

                        -- adjust if necessary
                        if currentCursorPos < PADDING then
                            Box.Position = UDim2.fromOffset(PADDING-width, 0)
                        elseif currentCursorPos > reveal - PADDING - 1 then
                            Box.Position = UDim2.fromOffset(reveal-width-PADDING-1, 0)
                        end
                    end
                end
            end

            task.spawn(Update)

            Box:GetPropertyChangedSignal('Text'):Connect(Update)
            Box:GetPropertyChangedSignal('CursorPosition'):Connect(Update)
            Box.FocusLost:Connect(Update)
            Box.Focused:Connect(Update)

            Library:AddToRegistry(Box, {
                TextColor3 = 'FontColor';
            });

            function Textbox:OnChanged(Func)
                Textbox.Changed = Func;
                Func(Textbox.Value);
            end;

            Groupbox:AddBlank(5);
            Groupbox:Resize();

            Options[Idx] = Textbox;

            return Textbox;
        end;

        function Funcs:AddToggle(Idx, Info)
            assert(Info.Text, 'AddInput: Missing `Text` string.')

            local Toggle = {
                Value = Info.Default or false;
                Type = 'Toggle';

                Callback = Info.Callback or function(Value) end;
                Addons = {},
                Risky = Info.Risky,
            };

            local Groupbox = self;
            local Container = Groupbox.Container;

            local ToggleOuter = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(0, 13, 0, 13);
                ZIndex = 5;
                Parent = Container;
            });

            Library:AddToRegistry(ToggleOuter, {
                BorderColor3 = 'Black';
            });

            local ToggleInner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = ToggleOuter;
            });

            Library:AddToRegistry(ToggleInner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            });

            local ToggleLabel = Library:CreateLabel({
                Size = UDim2.new(0, 216, 1, 0);
                Position = UDim2.new(1, 6, 0, 0);
                TextSize = 14;
                Text = Info.Text;
                TextXAlignment = Enum.TextXAlignment.Left;
                ZIndex = 6;
                Parent = ToggleInner;
            });

            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 4);
                FillDirection = Enum.FillDirection.Horizontal;
                HorizontalAlignment = Enum.HorizontalAlignment.Right;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = ToggleLabel;
            });

            local ToggleRegion = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Size = UDim2.new(0, 170, 1, 0);
                ZIndex = 8;
                Parent = ToggleOuter;
            });

            Library:OnHighlight(ToggleRegion, ToggleOuter,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'Black' }
            );

            function Toggle:UpdateColors()
                Toggle:Display();
            end;

            if type(Info.Tooltip) == 'string' then
                Library:AddToolTip(Info.Tooltip, ToggleRegion)
            end

            function Toggle:Display()
                ToggleInner.BackgroundColor3 = Toggle.Value and Library.AccentColor or Library.MainColor;
                ToggleInner.BorderColor3 = Toggle.Value and Library.AccentColorDark or Library.OutlineColor;

                Library.RegistryMap[ToggleInner].Properties.BackgroundColor3 = Toggle.Value and 'AccentColor' or 'MainColor';
                Library.RegistryMap[ToggleInner].Properties.BorderColor3 = Toggle.Value and 'AccentColorDark' or 'OutlineColor';
            end;

            function Toggle:OnChanged(Func)
                Toggle.Changed = Func;
                Func(Toggle.Value);
            end;

            function Toggle:SetValue(Bool)
                Bool = (not not Bool);

                Toggle.Value = Bool;
                Toggle:Display();

                for _, Addon in next, Toggle.Addons do
                    if Addon.Type == 'KeyPicker' and Addon.SyncToggleState then
                        Addon.Toggled = Bool
                        Addon:Update()
                    end
                end

                Library:SafeCallback(Toggle.Callback, Toggle.Value);
                Library:SafeCallback(Toggle.Changed, Toggle.Value);
                Library:UpdateDependencyBoxes();
            end;

            ToggleRegion.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                    Toggle:SetValue(not Toggle.Value) -- Why was it not like this from the start?
                    Library:AttemptSave();
                end;
            end);

            if Toggle.Risky then
                Library:RemoveFromRegistry(ToggleLabel)
                ToggleLabel.TextColor3 = Library.RiskColor
                Library:AddToRegistry(ToggleLabel, { TextColor3 = 'RiskColor' })
            end

            Toggle:Display();
            Groupbox:AddBlank(Info.BlankSize or 5 + 2);
            Groupbox:Resize();

            Toggle.TextLabel = ToggleLabel;
            Toggle.Container = Container;
            setmetatable(Toggle, BaseAddons);

            Toggles[Idx] = Toggle;

            Library:UpdateDependencyBoxes();

            return Toggle;
        end;

        function Funcs:AddSlider(Idx, Info)
            assert(Info.Default, 'AddSlider: Missing default value.');
            assert(Info.Text, 'AddSlider: Missing slider text.');
            assert(Info.Min, 'AddSlider: Missing minimum value.');
            assert(Info.Max, 'AddSlider: Missing maximum value.');
            assert(Info.Rounding, 'AddSlider: Missing rounding value.');

            local Slider = {
                Value = Info.Default;
                Min = Info.Min;
                Max = Info.Max;
                Rounding = Info.Rounding;
                MaxSize = 232;
                Type = 'Slider';
                Callback = Info.Callback or function(Value) end;
            };

            local Groupbox = self;
            local Container = Groupbox.Container;

            if not Info.Compact then
                Library:CreateLabel({
                    Size = UDim2.new(1, 0, 0, 10);
                    TextSize = 14;
                    Text = Info.Text;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextYAlignment = Enum.TextYAlignment.Bottom;
                    ZIndex = 5;
                    Parent = Container;
                });

                Groupbox:AddBlank(3);
            end

            local SliderOuter = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -4, 0, 13);
                ZIndex = 5;
                Parent = Container;
            });

            Library:AddToRegistry(SliderOuter, {
                BorderColor3 = 'Black';
            });

            local SliderInner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = SliderOuter;
            });

            Library:AddToRegistry(SliderInner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            });

            local Fill = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderColor3 = Library.AccentColorDark;
                Size = UDim2.new(0, 0, 1, 0);
                ZIndex = 7;
                Parent = SliderInner;
            });

            Library:AddToRegistry(Fill, {
                BackgroundColor3 = 'AccentColor';
                BorderColor3 = 'AccentColorDark';
            });

            local HideBorderRight = Library:Create('Frame', {
                BackgroundColor3 = Library.AccentColor;
                BorderSizePixel = 0;
                Position = UDim2.new(1, 0, 0, 0);
                Size = UDim2.new(0, 1, 1, 0);
                ZIndex = 8;
                Parent = Fill;
            });

            Library:AddToRegistry(HideBorderRight, {
                BackgroundColor3 = 'AccentColor';
            });

            local DisplayLabel = Library:CreateLabel({
                Size = UDim2.new(1, 0, 1, 0);
                TextSize = 14;
                Text = 'Infinite';
                ZIndex = 9;
                Parent = SliderInner;
            });

            Library:OnHighlight(SliderOuter, SliderOuter,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'Black' }
            );

            if type(Info.Tooltip) == 'string' then
                Library:AddToolTip(Info.Tooltip, SliderOuter)
            end

            function Slider:UpdateColors()
                Fill.BackgroundColor3 = Library.AccentColor;
                Fill.BorderColor3 = Library.AccentColorDark;
            end;

            function Slider:Display()
                local Suffix = Info.Suffix or '';

                if Info.HideMax then
                    DisplayLabel.Text = string.format('%s', Slider.Value .. Suffix)
                else
                    DisplayLabel.Text = string.format('%s/%s', Slider.Value .. Suffix, Slider.Max .. Suffix);
                end

                local X = math.ceil(Library:MapValue(Slider.Value, Slider.Min, Slider.Max, 0, Slider.MaxSize));
                Fill.Size = UDim2.new(0, X, 1, 0);

                HideBorderRight.Visible = not (X == Slider.MaxSize or X == 0);
            end;

            function Slider:OnChanged(Func)
                Slider.Changed = Func;
                Func(Slider.Value);
            end;

            local function Round(Value)
                if Slider.Rounding == 0 then
                    return math.floor(Value);
                end;


                return tonumber(string.format('%.' .. Slider.Rounding .. 'f', Value))
            end;

            function Slider:GetValueFromXOffset(X)
                return Round(Library:MapValue(X, 0, Slider.MaxSize, Slider.Min, Slider.Max));
            end;

            function Slider:SetValue(Str)
                local Num = tonumber(Str);

                if (not Num) then
                    return;
                end;

                Num = math.clamp(Num, Slider.Min, Slider.Max);

                Slider.Value = Num;
                Slider:Display();

                Library:SafeCallback(Slider.Callback, Slider.Value);
                Library:SafeCallback(Slider.Changed, Slider.Value);
            end;

            SliderInner.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                    local mPos = Mouse.X;
                    local gPos = Fill.Size.X.Offset;
                    local Diff = mPos - (Fill.AbsolutePosition.X + gPos);

                    while InputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
                        local nMPos = Mouse.X;
                        local nX = math.clamp(gPos + (nMPos - mPos) + Diff, 0, Slider.MaxSize);

                        local nValue = Slider:GetValueFromXOffset(nX);
                        local OldValue = Slider.Value;
                        Slider.Value = nValue;

                        Slider:Display();

                        if nValue ~= OldValue then
                            Library:SafeCallback(Slider.Callback, Slider.Value);
                            Library:SafeCallback(Slider.Changed, Slider.Value);
                        end;

                        RenderStepped:Wait();
                    end;

                    Library:AttemptSave();
                end;
            end);

            Slider:Display();
            Groupbox:AddBlank(Info.BlankSize or 6);
            Groupbox:Resize();

            Options[Idx] = Slider;

            return Slider;
        end;

        function Funcs:AddDropdown(Idx, Info)
            if Info.SpecialType == 'Player' then
                Info.Values = GetPlayersString();
                Info.AllowNull = true;
            elseif Info.SpecialType == 'Team' then
                Info.Values = GetTeamsString();
                Info.AllowNull = true;
            end;

            assert(Info.Values, 'AddDropdown: Missing dropdown value list.');
            assert(Info.AllowNull or Info.Default, 'AddDropdown: Missing default value. Pass `AllowNull` as true if this was intentional.')

            if (not Info.Text) then
                Info.Compact = true;
            end;

            local Dropdown = {
                Values = Info.Values;
                Value = Info.Multi and {};
                Multi = Info.Multi;
                Type = 'Dropdown';
                SpecialType = Info.SpecialType; -- can be either 'Player' or 'Team'
                Callback = Info.Callback or function(Value) end;
            };

            local Groupbox = self;
            local Container = Groupbox.Container;

            local RelativeOffset = 0;

            if not Info.Compact then
                local DropdownLabel = Library:CreateLabel({
                    Size = UDim2.new(1, 0, 0, 10);
                    TextSize = 14;
                    Text = Info.Text;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    TextYAlignment = Enum.TextYAlignment.Bottom;
                    ZIndex = 5;
                    Parent = Container;
                });

                Groupbox:AddBlank(3);
            end

            for _, Element in next, Container:GetChildren() do
                if not Element:IsA('UIListLayout') then
                    RelativeOffset = RelativeOffset + Element.Size.Y.Offset;
                end;
            end;

            local DropdownOuter = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                Size = UDim2.new(1, -4, 0, 20);
                ZIndex = 5;
                Parent = Container;
            });

            Library:AddToRegistry(DropdownOuter, {
                BorderColor3 = 'Black';
            });

            local DropdownInner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 6;
                Parent = DropdownOuter;
            });

            Library:AddToRegistry(DropdownInner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            });

            Library:Create('UIGradient', {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(212, 212, 212))
                });
                Rotation = 90;
                Parent = DropdownInner;
            });

            local DropdownArrow = Library:Create('ImageLabel', {
                AnchorPoint = Vector2.new(0, 0.5);
                BackgroundTransparency = 1;
                Position = UDim2.new(1, -16, 0.5, 0);
                Size = UDim2.new(0, 12, 0, 12);
                Image = 'http://www.roblox.com/asset/?id=6282522798';
                ZIndex = 8;
                Parent = DropdownInner;
            });

            local ItemList = Library:CreateLabel({
                Position = UDim2.new(0, 5, 0, 0);
                Size = UDim2.new(1, -5, 1, 0);
                TextSize = 14;
                Text = '--';
                TextXAlignment = Enum.TextXAlignment.Left;
                TextWrapped = true;
                ZIndex = 7;
                Parent = DropdownInner;
            });

            Library:OnHighlight(DropdownOuter, DropdownOuter,
                { BorderColor3 = 'AccentColor' },
                { BorderColor3 = 'Black' }
            );

            if type(Info.Tooltip) == 'string' then
                Library:AddToolTip(Info.Tooltip, DropdownOuter)
            end

            local MAX_DROPDOWN_ITEMS = 8;

            local ListOuter = Library:Create('Frame', {
                BackgroundColor3 = Color3.new(0, 0, 0);
                BorderColor3 = Color3.new(0, 0, 0);
                ZIndex = 20;
                Visible = false;
                Parent = ScreenGui;
            });

            local function RecalculateListPosition()
                ListOuter.Position = UDim2.fromOffset(DropdownOuter.AbsolutePosition.X, DropdownOuter.AbsolutePosition.Y + DropdownOuter.Size.Y.Offset + 1);
            end;

            local function RecalculateListSize(YSize)
                ListOuter.Size = UDim2.fromOffset(DropdownOuter.AbsoluteSize.X, YSize or (MAX_DROPDOWN_ITEMS * 20 + 2))
            end;

            RecalculateListPosition();
            RecalculateListSize();

            DropdownOuter:GetPropertyChangedSignal('AbsolutePosition'):Connect(RecalculateListPosition);

            local ListInner = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderColor3 = Library.OutlineColor;
                BorderMode = Enum.BorderMode.Inset;
                BorderSizePixel = 0;
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 21;
                Parent = ListOuter;
            });

            Library:AddToRegistry(ListInner, {
                BackgroundColor3 = 'MainColor';
                BorderColor3 = 'OutlineColor';
            });

            local Scrolling = Library:Create('ScrollingFrame', {
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                CanvasSize = UDim2.new(0, 0, 0, 0);
                Size = UDim2.new(1, 0, 1, 0);
                ZIndex = 21;
                Parent = ListInner;

                TopImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',
                BottomImage = 'rbxasset://textures/ui/Scroll/scroll-middle.png',

                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Library.AccentColor,
            });

            Library:AddToRegistry(Scrolling, {
                ScrollBarImageColor3 = 'AccentColor'
            })

            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 0);
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = Scrolling;
            });

            function Dropdown:Display()
                local Values = Dropdown.Values;
                local Str = '';

                if Info.Multi then
                    for Idx, Value in next, Values do
                        if Dropdown.Value[Value] then
                            Str = Str .. Value .. ', ';
                        end;
                    end;

                    Str = Str:sub(1, #Str - 2);
                else
                    Str = Dropdown.Value or '';
                end;

                ItemList.Text = (Str == '' and '--' or Str);
            end;

            function Dropdown:GetActiveValues()
                if Info.Multi then
                    local T = {};

                    for Value, Bool in next, Dropdown.Value do
                        table.insert(T, Value);
                    end;

                    return T;
                else
                    return Dropdown.Value and 1 or 0;
                end;
            end;

            function Dropdown:BuildDropdownList()
                local Values = Dropdown.Values;
                local Buttons = {};

                for _, Element in next, Scrolling:GetChildren() do
                    if not Element:IsA('UIListLayout') then
                        Element:Destroy();
                    end;
                end;

                local Count = 0;

                for Idx, Value in next, Values do
                    local Table = {};

                    Count = Count + 1;

                    local Button = Library:Create('Frame', {
                        BackgroundColor3 = Library.MainColor;
                        BorderColor3 = Library.OutlineColor;
                        BorderMode = Enum.BorderMode.Middle;
                        Size = UDim2.new(1, -1, 0, 20);
                        ZIndex = 23;
                        Active = true,
                        Parent = Scrolling;
                    });

                    Library:AddToRegistry(Button, {
                        BackgroundColor3 = 'MainColor';
                        BorderColor3 = 'OutlineColor';
                    });

                    local ButtonLabel = Library:CreateLabel({
                        Active = false;
                        Size = UDim2.new(1, -6, 1, 0);
                        Position = UDim2.new(0, 6, 0, 0);
                        TextSize = 14;
                        Text = Value;
                        TextXAlignment = Enum.TextXAlignment.Left;
                        ZIndex = 25;
                        Parent = Button;
                    });

                    Library:OnHighlight(Button, Button,
                        { BorderColor3 = 'AccentColor', ZIndex = 24 },
                        { BorderColor3 = 'OutlineColor', ZIndex = 23 }
                    );

                    local Selected;

                    if Info.Multi then
                        Selected = Dropdown.Value[Value];
                    else
                        Selected = Dropdown.Value == Value;
                    end;

                    function Table:UpdateButton()
                        if Info.Multi then
                            Selected = Dropdown.Value[Value];
                        else
                            Selected = Dropdown.Value == Value;
                        end;

                        ButtonLabel.TextColor3 = Selected and Library.AccentColor or Library.FontColor;
                        Library.RegistryMap[ButtonLabel].Properties.TextColor3 = Selected and 'AccentColor' or 'FontColor';
                    end;

                    ButtonLabel.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local Try = not Selected;

                            if Dropdown:GetActiveValues() == 1 and (not Try) and (not Info.AllowNull) then
                            else
                                if Info.Multi then
                                    Selected = Try;

                                    if Selected then
                                        Dropdown.Value[Value] = true;
                                    else
                                        Dropdown.Value[Value] = nil;
                                    end;
                                else
                                    Selected = Try;

                                    if Selected then
                                        Dropdown.Value = Value;
                                    else
                                        Dropdown.Value = nil;
                                    end;

                                    for _, OtherButton in next, Buttons do
                                        OtherButton:UpdateButton();
                                    end;
                                end;

                                Table:UpdateButton();
                                Dropdown:Display();

                                Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
                                Library:SafeCallback(Dropdown.Changed, Dropdown.Value);

                                Library:AttemptSave();
                            end;
                        end;
                    end);

                    Table:UpdateButton();
                    Dropdown:Display();

                    Buttons[Button] = Table;
                end;

                Scrolling.CanvasSize = UDim2.fromOffset(0, (Count * 20) + 1);

                local Y = math.clamp(Count * 20, 0, MAX_DROPDOWN_ITEMS * 20) + 1;
                RecalculateListSize(Y);
            end;

            function Dropdown:SetValues(NewValues)
                if NewValues then
                    Dropdown.Values = NewValues;
                end;

                Dropdown:BuildDropdownList();
            end;

            function Dropdown:OpenDropdown()
                ListOuter.Visible = true;
                Library.OpenedFrames[ListOuter] = true;
                DropdownArrow.Rotation = 180;
            end;

            function Dropdown:CloseDropdown()
                ListOuter.Visible = false;
                Library.OpenedFrames[ListOuter] = nil;
                DropdownArrow.Rotation = 0;
            end;

            function Dropdown:OnChanged(Func)
                Dropdown.Changed = Func;
                Func(Dropdown.Value);
            end;

            function Dropdown:SetValue(Val)
                if Dropdown.Multi then
                    local nTable = {};

                    for Value, Bool in next, Val do
                        if table.find(Dropdown.Values, Value) then
                            nTable[Value] = true
                        end;
                    end;

                    Dropdown.Value = nTable;
                else
                    if (not Val) then
                        Dropdown.Value = nil;
                    elseif table.find(Dropdown.Values, Val) then
                        Dropdown.Value = Val;
                    end;
                end;

                Dropdown:BuildDropdownList();

                Library:SafeCallback(Dropdown.Callback, Dropdown.Value);
                Library:SafeCallback(Dropdown.Changed, Dropdown.Value);
            end;

            DropdownOuter.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                    if ListOuter.Visible then
                        Dropdown:CloseDropdown();
                    else
                        Dropdown:OpenDropdown();
                    end;
                end;
            end);

            InputService.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    local AbsPos, AbsSize = ListOuter.AbsolutePosition, ListOuter.AbsoluteSize;

                    if Mouse.X < AbsPos.X or Mouse.X > AbsPos.X + AbsSize.X
                        or Mouse.Y < (AbsPos.Y - 20 - 1) or Mouse.Y > AbsPos.Y + AbsSize.Y then

                        Dropdown:CloseDropdown();
                    end;
                end;
            end);

            Dropdown:BuildDropdownList();
            Dropdown:Display();

            local Defaults = {}

            if type(Info.Default) == 'string' then
                local Idx = table.find(Dropdown.Values, Info.Default)
                if Idx then
                    table.insert(Defaults, Idx)
                end
            elseif type(Info.Default) == 'table' then
                for _, Value in next, Info.Default do
                    local Idx = table.find(Dropdown.Values, Value)
                    if Idx then
                        table.insert(Defaults, Idx)
                    end
                end
            elseif type(Info.Default) == 'number' and Dropdown.Values[Info.Default] ~= nil then
                table.insert(Defaults, Info.Default)
            end

            if next(Defaults) then
                for i = 1, #Defaults do
                    local Index = Defaults[i]
                    if Info.Multi then
                        Dropdown.Value[Dropdown.Values[Index]] = true
                    else
                        Dropdown.Value = Dropdown.Values[Index];
                    end

                    if (not Info.Multi) then break end
                end

                Dropdown:BuildDropdownList();
                Dropdown:Display();
            end

            Groupbox:AddBlank(Info.BlankSize or 5);
            Groupbox:Resize();

            Options[Idx] = Dropdown;

            return Dropdown;
        end;

        function Funcs:AddDependencyBox()
            local Depbox = {
                Dependencies = {};
            };
            
            local Groupbox = self;
            local Container = Groupbox.Container;

            local Holder = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 0, 0);
                Visible = false;
                Parent = Container;
            });

            local Frame = Library:Create('Frame', {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                Visible = true;
                Parent = Holder;
            });

            local Layout = Library:Create('UIListLayout', {
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                Parent = Frame;
            });

            function Depbox:Resize()
                Holder.Size = UDim2.new(1, 0, 0, Layout.AbsoluteContentSize.Y);
                Groupbox:Resize();
            end;

            Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                Depbox:Resize();
            end);

            Holder:GetPropertyChangedSignal('Visible'):Connect(function()
                Depbox:Resize();
            end);

            function Depbox:Update()
                for _, Dependency in next, Depbox.Dependencies do
                    local Elem = Dependency[1];
                    local Value = Dependency[2];

                    if Elem.Type == 'Toggle' and Elem.Value ~= Value then
                        Holder.Visible = false;
                        Depbox:Resize();
                        return;
                    end;
                end;

                Holder.Visible = true;
                Depbox:Resize();
            end;

            function Depbox:SetupDependencies(Dependencies)
                for _, Dependency in next, Dependencies do
                    assert(type(Dependency) == 'table', 'SetupDependencies: Dependency is not of type `table`.');
                    assert(Dependency[1], 'SetupDependencies: Dependency is missing element argument.');
                    assert(Dependency[2] ~= nil, 'SetupDependencies: Dependency is missing value argument.');
                end;

                Depbox.Dependencies = Dependencies;
                Depbox:Update();
            end;

            Depbox.Container = Frame;

            setmetatable(Depbox, BaseGroupbox);

            table.insert(Library.DependencyBoxes, Depbox);

            return Depbox;
        end;

        BaseGroupbox.__index = Funcs;
        BaseGroupbox.__namecall = function(Table, Key, ...)
            return Funcs[Key](...);
        end;
    end;

    -- < Create other UI elements >
    do
        Library.NotificationArea = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 0, 0, 40);
            Size = UDim2.new(0, 300, 0, 200);
            ZIndex = 100;
            Parent = ScreenGui;
        });

        Library:Create('UIListLayout', {
            Padding = UDim.new(0, 4);
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = Library.NotificationArea;
        });

        local WatermarkOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 100, 0, -25);
            Size = UDim2.new(0, 213, 0, 20);
            ZIndex = 200;
            Visible = false;
            Parent = ScreenGui;
        });

        local WatermarkInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.AccentColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 201;
            Parent = WatermarkOuter;
        });

        Library:AddToRegistry(WatermarkInner, {
            BorderColor3 = 'AccentColor';
        });

        local InnerFrame = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Position = UDim2.new(0, 1, 0, 1);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 202;
            Parent = WatermarkInner;
        });

        local Gradient = Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
            Rotation = -90;
            Parent = InnerFrame;
        });

        Library:AddToRegistry(Gradient, {
            Color = function()
                return ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                    ColorSequenceKeypoint.new(1, Library.MainColor),
                });
            end
        });

        local WatermarkLabel = Library:CreateLabel({
            Position = UDim2.new(0, 5, 0, 0);
            Size = UDim2.new(1, -4, 1, 0);
            TextSize = 14;
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 203;
            Parent = InnerFrame;
        });

        Library.Watermark = WatermarkOuter;
        Library.WatermarkText = WatermarkLabel;
        Library:MakeDraggable(Library.Watermark);



        local KeybindOuter = Library:Create('Frame', {
            AnchorPoint = Vector2.new(0, 0.5);
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 10, 0.5, 0);
            Size = UDim2.new(0, 210, 0, 20);
            Visible = false;
            ZIndex = 100;
            Parent = ScreenGui;
        });

        local KeybindInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 101;
            Parent = KeybindOuter;
        });

        Library:AddToRegistry(KeybindInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        }, true);

        local ColorFrame = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Size = UDim2.new(1, 0, 0, 2);
            ZIndex = 102;
            Parent = KeybindInner;
        });

        Library:AddToRegistry(ColorFrame, {
            BackgroundColor3 = 'AccentColor';
        }, true);

        local KeybindLabel = Library:CreateLabel({
            Size = UDim2.new(1, 0, 0, 20);
            Position = UDim2.fromOffset(5, 2),
            TextXAlignment = Enum.TextXAlignment.Left,

            Text = 'Keybinds';
            ZIndex = 104;
            Parent = KeybindInner;
        });

        local KeybindContainer = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Size = UDim2.new(1, 0, 1, -20);
            Position = UDim2.new(0, 0, 0, 20);
            ZIndex = 1;
            Parent = KeybindInner;
        });

        Library:Create('UIListLayout', {
            FillDirection = Enum.FillDirection.Vertical;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = KeybindContainer;
        });

        Library:Create('UIPadding', {
            PaddingLeft = UDim.new(0, 5),
            Parent = KeybindContainer,
        })

        Library.KeybindFrame = KeybindOuter;
        Library.KeybindContainer = KeybindContainer;
        Library:MakeDraggable(KeybindOuter);
    end;

    function Library:SetWatermarkVisibility(Bool)
        Library.Watermark.Visible = Bool;
    end;

    function Library:SetWatermark(Text)
        local X, Y = Library:GetTextBounds(Text, Library.Font, 14);
        Library.Watermark.Size = UDim2.new(0, X + 15, 0, (Y * 1.5) + 3);
        Library:SetWatermarkVisibility(true)

        Library.WatermarkText.Text = Text;
    end;

    function Library:Notify(Text, Time)
        local XSize, YSize = Library:GetTextBounds(Text, Library.Font, 14);

        YSize = YSize + 7

        local NotifyOuter = Library:Create('Frame', {
            BorderColor3 = Color3.new(0, 0, 0);
            Position = UDim2.new(0, 100, 0, 10);
            Size = UDim2.new(0, 0, 0, YSize);
            ClipsDescendants = true;
            ZIndex = 100;
            Parent = Library.NotificationArea;
        });

        local NotifyInner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            BorderMode = Enum.BorderMode.Inset;
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 101;
            Parent = NotifyOuter;
        });

        Library:AddToRegistry(NotifyInner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        }, true);

        local InnerFrame = Library:Create('Frame', {
            BackgroundColor3 = Color3.new(1, 1, 1);
            BorderSizePixel = 0;
            Position = UDim2.new(0, 1, 0, 1);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 102;
            Parent = NotifyInner;
        });

        local Gradient = Library:Create('UIGradient', {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                ColorSequenceKeypoint.new(1, Library.MainColor),
            });
            Rotation = -90;
            Parent = InnerFrame;
        });

        Library:AddToRegistry(Gradient, {
            Color = function()
                return ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Library:GetDarkerColor(Library.MainColor)),
                    ColorSequenceKeypoint.new(1, Library.MainColor),
                });
            end
        });

        local NotifyLabel = Library:CreateLabel({
            Position = UDim2.new(0, 4, 0, 0);
            Size = UDim2.new(1, -4, 1, 0);
            Text = Text;
            TextXAlignment = Enum.TextXAlignment.Left;
            TextSize = 14;
            ZIndex = 103;
            Parent = InnerFrame;
        });

        local LeftColor = Library:Create('Frame', {
            BackgroundColor3 = Library.AccentColor;
            BorderSizePixel = 0;
            Position = UDim2.new(0, -1, 0, -1);
            Size = UDim2.new(0, 3, 1, 2);
            ZIndex = 104;
            Parent = NotifyOuter;
        });

        Library:AddToRegistry(LeftColor, {
            BackgroundColor3 = 'AccentColor';
        }, true);

        pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, XSize + 8 + 4, 0, YSize), 'Out', 'Quad', 0.4, true);

        task.spawn(function()
            wait(Time or 5);

            pcall(NotifyOuter.TweenSize, NotifyOuter, UDim2.new(0, 0, 0, YSize), 'Out', 'Quad', 0.4, true);

            wait(0.4);

            NotifyOuter:Destroy();
        end);
    end;

    function Library:CreateWindow(...)
        local Arguments = { ... }
        local Config = { AnchorPoint = Vector2.zero }

        if type(...) == 'table' then
            Config = ...;
        else
            Config.Title = Arguments[1]
            Config.AutoShow = Arguments[2] or false;
        end

        if type(Config.Title) ~= 'string' then Config.Title = 'No title' end
        if type(Config.TabPadding) ~= 'number' then Config.TabPadding = 0 end
        if type(Config.MenuFadeTime) ~= 'number' then Config.MenuFadeTime = 0.2 end

        if typeof(Config.Position) ~= 'UDim2' then Config.Position = UDim2.fromOffset(175, 50) end
        if typeof(Config.Size) ~= 'UDim2' then Config.Size = UDim2.fromOffset(550, 600) end

        if Config.Center then
            Config.AnchorPoint = Vector2.new(0.5, 0.5)
            Config.Position = UDim2.fromScale(0.5, 0.5)
        end

        local Window = {
            Tabs = {};
        };

        local Outer = Library:Create('Frame', {
            AnchorPoint = Config.AnchorPoint,
            BackgroundColor3 = Color3.new(0, 0, 0);
            BorderSizePixel = 0;
            Position = Config.Position,
            Size = Config.Size,
            Visible = false;
            ZIndex = 1;
            Parent = ScreenGui;
        });

        Library:MakeDraggable(Outer, 25);

        local Inner = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.AccentColor;
            BorderMode = Enum.BorderMode.Inset;
            Position = UDim2.new(0, 1, 0, 1);
            Size = UDim2.new(1, -2, 1, -2);
            ZIndex = 1;
            Parent = Outer;
        });

        Library:AddToRegistry(Inner, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'AccentColor';
        });

        local WindowLabel = Library:CreateLabel({
            Position = UDim2.new(0, 7, 0, 0);
            Size = UDim2.new(0, 0, 0, 25);
            Text = Config.Title or '';
            TextXAlignment = Enum.TextXAlignment.Left;
            ZIndex = 1;
            Parent = Inner;
        });

        local MainSectionOuter = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Library.OutlineColor;
            Position = UDim2.new(0, 8, 0, 25);
            Size = UDim2.new(1, -16, 1, -33);
            ZIndex = 1;
            Parent = Inner;
        });

        Library:AddToRegistry(MainSectionOuter, {
            BackgroundColor3 = 'BackgroundColor';
            BorderColor3 = 'OutlineColor';
        });

        local MainSectionInner = Library:Create('Frame', {
            BackgroundColor3 = Library.BackgroundColor;
            BorderColor3 = Color3.new(0, 0, 0);
            BorderMode = Enum.BorderMode.Inset;
            Position = UDim2.new(0, 0, 0, 0);
            Size = UDim2.new(1, 0, 1, 0);
            ZIndex = 1;
            Parent = MainSectionOuter;
        });

        Library:AddToRegistry(MainSectionInner, {
            BackgroundColor3 = 'BackgroundColor';
        });

        local TabArea = Library:Create('Frame', {
            BackgroundTransparency = 1;
            Position = UDim2.new(0, 8, 0, 8);
            Size = UDim2.new(1, -16, 0, 21);
            ZIndex = 1;
            Parent = MainSectionInner;
        });

        local TabListLayout = Library:Create('UIListLayout', {
            Padding = UDim.new(0, Config.TabPadding);
            FillDirection = Enum.FillDirection.Horizontal;
            SortOrder = Enum.SortOrder.LayoutOrder;
            Parent = TabArea;
        });

        local TabContainer = Library:Create('Frame', {
            BackgroundColor3 = Library.MainColor;
            BorderColor3 = Library.OutlineColor;
            Position = UDim2.new(0, 8, 0, 30);
            Size = UDim2.new(1, -16, 1, -38);
            ZIndex = 2;
            Parent = MainSectionInner;
        });
        

        Library:AddToRegistry(TabContainer, {
            BackgroundColor3 = 'MainColor';
            BorderColor3 = 'OutlineColor';
        });

        function Window:SetWindowTitle(Title)
            WindowLabel.Text = Title;
        end;

        function Window:AddTab(Name)
            local Tab = {
                Groupboxes = {};
                Tabboxes = {};
            };

            local TabButtonWidth = Library:GetTextBounds(Name, Library.Font, 16);

            local TabButton = Library:Create('Frame', {
                BackgroundColor3 = Library.BackgroundColor;
                BorderColor3 = Library.OutlineColor;
                Size = UDim2.new(0, TabButtonWidth + 8 + 4, 1, 0);
                ZIndex = 1;
                Parent = TabArea;
            });

            Library:AddToRegistry(TabButton, {
                BackgroundColor3 = 'BackgroundColor';
                BorderColor3 = 'OutlineColor';
            });

            local TabButtonLabel = Library:CreateLabel({
                Position = UDim2.new(0, 0, 0, 0);
                Size = UDim2.new(1, 0, 1, -1);
                Text = Name;
                ZIndex = 1;
                Parent = TabButton;
            });

            local Blocker = Library:Create('Frame', {
                BackgroundColor3 = Library.MainColor;
                BorderSizePixel = 0;
                Position = UDim2.new(0, 0, 1, 0);
                Size = UDim2.new(1, 0, 0, 1);
                BackgroundTransparency = 1;
                ZIndex = 3;
                Parent = TabButton;
            });

            Library:AddToRegistry(Blocker, {
                BackgroundColor3 = 'MainColor';
            });

            local TabFrame = Library:Create('Frame', {
                Name = 'TabFrame',
                BackgroundTransparency = 1;
                Position = UDim2.new(0, 0, 0, 0);
                Size = UDim2.new(1, 0, 1, 0);
                Visible = false;
                ZIndex = 2;
                Parent = TabContainer;
            });

            local LeftSide = Library:Create('ScrollingFrame', {
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Position = UDim2.new(0, 8 - 1, 0, 8 - 1);
                Size = UDim2.new(0.5, -12 + 2, 0, 507 + 2);
                CanvasSize = UDim2.new(0, 0, 0, 0);
                BottomImage = '';
                TopImage = '';
                ScrollBarThickness = 0;
                ZIndex = 2;
                Parent = TabFrame;
            });

            local RightSide = Library:Create('ScrollingFrame', {
                BackgroundTransparency = 1;
                BorderSizePixel = 0;
                Position = UDim2.new(0.5, 4 + 1, 0, 8 - 1);
                Size = UDim2.new(0.5, -12 + 2, 0, 507 + 2);
                CanvasSize = UDim2.new(0, 0, 0, 0);
                BottomImage = '';
                TopImage = '';
                ScrollBarThickness = 0;
                ZIndex = 2;
                Parent = TabFrame;
            });

            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 8);
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                Parent = LeftSide;
            });

            Library:Create('UIListLayout', {
                Padding = UDim.new(0, 8);
                FillDirection = Enum.FillDirection.Vertical;
                SortOrder = Enum.SortOrder.LayoutOrder;
                HorizontalAlignment = Enum.HorizontalAlignment.Center;
                Parent = RightSide;
            });

            for _, Side in next, { LeftSide, RightSide } do
                Side:WaitForChild('UIListLayout'):GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()
                    Side.CanvasSize = UDim2.fromOffset(0, Side.UIListLayout.AbsoluteContentSize.Y);
                end);
            end;

            function Tab:ShowTab()
                for _, Tab in next, Window.Tabs do
                    Tab:HideTab();
                end;

                Blocker.BackgroundTransparency = 0;
                TabButton.BackgroundColor3 = Library.MainColor;
                Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'MainColor';
                TabFrame.Visible = true;
            end;

            function Tab:HideTab()
                Blocker.BackgroundTransparency = 1;
                TabButton.BackgroundColor3 = Library.BackgroundColor;
                Library.RegistryMap[TabButton].Properties.BackgroundColor3 = 'BackgroundColor';
                TabFrame.Visible = false;
            end;

            function Tab:SetLayoutOrder(Position)
                TabButton.LayoutOrder = Position;
                TabListLayout:ApplyLayout();
            end;

            function Tab:AddGroupbox(Info)
                local Groupbox = {};

                local BoxOuter = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Inset;
                    Size = UDim2.new(1, 0, 0, 507 + 2);
                    ZIndex = 2;
                    Parent = Info.Side == 1 and LeftSide or RightSide;
                });

                Library:AddToRegistry(BoxOuter, {
                    BackgroundColor3 = 'BackgroundColor';
                    BorderColor3 = 'OutlineColor';
                });

                local BoxInner = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderColor3 = Color3.new(0, 0, 0);
                    -- BorderMode = Enum.BorderMode.Inset;
                    Size = UDim2.new(1, -2, 1, -2);
                    Position = UDim2.new(0, 1, 0, 1);
                    ZIndex = 4;
                    Parent = BoxOuter;
                });

                Library:AddToRegistry(BoxInner, {
                    BackgroundColor3 = 'BackgroundColor';
                });

                local Highlight = Library:Create('Frame', {
                    BackgroundColor3 = Library.AccentColor;
                    BorderSizePixel = 0;
                    Size = UDim2.new(1, 0, 0, 2);
                    ZIndex = 5;
                    Parent = BoxInner;
                });

                Library:AddToRegistry(Highlight, {
                    BackgroundColor3 = 'AccentColor';
                });

                local GroupboxLabel = Library:CreateLabel({
                    Size = UDim2.new(1, 0, 0, 18);
                    Position = UDim2.new(0, 4, 0, 2);
                    TextSize = 14;
                    Text = Info.Name;
                    TextXAlignment = Enum.TextXAlignment.Left;
                    ZIndex = 5;
                    Parent = BoxInner;
                });

                local Container = Library:Create('Frame', {
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 4, 0, 20);
                    Size = UDim2.new(1, -4, 1, -20);
                    ZIndex = 1;
                    Parent = BoxInner;
                });

                Library:Create('UIListLayout', {
                    FillDirection = Enum.FillDirection.Vertical;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Parent = Container;
                });

                function Groupbox:Resize()
                    local Size = 0;

                    for _, Element in next, Groupbox.Container:GetChildren() do
                        if (not Element:IsA('UIListLayout')) and Element.Visible then
                            Size = Size + Element.Size.Y.Offset;
                        end;
                    end;

                    BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2);
                end;

                Groupbox.Container = Container;
                setmetatable(Groupbox, BaseGroupbox);

                Groupbox:AddBlank(3);
                Groupbox:Resize();

                Tab.Groupboxes[Info.Name] = Groupbox;

                return Groupbox;
            end;

            function Tab:AddLeftGroupbox(Name)
                return Tab:AddGroupbox({ Side = 1; Name = Name; });
            end;

            function Tab:AddRightGroupbox(Name)
                return Tab:AddGroupbox({ Side = 2; Name = Name; });
            end;

            function Tab:AddTabbox(Info)
                local Tabbox = {
                    Tabs = {};
                };

                local BoxOuter = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderColor3 = Library.OutlineColor;
                    BorderMode = Enum.BorderMode.Inset;
                    Size = UDim2.new(1, 0, 0, 0);
                    ZIndex = 2;
                    Parent = Info.Side == 1 and LeftSide or RightSide;
                });

                Library:AddToRegistry(BoxOuter, {
                    BackgroundColor3 = 'BackgroundColor';
                    BorderColor3 = 'OutlineColor';
                });

                local BoxInner = Library:Create('Frame', {
                    BackgroundColor3 = Library.BackgroundColor;
                    BorderColor3 = Color3.new(0, 0, 0);
                    -- BorderMode = Enum.BorderMode.Inset;
                    Size = UDim2.new(1, -2, 1, -2);
                    Position = UDim2.new(0, 1, 0, 1);
                    ZIndex = 4;
                    Parent = BoxOuter;
                });

                Library:AddToRegistry(BoxInner, {
                    BackgroundColor3 = 'BackgroundColor';
                });

                local Highlight = Library:Create('Frame', {
                    BackgroundColor3 = Library.AccentColor;
                    BorderSizePixel = 0;
                    Size = UDim2.new(1, 0, 0, 2);
                    ZIndex = 10;
                    Parent = BoxInner;
                });

                Library:AddToRegistry(Highlight, {
                    BackgroundColor3 = 'AccentColor';
                });

                local TabboxButtons = Library:Create('Frame', {
                    BackgroundTransparency = 1;
                    Position = UDim2.new(0, 0, 0, 1);
                    Size = UDim2.new(1, 0, 0, 18);
                    ZIndex = 5;
                    Parent = BoxInner;
                });

                Library:Create('UIListLayout', {
                    FillDirection = Enum.FillDirection.Horizontal;
                    HorizontalAlignment = Enum.HorizontalAlignment.Left;
                    SortOrder = Enum.SortOrder.LayoutOrder;
                    Parent = TabboxButtons;
                });

                function Tabbox:AddTab(Name)
                    local Tab = {};

                    local Button = Library:Create('Frame', {
                        BackgroundColor3 = Library.MainColor;
                        BorderColor3 = Color3.new(0, 0, 0);
                        Size = UDim2.new(0.5, 0, 1, 0);
                        ZIndex = 6;
                        Parent = TabboxButtons;
                    });

                    Library:AddToRegistry(Button, {
                        BackgroundColor3 = 'MainColor';
                    });

                    local ButtonLabel = Library:CreateLabel({
                        Size = UDim2.new(1, 0, 1, 0);
                        TextSize = 14;
                        Text = Name;
                        TextXAlignment = Enum.TextXAlignment.Center;
                        ZIndex = 7;
                        Parent = Button;
                    });

                    local Block = Library:Create('Frame', {
                        BackgroundColor3 = Library.BackgroundColor;
                        BorderSizePixel = 0;
                        Position = UDim2.new(0, 0, 1, 0);
                        Size = UDim2.new(1, 0, 0, 1);
                        Visible = false;
                        ZIndex = 9;
                        Parent = Button;
                    });

                    Library:AddToRegistry(Block, {
                        BackgroundColor3 = 'BackgroundColor';
                    });

                    local Container = Library:Create('Frame', {
                        BackgroundTransparency = 1;
                        Position = UDim2.new(0, 4, 0, 20);
                        Size = UDim2.new(1, -4, 1, -20);
                        ZIndex = 1;
                        Visible = false;
                        Parent = BoxInner;
                    });

                    Library:Create('UIListLayout', {
                        FillDirection = Enum.FillDirection.Vertical;
                        SortOrder = Enum.SortOrder.LayoutOrder;
                        Parent = Container;
                    });

                    function Tab:Show()
                        for _, Tab in next, Tabbox.Tabs do
                            Tab:Hide();
                        end;

                        Container.Visible = true;
                        Block.Visible = true;

                        Button.BackgroundColor3 = Library.BackgroundColor;
                        Library.RegistryMap[Button].Properties.BackgroundColor3 = 'BackgroundColor';

                        Tab:Resize();
                    end;

                    function Tab:Hide()
                        Container.Visible = false;
                        Block.Visible = false;

                        Button.BackgroundColor3 = Library.MainColor;
                        Library.RegistryMap[Button].Properties.BackgroundColor3 = 'MainColor';
                    end;

                    function Tab:Resize()
                        local TabCount = 0;

                        for _, Tab in next, Tabbox.Tabs do
                            TabCount = TabCount + 1;
                        end;

                        for _, Button in next, TabboxButtons:GetChildren() do
                            if not Button:IsA('UIListLayout') then
                                Button.Size = UDim2.new(1 / TabCount, 0, 1, 0);
                            end;
                        end;

                        if (not Container.Visible) then
                            return;
                        end;

                        local Size = 0;

                        for _, Element in next, Tab.Container:GetChildren() do
                            if (not Element:IsA('UIListLayout')) and Element.Visible then
                                Size = Size + Element.Size.Y.Offset;
                            end;
                        end;

                        BoxOuter.Size = UDim2.new(1, 0, 0, 20 + Size + 2 + 2);
                    end;

                    Button.InputBegan:Connect(function(Input)
                        if Input.UserInputType == Enum.UserInputType.MouseButton1 and not Library:MouseIsOverOpenedFrame() then
                            Tab:Show();
                            Tab:Resize();
                        end;
                    end);

                    Tab.Container = Container;
                    Tabbox.Tabs[Name] = Tab;

                    setmetatable(Tab, BaseGroupbox);

                    Tab:AddBlank(3);
                    Tab:Resize();

                    -- Show first tab (number is 2 cus of the UIListLayout that also sits in that instance)
                    if #TabboxButtons:GetChildren() == 2 then
                        Tab:Show();
                    end;

                    return Tab;
                end;

                Tab.Tabboxes[Info.Name or ''] = Tabbox;

                return Tabbox;
            end;

            function Tab:AddLeftTabbox(Name)
                return Tab:AddTabbox({ Name = Name, Side = 1; });
            end;

            function Tab:AddRightTabbox(Name)
                return Tab:AddTabbox({ Name = Name, Side = 2; });
            end;

            TabButton.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Tab:ShowTab();
                end;
            end);

            -- This was the first tab added, so we show it by default.
            if #TabContainer:GetChildren() == 1 then
                Tab:ShowTab();
            end;

            Window.Tabs[Name] = Tab;
            return Tab;
        end;

        local ModalElement = Library:Create('TextButton', {
            BackgroundTransparency = 1;
            Size = UDim2.new(0, 0, 0, 0);
            Visible = true;
            Text = '';
            Modal = false;
            Parent = ScreenGui;
        });

        local TransparencyCache = {};
        local Toggled = false;
        local Fading = false;

        function Library:Toggle()
            if Fading then
                return;
            end;

            local FadeTime = Config.MenuFadeTime;
            Fading = true;
            Toggled = (not Toggled);
            ModalElement.Modal = Toggled;

            if Toggled then
                -- A bit scuffed, but if we're going from not toggled -> toggled we want to show the frame immediately so that the fade is visible.
                Outer.Visible = true;

                task.spawn(function()
                    -- TODO: add cursor fade?
                    local State = InputService.MouseIconEnabled;

                    local Cursor = Drawing.new('Triangle');
                    Cursor.Thickness = 1;
                    Cursor.Filled = true;
                    Cursor.Visible = true;

                    local CursorOutline = Drawing.new('Triangle');
                    CursorOutline.Thickness = 1;
                    CursorOutline.Filled = false;
                    CursorOutline.Color = Color3.new(0, 0, 0);
                    CursorOutline.Visible = true;

                    while Toggled and ScreenGui.Parent do
                        InputService.MouseIconEnabled = false;

                        local mPos = InputService:GetMouseLocation();

                        Cursor.Color = Library.AccentColor;

                        Cursor.PointA = Vector2.new(mPos.X, mPos.Y);
                        Cursor.PointB = Vector2.new(mPos.X + 16, mPos.Y + 6);
                        Cursor.PointC = Vector2.new(mPos.X + 6, mPos.Y + 16);

                        CursorOutline.PointA = Cursor.PointA;
                        CursorOutline.PointB = Cursor.PointB;
                        CursorOutline.PointC = Cursor.PointC;

                        RenderStepped:Wait();
                    end;

                    InputService.MouseIconEnabled = State;

                    Cursor:Remove();
                    CursorOutline:Remove();
                end);
            end;

            for _, Desc in next, Outer:GetDescendants() do
                local Properties = {};

                if Desc:IsA('ImageLabel') then
                    table.insert(Properties, 'ImageTransparency');
                    table.insert(Properties, 'BackgroundTransparency');
                elseif Desc:IsA('TextLabel') or Desc:IsA('TextBox') then
                    table.insert(Properties, 'TextTransparency');
                elseif Desc:IsA('Frame') or Desc:IsA('ScrollingFrame') then
                    table.insert(Properties, 'BackgroundTransparency');
                elseif Desc:IsA('UIStroke') then
                    table.insert(Properties, 'Transparency');
                end;

                local Cache = TransparencyCache[Desc];

                if (not Cache) then
                    Cache = {};
                    TransparencyCache[Desc] = Cache;
                end;

                for _, Prop in next, Properties do
                    if not Cache[Prop] then
                        Cache[Prop] = Desc[Prop];
                    end;

                    if Cache[Prop] == 1 then
                        continue;
                    end;

                    TweenService:Create(Desc, TweenInfo.new(FadeTime, Enum.EasingStyle.Linear), { [Prop] = Toggled and Cache[Prop] or 1 }):Play();
                end;
            end;

            task.wait(FadeTime);

            Outer.Visible = Toggled;

            Fading = false;
        end

        Library:GiveSignal(InputService.InputBegan:Connect(function(Input, Processed)
            if type(Library.ToggleKeybind) == 'table' and Library.ToggleKeybind.Type == 'KeyPicker' then
                if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode.Name == Library.ToggleKeybind.Value then
                    task.spawn(Library.Toggle)
                end
            elseif Input.KeyCode == Enum.KeyCode.Insert then
                task.spawn(Library.Toggle)
            end
        end))

        if Config.AutoShow then task.spawn(Library.Toggle) end

        Window.Holder = Outer;

        return Window;
    end;

    local function OnPlayerChange()
        local PlayerList = GetPlayersString();

        for _, Value in next, Options do
            if Value.Type == 'Dropdown' and Value.SpecialType == 'Player' then
                Value:SetValues(PlayerList);
            end;
        end;
    end;

    Players.PlayerAdded:Connect(OnPlayerChange);
    Players.PlayerRemoving:Connect(OnPlayerChange);

    getgenv().Library = Library

    local httpService = game:GetService('HttpService')

    local SaveManager = {} do
        SaveManager.Folder = 'LinoriaLibSettings'
        SaveManager.Ignore = {}
        SaveManager.Parser = {
            Toggle = {
                Save = function(idx, object) 
                    return { type = 'Toggle', idx = idx, value = object.Value } 
                end,
                Load = function(idx, data)
                    if Toggles[idx] then 
                        Toggles[idx]:SetValue(data.value)
                    end
                end,
            },
            Slider = {
                Save = function(idx, object)
                    return { type = 'Slider', idx = idx, value = tostring(object.Value) }
                end,
                Load = function(idx, data)
                    if Options[idx] then 
                        Options[idx]:SetValue(data.value)
                    end
                end,
            },
            Dropdown = {
                Save = function(idx, object)
                    return { type = 'Dropdown', idx = idx, value = object.Value, mutli = object.Multi }
                end,
                Load = function(idx, data)
                    if Options[idx] then 
                        Options[idx]:SetValue(data.value)
                    end
                end,
            },
            ColorPicker = {
                Save = function(idx, object)
                    return { type = 'ColorPicker', idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
                end,
                Load = function(idx, data)
                    if Options[idx] then 
                        Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
                    end
                end,
            },
            KeyPicker = {
                Save = function(idx, object)
                    return { type = 'KeyPicker', idx = idx, mode = object.Mode, key = object.Value }
                end,
                Load = function(idx, data)
                    if Options[idx] then 
                        Options[idx]:SetValue({ data.key, data.mode })
                    end
                end,
            },

            Input = {
                Save = function(idx, object)
                    return { type = 'Input', idx = idx, text = object.Value }
                end,
                Load = function(idx, data)
                    if Options[idx] and type(data.text) == 'string' then
                        Options[idx]:SetValue(data.text)
                    end
                end,
            },
        }

        function SaveManager:SetIgnoreIndexes(list)
            for _, key in next, list do
                self.Ignore[key] = true
            end
        end

        function SaveManager:SetFolder(folder)
            self.Folder = folder;
            self:BuildFolderTree()
        end

        function SaveManager:Save(name)
            if (not name) then
                return false, 'no config file is selected'
            end

            local fullPath = self.Folder .. '/settings/' .. name .. '.json'

            local data = {
                objects = {}
            }

            for idx, toggle in next, Toggles do
                if self.Ignore[idx] then continue end

                table.insert(data.objects, self.Parser[toggle.Type].Save(idx, toggle))
            end

            for idx, option in next, Options do
                if not self.Parser[option.Type] then continue end
                if self.Ignore[idx] then continue end

                table.insert(data.objects, self.Parser[option.Type].Save(idx, option))
            end	

            local success, encoded = pcall(httpService.JSONEncode, httpService, data)
            if not success then
                return false, 'failed to encode data'
            end

            writefile(fullPath, encoded)
            return true
        end

        function SaveManager:Load(name)
            if (not name) then
                return false, 'no config file is selected'
            end
            
            local file = self.Folder .. '/settings/' .. name .. '.json'
            if not isfile(file) then return false, 'invalid file' end

            local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
            if not success then return false, 'decode error' end

            for _, option in next, decoded.objects do
                if self.Parser[option.type] then
                    task.spawn(function() self.Parser[option.type].Load(option.idx, option) end) -- task.spawn() so the config loading wont get stuck.
                end
            end

            return true
        end

        function SaveManager:IgnoreThemeSettings()
            self:SetIgnoreIndexes({ 
                "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", -- themes
                "ThemeManager_ThemeList", 'ThemeManager_CustomThemeList', 'ThemeManager_CustomThemeName', -- themes
            })
        end

        function SaveManager:BuildFolderTree()
            local paths = {
                self.Folder,
                self.Folder .. '/themes',
                self.Folder .. '/settings'
            }

            for i = 1, #paths do
                local str = paths[i]
                if not isfolder(str) then
                    makefolder(str)
                end
            end
        end

        function SaveManager:RefreshConfigList()
            local list = listfiles(self.Folder .. '/settings')

            local out = {}
            for i = 1, #list do
                local file = list[i]
                if file:sub(-5) == '.json' then
                    -- i hate this but it has to be done ...

                    local pos = file:find('.json', 1, true)
                    local start = pos

                    local char = file:sub(pos, pos)
                    while char ~= '/' and char ~= '\\' and char ~= '' do
                        pos = pos - 1
                        char = file:sub(pos, pos)
                    end

                    if char == '/' or char == '\\' then
                        table.insert(out, file:sub(pos + 1, start - 1))
                    end
                end
            end
            
            return out
        end

        function SaveManager:SetLibrary(library)
            self.Library = library
        end

        function SaveManager:LoadAutoloadConfig()
            if isfile(self.Folder .. '/settings/autoload.txt') then
                local name = readfile(self.Folder .. '/settings/autoload.txt')

                local success, err = self:Load(name)
                if not success then
                    return self.Library:Notify('Failed to load autoload config: ' .. err)
                end
            end
        end

        function SaveManager:BuildConfigSection(tab)
            assert(self.Library, 'Must set SaveManager.Library')

            local section = tab:AddRightGroupbox('Configuration')

            section:AddInput('SaveManager_ConfigName',    { Text = 'Config name' })
            section:AddDropdown('SaveManager_ConfigList', { Text = 'Config list', Values = self:RefreshConfigList(), AllowNull = true })

            section:AddDivider()

            section:AddButton('Save config', function()
                local name = Options.SaveManager_ConfigList.Value

                local success, err = self:Save(name)
                if not success then
                    return self.Library:Notify('Failed to save config: ' .. err)
                end

                self.Library:Notify(string.format('Overwrote config %q', name))
            end):AddButton('Load config', function()
                local name = Options.SaveManager_ConfigList.Value

                local success, err = self:Load(name)
                if not success then
                    return self.Library:Notify('Failed to load config: ' .. err)
                end

                self.Library:Notify(string.format('Loaded config %q', name))
            end)

            section:AddButton('Create config', function()
                local name = Options.SaveManager_ConfigName.Value

                if name:gsub(' ', '') == '' then 
                    return self.Library:Notify('Invalid config name (empty)', 2)
                end

                local success, err = self:Save(name)
                if not success then
                    return self.Library:Notify('Failed to save config: ' .. err)
                end

                self.Library:Notify(string.format('Created config %q', name))

                Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
                Options.SaveManager_ConfigList:SetValue(nil)
            end)

            section:AddButton('Refresh list', function()
                Options.SaveManager_ConfigList:SetValues(self:RefreshConfigList())
                Options.SaveManager_ConfigList:SetValue(nil)
            end)

            section:AddButton('Set as autoload', function()
                local name = Options.SaveManager_ConfigList.Value
                writefile(self.Folder .. '/settings/autoload.txt', name)
                SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
                self.Library:Notify(string.format('Set %q to auto load', name))
            end)

            SaveManager.AutoloadLabel = section:AddLabel('Current autoload config: none', true)

            if isfile(self.Folder .. '/settings/autoload.txt') then
                local name = readfile(self.Folder .. '/settings/autoload.txt')
                SaveManager.AutoloadLabel:SetText('Current autoload config: ' .. name)
            end

            SaveManager:SetIgnoreIndexes({ 'SaveManager_ConfigList', 'SaveManager_ConfigName' })
        end

        SaveManager:BuildFolderTree()
    end
--

-- Renderer
    local Renderer = {DrawList = {}}

    function Renderer:FindExistingShape(name)
        local Shape = self.DrawList[name]
        if Shape then
            return Shape
        else
            return nil
        end
    end

    function Renderer:Unrender(name_table)
        for _, v in pairs(name_table) do
            local Shape = self:FindExistingShape(v)
        
            if Shape then
                Shape.Visible = false
                Shape:Remove()
            end

            self.DrawList[v] = nil
        end
    end

    function Renderer:UnrenderAll()
        for Name, Shape in pairs(self.DrawList) do
            if Shape then
                Shape.Visible = false
                Shape:Remove()
            end

            self.DrawList[v] = nil
        end
    end

    function Renderer:UnrenderAllExcept(exclude_table)
        for Name, Shape in pairs(self.DrawList) do
            local ShouldContinue = false

            for _, Exclude in pairs(exclude_table) do
                if Exclude == Name then
                    ShouldContinue = true
                    break
                end
            end

            if ShouldContinue then
                ShouldContinue = false
                continue
            end

            if Shape then
                Shape.Visible = false
                Shape:Remove()
            end
    
            self.DrawList[Name] = nil
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
            
            self.DrawList[name] = Shape
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
            Shape.Filled = true
        else
            Shape = Drawing.new("Square")
            Shape.Visible = true
            Shape.Position = position
            Shape.Size = size
            Shape.Color = color
            Shape.Transparency = 1
            Shape.Filled = true

            self.DrawList[name] = Shape
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
            
            self.DrawList[name] = Shape
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
            Shape.Filled = true
        else
            Shape = Drawing.new("Circle")
            Shape.Visible = true
            Shape.Position = position
            Shape.Radius = radius
            Shape.Color = color
            Shape.Transparency = 1
            Shape.Filled = true
            
            self.DrawList[name] = Shape
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
            
            self.DrawList[name] = Shape
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
            
            self.DrawList[name] = Shape
        end
        
        return Shape
    end
--

-- Get Services
    local Teams = game:GetService('Teams')
    local Debris = game:GetService("Debris")
    local Players = game:GetService("Players")
    local Lighting = game:GetService("Lighting")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local HttpService = game:GetService("HttpService")
    local NetworkClient = game:GetService("NetworkClient")
    local TeleportService = game:GetService("TeleportService")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local MarketPlaceService = game:GetService("MarketplaceService")
    local VirtualInputManager = game:GetService("VirtualInputManager")
--

-- Get/Create Game Vars
    local Enviornment = getgenv()
    local Camera = Workspace.CurrentCamera
    local Base64Encode = base64encode
    local Base64Decode = base64decode
    local ColorRGB = Color3.fromRGB
    local ColorHSV = Color3.fromHSV
    local ColorHex = Color3.fromHex
    local Vec2 = Vector2.new
    local Vec3 = Vector3.new
--

--[[ Get Phantom Force modules (Stolen from moonlight because this is so minimalistic)
    local Modules = {Stored = {}}

    for _,instance in next, getnilinstances() do
        set_thread_identity(8)
        
        if not instance then
            continue
        end
        
        if not instance:IsA("ModuleScript") then
            continue
        end

        local Required = nil

        pcall(function()
            Required = require(instance)
        end)

        if not Required then
            continue
        end

        Modules.Stored[instance.Name] = Required
    end

    for _,instance in next, getloadedmodules() do
        set_thread_identity(8)

        if Modules.Stored[instance.Name] then
            continue
        end

        local Required = nil

        pcall(function()
            Required = require(instance)
        end)

        if not Required then
            continue
        end

        Modules.Stored[instance.Name] = Required
    end

    function Modules:GetFromProp(prop)
        local Module = nil
        for _,v in next, Modules.Stored do
                if type(v) == "table" and rawget(v, prop) then
                warn(_, v, prop)
                table.foreach(v, print)

                Module = v
            end
        end

        return Module
    end

    function Modules:Get(name)   
        return Modules.Stored[name] or nil
    end

    local RoundSystemClientInterface = Modules:GetFromProp("RoundSystemClientInterface")
    local WeaponControllerInterface = Modules:GetFromProp("WeaponControllerInterface")
    local PlayerDataClientInterface = Modules:GetFromProp("PlayerDataClientInterface")
    local HudCrosshairsInterface = Modules:GetFromProp("HudCrosshairsInterface") 
    local LeaderboardInterface = Modules:GetFromProp("LeaderboardInterface")
    local ReplicationInterface = Modules:GetFromProp("ReplicationInterface")
    local CharacterInterface = Modules:GetFromProp("CharacterInterface")
    local ActiveLoadoutUtils = Modules:GetFromProp("ActiveLoadoutUtils")
    local PlayerStatusEvents = Modules:GetFromProp("PlayerStatusEvents")
    local ReplicationObject = Modules:GetFromProp("ReplicationObject")
    local ThirdPersonObject = Modules:GetFromProp("ThirdPersonObject")
    local ContentDatabase = Modules:GetFromProp("ContentDatabase")
    local BulletInterface = Modules:GetFromProp("BulletInterface")
    local CharacterObject = Modules:GetFromProp("CharacterObject")
    local CameraInterface = Modules:GetFromProp("CameraInterface")
    local CameraObject = Modules:GetFromProp("MainCameraObject")
    local PublicSettings = Modules:GetFromProp("PublicSettings")
    local FirearmObject = Modules:GetFromProp("FirearmObject")
    local NetworkClient = Modules:GetFromProp("NetworkClient")
    local BulletObject = Modules:GetFromProp("BulletObject")
    local MeleeObject = Modules:GetFromProp("MeleeObject")
    local BulletCheck = Modules:GetFromProp("BulletCheck")
    local GameClock = Modules:GetFromProp("GameClock")
    local Physics = Modules:GetFromProp("PhysicsLib")
    local Sound = Modules:GetFromProp("AudioSystem")
    local Effects = Modules:GetFromProp("Effects")
--]]

-- Custom functions
    -- https://devforum.roblox.com/t/tutorial-check-if-an-object-has-property/1213998
    function ObjectHasProperty(object, propertyName)
        local success, _ = pcall(function() 
            object[propertyName] = object[propertyName]
        end)
        return success
    end

    local function GetTableKeys(tbl)
        local keyset = {}
        for k in pairs(tbl) do
            table.insert(keyset, k)
        end
        return keyset
    end

    function RoundDecimal(num, DecimalPlaces)
        return tonumber(string.format("%." .. (DecimalPlaces or 0) .. "f", num))
    end

    function RoundVec3(Vector, DecimalPlaces)
        return Vec3(RoundDecimal(Vector.X, 1), RoundDecimal(Vector.Y, 1), RoundDecimal(Vector.Z, 1))
    end
--

-- Config/Stored menu variables
    local Config = {
        Ragebot = {
            General = {
                Enabled = false,
                FieldOfViewMode = 'Circle', -- {'Circle', 'Angle'}
                FieldOfView = 180,
                MaxDistance = 400,

                TargetSelection = 'Crosshair', -- {'Crosshair', 'Distance', 'Health', 'Damage'}

                AutoWall = false,
                Autofire = false,
        
                Hitboxes = {} -- {'Head', 'Torso', 'LeftArm', 'RightArm', 'LeftLeg', 'RightLeg'}
            },

            Other = {}
        },

        Antiaim = {
            General = {
                Enabled = false,
            },

            FakeLag = {
                
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
                    Material = 'ForceField' -- Storage.PartMaterials
                },

                ArmChams = {
                    Enabled = false,
                    Color = Redacted.Accent,

                    Material = 'ForceField' -- Storage.PartMaterials
                }
            },

            World = {
                OverrideTechnology = 'Compatibility',
                OverrideWorldMaterials = 'Default',

                OverrideClockTime = {
                    Enabled = false,
                    Value = 12
                },

                OverrideStarsCount = {
                    Enabled = false,
                    Value = 5000
                },
            
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
--

-- Saved/Stored data, Used for mostly everything in our script requiring resetable data.
local Storage = {
    PenetrationDepth = {['AK12'] = 1.00,['AN-94'] = 1.00,['REMINGTON700'] = 3.00,['ASVAL'] = 1.00,['SCAR-L'] = 1.00,['AUGA1'] = 1.00,['M16A4'] = 1.10,['G36'] = 1.30,['M16A1'] = 0.80,['M16A3'] = 1.10,['TYPE20'] = 1.40,['AUGA2'] = 1.00,['K2'] = 1.00,['FAMASF1'] = 1.00,['AK47'] = 1.40,['AKM'] = 1.40,['AK103'] = 1.40,['TAR-21'] = 1.20,['TYPE88'] = 0.90,['M231'] = 1.00,['C7A2'] = 0.90,['STG-44'] = 1.60,['G11K2'] = 2.00,['M14'] = 1.80,['BEOWULFECR'] = 1.90,['SCAR-H'] = 1.50,['AK12BR'] = 2.00,['G3A3'] = 1.50,['AG-3'] = 2.00,['HK417'] = 1.60,['HENRY45-70'] = 2.00,['FAL50.00'] = 2.00,['HCAR'] = 2.20,['M4A1'] = 1.00,['G36K'] = 1.10,['M4'] = 1.00,['L22'] = 0.90,['SCARPDW'] = 0.90,['AKU12'] = 1.00,['GROZA-1'] = 1.50,['OTS-126'] = 1.20,['AK12C'] = 1.20,['HONEYBADGER'] = 1.30,['K1A'] = 0.75,['SR-3M'] = 1.00,['GROZA-4'] = 1.50,['MC51'] = 1.50,['FAL50.63PARA'] = 2.00,['1858CARBINE'] = 0.50,['AK105'] = 1.00,['JURY'] = 1.00,['KACSRR'] = 1.00,['GYROJETCARBINE'] = 0.70,['C8A2'] = 0.80,['X95R'] = 1.00,['HK51B'] = 1.90,['CANCANNON'] = 1.20,['KSG12'] = 0.40,['MODEL870'] = 0.50,['DBV12'] = 0.50,['KS-23M'] = 0.70,['SAIGA-12'] = 0.50,['STEVENSDB'] = 0.50,['E-GUN'] = 0.50,['AA-12'] = 0.30,['SPAS-12'] = 0.60,['DT11'] = 0.70,['USAS-12'] = 0.30,['MK11'] = 1.70,['SKS'] = 1.50,['SL-8'] = 1.30,['DRAGUNOVSVU'] = 2.80,['VSSVINTOREZ'] = 1.50,['MSG90'] = 2.00,['M21'] = 2.40,['BEOWULFTCR'] = 3.00,['SA58SPR'] = 2.00,['SCARSSR'] = 2.60,['COLTLMG'] = 1.40,['M60'] = 2.20,['AUGHBAR'] = 1.60,['MG36'] = 1.80,['RPK12'] = 1.60,['L86LSW'] = 1.60,['RPK'] = 1.60,['HK21E'] = 1.60,['HAMRIAR'] = 1.40,['RPK74'] = 1.20,['MG3KWS'] = 1.80,['M1918A2'] = 2.20,['MGV-176'] = 0.50,['STONER96'] = 1.20,['CHAINSAW'] = 1.20,['MG42'] = 2.00,['INTERVENTION'] = 4.00,['MODEL700'] = 3.00,['AWS'] = 2.00,['BFG50'] = 10.00,['AWM'] = 3.00,['TRG-42'] = 3.00,['MOSINNAGANT'] = 3.50,['DRAGUNOVSVDS'] = 3.20,['M1903'] = 3.80,['K14'] = 3.00,['HECATEII'] = 10.00,['FT300'] = 3.00,['M107'] = 5.00,['STEYRSCOUT'] = 3.00,['WA2000'] = 2.80,['NTW-20'] = 20.00,['M9'] = 0.50,['G17'] = 0.50,['M1911A1'] = 0.50,['M17'] = 0.50,['DESERTEAGLEL5'] = 1.00,['G21'] = 0.50,['G23'] = 0.60,['M45A1'] = 0.50,['G40'] = 0.80,['KG-99'] = 0.50,['G50'] = 1.00,['FIVESEVEN'] = 1.20,['ZIP22'] = 0.50,['GIM1'] = 1.00,['HARDBALLER'] = 0.80,['IZHEVSKPB'] = 0.50,['MAKAROVPM'] = 0.50,['GB-22'] = 0.50,['DESERTEAGLEXIX'] = 1.30,['AUTOMAGIII'] = 1.20,['GYROJETMARKI'] = 0.50,['GSP'] = 0.10,['GRIZZLY'] = 1.30,['M2011'] = 0.50,['ALIEN'] = 0.50,['AF2011-A1'] = 0.50,['G18C'] = 0.50,['93R'] = 0.50,['PP-2000'] = 1.00,['TEC-9'] = 0.50,['MICROUZI'] = 0.50,['ŠKORPIONVZ.61'] = 0.50,['ASMI'] = 0.50,['MP1911'] = 0.50,['ARMPISTOL'] = 0.90,['MP412REX'] = 0.50,['MATEBA6'] = 1.00,['1858NEWARMY'] = 0.50,['REDHAWK44'] = 1.00,['JUDGE'] = 1.00,['EXECUTIONER'] = 1.00,['SUPERSHORTY'] = 0.60,['SFG50'] = 10.00,['M79THUMPER'] = 0.50,['COILGUN'] = 0.50,['SAWEDOFF'] = 0.60,['SAIGA-12U'] = 0.40,['OBREZ'] = 2.00,['SASS308'] = 2.00,['GLOCK17'] = 0.50},
    WeaponVelocity  =  {['AK12'] = 2950.00,['REMINGTON700'] = 2650,['AN-94'] = 2950.00 ,['ASVAL'] = 1500.00 ,['SCAR-L'] = 2300.00 ,['AUGA1'] = 3200.00 ,['M16A4'] = 2700.00 ,['G36'] = 2700.00 ,['M16A1'] = 3100.00 ,['M16A3'] = 2700.00 ,['TYPE20'] = 2625.00 ,['AUGA2'] = 3200.00 ,['K2'] = 2400.00 ,['FAMASF1'] = 3100.00 ,['AK47'] = 2350.00 ,['AUGA3'] = 3200.00,['L85A2'] = 2500.00,['HK416'] = 2500.00,['AK74'] = 2900.00,['AKM'] = 2350.00,['AK103'] = 2350.00,['TAR-21'] = 2800.00,['TYPE88'] = 2950.00,['M231'] = 2200.00,['C7A2'] = 2800.00,['STG-44'] = 2250.00,['G11K2'] = 3100.00,['M14'] = 2550.00,['BEOWULFECR'] = 1800.00,['SCAR-H'] = 2900.00,['AK12BR'] = 2700.00,['G3A3'] = 2600.00,['AG-3'] = 2600.00,['HK417'] = 2500.00,['HENRY45-70'] = 1800.00,['FAL50.00'] = 2750.00,['HCAR'] = 2500.00,['M4A1'] = 2200.00,['G36K'] = 2500.00,['M4'] = 2200.00,['L22'] = 2000.00,['SCARPDW'] = 2200.00,['AKU12'] = 2550.00,['GROZA-1'] = 2400.00,['OTS-126'] = 2300.00,['AK12C'] = 2150.00,['HONEYBADGER'] = 2000.00,['K1A'] = 1700.00,['SR-3M'] = 2000.00,['GROZA-4'] = 1200.00,['MC51'] = 2000.00,['FAL50.63PARA'] = 2200.00,['1858CARBINE'] = 1500.00,['AK105'] = 2800.00,['JURY'] = 1500.00,['KACSRR'] = 1500.00,['GYROJETCARBINE'] = 50.00,['C8A2'] = 2400.00,['X95R'] = 2200.00,['HK51B'] = 2200.00,['CANCANNON'] = 1000.00,['KSG12'] = 1500.00,['MODEL870'] = 1500.00,['DBV12'] = 1500.00,['KS-23M'] = 1500.00,['SAIGA-12'] = 1500.00,['STEVENSDB'] = 1600.00,['E-GUN'] = 950.00,['AA-12'] = 1500.00,['SPAS-12'] = 1500.00,['DT11'] = 2000.00,['USAS-12'] = 1300.00,['MP5K'] = 1200.00,['UMP45'] = 870.00,['G36C'] = 2300.00,['MP7'] = 2400.00,['MAC10'] = 920.00,['P90'] = 2350.00,['COLTMARS'] = 2600.00,['MP5'] = 1300.00,['COLTSMG633'] = 1300.00,['L2A3'] = 1280.00,['MP5SD'] = 1050.00,['MP10'] = 1300.00,['M3A1'] = 900.00,['MP5/10'] = 1400.00,['UZI'] = 1300.00,['AUGA3PARAXS'] = 1200.00,['K7'] = 1300.00,['AKS74U'] = 2400.00,['PPSH-41'] = 1600.00,['FALPARASHORTY'] = 2000.00,['KRISSVECTOR'] = 960.00,['PP-19BIZON'] = 1250.00,['MP40'] = 1310.00,['X95SMG'] = 1300.00,['TOMMYGUN'] = 935.00,['RAMA1130'] = 1300.00,['BWC9A'] = 1300.00,['FIVE-0'] = 1200.00,['MK11'] = 2800.00,['SKS'] = 2500.00,['SL-8'] = 2800.00,['DRAGUNOVSVU'] = 2700.00,['VSSVINTOREZ'] = 2000.00,['MSG90'] = 2800.00,['M21'] = 2650.00,['BEOWULFTCR'] = 1800.00,['SA58SPR'] = 2500.00,['SCARSSR'] = 3000.00,['COLTLMG'] = 2500.00,['M60'] = 2800.00,['AUGHBAR'] = 3300.00,['MG36'] = 2700.00,['RPK12'] = 3100.00,['L86LSW'] = 3100.00,['RPK'] = 2450.00,['HK21E'] = 2600.00,['HAMRIAR'] = 2600.00,['RPK74'] = 3150.00,['MG3KWS'] = 2700.00,['M1918A2'] = 2800.00,['MGV-176'] = 1550.00,['STONER96'] = 3000.00,['CHAINSAW'] = 3000.00,['MG42'] = 2400.00,['INTERVENTION'] = 3000.00,['MODEL700'] = 2650.00,['AWS'] = 2500.00,['BFG50'] = 3000.00,['AWM'] = 3000.00,['TRG-42'] = 3000.00,['MOSINNAGANT'] = 3000.00,['DRAGUNOVSVDS'] = 2650.00,['M1903'] = 3000.00,['K14'] = 2800.00,['HECATEII'] = 3000.00,['FT300'] = 2800.00,['M107'] = 2800.00,['STEYRSCOUT'] = 3000.00,['WA2000'] = 2850.00,['NTW-20'] = 2400.00,['M9'] = 1300.00,['G17'] = 1230.00,['M1911A1'] = 830.00,['M17'] = 1200.00,['DESERTEAGLEL5'] = 1700.00,['G21'] = 810.00,['G23'] = 1025.00,['M45A1'] = 830.00,['G40'] = 1350.00,['KG-99'] = 1500.00,['G50'] = 1250.00,['FIVESEVEN'] = 2500.00,['ZIP22'] = 1600.00,['GIM1'] = 875.00,['HARDBALLER'] = 1400.00,['IZHEVSKPB'] = 950.00,['MAKAROVPM'] = 1030.00,['GB-22'] = 1900.00,['DESERTEAGLEXIX'] = 1425.00,['AUTOMAGIII'] = 1700.00,['GYROJETMARKI'] = 25.00,['GSP'] = 1800.00,['GRIZZLY'] = 1500.00,['M2011'] = 1300.00,['ALIEN'] = 1300.00,['AF2011-A1'] = 1250.00,['G18C'] = 1230.00,['93R'] = 1200.00,['PP-2000'] = 2000.00,['TEC-9'] = 1180.00,['MICROUZI'] = 2000.00,['ŠKORPIONVZ.61'] = 1200.00,['ASMI'] = 1260.00,['MP1911'] = 830.00,['ARMPISTOL'] = 2300.00,['MP412REX'] = 1700.00,['MATEBA6'] = 1450.00,['1858NEWARMY'] = 1000.00,['REDHAWK44'] = 1600.00,['JUDGE'] = 2000.00,['EXECUTIONER'] = 2000.00,['SUPERSHORTY'] = 1400.00,['SFG50'] = 2000.00,['M79THUMPER'] = 900.00,['COILGUN'] = 950.00,['SAWEDOFF'] = 1300.00,['SAIGA-12U'] = 1400.00,['OBREZ'] = 1500.00,['SASS308'] = 3000.00,['GLOCK17'] = 1230.00},

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
        },
        ["Dababy"] = {
            ["SkyboxBk"] = "rbxassetid://6083995041",
            ["SkyboxDn"] = "rbxassetid://6083995041",
            ["SkyboxFt"] = "rbxassetid://6083995041",
            ["SkyboxLf"] = "rbxassetid://6083995041",
            ["SkyboxRt"] = "rbxassetid://6083995041",
            ["SkyboxUp"] = "rbxassetid://6083995041"
        },
        ["Minecraft"] = {
            ["SkyboxBk"] = "rbxassetid://1876545003",
            ["SkyboxDn"] = "rbxassetid://1876544331",
            ["SkyboxFt"] = "rbxassetid://1876542941",
            ["SkyboxLf"] = "rbxassetid://1876543392",
            ["SkyboxRt"] = "rbxassetid://1876543764",
            ["SkyboxUp"] = "rbxassetid://1876544642"
        },
        ["Deep Space Cluster"] = {
            ["MoonTextureId"] = "rbxassetid://6444320592",
            ["SkyboxBk"]      = "rbxassetid://6444884337",
            ["SkyboxDn"]      = "rbxassetid://6444884785",
            ["SkyboxFt"]      = "rbxassetid://6444884337",
            ["SkyboxLf"]      = "rbxassetid://6444884337",
            ["SkyboxRt"]      = "rbxassetid://6444884337",
            ["SkyboxUp"]      = "rbxassetid://6412503613"
        },
        ["Oblivion Lost"] = {
            ["MoonTextureId"] = "rbxasset://sky/moon.jpg",
            ["SkyboxBk"]      = "rbxassetid://5103110171",
            ["SkyboxDn"]      = "rbxassetid://5102993828",
            ["SkyboxFt"]      = "rbxassetid://5103111020",
            ["SkyboxLf"]      = "rbxassetid://5103112417",
            ["SkyboxRt"]      = "rbxassetid://5103113734",
            ["SkyboxUp"]      = "rbxassetid://5102993828"
        }
    },

    MapMaterials = {
        ['Minecraft'] = {
            ['Wood'] = 3258599312,
            ['WoodPlanks'] = 8676581022,
            ['Brick'] = 8558400252,
            ['Cobblestone'] = 5003953441,
            ['Concrete'] = 7341687607,
            ['DiamondPlate'] = 6849247561,
            ['Fabric'] = 118776397,
            ['Granite'] = 4722586771,
            ['Grass'] = 4722588177,
            ['Ice'] = 3823766459,
            ['Marble'] = 62967586,
            ['Metal'] = 62967586,
            ['Sand'] = 152572215
        }
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

    HitboxMeshIds = {
        ["Head"] = "rbxassetid://6179256256",
        ["Torso"] = "rbxassetid://4049240078",
        ["Legs"] = "rbxassetid://4049240209",
        ["Arms"] = "rbxassetid://4049240323"
    },

    ScreenSize = Camera.ViewportSize,

    WorldAmbientsOriginal = nil,
    SkyboxOriginal = {},
    WorldOriginal = {},
    ArmsOriginal = {},
    GunOriginal = {},

    NextRagebotShot = tick(),
    TargetWithinFOV = false,
    AutoFireClick = false,
    AimbotFiring = false
}

-- UI/Menu Creation
    local Window = Library:CreateWindow({
        Title = 'Redacted-project ( ' .. Redacted.Username .. ", " .. Redacted.Build .. ' )',
        Center = true, AutoShow = true, TabPadding = 5, MenuFadeTime = 0.2
    })

    local Tabs = {
        Ragebot = Window:AddTab('Ragebot'),
        Antiaim = Window:AddTab('Anti-aim'),
        Visuals = Window:AddTab('Visuals'),
        Misc = Window:AddTab('Miscellaneous'),
        Settings = Window:AddTab('Settings')
    }

    local Groups = {
        Ragebot = {
            General = Tabs.Ragebot:AddLeftGroupbox('General'),
            Other = Tabs.Ragebot:AddRightGroupbox('Other')
        },

        Antiaim = {
            General = Tabs.Antiaim:AddLeftGroupbox('General'),
            Fakelag = Tabs.Antiaim:AddRightGroupbox('Fakelag'),
            Other = Tabs.Antiaim:AddRightGroupbox('Other')
        },

        Visuals = {
            Players = Tabs.Visuals:AddLeftGroupbox('Players'),
            World = Tabs.Visuals:AddRightGroupbox('World'),

            Throwables = Tabs.Visuals:AddLeftGroupbox('Throwables'),
            Other = Tabs.Visuals:AddRightGroupbox('Other')
        },

        Misc = {
            Movement = Tabs.Misc:AddLeftGroupbox('Movement'),
            Other = Tabs.Misc:AddRightGroupbox('Other')
        },

        Settings = {
            Menu = Tabs.Settings:AddLeftGroupbox(OverrideUserSettings and 'Menu / Developer' or 'Menu')
            -- 'Configuration' Is added later on by the SaveManager.
        }
    }

    -- UI -> Ragebot -> General [BROKEN AS OF 4TH OF JULY UPDATE, WORKING ON RECODE]
    Groups.Ragebot.General:AddToggle('RagebotEnabled', {
        Text = 'Aimbot', Tooltip = nil,
        Default = false,

        Callback = function(Value)
            Config.Ragebot.General.Enabled = Value
        end
    })

    Groups.Ragebot.General:AddDropdown('RagebotFieldOfViewMode', {
        Text = 'Field of view mode', Tooltip = nil,

        Values = {'Circle', 'Angle'},
        Multi = false,
        Default = 2,

        Callback = function(Value)
            Config.Ragebot.General.FieldOfViewMode = Value
        end
    })

    Groups.Ragebot.General:AddSlider('RagebotFieldOfView', {
        Text = 'Field of view', Tooltip = 'Maximum angle the aimbot is allowed for activation',

        Default = 360, Min = 0, Max = 360, Rounding = 1,
        Compact = false,

        Callback = function(Value)
            Config.Ragebot.General.FieldOfView = Value
        end
    })

    Groups.Ragebot.General:AddSlider('RagebotMaxDistance', {
        Text = 'Maximum distance', Tooltip = 'Maximum distance the aimbot is allowed for activation',

        Default = 200, Min = 0, Max = 1000, Rounding = 1,
        Compact = false,

        Callback = function(Value)
            Config.Ragebot.General.MaxDistance = Value
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

    --[[Groups.Ragebot.General:AddToggle('RagebotAutoWall', {
        Text = 'Auto wall', Tooltip = nil,
        Default = false,

        Callback = function(Value)
            Config.Ragebot.General.AutoWall = Value
        end
    })]]

    Groups.Ragebot.General:AddToggle('RagebotAutoShoot', {
        Text = 'Auto shoot', Tooltip = nil,
        Default = false,

        Callback = function(Value)
            Config.Ragebot.General.AutoFire = Value
        end
    })

    Groups.Ragebot.General:AddDropdown('RagebotHitboxes', {
        Text = 'Hitboxes', Tooltip = 'Which hitboxes the aimbot will target',

        Values = {'Head', 'Torso', 'Arms', 'Legs'},
        Multi = true,
        Default = 0,

        Callback = function(Value)
            Config.Ragebot.General.Hitboxes = Value
        end
    })

    -- UI -> Antiaim -> General
    Groups.Antiaim.General:AddToggle('AntiAimEnabled', {
        Text = 'Enabled',
        Tooltip = nil,

        Default = false,

        Callback = function(Value)
            Config.Antiaim.General.Enabled = Value
        end
    })

    -- UI -> Antiaim -> Fakelag
    --[[Groups.Antiaim.Fakelag:AddToggle('Fakelag', {
        Text = 'Enabled ( experimental! )',
        Tooltip = nil,

        Default = false,

        Callback = function(Value)
            Config.Antiaim.FakeLag.Enabled = Value
        end
    })

    Groups.Antiaim.Fakelag:AddSlider('FakelagMinDistance', {
        Text = 'Minimum range',
        Tooltip = nil,

        Default = 20, 
        Min = 1, 
        Max = 40,

        Rounding = 1,
        Compact = false,

        Callback = function(Value)
            Config.Antiaim.FakeLag.MinDistance = Value
        end
    })

    Groups.Antiaim.Fakelag:AddSlider('FakelagMaxDistance', {
        Text = 'Maximum range',
        Tooltip = nil,

        Default = 30, 
        Min = 1, 
        Max = 40,

        Rounding = 1,
        Compact = false,

        Callback = function(Value)
            Config.Antiaim.FakeLag.MaxDistance = Value
        end
    })]]

    -- UI -> Visuals -> Players
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

        Callback = function(Value, Transparency)
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
        Default = 'ForceField',

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
        Default = 'ForceField',

        Callback = function(Value)
            Config.Visuals.Players.ArmChams.Material = Value
        end
    })

    -- UI -> Visuals -> World
    Groups.Visuals.World:AddDropdown('OverrideTechnology', {
        Text = 'Override lighting', Tooltip = nil,

        Values = {'Compatibility', 'Future', 'Legacy', 'ShadowMap', 'Voxel'},
        Multi = false,
        Default = 'Compatibility',

        Callback = function(Value)
            Config.Visuals.World.OverrideTechnology = Value
        end
    })

    Groups.Visuals.World:AddDropdown('OverrideWorldMaterials', {
        Text = 'Override world materials', Tooltip = nil,

        Values = {'Default', 'Minecraft'},
        Multi = false,
        Default = 'Default',

        Callback = function(Value)
            Config.Visuals.World.OverrideWorldMaterials = Value
        end
    })

    Groups.Visuals.World:AddToggle('OverrideClockTime', {
        Text = 'Override ClockTime', Tooltip = nil,
        Default = false,

        Callback = function(Value)
            Config.Visuals.World.OverrideClockTime.Enabled = Value
        end
    })

    Groups.Visuals.World:AddSlider('OverrideClockTimeValue', {
        Text = '', Tooltip = nil,

        Default = 12,  Min = 0,  Max = 24, Rounding = 1,
        Compact = true,

        Callback = function(Value)
            Config.Visuals.World.OverrideClockTime.Value = Value
        end
    })

    Groups.Visuals.World:AddToggle('OverrideStarsCount', {
        Text = 'Override stars amount', Tooltip = nil,
        Default = false,

        Callback = function(Value)
            Config.Visuals.World.OverrideStarsCount.Enabled = Value
        end
    })

    Groups.Visuals.World:AddSlider('StarsCountValue', {
        Text = '', Tooltip = nil,

        Default = 5000,  Min = 0,  Max = 10000, Rounding = 1,
        Compact = true,

        Callback = function(Value)
            Config.Visuals.World.OverrideStarsCount.Value = Value
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

    Groups.Visuals.World:AddDropdown('SkyboxChangerTexture', {
        Text = 'Skybox', Tooltip = nil,

        Values = GetTableKeys(Storage.Skyboxes),
        Multi = false,
        Default = 1,

        Callback = function(Value)
            Config.Visuals.World.SkyboxChanger.Value = Value
        end
    })

    -- UI -> Visuals -> Other
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

        Default = 50,  Min = 0,  Max = 50, Rounding = 1,
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

        Default = 50,  Min = 0,  Max = 50, Rounding = 1,
        Compact = false,

        Callback = function(Value)
            Config.Misc.Movement.SpeedHack.Value = Value
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

    Groups.Settings.Menu:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', {
        Text = 'Menu keybind',
        Default = 'Insert', 
        NoUI = true
    })

    Library.ToggleKeybind = Options.MenuKeybind

    if OverrideUserSettings then
        Groups.Settings.Menu:AddButton('Load DarkDex', function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
        end)
    end
--

-- Skip Misc->Configuration, Handled at EOF because of unload function.
-- Now lets get into the juicy part of this code mf, 1/2 of this was written while in a zaza induced coma, AND RN AHHH

-- Features -> Phantom Forces (Getters, Setters, etc)
    local PhantomForces = {}

    -- This is only used for pointing the muzzle torwards our ragebot target.
    function PhantomForces:MakeObjectLookAt(Model, HitboxPosition)
        for _, Part in ipairs(Model:GetChildren()) do
            if not Part then
                continue
            end

            -- SightMark detection: Part.Transparency > 0 and Part:FindFirstChildWhichIsA("SurfaceGui")
            -- Flame/FlameSUP detection: RoundVec3(Part.Size) == Vec3(0.2, 0.2, 0.2) and not Part:FindFirstChildWhichIsA("Weld")

            if not ((Part.Transparency > 0 and Part:FindFirstChildWhichIsA("SurfaceGui")) or (RoundVec3(Part.Size) == Vec3(0.2, 0.2, 0.2) and not Part:FindFirstChildWhichIsA("Weld"))) then 
                continue
            end

            local LookVector = (HitboxPosition - Part.Position).unit
            
            local yaw = math.atan2(-LookVector.X, -LookVector.Z)
            local pitch = math.asin(LookVector.Y)
            
            Part.Orientation = Vector3.new(math.deg(pitch), math.deg(yaw), 0)
        end
    end

    -- Returns the muzzle tip to our viewmodel weapon, bullets fire from this position so we use this for aimbot currently.
    function PhantomForces:GetMuzzleParts(Gun)
        local MuzzleParts

        for _, Part in ipairs(Model:GetChildren()) do
            if not Part then
                continue
            end

            local Joints = Part:GetJoints()
    
            if Joints ~= nil and #Joints > 0 then
                -- SightMark detection: Part.Transparency > 0 and Part:FindFirstChildWhichIsA("SurfaceGui")
                -- Flame/FlameSUP detection: RoundVec3(Part.Size) == Vec3(0.2, 0.2, 0.2) and not Part:FindFirstChildWhichIsA("Weld")

                if (RoundVec3(Part.Size) == Vec3(0.2, 0.2, 0.2) and not Part:FindFirstChildWhichIsA("Weld")) or (Part.Transparency > 0 and Part:FindFirstChildWhichIsA("SurfaceGui")) then 
                    table.insert(MuzzleParts, Part)
                end
            end
        end

        return MuzzleParts
    end

    -- Returns Phantom Forces custom player models, The name variable is string encrypted under everything so don't even bother changing this.
    function PhantomForces:GetPlayerModels()
        local PlayerList = {}

        for i,Teams in Workspace.Players:GetChildren() do
            for i, Players in Teams:GetChildren() do
                table.insert(PlayerList, Players)
            end
        end

        return PlayerList
    end

    -- @litozinnamon & @Shay yall should go kys, I hate doing this fucking retarded bs it makes the code look stupid. yall doing this didn't prevent SHITTTTTT.
    function PhantomForces:GetPlayerTeam(Player)
        local Helmet = Player:FindFirstChildWhichIsA("Folder"):FindFirstChildOfClass("MeshPart")
        
        if Helmet then
            if Helmet.BrickColor == BrickColor.new("Black") then
                return Teams.Phantoms
            else
                return Teams.Ghosts
            end
        end
    end

    function PhantomForces:FindPartByMeshId(Target, MeshId)
        for _, Child in ipairs(Target:GetChildren()) do
            local SpecialMesh = Child:FindFirstChildOfClass("SpecialMesh")

            if not (Child:IsA("BasePart") and SpecialMesh) then
                continue
            end

            if SpecialMesh.MeshId == MeshId then
                return Child
            end
        end

        return nil
    end

    function PhantomForces:GetPlayerPart(Target, PartName)
        for _, MeshId in pairs(Storage.HitboxMeshIds) do
            local Part = PhantomForces:FindPartByMeshId(Target, MeshId)

            if Part and Part:IsA("BasePart") and MeshId == Storage.HitboxMeshIds[PartName] then
                return Part
            end
        end

        return nil
    end

    function PhantomForces:GetPlayerParts(Target)
        local Hitboxes = {}

        for HitboxName, MeshId in pairs(Storage.HitboxMeshIds) do
            if Config.Ragebot.General.Hitboxes[HitboxName] then
                local Part = PhantomForces:FindPartByMeshId(Target, MeshId)

                if Part and Part:IsA("BasePart") then
                    Hitboxes[HitboxName] = Part
                end
            end
        end

        return Hitboxes
    end

    -- PhantomForces -> LocalPlayer -> ...
    PhantomForces.LocalPlayer = {}

    function PhantomForces.LocalPlayer:Get()
        for i, Child in pairs(Workspace.Ignore:GetChildren()) do
            if Child:IsA("Model") then
                return Child
            end
        end

        return nil
    end

    function PhantomForces.LocalPlayer:IsAlive()
        for i, Child in pairs(Workspace.Ignore:GetChildren()) do
            if Child:IsA("Model") then
                return true
            end
        end

        return false
    end

    function PhantomForces.LocalPlayer:GetArms()
        local ArmsModel = {}

        for i, Viewmodel in ipairs(Camera:GetChildren()) do
            if Viewmodel and Viewmodel:IsA("Model") and Viewmodel:FindFirstChild("Arm") then
                table.insert(ArmsModel, Viewmodel)
            end
        end

        return ArmsModel
    end

    function PhantomForces.LocalPlayer:GetGun()
        local GunModel = nil

        for i, Viewmodel in ipairs(Camera:GetChildren()) do
            if Viewmodel and Viewmodel:IsA("Model") and not Viewmodel:FindFirstChild("Arm") then
                GunModel = Viewmodel
                break
            end
        end
        
        return GunModel
    end
--

-- Features -> Misc
    local Misc = {}

    function Misc:Run()
        if not PhantomForces.LocalPlayer:IsAlive() then
            return
        end

        local PlayerModel = PhantomForces.LocalPlayer:Get()

        if not PlayerModel then
            --[[if self.newroot then
                self.newroot:Destroy()
                self.newroot = nil
            end]]
            
            return
        end

        local Humanoid = PlayerModel:FindFirstChildOfClass("Humanoid")
        local RootPart = PlayerModel:FindFirstChild("HumanoidRootPart")

        --[[if RootPart then
            RootPart.Anchored = false
            self.oldroot = RootPart

            if not self.newroot then
                local Copy = RootPart:Clone()
                Copy.Parent = PlayerModel
                self.newroot = Copy
            else
                self.newroot.CFrame = RootPart.CFrame
                self.newroot.AssemblyLinearVelocity = RootPart.AssemblyLinearVelocity
                self.newroot.AssemblyAngularVelocity = RootPart.AssemblyAngularVelocity
                self.newroot.CanCollide = false

                self.oldroot.CanCollide = false
            end
        end]]

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
        elseif RootPart.Anchored then
            RootPart.Anchored = false
        end

        if not Config.Misc.Movement.FlyHack.Enabled and (Config.Misc.Movement.SpeedHack.Enabled and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)) then
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
--

-- Features -> Visuals
    local Visuals = {}

    function Visuals:UpdatePlayers()
        local PlayerModels = PhantomForces:GetPlayerModels()

        if Config.Visuals.Players.Boxes.Enabled and PlayerModels ~= nil then
            Renderer:UnrenderAllExcept({'FOVCircle', 'CrosshairHorizontal', 'CrosshairVertical'})

            for _, Player in pairs(PlayerModels) do
                if not Player:FindFirstChild("Dead") then
                    local Torso = PhantomForces:GetPlayerPart(Player, "Torso")
                    
                    if Torso then
                        local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Torso.Position)
        
                        if OnScreen and tostring(PhantomForces:GetPlayerTeam(Player)) ~= Players.LocalPlayer.Team.Name then
                            local Scale = math.floor(1000 / (Camera.CFrame.Position - Torso.Position).Magnitude * 80 / Camera.FieldOfView)
                            
                            local BoundingBox, SizeVec3 = Player:GetBoundingBox()
                            local Size = Vec3(math.floor(SizeVec3.X), math.floor(SizeVec3.Y), math.floor(SizeVec3.Z))

                            Renderer:Rectangle(Player.Name .. "_Box", ScreenPosition - (Size * (Scale / 2)) - Vec3(1, 1, 1), (Size * Scale) + Vec3(2, 2, 2), ColorRGB(0, 0, 0))
                            Renderer:Rectangle(Player.Name .. "_BoxOuter", ScreenPosition - (Size * (Scale / 2)) + Vec3(1, 1, 1), (Size * Scale) - Vec3(2, 2, 2), ColorRGB(0, 0, 0))
                            Renderer:Rectangle(Player.Name .. "_BoxInner", ScreenPosition - (Size * (Scale / 2)), Size * Scale, Config.Visuals.Players.Boxes.Color)
                        end
                    end
                end
            end
        elseif PlayerModels ~= nil then
            Renderer:UnrenderAllExcept({'FOVCircle', 'CrosshairHorizontal', 'CrosshairVertical'})
        end
    end

    function Visuals:UpdateFovCircle()
        if Config.Visuals.Other.VisualizeFOV.Enabled and PhantomForces.LocalPlayer:IsAlive() then
            local MousePosition = UserInputService:GetMouseLocation()

            Renderer:Circle("FOVCircle",
                Vec2(MousePosition.X, MousePosition.Y), Config.Ragebot.General.FieldOfView,
                (Storage.TargetWithinFOV and Config.Visuals.Other.VisualizeFOV.ActiveColor or Config.Visuals.Other.VisualizeFOV.InactiveColor)
            )
        else
            Renderer:Unrender({'FOVCircle'})
        end
    end

    function Visuals:UpdateCrosshair()
        if Config.Visuals.Other.Crosshair.Enabled and PhantomForces.LocalPlayer:IsAlive() then
            Renderer:Line("CrosshairVertical",
                Vec2(Storage.ScreenSize.X / 2, Storage.ScreenSize.Y / 2 - 10),
                Vec2(Storage.ScreenSize.X / 2, Storage.ScreenSize.Y / 2 + 10),
                Config.Visuals.Other.Crosshair.Color, 2
            )
            Renderer:Line("CrosshairHorizontal",
                Vec2(Storage.ScreenSize.X / 2 - 10, Storage.ScreenSize.Y / 2),
                Vec2(Storage.ScreenSize.X / 2 + 10, Storage.ScreenSize.Y / 2),
                Config.Visuals.Other.Crosshair.Color, 2
            )
        else
            Renderer:Unrender({'CrosshairHorizontal', 'CrosshairVertical'})
        end
    end

    function Visuals:UpdateAmbientLighting()
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
    end

    function Visuals:UpdateSkybox()
        local Sky = Lighting:FindFirstChildOfClass("Sky")

        if Config.Visuals.World.SkyboxChanger.Enabled and Sky then
            if not Storage.SkyboxOriginal then
                Storage.SkyboxOriginal = {
                    ["SkyboxBk"] = Sky.SkyboxBk,
                    ["SkyboxDn"] = Sky.SkyboxDn,
                    ["SkyboxFt"] = Sky.SkyboxFt,
                    ["SkyboxLf"] = Sky.SkyboxLf,
                    ["SkyboxRt"] = Sky.SkyboxRt,
                    ["SkyboxUp"] = Sky.SkyboxUp
                }
            end

            Sky:Destroy()

            local NewSky = Instance.new("Sky")

            for prop, value in pairs(Storage.Skyboxes[Config.Visuals.World.SkyboxChanger.Value]) do
                NewSky[prop] = value
            end

            NewSky.StarCount = Config.Visuals.World.OverrideStarsCount.Enabled and Config.Visuals.World.OverrideStarsCount.Value or 0
            NewSky.Parent = Lighting

            for _, v in pairs(Storage.Skyboxes[Config.Visuals.World.SkyboxChanger.Value]) do
                if Sky[_] ~= v then
                    Sky[_] = v
                end
            end
        elseif Storage.SkyboxOriginal and Sky then
            Sky:Destroy()
        
            local OriginalSky = Instance.new("Sky")

            for prop, value in pairs(Storage.SkyboxOriginal) do
                OriginalSky[prop] = value
            end

            OriginalSky.Parent = Lighting
        
            Storage.SkyboxOriginal = nil
        end
    end

    --Move this somewhere else, too lazy rn
    local WorldNeedsUpdate = Config.Visuals.World.OverrideWorldMaterials

    function Visuals:UpdateWorldMaterials()
        if WorldNeedsUpdate ~= Config.Visuals.World.OverrideWorldMaterials then
            WorldNeedsUpdate = Config.Visuals.World.OverrideWorldMaterials

            if Config.Visuals.World.OverrideWorldMaterials ~= 'Default' then
                for _, Part in pairs(workspace:GetDescendants()) do
                    if Part:IsA("BasePart") then
                        -- Remove existing override textures
                        for _, Texture in pairs(Part:GetChildren()) do
                            if Texture:IsA("Texture") and Texture.Name:match('^OverrideTexture_') then
                                Texture:Destroy()
                            end
                        end
        
                        for TextureName, TextureId in pairs(Storage.MapMaterials[Config.Visuals.World.OverrideWorldMaterials]) do
                            if Part.Material.Name == TextureName then
                                for _, Face in pairs({"Front", "Back", "Bottom", "Top", "Right", "Left"}) do
                                    local NewTextureName = 'OverrideTexture_' .. Face

                                    if not Part:FindFirstChild(NewTextureName) then
                                        local NewTexture = Instance.new("Texture", Part)
                                        NewTexture.Name = NewTextureName
                                        NewTexture.ZIndex = 2147483647
                                        NewTexture.Face = Enum.NormalId[Face]
                                        NewTexture.Texture = "rbxassetid://" .. TextureId
                                        NewTexture.Transparency = Part.Transparency
                                        NewTexture.Color3 = Part.Color
                                    end
                                end
                            end
                        end
                    end
                end
            else
                for _, Part in pairs(workspace:GetDescendants()) do
                    if Part:IsA("BasePart") then
                        for _, Texture in pairs(Part:GetChildren()) do
                            if Texture and Texture:IsA("Texture") and Texture.Name:match('^OverrideTexture_') then
                                Texture:Destroy()
                            end
                        end
                    end
                end
            end
        end
    end

    function Visuals:Update()
        if Config.Visuals.World.OverrideClockTime.Enabled then
            Lighting.ClockTime = Config.Visuals.World.OverrideClockTime.Value
        end
        
        Lighting.Technology = Config.Visuals.World.OverrideTechnology
        
        coroutine.wrap(function()
            self:UpdatePlayers()
        end)()

        self:UpdateFovCircle()
        self:UpdateCrosshair()
        self:UpdateAmbientLighting()
        self:UpdateWorldMaterials()

        self:UpdateSkybox()
    end
--

-- Features -> Chams
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

    function Chams:ApplyChams(Model, ExcludePartsWithColor, DestroyParts, Material, Color)
        if not Model then
            return
        end

        for _, Part in pairs(Model:GetChildren()) do
            if not Part then
                continue
            end

            if table.find(DestroyParts, Part.ClassName) or table.find(DestroyParts, Part.Name) then
                Part:Destroy()
            end
            
            if Part:IsA("BasePart") and not table.find(ExcludePartsWithColor, Part.Color) then
                if Part.Transparency < 1 then
                    Part.Transparency = 0
                end

                if ObjectHasProperty(Part, "UsePartColor") then
                    Part.UsePartColor = true
                end
                
                Part.Material = Material
                Part.Color = Color
            end
        end
    end

    function Chams:UpdatePlayers()
        local PlayerModels, Arms, Gun = PhantomForces:GetPlayerModels(), PhantomForces.LocalPlayer:GetArms(), PhantomForces.LocalPlayer:GetGun()

        if PlayerModels and #PlayerModels > 0 then
            for i, Player in PlayerModels do
                if Player then
                    -- CHAMS
                    local Highlight = Player:FindFirstChildOfClass("Highlight")

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
    end

    function Chams:UpdateViewmodel()
        local Arms, Gun = PhantomForces.LocalPlayer:GetArms(), PhantomForces.LocalPlayer:GetGun()

        if Gun then
            if Config.Visuals.Players.WeaponChams.Enabled then
                if not Storage.GunOriginal[Gun.Name] then
                    Storage.GunOriginal[Gun.Name] = Chams:CreateBackup(Gun, 'BasePart')
                end

                Chams:ApplyChams(
                    Gun, {ColorRGB(255, 152, 220)}, {'Texture'},
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

    function Chams:Update()
        self:UpdateViewmodel()
        self:UpdatePlayers()
    end
--

-- Features -> Antiaim
    local Antiaim = {}

    function Antiaim:Run()
        
    end
--

-- Features -> Autowall
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

        local Ignore = {Target:FindFirstChildOfClass("Folder"), Camera, Workspace.Ignore}

        for _, Part in pairs(PhantomForces:GetMuzzleParts(Gun)) do
            local Direction = Target.Position - Part.Position
            
            local RayCastIgnore = Workspace:FindPartOnRayWithIgnoreList(
                Ray.new(Part.Position, Direction),
                Ignore, false, true
            )

            if not RayCastIgnore then
                continue
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

            if Penetrated <= WeaponPenetratrion then
                if Storage.AimbotFiring then
                    print("Name:", Gun.Name, "Penetrated:", Penetrated, "WeaponPenetratrion:", WeaponPenetratrion)
                end

                return true
            end
        end
    end
--

-- Features -> Ragebot
    local Ragebot = {
        Scoped = false
    }

    function Ragebot:GetTarget(Targets, Gun)
        local MinDistance, MinCrosshairDistance = math.huge, math.huge
        local BestTarget = {}

        for i, Target in ipairs(Targets) do
            if Target ~= nil and tostring(PhantomForces:GetPlayerTeam(Target)) ~= Players.LocalPlayer.Team.Name then
                local Torso = PhantomForces:GetPlayerPart(Target, "Torso") -- Used for FOV Check (temporary ill add a hitbox sys)
                local Parts = PhantomForces:GetPlayerParts(Target)

                if not Torso or not Parts then 
                    continue
                end

                local Distance = (Torso.Position - Camera.CFrame.Position).Magnitude

                if Distance > Config.Ragebot.General.MaxDistance then
                    continue
                end

                local FieldOfViewMode = Config.Ragebot.General.FieldOfViewMode

                if FieldOfViewMode == 'Circle' then
                    local ScreenPos = Camera:WorldToViewportPoint(Torso.Position)
                    local ScreenMagnitude = (Vec2(Storage.ScreenSize.X / 2, Storage.ScreenSize.Y / 2) - Vec2(ScreenPos.X, ScreenPos.Y)).Magnitude

                    if ScreenMagnitude > Config.Ragebot.General.FieldOfView then
                        continue
                    end
                elseif FieldOfViewMode == 'Angle' then
                    local Direction = (Torso.Position - Camera.CFrame.Position).Unit
                    local DotProduct = Camera.CFrame.LookVector:Dot(Direction)
                    local Angle = math.deg(math.acos(DotProduct))

                    if Angle > Config.Ragebot.General.FieldOfView then
                        continue
                    end
                end

                Storage.TargetWithinFOV = true

                for _, Part in pairs(Parts) do
                    if Config.Ragebot.General.AutoWall and not Autowall:CalculatePenetration(Part, Gun) then
                        continue
                    elseif not Config.Ragebot.General.AutoWall and not Autowall:PlayerVisible(Target, Camera.CFrame.Position, Part.Position) then
                        continue
                    end
                    
                    -- {'Crosshair', 'Distance', 'Health', 'Damage'}
                    local TargetSelectionConfig = Config.Ragebot.General.TargetSelection

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
                    elseif TargetSelectionConfig == 'Health' then
                        -- This target selection option cannot be used yet because we need to find a way to retrieve player health, names, etc.
                    elseif TargetSelectionConfig == 'Damage' then
                        -- This target selection optiion also cannot be used because we don't have support to get access to weapon modules yet.
                    end

                    -- Update our target information, found a more optimal target
                    BestTarget = {
                        AimPoint = Part.Position,
                        Target = Target
                    }
                end
            end
        end

        return BestTarget
    end

    local function lerp(from, to, delta_time)
        return from + (to - from) * delta_time
    end

    function Ragebot:Run()
        Storage.TargetWithinFOV, Storage.AimbotFiring = false, false

        if not Config.Ragebot.General.Enabled or not PhantomForces.LocalPlayer:IsAlive() then
            return
        end

        local PlayerModels, Gun, Arms = PhantomForces:GetPlayerModels(), PhantomForces.LocalPlayer:GetGun(), PhantomForces.LocalPlayer:GetArms()
        
        if PlayerModels ~= nil and Gun ~= nil then
            local Target = Ragebot:GetTarget(PlayerModels, Gun)
            
            if next(Target) and Camera and Ragebot.Scoped then
                local ScreenPosition = Camera:WorldToScreenPoint(Target.AimPoint)
                local MousePosition = Camera:WorldToScreenPoint(Mouse.Hit.Position)
                
                local OldX, OldY = (ScreenPosition.X - MousePosition.X), (ScreenPosition.Y - MousePosition.Y)
                
                mousemoverel(OldX * 0.75, OldY * 0.75)

                -- High coding brrrrrr
                -- Will miss, ik cuz of new aimbot, idgaf this project is no longer maintained im working on recode.
                if Config.Ragebot.General.AutoFire then
                    Storage.AimbotFiring = true
                end
            end
        end

        -- Automatic shoot/fire. Can't use VirtualInputManager anymore PF Broke it lol
        if Config.Ragebot.General.AutoFire and Storage.AimbotFiring then
            Storage.AutoFireClick = true

            VirtualInputManager:SendMouseButtonEvent(
                Storage.ScreenSize.X / 2, Storage.ScreenSize.Y / 2, 0, true, game, 0
            )
        end

        if Storage.AutoFireClick and not Storage.AimbotFiring then
            Storage.AutoFireClick = false
            
            VirtualInputManager:SendMouseButtonEvent(
                Storage.ScreenSize.X / 2, Storage.ScreenSize.Y / 2, 0, false, game, 0
            )
        end
    end
--

-- Connections
    UserInputService.InputBegan:Connect(function(v)
        if v.UserInputType == Enum.UserInputType.MouseButton2 then
            Ragebot.Scoped = true
        end
    end)

    UserInputService.InputEnded:Connect(function(v)
        if v.UserInputType == Enum.UserInputType.MouseButton2 then
            Ragebot.Scoped = false
        end
    end)

    RunService.Stepped:Connect(function()
        if Library.Unloaded then
            return
        end

        Ragebot:Run()
        Antiaim:Run()
        Misc:Run()
    end)

    RunService.RenderStepped:Connect(function()
        if Library.Unloaded then
            return
        end

        Visuals:Update()
        Chams:Update()
    end)
--

-- Signal change detections
    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        Storage.ScreenSize = Camera.ViewportSize

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
--

-- Unload feature
    Groups.Settings.Menu:AddButton('Unload', function()
        Library:Notify('[RedactedProject] This feature is unsupported at the moment!')
        -- Removed for now, I couldnt care enough cuz 1/2 the time you need to relauch anyways.
        -- Add back before public/private release, we havent decided either yet also.
    end)
--

-- Load UI Library Save Manager / Config Manager.
-- This isnt indented like everything else due to a solara bug, your script won't run with a comment on the last line.
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

SaveManager:SetFolder('RedactedProject')

SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()

Library:Notify(string.format('[RedactedProject] Script loaded, Welcome %q!', Redacted.Username))
