--[[
    CHUDDY HUB | ULTIMATE EDITION [REFACTORED]
    Fixed Dropdowns, Enhanced Player Tab, Organized Configs, Proper Minimizing
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ChuddyLib = {}
local ActiveConnections = {}

--// Theme Configuration
local Theme = {
	Name = "Default",
	Main = Color3.fromRGB(20, 20, 20),
	Sidebar = Color3.fromRGB(25, 25, 25),
	Content = Color3.fromRGB(20, 20, 20),
	Element = Color3.fromRGB(30, 30, 30),
	ElementHover = Color3.fromRGB(40, 40, 40),
	Header = Color3.fromRGB(30, 30, 30),
	Text = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(150, 150, 150),
	Accent = Color3.fromRGB(114, 137, 218),
	Stroke = Color3.fromRGB(50, 50, 50),
	Divider = Color3.fromRGB(40, 40, 40),
	Red = Color3.fromRGB(255, 80, 80)
}

local Icons = {
	Logo = "rbxassetid://134140528282189", -- Chuddy Icon
	Home = "rbxassetid://10723415903",
	User = "rbxassetid://10723345518", -- Person Icon
	Settings = "rbxassetid://10723415903",
	Search = "rbxassetid://10723426249",
	Close = "rbxassetid://10723396659", -- Clean X
	Min = "rbxassetid://10723403313",   -- Clean Minus
	Max = "rbxassetid://10723398939",   -- Square
	Edit = "rbxassetid://10723343371",
	Arrow = "rbxassetid://10709790948",
	Check = "rbxassetid://10709790644"
}

--// Utility Functions
local function GetParent()
	local success, result = pcall(function() return gethui() end)
	if success and result then return result end
	if CoreGui:FindFirstChild("RobloxGui") then return CoreGui:FindFirstChild("RobloxGui") end
	return CoreGui
end

local function Tween(obj, props, time)
	local info = TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	TweenService:Create(obj, info, props):Play()
end

local function CreateStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Theme.Stroke
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

local function CreateCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = parent
	return corner
end

--// Config System
local ConfigFolder = "ChuddyConfigs"
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

local function SaveConfig(name, data)
	writefile(ConfigFolder .. "/" .. name .. ".json", HttpService:JSONEncode(data))
end

local function LoadConfig(name)
	local path = ConfigFolder .. "/" .. name .. ".json"
	if isfile(path) then
		return HttpService:JSONDecode(readfile(path))
	end
	return nil
end

local function GetConfigList()
	local list = {}
	for _, file in ipairs(listfiles(ConfigFolder)) do
		if file:sub(-5) == ".json" then
			table.insert(list, file:sub(#ConfigFolder + 2, -6))
		end
	end
	return list
end

--// Main Window Creation
function ChuddyLib:CreateWindow(Settings)
	local WindowName = Settings.Name or "Chuddy Hub"
	local ToggleKey = Settings.Keybind or Enum.KeyCode.RightControl
	
	-- Cleanup Old UI
	for _, ui in pairs(GetParent():GetChildren()) do
		if ui.Name == "ChuddyUI" then ui:Destroy() end
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ChuddyUI"
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = GetParent()
	ScreenGui.ResetOnSpawn = false

	-- State Variables
	local Minimized = false
	local OldSize = UDim2.new(0, 750, 0, 500)
	local Hovering = false

	-- Main Frame
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 750, 0, 500)
	Main.Position = UDim2.new(0.5, -375, 0.5, -250)
	Main.BackgroundColor3 = Theme.Main
	Main.ClipsDescendants = true -- Important for rounding
	Main.Parent = ScreenGui

	CreateCorner(Main, 8)
	CreateStroke(Main, Theme.Stroke, 1)

	-- Sidebar
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 200, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main

	local SidebarLine = Instance.new("Frame")
	SidebarLine.Name = "Line"
	SidebarLine.Size = UDim2.new(0, 1, 1, 0)
	SidebarLine.Position = UDim2.new(1, -1, 0, 0)
	SidebarLine.BackgroundColor3 = Theme.Divider
	SidebarLine.BorderSizePixel = 0
	SidebarLine.Parent = Sidebar

	-- Header (Icon + Title)
	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 60)
	Header.BackgroundTransparency = 1
	Header.Parent = Sidebar

	local Logo = Instance.new("ImageLabel")
	Logo.Size = UDim2.new(0, 28, 0, 28)
	Logo.Position = UDim2.new(0, 14, 0.5, -14)
	Logo.Image = Icons.Logo
	Logo.BackgroundTransparency = 1
	Logo.Parent = Header
	CreateCorner(Logo, 6)

	local Title = Instance.new("TextLabel")
	Title.Text = WindowName
	Title.Size = UDim2.new(1, -55, 1, 0)
	Title.Position = UDim2.new(0, 50, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Header

	-- Tab Container
	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(1, 0, 1, -110) -- Reserve space for Settings/Profile
	TabContainer.Position = UDim2.new(0, 0, 0, 60)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 2
	TabContainer.ScrollBarImageColor3 = Theme.Accent
	TabContainer.Parent = Sidebar

	local TabListLayout = Instance.new("UIListLayout")
	TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabListLayout.Padding = UDim.new(0, 4)
	TabListLayout.Parent = TabContainer

	local TabPadding = Instance.new("UIPadding")
	TabPadding.PaddingTop = UDim.new(0, 10)
	TabPadding.PaddingLeft = UDim.new(0, 10)
	TabPadding.PaddingRight = UDim.new(0, 10)
	TabPadding.Parent = TabContainer

	-- Profile Section (Bottom)
	local Profile = Instance.new("Frame")
	Profile.Name = "Profile"
	Profile.Size = UDim2.new(1, 0, 0, 60)
	Profile.Position = UDim2.new(0, 0, 1, -60)
	Profile.BackgroundTransparency = 1
	Profile.Parent = Sidebar

	local ProfileLine = Instance.new("Frame")
	ProfileLine.Size = UDim2.new(1, -20, 0, 1)
	ProfileLine.Position = UDim2.new(0, 10, 0, 0)
	ProfileLine.BackgroundColor3 = Theme.Divider
	ProfileLine.BorderSizePixel = 0
	ProfileLine.Parent = Profile

	local Avatar = Instance.new("ImageLabel")
	Avatar.Size = UDim2.new(0, 36, 0, 36)
	Avatar.Position = UDim2.new(0, 12, 0.5, -18)
	Avatar.BackgroundColor3 = Theme.Element
	Avatar.Parent = Profile
	CreateCorner(Avatar, 18) -- Circle

	task.spawn(function()
		local content = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		Avatar.Image = content
	end)

	local Username = Instance.new("TextLabel")
	Username.Text = LocalPlayer.Name
	Username.Size = UDim2.new(1, -60, 0, 20)
	Username.Position = UDim2.new(0, 58, 0.5, -10)
	Username.Font = Enum.Font.GothamBold
	Username.TextColor3 = Theme.Text
	Username.TextSize = 13
	Username.BackgroundTransparency = 1
	Username.TextXAlignment = Enum.TextXAlignment.Left
	Username.Parent = Profile

	local Rank = Instance.new("TextLabel")
	Rank.Text = "Premium User"
	Rank.Size = UDim2.new(1, -60, 0, 16)
	Rank.Position = UDim2.new(0, 58, 0.5, 4)
	Rank.Font = Enum.Font.Gotham
	Rank.TextColor3 = Theme.Accent
	Rank.TextSize = 11
	Rank.BackgroundTransparency = 1
	Rank.TextXAlignment = Enum.TextXAlignment.Left
	Rank.Parent = Profile

	-- Content Area
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Size = UDim2.new(1, -200, 1, 0)
	Content.Position = UDim2.new(0, 200, 0, 0)
	Content.BackgroundTransparency = 1
	Content.ClipsDescendants = true
	Content.Parent = Main

	-- Top Bar (Drag, Title, Controls)
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, 50)
	TopBar.BackgroundTransparency = 1
	TopBar.Parent = Content

	local TopBarLine = Instance.new("Frame")
	TopBarLine.Size = UDim2.new(1, 0, 0, 1)
	TopBarLine.Position = UDim2.new(0, 0, 1, -1)
	TopBarLine.BackgroundColor3 = Theme.Divider
	TopBarLine.BorderSizePixel = 0
	TopBarLine.Parent = TopBar

	local PageTitle = Instance.new("TextLabel")
	PageTitle.Text = "Home"
	PageTitle.Font = Enum.Font.GothamBold
	PageTitle.TextSize = 18
	PageTitle.TextColor3 = Theme.Text
	PageTitle.BackgroundTransparency = 1
	PageTitle.Size = UDim2.new(0, 200, 1, 0)
	PageTitle.Position = UDim2.new(0, 20, 0, 0)
	PageTitle.TextXAlignment = Enum.TextXAlignment.Left
	PageTitle.Parent = TopBar

	-- Window Controls
	local Controls = Instance.new("Frame")
	Controls.Size = UDim2.new(0, 100, 1, 0)
	Controls.Position = UDim2.new(1, -100, 0, 0)
	Controls.BackgroundTransparency = 1
	Controls.Parent = TopBar

	local function CreateControlBtn(icon, name, callback)
		local Btn = Instance.new("ImageButton")
		Btn.Name = name
		Btn.Size = UDim2.new(0, 40, 0, 40)
		Btn.AnchorPoint = Vector2.new(0, 0.5)
		Btn.BackgroundTransparency = 1
		Btn.Image = icon
		Btn.ImageColor3 = Theme.TextDim
		Btn.Parent = Controls
		
		-- Layout based on name
		if name == "Close" then Btn.Position = UDim2.new(1, -45, 0.5, 0) end
		if name == "MinMax" then Btn.Position = UDim2.new(1, -85, 0.5, 0) end

		local Pad = Instance.new("UIPadding")
		Pad.PaddingBottom = UDim.new(0, 10)
		Pad.PaddingTop = UDim.new(0, 10)
		Pad.PaddingLeft = UDim.new(0, 10)
		Pad.PaddingRight = UDim.new(0, 10)
		Pad.Parent = Btn

		Btn.MouseEnter:Connect(function() Tween(Btn, {ImageColor3 = Theme.Text}) end)
		Btn.MouseLeave:Connect(function() Tween(Btn, {ImageColor3 = Theme.TextDim}) end)
		Btn.MouseButton1Click:Connect(callback)
		return Btn
	end

	local CloseBtn = CreateControlBtn(Icons.Close, "Close", function() ScreenGui:Destroy() end)
	
	local MinMaxBtn = CreateControlBtn(Icons.Min, "MinMax", function()
		Minimized = not Minimized
		if Minimized then
			OldSize = Main.Size
			-- Shrink to bar height, keep width
			Tween(Main, {Size = UDim2.new(0, Main.AbsoluteSize.X, 0, 50)})
			Sidebar.Visible = false
			Content.Position = UDim2.new(0,0,0,0) -- Move content to left
			Content.Size = UDim2.new(1,0,1,0)
			-- Hide pages, keep topbar
			local Pages = Content:FindFirstChild("Pages")
			if Pages then Pages.Visible = false end
			MinMaxBtn.Image = Icons.Max
		else
			Tween(Main, {Size = OldSize})
			task.wait(0.2)
			Sidebar.Visible = true
			Content.Position = UDim2.new(0, 200, 0, 0)
			Content.Size = UDim2.new(1, -200, 1, 0)
			local Pages = Content:FindFirstChild("Pages")
			if Pages then Pages.Visible = true end
			MinMaxBtn.Image = Icons.Min
		end
	end)

	-- Page Holder
	local Pages = Instance.new("Frame")
	Pages.Name = "Pages"
	Pages.Size = UDim2.new(1, 0, 1, -50)
	Pages.Position = UDim2.new(0, 0, 0, 50)
	Pages.BackgroundTransparency = 1
	Pages.Parent = Content

	-- Dragging Logic
	local Dragging, DragInput, DragStart, StartPos
	
	local function UpdateDrag(input)
		local delta = input.Position - DragStart
		Tween(Main, {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)}, 0.05)
	end

	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			DragStart = input.Position
			StartPos = Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then Dragging = false end
			end)
		end
	end)
	
	TopBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then UpdateDrag(input) end
	end)

	-- Resizing Logic
	local ResizeBtn = Instance.new("ImageButton")
	ResizeBtn.Size = UDim2.new(0, 20, 0, 20)
	ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
	ResizeBtn.BackgroundTransparency = 1
	ResizeBtn.Image = Icons.Arrow -- Reuse arrow or logo
	ResizeBtn.ImageTransparency = 0.5
	ResizeBtn.ImageColor3 = Theme.TextDim
	ResizeBtn.Rotation = -45
	ResizeBtn.Parent = Main

	local Resizing, ResizeStart, StartSize
	ResizeBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Resizing = true
			ResizeStart = input.Position
			StartSize = Main.Size
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then Resizing = false end end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if Resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - ResizeStart
			local newW = math.max(600, StartSize.X.Offset + delta.X)
			local newH = math.max(400, StartSize.Y.Offset + delta.Y)
			Tween(Main, {Size = UDim2.new(0, newW, 0, newH)}, 0.05)
		end
	end)

	--// Tab System
	local Tabs = {}
	local FirstTab = true

	function Tabs:CreateTab(Name, IconId)
		local Tab = {}
		
		-- Sidebar Button
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, 0, 0, 40)
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = ""
		TabBtn.Parent = TabContainer
		
		CreateCorner(TabBtn, 6)
		
		local TabIcon = Instance.new("ImageLabel")
		TabIcon.Size = UDim2.new(0, 20, 0, 20)
		TabIcon.Position = UDim2.new(0, 10, 0.5, -10)
		TabIcon.Image = IconId or Icons.Home
		TabIcon.ImageColor3 = Theme.TextDim
		TabIcon.BackgroundTransparency = 1
		TabIcon.Parent = TabBtn
		
		local TabLabel = Instance.new("TextLabel")
		TabLabel.Text = Name
		TabLabel.Size = UDim2.new(1, -45, 1, 0)
		TabLabel.Position = UDim2.new(0, 40, 0, 0)
		TabLabel.BackgroundTransparency = 1
		TabLabel.TextColor3 = Theme.TextDim
		TabLabel.Font = Enum.Font.GothamMedium
		TabLabel.TextSize = 13
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left
		TabLabel.Parent = TabBtn
		
		-- Page Frame
		local Page = Instance.new("ScrollingFrame")
		Page.Name = Name .. "Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.BorderSizePixel = 0
		Page.ScrollBarThickness = 3
		Page.ScrollBarImageColor3 = Theme.Accent
		Page.Visible = false
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Page.CanvasSize = UDim2.new(0,0,0,0)
		Page.Parent = Pages
		
		local PageLayout = Instance.new("UIListLayout")
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 10)
		PageLayout.Parent = Page
		
		local PagePadding = Instance.new("UIPadding")
		PagePadding.PaddingTop = UDim.new(0, 20)
		PagePadding.PaddingLeft = UDim.new(0, 20)
		PagePadding.PaddingRight = UDim.new(0, 20)
		PagePadding.PaddingBottom = UDim.new(0, 20)
		PagePadding.Parent = Page
		
		local function Activate()
			-- Deactivate others
			for _, v in pairs(TabContainer:GetChildren()) do
				if v:IsA("TextButton") then
					Tween(v, {BackgroundTransparency = 1, BackgroundColor3 = Theme.Sidebar})
					Tween(v:FindFirstChildOfClass("TextLabel"), {TextColor3 = Theme.TextDim})
					Tween(v:FindFirstChildOfClass("ImageLabel"), {ImageColor3 = Theme.TextDim})
				end
			end
			-- Deactivate settings/player logic if needed
			for _, v in pairs(Pages:GetChildren()) do v.Visible = false end
			
			-- Activate
			Page.Visible = true
			Tween(TabBtn, {BackgroundTransparency = 0, BackgroundColor3 = Theme.Element})
			Tween(TabLabel, {TextColor3 = Theme.Text})
			Tween(TabIcon, {ImageColor3 = Theme.Accent})
			PageTitle.Text = Name
		end
		
		TabBtn.MouseButton1Click:Connect(Activate)
		if FirstTab then FirstTab = false; Activate() end
		
		--// Elements
		function Tab:CreateSection(Text)
			local Section = Instance.new("TextLabel")
			Section.Text = string.upper(Text)
			Section.Size = UDim2.new(1, 0, 0, 20)
			Section.BackgroundTransparency = 1
			Section.TextColor3 = Theme.Accent
			Section.Font = Enum.Font.GothamBold
			Section.TextSize = 11
			Section.TextXAlignment = Enum.TextXAlignment.Left
			Section.Parent = Page
		end
		
		function Tab:CreateButton(Config)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 0, 42)
			Btn.BackgroundColor3 = Theme.Element
			Btn.Text = ""
			Btn.AutoButtonColor = false
			Btn.Parent = Page
			CreateCorner(Btn, 6)
			CreateStroke(Btn, Theme.Stroke)
			
			local Title = Instance.new("TextLabel")
			Title.Text = Config.Name
			Title.Size = UDim2.new(1, -20, 1, 0)
			Title.Position = UDim2.new(0, 15, 0, 0)
			Title.BackgroundTransparency = 1
			Title.TextColor3 = Theme.Text
			Title.Font = Enum.Font.GothamSemibold
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.Parent = Btn
			
			local Icon = Instance.new("ImageLabel")
			Icon.Size = UDim2.new(0, 18, 0, 18)
			Icon.Position = UDim2.new(1, -30, 0.5, -9)
			Icon.BackgroundTransparency = 1
			Icon.Image = Icons.Arrow
			Icon.ImageColor3 = Theme.TextDim
			Icon.Parent = Btn
			
			Btn.MouseButton1Click:Connect(function()
				Tween(Btn, {BackgroundColor3 = Theme.Stroke}, 0.1)
				task.wait(0.1)
				Tween(Btn, {BackgroundColor3 = Theme.Element})
				if Config.Callback then pcall(Config.Callback) end
			end)
		end
		
		function Tab:CreateToggle(Config)
			local Toggled = Config.Default or false
			
			local Tog = Instance.new("TextButton")
			Tog.Size = UDim2.new(1, 0, 0, 42)
			Tog.BackgroundColor3 = Theme.Element
			Tog.Text = ""
			Tog.AutoButtonColor = false
			Tog.Parent = Page
			CreateCorner(Tog, 6)
			CreateStroke(Tog, Theme.Stroke)
			
			local Title = Instance.new("TextLabel")
			Title.Text = Config.Name
			Title.Size = UDim2.new(1, -60, 1, 0)
			Title.Position = UDim2.new(0, 15, 0, 0)
			Title.BackgroundTransparency = 1
			Title.TextColor3 = Theme.Text
			Title.Font = Enum.Font.GothamSemibold
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.Parent = Tog
			
			local Switch = Instance.new("Frame")
			Switch.Size = UDim2.new(0, 40, 0, 20)
			Switch.Position = UDim2.new(1, -55, 0.5, -10)
			Switch.BackgroundColor3 = Toggled and Theme.Accent or Theme.Main
			Switch.Parent = Tog
			CreateCorner(Switch, 10)
			
			local Dot = Instance.new("Frame")
			Dot.Size = UDim2.new(0, 16, 0, 16)
			Dot.Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
			Dot.BackgroundColor3 = Theme.Text
			Dot.Parent = Switch
			CreateCorner(Dot, 8)
			
			local function Update()
				Toggled = not Toggled
				Tween(Switch, {BackgroundColor3 = Toggled and Theme.Accent or Theme.Main})
				Tween(Dot, {Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
				if Config.Callback then pcall(Config.Callback, Toggled) end
			end
			
			Tog.MouseButton1Click:Connect(Update)
		end
		
		function Tab:CreateSlider(Config)
			local Min, Max = Config.Min, Config.Max
			local Val = Config.Default or Min
			
			local SlideFrame = Instance.new("Frame")
			SlideFrame.Size = UDim2.new(1, 0, 0, 60)
			SlideFrame.BackgroundColor3 = Theme.Element
			SlideFrame.Parent = Page
			CreateCorner(SlideFrame, 6)
			CreateStroke(SlideFrame, Theme.Stroke)
			
			local Title = Instance.new("TextLabel")
			Title.Text = Config.Name
			Title.Size = UDim2.new(1, -20, 0, 20)
			Title.Position = UDim2.new(0, 15, 0, 10)
			Title.BackgroundTransparency = 1
			Title.TextColor3 = Theme.Text
			Title.Font = Enum.Font.GothamSemibold
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.Parent = SlideFrame
			
			local ValText = Instance.new("TextLabel")
			ValText.Text = tostring(Val)
			ValText.Size = UDim2.new(0, 50, 0, 20)
			ValText.Position = UDim2.new(1, -65, 0, 10)
			ValText.BackgroundTransparency = 1
			ValText.TextColor3 = Theme.Accent
			ValText.Font = Enum.Font.GothamBold
			ValText.TextSize = 13
			ValText.TextXAlignment = Enum.TextXAlignment.Right
			ValText.Parent = SlideFrame
			
			local Bar = Instance.new("TextButton")
			Bar.Size = UDim2.new(1, -30, 0, 6)
			Bar.Position = UDim2.new(0, 15, 0, 40)
			Bar.BackgroundColor3 = Theme.Main
			Bar.Text = ""
			Bar.AutoButtonColor = false
			Bar.Parent = SlideFrame
			CreateCorner(Bar, 3)
			
			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new((Val - Min) / (Max - Min), 0, 1, 0)
			Fill.BackgroundColor3 = Theme.Accent
			Fill.BorderSizePixel = 0
			Fill.Parent = Bar
			CreateCorner(Fill, 3)
			
			local Dragging = false
			
			local function Update(input)
				local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
				Tween(Fill, {Size = UDim2.new(pos, 0, 1, 0)}, 0.1)
				local newVal = math.floor(Min + ((Max - Min) * pos))
				ValText.Text = tostring(newVal)
				pcall(Config.Callback, newVal)
			end
			
			Bar.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = true
					Update(i)
				end
			end)
			
			UserInputService.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
			end)
			
			UserInputService.InputChanged:Connect(function(i)
				if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end
			end)
		end
		
		function Tab:CreateDropdown(Config)
			local Expanded = false
			local Options = Config.Options or {}
			local Current = Config.Default or Options[1] or "None"
			
			local Container = Instance.new("Frame")
			Container.Size = UDim2.new(1, 0, 0, 42)
			Container.BackgroundColor3 = Theme.Element
			Container.ClipsDescendants = true
			Container.Parent = Page
			CreateCorner(Container, 6)
			CreateStroke(Container, Theme.Stroke)
			
			local Title = Instance.new("TextLabel")
			Title.Text = Config.Name
			Title.Size = UDim2.new(1, -120, 0, 42)
			Title.Position = UDim2.new(0, 15, 0, 0)
			Title.BackgroundTransparency = 1
			Title.TextColor3 = Theme.Text
			Title.Font = Enum.Font.GothamSemibold
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.Parent = Container
			
			local Display = Instance.new("TextLabel")
			Display.Text = Current
			Display.Size = UDim2.new(0, 100, 0, 42)
			Display.Position = UDim2.new(1, -135, 0, 0)
			Display.BackgroundTransparency = 1
			Display.TextColor3 = Theme.Accent
			Display.Font = Enum.Font.GothamBold
			Display.TextSize = 13
			Display.TextXAlignment = Enum.TextXAlignment.Right
			Display.Parent = Container
			
			local Arrow = Instance.new("ImageLabel")
			Arrow.Size = UDim2.new(0, 20, 0, 20)
			Arrow.Position = UDim2.new(1, -30, 0, 11)
			Arrow.BackgroundTransparency = 1
			Arrow.Image = Icons.Arrow
			Arrow.ImageColor3 = Theme.TextDim
			Arrow.Parent = Container
			
			local List = Instance.new("Frame")
			List.Size = UDim2.new(1, -20, 0, 0) -- Auto size via script
			List.Position = UDim2.new(0, 10, 0, 42)
			List.BackgroundTransparency = 1
			List.Parent = Container
			
			local ListLayout = Instance.new("UIListLayout")
			ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ListLayout.Padding = UDim.new(0, 4)
			ListLayout.Parent = List
			
			local function RefreshOptions()
				for _, v in pairs(List:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
				
				for _, opt in ipairs(Options) do
					local Item = Instance.new("TextButton")
					Item.Size = UDim2.new(1, 0, 0, 30)
					Item.BackgroundColor3 = Theme.Main
					Item.Text = "  " .. opt
					Item.TextColor3 = Theme.TextDim
					Item.Font = Enum.Font.Gotham
					Item.TextSize = 12
					Item.TextXAlignment = Enum.TextXAlignment.Left
					Item.AutoButtonColor = false
					Item.Parent = List
					CreateCorner(Item, 4)
					
					Item.MouseButton1Click:Connect(function()
						Current = opt
						Display.Text = Current
						pcall(Config.Callback, Current)
						-- Close
						Expanded = false
						Tween(Container, {Size = UDim2.new(1, 0, 0, 42)})
						Tween(Arrow, {Rotation = 0})
					end)
				end
			end
			
			RefreshOptions()
			
			local Trigger = Instance.new("TextButton")
			Trigger.Size = UDim2.new(1, 0, 0, 42)
			Trigger.BackgroundTransparency = 1
			Trigger.Text = ""
			Trigger.Parent = Container
			
			Trigger.MouseButton1Click:Connect(function()
				Expanded = not Expanded
				if Expanded then
					local Count = #Options
					Tween(Container, {Size = UDim2.new(1, 0, 0, 42 + (Count * 34) + 10)})
					Tween(Arrow, {Rotation = 180})
				else
					Tween(Container, {Size = UDim2.new(1, 0, 0, 42)})
					Tween(Arrow, {Rotation = 0})
				end
			end)
		end
		
		function Tab:CreateInput(Config)
			local InputFrame = Instance.new("Frame")
			InputFrame.Size = UDim2.new(1, 0, 0, 42)
			InputFrame.BackgroundColor3 = Theme.Element
			InputFrame.Parent = Page
			CreateCorner(InputFrame, 6)
			CreateStroke(InputFrame, Theme.Stroke)
			
			local Title = Instance.new("TextLabel")
			Title.Text = Config.Name
			Title.Size = UDim2.new(1, -150, 1, 0)
			Title.Position = UDim2.new(0, 15, 0, 0)
			Title.BackgroundTransparency = 1
			Title.TextColor3 = Theme.Text
			Title.Font = Enum.Font.GothamSemibold
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.Parent = InputFrame
			
			local Box = Instance.new("TextBox")
			Box.PlaceholderText = Config.Placeholder or "Enter text..."
			Box.Text = ""
			Box.Size = UDim2.new(0, 120, 0, 24)
			Box.Position = UDim2.new(1, -135, 0.5, -12)
			Box.BackgroundColor3 = Theme.Main
			Box.TextColor3 = Theme.Text
			Box.Font = Enum.Font.Gotham
			Box.TextSize = 12
			Box.Parent = InputFrame
			CreateCorner(Box, 4)
			
			Box.FocusLost:Connect(function(enter)
				if enter then
					pcall(Config.Callback, Box.Text)
				end
			end)
		end

		return Tab
	end

	--// Setup Sidebar Buttons (Config & Settings)
	local function CreateSidebarBtn(name, icon, order, callback)
		local Btn = Instance.new("TextButton")
		Btn.Name = name .. "Btn"
		Btn.Size = UDim2.new(1, -20, 0, 40)
		Btn.Position = UDim2.new(0, 10, 0, (order * 45))
		Btn.BackgroundColor3 = Theme.Sidebar
		Btn.BackgroundTransparency = 1
		Btn.Text = ""
		Btn.Parent = Sidebar:FindFirstChild("TabContainer") -- Actually, we want this pinned.
		-- Moving to fixed "SettingsArea" defined earlier? No, user wanted dedicated sections.
		-- Let's put these in the Settings Tab, but add a shortcut.
	end

	--// Creating Built-in Tabs
	
	-- 1. Player Tab (Enhanced)
	if Settings.PlayerTab ~= false then
		local Player = Tabs:CreateTab("Player", Icons.User)
		
		Player:CreateSection("Movement Modification")
		
		local SpeedMethod = "Velocity"
		Player:CreateDropdown({
			Name = "WalkSpeed Method",
			Options = {"Velocity", "CFrame", "Standard"},
			Default = "Standard",
			Callback = function(v) SpeedMethod = v end
		})
		
		Player:CreateToggle({
			Name = "Enable WalkSpeed",
			Callback = function(v)
				-- Loop logic here
				getgenv().WS_Enabled = v
				while getgenv().WS_Enabled do
					task.wait()
					if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
						if SpeedMethod == "Standard" then
							LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().WS_Val or 16
						end
					end
				end
			end
		})
		
		Player:CreateSlider({
			Name = "WalkSpeed Value",
			Min = 16, Max = 500, Default = 16,
			Callback = function(v) getgenv().WS_Val = v end
		})
		
		Player:CreateSection("Utilities")
		
		Player:CreateButton({
			Name = "Invisible Fling (Risky)",
			Callback = function()
				-- Basic Fling Logic
				local Char = LocalPlayer.Character
				if Char and Char:FindFirstChild("HumanoidRootPart") then
					local Root = Char.HumanoidRootPart
					local BV = Instance.new("BodyAngularVelocity")
					BV.AngularVelocity = Vector3.new(0, 99999, 0)
					BV.MaxTorque = Vector3.new(0, math.huge, 0)
					BV.P = math.huge
					BV.Parent = Root
					-- Cleanup needed, simplistic example
				end
			end
		})
		
		Player:CreateButton({
			Name = "NoClip (Toggle with N)",
			Callback = function()
				local noclip = false
				game:GetService("RunService").Stepped:Connect(function()
					if noclip then
						for _, v in pairs(LocalPlayer.Character:GetChildren()) do
							if v:IsA("BasePart") then v.CanCollide = false end
						end
					end
				end)
				UserInputService.InputBegan:Connect(function(input)
					if input.KeyCode == Enum.KeyCode.N then noclip = not noclip end
				end)
			end
		})
	end

	-- 2. Settings / Config Tab
	local SettingsTab = Tabs:CreateTab("Settings", Icons.Settings)
	
	SettingsTab:CreateSection("Configuration Manager")
	
	local SelectedConfig = "None"
	SettingsTab:CreateDropdown({
		Name = "Select Config",
		Options = GetConfigList(),
		Callback = function(v) SelectedConfig = v end
	})
	
	SettingsTab:CreateInput({
		Name = "New Config Name",
		Placeholder = "Type name...",
		Callback = function(t) SelectedConfig = t end
	})
	
	SettingsTab:CreateButton({
		Name = "Save Config",
		Callback = function()
			if SelectedConfig ~= "None" then
				SaveConfig(SelectedConfig, {Keybind = ToggleKey.Name}) -- Save example data
			end
		end
	})
	
	SettingsTab:CreateButton({
		Name = "Load Config",
		Callback = function()
			if SelectedConfig ~= "None" then
				local data = LoadConfig(SelectedConfig)
				print("Loaded config:", SelectedConfig)
			end
		end
	})
	
	SettingsTab:CreateSection("UI Settings")
	
	SettingsTab:CreateButton({
		Name = "Unload Library",
		Callback = function() ScreenGui:Destroy() end
	})

	-- Global Keybind
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == ToggleKey then
			ScreenGui.Enabled = not ScreenGui.Enabled
		end
	end)

	return Tabs
end

return ChuddyLib
