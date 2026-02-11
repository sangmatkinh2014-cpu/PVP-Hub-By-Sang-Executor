local p = game:GetService("Players").LocalPlayer
local run = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local mouse = p:GetMouse()
local vim = game:GetService("VirtualInputManager") 

-- Xóa menu cũ
local pgui = p:WaitForChild("PlayerGui")
if pgui:FindFirstChild("UltraMenu") then pgui.UltraMenu:Destroy() end

local sg = Instance.new("ScreenGui", pgui)
sg.Name = "UltraMenu"
sg.ResetOnSpawn = false

-- BIẾN ĐIỀU KHIỂN
local s_val, j_val, f_val = 0, 50, 50
local flying, aim_player, auto_tele = false, false, false
local auto_z, auto_x, auto_c, auto_v = false, false, false, false
local esp_player, esp_fruit = false, false 
local auto_get_fruit, auto_store = false, false
local auto_v3, auto_v4 = false, false
local target_player = nil
local active = true 

-- #######################################################
-- # UI HELPER                                           #
-- #######################################################
local function createLabel(txt, pos, size, parent)
    local l = Instance.new("TextLabel", parent)
    l.Size = UDim2.new(1, 0, 0, size + 10)
    l.Position = pos
    l.BackgroundTransparency = 1
    l.Text = txt
    l.TextColor3 = Color3.new(1, 1, 1)
    l.Font = Enum.Font.SciFi
    l.TextSize = size
    return l
end

-- NÚT MỞ MENU
local toggle = Instance.new("TextButton", sg)
toggle.Size = UDim2.new(0, 80, 0, 80)
toggle.Position = UDim2.new(0, 15, 0.5, -40)
toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggle.Text = ""
toggle.Draggable = true
toggle.Active = true
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
createLabel("Sang", UDim2.new(0,0,0.1,0), 20, toggle)
createLabel("HUB", UDim2.new(0,0,0.45,0), 14, toggle).TextColor3 = Color3.fromRGB(0, 255, 255)

-- KHUNG CHÍNH
local main = Instance.new("ScrollingFrame", sg)
main.Size = UDim2.new(0, 500, 0, 600)
main.Position = UDim2.new(0.5, -250, 0.5, -300)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.CanvasSize = UDim2.new(0, 0, 6, 0)
main.Visible = true
main.Active = true
Instance.new("UICorner", main)

toggle.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

-- HÀM TẠO TOGGLE & SLIDER
local function CreateToggle(name, y, def, cb)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0.85, 0, 0, 50)
    btn.Position = UDim2.new(0.075, 0, 0, y)
    btn.Text = name .. ": " .. (def and "BẬT" or "TẮT")
    btn.BackgroundColor3 = def and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(130, 0, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        def = not def
        btn.Text = name .. ": " .. (def and "BẬT" or "TẮT")
        btn.BackgroundColor3 = def and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(130, 0, 40)
        cb(def)
    end)
end

-- SETUP MENU
createLabel("--- MOVEMENT & PVP ---", UDim2.new(0,0,0,10), 24, main).TextColor3 = Color3.new(0,1,1)
CreateToggle("CHẾ ĐỘ BAY", 60, false, function(v) flying = v end)
CreateToggle("AUTO TELE ĐỊCH", 120, false, function(v) auto_tele = v end)

createLabel("--- ESP SETTINGS ---", UDim2.new(0,0,0,180), 24, main).TextColor3 = Color3.new(0,1,0)
CreateToggle("BẬT ESP (FULL SKELETON)", 230, false, function(v) esp_player = v end)
CreateToggle("ESP TRÁI ÁC QUỶ", 290, false, function(v) esp_fruit = v end)

createLabel("--- AUTO FEATURES ---", UDim2.new(0,0,0,350), 24, main).TextColor3 = Color3.new(1,0,1)
CreateToggle("AUTO NHẶT TRÁI", 400, false, function(v) auto_get_fruit = v end)
CreateToggle("AUTO CẤT TRÁI (STORE)", 460, false, function(v) auto_store = v end)
CreateToggle("AUTO RACE V3 (T)", 520, false, function(v) auto_v3 = v end)
CreateToggle("AUTO RACE V4 (Y)", 580, false, function(v) auto_v4 = v end)

-- #######################################################
-- # HỆ THỐNG SKELETON ESP & STATS                       #
-- #######################################################
local function CreateSkeleton(char)
    if not char:FindFirstChild("HumanoidRootPart") then return end
    local folder = Instance.new("Folder", char.HumanoidRootPart)
    folder.Name = "SkeleFolder"

    local function createLine(p1, p2)
        local line = Instance.new("Adornment", folder)
        if p1 and p2 then
            local beam = Instance.new("BoxHandleAdornment", folder)
            beam.Size = Vector3.new(0.2, 0.2, (char[p1].Position - char[p2].Position).Magnitude)
            beam.AlwaysOnTop = true
            beam.ZIndex = 10
            beam.Color3 = Color3.new(1, 1, 1)
            beam.Adornee = char[p1]
            
            run.RenderStepped:Connect(function()
                if char:FindFirstChild(p1) and char:FindFirstChild(p2) then
                    local dist = (char[p1].Position - char[p2].Position).Magnitude
                    beam.Size = Vector3.new(0.15, 0.15, dist)
                    beam.CFrame = CFrame.new(char[p1].Position:Lerp(char[p2].Position, 0.5), char[p2].Position)
                else
                    beam:Destroy()
                end
            end)
        end
    end

    -- Vẽ các khớp xương (R15)
    local joints = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
    }
    for _, v in pairs(joints) do pcall(function() createLine(v[1], v[2]) end) end
end

run.RenderStepped:Connect(function()
    if not active then return end
    for _, pl in pairs(players:GetPlayers()) do
        if pl ~= p and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            local char = pl.Character
            local hrp = char.HumanoidRootPart
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            -- Vẽ Stats (Tên, Máu, Năng lượng)
            local gui = hrp:FindFirstChild("ESP_STATS")
            if esp_player then
                if not gui then
                    gui = Instance.new("BillboardGui", hrp)
                    gui.Name = "ESP_STATS"
                    gui.Size = UDim2.new(0, 200, 0, 100)
                    gui.AlwaysOnTop = true
                    gui.ExtentsOffset = Vector3.new(0, 3, 0)
                    local l = Instance.new("TextLabel", gui)
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.BackgroundTransparency = 1
                    l.TextColor3 = Color3.new(1, 1, 1)
                    l.Font = Enum.Font.SciFi
                    l.TextSize = 14
                end
                
                local energy = pl:FindFirstChild("Data") and pl.Data:FindFirstChild("Energy") and pl.Data.Energy.Value or "N/A"
                gui.TextLabel.Text = string.format("%s\nHP: %d/%d\nEN: %s\n[%dm]", 
                    pl.Name, hum.Health, hum.MaxHealth, tostring(energy), 
                    math.floor((p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude))
                
                -- Vẽ Skeleton
                if not hrp:FindFirstChild("SkeleFolder") then CreateSkeleton(char) end
            else
                if gui then gui:Destroy() end
                if hrp:FindFirstChild("SkeleFolder") then hrp.SkeleFolder:Destroy() end
            end
        end
    end
end)

-- #######################################################
-- # AUTO FEATURES LOGIC                                 #
-- #######################################################

-- Auto Store & Race
task.spawn(function()
    while task.wait(0.5) do
        if not active then break end
        if auto_store then
            pcall(function()
                for _, v in pairs(p.Backpack:GetChildren()) do
                    if v.Name:find("Fruit") then game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", v:GetAttribute("FruitName"), v) end
                end
            end)
        end
        if auto_v3 then vim:SendKeyEvent(true, "T", false, game) task.wait() vim:SendKeyEvent(false, "T", false, game) end
        if auto_v4 then vim:SendKeyEvent(true, "Y", false, game) task.wait() vim:SendKeyEvent(false, "Y", false, game) end
    end
end)

-- Fruit Logic
run.Heartbeat:Connect(function()
    if not active then return end
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
            if auto_get_fruit and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.CFrame = v:GetModelCFrame() or v.Handle.CFrame
            end
        end
    end
end)

-- Movement (Fly & Speed)
run.Stepped:Connect(function()
    if not active or not p.Character then return end
    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        if flying then
            local bv = hrp:FindFirstChild("FlyVel") or Instance.new("BodyVelocity", hrp)
            bv.Name = "FlyVel"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            local move = Vector3.new(0,0,0)
            if uis:IsKeyDown(Enum.KeyCode.W) then move = move + workspace.CurrentCamera.CFrame.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then move = move - workspace.CurrentCamera.CFrame.LookVector end
            bv.Velocity = move * 100
            hum.PlatformStand = true
        else
            if hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end
            hum.PlatformStand = false
        end
        if auto_tele and target_player and target_player.Character:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = target_player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
        end
    end
end)

print("Sang Executor - ESP & Skeleton Loaded!")
