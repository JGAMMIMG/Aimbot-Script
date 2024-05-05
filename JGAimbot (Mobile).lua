local Players = game:GetService("Players")
local Camera = game:GetService("Workspace").CurrentCamera
local UserInputService = game:GetService("UserInputService")
local Mouse = Players.LocalPlayer:GetMouse()

-- Verificar se o jogador está em um dispositivo móvel
local function IsMobile()
	return UserInputService.TouchEnabled -- Retorna `true` se o jogador estiver no celular ou tablet
end

local target = nil
local aiming = false
local sensitivity = 1 -- Sensibilidade padrão

-- Função para encontrar o HumanoidRootPart de um modelo de jogador ou NPC
local function FindHumanoidRootPart(model)
	return model and model:FindFirstChild("HumanoidRootPart")
end

-- Função para encontrar o Head de um modelo de jogador
local function FindHead(model)
	return model and model:FindFirstChild("Head")
end

-- Função para encontrar o alvo mais próximo visível
local function GetNearestVisibleTarget()
	local localPlayer = Players.LocalPlayer
	local localTeam = localPlayer.Team
	local targets = {}

	-- Adicionar jogadores à lista de alvos, excluindo o jogador local e jogadores do mesmo time
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= localPlayer and (not localTeam or player.Team ~= localTeam) then
			local humanoidRootPart = FindHumanoidRootPart(player.Character)
			local head = FindHead(player.Character)
			if humanoidRootPart and head then
				table.insert(targets, {rootPart = humanoidRootPart, head = head})
			end
		end
	end

	-- Encontra o alvo mais próximo visível
	local closestTarget = nil
	local minDistance = math.huge

	for _, targetInfo in ipairs(targets) do
		local screenPos, onScreen = Camera:WorldToViewportPoint(targetInfo.head.Position)
		if onScreen then
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
	aiming = true
	target = GetNearestVisibleTarget()
	if target then
		AimAtTarget() -- Mirar no alvo
end
end

-- Função para processar a liberação do botão direito do mouse
local function OnMouseRightButtonUp()
	aiming = false
	target = nil
end

-- Função para criar botões para dispositivos móveis
local function CreateMobileButtons()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	-- Criar ScreenGui para armazenar botões móveis
	local mobileGui = Instance.new("ScreenGui", playerGui)
	mobileGui.Name = "MobileControls"

	-- Criar o botão para mirar
	local aimButton = Instance.new("TextButton", mobileGui)
	aimButton.Size = UDim2.new(0.1, 0, 0.1, 0) 
	aimButton.Position = UDim2.new(0.85, 0, 0.366, 0) 
	aimButton.Text = "Mirar"
	aimButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50) 

	return mobileGui, aimButton
end

-- Criar controles para celular se o jogador estiver em um dispositivo móvel
if IsMobile() then
	local mobileGui, aimButton = CreateMobileButtons()

	-- Conectar evento ao pressionar o botão no celular
	aimButton.MouseButton1Click:Connect(function()
		aiming = not aiming -- Alternar entre mirar e não mirar
		if aiming then
			target = GetNearestVisibleTarget()
			AimAtTarget() -- Mirar no alvo mais próximo
			else
	target = nil -- Desativar a mira
end
end)
end

-- Atualizar a mira se o jogador estiver mirando e o alvo estiver visível
game:GetService("RunService").RenderStepped:Connect(function()
	if aiming then
		target = GetNearestVisibleTarget()
		AimAtTarget() -- Mirar no alvo
end
end)
