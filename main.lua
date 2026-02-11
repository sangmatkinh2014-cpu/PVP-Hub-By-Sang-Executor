local p = game:GetService("Players").LocalPlayer
local run = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local players = game:GetService("Players")
local mouse = p:GetMouse()
local vim = game:GetService("VirtualInputManager") 

-- Xóa menu cũ để tránh ghi đè
local pgui = p:WaitForChild("PlayerGui")
if pgui:FindFirstChild("UltraMenu") then pgui.UltraMenu:Destroy() end

local sg = Instance.new("ScreenGui", pgui)
sg.Name = "UltraMenu"
sg.ResetOnSpawn = false

-- BIẾN ĐIỀU KHIỂN
local s_val, j_val, f_val = 0, 50, 50
local flying, auto_tele = false, false
local auto_z, auto_x, auto_c, auto_v = false, false, false, false
local esp_player, esp_fruit = false, false 
local auto_get_fruit, auto_store = false, false
local auto_v3, auto_v4 = false, false
local target_player = nil
local active = true 

-- #######################################################
-- # GIAO DIỆN (UI)                                      #
-- #######################################################
local main = Instance.new("ScrollingFrame", sg)
main.Size = UDim2.new(0, 500, 0, 600)
main.Position = UDim2.new(0.5, -250, 0.5, -300)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
main.CanvasSize = UDim2.new(0, 0, 6, 0)
main.ScrollBarThickness = 8
main.Visible = true
main.Active = true
Instance.new("UICorner", main)

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

local function CreateToggle(name, y, def, cb)
    local btn = Instance.new("TextButton", main)
    btn.Size = UDim2.new(0.85, 0, 0, 50)
    btn.Position = UDim2.new(0.075, 0, 0, y)
    btn.Text = name .. ": " .. (def and "BẬT" or "TẮT")
    btn.BackgroundColor3 = def and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(130, 0, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SciFi
    btn.TextSize = 20
    Instance.new("UICorner", btn)
    btn.MouseButton1Click:Connect(function()
        def = not def
        btn.Text = name .. ": " .. (def and "BẬT" or "TẮT")
        btn.BackgroundColor3 = def and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(130, 0, 40)
        cb(def)
    end)
end

-- SETUP MENU
createLabel("PVP Hub - Sang Executor", UDim2.new(0,0,0,10), 28, main).TextColor3 = Color3.new(0,1,1)

createLabel("--- ESP PLAYER SETTINGS ---", UDim2.new(0,0,0,60), 22, main).TextColor3 = Color3.new(1,1,0)
CreateToggle("BẬT ESP (Tên/HP/Năng Lượng/Dist)", 110, false, function(v) esp_player = v end)
CreateToggle("ESP TRÁI ÁC QUỶ", 170, false, function(v) esp_fruit = v end)

createLabel("--- AUTO & PVP ---", UDim2.new(0,0,0,240), 22, main).TextColor3 = Color3.new(0,1,0)
CreateToggle("AUTO TELE ĐỊCH", 290, false, function(v) auto_tele = v end)
CreateToggle("AUTO CẤT TRÁI (STORE)", 350, false, function(v) auto_store = v end)
CreateToggle("AUTO RACE V3 (T)", 410, false, function(v) auto_v3 = v end)
CreateToggle("AUTO RACE V4 (Y)", 470, false, function(v) auto_v4 = v end)

-- #######################################################
-- # HỆ THỐNG ESP PLAYER (STATS)                         #
-- #######################################################
run.RenderStepped:Connect(function()
    if not active then return end
    
    for _, pl in pairs(players:GetPlayers()) do
        if pl ~= p and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            local char = pl.Character
            local hrp = char.HumanoidRootPart
            local hum = char:FindFirstChildOfClass("Humanoid")
            
            local gui = hrp:FindFirstChild("SANG_ESP")
            
            if esp_player then
                if not gui then
                    gui = Instance.new("BillboardGui", hrp)
                    gui.Name = "SANG_ESP"
                    gui.Size = UDim2.new(0, 200, 0, 100)
                    gui.AlwaysOnTop = true
                    gui.ExtentsOffset = Vector3.new(0, 3, 0)
                    local l = Instance.new("TextLabel", gui)
                    l.Size = UDim2.new(1, 0, 1, 0)
                    l.BackgroundTransparency = 1
                    l.TextColor3 = Color3.new(1, 1, 1)
                    l.TextStrokeTransparency = 0
                    l.Font = Enum.Font.SciFi
                    l.TextSize = 16
                end
                
                -- Lấy năng lượng (Thường trong Blox Fruits là Data.Energy)
                local energy = "N/A"
                pcall(function()
                    if pl:FindFirstChild("Data") and pl.Data:FindFirstChild("Energy") then
                        energy = pl.Data.Energy.Value
                    end
                end)
                
                local dist = math.floor((p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                local hp = math.floor(hum.Health)
                local maxHp = math.floor(hum.MaxHealth)
                
                gui.TextLabel.Text = string.format(
                    "Name: %s\nHP: %d/%d\nEnergy: %s\nDistance: [%dm]",
                    pl.Name, hp, maxHp, tostring(energy), dist
                )
                
                -- Đổi màu theo máu
                if hp < maxHp * 0.3 then gui.TextLabel.TextColor3 = Color3.new(1, 0, 0)
                elseif hp < maxHp * 0.7 then gui.TextLabel.TextColor3 = Color3.new(1, 1, 0)
                else gui.TextLabel.TextColor3 = Color3.new(0, 1, 0) end
            else
                if gui then gui:Destroy() end
            end
        end
    end
end)

-- #######################################################
-- # CÁC TÍNH NĂNG AUTO KHÁC                             #
-- #######################################################

-- Auto Store & Race (T/Y)
task.spawn(function()
    while task.wait(0.5) do
        if not active then break end
        if auto_store then
            pcall(function()
                for _, v in pairs(p.Backpack:GetChildren()) do
                    if v.Name:find("Fruit") then 
                        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StoreFruit", v:GetAttribute("FruitName"), v) 
                    end
                end
            end)
        end
        if auto_v3 then vim:SendKeyEvent(true, "T", false, game) task.wait() vim:SendKeyEvent(false, "T", false, game) end
        if auto_v4 then vim:SendKeyEvent(true, "Y", false, game) task.wait() vim:SendKeyEvent(false, "Y", false, game) end
    end
end)

-- Nút đóng Menu
local closeBtn = Instance.new("TextButton", main)
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -45, 0, 5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.new(1,0,0)
closeBtn.TextColor3 = Color3.new(1,1,1)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() active = false end)

print("ESP Stats & Auto Features Loaded!")
