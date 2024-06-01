-- Serviços necessários
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Variáveis de controle
local ESPEnabled = true
local AIMEnabled = false
local ESPColor = Color3.fromRGB(255, 0, 0) -- Vermelho para inimigos
local FOVRadius = 300
local arrowSize = Vector3.new(2, 2, 2)
local sensitivity = 1 -- Sensibilidade padrão
local target = nil

-- Função para encontrar a HumanoidRootPart de um modelo de jogador ou NPC
local function FindHumanoidRootPart(model)
    return model and model:FindFirstChild("HumanoidRootPart")
end

-- Função para encontrar a cabeça de um modelo de jogador
local function FindHead(model)
    return model and model:FindFirstChild("Head")
end

-- Função para criar ESP para um jogador
local function createESP(player)
    local character = player.Character
    if character then
        local highlight = Instance.new("Highlight")
        highlight.Parent = character
        highlight.Adornee = character
        highlight.FillColor = ESPColor
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = ESPColor
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
end

-- Função para remover ESP de um jogador
local function removeESP(player)
    local character = player.Character
    if character then
        for _, highlight in pairs(character:GetChildren()) do
            if highlight:IsA("Highlight") then
                highlight:Destroy()
            end
        end
    end
end

-- Função para verificar o time
local function getTeam(player)
    return player.Team
end

-- Função principal do ESP
local function updateESP()
    if not ESPEnabled then return end

    local localPlayer = Players.LocalPlayer
    local localTeam = getTeam(localPlayer)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer then
            if getTeam(player) ~= localTeam then
                createESP(player)
            else
                removeESP(player)
            end
        end
    end
end

-- Função para desenhar setas apontando para inimigos fora da tela
local function updateArrows()
    for _, arrow in pairs(Workspace:GetChildren()) do
        if arrow:IsA("Part") and arrow.Name == "ESPArrow" then
            arrow:Destroy()
        end
    end

    local localPlayer = Players.LocalPlayer
    local localTeam = getTeam(localPlayer)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and getTeam(player) ~= localTeam and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local enemyPosition, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if not onScreen then
                local arrow = Instance.new("Part")
                arrow.Name = "ESPArrow"
                arrow.Size = arrowSize
                arrow.Anchored = true
                arrow.CanCollide = false
                arrow.Color = ESPColor
                arrow.Position = localPlayer.Character.HumanoidRootPart.Position + (enemyPosition - localPlayer.Character.HumanoidRootPart.Position).Unit * 5
                arrow.CFrame = CFrame.new(arrow.Position, localPlayer.Character.HumanoidRootPart.Position)
                arrow.Parent = Workspace
            end
        end
    end
end

-- Função para alternar o ESP
local function toggleESP()
    ESPEnabled = not ESPEnabled
    if not ESPEnabled then
        for _, player in pairs(Players:GetPlayers()) do
            removeESP(player)
        end
    end
end

-- Função para verificar se há linha de visão desobstruída para o alvo
local function isVisible(targetPosition)
    local rayOrigin = Camera.CFrame.Position
    local rayDirection = (targetPosition - rayOrigin).Unit * 500
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if raycastResult then
        return false
    else
        return true
    end
end

-- Função para encontrar o alvo mais próximo visível
local function GetNearestVisibleTarget()
    local localPlayer = Players.LocalPlayer
    local localTeam = localPlayer.Team
    local targets = {}

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and (not localTeam or player.Team ~= localTeam) then
            local humanoidRootPart = FindHumanoidRootPart(player.Character)
            local head = FindHead(player.Character)
            if humanoidRootPart and head then
                table.insert(targets, {rootPart = humanoidRootPart, head = head})
            end
        end
    end

    local closestTarget = nil
    local minDistance = math.huge

    for _, targetInfo in ipairs(targets) do
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetInfo.head.Position)
        if onScreen and isVisible(targetInfo.head.Position) then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if distance < minDistance then
                minDistance = distance
                closestTarget = targetInfo.head
            end
        end
    end

    return closestTarget
end

-- Função para mirar no alvo
local function AimAtTarget()
    if target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
    end
end

-- Função para alternar entre primeira e terceira pessoa ao pressionar a tecla F
local function ToggleCameraMode()
    local player = Players.LocalPlayer
    if player.CameraMode == Enum.CameraMode.LockFirstPerson then
        player.CameraMode = Enum.CameraMode.Classic
    else
        player.CameraMode = Enum.CameraMode.LockFirstPerson
    end
end

-- Função para processar a entrada do botão direito do mouse
local function OnMouseRightButtonDown()
    AIMEnabled = true
    target = GetNearestVisibleTarget()
    if target then
        AimAtTarget()
    end
end

-- Função para processar a liberação do botão direito do mouse
local function OnMouseRightButtonUp()
    AIMEnabled = false
    target = nil
end

-- Função para criar botões para dispositivos móveis
local function CreateMobileButtons()
    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

    local mobileGui = Instance.new("ScreenGui", playerGui)
    mobileGui.Name = "MobileControls"

    local aimButton = Instance.new("TextButton", mobileGui)
    aimButton.Size = UDim2.new(0.2, 0, 0.1, 0)
    aimButton.Position = UDim2.new(0.012, 0, 0.243, 0)
    aimButton.Text = "Aimbot - ON/OFF"
    aimButton.BackgroundColor3 = Color3.fromRGB(98, 0, 0)
    aimButton.Font = Enum.Font.SourceSansBold
    aimButton.TextSize = 22
    aimButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    aimButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    aimButton.TextStrokeTransparency = 0

    return mobileGui, aimButton
end

-- Criar controles para celular se o jogador estiver em um dispositivo móvel
if UserInputService.TouchEnabled then
    local mobileGui, aimButton = CreateMobileButtons()

    aimButton.MouseButton1Click:Connect(function()
        AIMEnabled = not AIMEnabled
        if AIMEnabled then
            target = GetNearestVisibleTarget()
            AimAtTarget()
        else
            target = nil
        end
    end)
end

-- Função para criar FOV
local function createFOV()
    local FOVCircle = Instance.new("Frame")
    FOVCircle.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
    FOVCircle.Position = UDim2.new(0.5, -FOVRadius, 0.5, -FOVRadius)
    FOVCircle.BackgroundTransparency = 1

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = FOVCircle

    local Border = Instance.new("Frame")
    Border.Size = UDim2.new(1, 0, 1, 0)
    Border.Position = UDim2.new(0, 0, 0, 0)
    Border.BackgroundColor3 = ESPColor
    Border.BorderSizePixel = 0
    Border.Parent = FOVCircle

    FOVCircle.Parent = LocalPlayer:WaitForChild("PlayerGui")
    return FOVCircle
end

local FOVCircle = createFOV()

-- Conexão de eventos
Mouse.Button2Down:Connect(OnMouseRightButtonDown)
Mouse.Button2Up:Connect(OnMouseRightButtonUp)

RunService.RenderStepped:Connect(function()
    if AIMEnabled then
        target = GetNearestVisibleTarget()
        AimAtTarget()
    end
end)

Players.PlayerAdded:Connect(updateESP)
Players.PlayerRemoving:Connect(updateESP)
RunService.RenderStepped:Connect(function()
    updateESP()
    FOVCircle.Visible = ESPEnabled
    updateArrows()
end)

-- Criar um botão de ativação/desativação na interface
local ScreenGui = Instance.new("ScreenGui")
local ToggleButton = Instance.new("TextButton")

ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.Name = "ESPUI"

ToggleButton.Parent = ScreenGui
ToggleButton.Size = UDim2.new(0.2, 0, 0.1, 0)
ToggleButton.Position = UDim2.new(0.012, 0, 0.385, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(98, 0, 0)
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.Text = "ESP - ON/OFF"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 22

ToggleButton.MouseButton1Click:Connect(toggleESP)
