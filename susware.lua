--[[   Susware Aimbot 
    Very badly made aimbot that works for some games. 
    Known working games:
     Arsenal
     POLYBATTLE
     CALIBER (Alpha)
     K.A.T
     
    Made by cheetoah#2334
--]]

local scriptVersion = 1.6

local CurrentCamera = workspace.CurrentCamera
local Players = game.GetService(game, "Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local IS = game.getService(game,"UserInputService")
local RunService = game:GetService("RunService")
local worldToViewportPoint = CurrentCamera.worldToViewportPoint

local settings = {
    Teamcheck = false,
    Wallcheck = false,
    Aim_Enabled = false,
    Draw_FOV = false,
    FOV_Colour = Color3.fromRGB(15,255,25),
    FOV_Radius = 0,
    Sensitivity = 0,
    Offset = 36 --Do not change unless yk what you are doing
}

local fovcircle = Drawing.new("Circle")
fovcircle.Visible = settings.Draw_FOV
fovcircle.Radius = settings.FOV_Radius
fovcircle.Thickness = .5
fovcircle.Filled = false
fovcircle.Transparency = 1
fovcircle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
fovcircle.Color = Color3.fromRGB(15,255,25)

IS.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        settings.Aiming = true
    end
end)

IS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        settings.Aiming = false
    end
end)

local function aimAt(vector)
    local newpos = worldToViewportPoint(CurrentCamera, vector)
    mousemoverel((newpos.X - Mouse.X) * settings.Sensitivity, ((newpos.Y - Mouse.Y - settings.Offset) * settings.Sensitivity))
end

local function isVis(p)
    if not settings.Wallcheck then return true end
	ignoreList = {LocalPlayer.Character, CurrentCamera, p.Character}
	local parts = workspace.CurrentCamera:GetPartsObscuringTarget({p.Character.Head.Position, CurrentCamera.CFrame.Position}, ignoreList)
    return #parts == 0
end

function get_target_aimbot()
    local MaxDist, Closest = math.huge

    for I,V in pairs(Players.GetPlayers(Players)) do
        if V == LocalPlayer or V.Team == LocalPlayer or not V.Character then continue end
    
        local Head = V.Character.FindFirstChild(V.Character, "Head")
        if not Head then continue end
    
        local Pos, Vis = CurrentCamera.WorldToScreenPoint(CurrentCamera, Head.Position)
        if not Vis then continue end
        
        local Humanoid = V.Character.FindFirstChild(V.Character, "Humanoid")
        if not Humanoid or Humanoid.Health <= 0 then continue end
        
        local ForceField = V.Character.FindFirstChild(V.Character, "ForceField")
        if ForceField then continue end
        
        if settings.Teamcheck and V.TeamColor == LocalPlayer.TeamColor then continue end
        --look at this horrible lua
        --I nearly killed myself after writing this function
        local MousePos, TheirPos = Vector2.new(Mouse.X, Mouse.Y), Vector2.new(Pos.X, Pos.Y)
        local Dist = (TheirPos - MousePos).Magnitude
        
        if Dist < MaxDist and Dist <= settings.FOV_Radius then 
            MaxDist = Dist
            Closest = V
        end
    end
    return Closest
end

RunService.RenderStepped:Connect(function()
    if settings.Aim_Enabled and settings.Aiming then
        local t = get_target_aimbot()
        if t and isVis(t) then
            aimAt(t.Character.Head:GetRenderCFrame().Position)
        end
    end
    
    if settings.Aim_Enabled and settings.Draw_FOV then
        fovcircle.Visible = true
        fovcircle.Radius = settings.FOV_Radius
        fovcircle.Color = settings.FOV_Colour
        fovcircle.Position = Vector2.new(Mouse.X, Mouse.Y + settings.Offset)
    else
        fovcircle.Visible = false
    end

end)

--[[
    Susware ESP by cheetoah
    also very shit
--]]

local espSettings = {
    Enabled = false,
    Teamcheck = false,
    Boxes = false,
    Box_Colour = Color3.fromRGB(255,15,25),
    Nametag_Colour = Color3.new(1,0.62,0),
    Healthbar_Colour = Color3.new(0.15,1,0.26),
    Nametags = false,
    Teamcheck = false,
    Healthbar = false
}

local HeadOff = Vector3.new(0, 0.5, 0)
local LegOff = Vector3.new(0,3,0)

for i,v in pairs(game.Players:GetChildren()) do
    local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255,15,25)
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false
    
    local Nametag = Drawing.new("Text")
    Nametag.Visible = false
    Nametag.Color = Color3.new(1,0.62,0)
    Nametag.Size = 20
    
    local HealthBar = Drawing.new("Square")
    HealthBar.Thickness = 1
    HealthBar.Filled = false
    HealthBar.Color = Color3.new(0.15,1,0.26)
    HealthBar.Transparency = 1 
    HealthBar.Visible = false
    
    function boxesp()
        game:GetService("RunService").RenderStepped:Connect(function()
            if v.Character ~= nil and v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("HumanoidRootPart") ~= nil and v ~= LocalPlayer and v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("Head") ~= nil then
                 if espSettings.Teamcheck and LocalPlayer.TeamColor ~= v.TeamColor or not espSettings.Teamcheck then
                    local Vector, onScreen = CurrentCamera:worldToViewportPoint(v.Character.HumanoidRootPart.Position)
        
                    local RootPart = v.Character.HumanoidRootPart
                    local Head = v.Character.Head
                    local RootPosition, RootVis = worldToViewportPoint(CurrentCamera, RootPart.Position)
                    local HeadPosition = worldToViewportPoint(CurrentCamera, Head.Position + HeadOff)
                    local LegPosition = worldToViewportPoint(CurrentCamera, RootPart.Position - LegOff)
                    local name = v.Name .. " (" .. v.DisplayName ..")" 
                  
                    if onScreen and espSettings.Enabled then
                        Box.Size = Vector2.new(1700 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                        Box.Position = Vector2.new(RootPosition.X - Box.Size.X / 2, RootPosition.Y - Box.Size.Y / 2)
                        if espSettings.Boxes then
                            Box.Visible = true 
                            Box.Color = espSettings.Box_Colour
                        else
                            Box.Visible = false
                        end
                       
                        Nametag.Text = name 
                        Nametag.Position = Vector2.new(HeadPosition.X + Box.Size.X + 0.5 / 2, HeadPosition.Y - 7)
                        if espSettings.Nametags then 
                            Nametag.Visible = true
                            Nametag.Color = espSettings.Nametag_Colour
                        else
                            Nametag.Visible = false
                        end
                        
                        HealthBar.Size = Vector2.new(2, (HeadPosition.Y - LegPosition.Y) * (v.Character.Humanoid.Health / v.Character.Humanoid.MaxHealth))
                        HealthBar.Position = Vector2.new(Box.Position.X - 5, Box.Position.Y + (1/HealthBar.Size.Y))
                        if espSettings.Healthbar then
                            HealthBar.Visible = true
                            HealthBar.Color = espSettings.Healthbar_Colour
                        else
                            HealthBar.Visible = false
                        end
                    else
                        Box.Visible = false
                        Nametag.Visible = false
                        HealthBar.Visible = false
                    end
                else
                    Box.Visible = false
                    Nametag.Visible = false
                    HealthBar.Visible = false
                end
            else
                Box.Visible = false
                Nametag.Visible = false
                HealthBar.Visible = false
            end
        end)
    end
    coroutine.wrap(boxesp)()
end

game.Players.PlayerAdded:Connect(function(v)
 local Box = Drawing.new("Square")
    Box.Visible = false
    Box.Color = Color3.fromRGB(255,15,25)
    Box.Thickness = 1
    Box.Transparency = 1
    Box.Filled = false
    
    local Nametag = Drawing.new("Text")
    Nametag.Visible = false
    Nametag.Color = Color3.new(1,0.62,0)
    Nametag.Size = 20
    
    local HealthBar = Drawing.new("Square")
    HealthBar.Thickness = 1
    HealthBar.Filled = false
    HealthBar.Color = Color3.new(0.15,1,0.26)
    HealthBar.Transparency = 1 
    HealthBar.Visible = false
    
    function boxesp()
        game:GetService("RunService").RenderStepped:Connect(function()
            if v.Character ~= nil and v.Character:FindFirstChild("Humanoid") ~= nil and v.Character:FindFirstChild("HumanoidRootPart") ~= nil and v ~= LocalPlayer and v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("Head") ~= nil then
                if espSettings.Teamcheck and LocalPlayer.TeamColor ~= v.TeamColor or not espSettings.Teamcheck then
                    local Vector, onScreen = CurrentCamera:worldToViewportPoint(v.Character.HumanoidRootPart.Position)
        
                    local RootPart = v.Character.HumanoidRootPart
                    local Head = v.Character.Head
                    local RootPosition, RootVis = worldToViewportPoint(CurrentCamera, RootPart.Position)
                    local HeadPosition = worldToViewportPoint(CurrentCamera, Head.Position + HeadOff)
                    local LegPosition = worldToViewportPoint(CurrentCamera, RootPart.Position - LegOff)
                    local name = v.Name .. " (" .. v.DisplayName ..")" 
                  
                    if onScreen and espSettings.Enabled then
                        Box.Size = Vector2.new(1700 / RootPosition.Z, HeadPosition.Y - LegPosition.Y)
                        Box.Position = Vector2.new(RootPosition.X - Box.Size.X / 2, RootPosition.Y - Box.Size.Y / 2)
                        if espSettings.Boxes then
                            Box.Visible = true 
                            Box.Color = espSettings.Box_Colour
                        else
                            Box.Visible = false
                        end
                       
                        Nametag.Text = name 
                        Nametag.Position = Vector2.new(HeadPosition.X + Box.Size.X + 0.5 / 2, HeadPosition.Y - 7)
                        if espSettings.Nametags then 
                            Nametag.Visible = true
                            Nametag.Color = espSettings.Nametag_Colour
                        else
                            Nametag.Visible = false
                        end
                        
                        HealthBar.Size = Vector2.new(2, (HeadPosition.Y - LegPosition.Y) * (v.Character.Humanoid.Health / v.Character.Humanoid.MaxHealth))
                        HealthBar.Position = Vector2.new(Box.Position.X - 5, Box.Position.Y + (1/HealthBar.Size.Y))
                        if espSettings.Healthbar then
                            HealthBar.Visible = true
                            HealthBar.Color = espSettings.Healthbar_Colour
                        else
                            HealthBar.Visible = false
                        end
                    else
                        Box.Visible = false
                        Nametag.Visible = false
                        HealthBar.Visible = false
                    end
                else
                    Box.Visible = false
                    Nametag.Visible = false
                    HealthBar.Visible = false
                end
            else
                Box.Visible = false
                Nametag.Visible = false
                HealthBar.Visible = false
            end
        end)
    end
    coroutine.wrap(boxesp)()
end)

--[[
    susware Silent Aimbot 
    Probs the worst silent aim possible
    lol
--]]

local silentAimSettings = {
    Enabled = false,
    Aim_FOV = 0,
    Teamcheck = false,
    Autoshoot = false,
    Draw_FOV = false,
    FOV_Colour = Color3.fromRGB(255,15,25),
    Offset = 36 --Do not change unless yk what you are doing
}


local silentfovcircle = Drawing.new("Circle")
silentfovcircle.Visible = silentAimSettings.Draw_FOV
silentfovcircle.Radius = silentAimSettings.Aim_FOV
silentfovcircle.Thickness = .5
silentfovcircle.Filled = false
silentfovcircle.Transparency = 1
silentfovcircle.Position = Vector2.new(CurrentCamera.ViewportSize.X / 2, CurrentCamera.ViewportSize.Y / 2)
silentfovcircle.Color = Color3.fromRGB(255,15,25)

local function isVisSilent(p)
	ignoreList = {LocalPlayer.Character, CurrentCamera, p.Character}
	local parts = workspace.CurrentCamera:GetPartsObscuringTarget({p.Character.Head.Position, CurrentCamera.CFrame.Position}, ignoreList)
    return #parts == 0
end

function get_target_silent()
    local MaxDist, Closest = math.huge
    for I,V in pairs(Players.GetPlayers(Players)) do
        if not silentAimSettings.Enabled then continue end
        
        if V == LocalPlayer or V.Team == LocalPlayer or not V.Character then continue end
    
        local Head = V.Character.FindFirstChild(V.Character, "Head")
        if not Head then continue end
    
        local Pos, Vis = CurrentCamera.WorldToScreenPoint(CurrentCamera, Head.Position)
        if not Vis then continue end
        
        local Humanoid = V.Character.FindFirstChild(V.Character, "Humanoid")
        if not Humanoid or Humanoid.Health <= 0 then continue end
        
        local ForceField = V.Character.FindFirstChild(V.Character, "ForceField")
        if ForceField then continue end
        
        if silentAimSettings.Teamcheck and V.TeamColor == LocalPlayer.TeamColor then continue end
        --look at this horrible lua
        --I nearly killed myself after writing this function
        local MousePos, TheirPos = Vector2.new(Mouse.X, Mouse.Y), Vector2.new(Pos.X, Pos.Y)
        local Dist = (TheirPos - MousePos).Magnitude
        
        if Dist < MaxDist and Dist <= silentAimSettings.Aim_FOV then 
            MaxDist = Dist
            Closest = V
        end
    end
    return Closest
end

local MT = getrawmetatable(game)
local OldNC = MT.__namecall
local OldIDX = MT.__index
setreadonly(MT, false)
MT.__namecall = newcclosure(function(self, ...)
    local Args, Method = {...}, getnamecallmethod()
    if Method == "FindPartOnRayWithIgnoreList" and not checkcaller() then
        local T = get_target_silent()
        if T and T.Character and T.Character.FindFirstChild(T.Character, "Head") then
            Args[1] = Ray.new(CurrentCamera.CFrame.Position, (T.Character.Head.Position - CurrentCamera.CFrame.Position).Unit * 1000)
            return OldNC(self, unpack(Args))
        end
    end
    return OldNC(self, ...)
end)

MT.__index = newcclosure(function(self, K)
    if K == "Clips" then
        return workspace.Map
    end
    return OldIDX(self, K)
end)
setreadonly(MT, true)


coroutine.wrap(function()
    while wait(0.01) do
        local t = get_target_silent()
        if t and isVis(t) then
            if silentAimSettings.Autoshoot then mouse1click() end
        end
    end
end)()


game:GetService("RunService").RenderStepped:Connect(function()
     if silentAimSettings.Enabled and silentAimSettings.Draw_FOV then
        silentfovcircle.Visible = true
        silentfovcircle.Radius = silentAimSettings.Aim_FOV
        silentfovcircle.Position = Vector2.new(Mouse.X, Mouse.Y + silentAimSettings.Offset)
    else
        silentfovcircle.Visible = false
    end
end)

--[[
    Kinda nice looking UI Library
    Yall should check out the creator.
    also why you snoopin through my code, you won't learn anything
--]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("susware", "BloodTheme")
--combat section
local CombatTab = Window:NewTab("Combat")

--aimbot section
local AimbotSection = CombatTab:NewSection("Aimbot")

AimbotSection:NewToggle("Enabled", "Aimbot", function(state)
    if state then
        settings.Aim_Enabled = true
    else
        settings.Aim_Enabled = false
    end
end)
AimbotSection:NewToggle("Wall Check", "Only aim at visible players", function(state)
    if state then
        settings.Wallcheck = true
    else
        settings.Wallcheck = false
    end
end)
AimbotSection:NewToggle("Team Check", "Only aim at players on other teams", function(state)
    if state then
        settings.Teamcheck = true
    else
        settings.Teamcheck = false
    end
end)
AimbotSection:NewSlider("FOV", "The max distance from the mouse that a player can be targeted at", 1500, 0, function(s)
   settings.FOV_Radius = s
end)
AimbotSection:NewToggle("Draw FOV", "Draws a circle to visualise the Aimbot FOV", function(state)
    settings.Draw_FOV = state
end)
AimbotSection:NewColorPicker("FOV Circle Colour", "What colour the circle is", Color3.fromRGB(15,255,25), function(color)
    settings.FOV_Colour = color
    fovcircle.Color = settings.FOV_Colour
end)
AimbotSection:NewSlider("Sensitivity", "How fast the aimbot moves your mouse", 100, 0, function(s)
   settings.Sensitivity = s / 100
end)

--silent aim section
local SilentSection = CombatTab:NewSection("Silent Aim")
SilentSection:NewToggle("Enabled", "Silent Aim", function(state)
    if state then
        silentAimSettings.Enabled = true
    else
        silentAimSettings.Enabled = false
    end
end)
SilentSection:NewToggle("Autoshoot", "Automatically shoot at visible players", function(state)
    if state then
        silentAimSettings.Autoshoot = true
    else
        silentAimSettings.Autoshoot = false
    end
end)
SilentSection:NewToggle("Team Check", "Only shoot players on other teams", function(state)
    if state then
        silentAimSettings.Teamcheck = true
    else
        silentAimSettings.Teamcheck = false
    end
end)
SilentSection:NewSlider("FOV", "Field Of View of Silent aim", 1500, 0, function(s)
   silentAimSettings.Aim_FOV = s
end)
SilentSection:NewToggle("Draw Fov", "Draws a circle to visualise the Silent Aimbot FOV", function(state)
    if state then
        silentAimSettings.Draw_FOV = true
    else
        silentAimSettings.Draw_FOV = false
    end
end)
SilentSection:NewColorPicker("FOV Circle Colour", "What colour the circle is", Color3.fromRGB(255,15,25), function(color)
    silentAimSettings.FOV_Colour = color
    silentfovcircle.Color = silentAimSettings.FOV_Colour
end)

--visuals tab
local VisualsTab = Window:NewTab("Visuals")
--esp section
local EspSection = VisualsTab:NewSection("ESP")

EspSection:NewToggle("Enabled", "Extra Sensory Perception", function(state)
    espSettings.Enabled = state
end)

EspSection:NewToggle("Team Check", "Only draw on players on other teams", function(state)
    espSettings.Teamcheck = state
end)

EspSection:NewToggle("Boxes", "Draw a box around other players", function(state)
     if state then
        espSettings.Boxes = true
    else
        espSettings.Boxes = false
    end
end)

EspSection:NewColorPicker("Box Colour", "What colour the boxes are...", Color3.fromRGB(255,15,25), function(color)
    espSettings.Box_Colour = color
end)

EspSection:NewToggle("Name Tags", "Draw the player's Name next to them", function(state)
    if state then
        espSettings.Nametags = true
    else
        espSettings.Nametags = false
    end
end)

EspSection:NewColorPicker("Nametag Colour", "What colour the nametags are...", Color3.new(1,0.62,0), function(color)
    espSettings.Nametag_Colour = color
end)

EspSection:NewToggle("Health Bar", "Draw a health bar next to the players", function(state)
    if state then
        espSettings.Healthbar = true
    else
        espSettings.Healthbar = false
    end
end)
EspSection:NewColorPicker("Healthbar Colour", "What colour the health bars are...", Color3.new(0.15,1,0.26), function(color)
    espSettings.Healthbar_Colour = color
end)

--other tab
local OtherTab = Window:NewTab("Other")
--game section
local GameSection = OtherTab:NewSection("Game")
GameSection:NewButton("Rejoin game", "Rejoins the same game server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, game:GetService("Players").LocalPlayer)
end)
--gui section
local GUISection = OtherTab:NewSection("GUI")
GUISection:NewKeybind("Toggle GUI", "Toggle the GUI (duh)", Enum.KeyCode.RightShift, function()
	Library:ToggleUI()
end)

--info section
local InfoSection = OtherTab:NewSection("Information")
InfoSection:NewLabel("Version ".. scriptVersion)
InfoSection:NewLabel("Created by cheetoah#2334")
