-- ╔══════════════════════════════════════════════════════════════╗
-- ║              CHUDDY HUB - ULTIMATE UI LIBRARY                 ║
-- ║                    Made by foeky                              ║
-- ║              Production-Ready v2.0 FIXED                      ║
-- ╚══════════════════════════════════════════════════════════════╝

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local Http = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local Chuddy = {}
Chuddy.__index = Chuddy
Chuddy.Version = "2.0.1"
Chuddy.Author = "foeky"

local Connections = {}
local CurrentWindow = nil

-- ═══════════════════════════════════════════════════════════════
-- THEME PRESETS
-- ═══════════════════════════════════════════════════════════════

local ThemePresets = {
	Chudjak = {
		Name = "Chudjak Classic",
		Main = Color3.fromRGB(18, 18, 20),
		Sidebar = Color3.fromRGB(24, 24, 26),
		Element = Color3.fromRGB(30, 30, 33),
		ElementHover = Color3.fromRGB(38, 38, 41),
		Text = Color3.fromRGB(240, 240, 240),
		TextDim = Color3.fromRGB(140, 140, 140),
		Accent = Color3.fromRGB(114, 137, 218),
		Stroke = Color3.fromRGB(45, 45, 48),
		Divider = Color3.fromRGB(35, 35, 38)
	},
	Gigachad = {
		Name = "Gigachad Gold",
		Main = Color3.fromRGB(20, 20, 22),
		Sidebar = Color3.fromRGB(25, 25, 27),
		Element = Color3.fromRGB(35, 32, 28),
		ElementHover = Color3.fromRGB(45, 42, 35),
		Text = Color3.fromRGB(255, 215, 0),
		TextDim = Color3.fromRGB(180, 155, 60),
		Accent = Color3.fromRGB(255, 215, 0),
		Stroke = Color3.fromRGB(60, 55, 40),
		Divider = Color3.fromRGB(50, 48, 35)
	},
	Soyjak = {
		Name = "Soyjak Soy",
		Main = Color3.fromRGB(15, 20, 15),
		Sidebar = Color3.fromRGB(20, 25, 20),
		Element = Color3.fromRGB(25, 35, 25),
		ElementHover = Color3.fromRGB(30, 45, 30),
		Text = Color3.fromRGB(144, 238, 144),
		TextDim = Color3.fromRGB(100, 180, 100),
		Accent = Color3.fromRGB(50, 205, 50),
		Stroke = Color3.fromRGB(40, 80, 40),
		Divider = Color3.fromRGB(30, 60, 30)
	}
}

local Theme = table.clone(ThemePresets.Chudjak)

local DefaultIcons = {
	Settings = "rbxassetid://10734949856",
	User = "rbxassetid://10747372992",
	Dropdown = "rbxassetid://10709790948"
}

local ConfigFolder = "ChuddyHub"

local function EnsureFolder()
	if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
end

local function SaveConfig(name, data)
	EnsureFolder()
	writefile(ConfigFolder .. "/" .. name .. ".json", Http:JSONEncode(data))
end

local function LoadConfig(name)
	local path = ConfigFolder .. "/" .. name .. ".json"
	if isfile(path) then
		local success, result = pcall(function() return Http:JSONDecode(readfile(path)) end)
		if success then return result end
	end
	return nil
end

local function DeleteConfig(name)
	local path = ConfigFolder .. "/" .. name .. ".json"
	if isfile(path) then delfile(path) end
end

local function GetAllConfigs()
	EnsureFolder()
	local configs = {}
	for _, file in ipairs(listfiles(ConfigFolder)) do
		if file:match("%.json$") and not file:match("theme_") then
			table.insert(configs, file:match("([^/\\]+)%.json$"))
		end
	end
	return configs
end

local function SaveTheme(name, themeData)
	EnsureFolder()
	writefile(ConfigFolder .. "/theme_" .. name .. ".json", Http:JSONEncode(themeData))
end

local function LoadTheme(name)
	local path = ConfigFolder .. "/theme_" .. name .. ".json"
	if isfile(path) then
		local success, result = pcall(function() return Http:JSONDecode(readfile(path)) end)
		if success then return result end
	end
	return nil
end

local function DeleteTheme(name)
	local path = ConfigFolder .. "/theme_" .. name .. ".json"
	if isfile(path) then delfile(path) end
end

local function GetAllThemes()
	EnsureFolder()
	local themes = {}
	for _, file in ipairs(listfiles(ConfigFolder)) do
		if file:match("theme_") and file:match("%.json$") then
			table.insert(themes, file:match("theme_([^/\\]+)%.json$"))
		end
	end
	return themes
end

local function Tween(obj, props, time)
	if not obj or not obj.Parent then return end
	TS:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad), props):Play()
end

local function GetParent()
	local success, result = pcall(gethui)
	return success and result or LP:WaitForChild("PlayerGui")
end

local function Corner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = parent
	return corner
end

local function Stroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Theme.Stroke
	stroke.Thickness = thickness or 1
	stroke.Parent = parent
	return stroke
end

local function Padding(parent, top, left, right, bottom)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, top or 0)
	padding.PaddingLeft = UDim.new(0, left or 0)
	padding.PaddingRight = UDim.new(0, right or 0)
	padding.PaddingBottom = UDim.new(0, bottom or 0)
	padding.Parent = parent
	return padding
end

function Chuddy:CreateWindow(config)
	config = config or {}
	
	local WindowName = config.Name or "Chuddy Hub"
	local ToggleKeybind = config.Keybind or Enum.KeyCode.RightControl
	local GameConfig = config.GameConfig ~= false
	local PlayerTab = config.PlayerTab ~= false
	local AutoLoad = config.AutoLoad or false
	local LogoImage = config.Logo or "rbxassetid://120758864298455"
	
	for _, connection in pairs(getconnections(LP.Idled)) do connection:Disable() end
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ChuddyUI_" .. game.PlaceId
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = GetParent()
	
	-- DROPDOWN OVERLAY CONTAINER (TOPMOST)
	local DropdownOverlay = Instance.new("Frame")
	DropdownOverlay.Name = "DropdownOverlay"
	DropdownOverlay.Size = UDim2.new(1, 0, 1, 0)
	DropdownOverlay.BackgroundTransparency = 1
	DropdownOverlay.ZIndex = 10000
	DropdownOverlay.Parent = ScreenGui
	
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 750, 0, 550)
	Main.Position = UDim2.new(0.5, -375, 0.5, -275)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui
	Corner(Main, 8)
	Stroke(Main, Theme.Stroke, 1)
	
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 210, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main
	
	local SidebarLine = Instance.new("Frame")
	SidebarLine.Size = UDim2.new(0, 1, 1, 0)
	SidebarLine.Position = UDim2.new(1, -1, 0, 0)
	SidebarLine.BackgroundColor3 = Theme.Divider
	SidebarLine.BorderSizePixel = 0
	SidebarLine.Parent = Sidebar
	
	local Header = Instance.new("Frame")
	Header.Size = UDim2.new(1, 0, 0, 60)
	Header.BackgroundTransparency = 1
	Header.Parent = Sidebar
	
	local Logo = Instance.new("ImageLabel")
	Logo.Size = UDim2.new(0, 30, 0, 30)
	Logo.Position = UDim2.new(0, 15, 0.5, -15)
	Logo.BackgroundTransparency = 1
	Logo.Image = LogoImage
	Logo.Parent = Header
	Corner(Logo, 5)
	
	local Title = Instance.new("TextLabel")
	Title.Text = WindowName
	Title.Size = UDim2.new(1, -60, 0, 20)
	Title.Position = UDim2.new(0, 55, 0, 12)
	Title.BackgroundTransparency = 1
	Title.TextColor3 = Theme.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 15
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextTruncate = Enum.TextTruncate.AtEnd
	Title.Parent = Header
	
	local Credit = Instance.new("TextLabel")
	Credit.Text = "by foeky"
	Credit.Size = UDim2.new(1, -60, 0, 12)
	Credit.Position = UDim2.new(0, 55, 0, 32)
	Credit.BackgroundTransparency = 1
	Credit.TextColor3 = Theme.TextDim
	Credit.Font = Enum.Font.Gotham
	Credit.TextSize = 9
	Credit.TextXAlignment = Enum.TextXAlignment.Left
	Credit.Parent = Header
	
	local UserProfile = Instance.new("Frame")
	UserProfile.Size = UDim2.new(1, 0, 0, 65)
	UserProfile.Position = UDim2.new(0, 0, 1, -65)
	UserProfile.BackgroundColor3 = Theme.Sidebar
	UserProfile.BorderSizePixel = 0
	UserProfile.Parent = Sidebar
	
	local ProfileLine = Instance.new("Frame")
	ProfileLine.Size = UDim2.new(1, -20, 0, 1)
	ProfileLine.Position = UDim2.new(0, 10, 0, 0)
	ProfileLine.BackgroundColor3 = Theme.Divider
	ProfileLine.BorderSizePixel = 0
	ProfileLine.Parent = UserProfile
	
	local Avatar = Instance.new("ImageLabel")
	Avatar.Size = UDim2.new(0, 36, 0, 36)
	Avatar.Position = UDim2.new(0, 12, 0.5, -18)
	Avatar.BackgroundColor3 = Theme.Element
	Avatar.Parent = UserProfile
	Corner(Avatar, 18)
	
	task.spawn(function()
		local success, thumbnail = pcall(function()
			return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
		if success then Avatar.Image = thumbnail end
	end)
	
	local Username = Instance.new("TextLabel")
	Username.Text = LP.Name
	Username.Size = UDim2.new(1, -60, 0, 20)
	Username.Position = UDim2.new(0, 58, 0.5, -10)
	Username.BackgroundTransparency = 1
	Username.TextColor3 = Theme.Text
	Username.Font = Enum.Font.GothamBold
	Username.TextSize = 13
	Username.TextXAlignment = Enum.TextXAlignment.Left
	Username.TextTruncate = Enum.TextTruncate.AtEnd
	Username.Parent = UserProfile
	
	local Rank = Instance.new("TextLabel")
	Rank.Text = "Certified Chad"
	Rank.Size = UDim2.new(1, -60, 0, 15)
	Rank.Position = UDim2.new(0, 58, 0.5, 4)
	Rank.BackgroundTransparency = 1
	Rank.TextColor3 = Theme.Accent
	Rank.Font = Enum.Font.Gotham
	Rank.TextSize = 11
	Rank.TextXAlignment = Enum.TextXAlignment.Left
	Rank.Parent = UserProfile
	
	local SettingsArea = Instance.new("Frame")
	SettingsArea.Size = UDim2.new(1, 0, 0, 50)
	SettingsArea.Position = UDim2.new(0, 0, 1, -115)
	SettingsArea.BackgroundTransparency = 1
	SettingsArea.Parent = Sidebar
	
	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Size = UDim2.new(1, 0, 1, -175)
	TabContainer.Position = UDim2.new(0, 0, 0, 60)
	TabContainer.BackgroundTransparency = 1
	TabContainer.BorderSizePixel = 0
	TabContainer.ScrollBarThickness = 3
	TabContainer.ScrollBarImageColor3 = Theme.Stroke
	TabContainer.ScrollBarImageTransparency = 0.5
	TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabContainer.Parent = Sidebar
	
	local TabList = Instance.new("UIListLayout")
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 4)
	TabList.Parent = TabContainer
	Padding(TabContainer, 5, 10, 10, 5)
	
	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1, -210, 1, 0)
	Content.Position = UDim2.new(0, 210, 0, 0)
	Content.BackgroundTransparency = 1
	Content.ClipsDescendants = true
	Content.Parent = Main
	
	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1, 0, 0, 50)
	TopBar.BackgroundTransparency = 1
	TopBar.Parent = Content
	
	local TopSeparator = Instance.new("Frame")
	TopSeparator.Size = UDim2.new(1, 0, 0, 1)
	TopSeparator.Position = UDim2.new(0, 0, 1, -1)
	TopSeparator.BackgroundColor3 = Theme.Divider
	TopSeparator.BorderSizePixel = 0
	TopSeparator.Parent = TopBar
	
	local function CreateTextControl(text, position)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0, 32, 0, 32)
		button.Position = position
		button.BackgroundColor3 = Theme.Element
		button.BorderSizePixel = 0
		button.Text = text
		button.TextColor3 = Theme.TextDim
		button.Font = Enum.Font.GothamBold
		button.TextSize = 18
		button.AutoButtonColor = false
		button.Parent = TopBar
		Corner(button, 6)
		button.MouseEnter:Connect(function()
			Tween(button, {TextColor3 = Theme.Text, BackgroundColor3 = Theme.ElementHover})
		end)
		button.MouseLeave:Connect(function()
			Tween(button, {TextColor3 = Theme.TextDim, BackgroundColor3 = Theme.Element})
		end)
		return button
	end
	
	local CloseBtn = CreateTextControl("X", UDim2.new(1, -42, 0, 9))
	local MinBtn = CreateTextControl("-", UDim2.new(1, -82, 0, 9))
	
	CloseBtn.MouseButton1Click:Connect(function()
		for _, connection in pairs(Connections) do
			if connection and connection.Disconnect then connection:Disconnect() end
		end
		Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
		task.wait(0.3)
		ScreenGui:Destroy()
	end)
	
	local Minimized = false
	local OldSize = Main.Size
	local MinBar = nil
	local ResizeIndicator = nil
	
	MinBtn.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		if Minimized then
			OldSize = Main.Size
			local miniWidth = math.max(300, OldSize.X.Offset * 0.4)
			local miniHeight = 50
			Sidebar.Visible = false
			Content.Visible = false
			if ResizeIndicator then ResizeIndicator.Visible = false end
			Tween(Main, {Size = UDim2.new(0, miniWidth, 0, miniHeight)}, 0.3)
			MinBar = Instance.new("Frame")
			MinBar.Name = "MinBar"
			MinBar.Size = UDim2.new(1, 0, 1, 0)
			MinBar.BackgroundTransparency = 1
			MinBar.Parent = Main
			local MinTitle = Instance.new("TextLabel")
			MinTitle.Text = WindowName
			MinTitle.Size = UDim2.new(1, -100, 1, 0)
			MinTitle.Position = UDim2.new(0, 15, 0, 0)
			MinTitle.BackgroundTransparency = 1
			MinTitle.TextColor3 = Theme.Text
			MinTitle.Font = Enum.Font.GothamBold
			MinTitle.TextSize = 14
			MinTitle.TextXAlignment = Enum.TextXAlignment.Left
			MinTitle.Parent = MinBar
			local MaxBtn = CreateTextControl("+", UDim2.new(1, -82, 0.5, -16))
			MaxBtn.Parent = MinBar
			MaxBtn.MouseButton1Click:Connect(function()
				Minimized = false
				if MinBar then MinBar:Destroy() end
				Tween(Main, {Size = OldSize}, 0.3)
				task.wait(0.25)
				Sidebar.Visible = true
				Content.Visible = true
				if ResizeIndicator then ResizeIndicator.Visible = true end
			end)
			local MiniClose = CreateTextControl("X", UDim2.new(1, -42, 0.5, -16))
			MiniClose.Parent = MinBar
			MiniClose.MouseButton1Click:Connect(function()
				for _, connection in pairs(Connections) do
					if connection and connection.Disconnect then connection:Disconnect() end
				end
				Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
				task.wait(0.3)
				ScreenGui:Destroy()
			end)
			local dragging = false
			local dragStart = nil
			local startPos = nil
			MinBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					dragStart = input.Position
					startPos = Main.Position
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then dragging = false end
					end)
				end
			end)
			UIS.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local delta = input.Position - dragStart
					Tween(Main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
				end
			end)
		end
	end)
	
	local Pages = Instance.new("Frame")
	Pages.Size = UDim2.new(1, 0, 1, -50)
	Pages.Position = UDim2.new(0, 0, 0, 50)
	Pages.BackgroundTransparency = 1
	Pages.ClipsDescendants = true
	Pages.Parent = Content
	
	local dragging = false
	local dragStart = nil
	local startPos = nil
	
	local function MakeDraggable(frame)
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not Minimized then
				dragging = true
				dragStart = input.Position
				startPos = Main.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then dragging = false end
				end)
			end
		end)
	end
	
	MakeDraggable(Sidebar)
	MakeDraggable(TopBar)
	
	UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragging and not Minimized then
			local delta = input.Position - dragStart
			Tween(Main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
		end
	end)
	
	-- RESIZE INDICATOR (FIXED POSITION)
	ResizeIndicator = Instance.new("Frame")
	ResizeIndicator.Name = "ResizeIndicator"
	ResizeIndicator.Size = UDim2.new(0, 20, 0, 20)
	ResizeIndicator.Position = UDim2.new(1, -22, 1, -22)
	ResizeIndicator.BackgroundTransparency = 1
	ResizeIndicator.Parent = Main
	
	local function CreateCorner(size, position)
		local corner = Instance.new("Frame")
		corner.Size = size
		corner.Position = position
		corner.BackgroundColor3 = Theme.TextDim
		corner.BorderSizePixel = 0
		corner.Parent = ResizeIndicator
		return corner
	end
	
	CreateCorner(UDim2.new(0, 2, 0, 10), UDim2.new(1, -2, 1, -10))
	CreateCorner(UDim2.new(0, 10, 0, 2), UDim2.new(1, -10, 1, -2))
	CreateCorner(UDim2.new(0, 2, 0, 6), UDim2.new(1, -6, 1, -6))
	CreateCorner(UDim2.new(0, 6, 0, 2), UDim2.new(1, -6, 1, -6))
	
	local resizing = false
	local resizeStart = nil
	local startSize = nil
	
	ResizeIndicator.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			resizeStart = input.Position
			startSize = Main.Size
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then resizing = false end
			end)
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - resizeStart
			local newW = math.clamp(startSize.X.Offset + delta.X, 600, 1400)
			local newH = math.clamp(startSize.Y.Offset + delta.Y, 400, 900)
			Tween(Main, {Size = UDim2.new(0, newW, 0, newH)}, 0.05)
		end
	end)
	
	local Tabs = {}
	local FirstTab = true
	local ActiveTab = nil
	local PlayerTabCreated = false
	
	function Tabs:CreateTab(name, icon)
		local TabButton = Instance.new("TextButton")
		TabButton.Name = name .. "Tab"
		TabButton.Size = UDim2.new(1, -20, 0, 40)
		TabButton.BackgroundTransparency = 1
		TabButton.BackgroundColor3 = Theme.Element
		TabButton.AutoButtonColor = false
		TabButton.Text = ""
		-- PLAYER TAB: LayoutOrder 998 (just above Settings at bottom)
		TabButton.LayoutOrder = (name == "Player") and 998 or 1
		TabButton.Parent = TabContainer
		Corner(TabButton, 6)
		
		local Icon = Instance.new("ImageLabel")
		Icon.Name = "Icon"
		Icon.Size = UDim2.new(0, 20, 0, 20)
		Icon.Position = UDim2.new(0, 12, 0.5, -10)
		Icon.BackgroundTransparency = 1
		Icon.Image = icon or DefaultIcons.User
		Icon.ImageColor3 = Theme.TextDim
		Icon.Parent = TabButton
		
		local Label = Instance.new("TextLabel")
		Label.Name = "Label"
		Label.Text = name
		Label.Size = UDim2.new(1, -50, 1, 0)
		Label.Position = UDim2.new(0, 42, 0, 0)
		Label.BackgroundTransparency = 1
		Label.TextColor3 = Theme.TextDim
		Label.Font = Enum.Font.GothamMedium
		Label.TextSize = 14
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextTruncate = Enum.TextTruncate.AtEnd
		Label.Parent = TabButton
		
		local Page = Instance.new("ScrollingFrame")
		Page.Name = name .. "Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.BorderSizePixel = 0
		Page.ScrollBarThickness = 4
		Page.ScrollBarImageColor3 = Theme.Stroke
		Page.ScrollBarImageTransparency = 0.3
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.Visible = false
		Page.ClipsDescendants = true
		Page.ZIndex = 1
		Page.Parent = Pages
		
		local PageLayout = Instance.new("UIListLayout")
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 8)
		PageLayout.Parent = Page
		Padding(Page, 15, 20, 20, 15)
		
		local function Activate()
			for _, tab in pairs(TabContainer:GetChildren()) do
				if tab:IsA("TextButton") and tab ~= TabButton then
					Tween(tab, {BackgroundTransparency = 1})
					if tab:FindFirstChild("Label") then Tween(tab.Label, {TextColor3 = Theme.TextDim}) end
					if tab:FindFirstChild("Icon") then Tween(tab.Icon, {ImageColor3 = Theme.TextDim}) end
				end
			end
			local SettingsBtn = SettingsArea:FindFirstChild("SettingsBtn")
			if SettingsBtn then
				Tween(SettingsBtn, {BackgroundTransparency = 1})
				if SettingsBtn:FindFirstChild("Label") then Tween(SettingsBtn.Label, {TextColor3 = Theme.TextDim}) end
				if SettingsBtn:FindFirstChild("Icon") then Tween(SettingsBtn.Icon, {ImageColor3 = Theme.TextDim}) end
			end
			for _, page in pairs(Pages:GetChildren()) do
				if page:IsA("ScrollingFrame") then page.Visible = false end
			end
			Page.Visible = true
			ActiveTab = name
			Tween(TabButton, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0})
			Tween(Label, {TextColor3 = Theme.Text})
			Tween(Icon, {ImageColor3 = Theme.Accent})
		end
		
		TabButton.MouseButton1Click:Connect(Activate)
		TabButton.MouseEnter:Connect(function()
			if ActiveTab ~= name then Tween(TabButton, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.5}) end
		end)
		TabButton.MouseLeave:Connect(function()
			if ActiveTab ~= name then Tween(TabButton, {BackgroundTransparency = 1}) end
		end)
		
		if FirstTab then FirstTab = false; Activate() end
		
		local Elements = {}
		
		function Elements:CreateSection(text)
			local section = Instance.new("TextLabel")
			section.Text = string.upper(text)
			section.Size = UDim2.new(1, 0, 0, 26)
			section.BackgroundTransparency = 1
			section.TextColor3 = Theme.Accent
			section.Font = Enum.Font.GothamBold
			section.TextSize = 11
			section.TextXAlignment = Enum.TextXAlignment.Left
			section.ZIndex = 2
			section.Parent = Page
			Padding(section, 8, 0, 0, 0)
			return section
		end
		
		function Elements:CreateLabel(config)
			config = config or {}
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 32)
			frame.BackgroundTransparency = 1
			frame.ZIndex = 2
			frame.Parent = Page
			local label = Instance.new("TextLabel")
			label.Text = config.Text or "Label"
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Theme.TextDim
			label.Font = Enum.Font.Gotham
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextWrapped = true
			label.ZIndex = 2
			label.Parent = frame
			Padding(label, 0, 5, 5, 0)
			return {SetText = function(self, text) label.Text = text end, GetText = function(self) return label.Text end, SetCallback = function(self, callback) end}
		end
		
		function Elements:CreateButton(config)
			config = config or {}
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1, 0, 0, 42)
			button.BackgroundColor3 = Theme.Element
			button.AutoButtonColor = false
			button.Text = ""
			button.ZIndex = 2
			button.Parent = Page
			Corner(button, 6)
			Stroke(button, Theme.Stroke, 1)
			local label = Instance.new("TextLabel")
			label.Text = config.Name or "Button"
			label.Size = UDim2.new(1, -60, 1, 0)
			label.Position = UDim2.new(0, 15, 0, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Theme.Text
			label.Font = Enum.Font.GothamSemibold
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.ZIndex = 2
			label.Parent = button
			local icon = Instance.new("ImageLabel")
			icon.Size = UDim2.new(0, 20, 0, 20)
			icon.Position = UDim2.new(1, -30, 0.5, -10)
			icon.BackgroundTransparency = 1
			icon.Image = "rbxassetid://10709791437"
			icon.ImageColor3 = Theme.TextDim
			icon.ZIndex = 2
			icon.Parent = button
			button.MouseEnter:Connect(function() Tween(button, {BackgroundColor3 = Theme.ElementHover}) Tween(icon, {ImageColor3 = Theme.Accent}) end)
			button.MouseLeave:Connect(function() Tween(button, {BackgroundColor3 = Theme.Element}) Tween(icon, {ImageColor3 = Theme.TextDim}) end)
			button.MouseButton1Click:Connect(function()
				Tween(button, {BackgroundColor3 = Theme.Stroke}, 0.1)
				task.wait(0.1)
				Tween(button, {BackgroundColor3 = Theme.Element}, 0.1)
				if config.Callback then task.spawn(config.Callback) end
			end)
			return {SetText = function(self, text) label.Text = text end, SetCallback = function(self, callback) config.Callback = callback end, Fire = function(self) if config.Callback then config.Callback() end end}
		end
		
		function Elements:CreateToggle(config)
			config = config or {}
			local state = config.Default or false
			local toggle = Instance.new("TextButton")
			toggle.Size = UDim2.new(1, 0, 0, 42)
			toggle.BackgroundColor3 = Theme.Element
			toggle.AutoButtonColor = false
			toggle.Text = ""
			toggle.ZIndex = 2
			toggle.Parent = Page
			Corner(toggle, 6)
			Stroke(toggle, Theme.Stroke, 1)
			local label = Instance.new("TextLabel")
			label.Text = config.Name or "Toggle"
			label.Size = UDim2.new(1, -70, 1, 0)
			label.Position = UDim2.new(0, 15, 0, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Theme.Text
			label.Font = Enum.Font.GothamSemibold
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.ZIndex = 2
			label.Parent = toggle
			local switch = Instance.new("Frame")
			switch.Size = UDim2.new(0, 42, 0, 22)
			switch.Position = UDim2.new(1, -55, 0.5, -11)
			switch.BackgroundColor3 = state and Theme.Accent or Theme.Main
			switch.BorderSizePixel = 0
			switch.ZIndex = 2
			switch.Parent = toggle
			Corner(switch, 11)
			local dot = Instance.new("Frame")
			dot.Size = UDim2.new(0, 18, 0, 18)
			dot.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
			dot.BackgroundColor3 = Theme.Text
			dot.BorderSizePixel = 0
			dot.ZIndex = 2
			dot.Parent = switch
			Corner(dot, 9)
			toggle.MouseButton1Click:Connect(function()
				state = not state
				Tween(switch, {BackgroundColor3 = state and Theme.Accent or Theme.Main}, 0.2)
				Tween(dot, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2)
				if config.Callback then task.spawn(config.Callback, state) end
			end)
			return {SetState = function(self, newState) state = newState Tween(switch, {BackgroundColor3 = state and Theme.Accent or Theme.Main}, 0.2) Tween(dot, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2) if config.Callback then task.spawn(config.Callback, state) end end, GetState = function(self) return state end, SetCallback = function(self, callback) config.Callback = callback end}
		end
		
		function Elements:CreateSlider(config)
			config = config or {}
			local min = config.Min or 0
			local max = config.Max or 100
			local value = config.Default or min
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 60)
			frame.BackgroundColor3 = Theme.Element
			frame.ZIndex = 2
			frame.Parent = Page
			Corner(frame, 6)
			Stroke(frame, Theme.Stroke, 1)
			local label = Instance.new("TextLabel")
			label.Text = config.Name or "Slider"
			label.Size = UDim2.new(1, -60, 0, 20)
			label.Position = UDim2.new(0, 15, 0, 10)
			label.BackgroundTransparency = 1
			label.TextColor3 = Theme.Text
			label.Font = Enum.Font.GothamSemibold
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.ZIndex = 2
			label.Parent = frame
			local valueLabel = Instance.new("TextLabel")
			valueLabel.Text = tostring(value)
			valueLabel.Size = UDim2.new(0, 50, 0, 20)
			valueLabel.Position = UDim2.new(1, -60, 0, 10)
			valueLabel.BackgroundTransparency = 1
			valueLabel.TextColor3 = Theme.Accent
			valueLabel.Font = Enum.Font.GothamBold
			valueLabel.TextSize = 13
			valueLabel.TextXAlignment = Enum.TextXAlignment.Right
			valueLabel.ZIndex = 2
			valueLabel.Parent = frame
			local bar = Instance.new("TextButton")
			bar.Text = ""
			bar.Size = UDim2.new(1, -30, 0, 6)
			bar.Position = UDim2.new(0, 15, 0, 42)
			bar.BackgroundColor3 = Theme.Main
			bar.AutoButtonColor = false
			bar.BorderSizePixel = 0
			bar.ZIndex = 2
			bar.Parent = frame
			Corner(bar, 3)
			local fill = Instance.new("Frame")
			fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
			fill.BackgroundColor3 = Theme.Accent
			fill.BorderSizePixel = 0
			fill.ZIndex = 2
			fill.Parent = bar
			Corner(fill, 3)
			local dragging = false
			local function Update(input)
				local percentage = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
				Tween(fill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1)
				local newValue = math.floor(min + ((max - min) * percentage))
				value = newValue
				valueLabel.Text = tostring(newValue)
				if config.Callback then task.spawn(config.Callback, newValue) end
			end
			bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true Update(input) end end)
			UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
			UIS.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end end)
			return {SetValue = function(self, newValue) value = math.clamp(newValue, min, max) valueLabel.Text = tostring(value) local percentage = (value - min) / (max - min) Tween(fill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.2) if config.Callback then task.spawn(config.Callback, value) end end, GetValue = function(self) return value end, SetCallback = function(self, callback) config.Callback = callback end}
		end
		
		function Elements:CreateKeybind(config)
			config = config or {}
			local key = config.Default
			local listening = false
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 42)
			frame.BackgroundColor3 = Theme.Element
			frame.ZIndex = 2
			frame.Parent = Page
			Corner(frame, 6)
			Stroke(frame, Theme.Stroke, 1)
			local label = Instance.new("TextLabel")
			label.Text = config.Name or "Keybind"
			label.Size = UDim2.new(1, -120, 1, 0)
			label.Position = UDim2.new(0, 15, 0, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Theme.Text
			label.Font = Enum.Font.GothamSemibold
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.ZIndex = 2
			label.Parent = frame
			local keyButton = Instance.new("TextButton")
			keyButton.Text = key and "[" .. key.Name .. "]" or "[NONE]"
			keyButton.Size = UDim2.new(0, 100, 0, 28)
			keyButton.Position = UDim2.new(1, -110, 0.5, -14)
			keyButton.BackgroundColor3 = Theme.Main
			keyButton.TextColor3 = Theme.Accent
			keyButton.Font = Enum.Font.GothamBold
			keyButton.TextSize = 12
			keyButton.AutoButtonColor = false
			keyButton.ZIndex = 2
			keyButton.Parent = frame
			Corner(keyButton, 4)
			keyButton.MouseButton1Click:Connect(function() listening = true keyButton.Text = "..." keyButton.TextColor3 = Theme.Text end)
			local connection
			connection = UIS.InputBegan:Connect(function(input, gameProcessed)
				if listening then
					if input.KeyCode == Enum.KeyCode.Escape then key = nil keyButton.Text = "[NONE]" keyButton.TextColor3 = Theme.Accent listening = false if config.Callback then task.spawn(config.Callback, nil) end
					elseif input.UserInputType == Enum.UserInputType.Keyboard and not gameProcessed then key = input.KeyCode keyButton.Text = "[" .. input.KeyCode.Name .. "]" keyButton.TextColor3 = Theme.Accent listening = false if config.Callback then task.spawn(config.Callback, key) end end
				end
			end)
			return {SetKey = function(self, newKey) key = newKey keyButton.Text = key and "[" .. key.Name .. "]" or "[NONE]" end, GetKey = function(self) return key end, SetCallback = function(self, callback) config.Callback = callback end}
		end
		
		function Elements:CreateInput(config)
			config = config or {}
			local text = config.Default or ""
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 42)
			frame.BackgroundColor3 = Theme.Element
			frame.ZIndex = 2
			frame.Parent = Page
			Corner(frame, 6)
			Stroke(frame, Theme.Stroke, 1)
			local label = Instance.new("TextLabel")
			label.Text = config.Name or "Input"
			label.Size = UDim2.new(0, 100, 1, 0)
			label.Position = UDim2.new(0, 15, 0, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Theme.Text
			label.Font = Enum.Font.GothamSemibold
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.ZIndex = 2
			label.Parent = frame
			local textBox = Instance.new("TextBox")
			textBox.Text = text
			textBox.PlaceholderText = config.Placeholder or "Enter..."
			textBox.Size = UDim2.new(1, -130, 0, 28)
			textBox.Position = UDim2.new(0, 120, 0.5, -14)
			textBox.BackgroundColor3 = Theme.Main
			textBox.TextColor3 = Theme.Text
			textBox.PlaceholderColor3 = Theme.TextDim
			textBox.Font = Enum.Font.Gotham
			textBox.TextSize = 12
			textBox.TextXAlignment = Enum.TextXAlignment.Left
			textBox.ClearTextOnFocus = false
			textBox.ZIndex = 2
			textBox.Parent = frame
			Corner(textBox, 4)
			Padding(textBox, 0, 10, 10, 0)
			textBox.FocusLost:Connect(function(enterPressed) text = textBox.Text if config.Callback then task.spawn(config.Callback, text, enterPressed) end end)
			return {SetText = function(self, newText) textBox.Text = newText text = newText end, GetText = function(self) return text end, SetCallback = function(self, callback) config.Callback = callback end}
		end
		
		function Elements:CreateDropdown(config)
			config = config or {}
			local options = config.Options or {"Option 1", "Option 2"}
			local selected = config.Default or options[1]
			local multiSelect = config.MultiSelect or false
			local selectedMulti = {}
			local open = false
			
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, 0, 0, 42)
			frame.BackgroundColor3 = Theme.Element
			frame.ClipsDescendants = false
			frame.ZIndex = 2
			frame.Parent = Page
			Corner(frame, 6)
			Stroke(frame, Theme.Stroke, 1)
			
			local label = Instance.new("TextLabel")
			label.Text = config.Name or "Dropdown"
			label.Size = UDim2.new(0, 120, 1, 0)
			label.Position = UDim2.new(0, 15, 0, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Theme.Text
			label.Font = Enum.Font.GothamSemibold
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.ZIndex = 2
			label.Parent = frame
			
			local selectButton = Instance.new("TextButton")
			selectButton.Text = selected
			selectButton.Size = UDim2.new(1, -145, 0, 28)
			selectButton.Position = UDim2.new(0, 130, 0.5, -14)
			selectButton.BackgroundColor3 = Theme.Main
			selectButton.TextColor3 = Theme.Accent
			selectButton.Font = Enum.Font.Gotham
			selectButton.TextSize = 12
			selectButton.TextXAlignment = Enum.TextXAlignment.Left
			selectButton.AutoButtonColor = false
			selectButton.TextTruncate = Enum.TextTruncate.AtEnd
			selectButton.ZIndex = 2
			selectButton.Parent = frame
			Corner(selectButton, 4)
			Padding(selectButton, 0, 10, 30, 0)
			
			local arrow = Instance.new("ImageLabel")
			arrow.Size = UDim2.new(0, 16, 0, 16)
			arrow.Position = UDim2.new(1, -22, 0.5, -8)
			arrow.BackgroundTransparency = 1
			arrow.Image = DefaultIcons.Dropdown
			arrow.ImageColor3 = Theme.TextDim
			arrow.Rotation = 0
			arrow.ZIndex = 2
			arrow.Parent = selectButton
			
			-- OPTIONS FRAME - PARENTED TO DROPDOWN OVERLAY
			local optionsFrame = Instance.new("ScrollingFrame")
			optionsFrame.Size = UDim2.new(0, frame.AbsoluteSize.X - 145, 0, 0)
			optionsFrame.Position = UDim2.new(0, frame.AbsolutePosition.X + 130, 0, frame.AbsolutePosition.Y + 47)
			optionsFrame.BackgroundColor3 = Theme.Element
			optionsFrame.Visible = false
			optionsFrame.ClipsDescendants = true
			optionsFrame.BorderSizePixel = 0
			optionsFrame.ScrollBarThickness = 3
			optionsFrame.ScrollBarImageColor3 = Theme.Stroke
			optionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			optionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
			optionsFrame.ZIndex = 10000
			optionsFrame.Parent = DropdownOverlay
			Corner(optionsFrame, 4)
			Stroke(optionsFrame, Theme.Stroke, 1)
			
			local optionsLayout = Instance.new("UIListLayout")
			optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
			optionsLayout.Padding = UDim.new(0, 2)
			optionsLayout.Parent = optionsFrame
			Padding(optionsFrame, 4, 4, 4, 4)
			
			local function UpdatePosition()
				optionsFrame.Position = UDim2.new(0, frame.AbsolutePosition.X + 130, 0, frame.AbsolutePosition.Y + 47)
				optionsFrame.Size = UDim2.new(0, frame.AbsoluteSize.X - 145, 0, optionsFrame.AbsoluteSize.Y)
			end
			
			frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePosition)
			frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdatePosition)
			
			local function CreateOption(optionText)
				local optionButton = Instance.new("TextButton")
				optionButton.Text = optionText
				optionButton.Size = UDim2.new(1, 0, 0, 28)
				optionButton.BackgroundColor3 = Theme.Main
				optionButton.TextColor3 = Theme.Text
				optionButton.Font = Enum.Font.Gotham
				optionButton.TextSize = 12
				optionButton.TextXAlignment = Enum.TextXAlignment.Left
				optionButton.AutoButtonColor = false
				optionButton.ZIndex = 10000
				optionButton.Parent = optionsFrame
				Corner(optionButton, 4)
				Padding(optionButton, 0, 8, 8, 0)
				
				optionButton.MouseEnter:Connect(function() Tween(optionButton, {BackgroundColor3 = Theme.ElementHover}) end)
				optionButton.MouseLeave:Connect(function() Tween(optionButton, {BackgroundColor3 = Theme.Main}) end)
				
				optionButton.MouseButton1Click:Connect(function()
					if multiSelect then
						if table.find(selectedMulti, optionText) then
							table.remove(selectedMulti, table.find(selectedMulti, optionText))
						else
							table.insert(selectedMulti, optionText)
						end
						selectButton.Text = #selectedMulti > 0 and table.concat(selectedMulti, ", ") or "None"
						if config.Callback then task.spawn(config.Callback, selectedMulti) end
					else
						selected = optionText
						selectButton.Text = optionText
						open = false
						Tween(optionsFrame, {Size = UDim2.new(0, frame.AbsoluteSize.X - 145, 0, 0)}, 0.2)
						Tween(arrow, {Rotation = 0}, 0.2)
						task.wait(0.2)
						optionsFrame.Visible = false
						if config.Callback then task.spawn(config.Callback, optionText) end
					end
				end)
			end
			
			for _, option in ipairs(options) do CreateOption(option) end
			
			selectButton.MouseButton1Click:Connect(function()
				open = not open
				if open then
					UpdatePosition()
					optionsFrame.Visible = true
					local height = math.min(#options * 30 + 8, 150)
					Tween(optionsFrame, {Size = UDim2.new(0, frame.AbsoluteSize.X - 145, 0, height)}, 0.2)
					Tween(arrow, {Rotation = 180}, 0.2)
				else
					Tween(optionsFrame, {Size = UDim2.new(0, frame.AbsoluteSize.X - 145, 0, 0)}, 0.2)
					Tween(arrow, {Rotation = 0}, 0.2)
					task.wait(0.2)
					optionsFrame.Visible = false
				end
			end)
			
			return {
				SetValue = function(self, value)
					if multiSelect then
						if type(value) == "table" then
							selectedMulti = value
							selectButton.Text = #selectedMulti > 0 and table.concat(selectedMulti, ", ") or "None"
							if config.Callback then task.spawn(config.Callback, selectedMulti) end
						end
					else
						if table.find(options, value) then
							selected = value
							selectButton.Text = value
							if config.Callback then task.spawn(config.Callback, value) end
						end
					end
				end,
				GetValue = function(self)
					return multiSelect and selectedMulti or selected
				end,
				UpdateOptions = function(self, newOptions)
					options = newOptions
					for _, child in ipairs(optionsFrame:GetChildren()) do
						if child:IsA("TextButton") then child:Destroy() end
					end
					for _, option in ipairs(options) do CreateOption(option) end
					if #options > 0 then
						if multiSelect then
							selectedMulti = {}
							selectButton.Text = "None"
						else
							selected = options[1]
							selectButton.Text = selected
						end
					end
				end,
				SetCallback = function(self, callback)
					config.Callback = callback
				end
			}
		end
		
		return Elements
	end
	
	UIS.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and ToggleKeybind and input.KeyCode == ToggleKeybind then
			ScreenGui.Enabled = not ScreenGui.Enabled
		end
	end)
	
	if PlayerTab and not PlayerTabCreated then
		PlayerTabCreated = true
		local Player = Tabs:CreateTab("Player", DefaultIcons.User)
		
		Player:CreateSection("Movement")
		
		local wsEnabled = false
		local wsValue = 16
		local wsMethod = "Heartbeat"
		
		Player:CreateToggle({Name = "Custom WalkSpeed", Default = false, Callback = function(state)
			wsEnabled = state
			if state then
				if Connections.WS then Connections.WS:Disconnect() end
				Connections.WS = RS[wsMethod]:Connect(function()
					if LP.Character and LP.Character:FindFirstChild("Humanoid") then
						LP.Character.Humanoid.WalkSpeed = wsValue
					end
				end)
			else
				if Connections.WS then Connections.WS:Disconnect() Connections.WS = nil end
				if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = 16 end
			end
		end})
		
		Player:CreateSlider({Name = "WalkSpeed Value", Min = 16, Max = 500, Default = 16, Callback = function(value) wsValue = value end})
		Player:CreateDropdown({Name = "WS Method", Options = {"Heartbeat", "RenderStepped", "Stepped"}, Default = "Heartbeat", Callback = function(value)
			wsMethod = value
			if wsEnabled then
				if Connections.WS then Connections.WS:Disconnect() end
				Connections.WS = RS[wsMethod]:Connect(function()
					if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed = wsValue end
				end)
			end
		end})
		
		local jpEnabled = false
		local jpValue = 50
		local jpMethod = "Heartbeat"
		
		Player:CreateToggle({Name = "Custom JumpPower", Default = false, Callback = function(state)
			jpEnabled = state
			if state then
				if Connections.JP then Connections.JP:Disconnect() end
				Connections.JP = RS[jpMethod]:Connect(function()
					if LP.Character and LP.Character:FindFirstChild("Humanoid") then
						LP.Character.Humanoid.UseJumpPower = true
						LP.Character.Humanoid.JumpPower = jpValue
					end
				end)
			else
				if Connections.JP then Connections.JP:Disconnect() Connections.JP = nil end
				if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.JumpPower = 50 end
			end
		end})
		
		Player:CreateSlider({Name = "JumpPower Value", Min = 50, Max = 500, Default = 50, Callback = function(value) jpValue = value end})
		Player:CreateDropdown({Name = "JP Method", Options = {"Heartbeat", "RenderStepped", "Stepped"}, Default = "Heartbeat", Callback = function(value)
			jpMethod = value
			if jpEnabled then
				if Connections.JP then Connections.JP:Disconnect() end
				Connections.JP = RS[jpMethod]:Connect(function()
					if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.UseJumpPower = true LP.Character.Humanoid.JumpPower = jpValue end
				end)
			end
		end})
		
		Player:CreateSection("Flight")
		
		local flying = false
		local flySpeed = 50
		local flyKey = nil
		
		Player:CreateKeybind({Name = "Fly Toggle", Default = nil, Callback = function(key)
			if flyKey and Connections.FlyKey then Connections.FlyKey:Disconnect() end
			flyKey = key
			if key then
				Connections.FlyKey = UIS.InputBegan:Connect(function(input, gameProcessed)
					if not gameProcessed and input.KeyCode == flyKey then
						flying = not flying
						local character = LP.Character
						if not character then return end
						local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
						if not humanoidRootPart then return end
						if flying then
							local bodyGyro = Instance.new("BodyGyro")
							local bodyVelocity = Instance.new("BodyVelocity")
							bodyGyro.P = 9e4
							bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
							bodyGyro.cframe = humanoidRootPart.CFrame
							bodyGyro.Parent = humanoidRootPart
							bodyVelocity.velocity = Vector3.zero
							bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
							bodyVelocity.Parent = humanoidRootPart
							Connections.Fly = RS.Heartbeat:Connect(function()
								if not flying or not character or not humanoidRootPart or not humanoidRootPart.Parent then
									if bodyGyro then bodyGyro:Destroy() end
									if bodyVelocity then bodyVelocity:Destroy() end
									if Connections.Fly then Connections.Fly:Disconnect() end
									return
								end
								local camera = workspace.CurrentCamera
								bodyGyro.cframe = camera.CFrame
								local velocity = Vector3.zero
								if UIS:IsKeyDown(Enum.KeyCode.W) then velocity = velocity + (camera.CFrame.LookVector * flySpeed) end
								if UIS:IsKeyDown(Enum.KeyCode.S) then velocity = velocity - (camera.CFrame.LookVector * flySpeed) end
								if UIS:IsKeyDown(Enum.KeyCode.D) then velocity = velocity + (camera.CFrame.RightVector * flySpeed) end
								if UIS:IsKeyDown(Enum.KeyCode.A) then velocity = velocity - (camera.CFrame.RightVector * flySpeed) end
								if UIS:IsKeyDown(Enum.KeyCode.Space) then velocity = velocity + Vector3.new(0, flySpeed, 0) end
								if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then velocity = velocity - Vector3.new(0, flySpeed, 0) end
								bodyVelocity.velocity = velocity
							end)
						else
							if Connections.Fly then Connections.Fly:Disconnect() end
						end
					end
				end)
			end
		end})
		
		Player:CreateSlider({Name = "Fly Speed", Min = 10, Max = 200, Default = 50, Callback = function(value) flySpeed = value end})
		
		local vflying = false
		local vflyKey = nil
		
		Player:CreateKeybind({Name = "Vehicle Fly Toggle", Default = nil, Callback = function(key)
			if vflyKey and Connections.VFlyKey then Connections.VFlyKey:Disconnect() end
			vflyKey = key
			if key then
				Connections.VFlyKey = UIS.InputBegan:Connect(function(input, gameProcessed)
					if not gameProcessed and input.KeyCode == vflyKey then
						vflying = not vflying
						local character = LP.Character
						if not character then return end
						local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
						if not humanoidRootPart then return end
						local humanoid = character:FindFirstChildOfClass("Humanoid")
						if not humanoid or not humanoid.SeatPart then return end
						if vflying then
							local seat = humanoid.SeatPart
							local vehicle = seat:FindFirstAncestorOfClass("Model")
							if not vehicle or not vehicle.PrimaryPart then return end
							local bodyGyro = Instance.new("BodyGyro")
							local bodyVelocity = Instance.new("BodyVelocity")
							bodyGyro.P = 9e4
							bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
							bodyGyro.cframe = vehicle.PrimaryPart.CFrame
							bodyGyro.Parent = vehicle.PrimaryPart
							bodyVelocity.velocity = Vector3.zero
							bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
							bodyVelocity.Parent = vehicle.PrimaryPart
							Connections.VFly = RS.Heartbeat:Connect(function()
								if not vflying or not vehicle or not vehicle.PrimaryPart or not vehicle.PrimaryPart.Parent then
									if bodyGyro then bodyGyro:Destroy() end
									if bodyVelocity then bodyVelocity:Destroy() end
									if Connections.VFly then Connections.VFly:Disconnect() end
									return
								end
								local camera = workspace.CurrentCamera
								bodyGyro.cframe = camera.CFrame
								local velocity = Vector3.zero
								if UIS:IsKeyDown(Enum.KeyCode.W) then velocity = velocity + (camera.CFrame.LookVector * flySpeed) end
								if UIS:IsKeyDown(Enum.KeyCode.S) then velocity = velocity - (camera.CFrame.LookVector * flySpeed) end
								if UIS:IsKeyDown(Enum.KeyCode.D) then velocity = velocity + (camera.CFrame.RightVector * flySpeed) end
								if UIS:IsKeyDown(Enum.KeyCode.A) then velocity = velocity - (camera.CFrame.RightVector * flySpeed) end
								if UIS:IsKeyDown(Enum.KeyCode.Space) then velocity = velocity + Vector3.new(0, flySpeed, 0) end
								if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then velocity = velocity - Vector3.new(0, flySpeed, 0) end
								bodyVelocity.velocity = velocity
							end)
						else
							if Connections.VFly then Connections.VFly:Disconnect() end
						end
					end
				end)
			end
		end})
		
		Player:CreateSection("Click TP")
		
		local ctpKey = nil
		
		Player:CreateKeybind({Name = "Click TP Key", Default = nil, Callback = function(key)
			if ctpKey and Connections.CtpKey then Connections.CtpKey:Disconnect() end
			ctpKey = key
			if key then
				Connections.CtpKey = UIS.InputBegan:Connect(function(input, gameProcessed)
					if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(ctpKey) then
						local humanoidRootPart = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
						if humanoidRootPart then
							local mouse = LP:GetMouse()
							if mouse.Target then humanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end
						end
					end
				end)
			end
		end})
		
		Player:CreateSection("Character")
		
		Player:CreateButton({Name = "Reset Character", Callback = function()
			if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.Health = 0 end
		end})
		
		local invisParts = {}
		
		Player:CreateToggle({Name = "Invisibility", Default = false, Callback = function(state)
			if state then
				if LP.Character then
					for _, descendant in pairs(LP.Character:GetDescendants()) do
						if descendant:IsA("BasePart") then invisParts[descendant] = descendant.Transparency descendant.Transparency = 1
						elseif descendant:IsA("Decal") then invisParts[descendant] = descendant.Transparency descendant.Transparency = 1 end
					end
				end
			else
				for part, transparency in pairs(invisParts) do
					if part and part.Parent then part.Transparency = transparency end
				end
				invisParts = {}
			end
		end})
		
		Player:CreateToggle({Name = "Fling", Default = false, Callback = function(state)
			if state then
				if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
					local humanoidRootPart = LP.Character.HumanoidRootPart
					local bodyAngularVelocity = Instance.new("BodyAngularVelocity")
					bodyAngularVelocity.Name = "Spin"
					bodyAngularVelocity.Parent = humanoidRootPart
					bodyAngularVelocity.MaxTorque = Vector3.new(0, math.huge, 0)
					bodyAngularVelocity.P = 9e9
					bodyAngularVelocity.AngularVelocity = Vector3.new(0, 9e9, 0)
					Connections.Fling = bodyAngularVelocity
				end
			else
				if Connections.Fling then Connections.Fling:Destroy() Connections.Fling = nil end
			end
		end})
		
		Player:CreateSection("World")
		
		Player:CreateButton({Name = "Fullbright", Callback = function() Lighting.Brightness = 2 Lighting.Ambient = Color3.new(1, 1, 1) end})
		Player:CreateButton({Name = "Remove Fog", Callback = function() Lighting.FogEnd = 999999 end})
		Player:CreateButton({Name = "Fix Lighting", Callback = function() Lighting.Brightness = 1 Lighting.Ambient = Color3.new(0.5, 0.5, 0.5) Lighting.FogEnd = 100000 end})
		
		Player:CreateSection("Server")
		
		Player:CreateButton({Name = "Rejoin Server", Callback = function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId) end})
		Player:CreateButton({Name = "Server Hop", Callback = function()
			local servers = {}
			local success, result = pcall(function() return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100") end)
			if success then
				local data = Http:JSONDecode(result)
				for _, server in pairs(data.data) do
					if server.id ~= game.JobId and server.playing < server.maxPlayers then table.insert(servers, server.id) end
				end
				if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)]) end
			end
		end})
	end
	
	local SettingsPage = Instance.new("ScrollingFrame")
	SettingsPage.Name = "SettingsPage"
	SettingsPage.Size = UDim2.new(1, 0, 1, 0)
	SettingsPage.BackgroundTransparency = 1
	SettingsPage.BorderSizePixel = 0
	SettingsPage.ScrollBarThickness = 4
	SettingsPage.ScrollBarImageColor3 = Theme.Stroke
	SettingsPage.ScrollBarImageTransparency = 0.3
	SettingsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
	SettingsPage.CanvasSize = UDim2.new(0, 0, 0, 0)
	SettingsPage.Visible = false
	SettingsPage.ZIndex = 2
	SettingsPage.Parent = Pages
	
	local SettingsLayout = Instance.new("UIListLayout")
	SettingsLayout.Padding = UDim.new(0, 15)
	SettingsLayout.Parent = SettingsPage
	Padding(SettingsPage, 15, 20, 20, 15)
	
	local function CreateSettingsSection(text)
		local section = Instance.new("TextLabel")
		section.Text = string.upper(text)
		section.Size = UDim2.new(1, 0, 0, 26)
		section.BackgroundTransparency = 1
		section.TextColor3 = Theme.Accent
		section.Font = Enum.Font.GothamBold
		section.TextSize = 11
		section.TextXAlignment = Enum.TextXAlignment.Left
		section.ZIndex = 2
		section.Parent = SettingsPage
		Padding(section, 8, 0, 0, 0)
		return section
	end
	
	local function CreateSettingsButton(text, callback)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, 0, 0, 42)
		button.BackgroundColor3 = Theme.Element
		button.AutoButtonColor = false
		button.Text = ""
		button.ZIndex = 2
		button.Parent = SettingsPage
		Corner(button, 6)
		Stroke(button, Theme.Stroke, 1)
		local label = Instance.new("TextLabel")
		label.Text = text
		label.Size = UDim2.new(1, -20, 1, 0)
		label.Position = UDim2.new(0, 15, 0, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Theme.Text
		label.Font = Enum.Font.GothamSemibold
		label.TextSize = 13
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 2
		label.Parent = button
		button.MouseEnter:Connect(function() Tween(button, {BackgroundColor3 = Theme.ElementHover}) end)
		button.MouseLeave:Connect(function() Tween(button, {BackgroundColor3 = Theme.Element}) end)
		button.MouseButton1Click:Connect(function() if callback then callback(label) end end)
		return button, label
	end
	
	CreateSettingsSection("Menu Controls")
	
	local keybindFrame = Instance.new("Frame")
	keybindFrame.Size = UDim2.new(1, 0, 0, 42)
	keybindFrame.BackgroundColor3 = Theme.Element
	keybindFrame.ZIndex = 2
	keybindFrame.Parent = SettingsPage
	Corner(keybindFrame, 6)
	Stroke(keybindFrame, Theme.Stroke, 1)
	
	local keybindLabel = Instance.new("TextLabel")
	keybindLabel.Text = "Toggle Keybind"
	keybindLabel.Size = UDim2.new(1, -120, 1, 0)
	keybindLabel.Position = UDim2.new(0, 15, 0, 0)
	keybindLabel.BackgroundTransparency = 1
	keybindLabel.TextColor3 = Theme.Text
	keybindLabel.Font = Enum.Font.GothamSemibold
	keybindLabel.TextSize = 13
	keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
	keybindLabel.ZIndex = 2
	keybindLabel.Parent = keybindFrame
	
	local keybindButton = Instance.new("TextButton")
	keybindButton.Text = ToggleKeybind and "[" .. ToggleKeybind.Name .. "]" or "[NONE]"
	keybindButton.Size = UDim2.new(0, 100, 0, 26)
	keybindButton.Position = UDim2.new(1, -110, 0.5, -13)
	keybindButton.BackgroundColor3 = Theme.Main
	keybindButton.TextColor3 = Theme.Accent
	keybindButton.Font = Enum.Font.GothamBold
	keybindButton.TextSize = 12
	keybindButton.AutoButtonColor = false
	keybindButton.ZIndex = 2
	keybindButton.Parent = keybindFrame
	Corner(keybindButton, 4)
	
	local keybindListening = false
	keybindButton.MouseButton1Click:Connect(function() keybindListening = true keybindButton.Text = "..." keybindButton.TextColor3 = Theme.Text end)
	
	UIS.InputBegan:Connect(function(input, gameProcessed)
		if keybindListening then
			if input.KeyCode == Enum.KeyCode.Escape then ToggleKeybind = nil keybindButton.Text = "[NONE]" keybindButton.TextColor3 = Theme.Accent keybindListening = false
			elseif input.UserInputType == Enum.UserInputType.Keyboard and not gameProcessed then ToggleKeybind = input.KeyCode keybindButton.Text = "[" .. input.KeyCode.Name .. "]" keybindButton.TextColor3 = Theme.Accent keybindListening = false end
		end
	end)
	
	CreateSettingsSection("Theme Management")
	
	local allThemes = GetAllThemes()
	local selectedTheme = allThemes[1] or nil
	
	local themeDropFrame = Instance.new("Frame")
	themeDropFrame.Size = UDim2.new(1, 0, 0, 42)
	themeDropFrame.BackgroundColor3 = Theme.Element
	themeDropFrame.ClipsDescendants = false
	themeDropFrame.ZIndex = 2
	themeDropFrame.Parent = SettingsPage
	Corner(themeDropFrame, 6)
	Stroke(themeDropFrame, Theme.Stroke, 1)
	
	local themeLabel = Instance.new("TextLabel")
	themeLabel.Text = "Selected:"
	themeLabel.Size = UDim2.new(0, 100, 1, 0)
	themeLabel.Position = UDim2.new(0, 15, 0, 0)
	themeLabel.BackgroundTransparency = 1
	themeLabel.TextColor3 = Theme.Text
	themeLabel.Font = Enum.Font.GothamSemibold
	themeLabel.TextSize = 13
	themeLabel.TextXAlignment = Enum.TextXAlignment.Left
	themeLabel.ZIndex = 2
	themeLabel.Parent = themeDropFrame
	
	local themeButton = Instance.new("TextButton")
	themeButton.Text = selectedTheme or "None"
	themeButton.Size = UDim2.new(1, -125, 0, 28)
	themeButton.Position = UDim2.new(0, 115, 0.5, -14)
	themeButton.BackgroundColor3 = Theme.Main
	themeButton.TextColor3 = Theme.Accent
	themeButton.Font = Enum.Font.Gotham
	themeButton.TextSize = 12
	themeButton.TextXAlignment = Enum.TextXAlignment.Left
	themeButton.AutoButtonColor = false
	themeButton.TextTruncate = Enum.TextTruncate.AtEnd
	themeButton.ZIndex = 2
	themeButton.Parent = themeDropFrame
	Corner(themeButton, 4)
	Padding(themeButton, 0, 10, 30, 0)
	
	local themeArrow = Instance.new("ImageLabel")
	themeArrow.Size = UDim2.new(0, 16, 0, 16)
	themeArrow.Position = UDim2.new(1, -22, 0.5, -8)
	themeArrow.BackgroundTransparency = 1
	themeArrow.Image = DefaultIcons.Dropdown
	themeArrow.ImageColor3 = Theme.TextDim
	themeArrow.Rotation = 0
	themeArrow.ZIndex = 2
	themeArrow.Parent = themeButton
	
	local themeOptionsFrame = Instance.new("ScrollingFrame")
	themeOptionsFrame.Size = UDim2.new(0, themeDropFrame.AbsoluteSize.X - 125, 0, 0)
	themeOptionsFrame.Position = UDim2.new(0, themeDropFrame.AbsolutePosition.X + 115, 0, themeDropFrame.AbsolutePosition.Y + 47)
	themeOptionsFrame.BackgroundColor3 = Theme.Element
	themeOptionsFrame.Visible = false
	themeOptionsFrame.ClipsDescendants = true
	themeOptionsFrame.BorderSizePixel = 0
	themeOptionsFrame.ScrollBarThickness = 3
	themeOptionsFrame.ScrollBarImageColor3 = Theme.Stroke
	themeOptionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	themeOptionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	themeOptionsFrame.ZIndex = 10000
	themeOptionsFrame.Parent = DropdownOverlay
	Corner(themeOptionsFrame, 4)
	Stroke(themeOptionsFrame, Theme.Stroke, 1)
	
	local themeOptionsLayout = Instance.new("UIListLayout")
	themeOptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	themeOptionsLayout.Padding = UDim.new(0, 2)
	themeOptionsLayout.Parent = themeOptionsFrame
	Padding(themeOptionsFrame, 4, 4, 4, 4)
	
	local themeDropdownOpen = false
	
	local function UpdateThemePosition()
		themeOptionsFrame.Position = UDim2.new(0, themeDropFrame.AbsolutePosition.X + 115, 0, themeDropFrame.AbsolutePosition.Y + 47)
		themeOptionsFrame.Size = UDim2.new(0, themeDropFrame.AbsoluteSize.X - 125, 0, themeOptionsFrame.AbsoluteSize.Y)
	end
	
	themeDropFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateThemePosition)
	themeDropFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateThemePosition)
	
	local function UpdateThemeDropdown()
		for _, child in ipairs(themeOptionsFrame:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		allThemes = GetAllThemes()
		for _, themeName in ipairs(allThemes) do
			local optionButton = Instance.new("TextButton")
			optionButton.Text = themeName
			optionButton.Size = UDim2.new(1, 0, 0, 28)
			optionButton.BackgroundColor3 = Theme.Main
			optionButton.TextColor3 = Theme.Text
			optionButton.Font = Enum.Font.Gotham
			optionButton.TextSize = 12
			optionButton.TextXAlignment = Enum.TextXAlignment.Left
			optionButton.AutoButtonColor = false
			optionButton.ZIndex = 10000
			optionButton.Parent = themeOptionsFrame
			Corner(optionButton, 4)
			Padding(optionButton, 0, 8, 8, 0)
			optionButton.MouseEnter:Connect(function() Tween(optionButton, {BackgroundColor3 = Theme.ElementHover}) end)
			optionButton.MouseLeave:Connect(function() Tween(optionButton, {BackgroundColor3 = Theme.Main}) end)
			optionButton.MouseButton1Click:Connect(function()
				selectedTheme = themeName
				themeButton.Text = themeName
				themeDropdownOpen = false
				Tween(themeOptionsFrame, {Size = UDim2.new(0, themeDropFrame.AbsoluteSize.X - 125, 0, 0)}, 0.2)
				Tween(themeArrow, {Rotation = 0}, 0.2)
				task.wait(0.2)
				themeOptionsFrame.Visible = false
			end)
		end
	end
	
	UpdateThemeDropdown()
	
	themeButton.MouseButton1Click:Connect(function()
		themeDropdownOpen = not themeDropdownOpen
		if themeDropdownOpen then
			UpdateThemePosition()
			themeOptionsFrame.Visible = true
			local height = math.min(#allThemes * 30 + 8, 150)
			Tween(themeOptionsFrame, {Size = UDim2.new(0, themeDropFrame.AbsoluteSize.X - 125, 0, height)}, 0.2)
			Tween(themeArrow, {Rotation = 180}, 0.2)
		else
			Tween(themeOptionsFrame, {Size = UDim2.new(0, themeDropFrame.AbsoluteSize.X - 125, 0, 0)}, 0.2)
			Tween(themeArrow, {Rotation = 0}, 0.2)
			task.wait(0.2)
			themeOptionsFrame.Visible = false
		end
	end)
	
	local themeNameFrame = Instance.new("Frame")
	themeNameFrame.Size = UDim2.new(1, 0, 0, 42)
	themeNameFrame.BackgroundColor3 = Theme.Element
	themeNameFrame.ZIndex = 2
	themeNameFrame.Parent = SettingsPage
	Corner(themeNameFrame, 6)
	Stroke(themeNameFrame, Theme.Stroke, 1)
	
	local themeNameLabel = Instance.new("TextLabel")
	themeNameLabel.Text = "Theme Name:"
	themeNameLabel.Size = UDim2.new(0, 100, 1, 0)
	themeNameLabel.Position = UDim2.new(0, 15, 0, 0)
	themeNameLabel.BackgroundTransparency = 1
	themeNameLabel.TextColor3 = Theme.Text
	themeNameLabel.Font = Enum.Font.GothamSemibold
	themeNameLabel.TextSize = 13
	themeNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	themeNameLabel.ZIndex = 2
	themeNameLabel.Parent = themeNameFrame
	
	local themeNameBox = Instance.new("TextBox")
	themeNameBox.Text = ""
	themeNameBox.PlaceholderText = "Enter theme name..."
	themeNameBox.Size = UDim2.new(1, -125, 0, 28)
	themeNameBox.Position = UDim2.new(0, 115, 0.5, -14)
	themeNameBox.BackgroundColor3 = Theme.Main
	themeNameBox.TextColor3 = Theme.Text
	themeNameBox.PlaceholderColor3 = Theme.TextDim
	themeNameBox.Font = Enum.Font.Gotham
	themeNameBox.TextSize = 12
	themeNameBox.TextXAlignment = Enum.TextXAlignment.Left
	themeNameBox.ClearTextOnFocus = false
	themeNameBox.ZIndex = 2
	themeNameBox.Parent = themeNameFrame
	Corner(themeNameBox, 4)
	Padding(themeNameBox, 0, 10, 10, 0)
	
	CreateSettingsButton("Create Theme", function(label) local themeName = themeNameBox.Text if themeName ~= "" then SaveTheme(themeName, Theme) label.Text = "✓ Created!" UpdateThemeDropdown() task.wait(2) label.Text = "Create Theme" end end)
	CreateSettingsButton("Overwrite Theme", function(label) if selectedTheme then SaveTheme(selectedTheme, Theme) label.Text = "✓ Overwritten!" task.wait(2) label.Text = "Overwrite Theme" end end)
	CreateSettingsButton("Delete Theme", function(label) if selectedTheme then DeleteTheme(selectedTheme) label.Text = "✓ Deleted!" UpdateThemeDropdown() selectedTheme = nil themeButton.Text = "None" task.wait(2) label.Text = "Delete Theme" end end)
	CreateSettingsButton("Load Theme", function(label) if selectedTheme then local themeData = LoadTheme(selectedTheme) if themeData then for key, value in pairs(themeData) do Theme[key] = value end label.Text = "✓ Loaded!" task.wait(2) label.Text = "Load Theme" end end end)
	CreateSettingsButton("Export Current Theme", function(label) setclipboard(Http:JSONEncode(Theme)) label.Text = "✓ Copied!" task.wait(2) label.Text = "Export Current Theme" end)
	
	CreateSettingsSection("Config Management")
	
	local allConfigs = GetAllConfigs()
	local selectedConfig = allConfigs[1] or nil
	
	local configDropFrame = Instance.new("Frame")
	configDropFrame.Size = UDim2.new(1, 0, 0, 42)
	configDropFrame.BackgroundColor3 = Theme.Element
	configDropFrame.ClipsDescendants = false
	configDropFrame.ZIndex = 2
	configDropFrame.Parent = SettingsPage
	Corner(configDropFrame, 6)
	Stroke(configDropFrame, Theme.Stroke, 1)
	
	local configLabel = Instance.new("TextLabel")
	configLabel.Text = "Selected:"
	configLabel.Size = UDim2.new(0, 100, 1, 0)
	configLabel.Position = UDim2.new(0, 15, 0, 0)
	configLabel.BackgroundTransparency = 1
	configLabel.TextColor3 = Theme.Text
	configLabel.Font = Enum.Font.GothamSemibold
	configLabel.TextSize = 13
	configLabel.TextXAlignment = Enum.TextXAlignment.Left
	configLabel.ZIndex = 2
	configLabel.Parent = configDropFrame
	
	local configButton = Instance.new("TextButton")
	configButton.Text = selectedConfig or "None"
	configButton.Size = UDim2.new(1, -125, 0, 28)
	configButton.Position = UDim2.new(0, 115, 0.5, -14)
	configButton.BackgroundColor3 = Theme.Main
	configButton.TextColor3 = Theme.Accent
	configButton.Font = Enum.Font.Gotham
	configButton.TextSize = 12
	configButton.TextXAlignment = Enum.TextXAlignment.Left
	configButton.AutoButtonColor = false
	configButton.TextTruncate = Enum.TextTruncate.AtEnd
	configButton.ZIndex = 2
	configButton.Parent = configDropFrame
	Corner(configButton, 4)
	Padding(configButton, 0, 10, 30, 0)
	
	local configArrow = Instance.new("ImageLabel")
	configArrow.Size = UDim2.new(0, 16, 0, 16)
	configArrow.Position = UDim2.new(1, -22, 0.5, -8)
	configArrow.BackgroundTransparency = 1
	configArrow.Image = DefaultIcons.Dropdown
	configArrow.ImageColor3 = Theme.TextDim
	configArrow.Rotation = 0
	configArrow.ZIndex = 2
	configArrow.Parent = configButton
	
	local configOptionsFrame = Instance.new("ScrollingFrame")
	configOptionsFrame.Size = UDim2.new(0, configDropFrame.AbsoluteSize.X - 125, 0, 0)
	configOptionsFrame.Position = UDim2.new(0, configDropFrame.AbsolutePosition.X + 115, 0, configDropFrame.AbsolutePosition.Y + 47)
	configOptionsFrame.BackgroundColor3 = Theme.Element
	configOptionsFrame.Visible = false
	configOptionsFrame.ClipsDescendants = true
	configOptionsFrame.BorderSizePixel = 0
	configOptionsFrame.ScrollBarThickness = 3
	configOptionsFrame.ScrollBarImageColor3 = Theme.Stroke
	configOptionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	configOptionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	configOptionsFrame.ZIndex = 10000
	configOptionsFrame.Parent = DropdownOverlay
	Corner(configOptionsFrame, 4)
	Stroke(configOptionsFrame, Theme.Stroke, 1)
	
	local configOptionsLayout = Instance.new("UIListLayout")
	configOptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	configOptionsLayout.Padding = UDim.new(0, 2)
	configOptionsLayout.Parent = configOptionsFrame
	Padding(configOptionsFrame, 4, 4, 4, 4)
	
	local configDropdownOpen = false
	
	local function UpdateConfigPosition()
		configOptionsFrame.Position = UDim2.new(0, configDropFrame.AbsolutePosition.X + 115, 0, configDropFrame.AbsolutePosition.Y + 47)
		configOptionsFrame.Size = UDim2.new(0, configDropFrame.AbsoluteSize.X - 125, 0, configOptionsFrame.AbsoluteSize.Y)
	end
	
	configDropFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateConfigPosition)
	configDropFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateConfigPosition)
	
	local function UpdateConfigDropdown()
		for _, child in ipairs(configOptionsFrame:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		allConfigs = GetAllConfigs()
		for _, configName in ipairs(allConfigs) do
			local optionButton = Instance.new("TextButton")
			optionButton.Text = configName
			optionButton.Size = UDim2.new(1, 0, 0, 28)
			optionButton.BackgroundColor3 = Theme.Main
			optionButton.TextColor3 = Theme.Text
			optionButton.Font = Enum.Font.Gotham
			optionButton.TextSize = 12
			optionButton.TextXAlignment = Enum.TextXAlignment.Left
			optionButton.AutoButtonColor = false
			optionButton.ZIndex = 10000
			optionButton.Parent = configOptionsFrame
			Corner(optionButton, 4)
			Padding(optionButton, 0, 8, 8, 0)
			optionButton.MouseEnter:Connect(function() Tween(optionButton, {BackgroundColor3 = Theme.ElementHover}) end)
			optionButton.MouseLeave:Connect(function() Tween(optionButton, {BackgroundColor3 = Theme.Main}) end)
			optionButton.MouseButton1Click:Connect(function()
				selectedConfig = configName
				configButton.Text = configName
				configDropdownOpen = false
				Tween(configOptionsFrame, {Size = UDim2.new(0, configDropFrame.AbsoluteSize.X - 125, 0, 0)}, 0.2)
				Tween(configArrow, {Rotation = 0}, 0.2)
				task.wait(0.2)
				configOptionsFrame.Visible = false
			end)
		end
	end
	
	UpdateConfigDropdown()
	
	configButton.MouseButton1Click:Connect(function()
		configDropdownOpen = not configDropdownOpen
		if configDropdownOpen then
			UpdateConfigPosition()
			configOptionsFrame.Visible = true
			local height = math.min(#allConfigs * 30 + 8, 150)
			Tween(configOptionsFrame, {Size = UDim2.new(0, configDropFrame.AbsoluteSize.X - 125, 0, height)}, 0.2)
			Tween(configArrow, {Rotation = 180}, 0.2)
		else
			Tween(configOptionsFrame, {Size = UDim2.new(0, configDropFrame.AbsoluteSize.X - 125, 0, 0)}, 0.2)
			Tween(configArrow, {Rotation = 0}, 0.2)
			task.wait(0.2)
			configOptionsFrame.Visible = false
		end
	end)
	
	local configNameFrame = Instance.new("Frame")
	configNameFrame.Size = UDim2.new(1, 0, 0, 42)
	configNameFrame.BackgroundColor3 = Theme.Element
	configNameFrame.ZIndex = 2
	configNameFrame.Parent = SettingsPage
	Corner(configNameFrame, 6)
	Stroke(configNameFrame, Theme.Stroke, 1)
	
	local configNameLabel = Instance.new("TextLabel")
	configNameLabel.Text = "Config Name:"
	configNameLabel.Size = UDim2.new(0, 100, 1, 0)
	configNameLabel.Position = UDim2.new(0, 15, 0, 0)
	configNameLabel.BackgroundTransparency = 1
	configNameLabel.TextColor3 = Theme.Text
	configNameLabel.Font = Enum.Font.GothamSemibold
	configNameLabel.TextSize = 13
	configNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	configNameLabel.ZIndex = 2
	configNameLabel.Parent = configNameFrame
	
	local configNameBox = Instance.new("TextBox")
	configNameBox.Text = GameConfig and tostring(game.PlaceId) or ""
	configNameBox.PlaceholderText = "Enter config name..."
	configNameBox.Size = UDim2.new(1, -125, 0, 28)
	configNameBox.Position = UDim2.new(0, 115, 0.5, -14)
	configNameBox.BackgroundColor3 = Theme.Main
	configNameBox.TextColor3 = Theme.Text
	configNameBox.PlaceholderColor3 = Theme.TextDim
	configNameBox.Font = Enum.Font.Gotham
	configNameBox.TextSize = 12
	configNameBox.TextXAlignment = Enum.TextXAlignment.Left
	configNameBox.ClearTextOnFocus = false
	configNameBox.ZIndex = 2
	configNameBox.Parent = configNameFrame
	Corner(configNameBox, 4)
	Padding(configNameBox, 0, 10, 10, 0)
	
	CreateSettingsButton("Create Config", function(label) local configName = configNameBox.Text if configName ~= "" then SaveConfig(configName, {theme = Theme}) label.Text = "✓ Created!" UpdateConfigDropdown() task.wait(2) label.Text = "Create Config" end end)
	CreateSettingsButton("Overwrite Config", function(label) if selectedConfig then SaveConfig(selectedConfig, {theme = Theme}) label.Text = "✓ Overwritten!" task.wait(2) label.Text = "Overwrite Config" end end)
	CreateSettingsButton("Delete Config", function(label) if selectedConfig then DeleteConfig(selectedConfig) label.Text = "✓ Deleted!" UpdateConfigDropdown() selectedConfig = nil configButton.Text = "None" task.wait(2) label.Text = "Delete Config" end end)
	CreateSettingsButton("Load Config", function(label) if selectedConfig then local configData = LoadConfig(selectedConfig) if configData and configData.theme then for key, value in pairs(configData.theme) do Theme[key] = value end label.Text = "✓ Loaded!" task.wait(2) label.Text = "Load Config" end end end)
	
	CreateSettingsSection("Library")
	
	CreateSettingsButton("Unload Hub", function()
		for _, connection in pairs(Connections) do if connection and connection.Disconnect then connection:Disconnect() end end
		Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
		task.wait(0.3)
		ScreenGui:Destroy()
	end)
	
	local SettingsButton = Instance.new("TextButton")
	SettingsButton.Name = "SettingsBtn"
	SettingsButton.Size = UDim2.new(1, -20, 1, -5)
	SettingsButton.Position = UDim2.new(0, 10, 0, 0)
	SettingsButton.BackgroundTransparency = 1
	SettingsButton.BackgroundColor3 = Theme.Element
	SettingsButton.AutoButtonColor = false
	SettingsButton.Text = ""
	SettingsButton.LayoutOrder = 999
	SettingsButton.Parent = SettingsArea
	Corner(SettingsButton, 6)
	
	local SettingsIcon = Instance.new("ImageLabel")
	SettingsIcon.Name = "Icon"
	SettingsIcon.Size = UDim2.new(0, 18, 0, 18)
	SettingsIcon.Position = UDim2.new(0, 12, 0.5, -9)
	SettingsIcon.BackgroundTransparency = 1
	SettingsIcon.Image = DefaultIcons.Settings
	SettingsIcon.ImageColor3 = Theme.TextDim
	SettingsIcon.Parent = SettingsButton
	
	local SettingsLabel = Instance.new("TextLabel")
	SettingsLabel.Name = "Label"
	SettingsLabel.Text = "Settings"
	SettingsLabel.Size = UDim2.new(1, -50, 1, 0)
	SettingsLabel.Position = UDim2.new(0, 42, 0, 0)
	SettingsLabel.BackgroundTransparency = 1
	SettingsLabel.TextColor3 = Theme.TextDim
	SettingsLabel.Font = Enum.Font.GothamMedium
	SettingsLabel.TextSize = 14
	SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
	SettingsLabel.Parent = SettingsButton
	
	SettingsButton.MouseEnter:Connect(function() if ActiveTab ~= "Settings" then Tween(SettingsButton, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.5}) end end)
	SettingsButton.MouseLeave:Connect(function() if ActiveTab ~= "Settings" then Tween(SettingsButton, {BackgroundTransparency = 1}) end end)
	
	SettingsButton.MouseButton1Click:Connect(function()
		for _, tab in pairs(TabContainer:GetChildren()) do
			if tab:IsA("TextButton") then Tween(tab, {BackgroundTransparency = 1}) if tab:FindFirstChild("Label") then Tween(tab.Label, {TextColor3 = Theme.TextDim}) end if tab:FindFirstChild("Icon") then Tween(tab.Icon, {ImageColor3 = Theme.TextDim}) end end
		end
		for _, page in pairs(Pages:GetChildren()) do if page:IsA("ScrollingFrame") then page.Visible = false end end
		SettingsPage.Visible = true
		ActiveTab = "Settings"
		Tween(SettingsButton, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0})
		Tween(SettingsLabel, {TextColor3 = Theme.Text})
		Tween(SettingsIcon, {ImageColor3 = Theme.Accent})
	end)
	
	if AutoLoad then
		local autoloadName = GameConfig and tostring(game.PlaceId) or "default"
		local configData = LoadConfig(autoloadName)
		if configData and configData.theme then for key, value in pairs(configData.theme) do Theme[key] = value end end
	end
	
	print("╔══════════════════════════════════════════╗")
	print("║       CHUDDY HUB - Made by foeky         ║")
	print("╚══════════════════════════════════════════╝")
	print("✓ GUI Loaded Successfully")
	print("Press [" .. (ToggleKeybind and ToggleKeybind.Name or "NONE") .. "] to toggle")
	print("Version: " .. Chuddy.Version)
	
	CurrentWindow = Tabs
	return Tabs
end

return Chuddy
