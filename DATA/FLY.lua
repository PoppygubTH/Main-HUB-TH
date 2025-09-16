-- Fly Script with GUI for Roblox (Mobile and PC compatible)
-- Controls: F key (PC) or GUI button (Mobile) to toggle fly, WASD or GUI buttons for movement
-- Created for Roblox Studio, use responsibly!

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Fly variables
local flying = false
local speed = 50 -- Fly speed (studs per second)
local bodyVelocity = nil
local bodyGyro = nil

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FlyGUI"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "FlyFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 300) -- Adjusted for mobile
mainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title Label
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Fly Control (Press F on PC)"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = mainFrame

-- Toggle Fly Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0.8, 0, 0, 40)
toggleButton.Position = UDim2.new(0.1, 0, 0, 50)
toggleButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
toggleButton.BorderSizePixel = 0
toggleButton.Text = "Fly: OFF"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Parent = mainFrame

-- Movement Buttons (Mobile)
local buttons = {
	{Name = "Up", Text = "Up", Pos = UDim2.new(0.1, 0, 0, 100), Key = Enum.KeyCode.Space},
	{Name = "Down", Text = "Down", Pos = UDim2.new(0.1, 0, 0, 150), Key = Enum.KeyCode.LeftControl},
	{Name = "Forward", Text = "Forward", Pos = UDim2.new(0.1, 0, 0, 200), Key = Enum.KeyCode.W},
	{Name = "Backward", Text = "Backward", Pos = UDim2.new(0.1, 0, 0, 250), Key = Enum.KeyCode.S},
	{Name = "Left", Text = "Left", Pos = UDim2.new(0.55, 0, 0, 200), Key = Enum.KeyCode.A},
	{Name = "Right", Text = "Right", Pos = UDim2.new(0.55, 0, 0, 250), Key = Enum.KeyCode.D}
}

local activeInputs = {} -- Track which buttons are being held
for _, btn in ipairs(buttons) do
	local button = Instance.new("TextButton")
	button.Name = btn.Name
	button.Size = UDim2.new(0.35, 0, 0, 40)
	button.Position = btn.Pos
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.BorderSizePixel = 0
	button.Text = btn.Text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextScaled = true
	button.Font = Enum.Font.SourceSans
	button.Parent = mainFrame

	-- Handle button press
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			activeInputs[btn.Key] = true
		end
	end)
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			activeInputs[btn.Key] = false
		end
	end)
end

-- Make GUI draggable
local function makeDraggable(frame)
	local dragging = false
	local dragStart = nil
	local startPos = nil

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	frame.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end
makeDraggable(mainFrame)

-- Function to start flying
local function startFlying()
	if not flying then
		flying = true
		bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		bodyVelocity.Parent = rootPart

		bodyGyro = Instance.new("BodyGyro")
		bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
		bodyGyro.P = 10000
		bodyGyro.D = 500
		bodyGyro.Parent = rootPart

		humanoid.PlatformStand = true
		toggleButton.Text = "Fly: ON"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
		print("Fly mode ON")
	end
end

-- Function to stop flying
local function stopFlying()
	if flying then
		flying = false
		if bodyVelocity then
			bodyVelocity:Destroy()
			bodyVelocity = nil
		end
		if bodyGyro then
			bodyGyro:Destroy()
			bodyGyro = nil
		end
		humanoid.PlatformStand = false
		toggleButton.Text = "Fly: OFF"
		toggleButton.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
		print("Fly mode OFF")
	end
end

-- Toggle fly with F key (PC) or button (Mobile)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
		if flying then
			stopFlying()
		else
			startFlying()
		end
	end
end)

toggleButton.MouseButton1Click:Connect(function()
	if flying then
		stopFlying()
	else
		startFlying()
	end
end)

-- Update movement
RunService.RenderStepped:Connect(function()
	if flying and bodyVelocity and bodyGyro then
		local camera = workspace.CurrentCamera
		local direction = Vector3.new(0, 0, 0)

		-- Check PC and Mobile inputs
		if UserInputService:IsKeyDown(Enum.KeyCode.W) or activeInputs[Enum.KeyCode.W] then
			direction = direction + camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) or activeInputs[Enum.KeyCode.S] then
			direction = direction - camera.CFrame.LookVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) or activeInputs[Enum.KeyCode.A] then
			direction = direction - camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) or activeInputs[Enum.KeyCode.D] then
			direction = direction + camera.CFrame.RightVector
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) or activeInputs[Enum.KeyCode.Space] then
			direction = direction + Vector3.new(0, 1, 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or activeInputs[Enum.KeyCode.LeftControl] then
			direction = direction - Vector3.new(0, 1, 0)
		end

		-- Apply movement
		if direction.Magnitude > 0 then
			direction = direction.Unit * speed
		end
		bodyVelocity.Velocity = direction

		-- Rotate to face camera direction
		bodyGyro.CFrame = CFrame.new(Vector3.new(0, 0, 0), camera.CFrame.LookVector)
	end
end)

-- Handle character respawn
player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	rootPart = character:WaitForChild("HumanoidRootPart")
	if flying then
		stopFlying()
	end
end)

-- GUI Fade-in
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
TweenService:Create(mainFrame, tweenInfo, {BackgroundTransparency = 0}):Play()
print("Fly GUI Script Loaded!")
