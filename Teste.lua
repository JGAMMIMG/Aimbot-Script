getgenv().teleport = true

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local TweenService = game:GetService('TweenService')

local coordinates = {
    Vector3.new(1502.1358642578125, 6.804904937744141, 353.610595703125),
    Vector3.new(-198.3150177001953, 6.7924957275390625, 733.0482788085938),
    Vector3.new(-424.7289733886719, 6.802382946014404, 632.3264770507812),
    Vector3.new(59.043880462646484, 6.822235584259033, 2060.05810546875),
    Vector3.new(1896.5364990234375, 6.815308570861816, 3631.830810546875),
    Vector3.new(4425.04443359375, 6.818443298339844, 3631.565185546875),
    Vector3.new(5573.07470703125, 6.8360981941223145, 3632.450927734375),
    Vector3.new(6410.06591796875, 15.339838981628418, 1891.790283203125),
    Vector3.new(6208.4111328125, 6.8275604248046875, 385.2886047363281),
    Vector3.new(3594.738525390625, 6.822550296783447, 18.177705764770508),
    Vector3.new(2896.74072265625, 6.837685585021973, -425.4273986816406)
}

local currentIndex = 1
local minDistance = 5

local function teleportToPosition(position)
    local seat = character:FindFirstChildOfClass("Seat") or character:FindFirstChildOfClass("VehicleSeat")
    local targetPart = seat or humanoidRootPart

    local currentCFrame = targetPart.CFrame
    local rotation = currentCFrame - currentCFrame.p

    local targetCFrame = CFrame.new(position) * rotation

    local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
    local tweenProperties = {
        CFrame = targetCFrame
    }

    local tween = TweenService:Create(targetPart, tweenInfo, tweenProperties)
    tween:Play()

    tween.Completed:Wait()
end

-- Função para garantir o movimento
local function forceMove()
    while getgenv().teleport and currentIndex <= #coordinates do
        local targetPosition = coordinates[currentIndex]
        teleportToPosition(targetPosition)

        -- Aguarda até que o jogador esteja próximo da posição desejada
        while (humanoidRootPart.Position - targetPosition).Magnitude > minDistance do
            wait(0.1)
        end

        currentIndex = currentIndex + 1
    end
end

-- Inicia o movimento forçado
forceMove()
