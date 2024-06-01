-- Carregar a biblioteca de UI
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/7yhx/kwargs_Ui_Library/main/source.lua"))()

local UI = Lib:Create{
    Theme = "Dark", -- ou qualquer outro tema
    Size = UDim2.new(0, 555, 0, 400) -- padrão
}

local Main = UI:Tab{
    Name = "Inicio"
}

local Divider = Main:Divider{
    Name = "Configurações de ESP"
}

local ESPEnabled = true

local ESPToggle = Main:Toggle{
    Name = "Ativar ESP",
    Default = ESPEnabled,
    Callback = function(state)
        ESPEnabled = state
        if not ESPEnabled then
            for _, player in pairs(game.Players:GetPlayers()) do
                removeESP(player)
            end
        end
    end
}

local QuitDivider = Main:Divider{
    Name = "Sair"
}

-- Configurações do ESP
local ESPColor = Color3.fromRGB(255, 0, 0) -- Vermelho para inimigos
local FOVRadius = 300
local arrowSize = Vector3.new(2, 2, 2)

-- Função para criar ESP para jogadores inimigos
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

-- Função para remover ESP
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
    
    local localPlayer = game.Players.LocalPlayer
    local localTeam = getTeam(localPlayer)
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer then
            if getTeam(player) ~= localTeam then
                createESP(player)
            else
                removeESP(player)
            end
        end
    end
end

-- Função para criar FOV
local function createFOV()
    local FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = ESPEnabled
    FOVCircle.Radius = FOVRadius
    FOVCircle.Thickness = 2
    FOVCircle.Color = ESPColor
    FOVCircle.Position = Vector2.new(workspace.CurrentCamera.ViewportSize.X / 2, workspace.CurrentCamera.ViewportSize.Y / 2)
    return FOVCircle
end

local FOVCircle = createFOV()

-- Função para desenhar setas apontando para inimigos fora da tela
local function updateArrows()
    for _, arrow in pairs(game.Workspace:GetChildren()) do
        if arrow:IsA("Part") and arrow.Name == "ESPArrow" then
            arrow:Destroy()
        end
    end
    
    local localPlayer = game.Players.LocalPlayer
    local localTeam = getTeam(localPlayer)
    
    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and getTeam(player) ~= localTeam and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local enemyPosition = workspace.CurrentCamera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if enemyPosition.Z < 0 then
                local arrow = Instance.new("Part")
                arrow.Name = "ESPArrow"
                arrow.Size = arrowSize
                arrow.Anchored = true
                arrow.CanCollide = false
                arrow.Color = ESPColor
                arrow.Position = workspace.CurrentCamera.CFrame:PointToWorldSpace(Vector3.new(enemyPosition.X, enemyPosition.Y, 0))
                arrow.Parent = workspace
            end
        end
    end
end

-- Conexão de eventos
game.Players.PlayerAdded:Connect(updateESP)
game.Players.PlayerRemoving:Connect(updateESP)
game:GetService("RunService").RenderStepped:Connect(function()
    updateESP()
    FOVCircle.Visible = ESPEnabled
    updateArrows()
end)

print("ESP script loaded. Use the toggle in the UI to enable/disable ESP.")
