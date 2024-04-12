local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera
local Mouse = Players.LocalPlayer:GetMouse()

local target = nil
local aiming = false
local sensitivity = 1 -- Sensibilidade padrão

-- Função para encontrar o objeto HumanoidRootPart de um modelo de jogador ou NPC
local function FindHumanoidRootPart(model)
    return model and model:FindFirstChild("HumanoidRootPart")
end

-- Função para encontrar o alvo mais próximo visível
local function GetNearestVisibleTarget()
    local targets = {}

    -- Adiciona jogadores à lista de alvos, excluindo o jogador local e NPCs
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local humanoidRootPart = FindHumanoidRootPart(player.Character)
            if humanoidRootPart then
                table.insert(targets, humanoidRootPart)
            end
        end
    end

    -- Encontra o alvo mais próximo visível
    local closestTarget = nil
    local minDistance = math.huge

    for _, targetPart in ipairs(targets) do
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
        if onScreen then
            local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
            if distance < minDistance then
                minDistance = distance
                closestTarget = targetPart
            end
        end
    end

    return closestTarget
end

-- Função para mirar no alvo
local function AimAtTarget()
    if target then
        local headPosition = target.Position + Vector3.new(0, target.Parent.Head.Size.Y, 0)
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPosition)
    end
end

-- Função para alternar entre primeira e terceira pessoa ao pressionar a tecla F
local function ToggleCameraMode()
    if Players.LocalPlayer.CameraMode == Enum.CameraMode.LockFirstPerson then
        Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
    else
        Players.LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
    end
end

-- Função para processar a entrada do botão direito do mouse
local function OnMouseRightButtonDown()
    aiming = true
    target = GetNearestVisibleTarget()
    if target then
        AimAtTarget()
    end
end

-- Função para processar a liberação do botão direito do mouse
local function OnMouseRightButtonUp()
    aiming = false
    target = nil
end

-- Conectar eventos do mouse aos manipuladores de eventos
Mouse.Button2Down:Connect(OnMouseRightButtonDown)
Mouse.Button2Up:Connect(OnMouseRightButtonUp)

-- Conectar a tecla F à função de alternância do modo de câmera
Mouse.KeyDown:Connect(function(key)
    if key == "f" or key == "F" then
        ToggleCameraMode()
    end
end)

-- Atualizar a mira se o jogador estiver mirando e o alvo estiver visível
game:GetService("RunService").RenderStepped:Connect(function()
    if aiming then
        target = GetNearestVisibleTarget()
        AimAtTarget()
    end
end)
