--[[ 
    CHUDDY HUB | PRODUCTION RELEASE v2.0
    ✓ Fixed Sidebar Layout Calculations
    ✓ Added Missing CreateKeybind & CreateInput
    ✓ Improved Text Scaling & Truncation
    ✓ Better ScrollBar Visibility
    ✓ ZIndex Management
    ✓ Enhanced Animations
    ✓ Production-Ready Code
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local ChuddyLib = {}

--// Theme Configuration
local Theme = {
	Main = Color3.fromRGB(18, 18, 20),
	Sidebar = Color3.fromRGB(24, 24, 26),
	Content = Color3.fromRGB(18, 18, 20),
	Element = Color3.fromRGB(30, 30, 33),
	ElementHover = Color3.fromRGB(38, 38, 41),
	Header = Color3.fromRGB(28, 28, 30),
	Text = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(140, 140, 140),
	Accent = Color3.fromRGB(114, 137, 218), -- Blurple
	AccentDark = Color3.fromRGB(88, 101, 242),
	Stroke = Color3.fromRGB(45, 45, 48),
	Divider = Color3.fromRGB(35, 35, 38),
	Success = Color3.fromRGB(67, 181, 129),
	Warning = Color3.fromRGB(250, 166, 26),
	Error = Color3.fromRGB(237, 66, 69)
}

--// Icons (Using Standard Roblox Assets for Reliability)
local Icons = {
	Logo = "rbxassetid://134140528282189",
	Settings = "rbxassetid://10723415903",
	User = "rbxassetid://10723415903",
	Close = "rbxassetid://3926305904",
	Min = "rbxassetid://3926307971",
	Resize = "rbxassetid://134140528282189",
	Pointer = "rbxassetid://10709791437",
	Search = "rbxassetid://10723407389",
	Checkmark = "rbxassetid://10709818928"
}

--// Utility Functions
local function GetCustomIcon(Url)
	local success, response = pcall(function()
		local file_name = "chuddy_ico.png"
		if not isfile(file_name) then 
			writefile(file_name, game:HttpGet(Url)) 
		end
		return getcustomasset(file_name)
	end)
	return success and response or Icons.Logo
end

local function Tween(obj, props, time)
	if not obj or not obj.Parent then return end
	TweenService:Create(
		obj, 
		TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
		props
	):Play()
end

local function GetParent()
	local s, r = pcall(function() return gethui() end)
	if s and r then return r end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local function CreateUICorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = parent
	return corner
end

local function CreateUIStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Theme.Stroke
	stroke.Thickness = thickness or 1
	stroke.Parent = parent
	return stroke
end

local function CreateUIPadding(parent, top, left, right, bottom)
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, top or 0)
	padding.PaddingLeft = UDim.new(0, left or 0)
	padding.PaddingRight = UDim.new(0, right or 0)
	padding.PaddingBottom = UDim.new(0, bottom or 0)
	padding.Parent = parent
	return padding
end

--// Main Window Creation
function ChuddyLib:CreateWindow(Settings)
	Settings = Settings or {}
	local WindowName = Settings.Name or "Chuddy Hub"
	local CurrentKeybind = Settings.Keybind or Enum.KeyCode.RightControl
	local CustomIconUrl = Settings.IconUrl or "https://raw.githubusercontent.com/foekey/ChuddyUILib/main/chud.png"
	
	-- 1. ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ChuddyUI_" .. HttpService:GenerateGUID(false)
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = GetParent()
	
	-- 2. Main Frame
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 750, 0, 550)
	Main.Position = UDim2.new(0.5, -375, 0.5, -275)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui
	
	CreateUICorner(Main, 8)
	CreateUIStroke(Main, Theme.Stroke, 1)

	-- 3. Sidebar (Left Panel)
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

	-- 3a. Header Section (Fixed Height: 60px)
	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 60)
	Header.BackgroundTransparency = 1
	Header.Parent = Sidebar
	
	local Logo = Instance.new("ImageLabel")
	Logo.Size = UDim2.new(0, 30, 0, 30)
	Logo.Position = UDim2.new(0, 15, 0.5, -15)
	Logo.BackgroundTransparency = 1
	Logo.Image = GetCustomIcon(CustomIconUrl)
	Logo.Parent = Header
	CreateUICorner(Logo, 5)
	
	local Title = Instance.new("TextLabel")
	Title.Text = WindowName
	Title.Size = UDim2.new(1, -60, 1, 0)
	Title.Position = UDim2.new(0, 55, 0, 0)
	Title.BackgroundTransparency = 1
	Title.TextColor3 = Theme.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 15
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextTruncate = Enum.TextTruncate.AtEnd
	Title.Parent = Header

	-- 3b. User Profile (Fixed at Bottom: 65px)
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
	CreateUICorner(Avatar, 18) -- Circular
	
	task.spawn(function()
		local success, thumbUrl = pcall(function()
			return Players:GetUserThumbnailAsync(
				LocalPlayer.UserId, 
				Enum.ThumbnailType.HeadShot, 
				Enum.ThumbnailSize.Size48x48
			)
		end)
		if success then Avatar.Image = thumbUrl end
	end)
	
	local Username = Instance.new("TextLabel")
	Username.Text = LocalPlayer.Name
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
	Rank.Text = "Premium"
	Rank.Size = UDim2.new(1, -60, 0, 15)
	Rank.Position = UDim2.new(0, 58, 0.5, 4)
	Rank.BackgroundTransparency = 1
	Rank.TextColor3 = Theme.Accent
	Rank.Font = Enum.Font.Gotham
	Rank.TextSize = 11
	Rank.TextXAlignment = Enum.TextXAlignment.Left
	Rank.Parent = UserProfile

	-- 3c. Settings Button (Fixed Above Profile: 50px)
	local SettingsArea = Instance.new("Frame")
	SettingsArea.Name = "SettingsArea"
	SettingsArea.Size = UDim2.new(1, 0, 0, 50)
	SettingsArea.Position = UDim2.new(0, 0, 1, -115) -- 65 (profile) + 50 (self) = 115
	SettingsArea.BackgroundTransparency = 1
	SettingsArea.Parent = Sidebar

	-- 3d. Tab Container (Fills Remaining Space)
	-- Space = Total Height - Header(60) - Settings(50) - Profile(65) = Height - 175
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
	
	CreateUIPadding(TabContainer, 5, 10, 10, 5)

	-- 4. Content Area (Right Panel)
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Size = UDim2.new(1, -210, 1, 0)
	Content.Position = UDim2.new(0, 210, 0, 0)
	Content.BackgroundTransparency = 1
	Content.ClipsDescendants = true
	Content.Parent = Main
	
	-- 4a. Top Bar
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
	
	-- Window Controls (Close & Minimize)
	local function CreateWinControl(Icon, Type)
		local Btn = Instance.new("ImageButton")
		Btn.Size = UDim2.new(0, 32, 0, 32)
		Btn.Position = UDim2.new(1, Type == "Close" and -42 or -82, 0, 9)
		Btn.BackgroundColor3 = Theme.Element
		Btn.BorderSizePixel = 0
		Btn.Image = Icon
		Btn.ImageColor3 = Theme.TextDim
		Btn.Parent = TopBar
		
		CreateUICorner(Btn, 6)
		CreateUIPadding(Btn, 8, 8, 8, 8)
		
		Btn.MouseEnter:Connect(function() 
			Tween(Btn, {ImageColor3 = Theme.Text, BackgroundColor3 = Theme.ElementHover})
		end)
		Btn.MouseLeave:Connect(function() 
			Tween(Btn, {ImageColor3 = Theme.TextDim, BackgroundColor3 = Theme.Element})
		end)
		return Btn
	end
	
	local CloseBtn = CreateWinControl(Icons.Close, "Close")
	local MinBtn = CreateWinControl(Icons.Min, "Min")
	
	CloseBtn.MouseButton1Click:Connect(function() 
		Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
		task.wait(0.3)
		ScreenGui:Destroy() 
	end)
	
	-- Minimize Logic
	local Minimized = false
	local OldSize = Main.Size
	MinBtn.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		if Minimized then
			OldSize = Main.Size
			Tween(Main, {Size = UDim2.new(0, OldSize.X.Offset, 0, 50)}, 0.3)
			Sidebar.Visible = false
			Content.Visible = false
			
			local MT = Instance.new("TextLabel")
			MT.Name = "MiniTitle"
			MT.Text = WindowName
			MT.Size = UDim2.new(1, -100, 1, 0)
			MT.Position = UDim2.new(0, 20, 0, 0)
			MT.BackgroundTransparency = 1
			MT.TextColor3 = Theme.Text
			MT.Font = Enum.Font.GothamBold
			MT.TextSize = 14
			MT.TextXAlignment = Enum.TextXAlignment.Left
			MT.Parent = Main
		else
			if Main:FindFirstChild("MiniTitle") then 
				Main.MiniTitle:Destroy() 
			end
			Tween(Main, {Size = OldSize}, 0.3)
			task.wait(0.2)
			Sidebar.Visible = true
			Content.Visible = true
		end
	end)

	-- 4b. Pages Container
	local Pages = Instance.new("Frame")
	Pages.Name = "Pages"
	Pages.Size = UDim2.new(1, 0, 1, -50)
	Pages.Position = UDim2.new(0, 0, 0, 50)
	Pages.BackgroundTransparency = 1
	Pages.ClipsDescendants = true
	Pages.Parent = Content

	-- Dragging System
	local Dragging, DragStart, StartPos = false, nil, nil
	
	local function MakeDraggable(frame)
		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = true
				DragStart = input.Position
				StartPos = Main.Position
				
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
	end
	
	MakeDraggable(Sidebar)
	MakeDraggable(TopBar)
	
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
			local delta = input.Position - DragStart
			Tween(Main, {
				Position = UDim2.new(
					StartPos.X.Scale, 
					StartPos.X.Offset + delta.X, 
					StartPos.Y.Scale, 
					StartPos.Y.Offset + delta.Y
				)
			}, 0.05)
		end
	end)
	
	-- Resizing System
	local ResizeBtn = Instance.new("ImageButton")
	ResizeBtn.Size = UDim2.new(0, 20, 0, 20)
	ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
	ResizeBtn.BackgroundTransparency = 1
	ResizeBtn.Image = Icons.Resize
	ResizeBtn.ImageColor3 = Theme.TextDim
	ResizeBtn.ImageTransparency = 0.5
	ResizeBtn.Parent = Main
	
	local Resizing, ResizeStart, StartSize = false, nil, nil
	
	ResizeBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Resizing = true
			ResizeStart = input.Position
			StartSize = Main.Size
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Resizing = false
				end
			end)
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if Resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - ResizeStart
			local newWidth = math.clamp(StartSize.X.Offset + delta.X, 600, 1400)
			local newHeight = math.clamp(StartSize.Y.Offset + delta.Y, 400, 900)
			
			Tween(Main, {Size = UDim2.new(0, newWidth, 0, newHeight)}, 0.05)
		end
	end)

	--// Tab System
	local Tabs = {}
	local FirstTab = true
	local ActiveTab = nil
	
	function Tabs:CreateTab(Name, Icon)
		-- Sidebar Tab Button
		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = Name .. "Tab"
		TabBtn.Size = UDim2.new(1, -20, 0, 40)
		TabBtn.BackgroundTransparency = 1
		TabBtn.BackgroundColor3 = Theme.Element
		TabBtn.AutoButtonColor = false
		TabBtn.Text = ""
		TabBtn.Parent = TabContainer
		
		CreateUICorner(TabBtn, 6)
		
		local Ico = Instance.new("ImageLabel")
		Ico.Name = "Icon"
		Ico.Size = UDim2.new(0, 20, 0, 20)
		Ico.Position = UDim2.new(0, 12, 0.5, -10)
		Ico.BackgroundTransparency = 1
		Ico.Image = Icon or Icons.User
		Ico.ImageColor3 = Theme.TextDim
		Ico.Parent = TabBtn
		
		local Lbl = Instance.new("TextLabel")
		Lbl.Name = "Label"
		Lbl.Text = Name
		Lbl.Size = UDim2.new(1, -50, 1, 0)
		Lbl.Position = UDim2.new(0, 42, 0, 0)
		Lbl.BackgroundTransparency = 1
		Lbl.TextColor3 = Theme.TextDim
		Lbl.Font = Enum.Font.GothamMedium
		Lbl.TextSize = 14
		Lbl.TextXAlignment = Enum.TextXAlignment.Left
		Lbl.TextTruncate = Enum.TextTruncate.AtEnd
		Lbl.Parent = TabBtn
		
		-- Page Container
		local Page = Instance.new("ScrollingFrame")
		Page.Name = Name .. "Page"
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
		
		CreateUIPadding(Page, 15, 20, 20, 15)
		
		-- Activation Logic
		local function Activate()
			-- Deactivate all tabs
			for _, tab in pairs(TabContainer:GetChildren()) do
				if tab:IsA("TextButton") and tab ~= TabBtn then
					Tween(tab, {BackgroundTransparency = 1})
					if tab:FindFirstChild("Label") then
						Tween(tab.Label, {TextColor3 = Theme.TextDim})
					end
					if tab:FindFirstChild("Icon") then
						Tween(tab.Icon, {ImageColor3 = Theme.TextDim})
					end
				end
			end
			
			-- Deactivate Settings if active
			local SettingsBtn = SettingsArea:FindFirstChild("SettingsBtn")
			if SettingsBtn then
				Tween(SettingsBtn, {BackgroundTransparency = 1})
				if SettingsBtn:FindFirstChild("Label") then
					Tween(SettingsBtn.Label, {TextColor3 = Theme.TextDim})
				end
				if SettingsBtn:FindFirstChild("Icon") then
					Tween(SettingsBtn.Icon, {ImageColor3 = Theme.TextDim})
				end
			end
			
			-- Hide all pages
			for _, page in pairs(Pages:GetChildren()) do
				if page:IsA("ScrollingFrame") then
					page.Visible = false
				end
			end
			
			-- Activate this tab
			Page.Visible = true
			ActiveTab = Name
			Tween(TabBtn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0})
			Tween(Lbl, {TextColor3 = Theme.Text})
			Tween(Ico, {ImageColor3 = Theme.Accent})
		end
		
		TabBtn.MouseButton1Click:Connect(Activate)
		
		-- Hover Effects
		TabBtn.MouseEnter:Connect(function()
			if ActiveTab ~= Name then
				Tween(TabBtn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0.5})
			end
		end)
		
		TabBtn.MouseLeave:Connect(function()
			if ActiveTab ~= Name then
				Tween(TabBtn, {BackgroundTransparency = 1})
			end
		end)
		
		if FirstTab then 
			FirstTab = false
			Activate()
		end
		
		--// Element Creation Functions
		local Elements = {}
		
		function Elements:CreateSection(Name)
			local Section = Instance.new("TextLabel")
			Section.Name = "Section"
			Section.Text = string.upper(Name)
			Section.Size = UDim2.new(1, 0, 0, 26)
			Section.BackgroundTransparency = 1
			Section.TextColor3 = Theme.Accent
			Section.Font = Enum.Font.GothamBold
			Section.TextSize = 11
			Section.TextXAlignment = Enum.TextXAlignment.Left
			Section.Parent = Page
			
			CreateUIPadding(Section, 8, 0, 0, 0)
			
			return Section
		end
		
		function Elements:CreateLabel(Config)
			Config = Config or {}
			local LabelFrame = Instance.new("Frame")
			LabelFrame.Name = "Label"
			LabelFrame.Size = UDim2.new(1, 0, 0, 32)
			LabelFrame.BackgroundTransparency = 1
			LabelFrame.Parent = Page
			
			local Label = Instance.new("TextLabel")
			Label.Text = Config.Text or "Label"
			Label.Size = UDim2.new(1, 0, 1, 0)
			Label.BackgroundTransparency = 1
			Label.TextColor3 = Theme.TextDim
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.TextWrapped = true
			Label.Parent = LabelFrame
			
			CreateUIPadding(Label, 0, 5, 5, 0)
			
			return {
				SetText = function(self, text)
					Label.Text = text
				end
			}
		end
		
		function Elements:CreateButton(Config)
			Config = Config or {}
			local Btn = Instance.new("TextButton")
			Btn.Name = "Button"
			Btn.Size = UDim2.new(1, 0, 0, 42)
			Btn.BackgroundColor3 = Theme.Element
			Btn.AutoButtonColor = false
			Btn.Text = ""
			Btn.Parent = Page
			
			CreateUICorner(Btn, 6)
			CreateUIStroke(Btn, Theme.Stroke, 1)
			
			local Label = Instance.new("TextLabel")
			Label.Text = Config.Name or "Button"
			Label.Size = UDim2.new(1, -60, 1, 0)
			Label.Position = UDim2.new(0, 15, 0, 0)
			Label.BackgroundTransparency = 1
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.TextTruncate = Enum.TextTruncate.AtEnd
			Label.Parent = Btn
			
			local Ico = Instance.new("ImageLabel")
			Ico.Size = UDim2.new(0, 20, 0, 20)
			Ico.Position = UDim2.new(1, -30, 0.5, -10)
			Ico.BackgroundTransparency = 1
			Ico.Image = Icons.Pointer
			Ico.ImageColor3 = Theme.TextDim
			Ico.Parent = Btn
			
			Btn.MouseEnter:Connect(function()
				Tween(Btn, {BackgroundColor3 = Theme.ElementHover})
				Tween(Ico, {ImageColor3 = Theme.Accent})
			end)
			
			Btn.MouseLeave:Connect(function()
				Tween(Btn, {BackgroundColor3 = Theme.Element})
				Tween(Ico, {ImageColor3 = Theme.TextDim})
			end)
			
			Btn.MouseButton1Click:Connect(function()
				Tween(Btn, {BackgroundColor3 = Theme.Stroke}, 0.1)
				task.wait(0.1)
				Tween(Btn, {BackgroundColor3 = Theme.Element}, 0.1)
				
				if Config.Callback then
					task.spawn(Config.Callback)
				end
			end)
			
			return Btn
		end
		
		function Elements:CreateToggle(Config)
			Config = Config or {}
			local State = Config.Default or false
			
			local Toggle = Instance.new("TextButton")
			Toggle.Name = "Toggle"
			Toggle.Size = UDim2.new(1, 0, 0, 42)
			Toggle.BackgroundColor3 = Theme.Element
			Toggle.AutoButtonColor = false
			Toggle.Text = ""
			Toggle.Parent = Page
			
			CreateUICorner(Toggle, 6)
			CreateUIStroke(Toggle, Theme.Stroke, 1)
			
			local Label = Instance.new("TextLabel")
			Label.Text = Config.Name or "Toggle"
			Label.Size = UDim2.new(1, -70, 1, 0)
			Label.Position = UDim2.new(0, 15, 0, 0)
			Label.BackgroundTransparency = 1
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.TextTruncate = Enum.TextTruncate.AtEnd
			Label.Parent = Toggle
			
			local Switch = Instance.new("Frame")
			Switch.Name = "Switch"
			Switch.Size = UDim2.new(0, 42, 0, 22)
			Switch.Position = UDim2.new(1, -55, 0.5, -11)
			Switch.BackgroundColor3 = State and Theme.Accent or Theme.Main
			Switch.BorderSizePixel = 0
			Switch.Parent = Toggle
			
			CreateUICorner(Switch, 11)
			
			local Dot = Instance.new("Frame")
			Dot.Name = "Dot"
			Dot.Size = UDim2.new(0, 18, 0, 18)
			Dot.Position = State and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
			Dot.BackgroundColor3 = Theme.Text
			Dot.BorderSizePixel = 0
			Dot.Parent = Switch
			
			CreateUICorner(Dot, 9)
			
			Toggle.MouseButton1Click:Connect(function()
				State = not State
				
				Tween(Switch, {BackgroundColor3 = State and Theme.Accent or Theme.Main}, 0.2)
				Tween(Dot, {
					Position = State and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
				}, 0.2)
				
				if Config.Callback then
					task.spawn(Config.Callback, State)
				end
			end)
			
			return {
				SetState = function(self, state)
					State = state
					Tween(Switch, {BackgroundColor3 = State and Theme.Accent or Theme.Main}, 0.2)
					Tween(Dot, {
						Position = State and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
					}, 0.2)
					
					if Config.Callback then
						task.spawn(Config.Callback, State)
					end
				end
			}
		end
		
		function Elements:CreateSlider(Config)
			Config = Config or {}
			local Min = Config.Min or 0
			local Max = Config.Max or 100
			local Default = Config.Default or Min
			local CurrentValue = Default
			
			local SliderFrame = Instance.new("Frame")
			SliderFrame.Name = "Slider"
			SliderFrame.Size = UDim2.new(1, 0, 0, 60)
			SliderFrame.BackgroundColor3 = Theme.Element
			SliderFrame.Parent = Page
			
			CreateUICorner(SliderFrame, 6)
			CreateUIStroke(SliderFrame, Theme.Stroke, 1)
			
			local Label = Instance.new("TextLabel")
			Label.Text = Config.Name or "Slider"
			Label.Size = UDim2.new(1, -60, 0, 20)
			Label.Position = UDim2.new(0, 15, 0, 10)
			Label.BackgroundTransparency = 1
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.TextTruncate = Enum.TextTruncate.AtEnd
			Label.Parent = SliderFrame
			
			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Text = tostring(CurrentValue)
			ValueLabel.Size = UDim2.new(0, 50, 0, 20)
			ValueLabel.Position = UDim2.new(1, -60, 0, 10)
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.TextColor3 = Theme.Accent
			ValueLabel.Font = Enum.Font.GothamBold
			ValueLabel.TextSize = 13
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValueLabel.Parent = SliderFrame
			
			local Bar = Instance.new("TextButton")
			Bar.Name = "Bar"
			Bar.Text = ""
			Bar.Size = UDim2.new(1, -30, 0, 6)
			Bar.Position = UDim2.new(0, 15, 0, 42)
			Bar.BackgroundColor3 = Theme.Main
			Bar.AutoButtonColor = false
			Bar.BorderSizePixel = 0
			Bar.Parent = SliderFrame
			
			CreateUICorner(Bar, 3)
			
			local Fill = Instance.new("Frame")
			Fill.Name = "Fill"
			Fill.Size = UDim2.new((CurrentValue - Min) / (Max - Min), 0, 1, 0)
			Fill.BackgroundColor3 = Theme.Accent
			Fill.BorderSizePixel = 0
			Fill.Parent = Bar
			
			CreateUICorner(Fill, 3)
			
			local Dragging = false
			
			local function UpdateSlider(input)
				local percentage = math.clamp(
					(input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X,
					0,
					1
				)
				
				Tween(Fill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.1)
				
				local newValue = math.floor(Min + ((Max - Min) * percentage))
				CurrentValue = newValue
				ValueLabel.Text = tostring(newValue)
				
				if Config.Callback then
					task.spawn(Config.Callback, newValue)
				end
			end
			
			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = true
					UpdateSlider(input)
				end
			end)
			
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = false
				end
			end)
			
			UserInputService.InputChanged:Connect(function(input)
				if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					UpdateSlider(input)
				end
			end)
			
			return {
				SetValue = function(self, value)
					CurrentValue = math.clamp(value, Min, Max)
					ValueLabel.Text = tostring(CurrentValue)
					local percentage = (CurrentValue - Min) / (Max - Min)
					Tween(Fill, {Size = UDim2.new(percentage, 0, 1, 0)}, 0.2)
					
					if Config.Callback then
						task.spawn(Config.Callback, CurrentValue)
					end
				end
			}
		end
		
		function Elements:CreateKeybind(Config)
			Config = Config or {}
			local CurrentKey = Config.Default or Enum.KeyCode.F
			local Listening = false
			
			local KeybindFrame = Instance.new("Frame")
			KeybindFrame.Name = "Keybind"
			KeybindFrame.Size = UDim2.new(1, 0, 0, 42)
			KeybindFrame.BackgroundColor3 = Theme.Element
			KeybindFrame.Parent = Page
			
			CreateUICorner(KeybindFrame, 6)
			CreateUIStroke(KeybindFrame, Theme.Stroke, 1)
			
			local Label = Instance.new("TextLabel")
			Label.Text = Config.Name or "Keybind"
			Label.Size = UDim2.new(1, -120, 1, 0)
			Label.Position = UDim2.new(0, 15, 0, 0)
			Label.BackgroundTransparency = 1
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.TextTruncate = Enum.TextTruncate.AtEnd
			Label.Parent = KeybindFrame
			
			local KeyButton = Instance.new("TextButton")
			KeyButton.Text = "[" .. CurrentKey.Name .. "]"
			KeyButton.Size = UDim2.new(0, 100, 0, 28)
			KeyButton.Position = UDim2.new(1, -110, 0.5, -14)
			KeyButton.BackgroundColor3 = Theme.Main
			KeyButton.TextColor3 = Theme.Accent
			KeyButton.Font = Enum.Font.GothamBold
			KeyButton.TextSize = 12
			KeyButton.AutoButtonColor = false
			KeyButton.Parent = KeybindFrame
			
			CreateUICorner(KeyButton, 4)
			
			KeyButton.MouseButton1Click:Connect(function()
				Listening = true
				KeyButton.Text = "..."
				KeyButton.TextColor3 = Theme.Text
			end)
			
			UserInputService.InputBegan:Connect(function(input)
				if Listening and input.UserInputType == Enum.UserInputType.Keyboard then
					CurrentKey = input.KeyCode
					KeyButton.Text = "[" .. input.KeyCode.Name .. "]"
					KeyButton.TextColor3 = Theme.Accent
					Listening = false
					
					if Config.Callback then
						task.spawn(Config.Callback, CurrentKey)
					end
				end
			end)
			
			return {
				SetKey = function(self, keycode)
					CurrentKey = keycode
					KeyButton.Text = "[" .. keycode.Name .. "]"
				end
			}
		end
		
		function Elements:CreateInput(Config)
			Config = Config or {}
			local CurrentText = Config.Default or ""
			
			local InputFrame = Instance.new("Frame")
			InputFrame.Name = "Input"
			InputFrame.Size = UDim2.new(1, 0, 0, 42)
			InputFrame.BackgroundColor3 = Theme.Element
			InputFrame.Parent = Page
			
			CreateUICorner(InputFrame, 6)
			CreateUIStroke(InputFrame, Theme.Stroke, 1)
			
			local Label = Instance.new("TextLabel")
			Label.Text = Config.Name or "Input"
			Label.Size = UDim2.new(0, 100, 1, 0)
			Label.Position = UDim2.new(0, 15, 0, 0)
			Label.BackgroundTransparency = 1
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.TextTruncate = Enum.TextTruncate.AtEnd
			Label.Parent = InputFrame
			
			local InputBox = Instance.new("TextBox")
			InputBox.Text = CurrentText
			InputBox.PlaceholderText = Config.Placeholder or "Enter text..."
			InputBox.Size = UDim2.new(1, -130, 0, 28)
			InputBox.Position = UDim2.new(0, 120, 0.5, -14)
			InputBox.BackgroundColor3 = Theme.Main
			InputBox.TextColor3 = Theme.Text
			InputBox.PlaceholderColor3 = Theme.TextDim
			InputBox.Font = Enum.Font.Gotham
			InputBox.TextSize = 12
			InputBox.TextXAlignment = Enum.TextXAlignment.Left
			InputBox.ClearTextOnFocus = false
			InputBox.Parent = InputFrame
			
			CreateUICorner(InputBox, 4)
			CreateUIPadding(InputBox, 0, 10, 10, 0)
			
			InputBox.FocusLost:Connect(function(enterPressed)
				CurrentText = InputBox.Text
				
				if Config.Callback then
					task.spawn(Config.Callback, CurrentText, enterPressed)
				end
			end)
			
			return {
				SetText = function(self, text)
					InputBox.Text = text
					CurrentText = text
				end,
				GetText = function(self)
					return CurrentText
				end
			}
		end
		
		function Elements:CreateDropdown(Config)
			Config = Config or {}
			local Options = Config.Options or {"Option 1", "Option 2", "Option 3"}
			local CurrentOption = Config.Default or Options[1]
			local Opened = false
			
			local DropdownFrame = Instance.new("Frame")
			DropdownFrame.Name = "Dropdown"
			DropdownFrame.Size = UDim2.new(1, 0, 0, 42)
			DropdownFrame.BackgroundColor3 = Theme.Element
			DropdownFrame.ClipsDescendants = false
			DropdownFrame.Parent = Page
			
			CreateUICorner(DropdownFrame, 6)
			CreateUIStroke(DropdownFrame, Theme.Stroke, 1)
			
			local Label = Instance.new("TextLabel")
			Label.Text = Config.Name or "Dropdown"
			Label.Size = UDim2.new(0, 120, 1, 0)
			Label.Position = UDim2.new(0, 15, 0, 0)
			Label.BackgroundTransparency = 1
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.TextTruncate = Enum.TextTruncate.AtEnd
			Label.Parent = DropdownFrame
			
			local SelectedButton = Instance.new("TextButton")
			SelectedButton.Text = CurrentOption
			SelectedButton.Size = UDim2.new(1, -145, 0, 28)
			SelectedButton.Position = UDim2.new(0, 130, 0.5, -14)
			SelectedButton.BackgroundColor3 = Theme.Main
			SelectedButton.TextColor3 = Theme.Accent
			SelectedButton.Font = Enum.Font.Gotham
			SelectedButton.TextSize = 12
			SelectedButton.TextXAlignment = Enum.TextXAlignment.Left
			SelectedButton.AutoButtonColor = false
			SelectedButton.Parent = DropdownFrame
			
			CreateUICorner(SelectedButton, 4)
			CreateUIPadding(SelectedButton, 0, 10, 30, 0)
			
			local Arrow = Instance.new("ImageLabel")
			Arrow.Size = UDim2.new(0, 16, 0, 16)
			Arrow.Position = UDim2.new(1, -22, 0.5, -8)
			Arrow.BackgroundTransparency = 1
			Arrow.Image = "rbxassetid://10709790948"
			Arrow.ImageColor3 = Theme.TextDim
			Arrow.Rotation = 0
			Arrow.Parent = SelectedButton
			
			local OptionsFrame = Instance.new("Frame")
			OptionsFrame.Name = "Options"
			OptionsFrame.Size = UDim2.new(1, -145, 0, 0)
			OptionsFrame.Position = UDim2.new(0, 130, 1, 5)
			OptionsFrame.BackgroundColor3 = Theme.Element
			OptionsFrame.Visible = false
			OptionsFrame.ClipsDescendants = true
			OptionsFrame.Parent = DropdownFrame
			
			CreateUICorner(OptionsFrame, 4)
			CreateUIStroke(OptionsFrame, Theme.Stroke, 1)
			
			local OptionsList = Instance.new("UIListLayout")
			OptionsList.SortOrder = Enum.SortOrder.LayoutOrder
			OptionsList.Padding = UDim.new(0, 2)
			OptionsList.Parent = OptionsFrame
			
			CreateUIPadding(OptionsFrame, 4, 4, 4, 4)
			
			local function CreateOption(optionName)
				local OptionBtn = Instance.new("TextButton")
				OptionBtn.Text = optionName
				OptionBtn.Size = UDim2.new(1, 0, 0, 28)
				OptionBtn.BackgroundColor3 = Theme.Main
				OptionBtn.TextColor3 = Theme.Text
				OptionBtn.Font = Enum.Font.Gotham
				OptionBtn.TextSize = 12
				OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
				OptionBtn.AutoButtonColor = false
				OptionBtn.Parent = OptionsFrame
				
				CreateUICorner(OptionBtn, 4)
				CreateUIPadding(OptionBtn, 0, 8, 8, 0)
				
				OptionBtn.MouseEnter:Connect(function()
					Tween(OptionBtn, {BackgroundColor3 = Theme.ElementHover})
				end)
				
				OptionBtn.MouseLeave:Connect(function()
					Tween(OptionBtn, {BackgroundColor3 = Theme.Main})
				end)
				
				OptionBtn.MouseButton1Click:Connect(function()
					CurrentOption = optionName
					SelectedButton.Text = optionName
					
					Opened = false
					Tween(OptionsFrame, {Size = UDim2.new(1, -145, 0, 0)}, 0.2)
					Tween(Arrow, {Rotation = 0}, 0.2)
					task.wait(0.2)
					OptionsFrame.Visible = false
					
					if Config.Callback then
						task.spawn(Config.Callback, optionName)
					end
				end)
			end
			
			for _, option in ipairs(Options) do
				CreateOption(option)
			end
			
			SelectedButton.MouseButton1Click:Connect(function()
				Opened = not Opened
				
				if Opened then
					OptionsFrame.Visible = true
					local targetHeight = (#Options * 30) + 8
					Tween(OptionsFrame, {Size = UDim2.new(1, -145, 0, targetHeight)}, 0.2)
					Tween(Arrow, {Rotation = 180}, 0.2)
				else
					Tween(OptionsFrame, {Size = UDim2.new(1, -145, 0, 0)}, 0.2)
					Tween(Arrow, {Rotation = 0}, 0.2)
					task.wait(0.2)
					OptionsFrame.Visible = false
				end
			end)
			
			return {
				SetValue = function(self, value)
					if table.find(Options, value) then
						CurrentOption = value
						SelectedButton.Text = value
						
						if Config.Callback then
							task.spawn(Config.Callback, value)
						end
					end
				end,
				GetValue = function(self)
					return CurrentOption
				end,
				UpdateOptions = function(self, newOptions)
					Options = newOptions
					
					for _, child in ipairs(OptionsFrame:GetChildren()) do
						if child:IsA("TextButton") then
							child:Destroy()
						end
					end
					
					for _, option in ipairs(Options) do
						CreateOption(option)
					end
					
					CurrentOption = Options[1]
					SelectedButton.Text = CurrentOption
				end
			}
		end
		
		return Elements
	end
	
	-- Global Keybind Toggle
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == CurrentKeybind then
			ScreenGui.Enabled = not ScreenGui.Enabled
		end
	end)

	-- Settings Page Creation
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
	
	local SettingsLayout = Instance.new("UIListLayout")
	SettingsLayout.Padding = UDim.new(0, 8)
	SettingsLayout.Parent = SettingsPage
	
	CreateUIPadding(SettingsPage, 15, 20, 20, 15)
	
	-- Settings Elements
	local function CreateSettingsSection(name)
		local Section = Instance.new("TextLabel")
		Section.Text = string.upper(name)
		Section.Size = UDim2.new(1, 0, 0, 26)
		Section.BackgroundTransparency = 1
		Section.TextColor3 = Theme.Accent
		Section.Font = Enum.Font.GothamBold
		Section.TextSize = 11
		Section.TextXAlignment = Enum.TextXAlignment.Left
		Section.Parent = SettingsPage
		
		CreateUIPadding(Section, 8, 0, 0, 0)
	end
	
	CreateSettingsSection("Menu Controls")
	
	-- Keybind Setting
	local KeybindFrame = Instance.new("Frame")
	KeybindFrame.Size = UDim2.new(1, 0, 0, 42)
	KeybindFrame.BackgroundColor3 = Theme.Element
	KeybindFrame.Parent = SettingsPage
	
	CreateUICorner(KeybindFrame, 6)
	CreateUIStroke(KeybindFrame, Theme.Stroke, 1)
	
	local KeybindLabel = Instance.new("TextLabel")
	KeybindLabel.Text = "Menu Toggle Keybind"
	KeybindLabel.Size = UDim2.new(1, -120, 1, 0)
	KeybindLabel.Position = UDim2.new(0, 15, 0, 0)
	KeybindLabel.BackgroundTransparency = 1
	KeybindLabel.TextColor3 = Theme.Text
	KeybindLabel.Font = Enum.Font.GothamSemibold
	KeybindLabel.TextSize = 13
	KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
	KeybindLabel.Parent = KeybindFrame
	
	local KeybindBtn = Instance.new("TextButton")
	KeybindBtn.Text = "[" .. CurrentKeybind.Name .. "]"
	KeybindBtn.Size = UDim2.new(0, 100, 0, 26)
	KeybindBtn.Position = UDim2.new(1, -110, 0.5, -13)
	KeybindBtn.BackgroundColor3 = Theme.Main
	KeybindBtn.TextColor3 = Theme.Accent
	KeybindBtn.Font = Enum.Font.GothamBold
	KeybindBtn.TextSize = 12
	KeybindBtn.AutoButtonColor = false
	KeybindBtn.Parent = KeybindFrame
	
	CreateUICorner(KeybindBtn, 4)
	
	local KeybindListening = false
	
	KeybindBtn.MouseButton1Click:Connect(function()
		KeybindListening = true
		KeybindBtn.Text = "..."
		KeybindBtn.TextColor3 = Theme.Text
	end)
	
	UserInputService.InputBegan:Connect(function(input)
		if KeybindListening and input.UserInputType == Enum.UserInputType.Keyboard then
			CurrentKeybind = input.KeyCode
			KeybindBtn.Text = "[" .. input.KeyCode.Name .. "]"
			KeybindBtn.TextColor3 = Theme.Accent
			KeybindListening = false
		end
	end)
	
	CreateSettingsSection("Library")
	
	-- Unload Button
	local UnloadBtn = Instance.new("TextButton")
	UnloadBtn.Size = UDim2.new(1, 0, 0, 42)
	UnloadBtn.BackgroundColor3 = Theme.Element
	UnloadBtn.AutoButtonColor = false
	UnloadBtn.Text = ""
	UnloadBtn.Parent = SettingsPage
	
	CreateUICorner(UnloadBtn, 6)
	CreateUIStroke(UnloadBtn, Theme.Stroke, 1)
	
	local UnloadLabel = Instance.new("TextLabel")
	UnloadLabel.Text = "Unload Library"
	UnloadLabel.Size = UDim2.new(1, -40, 1, 0)
	UnloadLabel.Position = UDim2.new(0, 15, 0, 0)
	UnloadLabel.BackgroundTransparency = 1
	UnloadLabel.TextColor3 = Theme.Error
	UnloadLabel.Font = Enum.Font.GothamSemibold
	UnloadLabel.TextSize = 13
	UnloadLabel.TextXAlignment = Enum.TextXAlignment.Left
	UnloadLabel.Parent = UnloadBtn
	
	UnloadBtn.MouseEnter:Connect(function()
		Tween(UnloadBtn, {BackgroundColor3 = Theme.ElementHover})
	end)
	
	UnloadBtn.MouseLeave:Connect(function()
		Tween(UnloadBtn, {BackgroundColor3 = Theme.Element})
	end)
	
	UnloadBtn.MouseButton1Click:Connect(function()
		Tween(Main, {Size = UDim2.new(0, 0, 0, 0)}, 0.3)
		task.wait(0.3)
		ScreenGui:Destroy()
	end)
	
	-- Settings Button in Sidebar
	local SettingsBtn = Instance.new("TextButton")
	SettingsBtn.Name = "SettingsBtn"
	SettingsBtn.Size = UDim2.new(1, -20, 1, -5)
	SettingsBtn.Position = UDim2.new(0, 10, 0, 0)
	SettingsBtn.BackgroundTransparency = 1
	SettingsBtn.BackgroundColor3 = Theme.Element
	SettingsBtn.AutoButtonColor = false
	SettingsBtn.Text = ""
	SettingsBtn.Parent = SettingsArea
	
	CreateUICorner(SettingsBtn, 6)
	
	local SettingsIcon = Instance.new("ImageLabel")
	SettingsIcon.Name = "Icon"
	SettingsIcon.Size = UDim2.new(0, 18, 0, 18)
	SettingsIcon.Position = UDim2.new(0, 12, 0.5, -9)
	SettingsIcon.BackgroundTransparency = 1
	SettingsIcon.Image = Icons.Settings
	SettingsIcon.ImageColor3 = Theme.TextDim
	SettingsIcon.Parent = SettingsBtn
	
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
	SettingsLabel.Parent = SettingsBtn
	
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
		-- Deactivate all tabs
		for _, tab in pairs(TabContainer:GetChildren()) do
			if tab:IsA("TextButton") then
				Tween(tab, {BackgroundTransparency = 1})
				if tab:FindFirstChild("Label") then
					Tween(tab.Label, {TextColor3 = Theme.TextDim})
				end
				if tab:FindFirstChild("Icon") then
					Tween(tab.Icon, {ImageColor3 = Theme.TextDim})
				end
			end
		end
		
		-- Hide all pages
		for _, page in pairs(Pages:GetChildren()) do
			if page:IsA("ScrollingFrame") then
				page.Visible = false
			end
		end
		
		-- Activate Settings
		SettingsPage.Visible = true
		ActiveTab = "Settings"
		Tween(SettingsBtn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0})
		Tween(SettingsLabel, {TextColor3 = Theme.Text})
		Tween(SettingsIcon, {ImageColor3 = Theme.Accent})
	end)
	
	return Tabs
end

return ChuddyLib
