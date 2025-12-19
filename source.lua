--[[
    CHUDDY HUB | ULTIMATE EDITION
    The most based UI library for chads
    Now with 100% more chudjak energy
]]

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local Http = game:GetService("HttpService")

local Chuddy = {}
local ActiveHumanoidMods = {}

-- Theme presets (for the gigachads)
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
	},
	Midnight = {
		Name = "Midnight Purple",
		Main = Color3.fromRGB(15, 12, 20),
		Sidebar = Color3.fromRGB(20, 15, 28),
		Element = Color3.fromRGB(28, 22, 38),
		ElementHover = Color3.fromRGB(35, 28, 48),
		Text = Color3.fromRGB(230, 220, 255),
		TextDim = Color3.fromRGB(150, 130, 180),
		Accent = Color3.fromRGB(138, 43, 226),
		Stroke = Color3.fromRGB(50, 40, 70),
		Divider = Color3.fromRGB(40, 30, 55)
	},
	Ocean = {
		Name = "Ocean Breeze",
		Main = Color3.fromRGB(10, 18, 25),
		Sidebar = Color3.fromRGB(15, 25, 35),
		Element = Color3.fromRGB(20, 35, 48),
		ElementHover = Color3.fromRGB(25, 45, 60),
		Text = Color3.fromRGB(200, 230, 255),
		TextDim = Color3.fromRGB(120, 160, 190),
		Accent = Color3.fromRGB(0, 191, 255),
		Stroke = Color3.fromRGB(30, 60, 85),
		Divider = Color3.fromRGB(25, 50, 70)
	}
}

local Theme = table.clone(ThemePresets.Chudjak)

local Icons = {
	Logo = "rbxassetid://134140528282189",
	Settings = "rbxassetid://10723415903",
	User = "rbxassetid://10723415903",
	Close = "rbxassetid://3926305904",
	Min = "rbxassetid://3926307971",
	Maximize = "rbxassetid://3926305904",
	Pointer = "rbxassetid://10709791437",
	Checkmark = "rbxassetid://10709818928",
	Dropdown = "rbxassetid://10709790948"
}

-- Chad utilities
local function Tween(obj, props, time)
	if not obj or not obj.Parent then return end
	TS:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad), props):Play()
end

local function GetParent()
	return pcall(gethui) and gethui() or LP:WaitForChild("PlayerGui")
end

local function Corner(parent, rad)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, rad or 6)
	c.Parent = parent
	return c
end

local function Stroke(parent, col, thick)
	local s = Instance.new("UIStroke")
	s.Color = col or Theme.Stroke
	s.Thickness = thick or 1
	s.Parent = parent
	return s
end

local function Padding(parent, t, l, r, b)
	local p = Instance.new("UIPadding")
	p.PaddingTop = UDim.new(0, t or 0)
	p.PaddingLeft = UDim.new(0, l or 0)
	p.PaddingRight = UDim.new(0, r or 0)
	p.PaddingBottom = UDim.new(0, b or 0)
	p.Parent = parent
	return p
end

-- Config management (for the organized chads)
local ConfigFolder = "ChuddyHub"
local function SaveConfig(name, data)
	if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
	writefile(ConfigFolder .. "/" .. name .. ".json", Http:JSONEncode(data))
end

local function LoadConfig(name)
	local path = ConfigFolder .. "/" .. name .. ".json"
	if isfile(path) then
		return Http:JSONDecode(readfile(path))
	end
	return nil
end

local function GetConfigs()
	if not isfolder(ConfigFolder) then return {} end
	local configs = {}
	for _, file in ipairs(listfiles(ConfigFolder)) do
		if file:match("%.json$") then
			local name = file:match("([^/]+)%.json$")
			table.insert(configs, name)
		end
	end
	return configs
end

-- Theme utilities (drip customization)
local function SaveTheme(name, themeData)
	SaveConfig("theme_" .. name, themeData)
end

local function LoadTheme(name)
	return LoadConfig("theme_" .. name)
end

local function ApplyTheme(newTheme)
	for k, v in pairs(newTheme) do
		Theme[k] = v
	end
end

local function ExportTheme()
	return Http:JSONEncode(Theme)
end

local function ImportTheme(themeJson)
	local success, decoded = pcall(function()
		return Http:JSONDecode(themeJson)
	end)
	if success and decoded then
		ApplyTheme(decoded)
		return true
	end
	return false
end

-- Player modification utilities (for the based exploiters)
local PlayerMods = {
	WalkSpeed = {default = 16, current = 16, enabled = false},
	JumpPower = {default = 50, current = 50, enabled = false},
	JumpHeight = {default = 7.2, current = 7.2, enabled = false},
	Gravity = {default = 196.2, current = 196.2, enabled = false},
	HipHeight = {default = 0, current = 0, enabled = false}
}

local function ApplyPlayerMod(modName, value)
	local char = LP.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	
	if modName == "WalkSpeed" then
		hum.WalkSpeed = value
	elseif modName == "JumpPower" then
		hum.UseJumpPower = true
		hum.JumpPower = value
	elseif modName == "JumpHeight" then
		hum.UseJumpPower = false
		hum.JumpHeight = value
	elseif modName == "Gravity" then
		workspace.Gravity = value
	elseif modName == "HipHeight" then
		hum.HipHeight = value
	end
end

local function EnablePlayerMod(modName)
	PlayerMods[modName].enabled = true
	
	if ActiveHumanoidMods[modName] then
		ActiveHumanoidMods[modName]:Disconnect()
	end
	
	ActiveHumanoidMods[modName] = RS.Heartbeat:Connect(function()
		if PlayerMods[modName].enabled then
			ApplyPlayerMod(modName, PlayerMods[modName].current)
		end
	end)
end

local function DisablePlayerMod(modName)
	PlayerMods[modName].enabled = false
	if ActiveHumanoidMods[modName] then
		ActiveHumanoidMods[modName]:Disconnect()
		ActiveHumanoidMods[modName] = nil
	end
	ApplyPlayerMod(modName, PlayerMods[modName].default)
end

-- Teleport utilities (zooming around like a chad)
local function TeleportTo(position, method)
	local char = LP.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	
	method = method or "CFrame"
	
	if method == "CFrame" then
		hrp.CFrame = CFrame.new(position)
	elseif method == "Position" then
		hrp.Position = position
	elseif method == "Velocity" then
		local direction = (position - hrp.Position).Unit
		local distance = (position - hrp.Position).Magnitude
		hrp.Velocity = direction * math.min(distance * 2, 200)
	elseif method == "Tween" then
		local tween = TS:Create(hrp, TweenInfo.new(0.5, Enum.EasingStyle.Linear), {CFrame = CFrame.new(position)})
		tween:Play()
	end
end

-- Anti-detection (stay under the radar king)
local function BypassAC()
	for _, v in pairs(getconnections(LP.Idled)) do
		v:Disable()
	end
end

-- Create the gigachad window
function Chuddy:CreateWindow(cfg)
	cfg = cfg or {}
	local WinName = cfg.Name or "Chuddy Hub"
	local Keybind = cfg.Keybind or Enum.KeyCode.RightControl
	local AutoLoad = cfg.AutoLoad ~= false
	local GameConfig = cfg.GameConfig ~= false
	
	BypassAC()
	
	local SGui = Instance.new("ScreenGui")
	SGui.Name = "ChuddyUI_" .. game.PlaceId
	SGui.ResetOnSpawn = false
	SGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	SGui.Parent = GetParent()
	
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 750, 0, 550)
	Main.Position = UDim2.new(0.5, -375, 0.5, -275)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = SGui
	
	Corner(Main, 8)
	Stroke(Main, Theme.Stroke, 1)

	-- Sidebar (left panel for navigation)
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

	-- Header
	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 60)
	Header.BackgroundTransparency = 1
	Header.Parent = Sidebar
	
	local Logo = Instance.new("ImageLabel")
	Logo.Size = UDim2.new(0, 30, 0, 30)
	Logo.Position = UDim2.new(0, 15, 0.5, -15)
	Logo.BackgroundTransparency = 1
	Logo.Image = Icons.Logo
	Logo.Parent = Header
	Corner(Logo, 5)
	
	local Title = Instance.new("TextLabel")
	Title.Text = WinName
	Title.Size = UDim2.new(1, -60, 1, 0)
	Title.Position = UDim2.new(0, 55, 0, 0)
	Title.BackgroundTransparency = 1
	Title.TextColor3 = Theme.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 15
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextTruncate = Enum.TextTruncate.AtEnd
	Title.Parent = Header

	-- User profile (flex your username)
	local UserProfile = Instance.new("Frame")
	UserProfile.Name = "UserProfile"
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
		local success, thumb = pcall(function()
			return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		end)
		if success then Avatar.Image = thumb end
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

	-- Settings area (above profile)
	local SettingsArea = Instance.new("Frame")
	SettingsArea.Name = "SettingsArea"
	SettingsArea.Size = UDim2.new(1, 0, 0, 50)
	SettingsArea.Position = UDim2.new(0, 0, 1, -115)
	SettingsArea.BackgroundTransparency = 1
	SettingsArea.Parent = Sidebar

	-- Tab container (scrollable list)
	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"
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

	-- Content area (main stuff goes here)
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Size = UDim2.new(1, -210, 1, 0)
	Content.Position = UDim2.new(0, 210, 0, 0)
	Content.BackgroundTransparency = 1
	Content.ClipsDescendants = true
	Content.Parent = Main
	
	-- Top bar with controls
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, 50)
	TopBar.BackgroundTransparency = 1
	TopBar.Parent = Content
	
	local TopSep = Instance.new("Frame")
	TopSep.Size = UDim2.new(1, 0, 0, 1)
	TopSep.Position = UDim2.new(0, 0, 1, -1)
	TopSep.BackgroundColor3 = Theme.Divider
	TopSep.BorderSizePixel = 0
	TopSep.Parent = TopBar
	
	-- Window controls
	local function WinControl(ico, typ)
		local btn = Instance.new("ImageButton")
		btn.Size = UDim2.new(0, 32, 0, 32)
		btn.Position = UDim2.new(1, typ == "Close" and -42 or -82, 0, 9)
		btn.BackgroundColor3 = Theme.Element
		btn.BorderSizePixel = 0
		btn.Image = ico
		btn.ImageColor3 = Theme.TextDim
		btn.Parent = TopBar
		
		Corner(btn, 6)
		Padding(btn, 8, 8, 8, 8)
		
		btn.MouseEnter:Connect(function() 
			Tween(btn, {ImageColor3 = Theme.Text, BackgroundColor3 = Theme.ElementHover})
		end)
		btn.MouseLeave:Connect(function() 
			Tween(btn, {ImageColor3 = Theme.TextDim, BackgroundColor3 = Theme.Element})
		end)
		return btn
	end
	
	local CloseBtn = WinControl(Icons.Close, "Close")
	local MinBtn = WinControl(Icons.Min, "Min")
	
	CloseBtn.MouseButton1Click:Connect(function() 
		Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
		task.wait(0.3)
		SGui:Destroy()
	end)
	
	-- Minimize system (fixed for the chads)
	local Minimized = false
	local OldSize = Main.Size
	local MinBar
	
	MinBtn.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		
		if Minimized then
			OldSize = Main.Size
			Sidebar.Visible = false
			Content.Visible = false
			Tween(Main, {Size = UDim2.new(0, 300, 0, 50)}, 0.3)
			
			MinBar = Instance.new("Frame")
			MinBar.Name = "MinBar"
			MinBar.Size = UDim2.new(1, 0, 1, 0)
			MinBar.BackgroundTransparency = 1
			MinBar.Parent = Main
			
			local MinTitle = Instance.new("TextLabel")
			MinTitle.Text = WinName
			MinTitle.Size = UDim2.new(1, -100, 1, 0)
			MinTitle.Position = UDim2.new(0, 15, 0, 0)
			MinTitle.BackgroundTransparency = 1
			MinTitle.TextColor3 = Theme.Text
			MinTitle.Font = Enum.Font.GothamBold
			MinTitle.TextSize = 14
			MinTitle.TextXAlignment = Enum.TextXAlignment.Left
			MinTitle.Parent = MinBar
			
			local MaxBtn = Instance.new("ImageButton")
			MaxBtn.Size = UDim2.new(0, 32, 0, 32)
			MaxBtn.Position = UDim2.new(1, -42, 0.5, -16)
			MaxBtn.BackgroundColor3 = Theme.Element
			MaxBtn.Image = Icons.Maximize
			MaxBtn.ImageColor3 = Theme.TextDim
			MaxBtn.Parent = MinBar
			Corner(MaxBtn, 6)
			Padding(MaxBtn, 8, 8, 8, 8)
			
			MaxBtn.MouseEnter:Connect(function()
				Tween(MaxBtn, {ImageColor3 = Theme.Text, BackgroundColor3 = Theme.ElementHover})
			end)
			MaxBtn.MouseLeave:Connect(function()
				Tween(MaxBtn, {ImageColor3 = Theme.TextDim, BackgroundColor3 = Theme.Element})
			end)
			
			MaxBtn.MouseButton1Click:Connect(function()
				Minimized = false
				if MinBar then MinBar:Destroy() end
				Tween(Main, {Size = OldSize}, 0.3)
				task.wait(0.25)
				Sidebar.Visible = true
				Content.Visible = true
			end)
			
			-- Keep draggable when minimized
			local dragging, dragStart, startPos
			MinBar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					dragStart = input.Position
					startPos = Main.Position
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end)
			
			UIS.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local delta = input.Position - dragStart
					Tween(Main, {
						Position = UDim2.new(
							startPos.X.Scale,
							startPos.X.Offset + delta.X,
							startPos.Y.Scale,
							startPos.Y.Offset + delta.Y
						)
					}, 0.05)
				end
			end)
		end
	end)

	-- Pages container
	local Pages = Instance.new("Frame")
	Pages.Name = "Pages"
	Pages.Size = UDim2.new(1, 0, 1, -50)
	Pages.Position = UDim2.new(0, 0, 0, 50)
	Pages.BackgroundTransparency = 1
	Pages.ClipsDescendants = true
	Pages.Parent = Content

	-- Dragging (chad movement)
	local dragging, dragStart, startPos
	
	local function MakeDraggable(frame)
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not Minimized then
				dragging = true
				dragStart = input.Position
				startPos = Main.Position
				
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
	end
	
	MakeDraggable(Sidebar)
	MakeDraggable(TopBar)
	
	UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
			local delta = input.Position - dragStart
			Tween(Main, {
				Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			}, 0.05)
		end
	end)
	
	-- Resizing
	local ResizeBtn = Instance.new("ImageButton")
	ResizeBtn.Size = UDim2.new(0, 20, 0, 20)
	ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
	ResizeBtn.BackgroundTransparency = 1
	ResizeBtn.Image = Icons.Logo
	ResizeBtn.ImageColor3 = Theme.TextDim
	ResizeBtn.ImageTransparency = 0.5
	ResizeBtn.Parent = Main
	
	local resizing, resizeStart, startSize
	
	ResizeBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			resizeStart = input.Position
			startSize = Main.Size
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
				end
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

	-- Tab system
	local Tabs = {}
	local FirstTab = true
	local ActiveTab = nil
	
	function Tabs:CreateTab(name, icon)
		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = name .. "Tab"
		TabBtn.Size = UDim2.new(1, -20, 0, 40)
		TabBtn.BackgroundTransparency = 1
		TabBtn.BackgroundColor3 = Theme.Element
		TabBtn.AutoButtonColor = false
		TabBtn.Text = ""
		TabBtn.Parent = TabContainer
		
		Corner(TabBtn, 6)
		
		local Ico = Instance.new("ImageLabel")
		Ico.Name = "Icon"
		Ico.Size = UDim2.new(0, 20, 0, 20)
		Ico.Position = UDim2.new(0, 12, 0.5, -10)
		Ico.BackgroundTransparency = 1
		Ico.Image = icon or Icons.User
		Ico.ImageColor3 = Theme.TextDim
		Ico.Parent = TabBtn
		
		local Lbl = Instance.new("TextLabel")
		Lbl.Name = "Label"
		Lbl.Text = name
		Lbl.Size = UDim2.new(1, -50, 1, 0)
		Lbl.Position = UDim2.new(0, 42, 0, 0)
		Lbl.BackgroundTransparency = 1
		Lbl.TextColor3 = Theme.TextDim
		Lbl.Font = Enum.Font.GothamMedium
		Lbl.TextSize = 14
		Lbl.TextXAlignment = Enum.TextXAlignment.Left
		Lbl.TextTruncate = Enum.TextTruncate.AtEnd
		Lbl.Parent = TabBtn
		
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
		Page.Parent = Pages
		
		local PageList = Instance.new("UIListLayout")
		PageList.SortOrder = Enum.SortOrder.LayoutOrder
		PageList.Padding = UDim.new(0, 8)
		PageList.Parent = Page
		
		Padding(Page, 15, 20, 20, 15)
		
		local function Activate()
			for _, tab in pairs(TabContainer:GetChildren()) do
				if tab:IsA("TextButton") and tab ~= TabBtn then
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
			Tween(TabBtn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0})
			Tween(Lbl, {TextColor3 = Theme.Text})
			Tween(Ico, {ImageColor3 = Theme.Accent})
		end
		
		TabBtn.MouseButton1Click:Connect(Activate)
		
		TabBtn.MouseEnter:Connect(function()
			if ActiveTab ~= name then
				Tween(TabBtn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.5})
			end
		end)
		
		TabBtn.MouseLeave:Connect(function()
			if ActiveTab ~= name then
				Tween(TabBtn, {BackgroundTransparency = 1})
			end
		end)
		
		if FirstTab then 
			FirstTab = false
			Activate()
		end
		
		-- Elements (the good stuff)
		local Elements = {}
		
		function Elements:CreateSection(txt)
			local sec = Instance.new("TextLabel")
			sec.Name = "Section"
			sec.Text = string.upper(txt)
			sec.Size = UDim2.new(1, 0, 0, 26)
			sec.BackgroundTransparency = 1
			sec.TextColor3 = Theme.Accent
			sec.Font = Enum.Font.GothamBold
			sec.TextSize = 11
			sec.TextXAlignment = Enum.TextXAlignment.Left
			sec.Parent = Page
			Padding(sec, 8, 0, 0, 0)
		end
		
		function Elements:CreateLabel(cfg)
			cfg = cfg or {}
			local f = Instance.new("Frame")
			f.Name = "Label"
			f.Size = UDim2.new(1, 0, 0, 32)
			f.BackgroundTransparency = 1
			f.Parent = Page
			
			local lbl = Instance.new("TextLabel")
			lbl.Text = cfg.Text or "Label"
			lbl.Size = UDim2.new(1, 0, 1, 0)
			lbl.BackgroundTransparency = 1
			lbl.TextColor3 = Theme.TextDim
			lbl.Font = Enum.Font.Gotham
			lbl.TextSize = 13
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.TextWrapped = true
			lbl.Parent = f
			Padding(lbl, 0, 5, 5, 0)
			
			return {SetText = function(_, t) lbl.Text = t end}
		end
		
		function Elements:CreateButton(cfg)
			cfg = cfg or {}
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 42)
			btn.BackgroundColor3 = Theme.Element
			btn.AutoButtonColor = false
			btn.Text = ""
			btn.Parent = Page
			Corner(btn, 6)
			Stroke(btn, Theme.Stroke, 1)
			
			local lbl = Instance.new("TextLabel")
			lbl.Text = cfg.Name or "Button"
			lbl.Size = UDim2.new(1, -60, 1, 0)
			lbl.Position = UDim2.new(0, 15, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.TextColor3 = Theme.Text
			lbl.Font = Enum.Font.GothamSemibold
			lbl.TextSize = 13
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.TextTruncate = Enum.TextTruncate.AtEnd
			lbl.Parent = btn
			
			local ico = Instance.new("ImageLabel")
			ico.Size = UDim2.new(0, 20, 0, 20)
			ico.Position = UDim2.new(1, -30, 0.5, -10)
			ico.BackgroundTransparency = 1
			ico.Image = Icons.Pointer
			ico.ImageColor3 = Theme.TextDim
			ico.Parent = btn
			
			btn.MouseEnter:Connect(function()
				Tween(btn, {BackgroundColor3 = Theme.ElementHover})
				Tween(ico, {ImageColor3 = Theme.Accent})
			end)
			btn.MouseLeave:Connect(function()
				Tween(btn, {BackgroundColor3 = Theme.Element})
				Tween(ico, {ImageColor3 = Theme.TextDim})
			end)
			btn.MouseButton1Click:Connect(function()
				Tween(btn, {BackgroundColor3 = Theme.Stroke}, 0.1)
				task.wait(0.1)
				Tween(btn, {BackgroundColor3 = Theme.Element}, 0.1)
				if cfg.Callback then task.spawn(cfg.Callback) end
			end)
		end
		
		function Elements:CreateToggle(cfg)
			cfg = cfg or {}
			local state = cfg.Default or false
			
			local tog = Instance.new("TextButton")
			tog.Size = UDim2.new(1, 0, 0, 42)
			tog.BackgroundColor3 = Theme.Element
			tog.AutoButtonColor = false
			tog.Text = ""
			tog.Parent = Page
			Corner(tog, 6)
			Stroke(tog, Theme.Stroke, 1)
			
			local lbl = Instance.new("TextLabel")
			lbl.Text = cfg.Name or "Toggle"
			lbl.Size = UDim2.new(1, -70, 1, 0)
			lbl.Position = UDim2.new(0, 15, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.TextColor3 = Theme.Text
			lbl.Font = Enum.Font.GothamSemibold
			lbl.TextSize = 13
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.TextTruncate = Enum.TextTruncate.AtEnd
			lbl.Parent = tog
			
			local sw = Instance.new("Frame")
			sw.Size = UDim2.new(0, 42, 0, 22)
			sw.Position = UDim2.new(1, -55, 0.5, -11)
			sw.BackgroundColor3 = state and Theme.Accent or Theme.Main
			sw.BorderSizePixel = 0
			sw.Parent = tog
			Corner(sw, 11)
			
			local dot = Instance.new("Frame")
			dot.Size = UDim2.new(0, 18, 0, 18)
			dot.Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
			dot.BackgroundColor3 = Theme.Text
			dot.BorderSizePixel = 0
			dot.Parent = sw
			Corner(dot, 9)
			
			tog.MouseButton1Click:Connect(function()
				state = not state
				Tween(sw, {BackgroundColor3 = state and Theme.Accent or Theme.Main}, 0.2)
				Tween(dot, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2)
				if cfg.Callback then task.spawn(cfg.Callback, state) end
			end)
			
			return {
				SetState = function(_, s)
					state = s
					Tween(sw, {BackgroundColor3 = state and Theme.Accent or Theme.Main}, 0.2)
					Tween(dot, {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2)
					if cfg.Callback then task.spawn(cfg.Callback, state) end
				end
			}
		end
		
		function Elements:CreateSlider(cfg)
			cfg = cfg or {}
			local min, max = cfg.Min or 0, cfg.Max or 100
			local val = cfg.Default or min
			
			local f = Instance.new("Frame")
			f.Size = UDim2.new(1, 0, 0, 60)
			f.BackgroundColor3 = Theme.Element
			f.Parent = Page
			Corner(f, 6)
			Stroke(f, Theme.Stroke, 1)
			
			local lbl = Instance.new("TextLabel")
			lbl.Text = cfg.Name or "Slider"
			lbl.Size = UDim2.new(1, -60, 0, 20)
			lbl.Position = UDim2.new(0, 15, 0, 10)
			lbl.BackgroundTransparency = 1
			lbl.TextColor3 = Theme.Text
			lbl.Font = Enum.Font.GothamSemibold
			lbl.TextSize = 13
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.TextTruncate = Enum.TextTruncate.AtEnd
			lbl.Parent = f
			
			local vLbl = Instance.new("TextLabel")
			vLbl.Text = tostring(val)
			vLbl.Size = UDim2.new(0, 50, 0, 20)
			vLbl.Position = UDim2.new(1, -60, 0, 10)
			vLbl.BackgroundTransparency = 1
			vLbl.TextColor3 = Theme.Accent
			vLbl.Font = Enum.Font.GothamBold
			vLbl.TextSize = 13
			vLbl.TextXAlignment = Enum.TextXAlignment.Right
			vLbl.Parent = f
			
			local bar = Instance.new("TextButton")
			bar.Text = ""
			bar.Size = UDim2.new(1, -30, 0, 6)
			bar.Position = UDim2.new(0, 15, 0, 42)
			bar.BackgroundColor3 = Theme.Main
			bar.AutoButtonColor = false
			bar.BorderSizePixel = 0
			bar.Parent = f
			Corner(bar, 3)
			
			local fill = Instance.new("Frame")
			fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
			fill.BackgroundColor3 = Theme.Accent
			fill.BorderSizePixel = 0
			fill.Parent = bar
			Corner(fill, 3)
			
			local drag = false
			
			local function upd(inp)
				local pct = math.clamp((inp.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
				Tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.1)
				local nv = math.floor(min + ((max - min) * pct))
				vLbl.Text = tostring(nv)
				if cfg.Callback then task.spawn(cfg.Callback, nv) end
			end
			
			bar.InputBegan:Connect(function(i) 
				if i.UserInputType == Enum.UserInputType.MouseButton1 then 
					drag = true 
					upd(i) 
				end 
			end)
			UIS.InputEnded:Connect(function(i) 
				if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end 
			end)
			UIS.InputChanged:Connect(function(i) 
				if drag and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i) end 
			end)
			
			return {
				SetValue = function(_, v)
					val = math.clamp(v, min, max)
					vLbl.Text = tostring(val)
					local pct = (val - min) / (max - min)
					Tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.2)
					if cfg.Callback then task.spawn(cfg.Callback, val) end
				end
			}
		end
		
		function Elements:CreateKeybind(cfg)
			cfg = cfg or {}
			local key = cfg.Default or Enum.KeyCode.F
			local listen = false
			
			local f = Instance.new("Frame")
			f.Size = UDim2.new(1, 0, 0, 42)
			f.BackgroundColor3 = Theme.Element
			f.Parent = Page
			Corner(f, 6)
			Stroke(f, Theme.Stroke, 1)
			
			local lbl = Instance.new("TextLabel")
			lbl.Text = cfg.Name or "Keybind"
			lbl.Size = UDim2.new(1, -120, 1, 0)
			lbl.Position = UDim2.new(0, 15, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.TextColor3 = Theme.Text
			lbl.Font = Enum.Font.GothamSemibold
			lbl.TextSize = 13
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.TextTruncate = Enum.TextTruncate.AtEnd
			lbl.Parent = f
			
			local kBtn = Instance.new("TextButton")
			kBtn.Text = "[" .. key.Name .. "]"
			kBtn.Size = UDim2.new(0, 100, 0, 28)
			kBtn.Position = UDim2.new(1, -110, 0.5, -14)
			kBtn.BackgroundColor3 = Theme.Main
			kBtn.TextColor3 = Theme.Accent
			kBtn.Font = Enum.Font.GothamBold
			kBtn.TextSize = 12
			kBtn.AutoButtonColor = false
			kBtn.Parent = f
			Corner(kBtn, 4)
			
			kBtn.MouseButton1Click:Connect(function()
				listen = true
				kBtn.Text = "..."
				kBtn.TextColor3 = Theme.Text
			end)
			
			UIS.InputBegan:Connect(function(i)
				if listen and i.UserInputType == Enum.UserInputType.Keyboard then
					key = i.KeyCode
					kBtn.Text = "[" .. i.KeyCode.Name .. "]"
					kBtn.TextColor3 = Theme.Accent
					listen = false
					if cfg.Callback then task.spawn(cfg.Callback, key) end
				end
			end)
			
			return {SetKey = function(_, k) key = k kBtn.Text = "[" .. k.Name .. "]" end}
		end
		
		function Elements:CreateInput(cfg)
			cfg = cfg or {}
			local txt = cfg.Default or ""
			
			local f = Instance.new("Frame")
			f.Size = UDim2.new(1, 0, 0, 42)
			f.BackgroundColor3 = Theme.Element
			f.Parent = Page
			Corner(f, 6)
			Stroke(f, Theme.Stroke, 1)
			
			local lbl = Instance.new("TextLabel")
			lbl.Text = cfg.Name or "Input"
			lbl.Size = UDim2.new(0, 100, 1, 0)
			lbl.Position = UDim2.new(0, 15, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.TextColor3 = Theme.Text
			lbl.Font = Enum.Font.GothamSemibold
			lbl.TextSize = 13
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.TextTruncate = Enum.TextTruncate.AtEnd
			lbl.Parent = f
			
			local box = Instance.new("TextBox")
			box.Text = txt
			box.PlaceholderText = cfg.Placeholder or "Enter..."
			box.Size = UDim2.new(1, -130, 0, 28)
			box.Position = UDim2.new(0, 120, 0.5, -14)
			box.BackgroundColor3 = Theme.Main
			box.TextColor3 = Theme.Text
			box.PlaceholderColor3 = Theme.TextDim
			box.Font = Enum.Font.Gotham
			box.TextSize = 12
			box.TextXAlignment = Enum.TextXAlignment.Left
			box.ClearTextOnFocus = false
			box.Parent = f
			Corner(box, 4)
			Padding(box, 0, 10, 10, 0)
			
			box.FocusLost:Connect(function(e)
				txt = box.Text
				if cfg.Callback then task.spawn(cfg.Callback, txt, e) end
			end)
			
			return {
				SetText = function(_, t) box.Text = t txt = t end,
				GetText = function() return txt end
			}
		end
		
		function Elements:CreateDropdown(cfg)
			cfg = cfg or {}
			local opts = cfg.Options or {"Option 1", "Option 2"}
			local sel = cfg.Default or opts[1]
			local open = false
			
			local f = Instance.new("Frame")
			f.Size = UDim2.new(1, 0, 0, 42)
			f.BackgroundColor3 = Theme.Element
			f.ClipsDescendants = false
			f.Parent = Page
			Corner(f, 6)
			Stroke(f, Theme.Stroke, 1)
			
			local lbl = Instance.new("TextLabel")
			lbl.Text = cfg.Name or "Dropdown"
			lbl.Size = UDim2.new(0, 120, 1, 0)
			lbl.Position = UDim2.new(0, 15, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.TextColor3 = Theme.Text
			lbl.Font = Enum.Font.GothamSemibold
			lbl.TextSize = 13
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.TextTruncate = Enum.TextTruncate.AtEnd
			lbl.Parent = f
			
			local sBtn = Instance.new("TextButton")
			sBtn.Text = sel
			sBtn.Size = UDim2.new(1, -145, 0, 28)
			sBtn.Position = UDim2.new(0, 130, 0.5, -14)
			sBtn.BackgroundColor3 = Theme.Main
			sBtn.TextColor3 = Theme.Accent
			sBtn.Font = Enum.Font.Gotham
			sBtn.TextSize = 12
			sBtn.TextXAlignment = Enum.TextXAlignment.Left
			sBtn.AutoButtonColor = false
			sBtn.Parent = f
			Corner(sBtn, 4)
			Padding(sBtn, 0, 10, 30, 0)
			
			local arr = Instance.new("ImageLabel")
			arr.Size = UDim2.new(0, 16, 0, 16)
			arr.Position = UDim2.new(1, -22, 0.5, -8)
			arr.BackgroundTransparency = 1
			arr.Image = Icons.Dropdown
			arr.ImageColor3 = Theme.TextDim
			arr.Rotation = 0
			arr.Parent = sBtn
			
			local optF = Instance.new("Frame")
			optF.Size = UDim2.new(1, -145, 0, 0)
			optF.Position = UDim2.new(0, 130, 1, 5)
			optF.BackgroundColor3 = Theme.Element
			optF.Visible = false
			optF.ClipsDescendants = true
			optF.Parent = f
			Corner(optF, 4)
			Stroke(optF, Theme.Stroke, 1)
			
			local optL = Instance.new("UIListLayout")
			optL.SortOrder = Enum.SortOrder.LayoutOrder
			optL.Padding = UDim.new(0, 2)
			optL.Parent = optF
			Padding(optF, 4, 4, 4, 4)
			
			local function makeOpt(o)
				local ob = Instance.new("TextButton")
				ob.Text = o
				ob.Size = UDim2.new(1, 0, 0, 28)
				ob.BackgroundColor3 = Theme.Main
				ob.TextColor3 = Theme.Text
				ob.Font = Enum.Font.Gotham
				ob.TextSize = 12
				ob.TextXAlignment = Enum.TextXAlignment.Left
				ob.AutoButtonColor = false
				ob.Parent = optF
				Corner(ob, 4)
				Padding(ob, 0, 8, 8, 0)
				
				ob.MouseEnter:Connect(function() Tween(ob, {BackgroundColor3 = Theme.ElementHover}) end)
				ob.MouseLeave:Connect(function() Tween(ob, {BackgroundColor3 = Theme.Main}) end)
				ob.MouseButton1Click:Connect(function()
					sel = o
					sBtn.Text = o
					open = false
					Tween(optF, {Size = UDim2.new(1, -145, 0, 0)}, 0.2)
					Tween(arr, {Rotation = 0}, 0.2)
					task.wait(0.2)
					optF.Visible = false
					if cfg.Callback then task.spawn(cfg.Callback, o) end
				end)
			end
			
			for _, o in ipairs(opts) do makeOpt(o) end
			
			sBtn.MouseButton1Click:Connect(function()
				open = not open
				if open then
					optF.Visible = true
					local h = (#opts * 30) + 8
					Tween(optF, {Size = UDim2.new(1, -145, 0, h)}, 0.2)
					Tween(arr, {Rotation = 180}, 0.2)
				else
					Tween(optF, {Size = UDim2.new(1, -145, 0, 0)}, 0.2)
					Tween(arr, {Rotation = 0}, 0.2)
					task.wait(0.2)
					optF.Visible = false
				end
			end)
			
			return {
				SetValue = function(_, v)
					if table.find(opts, v) then
						sel = v
						sBtn.Text = v
						if cfg.Callback then task.spawn(cfg.Callback, v) end
					end
				end,
				GetValue = function() return sel end,
				UpdateOptions = function(_, no)
					opts = no
					for _, c in ipairs(optF:GetChildren()) do
						if c:IsA("TextButton") then c:Destroy() end
					end
					for _, o in ipairs(opts) do makeOpt(o) end
					sel = opts[1]
					sBtn.Text = sel
				end
			}
		end
		
		return Elements
	end
	
	-- Keybind toggle
	UIS.InputBegan:Connect(function(i, p)
		if not p and i.KeyCode == Keybind then
			SGui.Enabled = not SGui.Enabled
		end
	end)

	-- Settings page (for the config chads)
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
	SettingsPage.Parent = Pages
	
	local SL = Instance.new("UIListLayout")
	SL.Padding = UDim.new(0, 8)
	SL.Parent = SettingsPage
	Padding(SettingsPage, 15, 20, 20, 15)
	
	local function SSec(t)
		local s = Instance.new("TextLabel")
		s.Text = string.upper(t)
		s.Size = UDim2.new(1, 0, 0, 26)
		s.BackgroundTransparency = 1
		s.TextColor3 = Theme.Accent
		s.Font = Enum.Font.GothamBold
		s.TextSize = 11
		s.TextXAlignment = Enum.TextXAlignment.Left
		s.Parent = SettingsPage
		Padding(s, 8, 0, 0, 0)
	end
	
	SSec("Menu Controls")
	
	-- Keybind setting
	local kbF = Instance.new("Frame")
	kbF.Size = UDim2.new(1, 0, 0, 42)
	kbF.BackgroundColor3 = Theme.Element
	kbF.Parent = SettingsPage
	Corner(kbF, 6)
	Stroke(kbF, Theme.Stroke, 1)
	
	local kbL = Instance.new("TextLabel")
	kbL.Text = "Toggle Keybind"
	kbL.Size = UDim2.new(1, -120, 1, 0)
	kbL.Position = UDim2.new(0, 15, 0, 0)
	kbL.BackgroundTransparency = 1
	kbL.TextColor3 = Theme.Text
	kbL.Font = Enum.Font.GothamSemibold
	kbL.TextSize = 13
	kbL.TextXAlignment = Enum.TextXAlignment.Left
	kbL.Parent = kbF
	
	local kbBtn = Instance.new("TextButton")
	kbBtn.Text = "[" .. Keybind.Name .. "]"
	kbBtn.Size = UDim2.new(0, 100, 0, 26)
	kbBtn.Position = UDim2.new(1, -110, 0.5, -13)
	kbBtn.BackgroundColor3 = Theme.Main
	kbBtn.TextColor3 = Theme.Accent
	kbBtn.Font = Enum.Font.GothamBold
	kbBtn.TextSize = 12
	kbBtn.AutoButtonColor = false
	kbBtn.Parent = kbF
	Corner(kbBtn, 4)
	
	local kbListen = false
	kbBtn.MouseButton1Click:Connect(function()
		kbListen = true
		kbBtn.Text = "..."
		kbBtn.TextColor3 = Theme.Text
	end)
	
	UIS.InputBegan:Connect(function(i)
		if kbListen and i.UserInputType == Enum.UserInputType.Keyboard then
			Keybind = i.KeyCode
			kbBtn.Text = "[" .. i.KeyCode.Name .. "]"
			kbBtn.TextColor3 = Theme.Accent
			kbListen = false
		end
	end)
	
	SSec("Theme System")
	
	-- Theme preset dropdown
	local presets = {}
	for k, v in pairs(ThemePresets) do table.insert(presets, v.Name) end
	
	local tPreset = Instance.new("Frame")
	tPreset.Size = UDim2.new(1, 0, 0, 42)
	tPreset.BackgroundColor3 = Theme.Element
	tPreset.ClipsDescendants = false
	tPreset.Parent = SettingsPage
	Corner(tPreset, 6)
	Stroke(tPreset, Theme.Stroke, 1)
	
	local tpL = Instance.new("TextLabel")
	tpL.Text = "Theme Preset"
	tpL.Size = UDim2.new(0, 120, 1, 0)
	tpL.Position = UDim2.new(0, 15, 0, 0)
	tpL.BackgroundTransparency = 1
	tpL.TextColor3 = Theme.Text
	tpL.Font = Enum.Font.GothamSemibold
	tpL.TextSize = 13
	tpL.TextXAlignment = Enum.TextXAlignment.Left
	tpL.Parent = tPreset
	
	local tpBtn = Instance.new("TextButton")
	tpBtn.Text = ThemePresets.Chudjak.Name
	tpBtn.Size = UDim2.new(1, -145, 0, 28)
	tpBtn.Position = UDim2.new(0, 130, 0.5, -14)
	tpBtn.BackgroundColor3 = Theme.Main
	tpBtn.TextColor3 = Theme.Accent
	tpBtn.Font = Enum.Font.Gotham
	tpBtn.TextSize = 12
	tpBtn.TextXAlignment = Enum.TextXAlignment.Left
	tpBtn.AutoButtonColor = false
	tpBtn.Parent = tPreset
	Corner(tpBtn, 4)
	Padding(tpBtn, 0, 10, 10, 0)
	
	local tpOpts = Instance.new("Frame")
	tpOpts.Size = UDim2.new(1, -145, 0, 0)
	tpOpts.Position = UDim2.new(0, 130, 1, 5)
	tpOpts.BackgroundColor3 = Theme.Element
	tpOpts.Visible = false
	tpOpts.ClipsDescendants = true
	tpOpts.Parent = tPreset
	Corner(tpOpts, 4)
	Stroke(tpOpts, Theme.Stroke, 1)
	
	local tpL2 = Instance.new("UIListLayout")
	tpL2.Padding = UDim.new(0, 2)
	tpL2.Parent = tpOpts
	Padding(tpOpts, 4, 4, 4, 4)
	
	local tpOpen = false
	
	for k, v in pairs(ThemePresets) do
		local ob = Instance.new("TextButton")
		ob.Text = v.Name
		ob.Size = UDim2.new(1, 0, 0, 28)
		ob.BackgroundColor3 = Theme.Main
		ob.TextColor3 = Theme.Text
		ob.Font = Enum.Font.Gotham
		ob.TextSize = 12
		ob.TextXAlignment = Enum.TextXAlignment.Left
		ob.AutoButtonColor = false
		ob.Parent = tpOpts
		Corner(ob, 4)
		Padding(ob, 0, 8, 8, 0)
		
		ob.MouseEnter:Connect(function() Tween(ob, {BackgroundColor3 = Theme.ElementHover}) end)
		ob.MouseLeave:Connect(function() Tween(ob, {BackgroundColor3 = Theme.Main}) end)
		ob.MouseButton1Click:Connect(function()
			ApplyTheme(v)
			tpBtn.Text = v.Name
			tpOpen = false
			Tween(tpOpts, {Size = UDim2.new(1, -145, 0, 0)}, 0.2)
			task.wait(0.2)
			tpOpts.Visible = false
		end)
	end
	
	tpBtn.MouseButton1Click:Connect(function()
		tpOpen = not tpOpen
		if tpOpen then
			tpOpts.Visible = true
			Tween(tpOpts, {Size = UDim2.new(1, -145, 0, (#presets * 30) + 8)}, 0.2)
		else
			Tween(tpOpts, {Size = UDim2.new(1, -145, 0, 0)}, 0.2)
			task.wait(0.2)
			tpOpts.Visible = false
		end
	end)
	
	-- Export/Import theme
	local expBtn = Instance.new("TextButton")
	expBtn.Size = UDim2.new(1, 0, 0, 42)
	expBtn.BackgroundColor3 = Theme.Element
	expBtn.AutoButtonColor = false
	expBtn.Text = ""
	expBtn.Parent = SettingsPage
	Corner(expBtn, 6)
	Stroke(expBtn, Theme.Stroke, 1)
	
	local expL = Instance.new("TextLabel")
	expL.Text = "Export Theme to Clipboard"
	expL.Size = UDim2.new(1, -20, 1, 0)
	expL.Position = UDim2.new(0, 15, 0, 0)
	expL.BackgroundTransparency = 1
	expL.TextColor3 = Theme.Text
	expL.Font = Enum.Font.GothamSemibold
	expL.TextSize = 13
	expL.TextXAlignment = Enum.TextXAlignment.Left
	expL.Parent = expBtn
	
	expBtn.MouseEnter:Connect(function() Tween(expBtn, {BackgroundColor3 = Theme.ElementHover}) end)
	expBtn.MouseLeave:Connect(function() Tween(expBtn, {BackgroundColor3 = Theme.Element}) end)
	expBtn.MouseButton1Click:Connect(function()
		setclipboard(ExportTheme())
		expL.Text = "✓ Exported!"
		task.wait(2)
		expL.Text = "Export Theme to Clipboard"
	end)
	
	-- Save/Load configs
	SSec("Config System")
	
	local cfgName = Instance.new("Frame")
	cfgName.Size = UDim2.new(1, 0, 0, 42)
	cfgName.BackgroundColor3 = Theme.Element
	cfgName.Parent = SettingsPage
	Corner(cfgName, 6)
	Stroke(cfgName, Theme.Stroke, 1)
	
	local cfgL = Instance.new("TextLabel")
	cfgL.Text = "Config Name"
	cfgL.Size = UDim2.new(0, 100, 1, 0)
	cfgL.Position = UDim2.new(0, 15, 0, 0)
	cfgL.BackgroundTransparency = 1
	cfgL.TextColor3 = Theme.Text
	cfgL.Font = Enum.Font.GothamSemibold
	cfgL.TextSize = 13
	cfgL.TextXAlignment = Enum.TextXAlignment.Left
	cfgL.Parent = cfgName
	
	local cfgBox = Instance.new("TextBox")
	cfgBox.Text = GameConfig and tostring(game.PlaceId) or "default"
	cfgBox.PlaceholderText = "Enter config name..."
	cfgBox.Size = UDim2.new(1, -130, 0, 28)
	cfgBox.Position = UDim2.new(0, 120, 0.5, -14)
	cfgBox.BackgroundColor3 = Theme.Main
	cfgBox.TextColor3 = Theme.Text
	cfgBox.PlaceholderColor3 = Theme.TextDim
	cfgBox.Font = Enum.Font.Gotham
	cfgBox.TextSize = 12
	cfgBox.TextXAlignment = Enum.TextXAlignment.Left
	cfgBox.ClearTextOnFocus = false
	cfgBox.Parent = cfgName
	Corner(cfgBox, 4)
	Padding(cfgBox, 0, 10, 10, 0)
	
	local saveBtn = Instance.new("TextButton")
	saveBtn.Size = UDim2.new(1, 0, 0, 42)
	saveBtn.BackgroundColor3 = Theme.Element
	saveBtn.AutoButtonColor = false
	saveBtn.Text = ""
	saveBtn.Parent = SettingsPage
	Corner(saveBtn, 6)
	Stroke(saveBtn, Theme.Stroke, 1)
	
	local saveL = Instance.new("TextLabel")
	saveL.Text = "Save Config"
	saveL.Size = UDim2.new(1, -20, 1, 0)
	saveL.Position = UDim2.new(0, 15, 0, 0)
	saveL.BackgroundTransparency = 1
	saveL.TextColor3 = Theme.Text
	saveL.Font = Enum.Font.GothamSemibold
	saveL.TextSize = 13
	saveL.TextXAlignment = Enum.TextXAlignment.Left
	saveL.Parent = saveBtn
	
	saveBtn.MouseEnter:Connect(function() Tween(saveBtn, {BackgroundColor3 = Theme.ElementHover}) end)
	saveBtn.MouseLeave:Connect(function() Tween(saveBtn, {BackgroundColor3 = Theme.Element}) end)
	saveBtn.MouseButton1Click:Connect(function()
		SaveConfig(cfgBox.Text, {theme = Theme, settings = {}})
		saveL.Text = "✓ Saved!"
		task.wait(2)
		saveL.Text = "Save Config"
	end)
	
	local loadBtn = Instance.new("TextButton")
	loadBtn.Size = UDim2.new(1, 0, 0, 42)
	loadBtn.BackgroundColor3 = Theme.Element
	loadBtn.AutoButtonColor = false
	loadBtn.Text = ""
	loadBtn.Parent = SettingsPage
	Corner(loadBtn, 6)
	Stroke(loadBtn, Theme.Stroke, 1)
	
	local loadL = Instance.new("TextLabel")
	loadL.Text = "Load Config"
	loadL.Size = UDim2.new(1, -20, 1, 0)
	loadL.Position = UDim2.new(0, 15, 0, 0)
	loadL.BackgroundTransparency = 1
	loadL.TextColor3 = Theme.Text
	loadL.Font = Enum.Font.GothamSemibold
	loadL.TextSize = 13
	loadL.TextXAlignment = Enum.TextXAlignment.Left
	loadL.Parent = loadBtn
	
	loadBtn.MouseEnter:Connect(function() Tween(loadBtn, {BackgroundColor3 = Theme.ElementHover}) end)
	loadBtn.MouseLeave:Connect(function() Tween(loadBtn, {BackgroundColor3 = Theme.Element}) end)
	loadBtn.MouseButton1Click:Connect(function()
		local data = LoadConfig(cfgBox.Text)
		if data and data.theme then
			ApplyTheme(data.theme)
			loadL.Text = "✓ Loaded!"
			task.wait(2)
			loadL.Text = "Load Config"
		else
			loadL.Text = "✗ Not found!"
			task.wait(2)
			loadL.Text = "Load Config"
		end
	end)
	
	SSec("Library")
	
	local unloadBtn = Instance.new("TextButton")
	unloadBtn.Size = UDim2.new(1, 0, 0, 42)
	unloadBtn.BackgroundColor3 = Theme.Element
	unloadBtn.AutoButtonColor = false
	unloadBtn.Text = ""
	unloadBtn.Parent = SettingsPage
	Corner(unloadBtn, 6)
	Stroke(unloadBtn, Theme.Stroke, 1)
	
	local unloadL = Instance.new("TextLabel")
	unloadL.Text = "Unload Chuddy Hub"
	unloadL.Size = UDim2.new(1, -20, 1, 0)
	unloadL.Position = UDim2.new(0, 15, 0, 0)
	unloadL.BackgroundTransparency = 1
	unloadL.TextColor3 = Color3.fromRGB(237, 66, 69)
	unloadL.Font = Enum.Font.GothamSemibold
	unloadL.TextSize = 13
	unloadL.TextXAlignment = Enum.TextXAlignment.Left
	unloadL.Parent = unloadBtn
	
	unloadBtn.MouseEnter:Connect(function() Tween(unloadBtn, {BackgroundColor3 = Theme.ElementHover}) end)
	unloadBtn.MouseLeave:Connect(function() Tween(unloadBtn, {BackgroundColor3 = Theme.Element}) end)
	unloadBtn.MouseButton1Click:Connect(function()
		for _, conn in pairs(ActiveHumanoidMods) do
			if conn then conn:Disconnect() end
		end
		Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
		task.wait(0.3)
		SGui:Destroy()
	end)
	
	-- Settings button
	local SettingsBtn = Instance.new("TextButton")
	SettingsBtn.Name = "SettingsBtn"
	SettingsBtn.Size = UDim2.new(1, -20, 1, -5)
	SettingsBtn.Position = UDim2.new(0, 10, 0, 0)
	SettingsBtn.BackgroundTransparency = 1
	SettingsBtn.BackgroundColor3 = Theme.Element
	SettingsBtn.AutoButtonColor = false
	SettingsBtn.Text = ""
	SettingsBtn.Parent = SettingsArea
	Corner(SettingsBtn, 6)
	
	local sIco = Instance.new("ImageLabel")
	sIco.Name = "Icon"
	sIco.Size = UDim2.new(0, 18, 0, 18)
	sIco.Position = UDim2.new(0, 12, 0.5, -9)
	sIco.BackgroundTransparency = 1
	sIco.Image = Icons.Settings
	sIco.ImageColor3 = Theme.TextDim
	sIco.Parent = SettingsBtn
	
	local sLbl = Instance.new("TextLabel")
	sLbl.Name = "Label"
	sLbl.Text = "Settings"
	sLbl.Size = UDim2.new(1, -50, 1, 0)
	sLbl.Position = UDim2.new(0, 42, 0, 0)
	sLbl.BackgroundTransparency = 1
	sLbl.TextColor3 = Theme.TextDim
	sLbl.Font = Enum.Font.GothamMedium
	sLbl.TextSize = 14
	sLbl.TextXAlignment = Enum.TextXAlignment.Left
	sLbl.Parent = SettingsBtn
	
	SettingsBtn.MouseEnter:Connect(function()
		if ActiveTab ~= "Settings" then
			Tween(SettingsBtn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.5})
		end
	end)
	SettingsBtn.MouseLeave:Connect(function()
		if ActiveTab ~= "Settings" then
			Tween(SettingsBtn, {BackgroundTransparency = 1})
		end
	end)
	SettingsBtn.MouseButton1Click:Connect(function()
		for _, tab in pairs(TabContainer:GetChildren()) do
			if tab:IsA("TextButton") then
				Tween(tab, {BackgroundTransparency = 1})
				if tab:FindFirstChild("Label") then Tween(tab.Label, {TextColor3 = Theme.TextDim}) end
				if tab:FindFirstChild("Icon") then Tween(tab.Icon, {ImageColor3 = Theme.TextDim}) end
			end
		end
		for _, page in pairs(Pages:GetChildren()) do
			if page:IsA("ScrollingFrame") then page.Visible = false end
		end
		SettingsPage.Visible = true
		ActiveTab = "Settings"
		Tween(SettingsBtn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0})
		Tween(sLbl, {TextColor3 = Theme.Text})
		Tween(sIco, {ImageColor3 = Theme.Accent})
	end)
	
	-- Auto-create Player tab if enabled
	if cfg.PlayerTab ~= false then
		local Player = Tabs:CreateTab("Player", "rbxassetid://10723407389")
		
		Player:CreateSection("Movement")
		
		local wsT = Player:CreateToggle({
			Name = "Custom WalkSpeed",
			Default = false,
			Callback = function(s)
				if s then EnablePlayerMod("WalkSpeed") else DisablePlayerMod("WalkSpeed") end
			end
		})
		
		Player:CreateSlider({
			Name = "WalkSpeed",
			Min = 16,
			Max = 500,
			Default = 16,
			Callback = function(v)
				PlayerMods.WalkSpeed.current = v
				if PlayerMods.WalkSpeed.enabled then
					ApplyPlayerMod("WalkSpeed", v)
				end
			end
		})
		
		local jpT = Player:CreateToggle({
			Name = "Custom JumpPower",
			Default = false,
			Callback = function(s)
				if s then EnablePlayerMod("JumpPower") else DisablePlayerMod("JumpPower") end
			end
		})
		
		Player:CreateSlider({
			Name = "JumpPower",
			Min = 50,
			Max = 500,
			Default = 50,
			Callback = function(v)
				PlayerMods.JumpPower.current = v
				if PlayerMods.JumpPower.enabled then
					ApplyPlayerMod("JumpPower", v)
				end
			end
		})
		
		Player:CreateSection("World")
		
		local gravT = Player:CreateToggle({
			Name = "Custom Gravity",
			Default = false,
			Callback = function(s)
				if s then EnablePlayerMod("Gravity") else DisablePlayerMod("Gravity") end
			end
		})
		
		Player:CreateSlider({
			Name = "Gravity",
			Min = 0,
			Max = 196.2,
			Default = 196.2,
			Callback = function(v)
				PlayerMods.Gravity.current = v
				if PlayerMods.Gravity.enabled then
					ApplyPlayerMod("Gravity", v)
				end
			end
		})
		
		Player:CreateSection("Character")
		
		Player:CreateButton({
			Name = "Reset Character",
			Callback = function()
				if LP.Character then
					LP.Character:BreakJoints()
				end
			end
		})
		
		Player:CreateButton({
			Name = "God Mode (Method 1)",
			Callback = function()
				if LP.Character then
					local hum = LP.Character:FindFirstChildOfClass("Humanoid")
					if hum then hum.Name = "1" end
					local hum2 = Instance.new("Humanoid", LP.Character)
					hum2.Name = "Humanoid"
					task.wait(0.1)
					if LP.Character:FindFirstChild("1") then
						LP.Character["1"]:Destroy()
					end
					workspace.CurrentCamera.CameraSubject = LP.Character.Humanoid
					LP.Character.Animate.Disabled = true
					task.wait()
					LP.Character.Animate.Disabled = false
				end
			end
		})
		
		Player:CreateSection("Teleportation")
		
		local tpMethod = "CFrame"
		Player:CreateDropdown({
			Name = "TP Method",
			Options = {"CFrame", "Position", "Velocity", "Tween"},
			Default = "CFrame",
			Callback = function(v)
				tpMethod = v
			end
		})
		
		Player:CreateInput({
			Name = "TP to Player",
			Placeholder = "Username...",
			Callback = function(t, e)
				if e and t ~= "" then
					for _, p in ipairs(Players:GetPlayers()) do
						if p.Name:lower():find(t:lower()) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
							TeleportTo(p.Character.HumanoidRootPart.Position, tpMethod)
							break
						end
					end
				end
			end
		})
	end
	
	return Tabs
end

return Chuddy
