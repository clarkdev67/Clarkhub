-- [[ 1. THE KILL SWITCH ]] --
-- Ensures only one instance runs and clean up old background loops
if _G.ClarkHub_Running then
    _G.ClarkHub_Running = false
    _G.ClarkHub_Enabled = false
    local oldUI = game:GetService("CoreGui"):FindFirstChild("clarkdev67_FinalFix")
    if oldUI then oldUI:Destroy() end
    task.wait(0.3)
end

_G.ClarkHub_Running = true
_G.ClarkHub_Enabled = false
local _G_Bind = Enum.KeyCode.K

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local Player = Players.LocalPlayer

-- Themes
local MainColor = Color3.fromRGB(30, 31, 22)
local SidebarColor = Color3.fromRGB(20, 21, 15)
local SectionColor = Color3.fromRGB(45, 46, 33)

-- [[ 2. UI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "clarkdev67_FinalFix"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 320)
Main.Position = UDim2.new(0.5, -250, 0.5, -160)
Main.BackgroundColor3 = MainColor
Main.Active, Main.Draggable = true, true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

-- HEADER NAME
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(0, 300, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Clarkdev67 - Anime Finals"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- CLOSE BUTTON
local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.MouseButton1Click:Connect(function()
    _G.ClarkHub_Running = false
    _G.ClarkHub_Enabled = false
    ScreenGui:Destroy()
end)

-- SIDEBAR
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 130, 1, -60)
Sidebar.Position = UDim2.new(1, -145, 0, 45)
Sidebar.BackgroundColor3 = SidebarColor
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local RaidsTabBtn = Instance.new("TextButton", Sidebar)
RaidsTabBtn.Size = UDim2.new(0.9, 0, 0, 40)
RaidsTabBtn.Position = UDim2.new(0.05, 0, 0, 10)
RaidsTabBtn.BackgroundColor3 = Color3.fromRGB(150, 180, 50)
RaidsTabBtn.Text = "Raids"
RaidsTabBtn.TextColor3 = Color3.new(1, 1, 1)
RaidsTabBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", RaidsTabBtn).CornerRadius = UDim.new(0, 8)

-- PAGE VIEW
local PageView = Instance.new("Frame", Main)
PageView.Size = UDim2.new(1, -170, 1, -60)
PageView.Position = UDim2.new(0, 15, 0, 45)
PageView.BackgroundTransparency = 1

-- TOGGLE
local ToggleFrame = Instance.new("Frame", PageView)
ToggleFrame.Size = UDim2.new(1, 0, 0, 60)
ToggleFrame.BackgroundColor3 = SectionColor
Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)

local Label = Instance.new("TextLabel", ToggleFrame)
Label.Size = UDim2.new(0.6, 0, 1, 0)
Label.Position = UDim2.new(0, 15, 0, 0)
Label.Text = "Auto Pyramid Raid"
Label.TextColor3 = Color3.new(1, 1, 1)
Label.Font = Enum.Font.GothamMedium
Label.BackgroundTransparency = 1
Label.TextXAlignment = Enum.TextXAlignment.Left

local StatusBtn = Instance.new("TextButton", ToggleFrame)
StatusBtn.Size = UDim2.new(0, 60, 0, 30)
StatusBtn.Position = UDim2.new(1, -75, 0.5, -15)
StatusBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
StatusBtn.Text = ""
Instance.new("UICorner", StatusBtn).CornerRadius = UDim.new(1, 0)

local Circle = Instance.new("Frame", StatusBtn)
Circle.Size = UDim2.new(0, 24, 0, 24)
Circle.Position = UDim2.new(0, 3, 0.5, -12)
Circle.BackgroundColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

StatusBtn.MouseButton1Click:Connect(function()
    _G.ClarkHub_Enabled = not _G.ClarkHub_Enabled
    StatusBtn.BackgroundColor3 = _G.ClarkHub_Enabled and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(180, 40, 40)
    Circle:TweenPosition(_G.ClarkHub_Enabled and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12), "Out", "Quart", 0.2, true)
end)

-- [[ 3. CORE SCRIPT LOGIC ]] --
task.spawn(function()
    while _G.ClarkHub_Running and task.wait(0.1) do
        -- FORCE GAIN
        ReplicatedStorage.Remotes.ClickRemote:FireServer()
        
        -- AUTO RAID
        if _G.ClarkHub_Enabled then
            local raid = nil
            for _, v in pairs(Workspace:GetChildren()) do
                if v.Name:find("Raid_W4") then raid = v break end
            end

            if not raid then
                pcall(function()
                    ReplicatedStorage.Remotes.GetRaidGate:InvokeServer("World4")
                    ReplicatedStorage.Remotes.JoinRaid:InvokeServer("World4")
                end)
                task.wait(2.5)
            else
                local root = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local enemies = Workspace:FindFirstChild("Enemies")
                    local target = nil
                    if enemies then
                        for _, e in pairs(enemies:GetChildren()) do
                            local eroot = e:FindFirstChild("HumanoidRootPart")
                            if eroot and e:FindFirstChildOfClass("Humanoid") and e:FindFirstChildOfClass("Humanoid").Health > 0 then
                                if (root.Position - eroot.Position).Magnitude < 250 then 
                                    target = eroot break 
                                end
                            end
                        end
                    end

                    if target then
                        root.CFrame = target.CFrame * CFrame.new(0, 0, 3)
                        ReplicatedStorage.Remotes.AttackEvent:FireServer()
                    else
                        -- Check for Room TP
                        local pGui = Player:FindFirstChild("PlayerGui")
                        local unlocked = false
                        if pGui then
                            for _, v in pairs(pGui:GetDescendants()) do
                                if v:IsA("TextLabel") and v.Visible and (v.Text:find("Unlocked") or v.Text:find("Climb")) then
                                    unlocked = true break
                                end
                            end
                        end
                        if unlocked then
                            for _, obj in pairs(raid:GetDescendants()) do
                                if obj.Name == "TP" and (root.Position - obj.Position).Magnitude < 300 then
                                    root.CFrame = obj.CFrame
                                    firetouchinterest(root, obj, 0)
                                    firetouchinterest(root, obj, 1)
                                    task.wait(2)
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Keybind
UserInputService.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == _G_Bind then Main.Visible = not Main.Visible end
end)
