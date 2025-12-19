--[[ 
    CHUDDY UI LIBRARY
    A sleek, modern interface suite.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local ChuddyLib = {}

--// Configuration
local DEFAULT_ICON = "rbxassetid://134140528282189"

--// Theme
local Theme = {
	Main = Color3.fromRGB(25, 25, 30),
	Header = Color3.fromRGB(35, 35, 40),
	Element = Color3.fromRGB(45, 45, 50),
	Text = Color3.fromRGB(255, 255, 255),
	Accent = Color3.fromRGB(0, 170, 255), -- Bright Blue
	Stroke = Color3.fromRGB(60, 60, 65),
	Placeholder = Color3.fromRGB(150, 150, 150)
}

--// Safe Parent Retrieval (Supports Executors & Studio)
local function GetParent()
	local Success, Result = pcall(function()
		return gethui()
	end)
	if Success and Result then return Result end
	
	if game:GetService("CoreGui"):FindFirstChild("RobloxGui") then
		return game:GetService("CoreGui")
	end
	
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

--// Utility: Draggable
local function MakeDraggable(topbar, mainFrame)
	local dragging, dragInput, dragStart, startPos
	topbar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	topbar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			TweenService:Create(mainFrame, TweenInfo.new(0.15), {
				Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			}):Play()
		end
	end)
end

--// Main Window Function
function ChuddyLib:CreateWindow(Settings)
	local WindowName = Settings.Name or "Chuddy UI"
	local ToggleKey = Settings.Keybind or Enum.KeyCode.RightControl
	
	-- 1. Create ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ChuddyInterface"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent = GetParent()
	
	-- 2. Main Frame
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 550, 0, 400)
	MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
	MainFrame.BackgroundColor3 = Theme.Main
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui
	
	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 10)
	MainCorner.Parent = MainFrame

	-- 3. Topbar
	local Topbar = Instance.new("Frame")
	Topbar.Name = "Topbar"
	Topbar.Size = UDim2.new(1, 0, 0, 45)
	Topbar.BackgroundColor3 = Theme.Header
	Topbar.BorderSizePixel = 0
	Topbar.Parent = MainFrame
	
	local TopbarCorner = Instance.new("UICorner")
	TopbarCorner.CornerRadius = UDim.new(0, 10)
	TopbarCorner.Parent = Topbar
	
	-- Fix bottom corners
	local TopbarCover = Instance.new("Frame")
	TopbarCover.BackgroundColor3 = Theme.Header
	TopbarCover.BorderSizePixel = 0
	TopbarCover.Size = UDim2.new(1, 0, 0, 10)
	TopbarCover.Position = UDim2.new(0, 0, 1, -10)
	TopbarCover.Parent = Topbar

	-- Icon & Title
	local Icon = Instance.new("ImageLabel")
	Icon.Size = UDim2.new(0, 28, 0, 28)
	Icon.Position = UDim2.new(0, 12, 0, 8)
	Icon.BackgroundTransparency = 1
	Icon.Image = DEFAULT_ICON
	Icon.Parent = Topbar
	
	local Title = Instance.new("TextLabel")
	Title.Text = WindowName
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 18
	Title.TextColor3 = Theme.Text
	Title.BackgroundTransparency = 1
	Title.Size = UDim2.new(0, 200, 1, 0)
	Title.Position = UDim2.new(0, 50, 0, 0)
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Topbar
	
	-- Controls (Min/Close)
	local function CreateControl(name, text, layoutOrder, callback)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.Text = text
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 18
		btn.TextColor3 = Theme.Text
		btn.BackgroundTransparency = 1
		btn.Size = UDim2.new(0, 35, 1, 0)
		btn.Position = UDim2.new(1, -35 * layoutOrder, 0, 0)
		btn.Parent = Topbar
		btn.MouseButton1Click:Connect(callback)
		return btn
	end

	CreateControl("Close", "X", 1, function() ScreenGui:Destroy() end)
	
	local Minimized = false
	local OldSize = MainFrame.Size
	CreateControl("Min", "-", 2, function()
		Minimized = not Minimized
		if Minimized then
			OldSize = MainFrame.Size
			TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, OldSize.X.Offset, 0, 45)}):Play()
		else
			TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = OldSize}):Play()
		end
	end)

	-- Resize Handle
	local ResizeHandle = Instance.new("ImageButton")
	ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
	ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
	ResizeHandle.BackgroundTransparency = 1
	ResizeHandle.Image = "rbxassetid://134140528282189"
	ResizeHandle.ImageTransparency = 0.6
	ResizeHandle.Parent = MainFrame
	
	-- Content Container
	local Container = Instance.new("ScrollingFrame")
	Container.Name = "Container"
	Container.Size = UDim2.new(1, -20, 1, -55)
	Container.Position = UDim2.new(0, 10, 0, 50)
	Container.BackgroundTransparency = 1
	Container.ScrollBarThickness = 2
	Container.ScrollBarImageColor3 = Theme.Accent
	Container.Parent = MainFrame
	
	local UIListLayout = Instance.new("UIListLayout")
	UIListLayout.Padding = UDim.new(0, 6)
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Parent = Container
	
	-- Resize Logic
	local resizing, resizeStart, startSize
	ResizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true; resizeStart = input.Position; startSize = MainFrame.Size
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then resizing = false end end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - resizeStart
			local newW = math.max(300, startSize.X.Offset + delta.X)
			local newH = math.max(150, startSize.Y.Offset + delta.Y)
			TweenService:Create(MainFrame, TweenInfo.new(0.05), {Size = UDim2.new(0, newW, 0, newH)}):Play()
		end
	end)
	
	MakeDraggable(Topbar, MainFrame)
	
	-- Keybind
	UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == ToggleKey then ScreenGui.Enabled = not ScreenGui.Enabled end
	end)

	--// TABS
	local Tabs = {}
	function Tabs:CreateTab(TabName)
		-- Simple Header for Tab
		local Header = Instance.new("TextLabel")
		Header.Text = "  // " .. string.upper(TabName)
		Header.Size = UDim2.new(1, 0, 0, 30)
		Header.BackgroundTransparency = 1
		Header.TextColor3 = Theme.Accent
		Header.Font = Enum.Font.GothamBlack
		Header.TextSize = 14
		Header.TextXAlignment = Enum.TextXAlignment.Left
		Header.Parent = Container
		
		local Elements = {}
		
		-- Button
		function Elements:CreateButton(Config)
			local Button = Instance.new("TextButton")
			Button.Size = UDim2.new(1, 0, 0, 38)
			Button.BackgroundColor3 = Theme.Element
			Button.Text = ""
			Button.AutoButtonColor = false
			Button.Parent = Container
			
			Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
			
			local Title = Instance.new("TextLabel")
			Title.Text = Config.Name
			Title.Size = UDim2.new(1, -20, 1, 0)
			Title.Position = UDim2.new(0, 12, 0, 0)
			Title.BackgroundTransparency = 1
			Title.TextColor3 = Theme.Text
			Title.Font = Enum.Font.GothamSemibold
			Title.TextSize = 14
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.Parent = Button
			
			local Icon = Instance.new("ImageLabel")
			Icon.Size = UDim2.new(0, 20, 0, 20)
			Icon.Position = UDim2.new(1, -30, 0.5, -10)
			Icon.BackgroundTransparency = 1
			Icon.Image = "rbxassetid://3944703587" -- Arrow icon
			Icon.Parent = Button
			
			Button.MouseButton1Click:Connect(function()
				TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
				task.wait(0.1)
				TweenService:Create(Button, TweenInfo.new(0.3), {BackgroundColor3 = Theme.Element}):Play()
				pcall(Config.Callback)
			end)
		end
		
		-- Toggle
		function Elements:CreateToggle(Config)
			local State = false
			
			local Toggle = Instance.new("TextButton")
			Toggle.Size = UDim2.new(1, 0, 0, 38)
			Toggle.BackgroundColor3 = Theme.Element
			Toggle.Text = ""
			Toggle.AutoButtonColor = false
			Toggle.Parent = Container
			
			Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 6)
			
			local Title = Instance.new("TextLabel")
			Title.Text = Config.Name
			Title.Size = UDim2.new(1, -50, 1, 0)
			Title.Position = UDim2.new(0, 12, 0, 0)
			Title.BackgroundTransparency = 1
			Title.TextColor3 = Theme.Text
			Title.Font = Enum.Font.GothamSemibold
			Title.TextSize = 14
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.Parent = Toggle
			
			local Indicator = Instance.new("Frame")
			Indicator.Size = UDim2.new(0, 20, 0, 20)
			Indicator.Position = UDim2.new(1, -30, 0.5, -10)
			Indicator.BackgroundColor3 = Theme.Main
			Indicator.Parent = Toggle
			Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 4)
			
			local Check = Instance.new("Frame")
			Check.Size = UDim2.new(1, -4, 1, -4)
			Check.Position = UDim2.new(0, 2, 0, 2)
			Check.BackgroundColor3 = Theme.Accent
			Check.BackgroundTransparency = 1
			Check.Parent = Indicator
			Instance.new("UICorner", Check).CornerRadius = UDim.new(0, 4)

			Toggle.MouseButton1Click:Connect(function()
				State = not State
				local targetAlpha = State and 0 or 1
				TweenService:Create(Check, TweenInfo.new(0.3), {BackgroundTransparency = targetAlpha}):Play()
				pcall(Config.Callback, State)
			end)
		end

		-- Slider
		function Elements:CreateSlider(Config)
			local Min = Config.Min or 0
			local Max = Config.Max or 100
			local Default = Config.Default or Min
			
			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, 0, 0, 55)
			Frame.BackgroundColor3 = Theme.Element
			Frame.Parent = Container
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
			
			local Title = Instance.new("TextLabel")
			Title.Text = Config.Name
			Title.Size = UDim2.new(1, -20, 0, 20)
			Title.Position = UDim2.new(0, 12, 0, 8)
			Title.BackgroundTransparency = 1
			Title.TextColor3 = Theme.Text
			Title.Font = Enum.Font.GothamSemibold
			Title.TextSize = 14
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.Parent = Frame
			
			local ValueText = Instance.new("TextLabel")
			ValueText.Text = tostring(Default)
			ValueText.Size = UDim2.new(0, 50, 0, 20)
			ValueText.Position = UDim2.new(1, -60, 0, 8)
			ValueText.BackgroundTransparency = 1
			ValueText.TextColor3 = Theme.Accent
			ValueText.Font = Enum.Font.GothamBold
			ValueText.TextSize = 14
			ValueText.TextXAlignment = Enum.TextXAlignment.Right
			ValueText.Parent = Frame
			
			local Bar = Instance.new("TextButton")
			Bar.Text = ""
			Bar.Size = UDim2.new(1, -24, 0, 8)
			Bar.Position = UDim2.new(0, 12, 0, 35)
			Bar.BackgroundColor3 = Theme.Main
			Bar.AutoButtonColor = false
			Bar.Parent = Frame
			Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 4)
			
			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new((Default - Min)/(Max - Min), 0, 1, 0)
			Fill.BackgroundColor3 = Theme.Accent
			Fill.Parent = Bar
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 4)
			
			local dragging = false
			local function Update(input)
				local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				Fill.Size = UDim2.new(pos, 0, 1, 0)
				local val = math.floor(Min + ((Max - Min) * pos))
				ValueText.Text = tostring(val)
				pcall(Config.Callback, val)
			end
			
			Bar.InputBegan:Connect(function(i) 
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; Update(i) end 
			end)
			UserInputService.InputEnded:Connect(function(i) 
				if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end 
			end)
			UserInputService.InputChanged:Connect(function(i) 
				if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then Update(i) end 
			end)
		end
		
		return Elements
	end
	
	return Tabs
end

return ChuddyLib
