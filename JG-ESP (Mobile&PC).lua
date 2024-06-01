-- Serviços necessários
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")
local Mouse = LocalPlayer:GetMouse()

-- Variável para controlar o estado do ESP
local ESPEnabled = true

-- Configurações do ESP
local ESPColor = Color3.fromRGB(255, 0, 0) -- Vermelho para inimigos
local FOVRadius = 300
local arrowSize = Vector3.new(2, 2, 2)

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

-- Função para desenhar setas apontando para inimigos fora da tela
local function updateArrows()
	for _, arrow in pairs(game.Workspace:GetChildren()) do
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
				arrow.Parent = game.Workspace
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
ToggleButton.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) -- Borda preta
ToggleButton.Text = "Toggle ESP"
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextSize = 22

ToggleButton.MouseButton1Click:Connect(toggleESP)

-- Conexão de eventos
Players.PlayerAdded:Connect(updateESP)
Players.PlayerRemoving:Connect(updateESP)
RunService.RenderStepped:Connect(function()
	updateESP()
	FOVCircle.Visible = ESPEnabled
	updateArrows()
end)
