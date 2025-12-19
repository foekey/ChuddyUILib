--[[ 
    CHUDDY HUB | PHANTASM EDIT
    Fully animated, Resizable, Profile integrated.
]]

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local ChuddyLib = {}

--// Theme Configuration
local Theme = {
	Main = Color3.fromRGB(18, 18, 18),
	Sidebar = Color3.fromRGB(25, 25, 25),
	Header = Color3.fromRGB(30, 30, 30),
	Element = Color3.fromRGB(32, 32, 32),
	Text = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(160, 160, 160),
	Accent = Color3.fromRGB(120, 80, 220), -- Phantasm Purple
	Stroke = Color3.fromRGB(55, 55, 55)
}

--// Icons (Lucide / RBX Assets)
local Icons = {
	User = "rbxassetid://10723415903", -- Gear/User placeholder
	Resize = "rbxassetid://134140528282189",
	Close = "rbxassetid://3926305904",
	Min = "rbxassetid://3926307971"
}

--// Helper Functions
local function GetParent()
	local Success, Result = pcall(function() return gethui() end)
	if Success and Result then return Result end
	if game:GetService("CoreGui"):FindFirstChild("RobloxGui") then return game:GetService("CoreGui") end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local function Tween(obj, props, time)
	TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

--// Main Window
function ChuddyLib:CreateWindow(Settings)
	local WindowName = Settings.Name or "Chuddy Hub"
	local CurrentKeybind = Settings.Keybind or Enum.KeyCode.RightControl
	local UI_Connections = {}
	
	-- 1. ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ChuddyPhantasm"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = GetParent()
	
	-- 2. Main Frame (Draggable & Resizable)
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 650, 0, 400)
	Main.Position = UDim2.new(0.5, -325, 0.5, -200)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui
	
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Theme.Stroke
	MainStroke.Thickness = 1
	MainStroke.Parent = Main
	
	-- 3. Sidebar (Left)
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 180, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main
	
	local SidebarDiv = Instance.new("Frame")
	SidebarDiv.Size = UDim2.new(0, 1, 1, 0)
	SidebarDiv.Position = UDim2.new(1, -1, 0, 0)
	SidebarDiv.BackgroundColor3 = Theme.Stroke
	SidebarDiv.BorderSizePixel = 0
	SidebarDiv.Parent = Sidebar
	
	-- Library Title
	local Title = Instance.new("TextLabel")
	Title.Text = WindowName
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 16
	Title.TextColor3 = Theme.Text
	Title.Size = UDim2.new(1, -20, 0, 50)
	Title.Position = UDim2.new(0, 15, 0, 0)
	Title.BackgroundTransparency = 1
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Sidebar
	
	-- Tab Container
	local TabHolder = Instance.new("ScrollingFrame")
	TabHolder.Name = "Tabs"
	TabHolder.Size = UDim2.new(1, 0, 1, -110) -- Space for header & user profile
	TabHolder.Position = UDim2.new(0, 0, 0, 50)
	TabHolder.BackgroundTransparency = 1
	TabHolder.ScrollBarThickness = 0
	TabHolder.Parent = Sidebar
	
	local TabList = Instance.new("UIListLayout")
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0, 4)
	TabList.Parent = TabHolder
	
	-- User Profile (Bottom Left)
	local UserProfile = Instance.new("Frame")
	UserProfile.Name = "UserProfile"
	UserProfile.Size = UDim2.new(1, 0, 0, 60)
	UserProfile.Position = UDim2.new(0, 0, 1, -60)
	UserProfile.BackgroundColor3 = Theme.Sidebar
	UserProfile.BorderSizePixel = 0
	UserProfile.Parent = Sidebar
	
	local UserDiv = Instance.new("Frame")
	UserDiv.Size = UDim2.new(1, 0, 0, 1)
	UserDiv.BackgroundColor3 = Theme.Stroke
	UserDiv.BorderSizePixel = 0
	UserDiv.Parent = UserProfile
	
	local UserImage = Instance.new("ImageLabel")
	UserImage.Size = UDim2.new(0, 32, 0, 32)
	UserImage.Position = UDim2.new(0, 12, 0.5, -16)
	UserImage.BackgroundColor3 = Theme.Stroke
	UserImage.Parent = UserProfile
	Instance.new("UICorner", UserImage).CornerRadius = UDim.new(1, 0)
	
	-- Get User Image
	task.spawn(function()
		local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
		UserImage.Image = content
	end)
	
	local UserName = Instance.new("TextLabel")
	UserName.Text = LocalPlayer.Name
	UserName.Font = Enum.Font.GothamBold
	UserName.TextSize = 12
	UserName.TextColor3 = Theme.Text
	UserName.Size = UDim2.new(0, 100, 0, 15)
	UserName.Position = UDim2.new(0, 54, 0.5, -8)
	UserName.BackgroundTransparency = 1
	UserName.TextXAlignment = Enum.TextXAlignment.Left
	UserName.Parent = UserProfile
	
	local UserRank = Instance.new("TextLabel")
	UserRank.Text = "Premium"
	UserRank.Font = Enum.Font.Gotham
	UserRank.TextSize = 11
	UserRank.TextColor3 = Theme.Accent
	UserRank.Size = UDim2.new(0, 100, 0, 15)
	UserRank.Position = UDim2.new(0, 54, 0.5, 6)
	UserRank.BackgroundTransparency = 1
	UserRank.TextXAlignment = Enum.TextXAlignment.Left
	UserRank.Parent = UserProfile
	
	-- 4. Content Area
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Size = UDim2.new(1, -180, 1, 0)
	Content.Position = UDim2.new(0, 180, 0, 0)
	Content.BackgroundTransparency = 1
	Content.Parent = Main
	
	-- Top Header (Search / Controls)
	local Header = Instance.new("Frame")
	Header.Size = UDim2.new(1, 0, 0, 40)
	Header.BackgroundTransparency = 1
	Header.Parent = Content
	
	local HeaderStroke = Instance.new("Frame") -- Bottom line of header
	HeaderStroke.Size = UDim2.new(1, 0, 0, 1)
	HeaderStroke.Position = UDim2.new(0, 0, 1, -1)
	HeaderStroke.BackgroundColor3 = Theme.Stroke
	HeaderStroke.BorderSizePixel = 0
	HeaderStroke.Parent = Header

	-- Controls
	local function CreateControl(Name, Icon, Callback)
		local Btn = Instance.new("ImageButton")
		Btn.Name = Name
		Btn.Size = UDim2.new(0, 40, 1, -1)
		Btn.Position = UDim2.new(1, -40 * (Name == "Close" and 1 or 2), 0, 0)
		Btn.BackgroundTransparency = 1
		Btn.Image = Icon
		Btn.ImageColor3 = Theme.TextDim
		Btn.ImageTransparency = 0.2
		Btn.Parent = Header
		
		-- Center the icon inside
		local Pad = Instance.new("UIPadding")
		Pad.PaddingTop = UDim.new(0, 10)
		Pad.PaddingBottom = UDim.new(0, 10)
		Pad.PaddingLeft = UDim.new(0, 10)
		Pad.PaddingRight = UDim.new(0, 10)
		Pad.Parent = Btn
		
		Btn.MouseButton1Click:Connect(Callback)
		Btn.MouseEnter:Connect(function() Tween(Btn, {ImageColor3 = Theme.Text}) end)
		Btn.MouseLeave:Connect(function() Tween(Btn, {ImageColor3 = Theme.TextDim}) end)
	end
	
	CreateControl("Close", Icons.Close, function() ScreenGui:Destroy() end)
	CreateControl("Min", Icons.Min, function() ScreenGui.Enabled = false end) -- Simple hide
	
	-- 5. Page Container
	local PageHolder = Instance.new("Frame")
	PageHolder.Name = "Pages"
	PageHolder.Size = UDim2.new(1, 0, 1, -40)
	PageHolder.Position = UDim2.new(0, 0, 0, 40)
	PageHolder.BackgroundTransparency = 1
	PageHolder.Parent = Content
	
	--// Dragging Logic
	local Dragging, DragInput, DragStart, StartPos
	Sidebar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			DragStart = input.Position
			StartPos = Main.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then Dragging = false end
			end)
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
	
	--// Resizing Logic
	local ResizeHandle = Instance.new("ImageButton")
	ResizeHandle.Size = UDim2.new(0, 20, 0, 20)
	ResizeHandle.Position = UDim2.new(1, -20, 1, -20)
	ResizeHandle.BackgroundTransparency = 1
	ResizeHandle.Image = Icons.Resize
	ResizeHandle.ImageColor3 = Theme.TextDim
	ResizeHandle.Parent = Main
	
	local Resizing, ResizeStart, StartSize
	ResizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Resizing = true
			ResizeStart = input.Position
			StartSize = Main.Size
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then Resizing = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if Resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - ResizeStart
			local newX = math.clamp(StartSize.X.Offset + delta.X, 500, 1000)
			local newY = math.clamp(StartSize.Y.Offset + delta.Y, 350, 800)
			Tween(Main, {Size = UDim2.new(0, newX, 0, newY)}, 0.05)
		end
	end)

	--// TABS SYSTEM
	local Tabs = {}
	local FirstTab = true
	
	function Tabs:CreateTab(TabName, TabIcon)
		-- Create Sidebar Button
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(1, -24, 0, 36)
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = ""
		TabBtn.Parent = TabHolder
		
		local BtnCorner = Instance.new("UICorner")
		BtnCorner.CornerRadius = UDim.new(0, 6)
		BtnCorner.Parent = TabBtn
		
		local Ico = Instance.new("ImageLabel")
		Ico.Size = UDim2.new(0, 20, 0, 20)
		Ico.Position = UDim2.new(0, 10, 0.5, -10)
		Ico.BackgroundTransparency = 1
		Ico.Image = TabIcon or Icons.User
		Ico.ImageColor3 = Theme.TextDim
		Ico.Parent = TabBtn
		
		local Txt = Instance.new("TextLabel")
		Txt.Text = TabName
		Txt.Size = UDim2.new(1, -40, 1, 0)
		Txt.Position = UDim2.new(0, 38, 0, 0)
		Txt.BackgroundTransparency = 1
		Txt.TextColor3 = Theme.TextDim
		Txt.Font = Enum.Font.GothamMedium
		Txt.TextSize = 13
		Txt.TextXAlignment = Enum.TextXAlignment.Left
		Txt.Parent = TabBtn
		
		-- Create Page
		local Page = Instance.new("ScrollingFrame")
		Page.Name = TabName
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Theme.Stroke
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Page.Visible = false
		Page.Parent = PageHolder
		
		local PagePad = Instance.new("UIPadding")
		PagePad.PaddingTop = UDim.new(0, 15)
		PagePad.PaddingLeft = UDim.new(0, 15)
		PagePad.PaddingRight = UDim.new(0, 15)
		PagePad.PaddingBottom = UDim.new(0, 15)
		PagePad.Parent = Page
		
		local PageList = Instance.new("UIListLayout")
		PageList.SortOrder = Enum.SortOrder.LayoutOrder
		PageList.Padding = UDim.new(0, 8)
		PageList.Parent = Page
		
		-- Activation Function
		local function Activate()
			-- Reset others
			for _, v in pairs(TabHolder:GetChildren()) do
				if v:IsA("TextButton") then
					Tween(v, {BackgroundTransparency = 1})
					Tween(v.ImageLabel, {ImageColor3 = Theme.TextDim})
					Tween(v.TextLabel, {TextColor3 = Theme.TextDim})
				end
			end
			for _, v in pairs(PageHolder:GetChildren()) do
				v.Visible = false
			end
			
			-- Activate This
			Page.Visible = true
			Tween(TabBtn, {BackgroundColor3 = Theme.Element, BackgroundTransparency = 0})
			Tween(Ico, {ImageColor3 = Theme.Accent})
			Tween(Txt, {TextColor3 = Theme.Text})
		end
		
		TabBtn.MouseButton1Click:Connect(Activate)
		
		if FirstTab then
			FirstTab = false
			Activate()
		end
		
		-- ELEMENTS
		local Elements = {}
		
		function Elements:CreateSection(Text)
			local Section = Instance.new("TextLabel")
			Section.Text = string.upper(Text)
			Section.Size = UDim2.new(1, 0, 0, 24)
			Section.BackgroundTransparency = 1
			Section.TextColor3 = Theme.Accent
			Section.Font = Enum.Font.GothamBold
			Section.TextSize = 11
			Section.TextXAlignment = Enum.TextXAlignment.Left
			Section.Parent = Page
		end
		
		function Elements:CreateButton(Config)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 0, 40)
			Btn.BackgroundColor3 = Theme.Element
			Btn.AutoButtonColor = false
			Btn.Text = ""
			Btn.Parent = Page
			Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
			Instance.new("UIStroke", Btn).Color = Theme.Stroke
			
			local Label = Instance.new("TextLabel")
			Label.Text = Config.Name
			Label.Size = UDim2.new(1, -20, 1, 0)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Btn
			
			Btn.MouseEnter:Connect(function() Tween(Btn, {BackgroundColor3 = Color3.fromRGB(40,40,40)}) end)
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
			Tog.Size = UDim2.new(1, 0, 0, 40)
			Tog.BackgroundColor3 = Theme.Element
			Tog.AutoButtonColor = false
			Tog.Text = ""
			Tog.Parent = Page
			Instance.new("UICorner", Tog).CornerRadius = UDim.new(0, 6)
			Instance.new("UIStroke", Tog).Color = Theme.Stroke
			
			local Label = Instance.new("TextLabel")
			Label.Text = Config.Name
			Label.Size = UDim2.new(1, -60, 1, 0)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Tog
			
			local Switch = Instance.new("Frame")
			Switch.Size = UDim2.new(0, 36, 0, 20)
			Switch.Position = UDim2.new(1, -46, 0.5, -10)
			Switch.BackgroundColor3 = State and Theme.Accent or Theme.Main
			Switch.Parent = Tog
			Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)
			
			local Dot = Instance.new("Frame")
			Dot.Size = UDim2.new(0, 16, 0, 16)
			Dot.Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
			Dot.BackgroundColor3 = Theme.Text
			Dot.Parent = Switch
			Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)
			
			Tog.MouseButton1Click:Connect(function()
				State = not State
				Tween(Switch, {BackgroundColor3 = State and Theme.Accent or Theme.Main})
				Tween(Dot, {Position = State and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)})
				pcall(Config.Callback, State)
			end)
		end
		
		function Elements:CreateSlider(Config)
			local Min, Max = Config.Min, Config.Max
			local Val = Config.Default or Min
			
			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, 0, 0, 55)
			Frame.BackgroundColor3 = Theme.Element
			Frame.Parent = Page
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
			Instance.new("UIStroke", Frame).Color = Theme.Stroke
			
			local Label = Instance.new("TextLabel")
			Label.Text = Config.Name
			Label.Size = UDim2.new(1, -20, 0, 20)
			Label.Position = UDim2.new(0, 12, 0, 8)
			Label.BackgroundTransparency = 1
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame
			
			local Display = Instance.new("TextLabel")
			Display.Text = tostring(Val)
			Display.Size = UDim2.new(0, 40, 0, 20)
			Display.Position = UDim2.new(1, -52, 0, 8)
			Display.BackgroundTransparency = 1
			Display.TextColor3 = Theme.Accent
			Display.Font = Enum.Font.GothamBold
			Display.TextSize = 13
			Display.TextXAlignment = Enum.TextXAlignment.Right
			Display.Parent = Frame
			
			local Bar = Instance.new("TextButton")
			Bar.Text = ""
			Bar.Size = UDim2.new(1, -24, 0, 8)
			Bar.Position = UDim2.new(0, 12, 0, 35)
			Bar.BackgroundColor3 = Theme.Main
			Bar.AutoButtonColor = false
			Bar.Parent = Frame
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
				local n = math.floor(Min + ((Max - Min) * pos))
				Display.Text = tostring(n)
				pcall(Config.Callback, n)
			end
			
			Bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true; Update(i) end end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
			UserInputService.InputChanged:Connect(function(i) if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end end)
		end
		
		function Elements:CreateKeybind(Config)
			local Val = Config.Default or Enum.KeyCode.RightControl
			
			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, 0, 0, 40)
			Frame.BackgroundColor3 = Theme.Element
			Frame.Parent = Page
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
			Instance.new("UIStroke", Frame).Color = Theme.Stroke
			
			local Label = Instance.new("TextLabel")
			Label.Text = Config.Name
			Label.Size = UDim2.new(1, -100, 1, 0)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.GothamSemibold
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame
			
			local BindBtn = Instance.new("TextButton")
			BindBtn.Size = UDim2.new(0, 80, 0, 24)
			BindBtn.Position = UDim2.new(1, -92, 0.5, -12)
			BindBtn.BackgroundColor3 = Theme.Main
			BindBtn.Text = "[" .. Val.Name .. "]"
			BindBtn.TextColor3 = Theme.Accent
			BindBtn.Font = Enum.Font.GothamBold
			BindBtn.TextSize = 11
			BindBtn.Parent = Frame
			Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 4)
			
			local Listening = false
			BindBtn.MouseButton1Click:Connect(function()
				Listening = true
				BindBtn.Text = "..."
				BindBtn.TextColor3 = Theme.Text
			end)
			
			UserInputService.InputBegan:Connect(function(input)
				if Listening and input.UserInputType == Enum.UserInputType.Keyboard then
					Val = input.KeyCode
					BindBtn.Text = "[" .. Val.Name .. "]"
					BindBtn.TextColor3 = Theme.Accent
					Listening = false
					pcall(Config.Callback, Val)
				end
			end)
		end
		
		return Elements
	end
	
	-- Toggle Keybind Listener (Global)
	UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == CurrentKeybind then
			ScreenGui.Enabled = not ScreenGui.Enabled
		end
	end)
	
	-- Settings Tab (Built-in)
	local SettingsTab = Tabs:CreateTab("Settings", "rbxassetid://10723415903")
	SettingsTab:CreateSection("Menu")
	
	SettingsTab:CreateKeybind({
		Name = "Menu Keybind",
		Default = CurrentKeybind,
		Callback = function(NewKey)
			CurrentKeybind = NewKey
		end
	})
	
	SettingsTab:CreateButton({
		Name = "Unload Library",
		Callback = function()
			ScreenGui:Destroy()
		end
	})
	
	return Tabs
end

return ChuddyLib
