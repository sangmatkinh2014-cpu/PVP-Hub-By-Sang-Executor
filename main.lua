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

-- BIẾN ĐIỀU KHIỂN (GỐC + MỚI)
local s_val, j_val, f_val = 0, 50, 50
local flying, aim_player, auto_tele = false, false, false
local auto_z, auto_x, auto_c, auto_v = false, false, false, false
local esp_player, esp_fruit = false, false 
local auto_get_fruit = false 
local auto_store = false -- Mới
local auto_v3 = false    -- Mới
local auto_v4 = false    -- Mới
local target_player = nil
local active = true 

-- #######################################################
-- # NÚT MỞ MENU (GIỮ NGUYÊN GỐC)                        #
-- #######################################################
local toggle = Instance.new("TextButton", sg)
toggle.Size = UDim2.new(0, 80, 0, 80)
toggle.Position = UDim2.new(0, 15, 0.5, -40)
toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
toggle.Text = ""
toggle.Draggable = true
toggle.Active = true
Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
local stroke = Instance.new("UIStroke", toggle)
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 2

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
createLabel("Sang", UDim2.new(0,0,0.1,0), 20, toggle)
createLabel("Executor", UDim2.new(0,0,0.45,0), 14, toggle).TextColor3 = Color3.fromRGB(150, 255, 255)

-- #######################################################
-- # KHUNG CHÍNH (TĂNG CANVAS ĐỂ CHỨA THÊM)               #
-- #######################################################
local main = Instance.new("ScrollingFrame", sg)
main.Size = UDim2.new(0, 500, 0, 600)
main.Position = UDim2.new(0.5, -250, 0.5, -300)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.BorderSizePixel = 0
main.CanvasSize = UDim2.new(0, 0, 6.5, 0) -- Tăng thêm chỗ cuộn
main.ScrollBarThickness = 8
main.Visible = true
main.Active = true
Instance.new("UICorner", main)

local hubTitle = createLabel("PVP Hub By Sang Executor", UDim2.new(0,0,0,10), 28, main)
hubTitle.TextColor3 = Color3.fromRGB(0, 255, 255)

local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0, 45, 0, 45)
closeBtn.Position = UDim2.new(1, -55, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.SciFi
closeBtn.TextSize = 25
Instance.new("UICorner", closeBtn)
closeBtn.MouseButton1Click:Connect(function() active = false sg:Destroy() end)

toggle.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

-- HÀM TẠO UI (GIỮ NGUYÊN GỐC)
local function CreateSlider(name, y, min, max, def, cb)
    local lab = createLabel(name .. ": " .. def, UDim2.new(0, 0, 0, y), 22, main)
    local bar = Instance.new("Frame", main)
    bar.Size = UDim2.new(0.8, 0, 0, 12)
    bar.Position = UDim2.new(0.1, 0, 0, y + 50)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    local dot = Instance.new("TextButton", bar)
    dot.Size = UDim2.new(0, 35, 0, 35)
    dot.Position = UDim2.new((def-min)/(max-min), -17, 0.5, -17)
    dot.Text = ""
    dot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local dragging = false
    dot.MouseButton1Down:Connect(function() dragging = true end)
    uis.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    run.RenderStepped:Connect(function()
        if dragging and active then
            local x = math.clamp((mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            dot.Position = UDim2.new(x, -17, 0.5, -17)
            local v = math.floor(min + (x * (max - min)))
            lab.Text = name .. ": " .. v
            cb(v)
        end
    end)
end

local function CreateToggle(name, y, def, cb)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0.85, 0, 0, 55)
    btn.Position = UDim2.new(0.075, 0, 0, y)
    btn.Text = name .. ": " .. (def and "BẬT" or "TẮT")
    btn.Font = Enum.Font.SciFi
    btn.TextSize = 22
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = def and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(130, 0, 40)
    Instance.new("UICorner", btn)
    local state = def
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "BẬT" or "TẮT")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(130, 0, 40)
        cb(state)
    end)
    return btn
end

-- #######################################################
-- # KHU VỰC CÁC NÚT (GIỮ GỐC + THÊM MỚI)                #
-- #######################################################

-- 1. Các Slider cũ
CreateSlider("TỐC ĐỘ (BOOST)", 70, 0, 150, 0, function(v) s_val = v end)
CreateSlider("NHẢY CAO", 150, 50, 500, 50, function(v) j_val = v end)
CreateSlider("TỐC ĐỘ BAY", 230, 10, 500, 50, function(v) f_val = v end)

-- 2. Các Toggle cũ
CreateToggle("CHẾ ĐỘ BAY", 320, false, function(v) flying = v end)
CreateToggle("AIM PLAYER", 385, false, function(v) aim_player = v end)
CreateToggle("AUTO TELEPORT ĐỊCH", 450, false, function(v) auto_tele = v end)

-- 3. ESP & Fruit (Mới + Cũ)
local espTitle = createLabel("--- ESP & FRUIT SETTINGS ---", UDim2.new(0,0,0,520), 24, main)
espTitle.TextColor3 = Color3.fromRGB(0, 200, 255)
CreateToggle("ESP PLAYER (Tên/HP/E/Dist)", 570, false, function(v) esp_player = v end) -- Cập nhật hiển thị mới
CreateToggle("ESP FRUIT (Trái Ác Quỷ)", 635, false, function(v) esp_fruit = v end)
CreateToggle("AUTO TELE TO FRUIT", 700, false, function(v) auto_get_fruit = v end)
CreateToggle("AUTO STORE FRUIT (Lưu Kho)", 765, false, function(v) auto_store = v end) -- Thêm mới

-- 4. Race Awakening (Thêm mới)
local awkTitle = createLabel("--- RACE AWAKENING ---", UDim2.new(0,0,0,840), 24, main)
awkTitle.TextColor3 = Color3.fromRGB(255, 0, 255)
CreateToggle("AUTO BẬT RACE V3 (T)", 890, false, function(v) auto_v3 = v end) -- Thêm mới
CreateToggle("AUTO BẬT RACE V4 (Y)", 955, false, function(v) auto_v4 = v end) -- Thêm mới

-- 5. Skill (Giữ cũ)
local skillTitle = createLabel("--- AUTO SKILL SETTINGS ---", UDim2.new(0,0,0,1030), 24, main)
skillTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
CreateToggle("Auto Skill [Z]", 1080, false, function(v) auto_z = v end)
CreateToggle("Auto Skill [X]", 1145, false, function(v) auto_x = v end)
CreateToggle("Auto Skill [C]", 1210, false, function(v) auto_c = v end)
CreateToggle("Auto Skill [V]", 1275, false, function(v) auto_v = v end)

-- 6. Player List (Giữ cũ)
local selectBtn = Instance.new("TextButton", main)
selectBtn.Size = UDim2.new(0.85, 0, 0, 55)
selectBtn.Position = UDim2.new(0.075, 0, 0, 1360)
selectBtn.Text = "DANH SÁCH NGƯỜI CHƠI (MỞ)"
selectBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
selectBtn.TextColor3 = Color3.new(1, 1, 1)
selectBtn.Font = Enum.Font.SciFi
selectBtn.TextSize = 22
Instance.new("UICorner", selectBtn)

local pFrame = Instance.new("Frame", main)
pFrame.Size = UDim2.new(0.85, 0, 0, 350)
pFrame.Position = UDim2.new(0.075, 0, 0, 1425)
pFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
pFrame.Visible = false 
Instance.new("UICorner", pFrame)

local pScroll = Instance.new("ScrollingFrame", pFrame)
pScroll.Size = UDim2.new(1, 0, 0.75, 0)
pScroll.Position = UDim2.new(0,0,0.05,0)
pScroll.BackgroundTransparency = 1
pScroll.CanvasSize = UDim2.new(0,0,0,0)
pScroll.ScrollBarThickness = 6
local layout = Instance.new("UIListLayout", pScroll)
layout.Padding = UDim.new(0, 8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local refreshBtn = Instance.new("TextButton", pFrame)
refreshBtn.Size = UDim2.new(0.9, 0, 0, 45)
refreshBtn.Position = UDim2.new(0.05, 0, 0.82, 0)
refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
refreshBtn.Text = "TẢI LẠI DANH SÁCH"
refreshBtn.TextColor3 = Color3.new(1, 1, 1)
refreshBtn.Font = Enum.Font.SciFi
refreshBtn.TextSize = 20
Instance.new("UICorner", refreshBtn)

-- #######################################################
-- # LOGIC HỆ THỐNG (GIỮ GỐC + CHÈN THÊM)                #
-- #######################################################

-- Logic ESP Player (Tên, HP, E, Dist)
run.RenderStepped:Connect(function()
    if not active then return end
    for _, pl in pairs(players:GetPlayers()) do
        if pl ~= p and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = pl.Character.HumanoidRootPart
            local hum = pl.Character:FindFirstChildOfClass("Humanoid")
            local espName = hrp:FindFirstChild("ESP_UI")
            if esp_player then
                if not espName then
                    espName = Instance.new("BillboardGui", hrp)
                    espName.Name = "ESP_UI"
                    espName.Size = UDim2.new(0, 150, 0, 80)
                    espName.AlwaysOnTop = true
                    espName.ExtentsOffset = Vector3.new(0, 3, 0)
                    local label = Instance.new("TextLabel", espName)
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.TextColor3 = Color3.new(1, 1, 1)
                    label.TextStrokeTransparency = 0
                    label.Font = Enum.Font.SciFi
                    label.TextSize = 15
                end
                -- Lấy Energy (Blox Fruits)
                local energy = "N/A"
                pcall(function() if pl:FindFirstChild("Data") and pl.Data:FindFirstChild("Energy") then energy = pl.Data.Energy.Value end end)
                local dist = math.floor((p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                
                espName.TextLabel.Text = string.format("%s\nHP: %d/%d\nE: %s\n[%dm]", pl.Name, hum.Health, hum.MaxHealth, tostring(energy), dist)
                
                if hum.Health < hum.MaxHealth * 0.3 then espName.TextLabel.TextColor3 = Color3.new(1,0,0)
                elseif hum.Health < hum.MaxHealth * 0.7 then espName.TextLabel.TextColor3 = Color3.new(1,1,0)
                else espName.TextLabel.TextColor3 = Color3.new(0,1,0) end
            else
                if espName then espName:Destroy() end
            end
        end
    end

    -- Fruit Logic
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
            if esp_fruit then
                if not v:FindFirstChild("Fruit_ESP") then
                    local bg = Instance.new("BillboardGui", v)
                    bg.Name = "Fruit_ESP"
                    bg.Size = UDim2.new(0, 100, 0, 40)
                    bg.AlwaysOnTop = true
                    local tl = Instance.new("TextLabel", bg)
                    tl.Size = UDim2.new(1, 0, 1, 0)
                    tl.BackgroundTransparency = 1
                    tl.Text = "🍎 " .. v.Name
                    tl.TextColor3 = Color3.fromRGB(255, 100, 0)
                    tl.Font = Enum.Font.SciFi
                    tl.TextSize = 18
                end
            end
            if auto_get_fruit and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local fruit_pos = v:GetModelCFrame() or (v:FindFirstChild("Handle") and v.Handle.CFrame)
                if fruit_pos then p.Character.HumanoidRootPart.CFrame = fruit_pos end
            end
        end
    end
end)

-- Logic Di chuyển & Bay (Giữ gốc)
run.Stepped:Connect(function()
    if not active then return end
    local char = p.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum then
        hum.UseJumpPower = true 
        hum.JumpPower = j_val
        if flying and hrp then
            local bv = hrp:FindFirstChild("FlyVel") or Instance.new("BodyVelocity", hrp)
            bv.Name = "FlyVel"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            local move = Vector3.new(0,0,0)
            local cam = workspace.CurrentCamera.CFrame
            if uis:IsKeyDown(Enum.KeyCode.W) then move = move + cam.LookVector end
            if uis:IsKeyDown(Enum.KeyCode.S) then move = move - cam.LookVector end
            bv.Velocity = move * f_val
            hum.PlatformStand = true
        else
            if hrp and hrp:FindFirstChild("FlyVel") then hrp.FlyVel:Destroy() end
            hum.PlatformStand = false
            if s_val > 0 and hum.MoveDirection.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (hum.MoveDirection * (s_val / 25))
            end
        end
        if auto_tele and target_player and target_player.Character and target_player.Character:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = target_player.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
        end
    end
end)

-- Logic Auto Skill & Auto Store & Auto Race (Kết hợp)
task.spawn(function()
    while active do
        -- Auto Skill (Giữ gốc)
        local target_hrp = target_player and target_player.Character and target_player.Character:FindFirstChild("HumanoidRootPart")
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and target_hrp then
            if (p.Character.HumanoidRootPart.Position - target_hrp.Position).Magnitude < 15 then
                if auto_z then vim:SendKeyEvent(true, "Z", false, game) task.wait() vim:SendKeyEvent(false, "Z", false, game) end
                if auto_x then vim:SendKeyEvent(true, "X", false, game) task.wait() vim:SendKeyEvent(false, "X", false, game) end
                if auto_c then vim:SendKeyEvent(true, "C", false, game) task.wait() vim:SendKeyEvent(false, "C", false, game) end
                if auto_v then vim:SendKeyEvent(true, "V", false, game) task.wait() vim:SendKeyEvent(false, "V", false, game) end
            end
        end

        -- Auto Store (Thêm mới)
        if auto_store then
            pcall(function()
                for _, tool in pairs(p.Backpack:GetChildren()) do
                    if tool.Name:find("Fruit") then game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", tool:GetAttribute("FruitName"), tool) end
                end
            end)
        end

        -- Auto Race (Thêm mới)
        if auto_v3 then vim:SendKeyEvent(true, "T", false, game) task.wait() vim:SendKeyEvent(false, "T", false, game) end
        if auto_v4 then vim:SendKeyEvent(true, "Y", false, game) task.wait() vim:SendKeyEvent(false, "Y", false, game) end

        task.wait(0.1)
    end
end)

-- Update Player List (Giữ gốc)
local function UpdateList()
    for _, child in pairs(pScroll:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    for _, pl in pairs(players:GetPlayers()) do
        if pl ~= p then
            local b = Instance.new("TextButton", pScroll)
            b.Size = UDim2.new(0.9, 0, 0, 50)
            b.Text = pl.Name 
            b.Font = Enum.Font.SciFi
            b.TextSize = 20
            b.BackgroundColor3 = (target_player == pl) and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(45, 45, 45)
            b.TextColor3 = Color3.new(1, 1, 1)
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(function() target_player = pl UpdateList() end)
        end
    end
    pScroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end

refreshBtn.MouseButton1Click:Connect(UpdateList)
selectBtn.MouseButton1Click:Connect(function()
    pFrame.Visible = not pFrame.Visible
    selectBtn.Text = pFrame.Visible and "DANH SÁCH NGƯỜI CHƠI (ĐÓNG)" or "DANH SÁCH NGƯỜI CHƠI (MỞ)"
    if pFrame.Visible then UpdateList() end
end)

UpdateList()
