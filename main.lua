-- [[ 1. THE KILL SWITCH & GLOBALS ]] --
if _G.ClarkHub_Running then
    _G.ClarkHub_Running = false
    _G.ClarkHub_Enabled = false
    _G.AutoFarmMobs = false
    local oldUI = game:GetService("CoreGui"):FindFirstChild("clarkdev67_FinalFix")
    if oldUI then oldUI:Destroy() end
    task.wait(0.5) -- Give the old loop time to die
end

_G.ClarkHub_Running = true
_G.ClarkHub_Enabled = false
_G.AutoClick = false
_G.AutoRank = false
_G.AntiAFK = false
_G.AutoFarmMobs = false
_G.SelectedMob = nil

local _G_Bind = Enum.KeyCode.K
local _G_WalkSpeed = 16

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
local AccentYellow = Color3.fromRGB(210, 190, 50)

-- [[ 2. UI CONSTRUCTION ]] --
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "clarkdev67_FinalFix"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 320)
Main.Position = UDim2.new(0.5, -250, 0.5, -160)
Main.BackgroundColor3 = MainColor
Main.Active = true 
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -40, 0, 35)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Text = "Clarkdev67 - Anime Finals"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1

-- Custom Dragging
local function MakeDraggable(dragHandle, frame)
    local dragging, dragInput, mousePos, framePos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end
MakeDraggable(Title, Main)

local CloseBtn = Instance.new("TextButton", Main)
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.new(1, 1, 1)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.MouseButton1Click:Connect(function()
    _G.ClarkHub_Running = false
    ScreenGui:Destroy()
end)

-- Sidebar
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 130, 1, -60)
Sidebar.Position = UDim2.new(1, -145, 0, 45)
Sidebar.BackgroundColor3 = SidebarColor
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)
Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)

local PageView = Instance.new("Frame", Main)
PageView.Size = UDim2.new(1, -170, 1, -60)
PageView.Position = UDim2.new(0, 15, 0, 45)
PageView.BackgroundTransparency = 1
PageView.ClipsDescendants = true 

local PageLayout = Instance.new("UIPageLayout", PageView)
PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
PageLayout.EasingStyle = Enum.EasingStyle.Quart

-- [[ 3. COMPONENT HELPERS ]] --
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame", PageView)
    Page.Name = name .. "Page"
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.BackgroundTransparency = 1
    Page.ScrollBarThickness = 0
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)
    
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(0.9, 0, 0, 35)
    TabBtn.Text = name
    TabBtn.BackgroundColor3 = SectionColor
    TabBtn.TextColor3 = Color3.new(1, 1, 1)
    TabBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
    TabBtn.MouseButton1Click:Connect(function() PageLayout:JumpTo(Page) end)
    return Page
end

local function AddToggle(parent, text, callback)
    local ToggleFrame = Instance.new("Frame", parent)
    ToggleFrame.Size = UDim2.new(1, -5, 0, 45)
    ToggleFrame.BackgroundColor3 = SectionColor
    Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 8)
    
    local Label = Instance.new("TextLabel", ToggleFrame)
    Label.Size = UDim2.new(0.6, 0, 1, 0)
    Label.Position = UDim2.new(0, 15, 0, 0)
    Label.Text = text
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.GothamMedium
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local StatusBtn = Instance.new("TextButton", ToggleFrame)
    StatusBtn.Size = UDim2.new(0, 50, 0, 24)
    StatusBtn.Position = UDim2.new(1, -65, 0.5, -12)
    StatusBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    StatusBtn.Text = ""
    Instance.new("UICorner", StatusBtn).CornerRadius = UDim.new(1, 0)
    
    local Circle = Instance.new("Frame", StatusBtn)
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = UDim2.new(0, 3, 0.5, -9)
    Circle.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
    
    local enabled = false
    StatusBtn.MouseButton1Click:Connect(function()
        enabled = not enabled
        StatusBtn.BackgroundColor3 = enabled and Color3.fromRGB(40, 180, 40) or Color3.fromRGB(180, 40, 40)
        Circle:TweenPosition(enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9), "Out", "Quart", 0.2, true)
        callback(enabled)
    end)
end

local function AddDynamicDropdown(parent, text, callback)
    local DropdownFrame = Instance.new("Frame", parent)
    DropdownFrame.Size = UDim2.new(1, -5, 0, 45)
    DropdownFrame.BackgroundColor3 = SectionColor
    DropdownFrame.ClipsDescendants = true
    Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 8)
    
    local TitleBtn = Instance.new("TextButton", DropdownFrame)
    TitleBtn.Size = UDim2.new(1, 0, 0, 45)
    TitleBtn.BackgroundTransparency = 1
    TitleBtn.Text = "  " .. text .. " [Scan]"
    TitleBtn.TextColor3 = Color3.new(1, 1, 1)
    TitleBtn.Font = Enum.Font.GothamMedium
    TitleBtn.TextXAlignment = Enum.TextXAlignment.Left
    
    local ItemList = Instance.new("Frame", DropdownFrame)
    ItemList.Size = UDim2.new(1, 0, 0, 0)
    ItemList.Position = UDim2.new(0, 0, 0, 45)
    ItemList.BackgroundTransparency = 1
    Instance.new("UIListLayout", ItemList)

    local open = false
    TitleBtn.MouseButton1Click:Connect(function()
        open = not open
        if open then
            for _, v in pairs(ItemList:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
            local list = {}
            if workspace:FindFirstChild("Enemies") then
                for _, e in pairs(workspace.Enemies:GetChildren()) do
                    if not table.find(list, e.Name) then table.insert(list, e.Name) end
                end
            end
            if #list == 0 then list = {"No Enemies Found"} end
            for _, name in pairs(list) do
                local Item = Instance.new("TextButton", ItemList)
                Item.Size = UDim2.new(1, 0, 0, 30)
                Item.BackgroundColor3 = Color3.fromRGB(35, 36, 25)
                Item.Text = name
                Item.TextColor3 = Color3.new(0.8, 0.8, 0.8)
                Item.Font = Enum.Font.Gotham
                Item.BorderSizePixel = 0
                Item.MouseButton1Click:Connect(function()
                    _G.SelectedMob = name ~= "No Enemies Found" and name or nil
                    TitleBtn.Text = "  " .. text .. " [" .. name .. "]"
                    callback(_G.SelectedMob)
                    open = false
                    DropdownFrame:TweenSize(UDim2.new(1, -5, 0, 45), "Out", "Quart", 0.3, true)
                end)
            end
            DropdownFrame:TweenSize(UDim2.new(1, -5, 0, 45 + (#list * 30)), "Out", "Quart", 0.3, true)
        else
            DropdownFrame:TweenSize(UDim2.new(1, -5, 0, 45), "Out", "Quart", 0.3, true)
        end
    end)
end

local function AddSlider(parent, text, min, max, callback)
    local SliderFrame = Instance.new("Frame", parent)
    SliderFrame.Size = UDim2.new(1, -5, 0, 60)
    SliderFrame.BackgroundColor3 = SectionColor
    Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 8)

    local Label = Instance.new("TextLabel", SliderFrame)
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.Position = UDim2.new(0, 15, 0, 5)
    Label.Text = text .. " : " .. min
    Label.TextColor3 = Color3.new(1, 1, 1)
    Label.Font = Enum.Font.GothamMedium
    Label.BackgroundTransparency = 1
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local SliderBar = Instance.new("Frame", SliderFrame)
    SliderBar.Size = UDim2.new(0.9, 0, 0, 4)
    SliderBar.Position = UDim2.new(0.05, 0, 0.75, 0)
    SliderBar.BackgroundColor3 = SidebarColor
    Instance.new("UICorner", SliderBar)

    local Fill = Instance.new("Frame", SliderBar)
    Fill.Size = UDim2.new(0, 0, 1, 0)
    Fill.BackgroundColor3 = AccentYellow
    Instance.new("UICorner", Fill)

    local Knob = Instance.new("Frame", SliderBar)
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.Position = UDim2.new(0, -6, 0.5, -6)
    Knob.BackgroundColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function update()
        local percent = math.clamp((UserInputService:GetMouseLocation().X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        Knob.Position = UDim2.new(percent, -6, 0.5, -6)
        Fill.Size = UDim2.new(percent, 0, 1, 0)
        local value = math.floor(min + (max - min) * percent)
        Label.Text = text .. " : " .. value
        callback(value)
    end

    Knob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
end

-- [[ 4. SETUP PAGES ]] --
local RaidsTab = CreatePage("Raids")
local MobsTab = CreatePage("Mobs")
local MiscTab = CreatePage("Misc")

AddToggle(RaidsTab, "Auto Pyramid Raid", function(state) _G.ClarkHub_Enabled = state end)
AddToggle(MobsTab, "Auto Farm Selected Mobs", function(state) _G.AutoFarmMobs = state end)
AddDynamicDropdown(MobsTab, "Select Mobs:", function(val) _G.SelectedMob = val end)
AddToggle(MiscTab, "Auto Click", function(state) _G.AutoClick = state end)
AddToggle(MiscTab, "Auto Rank", function(state) _G.AutoRank = state end)
AddToggle(MiscTab, "Anti-AFK", function(state) _G.AntiAFK = state end)
AddSlider(MiscTab, "WalkSpeed", 16, 250, function(val) _G_WalkSpeed = val end)

-- [[ 5. CORE LOOP ]] --
task.spawn(function()
    while _G.ClarkHub_Running do
        task.wait(0.1)
        
        local Character = Player.Character
        local Root = Character and Character:FindFirstChild("HumanoidRootPart")
        if not Root then continue end

        -- 1. WALKSPEED (Sprint Fix)
        if _G_WalkSpeed > 16 then 
            Character.Humanoid.WalkSpeed = _G_WalkSpeed 
        end

        -- 2. AUTO CLICK / RANK
        if _G.AutoClick then ReplicatedStorage.Remotes.ClickRemote:FireServer() end
        if _G.AutoRank then ReplicatedStorage.Remotes.RankUpRemote:InvokeServer() end

        -- 3. AUTO FARM MOBS
        if _G.AutoFarmMobs and _G.SelectedMob then
            local enemies = Workspace:FindFirstChild("Enemies")
            if enemies then
                for _, e in pairs(enemies:GetChildren()) do
                    if e.Name == _G.SelectedMob and e:FindFirstChild("Humanoid") and e.Humanoid.Health > 0 then
                        local eroot = e:FindFirstChild("HumanoidRootPart")
                        if eroot then
                            Root.CFrame = eroot.CFrame * CFrame.new(0, 0, 3)
                            ReplicatedStorage.Remotes.AttackEvent:FireServer()
                        end
                        break
                    end
                end
            end
        end

        -- 4. THE ULTIMATE RAID RE-FIX
        if _G.ClarkHub_Enabled then
            local EnemiesFolder = Workspace:FindFirstChild("Enemies")
            local target = nil
            
            -- Priority: Kill Mobs
            if EnemiesFolder then
                for _, enemy in pairs(EnemiesFolder:GetChildren()) do
                    local eRoot = enemy:FindFirstChild("HumanoidRootPart")
                    local eHum = enemy:FindFirstChildOfClass("Humanoid")
                    if eRoot and eHum and eHum.Health > 0 then
                        target = eRoot
                        break
                    end
                end
            end
            
            if target then
                Root.CFrame = target.CFrame * CFrame.new(0, 0, 3.5)
                ReplicatedStorage.Remotes.AttackEvent:FireServer()
            else
                -- Priority: Find Next Room (The Door Hack)
                local foundDoor = false
                for _, obj in pairs(Workspace:GetDescendants()) do
                    -- Detects the invisible trigger zone
                    if obj:IsA("TouchTransmitter") and obj.Parent:IsA("BasePart") then
                        local door = obj.Parent
                        -- Distance check to find the closest door
                        if (Root.Position - door.Position).Magnitude < 400 then
                            Root.CFrame = door.CFrame
                            firetouchinterest(Root, door, 0)
                            firetouchinterest(Root, door, 1)
                            foundDoor = true
                            task.wait(0.5)
                            break
                        end
                    end
                end

                -- Final Priority: Join if not in Raid
                if not foundDoor then
                    pcall(function()
                        ReplicatedStorage.Remotes.GetRaidGate:InvokeServer("World4")
                        ReplicatedStorage.Remotes.JoinRaid:InvokeServer("World4")
                    end)
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, p)
    if not p and i.KeyCode == _G_Bind then Main.Visible = not Main.Visible end
end)
