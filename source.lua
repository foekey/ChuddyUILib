--[[ 
    CHUDDY HUB | FINAL RELEASE 1.1
    Fixed Layout, Rounded Controls, Text Scaling, Taller.
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
	Header = Color3.fromRGB(28, 28, 30),
	Text = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(140, 140, 140),
	Accent = Color3.fromRGB(114, 137, 218), -- Blurple
	Stroke = Color3.fromRGB(45, 45, 48),
	Divider = Color3.fromRGB(35, 35, 38)
}

--// Icons
local Icons = {
	Logo = "rbxassetid://134140528282189",
	Settings = "rbxassetid://10723415903",
	User = "rbxassetid://10723415903",
	Close = "rbxassetid://3926305904",
	Min = "rbxassetid://3926307971",
	Resize = "rbxassetid://134140528282189"
}

--// Helpers
local function GetCustomIcon(Url)
	local success, response = pcall(function()
		local file_name = "chuddy_ico.png"
		if not isfile(file_name) then writefile(file_name, game:HttpGet(Url)) end
		return getcustomasset(file_name)
	end)
	return success and response or Icons.Logo
end

local function Tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local function GetParent()
	local s, r = pcall(function() return gethui() end)
	if s and r then return r end
	return LocalPlayer:WaitForChild("PlayerGui")
end

--// Main Window
function ChuddyLib:CreateWindow(Settings)
	local WindowName = Settings.Name or "Chuddy Hub"
	local CurrentKeybind = Settings.Keybind or Enum.KeyCode.RightControl
	local CustomIconUrl = "https://raw.githubusercontent.com/foekey/ChuddyUILib/main/chud.png"
	
	-- 1. ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ChuddyUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = GetParent()
	
	-- 2. Main Frame
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 750, 0, 550) -- Taller
	Main.Position = UDim2.new(0.5, -375, 0.5, -275)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui
	
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Theme.Stroke
	MainStroke.Thickness = 1
	MainStroke.Parent = Main

	-- 3. Sidebar
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
	Header.Size = UDim2.new(1, 0, 0, 60)
	Header.BackgroundTransparency = 1
	Header.Parent = Sidebar
	
	local Logo = Instance.new("ImageLabel")
	Logo.Size = UDim2.new(0, 30, 0, 30)
	Logo.Position = UDim2.new(0, 15, 0.5, -15)
	Logo.BackgroundTransparency = 1
	Logo.Image = GetCustomIcon(CustomIconUrl)
	Logo.Parent = Header
	Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 5)
	
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

	-- User Profile (Pinned Bottom)
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
	Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
	task.spawn(function()
		Avatar.Image = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
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

	-- Settings Area (Pinned Above Profile)
	local SettingsArea = Instance.new("Frame")
	SettingsArea.Size = UDim2.new(1, 0, 0, 50)
	SettingsArea.Position = UDim2.new(0, 0, 1, -115) -- 65 + 50
	SettingsArea.BackgroundTransparency = 1
	SettingsArea.Parent = Sidebar

	-- Tab Container (Fills Rest)
	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Size = UDim2.new(1, 0, 1, -175) -- 60 (Header) + 50 (Settings) + 65 (Profile)
	TabContainer.Position = UDim2.new(0, 0, 0, 60)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 0
	TabContainer.Parent = Sidebar
	
	local TabList = Instance.new("UIListLayout")
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 4)
	TabList.Parent = TabContainer
	
	local TabPad = Instance.new("UIPadding")
	TabPad.PaddingTop = UDim.new(0, 5)
	TabPad.PaddingLeft = UDim.new(0, 10)
	TabPad.Parent = TabContainer

	-- 4. Content Area
	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1, -210, 1, 0)
	Content.Position = UDim2.new(0, 210, 0, 0)
	Content.BackgroundTransparency = 1
	Content.ClipsDescendants = true -- Important for text scaling
	Content.Parent = Main
	
	-- Top Bar
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
		Btn.Size = UDim2.new(0, 32, 0, 32)
		Btn.Position = UDim2.new(1, Type == "Close" and -42 or -82, 0, 9)
		Btn.BackgroundColor3 = Theme.Element
		Btn.Image = Icon
		Btn.ImageColor3 = Theme.TextDim
		Btn.Parent = TopBar
		
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6) -- Rounded Controls
		
		local Pad = Instance.new("UIPadding")
		Pad.PaddingTop = UDim.new(0, 8)
		Pad.PaddingBottom = UDim.new(0, 8)
		Pad.PaddingLeft = UDim.new(0, 8)
		Pad.PaddingRight = UDim.new(0, 8)
		Pad.Parent = Btn
		
		Btn.MouseEnter:Connect(function() Tween(Btn, {ImageColor3 = Theme.Text, BackgroundColor3 = Theme.Stroke}) end)
		Btn.MouseLeave:Connect(function() Tween(Btn, {ImageColor3 = Theme.TextDim, BackgroundColor3 = Theme.Element}) end)
		return Btn
	end
	
	local CloseBtn = CreateWinControl(Icons.Close, "Close")
	local MinBtn = CreateWinControl(Icons.Min, "Min")
	
	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	
	-- Minimize Logic
	local Minimized = false
	local OldSize = Main.Size
	MinBtn.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		if Minimized then
			OldSize = Main.Size
			Tween(Main, {Size = UDim2.new(0, OldSize.X.Offset, 0, 50)}, 0.4)
			Sidebar.Visible = false
			Content.Visible = false
			-- Mini Title
			local MT = Instance.new("TextLabel")
			MT.Name = "MT"
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
			if Main:FindFirstChild("MT") then Main.MT:Destroy() end
			Tween(Main, {Size = OldSize}, 0.4)
			task.wait(0.25)
			Sidebar.Visible = true
			Content.Visible = true
		end
	end)

	-- Page Holder
	local Pages = Instance.new("Frame")
	Pages.Name = "Pages"
	Pages.Size = UDim2.new(1, 0, 1, -50)
	Pages.Position = UDim2.new(0, 0, 0, 50)
	Pages.BackgroundTransparency = 1
	Pages.Parent = Content

	-- Dragging
	local Dragging, DragStart, StartPos
	Sidebar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true; DragStart = input.Position; StartPos = Main.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
			local delta = input.Position - DragStart
			Tween(Main, {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)}, 0.05)
		end
	end)
	
	-- Resizing
	local ResizeBtn = Instance.new("ImageButton")
	ResizeBtn.Size = UDim2.new(0, 20, 0, 20)
	ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
	ResizeBtn.BackgroundTransparency = 1
	ResizeBtn.Image = Icons.Resize
	ResizeBtn.ImageColor3 = Theme.TextDim
	ResizeBtn.ImageTransparency = 0.5
	ResizeBtn.Parent = Main
	
	local Resizing, ResizeStart, StartSize
	ResizeBtn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			Resizing = true; ResizeStart = i.Position; StartSize = Main.Size
			i.Changed:Connect(function() if i.UserInputState == Enum.UserInputState.End then Resizing = false end end)
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if Resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
			local d = i.Position - ResizeStart
			Tween(Main, {Size = UDim2.new(0, math.clamp(StartSize.X.Offset+d.X, 600, 1200), 0, math.clamp(StartSize.Y.Offset+d.Y, 400, 900))}, 0.05)
		end
	end)

	--// Tab System
	local Tabs = {}
	local FirstTab = true
	
	function Tabs:CreateTab(Name, Icon)
		-- Sidebar Button
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, -20, 0, 40)
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = ""
		TabBtn.Parent = TabContainer
		
		local TabCorner = Instance.new("UICorner")
		TabCorner.CornerRadius = UDim.new(0, 6)
		TabCorner.Parent = TabBtn
		
		local Ico = Instance.new("ImageLabel")
		Ico.Size = UDim2.new(0, 20, 0, 20)
		Ico.Position = UDim2.new(0, 12, 0.5, -10)
		Ico.BackgroundTransparency = 1
		Ico.Image = Icon or Icons.User
		Ico.ImageColor3 = Theme.TextDim
		Ico.Parent = TabBtn
		
		local Lbl = Instance.new("TextLabel")
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
		
		-- Page (The fix for "not appearing")
		local Page = Instance.new("ScrollingFrame")
		Page.Name = Name
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.BorderSizePixel = 0
		Page.ScrollBarThickness = 3
		Page.ScrollBarImageColor3 = Theme.Stroke
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Page.CanvasSize = UDim2.new(0,0,0,0) -- Crucial for auto sizing
		Page.Visible = false
		Page.Parent = Pages
		
		local PageList = Instance.new("UIListLayout")
		PageList.SortOrder = Enum.SortOrder.LayoutOrder
		PageList.Padding = UDim.new(0, 8)
		PageList.Parent = Page
		
		local PagePad = Instance.new("UIPadding")
		PagePad.PaddingTop = UDim.new(0, 15)
		PagePad.PaddingLeft = UDim.new(0, 20)
		PagePad.PaddingRight = UDim.new(0, 20)
		PagePad.PaddingBottom = UDim.new(0, 15)
		PagePad.Parent = Page
		
		local function Activate()
			for _, v in pairs(TabContainer:GetChildren()) do
				if v:IsA("TextButton") then
					Tween(v, {BackgroundTransparency = 1})
					Tween(v.TextLabel, {TextColor3 = Theme.TextDim})
					Tween(v.ImageLabel, {ImageColor3 = Theme.TextDim})
				end
			end
			local SBtn = SettingsArea:FindFirstChild("SettingsBtn")
			if SBtn then
				Tween(SBtn, {BackgroundTransparency = 1})
				Tween(SBtn.TextLabel, {TextColor3 = Theme.TextDim})
				Tween(SBtn.ImageLabel, {ImageColor3 = Theme.TextDim})
			end
			for _, v in pairs(Pages:GetChildren()) do v.Visible = false end
			
			Page.Visible = true
			Tween(TabBtn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0})
			Tween(Lbl, {TextColor3 = Theme.Text})
			Tween(Ico, {ImageColor3 = Theme.Accent})
		end
		
		TabBtn.MouseButton1Click:Connect(Activate)
		if FirstTab then FirstTab = false; Activate() end
		
		-- Elements
		local Elements = {}
		
		function Elements:CreateSection(Name)
			local Lab = Instance.new("TextLabel")
			Lab.Text = string.upper(Name)
			Lab.Size = UDim2.new(1, 0, 0, 26)
			Lab.BackgroundTransparency = 1
			Lab.TextColor3 = Theme.Accent
			Lab.Font = Enum.Font.GothamBold
			Lab.TextSize = 11
			Lab.TextXAlignment = Enum.TextXAlignment.Left
			Lab.Parent = Page
			local P = Instance.new("UIPadding"); P.PaddingTop = UDim.new(0, 8); P.Parent = Lab
		end
		
		function Elements:CreateButton(Config)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 0, 42)
			Btn.BackgroundColor3 = Theme.Element
			Btn.AutoButtonColor = false
			Btn.Text = ""
			Btn.Parent = Page
			Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
			Instance.new("UIStroke", Btn).Color = Theme.Stroke
			
			local L = Instance.new("TextLabel")
			L.Text = Config.Name
			L.Size = UDim2.new(1, -40, 1, 0)
			L.Position = UDim2.new(0, 15, 0, 0)
			L.BackgroundTransparency = 1
			L.TextColor3 = Theme.Text
			L.Font = Enum.Font.GothamSemibold
			L.TextSize = 13
			L.TextXAlignment = Enum.TextXAlignment.Left
			L.TextTruncate = Enum.TextTruncate.AtEnd
			L.Parent = Btn
			
			local Ico = Instance.new("ImageLabel")
			Ico.Size = UDim2.new(0, 20, 0, 20)
			Ico.Position = UDim2.new(1, -30, 0.5, -10)
			Ico.BackgroundTransparency = 1
			Ico.Image = "rbxassetid://10709791437" -- Pointer
			Ico.ImageColor3 = Theme.TextDim
			Ico.Parent = Btn
			
			Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Color3.fromRGB(38,38,41)}) end)
			Btn.MouseLeave:Connect(function() Tween(Btn, {BackgroundColor3 = Theme.Element}) end)
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
			Tog.AutoButtonColor = false
			Tog.Text = ""
			Tog.Parent = Page
			Instance.new("UICorner", Tog).CornerRadius = UDim.new(0, 6)
			Instance.new("UIStroke", Tog).Color = Theme.Stroke
			
			local L = Instance.new("TextLabel")
			L.Text = Config.Name
			L.Size = UDim2.new(1, -70, 1, 0)
			L.Position = UDim2.new(0, 15, 0, 0)
			L.BackgroundTransparency = 1
			L.TextColor3 = Theme.Text
			L.Font = Enum.Font.GothamSemibold
			L.TextSize = 13
			L.TextXAlignment = Enum.TextXAlignment.Left
			L.TextTruncate = Enum.TextTruncate.AtEnd
			L.Parent = Tog
			
			local Sw = Instance.new("Frame")
			Sw.Size = UDim2.new(0, 42, 0, 22)
			Sw.Position = UDim2.new(1, -55, 0.5, -11)
			Sw.BackgroundColor3 = State and Theme.Accent or Theme.Main
			Sw.Parent = Tog
			Instance.new("UICorner", Sw).CornerRadius = UDim.new(1, 0)
			
			local Dot = Instance.new("Frame")
			Dot.Size = UDim2.new(0, 18, 0, 18)
			Dot.Position = State and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
			Dot.BackgroundColor3 = Theme.Text
			Dot.Parent = Sw
			Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
			
			Tog.MouseButton1Click:Connect(function()
				State = not State
				Tween(Sw, {BackgroundColor3 = State and Theme.Accent or Theme.Main})
				Tween(Dot, {Position = State and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
				pcall(Config.Callback, State)
			end)
		end
		
		function Elements:CreateSlider(Config)
			local Min, Max = Config.Min, Config.Max
			local Val = Config.Default or Min
			
			local F = Instance.new("Frame")
			F.Size = UDim2.new(1, 0, 0, 52)
			F.BackgroundColor3 = Theme.Element
			F.Parent = Page
			Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)
			Instance.new("UIStroke", F).Color = Theme.Stroke
			
			local L = Instance.new("TextLabel")
			L.Text = Config.Name
			L.Size = UDim2.new(1, -60, 0, 20)
			L.Position = UDim2.new(0, 15, 0, 8)
			L.BackgroundTransparency = 1
			L.TextColor3 = Theme.Text
			L.Font = Enum.Font.GothamSemibold
			L.TextSize = 13
			L.TextXAlignment = Enum.TextXAlignment.Left
			L.Parent = F
			
			local V = Instance.new("TextLabel")
			V.Text = tostring(Val)
			V.Size = UDim2.new(0, 40, 0, 20)
			V.Position = UDim2.new(1, -55, 0, 8)
			V.BackgroundTransparency = 1
			V.TextColor3 = Theme.Accent
			V.Font = Enum.Font.GothamBold
			V.TextSize = 13
			V.TextXAlignment = Enum.TextXAlignment.Right
			V.Parent = F
			
			local Bar = Instance.new("TextButton")
			Bar.Text = ""
			Bar.Size = UDim2.new(1, -30, 0, 6)
			Bar.Position = UDim2.new(0, 15, 0, 35)
			Bar.BackgroundColor3 = Theme.Main
			Bar.AutoButtonColor = false
			Bar.Parent = F
			Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
			
			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new((Val - Min)/(Max - Min), 0, 1, 0)
			Fill.BackgroundColor3 = Theme.Accent
			Fill.BorderSizePixel = 0
			Fill.Parent = Bar
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
			
			local Dragging = false
			local function Update(i)
				local p = math.clamp((i.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				Tween(Fill, {Size = UDim2.new(p, 0, 1, 0)}, 0.1)
				local n = math.floor(Min + ((Max - Min) * p))
				V.Text = tostring(n)
				pcall(Config.Callback, n)
			end
			Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging=true; Update(i) end end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging=false end end)
			UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
		end
		
		return Elements
	end
	
	-- Global Keybind
	UserInputService.InputBegan:Connect(function(i, p)
		if not p and i.KeyCode == CurrentKeybind then ScreenGui.Enabled = not ScreenGui.Enabled end
	end)

	-- Manual Settings Page
	local SetPage = Instance.new("ScrollingFrame")
	SetPage.Name = "Settings"
	SetPage.Size = UDim2.new(1, 0, 1, 0)
	SetPage.BackgroundTransparency = 1
	SetPage.Visible = false
	SetPage.Parent = Pages
	local SL = Instance.new("UIListLayout"); SL.Padding = UDim.new(0, 8); SL.Parent = SetPage
	local SP = Instance.new("UIPadding"); SP.PaddingTop = UDim.new(0, 15); SP.PaddingLeft = UDim.new(0, 20); SP.PaddingRight = UDim.new(0, 20); SP.Parent = SetPage
	
	-- Helper for Settings elements
	local function MakeSetLabel(Txt) local L=Instance.new("TextLabel"); L.Text=string.upper(Txt); L.Size=UDim2.new(1,0,0,26); L.BackgroundTransparency=1; L.TextColor3=Theme.Accent; L.Font=Enum.Font.GothamBold; L.TextSize=11; L.TextXAlignment=Enum.TextXAlignment.Left; L.Parent=SetPage; local P=Instance.new("UIPadding"); P.PaddingTop=UDim.new(0,8); P.Parent=L end
	MakeSetLabel("Menu")
	
	-- Keybind Button
	local KF = Instance.new("Frame"); KF.Size=UDim2.new(1,0,0,42); KF.BackgroundColor3=Theme.Element; KF.Parent=SetPage; Instance.new("UICorner",KF).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",KF).Color=Theme.Stroke
	local KL = Instance.new("TextLabel"); KL.Text="Menu Keybind"; KL.Size=UDim2.new(1,-100,1,0); KL.Position=UDim2.new(0,15,0,0); KL.BackgroundTransparency=1; KL.TextColor3=Theme.Text; KL.Font=Enum.Font.GothamSemibold; KL.TextSize=13; KL.TextXAlignment=Enum.TextXAlignment.Left; KL.Parent=KF
	local KB = Instance.new("TextButton"); KB.Text="["..CurrentKeybind.Name.."]"; KB.Size=UDim2.new(0,100,0,26); KB.Position=UDim2.new(1,-110,0.5,-13); KB.BackgroundColor3=Theme.Main; KB.TextColor3=Theme.Accent; KB.Font=Enum.Font.GothamBold; KB.TextSize=12; KB.Parent=KF; Instance.new("UICorner",KB).CornerRadius=UDim.new(0,4)
	local listening=false; KB.MouseButton1Click:Connect(function() listening=true; KB.Text="..."; KB.TextColor3=Theme.Text end)
	UserInputService.InputBegan:Connect(function(i) if listening and i.UserInputType==Enum.UserInputType.Keyboard then CurrentKeybind=i.KeyCode; KB.Text="["..i.KeyCode.Name.."]"; KB.TextColor3=Theme.Accent; listening=false end end)
	
	-- Unload
	local UBtn = Instance.new("TextButton"); UBtn.Size=UDim2.new(1,0,0,42); UBtn.BackgroundColor3=Theme.Element; UBtn.Text=""; UBtn.Parent=SetPage; Instance.new("UICorner",UBtn).CornerRadius=UDim.new(0,6); Instance.new("UIStroke",UBtn).Color=Theme.Stroke
	local UL = Instance.new("TextLabel"); UL.Text="Unload Library"; UL.Size=UDim2.new(1,-20,1,0); UL.Position=UDim2.new(0,15,0,0); UL.BackgroundTransparency=1; UL.TextColor3=Color3.fromRGB(200,60,60); UL.Font=Enum.Font.GothamSemibold; UL.TextSize=13; UL.TextXAlignment=Enum.TextXAlignment.Left; UL.Parent=UBtn
	UBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	
	-- Sidebar Settings Button
	local SetBtn = Instance.new("TextButton")
	SetBtn.Name = "SettingsBtn"
	SetBtn.Size = UDim2.new(1, -20, 1, -5)
	SetBtn.Position = UDim2.new(0, 10, 0, 0)
	SetBtn.BackgroundTransparency = 1
	SetBtn.Text = ""
	SetBtn.Parent = SettingsArea
	
	local SCorn = Instance.new("UICorner"); SCorn.CornerRadius=UDim.new(0,6); SCorn.Parent=SetBtn
	local SIco = Instance.new("ImageLabel"); SIco.Size=UDim2.new(0,18,0,18); SIco.Position=UDim2.new(0,12,0.5,-9); SIco.BackgroundTransparency=1; SIco.Image=Icons.Settings; SIco.ImageColor3=Theme.TextDim; SIco.Parent=SetBtn
	local SLbl = Instance.new("TextLabel"); SLbl.Text="Settings"; SLbl.Size=UDim2.new(1,-50,1,0); SLbl.Position=UDim2.new(0,42,0,0); SLbl.BackgroundTransparency=1; SLbl.TextColor3=Theme.TextDim; SLbl.Font=Enum.Font.GothamMedium; SLbl.TextSize=14; SLbl.TextXAlignment=Enum.TextXAlignment.Left; SLbl.Parent=SetBtn
	
	SetBtn.MouseButton1Click:Connect(function()
		for _,v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then Tween(v,{BackgroundTransparency=1}); Tween(v.TextLabel,{TextColor3=Theme.TextDim}); Tween(v.ImageLabel,{ImageColor3=Theme.TextDim}) end end
		for _,v in pairs(Pages:GetChildren()) do v.Visible=false end
		SetPage.Visible=true
		Tween(SetBtn,{BackgroundColor3=Theme.Element, BackgroundTransparency=0})
		Tween(SLbl,{TextColor3=Theme.Text})
		Tween(SIco,{ImageColor3=Theme.Accent})
	end)
	
	return Tabs
end

return ChuddyLib
