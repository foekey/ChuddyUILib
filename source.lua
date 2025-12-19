--[[ 
    CHUDDY HUB | OBSIDIAN EDITION
    A sleek, sidebar-based UI library.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local ChuddyLib = {}

--// Theme Configuration (Obsidian Style)
local Theme = {
	Main = Color3.fromRGB(25, 25, 25),       -- Darker background
	Sidebar = Color3.fromRGB(30, 30, 30),    -- Slightly lighter sidebar
	Element = Color3.fromRGB(35, 35, 35),    -- Element background
	Header = Color3.fromRGB(40, 40, 40),     -- Tops of sections
	Text = Color3.fromRGB(220, 220, 220),    -- Off-white text
	TextDark = Color3.fromRGB(150, 150, 150),-- Subtext
	Accent = Color3.fromRGB(114, 137, 218),  -- Blurple/Obsidian Accent
	Stroke = Color3.fromRGB(50, 50, 50),     -- Outlines
	Red = Color3.fromRGB(210, 60, 60)        -- Destructive actions
}

--// Helper: Safe Parent
local function GetParent()
	local Success, Result = pcall(function() return gethui() end)
	if Success and Result then return Result end
	if game:GetService("CoreGui"):FindFirstChild("RobloxGui") then return game:GetService("CoreGui") end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

--// Helper: Tween
local function Tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

--// Main Window
function ChuddyLib:CreateWindow(Settings)
	local WindowName = Settings.Name or "Chuddy Hub"
	local CurrentKeybind = Settings.Keybind or Enum.KeyCode.RightControl
	local UI_Connections = {}

	-- 1. ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ChuddyObsidian"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = GetParent()

	-- 2. Main Container (Centered)
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "Main"
	MainFrame.Size = UDim2.new(0, 650, 0, 450)
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.BackgroundColor3 = Theme.Main
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui

	-- Outline
	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Theme.Stroke
	MainStroke.Thickness = 1
	MainStroke.Parent = MainFrame
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

	-- 3. Sidebar (Left)
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 160, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = MainFrame

	local SidebarLine = Instance.new("Frame")
	SidebarLine.Size = UDim2.new(0, 1, 1, 0)
	SidebarLine.Position = UDim2.new(1, -1, 0, 0)
	SidebarLine.BackgroundColor3 = Theme.Stroke
	SidebarLine.BorderSizePixel = 0
	SidebarLine.Parent = Sidebar

	-- Title Area
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Text = WindowName
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 16
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.Size = UDim2.new(1, -20, 0, 50)
	TitleLabel.Position = UDim2.new(0, 15, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Sidebar

	-- Tab Container
	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(1, 0, 1, -60) -- Leave room for Settings
	TabContainer.Position = UDim2.new(0, 0, 0, 50)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 0
	TabContainer.Parent = Sidebar
	
	local TabList = Instance.new("UIListLayout")
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 4)
	TabList.Parent = TabContainer

	-- 4. Content Area (Right)
	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "Content"
	ContentArea.Size = UDim2.new(1, -160, 1, 0)
	ContentArea.Position = UDim2.new(0, 160, 0, 0)
	ContentArea.BackgroundTransparency = 1
	ContentArea.Parent = MainFrame

	--// Drag Logic
	local Dragging, DragInput, DragStart, StartPos
	Sidebar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true; DragStart = input.Position; StartPos = MainFrame.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
		end
	end)
	Sidebar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			local delta = input.Position - DragStart
			Tween(MainFrame, {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)}, 0.05)
		end
	end)

	--// Toggle UI Logic
	table.insert(UI_Connections, UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == CurrentKeybind then
			ScreenGui.Enabled = not ScreenGui.Enabled
		end
	end))

	--// Tab System
	local Tabs = {}
	local FirstTab = true

	function Tabs:CreateTab(TabName, IconId)
		-- 1. Page Frame
		local Page = Instance.new("ScrollingFrame")
		Page.Name = TabName .. "_Page"
		Page.Size = UDim2.new(1, -20, 1, -20)
		Page.Position = UDim2.new(0, 10, 0, 10)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Theme.Stroke
		Page.Visible = false
		Page.Parent = ContentArea

		local PageList = Instance.new("UIListLayout")
		PageList.SortOrder = Enum.SortOrder.LayoutOrder
		PageList.Padding = UDim.new(0, 6)
		PageList.Parent = Page

		local PagePad = Instance.new("UIPadding")
		PagePad.PaddingTop = UDim.new(0, 5)
		PagePad.PaddingBottom = UDim.new(0, 5)
		PagePad.Parent = Page

		-- 2. Sidebar Button
		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = TabName
		TabBtn.Size = UDim2.new(1, -20, 0, 32)
		TabBtn.BackgroundColor3 = Theme.Sidebar
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = ""
		TabBtn.AutoButtonColor = false
		TabBtn.Parent = TabContainer

		local TabLabel = Instance.new("TextLabel")
		TabLabel.Text = TabName
		TabLabel.Size = UDim2.new(1, -30, 1, 0)
		TabLabel.Position = UDim2.new(0, 34, 0, 0) -- Adjusted for icon or line
		TabLabel.BackgroundTransparency = 1
		TabLabel.TextColor3 = Theme.TextDark
		TabLabel.Font = Enum.Font.GothamMedium
		TabLabel.TextSize = 13
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left
		TabLabel.Parent = TabBtn

		local TabIndicator = Instance.new("Frame")
		TabIndicator.Size = UDim2.new(0, 3, 0.6, 0)
		TabIndicator.Position = UDim2.new(0, 0, 0.2, 0)
		TabIndicator.BackgroundColor3 = Theme.Accent
		TabIndicator.BackgroundTransparency = 1 -- Hidden by default
		TabIndicator.Parent = TabBtn
		Instance.new("UICorner", TabIndicator).CornerRadius = UDim.new(0, 2)

		-- Optional Icon
		if IconId then
			local Ico = Instance.new("ImageLabel")
			Ico.Size = UDim2.new(0, 16, 0, 16)
			Ico.Position = UDim2.new(0, 10, 0.5, -8)
			Ico.BackgroundTransparency = 1
			Ico.Image = "rbxassetid://" .. tostring(IconId)
			Ico.ImageColor3 = Theme.TextDark
			Ico.Parent = TabBtn
		end

		-- Activation Logic
		local function Activate()
			-- Deactivate all others
			for _, v in pairs(TabContainer:GetChildren()) do
				if v:IsA("TextButton") then
					Tween(v.TextLabel, {TextColor3 = Theme.TextDark})
					Tween(v.Frame, {BackgroundTransparency = 1})
				end
			end
			for _, v in pairs(ContentArea:GetChildren()) do
				if v:IsA("ScrollingFrame") then v.Visible = false end
			end

			-- Activate Current
			Page.Visible = true
			Tween(TabLabel, {TextColor3 = Theme.Text})
			Tween(TabIndicator, {BackgroundTransparency = 0})
		end

		TabBtn.MouseButton1Click:Connect(Activate)

		if FirstTab then
			FirstTab = false
			Activate()
		end

		--// Elements
		local Elements = {}

		function Elements:CreateSection(Name)
			local SectionLabel = Instance.new("TextLabel")
			SectionLabel.Text = string.upper(Name)
			SectionLabel.Size = UDim2.new(1, 0, 0, 24)
			SectionLabel.BackgroundTransparency = 1
			SectionLabel.TextColor3 = Theme.Accent
			SectionLabel.Font = Enum.Font.GothamBold
			SectionLabel.TextSize = 11
			SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
			SectionLabel.Parent = Page
			
			local Pad = Instance.new("UIPadding")
			Pad.PaddingLeft = UDim.new(0, 2)
			Pad.Parent = SectionLabel
		end

		function Elements:CreateButton(Config)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 0, 36)
			Btn.BackgroundColor3 = Theme.Element
			Btn.Text = ""
			Btn.AutoButtonColor = false
			Btn.Parent = Page
			Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
			Instance.new("UIStroke", Btn).Color = Theme.Stroke

			local Title = Instance.new("TextLabel")
			Title.Text = Config.Name
			Title.Size = UDim2.new(1, -10, 1, 0)
			Title.Position = UDim2.new(0, 10, 0, 0)
			Title.BackgroundTransparency = 1
			Title.TextColor3 = Theme.Text
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.Parent = Btn

			-- Click Effect
			Btn.MouseButton1Click:Connect(function()
				Tween(Btn, {BackgroundColor3 = Theme.Stroke}, 0.1)
				task.wait(0.1)
				Tween(Btn, {BackgroundColor3 = Theme.Element}, 0.2)
				pcall(Config.Callback)
			end)
		end

		function Elements:CreateToggle(Config)
			local State = Config.Default or false
			
			local Tog = Instance.new("TextButton")
			Tog.Size = UDim2.new(1, 0, 0, 36)
			Tog.BackgroundColor3 = Theme.Element
			Tog.Text = ""
			Tog.AutoButtonColor = false
			Tog.Parent = Page
			Instance.new("UICorner", Tog).CornerRadius = UDim.new(0, 4)
			Instance.new("UIStroke", Tog).Color = Theme.Stroke

			local Title = Instance.new("TextLabel")
			Title.Text = Config.Name
			Title.Size = UDim2.new(1, -40, 1, 0)
			Title.Position = UDim2.new(0, 10, 0, 0)
			Title.BackgroundTransparency = 1
			Title.TextColor3 = Theme.Text
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.Parent = Tog

			-- Switch Graphic
			local SwitchBg = Instance.new("Frame")
			SwitchBg.Size = UDim2.new(0, 36, 0, 18)
			SwitchBg.Position = UDim2.new(1, -46, 0.5, -9)
			SwitchBg.BackgroundColor3 = State and Theme.Accent or Theme.Main
			SwitchBg.Parent = Tog
			Instance.new("UICorner", SwitchBg).CornerRadius = UDim.new(1, 0)
			
			local Knob = Instance.new("Frame")
			Knob.Size = UDim2.new(0, 14, 0, 14)
			Knob.Position = State and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
			Knob.BackgroundColor3 = Theme.Text
			Knob.Parent = SwitchBg
			Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

			Tog.MouseButton1Click:Connect(function()
				State = not State
				Tween(SwitchBg, {BackgroundColor3 = State and Theme.Accent or Theme.Main}, 0.2)
				Tween(Knob, {Position = State and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}, 0.2)
				pcall(Config.Callback, State)
			end)
		end

		function Elements:CreateSlider(Config)
			local Min, Max, Val = Config.Min, Config.Max, Config.Default or Config.Min
			
			local SlideFrame = Instance.new("Frame")
			SlideFrame.Size = UDim2.new(1, 0, 0, 50)
			SlideFrame.BackgroundColor3 = Theme.Element
			SlideFrame.Parent = Page
			Instance.new("UICorner", SlideFrame).CornerRadius = UDim.new(0, 4)
			Instance.new("UIStroke", SlideFrame).Color = Theme.Stroke

			local Title = Instance.new("TextLabel")
			Title.Text = Config.Name
			Title.Size = UDim2.new(1, -10, 0, 20)
			Title.Position = UDim2.new(0, 10, 0, 5)
			Title.BackgroundTransparency = 1
			Title.TextColor3 = Theme.Text
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.Parent = SlideFrame
			
			local ValLabel = Instance.new("TextLabel")
			ValLabel.Text = tostring(Val)
			ValLabel.Size = UDim2.new(0, 50, 0, 20)
			ValLabel.Position = UDim2.new(1, -60, 0, 5)
			ValLabel.BackgroundTransparency = 1
			ValLabel.TextColor3 = Theme.TextDark
			ValLabel.Font = Enum.Font.Gotham
			ValLabel.TextSize = 12
			ValLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValLabel.Parent = SlideFrame

			local Bar = Instance.new("TextButton")
			Bar.Text = ""
			Bar.Size = UDim2.new(1, -20, 0, 6)
			Bar.Position = UDim2.new(0, 10, 0, 32)
			Bar.BackgroundColor3 = Theme.Main
			Bar.AutoButtonColor = false
			Bar.Parent = SlideFrame
			Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new((Val - Min) / (Max - Min), 0, 1, 0)
			Fill.BackgroundColor3 = Theme.Accent
			Fill.Parent = Bar
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

			local Dragging = false
			local function Update(input)
				local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
				local new = math.floor(Min + ((Max - Min) * pos))
				ValLabel.Text = tostring(new)
				pcall(Config.Callback, new)
			end

			Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Update(i) end end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
			UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
		end
		
		function Elements:CreateLabel(Text)
			local Lab = Instance.new("TextLabel")
			Lab.Text = Text
			Lab.Size = UDim2.new(1, 0, 0, 20)
			Lab.BackgroundTransparency = 1
			Lab.TextColor3 = Theme.TextDark
			Lab.Font = Enum.Font.Gotham
			Lab.TextSize = 12
			Lab.TextXAlignment = Enum.TextXAlignment.Left
			Lab.Parent = Page
			local P = Instance.new("UIPadding"); P.PaddingLeft = UDim.new(0, 10); P.Parent = Lab
		end

		return Elements
	end

	--// Built-in Settings Tab
	local SetTab = Tabs:CreateTab("Settings", "10723415903") -- Gear Icon
	SetTab:CreateSection("Keybinds")
	
	-- Keybind Changer
	local KeyBtn = Instance.new("TextButton")
	KeyBtn.Size = UDim2.new(1, 0, 0, 36)
	KeyBtn.BackgroundColor3 = Theme.Element
	KeyBtn.Text = ""
	KeyBtn.AutoButtonColor = false
	KeyBtn.Parent = SetTab.Settings_Page -- Accessing internal frame directly
	Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 4)
	Instance.new("UIStroke", KeyBtn).Color = Theme.Stroke
	
	local KeyTitle = Instance.new("TextLabel")
	KeyTitle.Text = "Menu Toggle Key"
	KeyTitle.Size = UDim2.new(1, -10, 1, 0)
	KeyTitle.Position = UDim2.new(0, 10, 0, 0)
	KeyTitle.BackgroundTransparency = 1
	KeyTitle.TextColor3 = Theme.Text
	KeyTitle.Font = Enum.Font.GothamMedium
	KeyTitle.TextSize = 13
	KeyTitle.TextXAlignment = Enum.TextXAlignment.Left
	KeyTitle.Parent = KeyBtn
	
	local KeyDisplay = Instance.new("TextLabel")
	KeyDisplay.Text = "[" .. CurrentKeybind.Name .. "]"
	KeyDisplay.Size = UDim2.new(0, 100, 1, 0)
	KeyDisplay.Position = UDim2.new(1, -110, 0, 0)
	KeyDisplay.BackgroundTransparency = 1
	KeyDisplay.TextColor3 = Theme.Accent
	KeyDisplay.Font = Enum.Font.GothamBold
	KeyDisplay.TextSize = 13
	KeyDisplay.TextXAlignment = Enum.TextXAlignment.Right
	KeyDisplay.Parent = KeyBtn
	
	local Listening = false
	KeyBtn.MouseButton1Click:Connect(function()
		Listening = true
		KeyDisplay.Text = "..."
		KeyDisplay.TextColor3 = Theme.Text
	end)
	
	table.insert(UI_Connections, UserInputService.InputBegan:Connect(function(input)
		if Listening and input.UserInputType == Enum.UserInputType.Keyboard then
			CurrentKeybind = input.KeyCode
			KeyDisplay.Text = "[" .. input.KeyCode.Name .. "]"
			KeyDisplay.TextColor3 = Theme.Accent
			Listening = false
		end
	end))
	
	SetTab:CreateSection("Management")
	
	SetTab:CreateButton({
		Name = "Unload UI",
		Callback = function()
			ScreenGui:Destroy()
			for _, c in pairs(UI_Connections) do c:Disconnect() end
		end
	})

	return Tabs
end

return ChuddyLib
