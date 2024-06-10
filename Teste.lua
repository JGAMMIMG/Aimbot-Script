-- Lista de coordenadas
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

-- Variável para armazenar o índice atual
local currentIndex = 1

-- Distância mínima para considerar que o jogador atingiu a posição
local minDistance = 5

-- Função para teleportar o jogador para a próxima coordenada na lista
local function teleportPlayer(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local targetPosition = coordinates[currentIndex]
        player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        print("Jogador teleportado para: " .. tostring(targetPosition))
    else
        warn("O jogador ou a parte do humanoide não foi encontrada.")
    end
end

-- Função para verificar a distância do jogador até a coordenada
local function checkDistance(player)
    if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local playerPosition = player.Character.HumanoidRootPart.Position
        local targetPosition = coordinates[currentIndex]
        local distance = (playerPosition - targetPosition).Magnitude

        if distance <= minDistance then
            -- Avança para a próxima coordenada
            currentIndex = currentIndex + 1
            if currentIndex > #coordinates then
                currentIndex = 1 -- Reinicia para a primeira coordenada se todas tiverem sido usadas
            end

            -- Teleporta o jogador para a próxima coordenada
            teleportPlayer(player)
        end
    end
end

-- Assumindo que este script é executado ao adicionar um jogador
game.Players.PlayerAdded:Connect(function(player)
    teleportPlayer(player)

    -- Verifica a distância periodicamente
    while true do
        task.wait(1)
        checkDistance(player)
    end
end)
