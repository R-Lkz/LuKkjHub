-- --- CONFIGURAÇÕES ---
local fov = 39 -- FOV aumentado para um aimbot mais "forte"
local smoothing = 0.8 -- QUANTO MAIOR, MAIS FORTE PUXA (0.1 a 1.0)
local fovVisible = false
local immunityDistance = 25 -- Aprox 7 metros

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Cam = game.Workspace.CurrentCamera

local activeTargets = {}
-- Ignoramos pés (LowerTorso/Legs) para focar no que importa
local targetParts = {"Head", "UpperTorso", "HumanoidRootPart"}

-- --- INTERFACE DO HUB ---
local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "LuKkjHub"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 200)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "LuKkj Hub - Anti-Cheat?"
Title.BackgroundColor3 = Color3.fromRGB(75, 0, 130)
Title.TextColor3 = Color3.new(1,1,1)
Title.TextSize = 18

local Desc = Instance.new("TextLabel", MainFrame)
Desc.Size = UDim2.new(1, -20, 0, 80)
Desc.Position = UDim2.new(0, 10, 0, 45)
Desc.Text = "Feito por lukkj. Xitar é feio, mas como somos horrorosos, a gente apela. Use com moderação!"
Desc.TextColor3 = Color3.new(0.8, 0.8, 0.8)
Desc.TextWrapped = true
Desc.BackgroundTransparency = 1

local ApplyBtn = Instance.new("TextButton", MainFrame)
ApplyBtn.Size = UDim2.new(1, -20, 0, 40)
ApplyBtn.Position = UDim2.new(0, 10, 1, -50)
ApplyBtn.Text = "APLICAR (IMUNIDADE 7M)"
ApplyBtn.BackgroundColor3 = Color3.fromRGB(128, 0, 128)
ApplyBtn.TextColor3 = Color3.new(1,1,1)

-- Toggle Tecla U
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.U then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- --- LÓGICA DE ALVOS ---
ApplyBtn.MouseButton1Click:Connect(function()
    activeTargets = {}
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if root then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                if dist > immunityDistance then
                    activeTargets[p.Name] = true
                end
            end
        end
        ApplyBtn.Text = "APLICADO!"
        task.wait(1)
        ApplyBtn.Text = "RE-APLICAR SELEÇÃO"
    end
end)

-- --- LÓGICA DO AIMBOT ---
local FOVring = Drawing.new("Circle")
FOVring.Visible = fovVisible
FOVring.Thickness = 1
FOVring.Color = Color3.fromRGB(255, 0, 0)
FOVring.Radius = fov

local function isVisible(part, character)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(Cam.CFrame.Position, part.Position - Cam.CFrame.Position, raycastParams)
    return result == nil
end

local function getBestTarget()
    local nearestPart = nil
    local minDistance = fov

    for name, _ in pairs(activeTargets) do
        local p = Players:FindFirstChild(name)
        if p and p.Character then
            -- Tenta achar qualquer parte visível que não seja o pé
            for _, partName in ipairs(targetParts) do
                local part = p.Character:FindFirstChild(partName)
                if part then
                    local ePos, onScreen = Cam:WorldToViewportPoint(part.Position)
                    if onScreen and ePos.Z > 0 then
                        local screenDist = (Vector2.new(ePos.x, ePos.y) - (Cam.ViewportSize / 2)).Magnitude
                        if screenDist < minDistance and isVisible(part, p.Character) then
                            minDistance = screenDist
                            nearestPart = part
                        end
                    end
                end
            end
        end
    end
    return nearestPart
end

RunService.RenderStepped:Connect(function()
    FOVring.Position = Cam.ViewportSize / 2
    
    if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getBestTarget()
        if target then
            -- Aimbot puxando forte com base na variável 'smoothing'
            local lookVector = (target.Position - Cam.CFrame.Position).unit
            local targetCFrame = CFrame.new(Cam.CFrame.Position, Cam.CFrame.Position + lookVector)
            Cam.CFrame = Cam.CFrame:Lerp(targetCFrame, smoothing)
        end
    end
end)
