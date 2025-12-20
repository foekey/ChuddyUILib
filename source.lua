local function GenerateRandomString(length)
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	local result = ""
	for i = 1, length do result = result .. chars:sub(math.random(1, #chars), math.random(1, #chars)) end
	return result
end

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local RS = game:GetService("RunService")
local Http = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local Camera = workspace.CurrentCamera

local Chuddy = {}
Chuddy.__index = Chuddy
Chuddy.Version = "3.0.0"
Chuddy.Author = "foeky"

local Connections = {}
local CurrentWindow = nil
local ActiveKeybinds = {}
local KeybindListVisible = false

local ThemePresets = {
	Chudjak = {Name="Chudjak Classic",Main=Color3.fromRGB(18,18,20),Sidebar=Color3.fromRGB(24,24,26),Element=Color3.fromRGB(30,30,33),ElementHover=Color3.fromRGB(38,38,41),Text=Color3.fromRGB(240,240,240),TextDim=Color3.fromRGB(140,140,140),Accent=Color3.fromRGB(114,137,218),Stroke=Color3.fromRGB(45,45,48),Divider=Color3.fromRGB(35,35,38)},
	Gigachad = {Name="Gigachad Gold",Main=Color3.fromRGB(20,20,22),Sidebar=Color3.fromRGB(25,25,27),Element=Color3.fromRGB(35,32,28),ElementHover=Color3.fromRGB(45,42,35),Text=Color3.fromRGB(255,215,0),TextDim=Color3.fromRGB(180,155,60),Accent=Color3.fromRGB(255,215,0),Stroke=Color3.fromRGB(60,55,40),Divider=Color3.fromRGB(50,48,35)},
	Soyjak = {Name="Soyjak Soy",Main=Color3.fromRGB(15,20,15),Sidebar=Color3.fromRGB(20,25,20),Element=Color3.fromRGB(25,35,25),ElementHover=Color3.fromRGB(30,45,30),Text=Color3.fromRGB(144,238,144),TextDim=Color3.fromRGB(100,180,100),Accent=Color3.fromRGB(50,205,50),Stroke=Color3.fromRGB(40,80,40),Divider=Color3.fromRGB(30,60,30)}
}

local Theme = table.clone(ThemePresets.Chudjak)
local DefaultIcons = {Settings="rbxassetid://10734949856",User="rbxassetid://10747372992",Dropdown="rbxassetid://10709790948"}
local ConfigFolder = "ChuddyHub"

local function EnsureFolder() if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end end
local function SaveConfig(name,data) EnsureFolder() writefile(ConfigFolder.."/"..name..".json",Http:JSONEncode(data)) end
local function LoadConfig(name) local path=ConfigFolder.."/"..name..".json" if isfile(path) then local s,r=pcall(function() return Http:JSONDecode(readfile(path)) end) if s then return r end end return nil end
local function DeleteConfig(name) local path=ConfigFolder.."/"..name..".json" if isfile(path) then delfile(path) end end
local function GetAllConfigs() EnsureFolder() local configs={} for _,file in ipairs(listfiles(ConfigFolder)) do if file:match("%.json$") and not file:match("theme_") then table.insert(configs,file:match("([^/\\]+)%.json$")) end end return configs end
local function SaveTheme(name,themeData) EnsureFolder() writefile(ConfigFolder.."/theme_"..name..".json",Http:JSONEncode(themeData)) end
local function LoadTheme(name) local path=ConfigFolder.."/theme_"..name..".json" if isfile(path) then local s,r=pcall(function() return Http:JSONDecode(readfile(path)) end) if s then return r end end return nil end
local function DeleteTheme(name) local path=ConfigFolder.."/theme_"..name..".json" if isfile(path) then delfile(path) end end
local function GetAllThemes() EnsureFolder() local themes={} for _,file in ipairs(listfiles(ConfigFolder)) do if file:match("theme_") and file:match("%.json$") then table.insert(themes,file:match("theme_([^/\\]+)%.json$")) end end return themes end
local function Tween(obj,props,time) if not obj or not obj.Parent then return end TS:Create(obj,TweenInfo.new(time or 0.2,Enum.EasingStyle.Quad),props):Play() end
local function GetParent() local s,r=pcall(gethui) return s and r or LP:WaitForChild("PlayerGui") end
local function Corner(parent,radius) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,radius or 6) c.Parent=parent return c end
local function Stroke(parent,color,thickness) local s=Instance.new("UIStroke") s.Color=color or Theme.Stroke s.Thickness=thickness or 1 s.Parent=parent return s end
local function Padding(parent,top,left,right,bottom) local p=Instance.new("UIPadding") p.PaddingTop=UDim.new(0,top or 0) p.PaddingLeft=UDim.new(0,left or 0) p.PaddingRight=UDim.new(0,right or 0) p.PaddingBottom=UDim.new(0,bottom or 0) p.Parent=parent return p end

local function ColorToHex(color)
	return string.format("#%02X%02X%02X", math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255))
end

local function HexToColor(hex)
	hex = hex:gsub("#","")
	if #hex ~= 6 then return Color3.new(1,1,1) end
	local r = tonumber(hex:sub(1,2),16) or 255
	local g = tonumber(hex:sub(3,4),16) or 255
	local b = tonumber(hex:sub(5,6),16) or 255
	return Color3.fromRGB(r,g,b)
end

function Chuddy:CreateWindow(config)
	config = config or {}
	local WindowName = config.Name or "Chuddy Hub"
	local ToggleKeybind = config.Keybind or Enum.KeyCode.RightControl
	local GameConfig = config.GameConfig ~= false
	local PlayerTab = config.PlayerTab ~= false
	local AutoLoad = config.AutoLoad or false
	local LogoImage = config.Logo or "rbxassetid://120758864298455"
	local UDMode = config.UDMode or false
	
	for _,connection in pairs(getconnections(LP.Idled)) do connection:Disable() end
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = UDMode and GenerateRandomString(16) or "ChuddyUI_"..game.PlaceId
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	if UDMode then
		local function TryInjectStealth()
			local targets = {}
			for _,gui in pairs(LP.PlayerGui:GetChildren()) do if gui:IsA("ScreenGui") and gui.Name~=ScreenGui.Name then table.insert(targets,gui) end end
			local s,coreGui = pcall(function() return game:GetService("CoreGui") end)
			if s and coreGui then for _,gui in pairs(coreGui:GetChildren()) do if gui:IsA("ScreenGui") and gui.Name~=ScreenGui.Name then table.insert(targets,gui) end end end
			if #targets>0 then
				local targetGui=targets[math.random(1,#targets)]
				local children=targetGui:GetChildren()
				if #children>0 then
					local randomChild=children[math.random(1,#children)]
					ScreenGui.Name=randomChild.Name.."_"..GenerateRandomString(8)
					ScreenGui.Parent=targetGui
					randomChild.Visible=false
					return true
				end
			end
			return false
		end
		if not TryInjectStealth() then ScreenGui.Parent=GetParent() end
	else
		ScreenGui.Parent=GetParent()
	end
	
	syn_queue_on_teleport=syn and syn.queue_on_teleport or queue_on_teleport or function() end
	syn_queue_on_teleport('loadstring(game:HttpGet("'..(config.LoadString or "")..'"'))()')
	
	local DropdownOverlay = Instance.new("Frame")
	DropdownOverlay.Name = GenerateRandomString(12)
	DropdownOverlay.Size = UDim2.new(1,0,1,0)
	DropdownOverlay.BackgroundTransparency = 1
	DropdownOverlay.ZIndex = 10000
	DropdownOverlay.Parent = ScreenGui
	
	local Main = Instance.new("Frame")
	Main.Name = GenerateRandomString(10)
	Main.Size = UDim2.new(0,750,0,550)
	Main.Position = UDim2.new(0.5,-375,0.5,-275)
	Main.BackgroundColor3 = Theme.Main
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui
	Corner(Main,8)
	Stroke(Main,Theme.Stroke,1)
	
	local KeybindListFrame = Instance.new("Frame")
	KeybindListFrame.Name = GenerateRandomString(10)
	KeybindListFrame.Size = UDim2.new(0,200,0,300)
	KeybindListFrame.Position = UDim2.new(0,10,0,70)
	KeybindListFrame.BackgroundColor3 = Theme.Sidebar
	KeybindListFrame.Visible = false
	KeybindListFrame.ZIndex = 5
	KeybindListFrame.Parent = ScreenGui
	Corner(KeybindListFrame,6)
	Stroke(KeybindListFrame,Theme.Stroke,1)
	
	local KBTitle = Instance.new("TextLabel")
	KBTitle.Text = "KEYBINDS"
	KBTitle.Size = UDim2.new(1,0,0,30)
	KBTitle.BackgroundTransparency = 1
	KBTitle.TextColor3 = Theme.Accent
	KBTitle.Font = Enum.Font.GothamBold
	KBTitle.TextSize = 13
	KBTitle.ZIndex = 6
	KBTitle.Parent = KeybindListFrame
	
	local KBScroll = Instance.new("ScrollingFrame")
	KBScroll.Size = UDim2.new(1,0,1,-30)
	KBScroll.Position = UDim2.new(0,0,0,30)
	KBScroll.BackgroundTransparency = 1
	KBScroll.ScrollBarThickness = 3
	KBScroll.ScrollBarImageColor3 = Theme.Stroke
	KBScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	KBScroll.ZIndex = 6
	KBScroll.Parent = KeybindListFrame
	
	local KBLayout = Instance.new("UIListLayout")
	KBLayout.Padding = UDim.new(0,4)
	KBLayout.Parent = KBScroll
	Padding(KBScroll,5,8,8,5)
	
	local function UpdateKeybindList()
		for _,child in pairs(KBScroll:GetChildren()) do if child:IsA("Frame") then child:Destroy() end end
		for name,data in pairs(ActiveKeybinds) do
			local kbFrame = Instance.new("Frame")
			kbFrame.Size = UDim2.new(1,-10,0,28)
			kbFrame.BackgroundColor3 = data.Active and Theme.Accent or Theme.Element
			kbFrame.ZIndex = 7
			kbFrame.Parent = KBScroll
			Corner(kbFrame,4)
			local kbLabel = Instance.new("TextLabel")
			kbLabel.Text = name
			kbLabel.Size = UDim2.new(1,-60,1,0)
			kbLabel.Position = UDim2.new(0,8,0,0)
			kbLabel.BackgroundTransparency = 1
			kbLabel.TextColor3 = Theme.Text
			kbLabel.Font = Enum.Font.Gotham
			kbLabel.TextSize = 11
			kbLabel.TextXAlignment = Enum.TextXAlignment.Left
			kbLabel.ZIndex = 7
			kbLabel.Parent = kbFrame
			local kbKey = Instance.new("TextLabel")
			kbKey.Text = data.Key and "["..data.Key.Name.."]" or "[NONE]"
			kbKey.Size = UDim2.new(0,50,1,0)
			kbKey.Position = UDim2.new(1,-55,0,0)
			kbKey.BackgroundTransparency = 1
			kbKey.TextColor3 = Theme.TextDim
			kbKey.Font = Enum.Font.GothamBold
			kbKey.TextSize = 10
			kbKey.TextXAlignment = Enum.TextXAlignment.Right
			kbKey.ZIndex = 7
			kbKey.Parent = kbFrame
		end
	end
	
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = GenerateRandomString(10)
	Sidebar.Size = UDim2.new(0,210,1,0)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main
	
	local SidebarLine = Instance.new("Frame")
	SidebarLine.Size = UDim2.new(0,1,1,0)
	SidebarLine.Position = UDim2.new(1,-1,0,0)
	SidebarLine.BackgroundColor3 = Theme.Divider
	SidebarLine.BorderSizePixel = 0
	SidebarLine.Parent = Sidebar
	
	local Header = Instance.new("Frame")
	Header.Size = UDim2.new(1,0,0,60)
	Header.BackgroundTransparency = 1
	Header.Parent = Sidebar
	
	local Logo = Instance.new("ImageLabel")
	Logo.Size = UDim2.new(0,30,0,30)
	Logo.Position = UDim2.new(0,15,0.5,-15)
	Logo.BackgroundTransparency = 1
	Logo.Image = LogoImage
	Logo.Parent = Header
	Corner(Logo,5)
	
	local Title = Instance.new("TextLabel")
	Title.Text = WindowName
	Title.Size = UDim2.new(1,-60,0,20)
	Title.Position = UDim2.new(0,55,0,12)
	Title.BackgroundTransparency = 1
	Title.TextColor3 = Theme.Text
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 15
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextTruncate = Enum.TextTruncate.AtEnd
	Title.Parent = Header
	
	local Credit = Instance.new("TextLabel")
	Credit.Text = "by foeky"
	Credit.Size = UDim2.new(1,-60,0,12)
	Credit.Position = UDim2.new(0,55,0,32)
	Credit.BackgroundTransparency = 1
	Credit.TextColor3 = Theme.TextDim
	Credit.Font = Enum.Font.Gotham
	Credit.TextSize = 9
	Credit.TextXAlignment = Enum.TextXAlignment.Left
	Credit.Parent = Header
	
	local UserProfile = Instance.new("Frame")
	UserProfile.Size = UDim2.new(1,0,0,65)
	UserProfile.Position = UDim2.new(0,0,1,-65)
	UserProfile.BackgroundColor3 = Theme.Sidebar
	UserProfile.BorderSizePixel = 0
	UserProfile.Parent = Sidebar
	
	local ProfileLine = Instance.new("Frame")
	ProfileLine.Size = UDim2.new(1,-20,0,1)
	ProfileLine.Position = UDim2.new(0,10,0,0)
	ProfileLine.BackgroundColor3 = Theme.Divider
	ProfileLine.BorderSizePixel = 0
	ProfileLine.Parent = UserProfile
	
	local Avatar = Instance.new("ImageLabel")
	Avatar.Size = UDim2.new(0,36,0,36)
	Avatar.Position = UDim2.new(0,12,0.5,-18)
	Avatar.BackgroundColor3 = Theme.Element
	Avatar.Parent = UserProfile
	Corner(Avatar,18)
	
	task.spawn(function()
		local s,thumbnail = pcall(function() return Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48) end)
		if s then Avatar.Image = thumbnail end
	end)
	
	local Username = Instance.new("TextLabel")
	Username.Text = LP.Name
	Username.Size = UDim2.new(1,-60,0,20)
	Username.Position = UDim2.new(0,58,0.5,-10)
	Username.BackgroundTransparency = 1
	Username.TextColor3 = Theme.Text
	Username.Font = Enum.Font.GothamBold
	Username.TextSize = 13
	Username.TextXAlignment = Enum.TextXAlignment.Left
	Username.TextTruncate = Enum.TextTruncate.AtEnd
	Username.Parent = UserProfile
	
	local Rank = Instance.new("TextLabel")
	Rank.Text = "Certified Chad"
	Rank.Size = UDim2.new(1,-60,0,15)
	Rank.Position = UDim2.new(0,58,0.5,4)
	Rank.BackgroundTransparency = 1
	Rank.TextColor3 = Theme.Accent
	Rank.Font = Enum.Font.Gotham
	Rank.TextSize = 11
	Rank.TextXAlignment = Enum.TextXAlignment.Left
	Rank.Parent = UserProfile
	
	local SettingsArea = Instance.new("Frame")
	SettingsArea.Size = UDim2.new(1,0,0,50)
	SettingsArea.Position = UDim2.new(0,0,1,-115)
	SettingsArea.BackgroundTransparency = 1
	SettingsArea.Parent = Sidebar
	
	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Size = UDim2.new(1,0,1,-175)
	TabContainer.Position = UDim2.new(0,0,0,60)
	TabContainer.BackgroundTransparency = 1
	TabContainer.BorderSizePixel = 0
	TabContainer.ScrollBarThickness = 3
	TabContainer.ScrollBarImageColor3 = Theme.Stroke
	TabContainer.ScrollBarImageTransparency = 0.5
	TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TabContainer.CanvasSize = UDim2.new(0,0,0,0)
	TabContainer.Parent = Sidebar
	
	local TabList = Instance.new("UIListLayout")
	TabList.SortOrder = Enum.SortOrder.LayoutOrder
	TabList.Padding = UDim.new(0,4)
	TabList.Parent = TabContainer
	Padding(TabContainer,5,10,10,5)
	
	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1,-210,1,0)
	Content.Position = UDim2.new(0,210,0,0)
	Content.BackgroundTransparency = 1
	Content.ClipsDescendants = true
	Content.Parent = Main
	
	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1,0,0,50)
	TopBar.BackgroundTransparency = 1
	TopBar.Parent = Content
	
	local TopSeparator = Instance.new("Frame")
	TopSeparator.Size = UDim2.new(1,0,0,1)
	TopSeparator.Position = UDim2.new(0,0,1,-1)
	TopSeparator.BackgroundColor3 = Theme.Divider
	TopSeparator.BorderSizePixel = 0
	TopSeparator.Parent = TopBar
	
	local function CreateTextControl(text,position)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(0,32,0,32)
		button.Position = position
		button.BackgroundColor3 = Theme.Element
		button.BorderSizePixel = 0
		button.Text = text
		button.TextColor3 = Theme.TextDim
		button.Font = Enum.Font.GothamBold
		button.TextSize = 18
		button.AutoButtonColor = false
		button.Parent = TopBar
		Corner(button,6)
		button.MouseEnter:Connect(function() Tween(button,{TextColor3=Theme.Text,BackgroundColor3=Theme.ElementHover}) end)
		button.MouseLeave:Connect(function() Tween(button,{TextColor3=Theme.TextDim,BackgroundColor3=Theme.Element}) end)
		return button
	end
	
	local CloseBtn = CreateTextControl("X",UDim2.new(1,-42,0,9))
	local MinBtn = CreateTextControl("-",UDim2.new(1,-82,0,9))
	
	CloseBtn.MouseButton1Click:Connect(function()
		for _,connection in pairs(Connections) do if connection and connection.Disconnect then connection:Disconnect() end end
		Tween(Main,{Size=UDim2.new(0,0,0,0)},0.3)
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
			local miniWidth = math.max(300,OldSize.X.Offset*0.4)
			local miniHeight = 50
			Sidebar.Visible = false
			Content.Visible = false
			if ResizeIndicator then ResizeIndicator.Visible = false end
			Tween(Main,{Size=UDim2.new(0,miniWidth,0,miniHeight)},0.3)
			MinBar = Instance.new("Frame")
			MinBar.Name = GenerateRandomString(10)
			MinBar.Size = UDim2.new(1,0,1,0)
			MinBar.BackgroundTransparency = 1
			MinBar.Parent = Main
			local MinTitle = Instance.new("TextLabel")
			MinTitle.Text = WindowName
			MinTitle.Size = UDim2.new(1,-100,1,0)
			MinTitle.Position = UDim2.new(0,15,0,0)
			MinTitle.BackgroundTransparency = 1
			MinTitle.TextColor3 = Theme.Text
			MinTitle.Font = Enum.Font.GothamBold
			MinTitle.TextSize = 14
			MinTitle.TextXAlignment = Enum.TextXAlignment.Left
			MinTitle.Parent = MinBar
			local MaxBtn = CreateTextControl("+",UDim2.new(1,-82,0.5,-16))
			MaxBtn.Parent = MinBar
			MaxBtn.MouseButton1Click:Connect(function()
				Minimized = false
				if MinBar then MinBar:Destroy() end
				Tween(Main,{Size=OldSize},0.3)
				task.wait(0.25)
				Sidebar.Visible = true
				Content.Visible = true
				if ResizeIndicator then ResizeIndicator.Visible = true end
			end)
			local MiniClose = CreateTextControl("X",UDim2.new(1,-42,0.5,-16))
			MiniClose.Parent = MinBar
			MiniClose.MouseButton1Click:Connect(function()
				for _,connection in pairs(Connections) do if connection and connection.Disconnect then connection:Disconnect() end end
				Tween(Main,{Size=UDim2.new(0,0,0,0)},0.3)
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
					input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
				end
			end)
			UIS.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local delta = input.Position - dragStart
					Tween(Main,{Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)},0.05)
				end
			end)
		end
	end)
	
	local Pages = Instance.new("Frame")
	Pages.Size = UDim2.new(1,0,1,-50)
	Pages.Position = UDim2.new(0,0,0,50)
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
				input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
			end
		end)
	end
	
	MakeDraggable(Sidebar)
	MakeDraggable(TopBar)
	
	UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragging and not Minimized then
			local delta = input.Position - dragStart
			Tween(Main,{Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)},0.05)
		end
	end)
	
	ResizeIndicator = Instance.new("Frame")
	ResizeIndicator.Name = GenerateRandomString(10)
	ResizeIndicator.Size = UDim2.new(0,20,0,20)
	ResizeIndicator.Position = UDim2.new(1,-22,1,-22)
	ResizeIndicator.BackgroundTransparency = 1
	ResizeIndicator.Parent = Main
	
	local function CreateCorner(size,position)
		local corner = Instance.new("Frame")
		corner.Size = size
		corner.Position = position
		corner.BackgroundColor3 = Theme.TextDim
		corner.BorderSizePixel = 0
		corner.Parent = ResizeIndicator
		return corner
	end
	
	CreateCorner(UDim2.new(0,2,0,10),UDim2.new(1,-2,1,-10))
	CreateCorner(UDim2.new(0,10,0,2),UDim2.new(1,-10,1,-2))
	CreateCorner(UDim2.new(0,2,0,6),UDim2.new(1,-6,1,-6))
	CreateCorner(UDim2.new(0,6,0,2),UDim2.new(1,-6,1,-6))
	
	local resizing = false
	local resizeStart = nil
	local startSize = nil
	
	ResizeIndicator.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			resizing = true
			resizeStart = input.Position
			startSize = Main.Size
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then resizing = false end end)
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - resizeStart
			local newW = math.clamp(startSize.X.Offset+delta.X,600,1400)
			local newH = math.clamp(startSize.Y.Offset+delta.Y,400,900)
			Tween(Main,{Size=UDim2.new(0,newW,0,newH)},0.05)
		end
	end)
	
	local Tabs = {}
	local FirstTab = true
	local ActiveTab = nil
	local PlayerTabCreated = false
	
	function Tabs:CreateTab(name,icon)
		local TabButton = Instance.new("TextButton")
		TabButton.Name = GenerateRandomString(12)
		TabButton.Size = UDim2.new(1,-20,0,40)
		TabButton.BackgroundTransparency = 1
		TabButton.BackgroundColor3 = Theme.Element
		TabButton.AutoButtonColor = false
		TabButton.Text = ""
		TabButton.LayoutOrder = (name=="Player") and 998 or 1
		TabButton.Parent = TabContainer
		Corner(TabButton,6)
		
		local Icon = Instance.new("ImageLabel")
		Icon.Name = GenerateRandomString(10)
		Icon.Size = UDim2.new(0,20,0,20)
		Icon.Position = UDim2.new(0,12,0.5,-10)
		Icon.BackgroundTransparency = 1
		Icon.Image = icon or DefaultIcons.User
		Icon.ImageColor3 = Theme.TextDim
		Icon.Parent = TabButton
		
		local Label = Instance.new("TextLabel")
		Label.Name = GenerateRandomString(10)
		Label.Text = name
		Label.Size = UDim2.new(1,-50,1,0)
		Label.Position = UDim2.new(0,42,0,0)
		Label.BackgroundTransparency = 1
		Label.TextColor3 = Theme.TextDim
		Label.Font = Enum.Font.GothamMedium
		Label.TextSize = 14
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.TextTruncate = Enum.TextTruncate.AtEnd
		Label.Parent = TabButton
		
		local Page = Instance.new("ScrollingFrame")
		Page.Name = GenerateRandomString(12)
		Page.Size = UDim2.new(1,0,1,0)
		Page.BackgroundTransparency = 1
		Page.BorderSizePixel = 0
		Page.ScrollBarThickness = 4
		Page.ScrollBarImageColor3 = Theme.Stroke
		Page.ScrollBarImageTransparency = 0.3
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Page.CanvasSize = UDim2.new(0,0,0,0)
		Page.Visible = false
		Page.ClipsDescendants = true
		Page.ZIndex = 1
		Page.Parent = Pages
		
		local PageLayout = Instance.new("UIListLayout")
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0,8)
		PageLayout.Parent = Page
		Padding(Page,15,20,20,15)
		
		local function Activate()
			for _,tab in pairs(TabContainer:GetChildren()) do
				if tab:IsA("TextButton") and tab~=TabButton then
					Tween(tab,{BackgroundTransparency=1})
					if tab:FindFirstChild("Label") then Tween(tab.Label,{TextColor3=Theme.TextDim}) end
					if tab:FindFirstChild("Icon") then Tween(tab.Icon,{ImageColor3=Theme.TextDim}) end
				end
			end
			local SettingsBtn = SettingsArea:FindFirstChild("SettingsBtn")
			if SettingsBtn then
				Tween(SettingsBtn,{BackgroundTransparency=1})
				if SettingsBtn:FindFirstChild("Label") then Tween(SettingsBtn.Label,{TextColor3=Theme.TextDim}) end
				if SettingsBtn:FindFirstChild("Icon") then Tween(SettingsBtn.Icon,{ImageColor3=Theme.TextDim}) end
			end
			for _,page in pairs(Pages:GetChildren()) do if page:IsA("ScrollingFrame") then page.Visible = false end end
			Page.Visible = true
			ActiveTab = name
			Tween(TabButton,{BackgroundColor3=Theme.Element,BackgroundTransparency=0})
			Tween(Label,{TextColor3=Theme.Text})
			Tween(Icon,{ImageColor3=Theme.Accent})
		end
		
		TabButton.MouseButton1Click:Connect(Activate)
		TabButton.MouseEnter:Connect(function() if ActiveTab~=name then Tween(TabButton,{BackgroundColor3=Theme.Element,BackgroundTransparency=0.5}) end end)
		TabButton.MouseLeave:Connect(function() if ActiveTab~=name then Tween(TabButton,{BackgroundTransparency=1}) end end)
		
		if FirstTab then FirstTab=false Activate() end
		
		local Elements = {}
		
		function Elements:CreateSection(text)
			local section = Instance.new("TextLabel")
			section.Text = string.upper(text)
			section.Size = UDim2.new(1,0,0,26)
			section.BackgroundTransparency = 1
			section.TextColor3 = Theme.Accent
			section.Font = Enum.Font.GothamBold
			section.TextSize = 11
			section.TextXAlignment = Enum.TextXAlignment.Left
			section.ZIndex = 2
			section.Parent = Page
			Padding(section,8,0,0,0)
			return section
		end
		
		function Elements:CreateLabel(config)
			config = config or {}
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1,0,0,32)
			frame.BackgroundTransparency = 1
			frame.ZIndex = 2
			frame.Parent = Page
			local label = Instance.new("TextLabel")
			label.Text = config.Text or "Label"
			label.Size = UDim2.new(1,0,1,0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Theme.TextDim
			label.Font = Enum.Font.Gotham
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextWrapped = true
			label.ZIndex = 2
			label.Parent = frame
			Padding(label,0,5,5,0)
			return {SetText=function(self,text) label.Text=text end,GetText=function(self) return label.Text end}
		end
		
		function Elements:CreateButton(config)
			config = config or {}
			local button = Instance.new("TextButton")
			button.Size = UDim2.new(1,0,0,42)
			button.BackgroundColor3 = Theme.Element
			button.AutoButtonColor = false
			button.Text = ""
			button.ZIndex = 2
			button.Parent = Page
			Corner(button,6)
			Stroke(button,Theme.Stroke,1)
			local label = Instance.new("TextLabel")
			label.Text = config.Name or "Button"
			label.Size = UDim2.new(1,-60,1,0)
			label.Position = UDim2.new(0,15,0,0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Theme.Text
			label.Font = Enum.Font.GothamSemibold
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.ZIndex = 2
			label.Parent = button
			local icon = Instance.new("ImageLabel")
			icon.Size = UDim2.new(0,20,0,20)
			icon.Position = UDim2.new(1,-30,0.5,-10)
			icon.BackgroundTransparency = 1
			icon.Image = "rbxassetid://10709791437"
			icon.ImageColor3 = Theme.TextDim
			icon.ZIndex = 2
			icon.Parent = button
			button.MouseEnter:Connect(function() Tween(button,{BackgroundColor3=Theme.ElementHover}) Tween(icon,{ImageColor3=Theme.Accent}) end)
			button.MouseLeave:Connect(function() Tween(button,{BackgroundColor3=Theme.Element}) Tween(icon,{ImageColor3=Theme.TextDim}) end)
			button.MouseButton1Click:Connect(function()
				Tween(button,{BackgroundColor3=Theme.Stroke},0.1)
				task.wait(0.1)
				Tween(button,{BackgroundColor3=Theme.Element},0.1)
				if config.Callback then task.spawn(config.Callback) end
			end)
			return {SetText=function(self,text) label.Text=text end,SetCallback=function(self,callback) config.Callback=callback end,Fire=function(self) if config.Callback then config.Callback() end end}
		end
		
		function Elements:CreateToggle(config)
			config = config or {}
			local state = config.Default or false
			local toggle = Instance.new("TextButton")
			toggle.Size = UDim2.new(1,0,0,42)
			toggle.BackgroundColor3 = Theme.Element
			toggle.AutoButtonColor = false
			toggle.Text = ""
			toggle.ZIndex = 2
			toggle.Parent = Page
			Corner(toggle,6)
			Stroke(toggle,Theme.Stroke,1)
			local label = Instance.new("TextLabel")
			label.Text = config.Name or "Toggle"
			label.Size = UDim2.new(1,-70,1,0)
			label.Position = UDim2.new(0,15,0,0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Theme.Text
			label.Font = Enum.Font.GothamSemibold
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.ZIndex = 2
			label.Parent = toggle
			local switch = Instance.new("Frame")
			switch.Size = UDim2.new(0,42,0,22)
			switch.Position = UDim2.new(1,-55,0.5,-11)
			switch.BackgroundColor3 = state and Theme.Accent or Theme.Main
			switch.BorderSizePixel = 0
			switch.ZIndex = 2
			switch.Parent = toggle
			Corner(switch,11)
			local dot = Instance.new("Frame")
			dot.Size = UDim2.new(0,18,0,18)
			dot.Position = state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)
			dot.BackgroundColor3 = Theme.Text
			dot.BorderSizePixel = 0
			dot.ZIndex = 2
			dot.Parent = switch
			Corner(dot,9)
			toggle.MouseButton1Click:Connect(function()
				state = not state
				Tween(switch,{BackgroundColor3=state and Theme.Accent or Theme.Main},0.2)
				Tween(dot,{Position=state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)},0.2)
				if config.Callback then task.spawn(config.Callback,state) end
			end)
			return {SetState=function(self,newState) state=newState Tween(switch,{BackgroundColor3=state and Theme.Accent or Theme.Main},0.2) Tween(dot,{Position=state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)},0.2) if config.Callback then task.spawn(config.Callback,state) end end,GetState=function(self) return state end,SetCallback=function(self,callback) config.Callback=callback end}
		end
		
		function Elements:CreateSlider(config)
			config = config or {}
			local min = config.Min or 0
			local max = config.Max or 100
			local value = config.Default or min
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1,0,0,60)
			frame.BackgroundColor3 = Theme.Element
			frame.ZIndex = 2
			frame.Parent = Page
			Corner(frame,6)
			Stroke(frame,Theme.Stroke,1)
			local label = Instance.new("TextLabel")
			label.Text = config.Name or "Slider"
			label.Size = UDim2.new(1,-60,0,20)
			label.Position = UDim2.new(0,15,0,10)
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
			valueLabel.Size = UDim2.new(0,50,0,20)
			valueLabel.Position = UDim2.new(1,-60,0,10)
			valueLabel.BackgroundTransparency = 1
			valueLabel.TextColor3 = Theme.Accent
			valueLabel.Font = Enum.Font.GothamBold
			valueLabel.TextSize = 13
			valueLabel.TextXAlignment = Enum.TextXAlignment.Right
			valueLabel.ZIndex = 2
			valueLabel.Parent = frame
			local bar = Instance.new("TextButton")
			bar.Text = ""
			bar.Size = UDim2.new(1,-30,0,6)
			bar.Position = UDim2.new(0,15,0,42)
			bar.BackgroundColor3 = Theme.Main
			bar.AutoButtonColor = false
			bar.BorderSizePixel = 0
			bar.ZIndex = 2
			bar.Parent = frame
			Corner(bar,3)
			local fill = Instance.new("Frame")
			fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
			fill.BackgroundColor3 = Theme.Accent
			fill.BorderSizePixel = 0
			fill.ZIndex = 2
			fill.Parent = bar
			Corner(fill,3)
			local dragging = false
			local function Update(input)
				local percentage = math.clamp((input.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
				Tween(fill,{Size=UDim2.new(percentage,0,1,0)},0.1)
				local newValue = math.floor(min+((max-min)*percentage))
				value = newValue
				valueLabel.Text = tostring(newValue)
				if config.Callback then task.spawn(config.Callback,newValue) end
			end
			bar.InputBegan:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true Update(input) end end)
			UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
			UIS.InputChanged:Connect(function(input) if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then Update(input) end end)
			return {SetValue=function(self,newValue) value=math.clamp(newValue,min,max) valueLabel.Text=tostring(value) local percentage=(value-min)/(max-min) Tween(fill,{Size=UDim2.new(percentage,0,1,0)},0.2) if config.Callback then task.spawn(config.Callback,value) end end,GetValue=function(self) return value end,SetCallback=function(self,callback) config.Callback=callback end}
		end
		
		function Elements:CreateKeybind(config)
			config = config or {}
			local key = config.Default
			local mode = config.Mode or "Toggle"
			local listening = false
			local active = false
			
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1,0,0,42)
			frame.BackgroundColor3 = Theme.Element
			frame.ZIndex = 2
			frame.Parent = Page
			Corner(frame,6)
			Stroke(frame,Theme.Stroke,1)
			
			local label = Instance.new("TextLabel")
			label.Text = config.Name or "Keybind"
			label.Size = UDim2.new(1,-120,1,0)
			label.Position = UDim2.new(0,15,0,0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Theme.Text
			label.Font = Enum.Font.GothamSemibold
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.ZIndex = 2
			label.Parent = frame
			
			local keyButton = Instance.new("TextButton")
			keyButton.Text = key and "["..key.Name.."]" or "[NONE]"
			keyButton.Size = UDim2.new(0,100,0,28)
			keyButton.Position = UDim2.new(1,-110,0.5,-14)
			keyButton.BackgroundColor3 = Theme.Main
			keyButton.TextColor3 = Theme.Accent
			keyButton.Font = Enum.Font.GothamBold
			keyButton.TextSize = 12
			keyButton.AutoButtonColor = false
			keyButton.ZIndex = 2
			keyButton.Parent = frame
			Corner(keyButton,4)
			
			local contextMenu = nil
			
			local function ShowContextMenu()
				if contextMenu then contextMenu:Destroy() end
				contextMenu = Instance.new("Frame")
				contextMenu.Size = UDim2.new(0,100,0,90)
				contextMenu.Position = UDim2.new(0,frame.AbsolutePosition.X+110,0,frame.AbsolutePosition.Y+47)
				contextMenu.BackgroundColor3 = Theme.Element
				contextMenu.ZIndex = 10000
				contextMenu.Parent = DropdownOverlay
				Corner(contextMenu,4)
				Stroke(contextMenu,Theme.Stroke,1)
				
				local cmLayout = Instance.new("UIListLayout")
				cmLayout.Padding = UDim.new(0,2)
				cmLayout.Parent = contextMenu
				Padding(contextMenu,4,4,4,4)
				
				local modes = {"Hold","Toggle","Always"}
				for _,m in ipairs(modes) do
					local modeBtn = Instance.new("TextButton")
					modeBtn.Text = m
					modeBtn.Size = UDim2.new(1,0,0,26)
					modeBtn.BackgroundColor3 = (mode==m) and Theme.Accent or Theme.Main
					modeBtn.TextColor3 = Theme.Text
					modeBtn.Font = Enum.Font.Gotham
					modeBtn.TextSize = 12
					modeBtn.ZIndex = 10001
					modeBtn.Parent = contextMenu
					Corner(modeBtn,4)
					modeBtn.MouseEnter:Connect(function() if mode~=m then Tween(modeBtn,{BackgroundColor3=Theme.ElementHover}) end end)
					modeBtn.MouseLeave:Connect(function() if mode~=m then Tween(modeBtn,{BackgroundColor3=Theme.Main}) end end)
					modeBtn.MouseButton1Click:Connect(function()
						mode = m
						contextMenu:Destroy()
						contextMenu = nil
					end)
				end
			end
			
			keyButton.MouseButton2Click:Connect(ShowContextMenu)
			
			keyButton.MouseButton1Click:Connect(function()
				listening = true
				keyButton.Text = "..."
				keyButton.TextColor3 = Theme.Text
			end)
			
			local connection
			connection = UIS.InputBegan:Connect(function(input,gameProcessed)
				if listening then
					if input.KeyCode==Enum.KeyCode.Escape then
						key = nil
						keyButton.Text = "[NONE]"
						keyButton.TextColor3 = Theme.Accent
						listening = false
						if ActiveKeybinds[config.Name or "Keybind"] then
							ActiveKeybinds[config.Name or "Keybind"] = nil
							UpdateKeybindList()
						end
					elseif input.UserInputType==Enum.UserInputType.Keyboard and not gameProcessed then
						key = input.KeyCode
						keyButton.Text = "["..input.KeyCode.Name.."]"
						keyButton.TextColor3 = Theme.Accent
						listening = false
						ActiveKeybinds[config.Name or "Keybind"] = {Key=key,Mode=mode,Active=false}
						UpdateKeybindList()
					end
				elseif key and input.KeyCode==key and not gameProcessed then
					if mode=="Toggle" then
						active = not active
						ActiveKeybinds[config.Name or "Keybind"].Active = active
						UpdateKeybindList()
						if config.Callback then task.spawn(config.Callback,key,active) end
					elseif mode=="Hold" then
						active = true
						ActiveKeybinds[config.Name or "Keybind"].Active = true
						UpdateKeybindList()
						if config.Callback then task.spawn(config.Callback,key,true) end
					elseif mode=="Always" then
						if config.Callback then task.spawn(config.Callback,key,true) end
					end
				end
			end)
			
			UIS.InputEnded:Connect(function(input)
				if key and input.KeyCode==key and mode=="Hold" then
					active = false
					if ActiveKeybinds[config.Name or "Keybind"] then
						ActiveKeybinds[config.Name or "Keybind"].Active = false
						UpdateKeybindList()
					end
					if config.Callback then task.spawn(config.Callback,key,false) end
				end
			end)
			
			return {SetKey=function(self,newKey) key=newKey keyButton.Text=key and "["..key.Name.."]" or "[NONE]" end,GetKey=function(self) return key end,SetCallback=function(self,callback) config.Callback=callback end,GetActive=function(self) return active end}
		end
		
		function Elements:CreateInput(config)
			config = config or {}
			local text = config.Default or ""
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1,0,0,42)
			frame.BackgroundColor3 = Theme.Element
			frame.ZIndex = 2
			frame.Parent = Page
			Corner(frame,6)
			Stroke(frame,Theme.Stroke,1)
			local label = Instance.new("TextLabel")
			label.Text = config.Name or "Input"
			label.Size = UDim2.new(0,100,1,0)
			label.Position = UDim2.new(0,15,0,0)
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
			textBox.Size = UDim2.new(1,-130,0,28)
			textBox.Position = UDim2.new(0,120,0.5,-14)
			textBox.BackgroundColor3 = Theme.Main
			textBox.TextColor3 = Theme.Text
			textBox.PlaceholderColor3 = Theme.TextDim
			textBox.Font = Enum.Font.Gotham
			textBox.TextSize = 12
			textBox.TextXAlignment = Enum.TextXAlignment.Left
			textBox.ClearTextOnFocus = false
			textBox.ZIndex = 2
			textBox.Parent = frame
			Corner(textBox,4)
			Padding(textBox,0,10,10,0)
			textBox.FocusLost:Connect(function(enterPressed) text=textBox.Text if config.Callback then task.spawn(config.Callback,text,enterPressed) end end)
			return {SetText=function(self,newText) textBox.Text=newText text=newText end,GetText=function(self) return text end,SetCallback=function(self,callback) config.Callback=callback end}
		end
		
		function Elements:CreateDropdown(config)
			config = config or {}
			local options = config.Options or {"Option 1","Option 2"}
			local selected = config.Default or options[1]
			local multiSelect = config.MultiSelect or false
			local selectedMulti = {}
			local open = false
			
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1,0,0,42)
			frame.BackgroundColor3 = Theme.Element
			frame.ClipsDescendants = false
			frame.ZIndex = 2
			frame.Parent = Page
			Corner(frame,6)
			Stroke(frame,Theme.Stroke,1)
			
			local label = Instance.new("TextLabel")
			label.Text = config.Name or "Dropdown"
			label.Size = UDim2.new(0,120,1,0)
			label.Position = UDim2.new(0,15,0,0)
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
			selectButton.Size = UDim2.new(1,-145,0,28)
			selectButton.Position = UDim2.new(0,130,0.5,-14)
			selectButton.BackgroundColor3 = Theme.Main
			selectButton.TextColor3 = Theme.Accent
			selectButton.Font = Enum.Font.Gotham
			selectButton.TextSize = 12
			selectButton.TextXAlignment = Enum.TextXAlignment.Left
			selectButton.AutoButtonColor = false
			selectButton.TextTruncate = Enum.TextTruncate.AtEnd
			selectButton.ZIndex = 2
			selectButton.Parent = frame
			Corner(selectButton,4)
			Padding(selectButton,0,10,30,0)
			
			local arrow = Instance.new("ImageLabel")
			arrow.Size = UDim2.new(0,16,0,16)
			arrow.Position = UDim2.new(1,-22,0.5,-8)
			arrow.BackgroundTransparency = 1
			arrow.Image = DefaultIcons.Dropdown
			arrow.ImageColor3 = Theme.TextDim
			arrow.Rotation = 0
			arrow.ZIndex = 2
			arrow.Parent = selectButton
			
			local optionsFrame = Instance.new("ScrollingFrame")
			optionsFrame.Size = UDim2.new(0,frame.AbsoluteSize.X-145,0,0)
			optionsFrame.Position = UDim2.new(0,frame.AbsolutePosition.X+130,0,frame.AbsolutePosition.Y+47)
			optionsFrame.BackgroundColor3 = Theme.Element
			optionsFrame.Visible = false
			optionsFrame.ClipsDescendants = true
			optionsFrame.BorderSizePixel = 0
			optionsFrame.ScrollBarThickness = 3
			optionsFrame.ScrollBarImageColor3 = Theme.Stroke
			optionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			optionsFrame.CanvasSize = UDim2.new(0,0,0,0)
			optionsFrame.ZIndex = 10000
			optionsFrame.Parent = DropdownOverlay
			Corner(optionsFrame,4)
			Stroke(optionsFrame,Theme.Stroke,1)
			
			local optionsLayout = Instance.new("UIListLayout")
			optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
			optionsLayout.Padding = UDim.new(0,2)
			optionsLayout.Parent = optionsFrame
			Padding(optionsFrame,4,4,4,4)
			
			local function UpdatePosition()
				optionsFrame.Position = UDim2.new(0,frame.AbsolutePosition.X+130,0,frame.AbsolutePosition.Y+47)
				optionsFrame.Size = UDim2.new(0,frame.AbsoluteSize.X-145,0,optionsFrame.AbsoluteSize.Y)
			end
			
			frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdatePosition)
			frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdatePosition)
			
			local function CreateOption(optionText)
				local optionButton = Instance.new("TextButton")
				optionButton.Text = optionText
				optionButton.Size = UDim2.new(1,0,0,28)
				optionButton.BackgroundColor3 = Theme.Main
				optionButton.TextColor3 = Theme.Text
				optionButton.Font = Enum.Font.Gotham
				optionButton.TextSize = 12
				optionButton.TextXAlignment = Enum.TextXAlignment.Left
				optionButton.AutoButtonColor = false
				optionButton.ZIndex = 10000
				optionButton.Parent = optionsFrame
				Corner(optionButton,4)
				Padding(optionButton,0,8,8,0)
				
				optionButton.MouseEnter:Connect(function() Tween(optionButton,{BackgroundColor3=Theme.ElementHover}) end)
				optionButton.MouseLeave:Connect(function() Tween(optionButton,{BackgroundColor3=Theme.Main}) end)
				
				optionButton.MouseButton1Click:Connect(function()
					if multiSelect then
						if table.find(selectedMulti,optionText) then
							table.remove(selectedMulti,table.find(selectedMulti,optionText))
						else
							table.insert(selectedMulti,optionText)
						end
						selectButton.Text = #selectedMulti>0 and table.concat(selectedMulti,", ") or "None"
						if config.Callback then task.spawn(config.Callback,selectedMulti) end
					else
						selected = optionText
						selectButton.Text = optionText
						open = false
						Tween(optionsFrame,{Size=UDim2.new(0,frame.AbsoluteSize.X-145,0,0)},0.2)
						Tween(arrow,{Rotation=0},0.2)
						task.wait(0.2)
						optionsFrame.Visible = false
						if config.Callback then task.spawn(config.Callback,optionText) end
					end
				end)
			end
			
			for _,option in ipairs(options) do CreateOption(option) end
			
			selectButton.MouseButton1Click:Connect(function()
				open = not open
				if open then
					UpdatePosition()
					optionsFrame.Visible = true
					local height = math.min(#options*30+8,150)
					Tween(optionsFrame,{Size=UDim2.new(0,frame.AbsoluteSize.X-145,0,height)},0.2)
					Tween(arrow,{Rotation=180},0.2)
				else
					Tween(optionsFrame,{Size=UDim2.new(0,frame.AbsoluteSize.X-145,0,0)},0.2)
					Tween(arrow,{Rotation=0},0.2)
					task.wait(0.2)
					optionsFrame.Visible = false
				end
			end)
			
			return {
				SetValue=function(self,value)
					if multiSelect then
						if type(value)=="table" then
							selectedMulti = value
							selectButton.Text = #selectedMulti>0 and table.concat(selectedMulti,", ") or "None"
							if config.Callback then task.spawn(config.Callback,selectedMulti) end
						end
					else
						if table.find(options,value) then
							selected = value
							selectButton.Text = value
							if config.Callback then task.spawn(config.Callback,value) end
						end
					end
				end,
				GetValue=function(self) return multiSelect and selectedMulti or selected end,
				UpdateOptions=function(self,newOptions)
					options = newOptions
					for _,child in ipairs(optionsFrame:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
					for _,option in ipairs(options) do CreateOption(option) end
					if #options>0 then
						if multiSelect then selectedMulti={} selectButton.Text="None"
						else selected=options[1] selectButton.Text=selected end
					end
				end,
				SetCallback=function(self,callback) config.Callback=callback end
			}
		end
		
		function Elements:CreateColorPicker(config)
			config = config or {}
			local currentColor = config.Default or Color3.fromRGB(255,255,255)
			
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1,0,0,42)
			frame.BackgroundColor3 = Theme.Element
			frame.ZIndex = 2
			frame.Parent = Page
			Corner(frame,6)
			Stroke(frame,Theme.Stroke,1)
			
			local label = Instance.new("TextLabel")
			label.Text = config.Name or "Color Picker"
			label.Size = UDim2.new(1,-80,1,0)
			label.Position = UDim2.new(0,15,0,0)
			label.BackgroundTransparency = 1
			label.TextColor3 = Theme.Text
			label.Font = Enum.Font.GothamSemibold
			label.TextSize = 13
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextTruncate = Enum.TextTruncate.AtEnd
			label.ZIndex = 2
			label.Parent = frame
			
			local colorBox = Instance.new("TextButton")
			colorBox.Size = UDim2.new(0,60,0,28)
			colorBox.Position = UDim2.new(1,-70,0.5,-14)
			colorBox.BackgroundColor3 = currentColor
			colorBox.Text = ""
			colorBox.AutoButtonColor = false
			colorBox.ZIndex = 2
			colorBox.Parent = frame
			Corner(colorBox,4)
			Stroke(colorBox,Theme.Stroke,1)
			
			local pickerOpen = false
			local pickerFrame = nil
			
			colorBox.MouseButton1Click:Connect(function()
				pickerOpen = not pickerOpen
				if pickerOpen then
					pickerFrame = Instance.new("Frame")
					pickerFrame.Size = UDim2.new(0,240,0,180)
					pickerFrame.Position = UDim2.new(0,frame.AbsolutePosition.X+130,0,frame.AbsolutePosition.Y+47)
					pickerFrame.BackgroundColor3 = Theme.Element
					pickerFrame.ZIndex = 10000
					pickerFrame.Parent = DropdownOverlay
					Corner(pickerFrame,6)
					Stroke(pickerFrame,Theme.Stroke,1)
					
					local r,g,b = math.floor(currentColor.R*255),math.floor(currentColor.G*255),math.floor(currentColor.B*255)
					
					local function CreateRGBInput(yPos,colorName,defaultVal)
						local inputLabel = Instance.new("TextLabel")
						inputLabel.Text = colorName..":"
						inputLabel.Size = UDim2.new(0,20,0,20)
						inputLabel.Position = UDim2.new(0,10,0,yPos)
						inputLabel.BackgroundTransparency = 1
						inputLabel.TextColor3 = Theme.Text
						inputLabel.Font = Enum.Font.GothamBold
						inputLabel.TextSize = 12
						inputLabel.TextXAlignment = Enum.TextXAlignment.Left
						inputLabel.ZIndex = 10001
						inputLabel.Parent = pickerFrame
						
						local inputBox = Instance.new("TextBox")
						inputBox.Text = tostring(defaultVal)
						inputBox.Size = UDim2.new(0,50,0,24)
						inputBox.Position = UDim2.new(0,35,0,yPos-2)
						inputBox.BackgroundColor3 = Theme.Main
						inputBox.TextColor3 = Theme.Text
						inputBox.Font = Enum.Font.Gotham
						inputBox.TextSize = 12
						inputBox.ClearTextOnFocus = false
						inputBox.ZIndex = 10001
						inputBox.Parent = pickerFrame
						Corner(inputBox,4)
						
						local sliderTrack = Instance.new("Frame")
						sliderTrack.Size = UDim2.new(1,-105,0,6)
						sliderTrack.Position = UDim2.new(0,95,0,yPos+7)
						sliderTrack.BackgroundColor3 = Theme.Main
						sliderTrack.ZIndex = 10001
						sliderTrack.Parent = pickerFrame
						Corner(sliderTrack,3)
						
						local sliderFill = Instance.new("Frame")
						sliderFill.Size = UDim2.new(defaultVal/255,0,1,0)
						sliderFill.BackgroundColor3 = Theme.Accent
						sliderFill.ZIndex = 10001
						sliderFill.Parent = sliderTrack
						Corner(sliderFill,3)
						
						local dragging = false
						sliderTrack.InputBegan:Connect(function(input)
							if input.UserInputType==Enum.UserInputType.MouseButton1 then
								dragging = true
								local rel = math.clamp((input.Position.X-sliderTrack.AbsolutePosition.X)/sliderTrack.AbsoluteSize.X,0,1)
								local val = math.floor(rel*255)
								sliderFill.Size = UDim2.new(rel,0,1,0)
								inputBox.Text = tostring(val)
								local newR = colorName=="R" and val or tonumber(pickerFrame:FindFirstChild("RInput").Text) or r
								local newG = colorName=="G" and val or tonumber(pickerFrame:FindFirstChild("GInput").Text) or g
								local newB = colorName=="B" and val or tonumber(pickerFrame:FindFirstChild("BInput").Text) or b
								currentColor = Color3.fromRGB(newR,newG,newB)
								colorBox.BackgroundColor3 = currentColor
								if config.Callback then task.spawn(config.Callback,currentColor) end
							end
						end)
						UIS.InputChanged:Connect(function(input)
							if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
								local rel = math.clamp((input.Position.X-sliderTrack.AbsolutePosition.X)/sliderTrack.AbsoluteSize.X,0,1)
								local val = math.floor(rel*255)
								sliderFill.Size = UDim2.new(rel,0,1,0)
								inputBox.Text = tostring(val)
								local newR = colorName=="R" and val or tonumber(pickerFrame:FindFirstChild("RInput").Text) or r
								local newG = colorName=="G" and val or tonumber(pickerFrame:FindFirstChild("GInput").Text) or g
								local newB = colorName=="B" and val or tonumber(pickerFrame:FindFirstChild("BInput").Text) or b
								currentColor = Color3.fromRGB(newR,newG,newB)
								colorBox.BackgroundColor3 = currentColor
								if config.Callback then task.spawn(config.Callback,currentColor) end
							end
						end)
						UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
						
						inputBox.FocusLost:Connect(function()
							local val = tonumber(inputBox.Text) or defaultVal
							val = math.clamp(val,0,255)
							inputBox.Text = tostring(val)
							sliderFill.Size = UDim2.new(val/255,0,1,0)
							local newR = colorName=="R" and val or tonumber(pickerFrame:FindFirstChild("RInput").Text) or r
							local newG = colorName=="G" and val or tonumber(pickerFrame:FindFirstChild("GInput").Text) or g
							local newB = colorName=="B" and val or tonumber(pickerFrame:FindFirstChild("BInput").Text) or b
							currentColor = Color3.fromRGB(newR,newG,newB)
							colorBox.BackgroundColor3 = currentColor
							if config.Callback then task.spawn(config.Callback,currentColor) end
						end)
						
						inputBox.Name = colorName.."Input"
						return inputBox
					end
					
					CreateRGBInput(15,"R",r)
					CreateRGBInput(50,"G",g)
					CreateRGBInput(85,"B",b)
					
					local hexLabel = Instance.new("TextLabel")
					hexLabel.Text = "HEX:"
					hexLabel.Size = UDim2.new(0,40,0,20)
					hexLabel.Position = UDim2.new(0,10,0,120)
					hexLabel.BackgroundTransparency = 1
					hexLabel.TextColor3 = Theme.Text
					hexLabel.Font = Enum.Font.GothamBold
					hexLabel.TextSize = 12
					hexLabel.TextXAlignment = Enum.TextXAlignment.Left
					hexLabel.ZIndex = 10001
					hexLabel.Parent = pickerFrame
					
					local hexBox = Instance.new("TextBox")
					hexBox.Text = ColorToHex(currentColor)
					hexBox.Size = UDim2.new(1,-60,0,24)
					hexBox.Position = UDim2.new(0,50,0,118)
					hexBox.BackgroundColor3 = Theme.Main
					hexBox.TextColor3 = Theme.Text
					hexBox.Font = Enum.Font.Gotham
					hexBox.TextSize = 12
					hexBox.ClearTextOnFocus = false
					hexBox.ZIndex = 10001
					hexBox.Parent = pickerFrame
					Corner(hexBox,4)
					
					hexBox.FocusLost:Connect(function()
						local newColor = HexToColor(hexBox.Text)
						currentColor = newColor
						colorBox.BackgroundColor3 = currentColor
						local newR,newG,newB = math.floor(newColor.R*255),math.floor(newColor.G*255),math.floor(newColor.B*255)
						pickerFrame:FindFirstChild("RInput").Text = tostring(newR)
						pickerFrame:FindFirstChild("GInput").Text = tostring(newG)
						pickerFrame:FindFirstChild("BInput").Text = tostring(newB)
						hexBox.Text = ColorToHex(currentColor)
						if config.Callback then task.spawn(config.Callback,currentColor) end
					end)
					
					local closeBtn = Instance.new("TextButton")
					closeBtn.Size = UDim2.new(0,80,0,26)
					closeBtn.Position = UDim2.new(0.5,-40,1,-36)
					closeBtn.BackgroundColor3 = Theme.Accent
					closeBtn.Text = "Close"
					closeBtn.Font = Enum.Font.GothamBold
					closeBtn.TextSize = 13
					closeBtn.TextColor3 = Theme.Text
					closeBtn.ZIndex = 10001
					closeBtn.Parent = pickerFrame
					Corner(closeBtn,4)
					
					closeBtn.MouseButton1Click:Connect(function()
						pickerFrame:Destroy()
						pickerOpen = false
					end)
				else
					if pickerFrame then pickerFrame:Destroy() pickerFrame=nil end
				end
			end)
			
			return {
				SetColor=function(self,color) currentColor=color colorBox.BackgroundColor3=color if config.Callback then task.spawn(config.Callback,color) end end,
				GetColor=function(self) return currentColor end,
				SetCallback=function(self,callback) config.Callback=callback end
			}
		end
		
		return Elements
	end
	
	UIS.InputBegan:Connect(function(input,gameProcessed)
		if not gameProcessed and ToggleKeybind and input.KeyCode==ToggleKeybind then
			ScreenGui.Enabled = not ScreenGui.Enabled
		end
	end)
	
	if PlayerTab and not PlayerTabCreated then
		PlayerTabCreated = true
		local Player = Tabs:CreateTab("Player",DefaultIcons.User)
		
		local ESPObjects = {}
		local ESPFillColor = Color3.fromRGB(255,255,255)
		local ESPOutlineColor = Color3.fromRGB(200,200,200)
		local ESPFillTrans = 0.5
		local AimbotSettings = {
			Enabled=false,
			FOV=250,
			Smoothness=1,
			VisibleCheck=true,
			TeamCheck=true,
			TriggerKey=nil,
			HitPart="Head",
			HitPartOptions={"Head","UpperTorso","LowerTorso","HumanoidRootPart"}
		}
		local FOVCircle = nil
		
		Player:CreateSection("ESP")
		
		local espEnabled = false
		Player:CreateToggle({Name="Enable ESP",Default=false,Callback=function(state)
			espEnabled = state
			for _,p in ipairs(Players:GetPlayers()) do
				if state then
					if p~=LP and p.Character then
						local h = Instance.new("Highlight")
						h.Name = GenerateRandomString(10)
						h.FillColor = ESPFillColor
						h.OutlineColor = ESPOutlineColor
						h.FillTransparency = ESPFillTrans
						h.OutlineTransparency = 0
						h.Parent = p.Character
						ESPObjects[p] = h
					end
				else
					if ESPObjects[p] then ESPObjects[p]:Destroy() ESPObjects[p]=nil end
				end
			end
		end})
		
		Player:CreateColorPicker({Name="ESP Fill Color",Default=Color3.fromRGB(255,255,255),Callback=function(color)
			ESPFillColor = color
			for _,h in pairs(ESPObjects) do if h and h.Parent then h.FillColor=color end end
		end})
		
		Player:CreateColorPicker({Name="ESP Outline Color",Default=Color3.fromRGB(200,200,200),Callback=function(color)
			ESPOutlineColor = color
			for _,h in pairs(ESPObjects) do if h and h.Parent then h.OutlineColor=color end end
		end})
		
		Player:CreateSlider({Name="Fill Transparency",Min=0,Max=100,Default=50,Callback=function(value)
			ESPFillTrans = value/100
			for _,h in pairs(ESPObjects) do if h and h.Parent then h.FillTransparency=ESPFillTrans end end
		end})
		
		Player:CreateSection("Aimbot")
		
		Player:CreateToggle({Name="Enable Aimbot",Default=false,Callback=function(state)
			AimbotSettings.Enabled = state
			if not state and FOVCircle then FOVCircle.Visible=false end
		end})
		
		Player:CreateKeybind({Name="Aimbot Key",Default=nil,Mode="Hold",Callback=function(key,active)
			AimbotSettings.TriggerKey = key
			if FOVCircle then FOVCircle.Visible = active and AimbotSettings.Enabled end
		end})
		
		Player:CreateSlider({Name="FOV",Min=50,Max=500,Default=250,Callback=function(value) AimbotSettings.FOV=value if FOVCircle then FOVCircle.Radius=value end end})
		Player:CreateSlider({Name="Smoothness",Min=1,Max=20,Default=1,Callback=function(value) AimbotSettings.Smoothness=value end})
		Player:CreateDropdown({Name="Hit Part",Options=AimbotSettings.HitPartOptions,Default="Head",Callback=function(value) AimbotSettings.HitPart=value end})
		Player:CreateToggle({Name="Visible Check",Default=true,Callback=function(state) AimbotSettings.VisibleCheck=state end})
		Player:CreateToggle({Name="Team Check",Default=true,Callback=function(state) AimbotSettings.TeamCheck=state end})
		
		task.spawn(function()
			if not FOVCircle then
				FOVCircle = Drawing.new("Circle")
				FOVCircle.Thickness = 2
				FOVCircle.NumSides = 64
				FOVCircle.Radius = AimbotSettings.FOV
				FOVCircle.Filled = false
				FOVCircle.Visible = false
				FOVCircle.ZIndex = 999
				FOVCircle.Transparency = 1
				FOVCircle.Color = Color3.fromRGB(255,255,255)
			end
		end)
		
		RS.RenderStepped:Connect(function()
			if FOVCircle then
				FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
			end
			if AimbotSettings.Enabled and AimbotSettings.TriggerKey and UIS:IsKeyDown(AimbotSettings.TriggerKey) then
				local closest,closestDist = nil,AimbotSettings.FOV
				for _,p in ipairs(Players:GetPlayers()) do
					if p~=LP and p.Character and p.Character:FindFirstChild(AimbotSettings.HitPart) then
						local part = p.Character[AimbotSettings.HitPart]
						local pos,onscreen = Camera:WorldToViewportPoint(part.Position)
						if onscreen then
							local dist = (Vector2.new(pos.X,pos.Y)-Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)).Magnitude
							if dist<closestDist then
								if AimbotSettings.VisibleCheck then
									local ray = workspace:FindPartOnRayWithIgnoreList(Ray.new(Camera.CFrame.Position,(part.Position-Camera.CFrame.Position).Unit*(part.Position-Camera.CFrame.Position).Magnitude),{LP.Character,Camera})
									if not ray or not ray:IsDescendantOf(p.Character) then continue end
								end
								if AimbotSettings.TeamCheck and p.Team==LP.Team then continue end
								closest = part
								closestDist = dist
							end
						end
					end
				end
				if closest then
					local targetPos = closest.Position
					local currentCam = Camera.CFrame
					local newCam = CFrame.new(currentCam.Position,targetPos)
					Camera.CFrame = currentCam:Lerp(newCam,1/AimbotSettings.Smoothness)
				end
			end
		end)
		
		Player:CreateSection("Movement")
		
		local wsEnabled = false
		local wsValue = 16
		local wsMethod = "Heartbeat"
		
		Player:CreateToggle({Name="Custom WalkSpeed",Default=false,Callback=function(state)
			wsEnabled = state
			if state then
				if Connections.WS then Connections.WS:Disconnect() end
				Connections.WS = RS[wsMethod]:Connect(function()
					if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed=wsValue end
				end)
			else
				if Connections.WS then Connections.WS:Disconnect() Connections.WS=nil end
				if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed=16 end
			end
		end})
		
		Player:CreateSlider({Name="WalkSpeed Value",Min=16,Max=500,Default=16,Callback=function(value) wsValue=value end})
		Player:CreateDropdown({Name="WS Method",Options={"Heartbeat","RenderStepped","Stepped"},Default="Heartbeat",Callback=function(value)
			wsMethod = value
			if wsEnabled then
				if Connections.WS then Connections.WS:Disconnect() end
				Connections.WS = RS[wsMethod]:Connect(function()
					if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.WalkSpeed=wsValue end
				end)
			end
		end})
		
		local jpEnabled = false
		local jpValue = 50
		local jpMethod = "Heartbeat"
		
		Player:CreateToggle({Name="Custom JumpPower",Default=false,Callback=function(state)
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
				if Connections.JP then Connections.JP:Disconnect() Connections.JP=nil end
				if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.JumpPower=50 end
			end
		end})
		
		Player:CreateSlider({Name="JumpPower Value",Min=50,Max=500,Default=50,Callback=function(value) jpValue=value end})
		Player:CreateDropdown({Name="JP Method",Options={"Heartbeat","RenderStepped","Stepped"},Default="Heartbeat",Callback=function(value)
			jpMethod = value
			if jpEnabled then
				if Connections.JP then Connections.JP:Disconnect() end
				Connections.JP = RS[jpMethod]:Connect(function()
					if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.UseJumpPower=true LP.Character.Humanoid.JumpPower=jpValue end
				end)
			end
		end})
		
		Player:CreateSection("Flight")
		
		local flying = false
		local flySpeed = 50
		local flyMethod = "BodyVelocity"
		local flyBV = nil
		local flyBG = nil
		
		Player:CreateKeybind({Name="Fly Toggle",Default=nil,Mode="Toggle",Callback=function(key,active)
			flying = active
			local character = LP.Character
			if not character then return end
			local hrp = character:FindFirstChild("HumanoidRootPart")
			if not hrp then return end
			
			if active then
				if flyMethod=="BodyVelocity" then
					if flyBV then flyBV:Destroy() end
					if flyBG then flyBG:Destroy() end
					flyBG = Instance.new("BodyGyro")
					flyBV = Instance.new("BodyVelocity")
					flyBG.P = 9e4
					flyBG.maxTorque = Vector3.new(9e9,9e9,9e9)
					flyBG.cframe = hrp.CFrame
					flyBG.Parent = hrp
					flyBV.velocity = Vector3.zero
					flyBV.maxForce = Vector3.new(9e9,9e9,9e9)
					flyBV.Parent = hrp
					if Connections.Fly then Connections.Fly:Disconnect() end
					Connections.Fly = RS.Heartbeat:Connect(function()
						if not flying or not character or not hrp or not hrp.Parent then
							if flyBG then flyBG:Destroy() flyBG=nil end
							if flyBV then flyBV:Destroy() flyBV=nil end
							if Connections.Fly then Connections.Fly:Disconnect() Connections.Fly=nil end
							return
						end
						local cam = workspace.CurrentCamera
						flyBG.cframe = cam.CFrame
						local velocity = Vector3.zero
						if UIS:IsKeyDown(Enum.KeyCode.W) then velocity=velocity+(cam.CFrame.LookVector*flySpeed) end
						if UIS:IsKeyDown(Enum.KeyCode.S) then velocity=velocity-(cam.CFrame.LookVector*flySpeed) end
						if UIS:IsKeyDown(Enum.KeyCode.D) then velocity=velocity+(cam.CFrame.RightVector*flySpeed) end
						if UIS:IsKeyDown(Enum.KeyCode.A) then velocity=velocity-(cam.CFrame.RightVector*flySpeed) end
						if UIS:IsKeyDown(Enum.KeyCode.Space) then velocity=velocity+Vector3.new(0,flySpeed,0) end
						if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then velocity=velocity-Vector3.new(0,flySpeed,0) end
						flyBV.velocity = velocity
					end)
				elseif flyMethod=="CFrame" then
					if Connections.Fly then Connections.Fly:Disconnect() end
					Connections.Fly = RS.Heartbeat:Connect(function()
						if not flying or not character or not hrp or not hrp.Parent then
							if Connections.Fly then Connections.Fly:Disconnect() Connections.Fly=nil end
							return
						end
						local cam = workspace.CurrentCamera
						local velocity = Vector3.zero
						if UIS:IsKeyDown(Enum.KeyCode.W) then velocity=velocity+(cam.CFrame.LookVector*flySpeed*0.05) end
						if UIS:IsKeyDown(Enum.KeyCode.S) then velocity=velocity-(cam.CFrame.LookVector*flySpeed*0.05) end
						if UIS:IsKeyDown(Enum.KeyCode.D) then velocity=velocity+(cam.CFrame.RightVector*flySpeed*0.05) end
						if UIS:IsKeyDown(Enum.KeyCode.A) then velocity=velocity-(cam.CFrame.RightVector*flySpeed*0.05) end
						if UIS:IsKeyDown(Enum.KeyCode.Space) then velocity=velocity+Vector3.new(0,flySpeed*0.05,0) end
						if UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then velocity=velocity-Vector3.new(0,flySpeed*0.05,0) end
						hrp.CFrame = hrp.CFrame+velocity
					end)
				end
			else
				if flyBG then flyBG:Destroy() flyBG=nil end
				if flyBV then flyBV:Destroy() flyBV=nil end
				if Connections.Fly then Connections.Fly:Disconnect() Connections.Fly=nil end
			end
		end})
		
		Player:CreateSlider({Name="Fly Speed",Min=10,Max=200,Default=50,Callback=function(value) flySpeed=value end})
		Player:CreateDropdown({Name="Fly Method",Options={"BodyVelocity","CFrame"},Default="BodyVelocity",Callback=function(value) flyMethod=value end})
		
		Player:CreateSection("Noclip")
		
		local noclipEnabled = false
		local noclipMethod = "Loop"
		local noclipInterval = 0.3
		
		Player:CreateToggle({Name="Enable Noclip",Default=false,Callback=function(state)
			noclipEnabled = state
			if state then
				if noclipMethod=="Loop" then
					if Connections.Noclip then task.cancel(Connections.Noclip) end
					Connections.Noclip = task.spawn(function()
						while noclipEnabled do
							if LP.Character then
								for _,v in pairs(LP.Character:GetDescendants()) do
									if v:IsA("BasePart") then pcall(function() v.CanCollide=false end) end
								end
							end
							task.wait(noclipInterval)
						end
					end)
				elseif noclipMethod=="Stepped" then
					if Connections.Noclip then Connections.Noclip:Disconnect() end
					Connections.Noclip = RS.Stepped:Connect(function()
						if LP.Character then
							for _,v in pairs(LP.Character:GetDescendants()) do
								if v:IsA("BasePart") then pcall(function() v.CanCollide=false end) end
							end
						end
					end)
				end
			else
				if Connections.Noclip then
					if type(Connections.Noclip)=="thread" then task.cancel(Connections.Noclip)
					else Connections.Noclip:Disconnect() end
					Connections.Noclip = nil
				end
				if LP.Character then for _,v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then pcall(function() v.CanCollide=true end) end end end
			end
		end})
		
		Player:CreateDropdown({Name="Noclip Method",Options={"Loop","Stepped"},Default="Loop",Callback=function(value)
			noclipMethod = value
			if noclipEnabled then
				if Connections.Noclip then
					if type(Connections.Noclip)=="thread" then task.cancel(Connections.Noclip)
					else Connections.Noclip:Disconnect() end
					Connections.Noclip = nil
				end
				if noclipMethod=="Loop" then
					Connections.Noclip = task.spawn(function()
						while noclipEnabled do
							if LP.Character then for _,v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then pcall(function() v.CanCollide=false end) end end end
							task.wait(noclipInterval)
						end
					end)
				elseif noclipMethod=="Stepped" then
					Connections.Noclip = RS.Stepped:Connect(function()
						if LP.Character then for _,v in pairs(LP.Character:GetDescendants()) do if v:IsA("BasePart") then pcall(function() v.CanCollide=false end) end end end
					end)
				end
			end
		end})
		
		Player:CreateSlider({Name="Loop Interval",Min=1,Max=10,Default=3,Callback=function(value) noclipInterval=value/10 end})
		
		Player:CreateSection("Click TP")
		
		Player:CreateKeybind({Name="Click TP Key",Default=nil,Mode="Hold",Callback=function(key,active)
			if not active then return end
			local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local mouse = LP:GetMouse()
				if mouse.Target then hrp.CFrame=CFrame.new(mouse.Hit.Position+Vector3.new(0,3,0)) end
			end
		end})
		
		Player:CreateSection("Character")
		
		Player:CreateButton({Name="Reset Character",Callback=function()
			if LP.Character and LP.Character:FindFirstChild("Humanoid") then LP.Character.Humanoid.Health=0 end
		end})
		
		local invisParts = {}
		Player:CreateToggle({Name="Invisibility",Default=false,Callback=function(state)
			if state then
				if LP.Character then
					for _,descendant in pairs(LP.Character:GetDescendants()) do
						if descendant:IsA("BasePart") then invisParts[descendant]=descendant.Transparency descendant.Transparency=1
						elseif descendant:IsA("Decal") then invisParts[descendant]=descendant.Transparency descendant.Transparency=1 end
					end
				end
			else
				for part,transparency in pairs(invisParts) do if part and part.Parent then part.Transparency=transparency end end
				invisParts = {}
			end
		end})
		
		Player:CreateToggle({Name="Fling",Default=false,Callback=function(state)
			if state then
				if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
					local hrp = LP.Character.HumanoidRootPart
					local bav = Instance.new("BodyAngularVelocity")
					bav.Name = GenerateRandomString(10)
					bav.Parent = hrp
					bav.MaxTorque = Vector3.new(0,math.huge,0)
					bav.P = 9e9
					bav.AngularVelocity = Vector3.new(0,9e9,0)
					Connections.Fling = bav
				end
			else
				if Connections.Fling then Connections.Fling:Destroy() Connections.Fling=nil end
			end
		end})
		
		Player:CreateSection("World")
		
		Player:CreateButton({Name="Fullbright",Callback=function() Lighting.Brightness=2 Lighting.Ambient=Color3.new(1,1,1) end})
		Player:CreateButton({Name="Remove Fog",Callback=function() Lighting.FogEnd=999999 end})
		Player:CreateButton({Name="Fix Lighting",Callback=function() Lighting.Brightness=1 Lighting.Ambient=Color3.new(0.5,0.5,0.5) Lighting.FogEnd=100000 end})
		
		Player:CreateSection("Server")
		
		Player:CreateButton({Name="Rejoin Server",Callback=function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId) end})
		Player:CreateButton({Name="Server Hop",Callback=function()
			local servers = {}
			local s,result = pcall(function() return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100") end)
			if s then
				local data = Http:JSONDecode(result)
				for _,server in pairs(data.data) do if server.id~=game.JobId and server.playing<server.maxPlayers then table.insert(servers,server.id) end end
				if #servers>0 then TeleportService:TeleportToPlaceInstance(game.PlaceId,servers[math.random(1,#servers)]) end
			end
		end})
	end
	
	local scriptLibrary = {}
	
	local function CreateScriptHub()
		local ScriptHub = Tabs:CreateTab("Script Hub","rbxassetid://10723434711")
		
		ScriptHub:CreateSection("Custom Scripts")
		
		ScriptHub:CreateInput({Name="Script Name",Placeholder="Enter script name...",Callback=function(text)
			scriptLibrary.currentName = text
		end})
		
		ScriptHub:CreateInput({Name="Script URL",Placeholder="https://...",Callback=function(text)
			scriptLibrary.currentURL = text
		end})
		
		ScriptHub:CreateButton({Name="Add Script",Callback=function()
			if scriptLibrary.currentName and scriptLibrary.currentURL then
				if not scriptLibrary.scripts then scriptLibrary.scripts = {} end
				table.insert(scriptLibrary.scripts,{Name=scriptLibrary.currentName,URL=scriptLibrary.currentURL})
				scriptLibrary.currentName = nil
				scriptLibrary.currentURL = nil
			end
		end})
		
		ScriptHub:CreateSection("Execute Scripts")
		
		ScriptHub:CreateButton({Name="Execute from Clipboard",Callback=function()
			local clipboard = getclipboard()
			if clipboard then loadstring(clipboard)() end
		end})
		
		ScriptHub:CreateButton({Name="Load Script from URL",Callback=function()
			if scriptLibrary.currentURL then
				local s,script = pcall(function() return game:HttpGet(scriptLibrary.currentURL) end)
				if s then loadstring(script)() end
			end
		end})
		
		ScriptHub:CreateSection("Saved Scripts")
		
		if scriptLibrary.scripts then
			for _,script in ipairs(scriptLibrary.scripts) do
				ScriptHub:CreateButton({Name=script.Name,Callback=function()
					local s,scr = pcall(function() return game:HttpGet(script.URL) end)
					if s then loadstring(scr)() end
				end})
			end
		end
	end
	
	CreateScriptHub()
	
	local SettingsPage = Instance.new("ScrollingFrame")
	SettingsPage.Name = GenerateRandomString(12)
	SettingsPage.Size = UDim2.new(1,0,1,0)
	SettingsPage.BackgroundTransparency = 1
	SettingsPage.BorderSizePixel = 0
	SettingsPage.ScrollBarThickness = 4
	SettingsPage.ScrollBarImageColor3 = Theme.Stroke
	SettingsPage.ScrollBarImageTransparency = 0.3
	SettingsPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
	SettingsPage.CanvasSize = UDim2.new(0,0,0,0)
	SettingsPage.Visible = false
	SettingsPage.ZIndex = 2
	SettingsPage.Parent = Pages
	
	local SettingsLayout = Instance.new("UIListLayout")
	SettingsLayout.Padding = UDim.new(0,15)
	SettingsLayout.Parent = SettingsPage
	Padding(SettingsPage,15,20,20,15)
	
	local function CreateSettingsSection(text)
		local section = Instance.new("TextLabel")
		section.Text = string.upper(text)
		section.Size = UDim2.new(1,0,0,26)
		section.BackgroundTransparency = 1
		section.TextColor3 = Theme.Accent
		section.Font = Enum.Font.GothamBold
		section.TextSize = 11
		section.TextXAlignment = Enum.TextXAlignment.Left
		section.ZIndex = 2
		section.Parent = SettingsPage
		Padding(section,8,0,0,0)
		return section
	end
	
	local function CreateSettingsButton(text,callback)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1,0,0,42)
		button.BackgroundColor3 = Theme.Element
		button.AutoButtonColor = false
		button.Text = ""
		button.ZIndex = 2
		button.Parent = SettingsPage
		Corner(button,6)
		Stroke(button,Theme.Stroke,1)
		local label = Instance.new("TextLabel")
		label.Text = text
		label.Size = UDim2.new(1,-20,1,0)
		label.Position = UDim2.new(0,15,0,0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Theme.Text
		label.Font = Enum.Font.GothamSemibold
		label.TextSize = 13
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.ZIndex = 2
		label.Parent = button
		button.MouseEnter:Connect(function() Tween(button,{BackgroundColor3=Theme.ElementHover}) end)
		button.MouseLeave:Connect(function() Tween(button,{BackgroundColor3=Theme.Element}) end)
		button.MouseButton1Click:Connect(function() if callback then callback(label) end end)
		return button,label
	end
	
	CreateSettingsSection("Menu Controls")
	
	local keybindListToggle = Instance.new("Frame")
	keybindListToggle.Size = UDim2.new(1,0,0,42)
	keybindListToggle.BackgroundColor3 = Theme.Element
	keybindListToggle.ZIndex = 2
	keybindListToggle.Parent = SettingsPage
	Corner(keybindListToggle,6)
	Stroke(keybindListToggle,Theme.Stroke,1)
	
	local kbLabel = Instance.new("TextLabel")
	kbLabel.Text = "Keybind List"
	kbLabel.Size = UDim2.new(1,-70,1,0)
	kbLabel.Position = UDim2.new(0,15,0,0)
	kbLabel.BackgroundTransparency = 1
	kbLabel.TextColor3 = Theme.Text
	kbLabel.Font = Enum.Font.GothamSemibold
	kbLabel.TextSize = 13
	kbLabel.TextXAlignment = Enum.TextXAlignment.Left
	kbLabel.ZIndex = 2
	kbLabel.Parent = keybindListToggle
	
	local kbSwitch = Instance.new("Frame")
	kbSwitch.Size = UDim2.new(0,42,0,22)
	kbSwitch.Position = UDim2.new(1,-55,0.5,-11)
	kbSwitch.BackgroundColor3 = Theme.Main
	kbSwitch.BorderSizePixel = 0
	kbSwitch.ZIndex = 2
	kbSwitch.Parent = keybindListToggle
	Corner(kbSwitch,11)
	
	local kbDot = Instance.new("Frame")
	kbDot.Size = UDim2.new(0,18,0,18)
	kbDot.Position = UDim2.new(0,2,0.5,-9)
	kbDot.BackgroundColor3 = Theme.Text
	kbDot.BorderSizePixel = 0
	kbDot.ZIndex = 2
	kbDot.Parent = kbSwitch
	Corner(kbDot,9)
	
	keybindListToggle.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 then
			KeybindListVisible = not KeybindListVisible
			KeybindListFrame.Visible = KeybindListVisible
			Tween(kbSwitch,{BackgroundColor3=KeybindListVisible and Theme.Accent or Theme.Main},0.2)
			Tween(kbDot,{Position=KeybindListVisible and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)},0.2)
		end
	end)
	
	local keybindFrame = Instance.new("Frame")
	keybindFrame.Size = UDim2.new(1,0,0,42)
	keybindFrame.BackgroundColor3 = Theme.Element
	keybindFrame.ZIndex = 2
	keybindFrame.Parent = SettingsPage
	Corner(keybindFrame,6)
	Stroke(keybindFrame,Theme.Stroke,1)
	
	local keybindLabel = Instance.new("TextLabel")
	keybindLabel.Text = "Toggle Keybind"
	keybindLabel.Size = UDim2.new(1,-120,1,0)
	keybindLabel.Position = UDim2.new(0,15,0,0)
	keybindLabel.BackgroundTransparency = 1
	keybindLabel.TextColor3 = Theme.Text
	keybindLabel.Font = Enum.Font.GothamSemibold
	keybindLabel.TextSize = 13
	keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
	keybindLabel.ZIndex = 2
	keybindLabel.Parent = keybindFrame
	
	local keybindButton = Instance.new("TextButton")
	keybindButton.Text = ToggleKeybind and "["..ToggleKeybind.Name.."]" or "[NONE]"
	keybindButton.Size = UDim2.new(0,100,0,26)
	keybindButton.Position = UDim2.new(1,-110,0.5,-13)
	keybindButton.BackgroundColor3 = Theme.Main
	keybindButton.TextColor3 = Theme.Accent
	keybindButton.Font = Enum.Font.GothamBold
	keybindButton.TextSize = 12
	keybindButton.AutoButtonColor = false
	keybindButton.ZIndex = 2
	keybindButton.Parent = keybindFrame
	Corner(keybindButton,4)
	
	local keybindListening = false
	keybindButton.MouseButton1Click:Connect(function() keybindListening=true keybindButton.Text="..." keybindButton.TextColor3=Theme.Text end)
	
	UIS.InputBegan:Connect(function(input,gameProcessed)
		if keybindListening then
			if input.KeyCode==Enum.KeyCode.Escape then ToggleKeybind=nil keybindButton.Text="[NONE]" keybindButton.TextColor3=Theme.Accent keybindListening=false
			elseif input.UserInputType==Enum.UserInputType.Keyboard and not gameProcessed then ToggleKeybind=input.KeyCode keybindButton.Text="["..input.KeyCode.Name.."]" keybindButton.TextColor3=Theme.Accent keybindListening=false end
		end
	end)
	
	CreateSettingsSection("Theme & Config Management")
	
	local splitFrame = Instance.new("Frame")
	splitFrame.Size = UDim2.new(1,0,0,600)
	splitFrame.BackgroundTransparency = 1
	splitFrame.ZIndex = 2
	splitFrame.Parent = SettingsPage
	
	local leftSide = Instance.new("Frame")
	leftSide.Size = UDim2.new(0.48,0,1,0)
	leftSide.BackgroundColor3 = Theme.Element
	leftSide.ZIndex = 2
	leftSide.Parent = splitFrame
	Corner(leftSide,6)
	Stroke(leftSide,Theme.Stroke,1)
	
	local leftTitle = Instance.new("TextLabel")
	leftTitle.Text = "THEME EDITOR"
	leftTitle.Size = UDim2.new(1,0,0,30)
	leftTitle.BackgroundTransparency = 1
	leftTitle.TextColor3 = Theme.Accent
	leftTitle.Font = Enum.Font.GothamBold
	leftTitle.TextSize = 12
	leftTitle.ZIndex = 3
	leftTitle.Parent = leftSide
	
	local leftScroll = Instance.new("ScrollingFrame")
	leftScroll.Size = UDim2.new(1,0,1,-30)
	leftScroll.Position = UDim2.new(0,0,0,30)
	leftScroll.BackgroundTransparency = 1
	leftScroll.ScrollBarThickness = 3
	leftScroll.ScrollBarImageColor3 = Theme.Stroke
	leftScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	leftScroll.ZIndex = 3
	leftScroll.Parent = leftSide
	
	local leftLayout = Instance.new("UIListLayout")
	leftLayout.Padding = UDim.new(0,8)
	leftLayout.Parent = leftScroll
	Padding(leftScroll,8,8,8,8)
	
	local rightSide = Instance.new("Frame")
	rightSide.Size = UDim2.new(0.48,0,1,0)
	rightSide.Position = UDim2.new(0.52,0,0,0)
	rightSide.BackgroundColor3 = Theme.Element
	rightSide.ZIndex = 2
	rightSide.Parent = splitFrame
	Corner(rightSide,6)
	Stroke(rightSide,Theme.Stroke,1)
	
	local rightTitle = Instance.new("TextLabel")
	rightTitle.Text = "CONFIG MANAGER"
	rightTitle.Size = UDim2.new(1,0,0,30)
	rightTitle.BackgroundTransparency = 1
	rightTitle.TextColor3 = Theme.Accent
	rightTitle.Font = Enum.Font.GothamBold
	rightTitle.TextSize = 12
	rightTitle.ZIndex = 3
	rightTitle.Parent = rightSide
	
	local rightScroll = Instance.new("ScrollingFrame")
	rightScroll.Size = UDim2.new(1,0,1,-30)
	rightScroll.Position = UDim2.new(0,0,0,30)
	rightScroll.BackgroundTransparency = 1
	rightScroll.ScrollBarThickness = 3
	rightScroll.ScrollBarImageColor3 = Theme.Stroke
	rightScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	rightScroll.ZIndex = 3
	rightScroll.Parent = rightSide
	
	local rightLayout = Instance.new("UIListLayout")
	rightLayout.Padding = UDim.new(0,8)
	rightLayout.Parent = rightScroll
	Padding(rightScroll,8,8,8,8)
	
	CreateSettingsButton("Unload Hub",function()
		for _,connection in pairs(Connections) do if connection and connection.Disconnect then connection:Disconnect() end end
		Tween(Main,{Size=UDim2.new(0,0,0,0)},0.3)
		task.wait(0.3)
		ScreenGui:Destroy()
	end)
	
	local SettingsButton = Instance.new("TextButton")
	SettingsButton.Name = "SettingsBtn"
	SettingsButton.Size = UDim2.new(1,-20,1,-5)
	SettingsButton.Position = UDim2.new(0,10,0,0)
	SettingsButton.BackgroundTransparency = 1
	SettingsButton.BackgroundColor3 = Theme.Element
	SettingsButton.AutoButtonColor = false
	SettingsButton.Text = ""
	SettingsButton.LayoutOrder = 999
	SettingsButton.Parent = SettingsArea
	Corner(SettingsButton,6)
	
	local SettingsIcon = Instance.new("ImageLabel")
	SettingsIcon.Name = GenerateRandomString(10)
	SettingsIcon.Size = UDim2.new(0,18,0,18)
	SettingsIcon.Position = UDim2.new(0,12,0.5,-9)
	SettingsIcon.BackgroundTransparency = 1
	SettingsIcon.Image = DefaultIcons.Settings
	SettingsIcon.ImageColor3 = Theme.TextDim
	SettingsIcon.Parent = SettingsButton
	
	local SettingsLabel = Instance.new("TextLabel")
	SettingsLabel.Name = GenerateRandomString(10)
	SettingsLabel.Text = "Settings"
	SettingsLabel.Size = UDim2.new(1,-50,1,0)
	SettingsLabel.Position = UDim2.new(0,42,0,0)
	SettingsLabel.BackgroundTransparency = 1
	SettingsLabel.TextColor3 = Theme.TextDim
	SettingsLabel.Font = Enum.Font.GothamMedium
	SettingsLabel.TextSize = 14
	SettingsLabel.TextXAlignment = Enum.TextXAlignment.Left
	SettingsLabel.Parent = SettingsButton
	
	SettingsButton.MouseEnter:Connect(function() if ActiveTab~="Settings" then Tween(SettingsButton,{BackgroundColor3=Theme.Element,BackgroundTransparency=0.5}) end end)
	SettingsButton.MouseLeave:Connect(function() if ActiveTab~="Settings" then Tween(SettingsButton,{BackgroundTransparency=1}) end end)
	
	SettingsButton.MouseButton1Click:Connect(function()
		for _,tab in pairs(TabContainer:GetChildren()) do
			if tab:IsA("TextButton") then Tween(tab,{BackgroundTransparency=1}) if tab:FindFirstChild("Label") then Tween(tab.Label,{TextColor3=Theme.TextDim}) end if tab:FindFirstChild("Icon") then Tween(tab.Icon,{ImageColor3=Theme.TextDim}) end end
		end
		for _,page in pairs(Pages:GetChildren()) do if page:IsA("ScrollingFrame") then page.Visible=false end end
		SettingsPage.Visible = true
		ActiveTab = "Settings"
		Tween(SettingsButton,{BackgroundColor3=Theme.Element,BackgroundTransparency=0})
		Tween(SettingsLabel,{TextColor3=Theme.Text})
		Tween(SettingsIcon,{ImageColor3=Theme.Accent})
	end)
	
	if AutoLoad then
		local autoloadName = GameConfig and tostring(game.PlaceId) or "default"
		local configData = LoadConfig(autoloadName)
		if configData and configData.theme then for key,value in pairs(configData.theme) do Theme[key]=value end end
	end
	
	CurrentWindow = Tabs
	return Tabs
end

return Chuddy
