--[[ 
    CHUDDY HUB | FINAL RELEASE
    Obsidian Style, Fixed Layout, Taller, Custom Icons.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local ChuddyLib = {}

--// Theme Configuration (Obsidian Dark)
local Theme = {
	Main = Color3.fromRGB(15, 15, 17),
	Sidebar = Color3.fromRGB(20, 20, 23),
	Content = Color3.fromRGB(15, 15, 17),
	Element = Color3.fromRGB(28, 28, 32),
	Header = Color3.fromRGB(25, 25, 28),
	Text = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(140, 140, 140),
	Accent = Color3.fromRGB(114, 137, 218), -- Obsidian Blurple
	Stroke = Color3.fromRGB(45, 45, 50),
	Divider = Color3.fromRGB(35, 35, 40)
}

--// Icons (Clean Outline Style)
local Icons = {
	Logo = "rbxassetid://134140528282189", -- Default fallback
	Settings = "rbxassetid://10723415903",
	User = "rbxassetid://10723415903",
	Close = "rbxassetid://3926305904",
	Min = "rbxassetid://3926307971",
	Resize = "rbxassetid://134140528282189"
}

--// Helper: Custom Image Loader (For your GitHub Icon)
local function GetCustomIcon(Url)
	-- This function attempts to load the image via Executor functions if available
	-- Otherwise falls back to a placeholder to prevent errors in Studio
	local success, response = pcall(function()
		local file_name = "chuddy_logo.png"
		if not isfile(file_name) then
			local content = game:HttpGet(Url)
			writefile(file_name, content)
		end
		return getcustomasset(file_name)
	end)
	return success and response or Icons.Logo
end

--// Helper: Tween
local function Tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

--// Helper: Safe Parent
local function GetParent()
	local Success, Result = pcall(function() return gethui() end)
	if Success and Result then return Result end
	if game:GetService("CoreGui"):FindFirstChild("RobloxGui") then return game:GetService("CoreGui") end
	return LocalPlayer:WaitForChild("PlayerGui")
end

--// Main Window
function ChuddyLib:CreateWindow(Settings)
	local WindowName = Settings.Name or "Chuddy Hub"
	local CurrentKeybind = Settings.Keybind or Enum.KeyCode.RightControl
	local CustomIconUrl = "https://raw.githubusercontent.com/foekey/ChuddyUILib/main/chud.png"
	
	-- 1. ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ChuddyObsidian"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = GetParent()
	
	-- 2. Main Frame (Taller Form Factor)
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 700, 0, 550) -- Taller size requested
	Main.Position = UDim2.new(0.5, -350, 0.5, -275)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui
	
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)
	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Theme.Stroke
	MainStroke.Thickness = 1
	MainStroke.Parent = Main

	-- 3. Sidebar Container
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 200, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main
	
	local SidebarLine = Instance.new("Frame")
	SidebarLine.Size = UDim2.new(0, 1, 1, 0)
	SidebarLine.Position = UDim2.new(1, -1, 0, 0)
	SidebarLine.BackgroundColor3 = Theme.Divider
	SidebarLine.BorderSizePixel = 0
	SidebarLine.Parent = Sidebar

	-- 3a. Sidebar Header (Logo + Title)
	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 60)
	Header.BackgroundTransparency = 1
	Header.Parent = Sidebar
	
	local Logo = Instance.new("ImageLabel")
	Logo.Size = UDim2.new(0, 28, 0, 28)
	Logo.Position = UDim2.new(0, 14, 0.5, -14)
	Logo.BackgroundTransparency = 1
	-- Try to load your GitHub icon, fallback to default if not in executor
	Logo.Image = GetCustomIcon(CustomIconUrl) 
	Logo.Parent = Header
	Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 4)
	
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Text = WindowName
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 16
	TitleLabel.TextColor3 = Theme.Text
	TitleLabel.Size = UDim2.new(1, -50, 1, 0)
	TitleLabel.Position = UDim2.new(0, 50, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Header

	-- 3b. User Profile (Pinned Bottom)
	local UserProfile = Instance.new("Frame")
	UserProfile.Name = "UserProfile"
	UserProfile.Size = UDim2.new(1, 0, 0, 60)
	UserProfile.Position = UDim2.new(0, 0, 1, -60)
	UserProfile.BackgroundColor3 = Theme.Sidebar
	UserProfile.BorderSizePixel = 0
	UserProfile.Parent = Sidebar
	
	local ProfileSep = Instance.new("Frame")
	ProfileSep.Size = UDim2.new(1, -20, 0, 1)
	ProfileSep.Position = UDim2.new(0, 10, 0, 0)
	ProfileSep.BackgroundColor3 = Theme.Divider
	ProfileSep.BorderSizePixel = 0
	ProfileSep.Parent = UserProfile

	local Avatar = Instance.new("ImageLabel")
	Avatar.Size = UDim2.new(0, 36, 0, 36)
	Avatar.Position = UDim2.new(0, 12, 0.5, -18)
	Avatar.BackgroundColor3 = Theme.Element
	Avatar.Parent = UserProfile
	Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
	
	task.spawn(function()
		local img = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		Avatar.Image = img
	end)
	
	local Username = Instance.new("TextLabel")
	Username.Text = LocalPlayer.Name
	Username.Font = Enum.Font.GothamBold
	Username.TextSize = 13
	Username.TextColor3 = Theme.Text
	Username.Size = UDim2.new(1, -60, 0, 20)
	Username.Position = UDim2.new(0, 58, 0.5, -10)
	Username.BackgroundTransparency = 1
	Username.TextXAlignment = Enum.TextXAlignment.Left
	Username.Parent = UserProfile
	
	local Rank = Instance.new("TextLabel")
	Rank.Text = "Premium User"
	Rank.Font = Enum.Font.Gotham
	Rank.TextSize = 11
	Rank.TextColor3 = Theme.Accent
	Rank.Size = UDim2.new(1, -60, 0, 15)
	Rank.Position = UDim2.new(0, 58, 0.5, 4)
	Rank.BackgroundTransparency = 1
	Rank.TextXAlignment = Enum.TextXAlignment.Left
	Rank.Parent = UserProfile

	-- 3c. Settings Button (Pinned Above Profile)
	local SettingsArea = Instance.new("Frame")
	SettingsArea.Name = "SettingsArea"
	SettingsArea.Size = UDim2.new(1, 0, 0, 45)
	SettingsArea.Position = UDim2.new(0, 0, 1, -105) -- 60 (Profile) + 45 (Self)
	SettingsArea.BackgroundTransparency = 1
	SettingsArea.Parent = Sidebar
	
	-- 3d. Tab Scroll (Fills remaining space)
	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "Tabs"
	TabContainer.Size = UDim2.new(1, 0, 1, -165) -- Total Height - (Header(60) + Settings(45) + Profile(60))
	TabContainer.Position = UDim2.new(0, 0, 0, 60)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 0
	TabContainer.Parent = Sidebar
	
	local TabList = Instance.new("UIListLayout")
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 4)
	TabList.Parent = TabContainer
	
	local TabPad = Instance.new("UIPadding")
	TabPad.PaddingLeft = UDim.new(0, 10)
	TabPad.PaddingTop = UDim.new(0, 10)
	TabPad.Parent = TabContainer

	-- 4. Content Area
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Size = UDim2.new(1, -200, 1, 0)
	Content.Position = UDim2.new(0, 200, 0, 0)
	Content.BackgroundTransparency = 1
	Content.Parent = Main
	
	-- Top Bar (Search/Min/Close)
	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1, 0, 0, 50)
	TopBar.BackgroundTransparency = 1
	TopBar.Parent = Content
	
	local TopSep = Instance.new("Frame")
	TopSep.Size = UDim2.new(1, 0, 0, 1)
	TopSep.Position = UDim2.new(0, 0, 1, -1)
	TopSep.BackgroundColor3 = Theme.Divider
	TopSep.BorderSizePixel = 0
	TopSep.Parent = TopBar
	
	local function CreateWinControl(Icon, Type)
		local Btn = Instance.new("ImageButton")
		Btn.Size = UDim2.new(0, 40, 0, 40)
		Btn.Position = UDim2.new(1, Type == "Close" and -40 or -80, 0, 5)
		Btn.BackgroundTransparency = 1
		Btn.Image = Icon
		Btn.ImageColor3 = Theme.TextDim
		Btn.Parent = TopBar
		
		local Pad = Instance.new("UIPadding")
		Pad.PaddingTop = UDim.new(0, 11)
		Pad.PaddingBottom = UDim.new(0, 11)
		Pad.PaddingLeft = UDim.new(0, 11)
		Pad.PaddingRight = UDim.new(0, 11)
		Pad.Parent = Btn
		
		Btn.MouseEnter:Connect(function() Tween(Btn, {ImageColor3 = Theme.Text}) end)
		Btn.MouseLeave:Connect(function() Tween(Btn, {ImageColor3 = Theme.TextDim}) end)
		return Btn
	end
	
	local CloseBtn = CreateWinControl(Icons.Close, "Close")
	local MinBtn = CreateWinControl(Icons.Min, "Min")
	
	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	
	-- Minimize Logic (Shrink)
	local Minimized = false
	local OldSize = Main.Size
	
	MinBtn.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		if Minimized then
			OldSize = Main.Size
			Tween(Main, {Size = UDim2.new(0, OldSize.X.Offset, 0, 50)}, 0.4)
			Sidebar.Visible = false
			Content.Visible = false -- Hide content, keep main frame as just a bar
			-- Create a temporary title bar when minimized so you can drag it
			local MiniTitle = Instance.new("TextLabel")
			MiniTitle.Name = "MiniTitle"
			MiniTitle.Text = WindowName
			MiniTitle.Size = UDim2.new(1, -50, 1, 0)
			MiniTitle.Position = UDim2.new(0, 15, 0, 0)
			MiniTitle.BackgroundTransparency = 1
			MiniTitle.TextColor3 = Theme.Text
			MiniTitle.Font = Enum.Font.GothamBold
			MiniTitle.TextSize = 14
			MiniTitle.TextXAlignment = Enum.TextXAlignment.Left
			MiniTitle.Parent = Main
		else
			if Main:FindFirstChild("MiniTitle") then Main.MiniTitle:Destroy() end
			Tween(Main, {Size = OldSize}, 0.4)
			task.wait(0.2)
			Sidebar.Visible = true
			Content.Visible = true
		end
	end)

	-- Page Container
	local Pages = Instance.new("Frame")
	Pages.Name = "Pages"
	Pages.Size = UDim2.new(1, 0, 1, -50)
	Pages.Position = UDim2.new(0, 0, 0, 50)
	Pages.BackgroundTransparency = 1
	Pages.Parent = Content

	--// Dragging
	local Dragging, DragInput, DragStart, StartPos
	Sidebar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true; DragStart = input.Position; StartPos = Main.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
		end
	end)
	Sidebar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			local delta = input.Position - DragStart
			Tween(Main, {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)}, 0.05)
		end
	end)

	--// Resizing
	local ResizeHandle = Instance.new("ImageButton")
	ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
	ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
	ResizeHandle.BackgroundTransparency = 1
	ResizeHandle.Image = Icons.Resize
	ResizeHandle.ImageTransparency = 0.5
	ResizeHandle.ImageColor3 = Theme.TextDim
	ResizeHandle.Parent = Main
	
	local Resizing, ResizeStart, StartSize
	ResizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Resizing = true; ResizeStart = input.Position; StartSize = Main.Size
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Resizing = false end end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if Resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - ResizeStart
			local newX = math.clamp(StartSize.X.Offset + delta.X, 600, 1000)
			local newY = math.clamp(StartSize.Y.Offset + delta.Y, 400, 800)
			Tween(Main, {Size = UDim2.new(0, newX, 0, newY)}, 0.05)
		end
	end)

	--// Tabs System
	local Tabs = {}
	local FirstTab = true

	function Tabs:CreateTab(TabName, IconId)
		-- Sidebar Button
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, -10, 0, 38)
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = ""
		TabBtn.Parent = TabContainer
		
		local BtnCorner = Instance.new("UICorner")
		BtnCorner.CornerRadius = UDim.new(0, 6)
		BtnCorner.Parent = TabBtn
		
		local Ico = Instance.new("ImageLabel")
		Ico.Size = UDim2.new(0, 18, 0, 18)
		Ico.Position = UDim2.new(0, 12, 0.5, -9)
		Ico.BackgroundTransparency = 1
		Ico.Image = IconId or Icons.User
		Ico.ImageColor3 = Theme.TextDim
		Ico.Parent = TabBtn
		
		local Txt = Instance.new("TextLabel")
		Txt.Text = TabName
		Txt.Size = UDim2.new(1, -40, 1, 0)
		Txt.Position = UDim2.new(0, 42, 0, 0)
		Txt.BackgroundTransparency = 1
		Txt.TextColor3 = Theme.TextDim
		Txt.Font = Enum.Font.GothamMedium
		Txt.TextSize = 13
		Txt.TextXAlignment = Enum.TextXAlignment.Left
		Txt.Parent = TabBtn
		
		-- Page Frame
		local Page = Instance.new("ScrollingFrame")
		Page.Name = TabName
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 3
		Page.ScrollBarImageColor3 = Theme.Accent
		Page.Visible = false
		Page.Parent = Pages
		
		local PageList = Instance.new("UIListLayout")
		PageList.SortOrder = Enum.SortOrder.LayoutOrder
		PageList.Padding = UDim.new(0, 8)
		PageList.Parent = Page
		
		local PagePad = Instance.new("UIPadding")
		PagePad.PaddingTop = UDim.new(0, 10)
		PagePad.PaddingLeft = UDim.new(0, 20)
		PagePad.PaddingRight = UDim.new(0, 20)
		PagePad.PaddingBottom = UDim.new(0, 10)
		PagePad.Parent = Page
		
		local function Activate()
			-- Deactivate others
			for _, v in pairs(TabContainer:GetChildren()) do
				if v:IsA("TextButton") then
					Tween(v, {BackgroundTransparency = 1})
					Tween(v.TextLabel, {TextColor3 = Theme.TextDim})
					Tween(v.ImageLabel, {ImageColor3 = Theme.TextDim})
				end
			end
			-- Deactivate Settings Button visually
			local SetBtn = SettingsArea:FindFirstChild("SettingsBtn")
			if SetBtn then 
				Tween(SetBtn, {BackgroundTransparency = 1})
				Tween(SetBtn.TextLabel, {TextColor3 = Theme.TextDim})
				Tween(SetBtn.ImageLabel, {ImageColor3 = Theme.TextDim})
			end
			
			for _, v in pairs(Pages:GetChildren()) do v.Visible = false end
			
			-- Activate This
			Page.Visible = true
			Tween(TabBtn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0})
			Tween(Txt, {TextColor3 = Theme.Text})
			Tween(Ico, {ImageColor3 = Theme.Accent})
		end
		
		TabBtn.MouseButton1Click:Connect(Activate)
		
		if FirstTab then FirstTab = false; Activate() end
		
		local Elements = {}
		
		function Elements:CreateSection(Name)
			local Lab = Instance.new("TextLabel")
			Lab.Text = string.upper(Name)
			Lab.Size = UDim2.new(1, 0, 0, 30)
			Lab.BackgroundTransparency = 1
			Lab.TextColor3 = Theme.Accent
			Lab.Font = Enum.Font.GothamBold
			Lab.TextSize = 11
			Lab.TextXAlignment = Enum.TextXAlignment.Left
			Lab.Parent = Page
			local P = Instance.new("UIPadding"); P.PaddingTop = UDim.new(0, 10); P.Parent = Lab
		end
		
		function Elements:CreateButton(Config)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 0, 42)
			Btn.BackgroundColor3 = Theme.Element
			Btn.Text = ""
			Btn.AutoButtonColor = false
			Btn.Parent = Page
			Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
			Instance.new("UIStroke", Btn).Color = Theme.Stroke
			
			local T = Instance.new("TextLabel")
			T.Text = Config.Name
			T.Size = UDim2.new(1, -20, 1, 0)
			T.Position = UDim2.new(0, 15, 0, 0)
			T.BackgroundTransparency = 1
			T.TextColor3 = Theme.Text
			T.Font = Enum.Font.GothamSemibold
			T.TextSize = 13
			T.TextXAlignment = Enum.TextXAlignment.Left
			T.Parent = Btn
			
			Btn.MouseButton1Click:Connect(function()
				Tween(Btn, {BackgroundColor3 = Theme.Stroke}, 0.1)
				task.wait(0.1)
				Tween(Btn, {BackgroundColor3 = Theme.Element})
				pcall(Config.Callback)
			end)
		end
		
		function Elements:CreateToggle(Config)
			local State = Config.Default or false
			
			local Tog = Instance.new("TextButton")
			Tog.Size = UDim2.new(1, 0, 0, 42)
			Tog.BackgroundColor3 = Theme.Element
			Tog.Text = ""
			Tog.AutoButtonColor = false
			Tog.Parent = Page
			Instance.new("UICorner", Tog).CornerRadius = UDim.new(0, 6)
			Instance.new("UIStroke", Tog).Color = Theme.Stroke
			
			local T = Instance.new("TextLabel")
			T.Text = Config.Name
			T.Size = UDim2.new(1, -70, 1, 0)
			T.Position = UDim2.new(0, 15, 0, 0)
			T.BackgroundTransparency = 1
			T.TextColor3 = Theme.Text
			T.Font = Enum.Font.GothamSemibold
			T.TextSize = 13
			T.TextXAlignment = Enum.TextXAlignment.Left
			T.Parent = Tog
			
			local Sw = Instance.new("Frame")
			Sw.Size = UDim2.new(0, 40, 0, 22)
			Sw.Position = UDim2.new(1, -50, 0.5, -11)
			Sw.BackgroundColor3 = State and Theme.Accent or Theme.Main
			Sw.Parent = Tog
			Instance.new("UICorner", Sw).CornerRadius = UDim.new(1, 0)
			
			local Circle = Instance.new("Frame")
			Circle.Size = UDim2.new(0, 18, 0, 18)
			Circle.Position = State and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
			Circle.BackgroundColor3 = Theme.Text
			Circle.Parent = Sw
			Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
			
			Tog.MouseButton1Click:Connect(function()
				State = not State
				Tween(Sw, {BackgroundColor3 = State and Theme.Accent or Theme.Main})
				Tween(Circle, {Position = State and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
				pcall(Config.Callback, State)
			end)
		end
		
		function Elements:CreateSlider(Config)
			local Min, Max = Config.Min, Config.Max
			local Val = Config.Default or Min
			
			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, 0, 0, 50)
			Frame.BackgroundColor3 = Theme.Element
			Frame.Parent = Page
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
			Instance.new("UIStroke", Frame).Color = Theme.Stroke
			
			local T = Instance.new("TextLabel")
			T.Text = Config.Name
			T.Size = UDim2.new(1, -20, 0, 20)
			T.Position = UDim2.new(0, 15, 0, 8)
			T.BackgroundTransparency = 1
			T.TextColor3 = Theme.Text
			T.Font = Enum.Font.GothamSemibold
			T.TextSize = 13
			T.TextXAlignment = Enum.TextXAlignment.Left
			T.Parent = Frame
			
			local Num = Instance.new("TextLabel")
			Num.Text = tostring(Val)
			Num.Size = UDim2.new(0, 50, 0, 20)
			Num.Position = UDim2.new(1, -60, 0, 8)
			Num.BackgroundTransparency = 1
			Num.TextColor3 = Theme.Accent
			Num.Font = Enum.Font.GothamBold
			Num.TextSize = 13
			Num.TextXAlignment = Enum.TextXAlignment.Right
			Num.Parent = Frame
			
			local Bar = Instance.new("TextButton")
			Bar.Text = ""
			Bar.Size = UDim2.new(1, -30, 0, 6)
			Bar.Position = UDim2.new(0, 15, 0, 32)
			Bar.BackgroundColor3 = Theme.Main
			Bar.AutoButtonColor = false
			Bar.Parent = Frame
			Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
			
			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new((Val - Min)/(Max - Min), 0, 1, 0)
			Fill.BackgroundColor3 = Theme.Accent
			Fill.BorderSizePixel = 0
			Fill.Parent = Bar
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
			
			local Dragging = false
			local function Update(i)
				local pos = math.clamp((i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
				local n = math.floor(Min + ((Max - Min) * pos))
				Num.Text = tostring(n)
				pcall(Config.Callback, n)
			end
			Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Update(i) end end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
			UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
		end
		
		function Elements:CreateKeybind(Config)
			local Val = Config.Default or Enum.KeyCode.RightControl
			
			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, 0, 0, 42)
			Frame.BackgroundColor3 = Theme.Element
			Frame.Parent = Page
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
			Instance.new("UIStroke", Frame).Color = Theme.Stroke
			
			local T = Instance.new("TextLabel")
			T.Text = Config.Name
			T.Size = UDim2.new(1, -100, 1, 0)
			T.Position = UDim2.new(0, 15, 0, 0)
			T.BackgroundTransparency = 1
			T.TextColor3 = Theme.Text
			T.Font = Enum.Font.GothamSemibold
			T.TextSize = 13
			T.TextXAlignment = Enum.TextXAlignment.Left
			T.Parent = Frame
			
			local Bind = Instance.new("TextButton")
			Bind.Text = "[" .. Val.Name .. "]"
			Bind.Size = UDim2.new(0, 90, 0, 26)
			Bind.Position = UDim2.new(1, -100, 0.5, -13)
			Bind.BackgroundColor3 = Theme.Main
			Bind.TextColor3 = Theme.Accent
			Bind.Font = Enum.Font.GothamBold
			Bind.TextSize = 12
			Bind.Parent = Frame
			Instance.new("UICorner", Bind).CornerRadius = UDim.new(0, 4)
			
			local Listening = false
			Bind.MouseButton1Click:Connect(function()
				Listening = true
				Bind.Text = "..."
				Bind.TextColor3 = Theme.Text
			end)
			UserInputService.InputBegan:Connect(function(input)
				if Listening and input.UserInputType == Enum.UserInputType.Keyboard then
					Val = input.KeyCode
					Bind.Text = "[" .. Val.Name .. "]"
					Bind.TextColor3 = Theme.Accent
					Listening = false
					pcall(Config.Callback, Val)
				end
			end)
		end
		
		return Elements
	end
	
	-- Global Toggle
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == CurrentKeybind then
			ScreenGui.Enabled = not ScreenGui.Enabled
		end
	end)

	--// Manual Settings Tab Construction
	-- We do this manually to allow specific button placement logic for the "Settings" button in sidebar
	
	local SetPage = Instance.new("ScrollingFrame")
	SetPage.Name = "Settings"
	SetPage.Size = UDim2.new(1, 0, 1, 0)
	SetPage.BackgroundTransparency = 1
	SetPage.Visible = false
	SetPage.Parent = Pages
	local SetList = Instance.new("UIListLayout"); SetList.Padding = UDim.new(0, 8); SetList.Parent = SetPage
	local SetPad = Instance.new("UIPadding"); SetPad.PaddingTop = UDim.new(0, 10); SetPad.PaddingLeft = UDim.new(0, 20); SetPad.PaddingRight = UDim.new(0, 20); SetPad.Parent = SetPage

	-- Define Settings Elements Interface
	local SetElements = {}
	function SetElements:CreateSection(Name) Tabs.CreateTab("Temp").CreateSection(Name) end -- Reuse logic hack or copy paste
	-- Re-implementing simplified versions for settings page specifically
	local function CreateSetHeader(Txt) 
		local L = Instance.new("TextLabel"); L.Text=string.upper(Txt); L.Size=UDim2.new(1,0,0,30); L.BackgroundTransparency=1; L.TextColor3=Theme.Accent; L.Font=Enum.Font.GothamBold; L.TextSize=11; L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=SetPage; local P=Instance.new("UIPadding"); P.PaddingTop=UDim2.new(0,10); P.Parent=L 
	end
	
	CreateSetHeader("Menu")
	
	-- Keybind Element for Settings
	local KeyFrame = Instance.new("Frame")
	KeyFrame.Size = UDim2.new(1, 0, 0, 42)
	KeyFrame.BackgroundColor3 = Theme.Element
	KeyFrame.Parent = SetPage
	Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", KeyFrame).Color = Theme.Stroke
	local KeyLbl = Instance.new("TextLabel"); KeyLbl.Text = "Menu Toggle"; KeyLbl.Size = UDim2.new(1, -100, 1, 0); KeyLbl.Position = UDim2.new(0, 15, 0, 0); KeyLbl.BackgroundTransparency = 1; KeyLbl.TextColor3 = Theme.Text; KeyLbl.Font = Enum.Font.GothamSemibold; KeyLbl.TextSize = 13; KeyLbl.TextXAlignment = Enum.TextXAlignment.Left; KeyLbl.Parent = KeyFrame
	local KeyBtn = Instance.new("TextButton"); KeyBtn.Text = "["..CurrentKeybind.Name.."]"; KeyBtn.Size = UDim2.new(0, 90, 0, 26); KeyBtn.Position = UDim2.new(1, -100, 0.5, -13); KeyBtn.BackgroundColor3 = Theme.Main; KeyBtn.TextColor3 = Theme.Accent; KeyBtn.Font = Enum.Font.GothamBold; KeyBtn.TextSize = 12; KeyBtn.Parent = KeyFrame; Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 4)
	local KL = false
	KeyBtn.MouseButton1Click:Connect(function() KL = true; KeyBtn.Text = "..."; KeyBtn.TextColor3 = Theme.Text end)
	UserInputService.InputBegan:Connect(function(i) if KL and i.UserInputType == Enum.UserInputType.Keyboard then CurrentKeybind = i.KeyCode; KeyBtn.Text = "["..i.KeyCode.Name.."]"; KeyBtn.TextColor3 = Theme.Accent; KL = false end end)
	
	-- Unload Button
	local UnloadBtn = Instance.new("TextButton")
	UnloadBtn.Size = UDim2.new(1, 0, 0, 42)
	UnloadBtn.BackgroundColor3 = Theme.Element
	UnloadBtn.Text = ""
	UnloadBtn.Parent = SetPage
	Instance.new("UICorner", UnloadBtn).CornerRadius = UDim.new(0, 6)
	Instance.new("UIStroke", UnloadBtn).Color = Theme.Stroke
	local ULT = Instance.new("TextLabel"); ULT.Text = "Unload Library"; ULT.Size = UDim2.new(1, -20, 1, 0); ULT.Position = UDim2.new(0, 15, 0, 0); ULT.BackgroundTransparency = 1; ULT.TextColor3 = Color3.fromRGB(200, 50, 50); ULT.Font = Enum.Font.GothamSemibold; ULT.TextSize = 13; ULT.TextXAlignment = Enum.TextXAlignment.Left; ULT.Parent = UnloadBtn
	UnloadBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	
	-- Sidebar Settings Button
	local SetBtn = Instance.new("TextButton")
	SetBtn.Name = "SettingsBtn"
	SetBtn.Size = UDim2.new(1, -20, 1, -5)
	SetBtn.Position = UDim2.new(0, 10, 0, 0)
	SetBtn.BackgroundTransparency = 1
	SetBtn.Text = ""
	SetBtn.Parent = SettingsArea
	
	local SetCorner = Instance.new("UICorner")
	SetCorner.CornerRadius = UDim.new(0, 6)
	SetCorner.Parent = SetBtn
	
	local SIco = Instance.new("ImageLabel")
	SIco.Size = UDim2.new(0, 18, 0, 18)
	SIco.Position = UDim2.new(0, 12, 0.5, -9)
	SIco.BackgroundTransparency = 1
	SIco.Image = Icons.Settings
	SIco.ImageColor3 = Theme.TextDim
	SIco.Parent = SetBtn
	
	local STxt = Instance.new("TextLabel")
	STxt.Text = "Settings"
	STxt.Size = UDim2.new(1, -40, 1, 0)
	STxt.Position = UDim2.new(0, 42, 0, 0)
	STxt.BackgroundTransparency = 1
	STxt.TextColor3 = Theme.TextDim
	STxt.Font = Enum.Font.GothamMedium
	STxt.TextSize = 13
	STxt.TextXAlignment = Enum.TextXAlignment.Left
	STxt.Parent = SetBtn
	
	SetBtn.MouseButton1Click:Connect(function()
		-- Deactivate Tabs
		for _, v in pairs(TabContainer:GetChildren()) do
			if v:IsA("TextButton") then
				Tween(v, {BackgroundTransparency = 1})
				Tween(v.TextLabel, {TextColor3 = Theme.TextDim})
				Tween(v.ImageLabel, {ImageColor3 = Theme.TextDim})
			end
		end
		for _, v in pairs(Pages:GetChildren()) do v.Visible = false end
		
		-- Activate Settings
		SetPage.Visible = true
		Tween(SetBtn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0})
		Tween(STxt, {TextColor3 = Theme.Text})
		Tween(SIco, {ImageColor3 = Theme.Accent})
	end)
	
	return Tabs
end

return ChuddyLib
