local UIS=game:GetService("UserInputService")
local TS=game:GetService("TweenService")
local Players=game:GetService("Players")
local LP=Players.LocalPlayer
local RS=game:GetService("RunService")
local Http=game:GetService("HttpService")
local Lighting=game:GetService("Lighting")
local TeleportService=game:GetService("TeleportService")

local Chuddy={}
local Connections={}

local ThemePresets={
	Chudjak={Name="Chudjak Classic",Main=Color3.fromRGB(18,18,20),Sidebar=Color3.fromRGB(24,24,26),Element=Color3.fromRGB(30,30,33),ElementHover=Color3.fromRGB(38,38,41),Text=Color3.fromRGB(240,240,240),TextDim=Color3.fromRGB(140,140,140),Accent=Color3.fromRGB(114,137,218),Stroke=Color3.fromRGB(45,45,48),Divider=Color3.fromRGB(35,35,38)},
	Gigachad={Name="Gigachad Gold",Main=Color3.fromRGB(20,20,22),Sidebar=Color3.fromRGB(25,25,27),Element=Color3.fromRGB(35,32,28),ElementHover=Color3.fromRGB(45,42,35),Text=Color3.fromRGB(255,215,0),TextDim=Color3.fromRGB(180,155,60),Accent=Color3.fromRGB(255,215,0),Stroke=Color3.fromRGB(60,55,40),Divider=Color3.fromRGB(50,48,35)},
	Soyjak={Name="Soyjak Soy",Main=Color3.fromRGB(15,20,15),Sidebar=Color3.fromRGB(20,25,20),Element=Color3.fromRGB(25,35,25),ElementHover=Color3.fromRGB(30,45,30),Text=Color3.fromRGB(144,238,144),TextDim=Color3.fromRGB(100,180,100),Accent=Color3.fromRGB(50,205,50),Stroke=Color3.fromRGB(40,80,40),Divider=Color3.fromRGB(30,60,30)}
}

local Theme=table.clone(ThemePresets.Chudjak)

local Icons={
	Close="rbxassetid://10747384394",
	Minimize="rbxassetid://96827055055093",
	Maximize="rbxassetid://81244221021568",
	Settings="rbxassetid://10734949856",
	User="rbxassetid://10747372992",
	Dropdown="rbxassetid://10709790948"
}

local function Tween(obj,props,time)
	if not obj or not obj.Parent then return end
	TS:Create(obj,TweenInfo.new(time or 0.2,Enum.EasingStyle.Quad),props):Play()
end

local function GetParent()
	return pcall(gethui)and gethui()or LP:WaitForChild("PlayerGui")
end

local function Corner(p,r)
	local c=Instance.new("UICorner")
	c.CornerRadius=UDim.new(0,r or 6)
	c.Parent=p
	return c
end

local function Stroke(p,col,t)
	local s=Instance.new("UIStroke")
	s.Color=col or Theme.Stroke
	s.Thickness=t or 1
	s.Parent=p
	return s
end

local function Padding(p,t,l,r,b)
	local pad=Instance.new("UIPadding")
	pad.PaddingTop=UDim.new(0,t or 0)
	pad.PaddingLeft=UDim.new(0,l or 0)
	pad.PaddingRight=UDim.new(0,r or 0)
	pad.PaddingBottom=UDim.new(0,b or 0)
	pad.Parent=p
	return pad
end

local ConfigFolder="ChuddyHub"

local function SaveConfig(name,data)
	if not isfolder(ConfigFolder)then makefolder(ConfigFolder)end
	writefile(ConfigFolder.."/"..name..".json",Http:JSONEncode(data))
end

local function LoadConfig(name)
	local path=ConfigFolder.."/"..name..".json"
	if isfile(path)then return Http:JSONDecode(readfile(path))end
	return nil
end

local function ApplyTheme(newTheme)
	for k,v in pairs(newTheme)do Theme[k]=v end
end

local function ExportTheme()
	return Http:JSONEncode(Theme)
end

function Chuddy:CreateWindow(cfg)
	cfg=cfg or{}
	local WinName=cfg.Name or"Chuddy Hub"
	local Keybind=cfg.Keybind or Enum.KeyCode.RightControl
	local GameConfig=cfg.GameConfig~=false
	
	for _,v in pairs(getconnections(LP.Idled))do v:Disable()end
	
	local SGui=Instance.new("ScreenGui")
	SGui.Name="ChuddyUI_"..game.PlaceId
	SGui.ResetOnSpawn=false
	SGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
	SGui.Parent=GetParent()
	
	local Main=Instance.new("Frame")
	Main.Name="Main"
	Main.Size=UDim2.new(0,750,0,550)
	Main.Position=UDim2.new(0.5,-375,0.5,-275)
	Main.BackgroundColor3=Theme.Main
	Main.BorderSizePixel=0
	Main.ClipsDescendants=true
	Main.Parent=SGui
	Corner(Main,8)
	Stroke(Main,Theme.Stroke,1)
	
	local Sidebar=Instance.new("Frame")
	Sidebar.Name="Sidebar"
	Sidebar.Size=UDim2.new(0,210,1,0)
	Sidebar.BackgroundColor3=Theme.Sidebar
	Sidebar.BorderSizePixel=0
	Sidebar.Parent=Main
	
	local SidebarLine=Instance.new("Frame")
	SidebarLine.Size=UDim2.new(0,1,1,0)
	SidebarLine.Position=UDim2.new(1,-1,0,0)
	SidebarLine.BackgroundColor3=Theme.Divider
	SidebarLine.BorderSizePixel=0
	SidebarLine.Parent=Sidebar
	
	local Header=Instance.new("Frame")
	Header.Size=UDim2.new(1,0,0,60)
	Header.BackgroundTransparency=1
	Header.Parent=Sidebar
	
	local Logo=Instance.new("ImageLabel")
	Logo.Size=UDim2.new(0,30,0,30)
	Logo.Position=UDim2.new(0,15,0.5,-15)
	Logo.BackgroundTransparency=1
	Logo.Image="rbxassetid://120758864298455"
	Logo.Parent=Header
	Corner(Logo,5)
	
	local Title=Instance.new("TextLabel")
	Title.Text=WinName
	Title.Size=UDim2.new(1,-60,1,0)
	Title.Position=UDim2.new(0,55,0,0)
	Title.BackgroundTransparency=1
	Title.TextColor3=Theme.Text
	Title.Font=Enum.Font.GothamBold
	Title.TextSize=15
	Title.TextXAlignment=Enum.TextXAlignment.Left
	Title.TextTruncate=Enum.TextTruncate.AtEnd
	Title.Parent=Header
	
	local UserProfile=Instance.new("Frame")
	UserProfile.Size=UDim2.new(1,0,0,65)
	UserProfile.Position=UDim2.new(0,0,1,-65)
	UserProfile.BackgroundColor3=Theme.Sidebar
	UserProfile.BorderSizePixel=0
	UserProfile.Parent=Sidebar
	
	local ProfileLine=Instance.new("Frame")
	ProfileLine.Size=UDim2.new(1,-20,0,1)
	ProfileLine.Position=UDim2.new(0,10,0,0)
	ProfileLine.BackgroundColor3=Theme.Divider
	ProfileLine.BorderSizePixel=0
	ProfileLine.Parent=UserProfile
	
	local Avatar=Instance.new("ImageLabel")
	Avatar.Size=UDim2.new(0,36,0,36)
	Avatar.Position=UDim2.new(0,12,0.5,-18)
	Avatar.BackgroundColor3=Theme.Element
	Avatar.Parent=UserProfile
	Corner(Avatar,18)
	
	task.spawn(function()
		local s,t=pcall(function()return Players:GetUserThumbnailAsync(LP.UserId,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size48x48)end)
		if s then Avatar.Image=t end
	end)
	
	local Username=Instance.new("TextLabel")
	Username.Text=LP.Name
	Username.Size=UDim2.new(1,-60,0,20)
	Username.Position=UDim2.new(0,58,0.5,-10)
	Username.BackgroundTransparency=1
	Username.TextColor3=Theme.Text
	Username.Font=Enum.Font.GothamBold
	Username.TextSize=13
	Username.TextXAlignment=Enum.TextXAlignment.Left
	Username.TextTruncate=Enum.TextTruncate.AtEnd
	Username.Parent=UserProfile
	
	local Rank=Instance.new("TextLabel")
	Rank.Text="Certified Chad"
	Rank.Size=UDim2.new(1,-60,0,15)
	Rank.Position=UDim2.new(0,58,0.5,4)
	Rank.BackgroundTransparency=1
	Rank.TextColor3=Theme.Accent
	Rank.Font=Enum.Font.Gotham
	Rank.TextSize=11
	Rank.TextXAlignment=Enum.TextXAlignment.Left
	Rank.Parent=UserProfile
	
	local SettingsArea=Instance.new("Frame")
	SettingsArea.Size=UDim2.new(1,0,0,50)
	SettingsArea.Position=UDim2.new(0,0,1,-115)
	SettingsArea.BackgroundTransparency=1
	SettingsArea.Parent=Sidebar
	
	local TabContainer=Instance.new("ScrollingFrame")
	TabContainer.Size=UDim2.new(1,0,1,-175)
	TabContainer.Position=UDim2.new(0,0,0,60)
	TabContainer.BackgroundTransparency=1
	TabContainer.BorderSizePixel=0
	TabContainer.ScrollBarThickness=3
	TabContainer.ScrollBarImageColor3=Theme.Stroke
	TabContainer.ScrollBarImageTransparency=0.5
	TabContainer.AutomaticCanvasSize=Enum.AutomaticSize.Y
	TabContainer.CanvasSize=UDim2.new(0,0,0,0)
	TabContainer.Parent=Sidebar
	
	local TabList=Instance.new("UIListLayout")
	TabList.SortOrder=Enum.SortOrder.LayoutOrder
	TabList.Padding=UDim.new(0,4)
	TabList.Parent=TabContainer
	Padding(TabContainer,5,10,10,5)
	
	local Content=Instance.new("Frame")
	Content.Size=UDim2.new(1,-210,1,0)
	Content.Position=UDim2.new(0,210,0,0)
	Content.BackgroundTransparency=1
	Content.ClipsDescendants=true
	Content.Parent=Main
	
	local TopBar=Instance.new("Frame")
	TopBar.Size=UDim2.new(1,0,0,50)
	TopBar.BackgroundTransparency=1
	TopBar.Parent=Content
	
	local TopSep=Instance.new("Frame")
	TopSep.Size=UDim2.new(1,0,0,1)
	TopSep.Position=UDim2.new(0,0,1,-1)
	TopSep.BackgroundColor3=Theme.Divider
	TopSep.BorderSizePixel=0
	TopSep.Parent=TopBar
	
	local function WinControl(ico,typ)
		local btn=Instance.new("ImageButton")
		btn.Size=UDim2.new(0,32,0,32)
		btn.Position=UDim2.new(1,typ=="Close"and-42 or-82,0,9)
		btn.BackgroundColor3=Theme.Element
		btn.BorderSizePixel=0
		btn.Image=ico
		btn.ImageColor3=Theme.TextDim
		btn.Parent=TopBar
		Corner(btn,6)
		Padding(btn,8,8,8,8)
		btn.MouseEnter:Connect(function()Tween(btn,{ImageColor3=Theme.Text,BackgroundColor3=Theme.ElementHover})end)
		btn.MouseLeave:Connect(function()Tween(btn,{ImageColor3=Theme.TextDim,BackgroundColor3=Theme.Element})end)
		return btn
	end
	
	local CloseBtn=WinControl(Icons.Close,"Close")
	local MinBtn=WinControl(Icons.Minimize,"Min")
	
	CloseBtn.MouseButton1Click:Connect(function()
		for _,c in pairs(Connections)do
			if c and c.Disconnect then c:Disconnect()end
		end
		Tween(Main,{Size=UDim2.new(0,0,0,0)},0.3)
		task.wait(0.3)
		SGui:Destroy()
	end)
	
	local Minimized=false
	local OldSize=Main.Size
	local MinBar
	
	MinBtn.MouseButton1Click:Connect(function()
		Minimized=not Minimized
		
		if Minimized then
			OldSize=Main.Size
			local miniWidth=math.max(300,OldSize.X.Offset*0.4)
			local miniHeight=50
			Sidebar.Visible=false
			Content.Visible=false
			Tween(Main,{Size=UDim2.new(0,miniWidth,0,miniHeight)},0.3)
			
			MinBar=Instance.new("Frame")
			MinBar.Name="MinBar"
			MinBar.Size=UDim2.new(1,0,1,0)
			MinBar.BackgroundTransparency=1
			MinBar.Parent=Main
			
			local MinTitle=Instance.new("TextLabel")
			MinTitle.Text=WinName
			MinTitle.Size=UDim2.new(1,-100,1,0)
			MinTitle.Position=UDim2.new(0,15,0,0)
			MinTitle.BackgroundTransparency=1
			MinTitle.TextColor3=Theme.Text
			MinTitle.Font=Enum.Font.GothamBold
			MinTitle.TextSize=14
			MinTitle.TextXAlignment=Enum.TextXAlignment.Left
			MinTitle.Parent=MinBar
			
			local MaxBtn=Instance.new("ImageButton")
			MaxBtn.Size=UDim2.new(0,32,0,32)
			MaxBtn.Position=UDim2.new(1,-82,0.5,-16)
			MaxBtn.BackgroundColor3=Theme.Element
			MaxBtn.Image=Icons.Maximize
			MaxBtn.ImageColor3=Theme.TextDim
			MaxBtn.Parent=MinBar
			Corner(MaxBtn,6)
			Padding(MaxBtn,8,8,8,8)
			
			MaxBtn.MouseEnter:Connect(function()Tween(MaxBtn,{ImageColor3=Theme.Text,BackgroundColor3=Theme.ElementHover})end)
			MaxBtn.MouseLeave:Connect(function()Tween(MaxBtn,{ImageColor3=Theme.TextDim,BackgroundColor3=Theme.Element})end)
			
			MaxBtn.MouseButton1Click:Connect(function()
				Minimized=false
				if MinBar then MinBar:Destroy()end
				Tween(Main,{Size=OldSize},0.3)
				task.wait(0.25)
				Sidebar.Visible=true
				Content.Visible=true
			end)
			
			local MiniClose=Instance.new("ImageButton")
			MiniClose.Size=UDim2.new(0,32,0,32)
			MiniClose.Position=UDim2.new(1,-42,0.5,-16)
			MiniClose.BackgroundColor3=Theme.Element
			MiniClose.Image=Icons.Close
			MiniClose.ImageColor3=Theme.TextDim
			MiniClose.Parent=MinBar
			Corner(MiniClose,6)
			Padding(MiniClose,8,8,8,8)
			
			MiniClose.MouseEnter:Connect(function()Tween(MiniClose,{ImageColor3=Theme.Text,BackgroundColor3=Theme.ElementHover})end)
			MiniClose.MouseLeave:Connect(function()Tween(MiniClose,{ImageColor3=Theme.TextDim,BackgroundColor3=Theme.Element})end)
			
			MiniClose.MouseButton1Click:Connect(function()
				for _,c in pairs(Connections)do
					if c and c.Disconnect then c:Disconnect()end
				end
				Tween(Main,{Size=UDim2.new(0,0,0,0)},0.3)
				task.wait(0.3)
				SGui:Destroy()
			end)
			
			local dragging,dragStart,startPos
			MinBar.InputBegan:Connect(function(input)
				if input.UserInputType==Enum.UserInputType.MouseButton1 then
					dragging=true
					dragStart=input.Position
					startPos=Main.Position
					input.Changed:Connect(function()
						if input.UserInputState==Enum.UserInputState.End then dragging=false end
					end)
				end
			end)
			
			UIS.InputChanged:Connect(function(input)
				if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
					local delta=input.Position-dragStart
					Tween(Main,{Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)},0.05)
				end
			end)
		end
	end)
	
	local Pages=Instance.new("Frame")
	Pages.Size=UDim2.new(1,0,1,-50)
	Pages.Position=UDim2.new(0,0,0,50)
	Pages.BackgroundTransparency=1
	Pages.ClipsDescendants=true
	Pages.Parent=Content
	
	local dragging,dragStart,startPos
	
	local function MakeDraggable(frame)
		frame.InputBegan:Connect(function(input)
			if input.UserInputType==Enum.UserInputType.MouseButton1 and not Minimized then
				dragging=true
				dragStart=input.Position
				startPos=Main.Position
				input.Changed:Connect(function()
					if input.UserInputState==Enum.UserInputState.End then dragging=false end
				end)
			end
		end)
	end
	
	MakeDraggable(Sidebar)
	MakeDraggable(TopBar)
	
	UIS.InputChanged:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseMovement and dragging then
			local delta=input.Position-dragStart
			Tween(Main,{Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,startPos.Y.Scale,startPos.Y.Offset+delta.Y)},0.05)
		end
	end)
	
	local ResizeIndicator=Instance.new("Frame")
	ResizeIndicator.Size=UDim2.new(0,20,0,20)
	ResizeIndicator.Position=UDim2.new(1,-20,1,-20)
	ResizeIndicator.BackgroundTransparency=1
	ResizeIndicator.Parent=Main
	
	local Corner1=Instance.new("Frame")
	Corner1.Size=UDim2.new(0,2,0,10)
	Corner1.Position=UDim2.new(1,-2,1,-10)
	Corner1.BackgroundColor3=Theme.TextDim
	Corner1.BorderSizePixel=0
	Corner1.Parent=ResizeIndicator
	
	local Corner2=Instance.new("Frame")
	Corner2.Size=UDim2.new(0,10,0,2)
	Corner2.Position=UDim2.new(1,-10,1,-2)
	Corner2.BackgroundColor3=Theme.TextDim
	Corner2.BorderSizePixel=0
	Corner2.Parent=ResizeIndicator
	
	local Corner3=Instance.new("Frame")
	Corner3.Size=UDim2.new(0,2,0,6)
	Corner3.Position=UDim2.new(1,-6,1,-6)
	Corner3.BackgroundColor3=Theme.TextDim
	Corner3.BorderSizePixel=0
	Corner3.Parent=ResizeIndicator
	
	local Corner4=Instance.new("Frame")
	Corner4.Size=UDim2.new(0,6,0,2)
	Corner4.Position=UDim2.new(1,-6,1,-6)
	Corner4.BackgroundColor3=Theme.TextDim
	Corner4.BorderSizePixel=0
	Corner4.Parent=ResizeIndicator
	
	local resizing,resizeStart,startSize
	ResizeIndicator.InputBegan:Connect(function(input)
		if input.UserInputType==Enum.UserInputType.MouseButton1 then
			resizing=true
			resizeStart=input.Position
			startSize=Main.Size
			input.Changed:Connect(function()
				if input.UserInputState==Enum.UserInputState.End then resizing=false end
			end)
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if resizing and input.UserInputType==Enum.UserInputType.MouseMovement then
			local delta=input.Position-resizeStart
			local newW=math.clamp(startSize.X.Offset+delta.X,600,1400)
			local newH=math.clamp(startSize.Y.Offset+delta.Y,400,900)
			Tween(Main,{Size=UDim2.new(0,newW,0,newH)},0.05)
		end
	end)
	
	local Tabs={}
	local FirstTab=true
	local ActiveTab=nil
	local PlayerTabCreated=false
	
	function Tabs:CreateTab(name,icon)
		local TabBtn=Instance.new("TextButton")
		TabBtn.Name=name.."Tab"
		TabBtn.Size=UDim2.new(1,-20,0,40)
		TabBtn.BackgroundTransparency=1
		TabBtn.BackgroundColor3=Theme.Element
		TabBtn.AutoButtonColor=false
		TabBtn.Text=""
		TabBtn.LayoutOrder=name=="Player"and 999 or 1
		TabBtn.Parent=TabContainer
		Corner(TabBtn,6)
		
		local Ico=Instance.new("ImageLabel")
		Ico.Name="Icon"
		Ico.Size=UDim2.new(0,20,0,20)
		Ico.Position=UDim2.new(0,12,0.5,-10)
		Ico.BackgroundTransparency=1
		Ico.Image=icon or Icons.User
		Ico.ImageColor3=Theme.TextDim
		Ico.Parent=TabBtn
		
		local Lbl=Instance.new("TextLabel")
		Lbl.Name="Label"
		Lbl.Text=name
		Lbl.Size=UDim2.new(1,-50,1,0)
		Lbl.Position=UDim2.new(0,42,0,0)
		Lbl.BackgroundTransparency=1
		Lbl.TextColor3=Theme.TextDim
		Lbl.Font=Enum.Font.GothamMedium
		Lbl.TextSize=14
		Lbl.TextXAlignment=Enum.TextXAlignment.Left
		Lbl.TextTruncate=Enum.TextTruncate.AtEnd
		Lbl.Parent=TabBtn
		
		local Page=Instance.new("ScrollingFrame")
		Page.Name=name.."Page"
		Page.Size=UDim2.new(1,0,1,0)
		Page.BackgroundTransparency=1
		Page.BorderSizePixel=0
		Page.ScrollBarThickness=4
		Page.ScrollBarImageColor3=Theme.Stroke
		Page.ScrollBarImageTransparency=0.3
		Page.AutomaticCanvasSize=Enum.AutomaticSize.Y
		Page.CanvasSize=UDim2.new(0,0,0,0)
		Page.Visible=false
		Page.ClipsDescendants=true
		Page.Parent=Pages
		
		local PageList=Instance.new("UIListLayout")
		PageList.SortOrder=Enum.SortOrder.LayoutOrder
		PageList.Padding=UDim.new(0,8)
		PageList.Parent=Page
		Padding(Page,15,20,20,15)
		
		local function Activate()
			for _,tab in pairs(TabContainer:GetChildren())do
				if tab:IsA("TextButton")and tab~=TabBtn then
					Tween(tab,{BackgroundTransparency=1})
					if tab:FindFirstChild("Label")then Tween(tab.Label,{TextColor3=Theme.TextDim})end
					if tab:FindFirstChild("Icon")then Tween(tab.Icon,{ImageColor3=Theme.TextDim})end
				end
			end
			
			local SettingsBtn=SettingsArea:FindFirstChild("SettingsBtn")
			if SettingsBtn then
				Tween(SettingsBtn,{BackgroundTransparency=1})
				if SettingsBtn:FindFirstChild("Label")then Tween(SettingsBtn.Label,{TextColor3=Theme.TextDim})end
				if SettingsBtn:FindFirstChild("Icon")then Tween(SettingsBtn.Icon,{ImageColor3=Theme.TextDim})end
			end
			
			for _,page in pairs(Pages:GetChildren())do
				if page:IsA("ScrollingFrame")then page.Visible=false end
			end
			
			Page.Visible=true
			ActiveTab=name
			Tween(TabBtn,{BackgroundColor3=Theme.Element,BackgroundTransparency=0})
			Tween(Lbl,{TextColor3=Theme.Text})
			Tween(Ico,{ImageColor3=Theme.Accent})
		end
		
		TabBtn.MouseButton1Click:Connect(Activate)
		TabBtn.MouseEnter:Connect(function()
			if ActiveTab~=name then Tween(TabBtn,{BackgroundColor3=Theme.Element,BackgroundTransparency=0.5})end
		end)
		TabBtn.MouseLeave:Connect(function()
			if ActiveTab~=name then Tween(TabBtn,{BackgroundTransparency=1})end
		end)
		
		if FirstTab then
			FirstTab=false
			Activate()
		end
		
		local Elements={}
		
		function Elements:CreateSection(txt)
			local sec=Instance.new("TextLabel")
			sec.Text=string.upper(txt)
			sec.Size=UDim2.new(1,0,0,26)
			sec.BackgroundTransparency=1
			sec.TextColor3=Theme.Accent
			sec.Font=Enum.Font.GothamBold
			sec.TextSize=11
			sec.TextXAlignment=Enum.TextXAlignment.Left
			sec.Parent=Page
			Padding(sec,8,0,0,0)
		end
		
		function Elements:CreateLabel(cfg)
			cfg=cfg or{}
			local f=Instance.new("Frame")
			f.Size=UDim2.new(1,0,0,32)
			f.BackgroundTransparency=1
			f.Parent=Page
			local lbl=Instance.new("TextLabel")
			lbl.Text=cfg.Text or"Label"
			lbl.Size=UDim2.new(1,0,1,0)
			lbl.BackgroundTransparency=1
			lbl.TextColor3=Theme.TextDim
			lbl.Font=Enum.Font.Gotham
			lbl.TextSize=13
			lbl.TextXAlignment=Enum.TextXAlignment.Left
			lbl.TextWrapped=true
			lbl.Parent=f
			Padding(lbl,0,5,5,0)
			return{SetText=function(_,t)lbl.Text=t end}
		end
		
		function Elements:CreateButton(cfg)
			cfg=cfg or{}
			local btn=Instance.new("TextButton")
			btn.Size=UDim2.new(1,0,0,42)
			btn.BackgroundColor3=Theme.Element
			btn.AutoButtonColor=false
			btn.Text=""
			btn.Parent=Page
			Corner(btn,6)
			Stroke(btn,Theme.Stroke,1)
			local lbl=Instance.new("TextLabel")
			lbl.Text=cfg.Name or"Button"
			lbl.Size=UDim2.new(1,-60,1,0)
			lbl.Position=UDim2.new(0,15,0,0)
			lbl.BackgroundTransparency=1
			lbl.TextColor3=Theme.Text
			lbl.Font=Enum.Font.GothamSemibold
			lbl.TextSize=13
			lbl.TextXAlignment=Enum.TextXAlignment.Left
			lbl.TextTruncate=Enum.TextTruncate.AtEnd
			lbl.Parent=btn
			local ico=Instance.new("ImageLabel")
			ico.Size=UDim2.new(0,20,0,20)
			ico.Position=UDim2.new(1,-30,0.5,-10)
			ico.BackgroundTransparency=1
			ico.Image="rbxassetid://10709791437"
			ico.ImageColor3=Theme.TextDim
			ico.Parent=btn
			btn.MouseEnter:Connect(function()
				Tween(btn,{BackgroundColor3=Theme.ElementHover})
				Tween(ico,{ImageColor3=Theme.Accent})
			end)
			btn.MouseLeave:Connect(function()
				Tween(btn,{BackgroundColor3=Theme.Element})
				Tween(ico,{ImageColor3=Theme.TextDim})
			end)
			btn.MouseButton1Click:Connect(function()
				Tween(btn,{BackgroundColor3=Theme.Stroke},0.1)
				task.wait(0.1)
				Tween(btn,{BackgroundColor3=Theme.Element},0.1)
				if cfg.Callback then task.spawn(cfg.Callback)end
			end)
		end
		
		function Elements:CreateToggle(cfg)
			cfg=cfg or{}
			local state=cfg.Default or false
			local tog=Instance.new("TextButton")
			tog.Size=UDim2.new(1,0,0,42)
			tog.BackgroundColor3=Theme.Element
			tog.AutoButtonColor=false
			tog.Text=""
			tog.Parent=Page
			Corner(tog,6)
			Stroke(tog,Theme.Stroke,1)
			local lbl=Instance.new("TextLabel")
			lbl.Text=cfg.Name or"Toggle"
			lbl.Size=UDim2.new(1,-70,1,0)
			lbl.Position=UDim2.new(0,15,0,0)
			lbl.BackgroundTransparency=1
			lbl.TextColor3=Theme.Text
			lbl.Font=Enum.Font.GothamSemibold
			lbl.TextSize=13
			lbl.TextXAlignment=Enum.TextXAlignment.Left
			lbl.TextTruncate=Enum.TextTruncate.AtEnd
			lbl.Parent=tog
			local sw=Instance.new("Frame")
			sw.Size=UDim2.new(0,42,0,22)
			sw.Position=UDim2.new(1,-55,0.5,-11)
			sw.BackgroundColor3=state and Theme.Accent or Theme.Main
			sw.BorderSizePixel=0
			sw.Parent=tog
			Corner(sw,11)
			local dot=Instance.new("Frame")
			dot.Size=UDim2.new(0,18,0,18)
			dot.Position=state and UDim2.new(1,-20,0.5,-9)or UDim2.new(0,2,0.5,-9)
			dot.BackgroundColor3=Theme.Text
			dot.BorderSizePixel=0
			dot.Parent=sw
			Corner(dot,9)
			tog.MouseButton1Click:Connect(function()
				state=not state
				Tween(sw,{BackgroundColor3=state and Theme.Accent or Theme.Main},0.2)
				Tween(dot,{Position=state and UDim2.new(1,-20,0.5,-9)or UDim2.new(0,2,0.5,-9)},0.2)
				if cfg.Callback then task.spawn(cfg.Callback,state)end
			end)
			return{
				SetState=function(_,s)
					state=s
					Tween(sw,{BackgroundColor3=state and Theme.Accent or Theme.Main},0.2)
					Tween(dot,{Position=state and UDim2.new(1,-20,0.5,-9)or UDim2.new(0,2,0.5,-9)},0.2)
					if cfg.Callback then task.spawn(cfg.Callback,state)end
				end
			}
		end
		
		function Elements:CreateSlider(cfg)
			cfg=cfg or{}
			local min,max=cfg.Min or 0,cfg.Max or 100
			local val=cfg.Default or min
			local f=Instance.new("Frame")
			f.Size=UDim2.new(1,0,0,60)
			f.BackgroundColor3=Theme.Element
			f.Parent=Page
			Corner(f,6)
			Stroke(f,Theme.Stroke,1)
			local lbl=Instance.new("TextLabel")
			lbl.Text=cfg.Name or"Slider"
			lbl.Size=UDim2.new(1,-60,0,20)
			lbl.Position=UDim2.new(0,15,0,10)
			lbl.BackgroundTransparency=1
			lbl.TextColor3=Theme.Text
			lbl.Font=Enum.Font.GothamSemibold
			lbl.TextSize=13
			lbl.TextXAlignment=Enum.TextXAlignment.Left
			lbl.TextTruncate=Enum.TextTruncate.AtEnd
			lbl.Parent=f
			local vLbl=Instance.new("TextLabel")
			vLbl.Text=tostring(val)
			vLbl.Size=UDim2.new(0,50,0,20)
			vLbl.Position=UDim2.new(1,-60,0,10)
			vLbl.BackgroundTransparency=1
			vLbl.TextColor3=Theme.Accent
			vLbl.Font=Enum.Font.GothamBold
			vLbl.TextSize=13
			vLbl.TextXAlignment=Enum.TextXAlignment.Right
			vLbl.Parent=f
			local bar=Instance.new("TextButton")
			bar.Text=""
			bar.Size=UDim2.new(1,-30,0,6)
			bar.Position=UDim2.new(0,15,0,42)
			bar.BackgroundColor3=Theme.Main
			bar.AutoButtonColor=false
			bar.BorderSizePixel=0
			bar.Parent=f
			Corner(bar,3)
			local fill=Instance.new("Frame")
			fill.Size=UDim2.new((val-min)/(max-min),0,1,0)
			fill.BackgroundColor3=Theme.Accent
			fill.BorderSizePixel=0
			fill.Parent=bar
			Corner(fill,3)
			local drag=false
			local function upd(inp)
				local pct=math.clamp((inp.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
				Tween(fill,{Size=UDim2.new(pct,0,1,0)},0.1)
				local nv=math.floor(min+((max-min)*pct))
				vLbl.Text=tostring(nv)
				if cfg.Callback then task.spawn(cfg.Callback,nv)end
			end
			bar.InputBegan:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1 then
					drag=true
					upd(i)
				end
			end)
			UIS.InputEnded:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
			end)
			UIS.InputChanged:Connect(function(i)
				if drag and i.UserInputType==Enum.UserInputType.MouseMovement then upd(i)end
			end)
			return{
				SetValue=function(_,v)
					val=math.clamp(v,min,max)
					vLbl.Text=tostring(val)
					local pct=(val-min)/(max-min)
					Tween(fill,{Size=UDim2.new(pct,0,1,0)},0.2)
					if cfg.Callback then task.spawn(cfg.Callback,val)end
				end
			}
		end
		
		function Elements:CreateKeybind(cfg)
			cfg=cfg or{}
			local key=cfg.Default or Enum.KeyCode.F
			local listen=false
			local f=Instance.new("Frame")
			f.Size=UDim2.new(1,0,0,42)
			f.BackgroundColor3=Theme.Element
			f.Parent=Page
			Corner(f,6)
			Stroke(f,Theme.Stroke,1)
			local lbl=Instance.new("TextLabel")
			lbl.Text=cfg.Name or"Keybind"
			lbl.Size=UDim2.new(1,-120,1,0)
			lbl.Position=UDim2.new(0,15,0,0)
			lbl.BackgroundTransparency=1
			lbl.TextColor3=Theme.Text
			lbl.Font=Enum.Font.GothamSemibold
			lbl.TextSize=13
			lbl.TextXAlignment=Enum.TextXAlignment.Left
			lbl.TextTruncate=Enum.TextTruncate.AtEnd
			lbl.Parent=f
			local kBtn=Instance.new("TextButton")
			kBtn.Text="["..key.Name.."]"
			kBtn.Size=UDim2.new(0,100,0,28)
			kBtn.Position=UDim2.new(1,-110,0.5,-14)
			kBtn.BackgroundColor3=Theme.Main
			kBtn.TextColor3=Theme.Accent
			kBtn.Font=Enum.Font.GothamBold
			kBtn.TextSize=12
			kBtn.AutoButtonColor=false
			kBtn.Parent=f
			Corner(kBtn,4)
			kBtn.MouseButton1Click:Connect(function()
				listen=true
				kBtn.Text="..."
				kBtn.TextColor3=Theme.Text
			end)
			UIS.InputBegan:Connect(function(i)
				if listen and i.UserInputType==Enum.UserInputType.Keyboard then
					key=i.KeyCode
					kBtn.Text="["..i.KeyCode.Name.."]"
					kBtn.TextColor3=Theme.Accent
					listen=false
					if cfg.Callback then task.spawn(cfg.Callback,key)end
				end
			end)
			return{SetKey=function(_,k)key=k kBtn.Text="["..k.Name.."]"end}
		end
		
		function Elements:CreateInput(cfg)
			cfg=cfg or{}
			local txt=cfg.Default or""
			local f=Instance.new("Frame")
			f.Size=UDim2.new(1,0,0,42)
			f.BackgroundColor3=Theme.Element
			f.Parent=Page
			Corner(f,6)
			Stroke(f,Theme.Stroke,1)
			local lbl=Instance.new("TextLabel")
			lbl.Text=cfg.Name or"Input"
			lbl.Size=UDim2.new(0,100,1,0)
			lbl.Position=UDim2.new(0,15,0,0)
			lbl.BackgroundTransparency=1
			lbl.TextColor3=Theme.Text
			lbl.Font=Enum.Font.GothamSemibold
			lbl.TextSize=13
			lbl.TextXAlignment=Enum.TextXAlignment.Left
			lbl.TextTruncate=Enum.TextTruncate.AtEnd
			lbl.Parent=f
			local box=Instance.new("TextBox")
			box.Text=txt
			box.PlaceholderText=cfg.Placeholder or"Enter..."
			box.Size=UDim2.new(1,-130,0,28)
			box.Position=UDim2.new(0,120,0.5,-14)
			box.BackgroundColor3=Theme.Main
			box.TextColor3=Theme.Text
			box.PlaceholderColor3=Theme.TextDim
			box.Font=Enum.Font.Gotham
			box.TextSize=12
			box.TextXAlignment=Enum.TextXAlignment.Left
			box.ClearTextOnFocus=false
			box.Parent=f
			Corner(box,4)
			Padding(box,0,10,10,0)
			box.FocusLost:Connect(function(e)
				txt=box.Text
				if cfg.Callback then task.spawn(cfg.Callback,txt,e)end
			end)
			return{
				SetText=function(_,t)box.Text=t txt=t end,
				GetText=function()return txt end
			}
		end
		
		function Elements:CreateDropdown(cfg)
			cfg=cfg or{}
			local opts=cfg.Options or{"Option 1","Option 2"}
			local sel=cfg.Default or opts[1]
			local open=false
			local f=Instance.new("Frame")
			f.Size=UDim2.new(1,0,0,42)
			f.BackgroundColor3=Theme.Element
			f.ClipsDescendants=false
			f.Parent=Page
			Corner(f,6)
			Stroke(f,Theme.Stroke,1)
			local lbl=Instance.new("TextLabel")
			lbl.Text=cfg.Name or"Dropdown"
			lbl.Size=UDim2.new(0,120,1,0)
			lbl.Position=UDim2.new(0,15,0,0)
			lbl.BackgroundTransparency=1
			lbl.TextColor3=Theme.Text
			lbl.Font=Enum.Font.GothamSemibold
			lbl.TextSize=13
			lbl.TextXAlignment=Enum.TextXAlignment.Left
			lbl.TextTruncate=Enum.TextTruncate.AtEnd
			lbl.Parent=f
			local sBtn=Instance.new("TextButton")
			sBtn.Text=sel
			sBtn.Size=UDim2.new(1,-145,0,28)
			sBtn.Position=UDim2.new(0,130,0.5,-14)
			sBtn.BackgroundColor3=Theme.Main
			sBtn.TextColor3=Theme.Accent
			sBtn.Font=Enum.Font.Gotham
			sBtn.TextSize=12
			sBtn.TextXAlignment=Enum.TextXAlignment.Left
			sBtn.AutoButtonColor=false
			sBtn.TextTruncate=Enum.TextTruncate.AtEnd
			sBtn.Parent=f
			Corner(sBtn,4)
			Padding(sBtn,0,10,30,0)
			local arr=Instance.new("ImageLabel")
			arr.Size=UDim2.new(0,16,0,16)
			arr.Position=UDim2.new(1,-22,0.5,-8)
			arr.BackgroundTransparency=1
			arr.Image=Icons.Dropdown
			arr.ImageColor3=Theme.TextDim
			arr.Rotation=0
			arr.Parent=sBtn
			local optF=Instance.new("ScrollingFrame")
			optF.Size=UDim2.new(1,-145,0,0)
			optF.Position=UDim2.new(0,130,1,5)
			optF.BackgroundColor3=Theme.Element
			optF.Visible=false
			optF.ClipsDescendants=true
			optF.BorderSizePixel=0
			optF.ScrollBarThickness=3
			optF.ScrollBarImageColor3=Theme.Stroke
			optF.AutomaticCanvasSize=Enum.AutomaticSize.Y
			optF.CanvasSize=UDim2.new(0,0,0,0)
			optF.Parent=f
			Corner(optF,4)
			Stroke(optF,Theme.Stroke,1)
			local optL=Instance.new("UIListLayout")
			optL.SortOrder=Enum.SortOrder.LayoutOrder
			optL.Padding=UDim.new(0,2)
			optL.Parent=optF
			Padding(optF,4,4,4,4)
			local function makeOpt(o)
				local ob=Instance.new("TextButton")
				ob.Text=o
				ob.Size=UDim2.new(1,0,0,28)
				ob.BackgroundColor3=Theme.Main
				ob.TextColor3=Theme.Text
				ob.Font=Enum.Font.Gotham
				ob.TextSize=12
				ob.TextXAlignment=Enum.TextXAlignment.Left
				ob.AutoButtonColor=false
				ob.Parent=optF
				Corner(ob,4)
				Padding(ob,0,8,8,0)
				ob.MouseEnter:Connect(function()Tween(ob,{BackgroundColor3=Theme.ElementHover})end)
				ob.MouseLeave:Connect(function()Tween(ob,{BackgroundColor3=Theme.Main})end)
				ob.MouseButton1Click:Connect(function()
					sel=o
					sBtn.Text=o
					open=false
					Tween(optF,{Size=UDim2.new(1,-145,0,0)},0.2)
					Tween(arr,{Rotation=0},0.2)
					task.wait(0.2)
					optF.Visible=false
					if cfg.Callback then task.spawn(cfg.Callback,o)end
				end)
			end
			for _,o in ipairs(opts)do makeOpt(o)end
			sBtn.MouseButton1Click:Connect(function()
				open=not open
				if open then
					optF.Visible=true
					local h=math.min(#opts*30+8,150)
					Tween(optF,{Size=UDim2.new(1,-145,0,h)},0.2)
					Tween(arr,{Rotation=180},0.2)
				else
					Tween(optF,{Size=UDim2.new(1,-145,0,0)},0.2)
					Tween(arr,{Rotation=0},0.2)
					task.wait(0.2)
					optF.Visible=false
				end
			end)
			return{
				SetValue=function(_,v)
					if table.find(opts,v)then
						sel=v
						sBtn.Text=v
						if cfg.Callback then task.spawn(cfg.Callback,v)end
					end
				end,
				GetValue=function()return sel end,
				UpdateOptions=function(_,no)
					opts=no
					for _,c in ipairs(optF:GetChildren())do
						if c:IsA("TextButton")then c:Destroy()end
					end
					for _,o in ipairs(opts)do makeOpt(o)end
					sel=opts[1]
					sBtn.Text=sel
				end
			}
		end
		
		return Elements
	end
	
	UIS.InputBegan:Connect(function(i,p)
		if not p and i.KeyCode==Keybind then
			SGui.Enabled=not SGui.Enabled
		end
	end)
	
	if cfg.PlayerTab~=false and not PlayerTabCreated then
		PlayerTabCreated=true
		local Player=Tabs:CreateTab("Player",Icons.User)
		
		Player:CreateSection("Movement")
		
		local wsEnabled=false
		local wsValue=16
		local wsMethod="Heartbeat"
		Player:CreateToggle({Name="Custom WalkSpeed",Default=false,Callback=function(s)
			wsEnabled=s
			if s then
				if wsMethod=="Heartbeat"then
					Connections.WS=RS.Heartbeat:Connect(function()
						if LP.Character and LP.Character:FindFirstChild("Humanoid")then
							LP.Character.Humanoid.WalkSpeed=wsValue
						end
					end)
				else
					Connections.WS=RS.RenderStepped:Connect(function()
						if LP.Character and LP.Character:FindFirstChild("Humanoid")then
							LP.Character.Humanoid.WalkSpeed=wsValue
						end
					end)
				end
			else
				if Connections.WS then Connections.WS:Disconnect()Connections.WS=nil end
				if LP.Character and LP.Character:FindFirstChild("Humanoid")then
					LP.Character.Humanoid.WalkSpeed=16
				end
			end
		end})
		
		Player:CreateSlider({Name="WalkSpeed Value",Min=16,Max=500,Default=16,Callback=function(v)wsValue=v end})
		Player:CreateDropdown({Name="WS Method",Options={"Heartbeat","RenderStepped"},Default="Heartbeat",Callback=function(v)
			wsMethod=v
			if wsEnabled then
				if Connections.WS then Connections.WS:Disconnect()end
				if v=="Heartbeat"then
					Connections.WS=RS.Heartbeat:Connect(function()
						if LP.Character and LP.Character:FindFirstChild("Humanoid")then
							LP.Character.Humanoid.WalkSpeed=wsValue
						end
					end)
				else
					Connections.WS=RS.RenderStepped:Connect(function()
						if LP.Character and LP.Character:FindFirstChild("Humanoid")then
							LP.Character.Humanoid.WalkSpeed=wsValue
						end
					end)
				end
			end
		end})
		
		local jpEnabled=false
		local jpValue=50
		local jpMethod="Heartbeat"
		Player:CreateToggle({Name="Custom JumpPower",Default=false,Callback=function(s)
			jpEnabled=s
			if s then
				if jpMethod=="Heartbeat"then
					Connections.JP=RS.Heartbeat:Connect(function()
						if LP.Character and LP.Character:FindFirstChild("Humanoid")then
							LP.Character.Humanoid.UseJumpPower=true
							LP.Character.Humanoid.JumpPower=jpValue
						end
					end)
				else
					Connections.JP=RS.RenderStepped:Connect(function()
						if LP.Character and LP.Character:FindFirstChild("Humanoid")then
							LP.Character.Humanoid.UseJumpPower=true
							LP.Character.Humanoid.JumpPower=jpValue
						end
					end)
				end
			else
				if Connections.JP then Connections.JP:Disconnect()Connections.JP=nil end
				if LP.Character and LP.Character:FindFirstChild("Humanoid")then
					LP.Character.Humanoid.JumpPower=50
				end
			end
		end})
		
		Player:CreateSlider({Name="JumpPower Value",Min=50,Max=500,Default=50,Callback=function(v)jpValue=v end})
		Player:CreateDropdown({Name="JP Method",Options={"Heartbeat","RenderStepped"},Default="Heartbeat",Callback=function(v)
			jpMethod=v
			if jpEnabled then
				if Connections.JP then Connections.JP:Disconnect()end
				if v=="Heartbeat"then
					Connections.JP=RS.Heartbeat:Connect(function()
						if LP.Character and LP.Character:FindFirstChild("Humanoid")then
							LP.Character.Humanoid.UseJumpPower=true
							LP.Character.Humanoid.JumpPower=jpValue
						end
					end)
				else
					Connections.JP=RS.RenderStepped:Connect(function()
						if LP.Character and LP.Character:FindFirstChild("Humanoid")then
							LP.Character.Humanoid.UseJumpPower=true
							LP.Character.Humanoid.JumpPower=jpValue
						end
					end)
				end
			end
		end})
		
		Player:CreateSection("Character")
		
		Player:CreateButton({Name="Reset Character",Callback=function()
			if LP.Character and LP.Character:FindFirstChild("Humanoid")then
				LP.Character.Humanoid.Health=0
			end
		end})
		
		local invisParts={}
		Player:CreateToggle({Name="Invisibility",Default=false,Callback=function(s)
			if s then
				if LP.Character then
					for _,v in pairs(LP.Character:GetDescendants())do
						if v:IsA("BasePart")and v.Name~="HumanoidRootPart"then
							invisParts[v]=v.Transparency
							v.Transparency=1
						elseif v:IsA("Accessory")and v:FindFirstChild("Handle")then
							invisParts[v.Handle]=v.Handle.Transparency
							v.Handle.Transparency=1
						end
					end
					if LP.Character:FindFirstChild("Head")and LP.Character.Head:FindFirstChild("face")then
						invisParts[LP.Character.Head.face]=LP.Character.Head.face.Transparency
						LP.Character.Head.face.Transparency=1
					end
				end
			else
				if LP.Character then
					for part,trans in pairs(invisParts)do
						if part and part.Parent then
							part.Transparency=trans
						end
					end
					invisParts={}
				end
			end
		end})
		
		local flingEnabled=false
		Player:CreateToggle({Name="Fling",Default=false,Callback=function(s)
			flingEnabled=s
			if s then
				if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")then
					local hrp=LP.Character.HumanoidRootPart
					local bamFling=Instance.new("BodyAngularVelocity")
					bamFling.Name="Spin"
					bamFling.Parent=hrp
					bamFling.MaxTorque=Vector3.new(0,math.huge,0)
					bamFling.P=9e9
					bamFling.AngularVelocity=Vector3.new(0,9e9,0)
					Connections.Fling=bamFling
				end
			else
				if Connections.Fling then
					Connections.Fling:Destroy()
					Connections.Fling=nil
				end
			end
		end})
		
		Player:CreateSection("World")
		
		Player:CreateButton({Name="Fullbright",Callback=function()
			Lighting.Brightness=2
			Lighting.Ambient=Color3.new(1,1,1)
		end})
		
		Player:CreateButton({Name="Remove Fog",Callback=function()
			Lighting.FogEnd=999999
		end})
		
		Player:CreateButton({Name="Fix Lighting",Callback=function()
			Lighting.Brightness=1
			Lighting.Ambient=Color3.new(0.5,0.5,0.5)
			Lighting.FogEnd=100000
		end})
		
		Player:CreateSection("Server")
		
		Player:CreateButton({Name="Rejoin Server",Callback=function()
			TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId)
		end})
		
		Player:CreateButton({Name="Server Hop",Callback=function()
			local servers={}
			local success,result=pcall(function()
				return game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
			end)
			if success then
				local data=Http:JSONDecode(result)
				for _,server in pairs(data.data)do
					if server.id~=game.JobId and server.playing<server.maxPlayers then
						table.insert(servers,server.id)
					end
				end
				if #servers>0 then
					TeleportService:TeleportToPlaceInstance(game.PlaceId,servers[math.random(1,#servers)])
				end
			end
		end})
	end
	
	local SettingsPage=Instance.new("ScrollingFrame")
	SettingsPage.Name="SettingsPage"
	SettingsPage.Size=UDim2.new(1,0,1,0)
	SettingsPage.BackgroundTransparency=1
	SettingsPage.BorderSizePixel=0
	SettingsPage.ScrollBarThickness=4
	SettingsPage.ScrollBarImageColor3=Theme.Stroke
	SettingsPage.ScrollBarImageTransparency=0.3
	SettingsPage.AutomaticCanvasSize=Enum.AutomaticSize.Y
	SettingsPage.CanvasSize=UDim2.new(0,0,0,0)
	SettingsPage.Visible=false
	SettingsPage.Parent=Pages
	
	local SL=Instance.new("UIListLayout")
	SL.Padding=UDim.new(0,8)
	SL.Parent=SettingsPage
	Padding(SettingsPage,15,20,20,15)
	
	local function SSec(t)
		local s=Instance.new("TextLabel")
		s.Text=string.upper(t)
		s.Size=UDim2.new(1,0,0,26)
		s.BackgroundTransparency=1
		s.TextColor3=Theme.Accent
		s.Font=Enum.Font.GothamBold
		s.TextSize=11
		s.TextXAlignment=Enum.TextXAlignment.Left
		s.Parent=SettingsPage
		Padding(s,8,0,0,0)
	end
	
	SSec("Menu Controls")
	
	local kbF=Instance.new("Frame")
	kbF.Size=UDim2.new(1,0,0,42)
	kbF.BackgroundColor3=Theme.Element
	kbF.Parent=SettingsPage
	Corner(kbF,6)
	Stroke(kbF,Theme.Stroke,1)
	local kbL=Instance.new("TextLabel")
	kbL.Text="Toggle Keybind"
	kbL.Size=UDim2.new(1,-120,1,0)
	kbL.Position=UDim2.new(0,15,0,0)
	kbL.BackgroundTransparency=1
	kbL.TextColor3=Theme.Text
	kbL.Font=Enum.Font.GothamSemibold
	kbL.TextSize=13
	kbL.TextXAlignment=Enum.TextXAlignment.Left
	kbL.Parent=kbF
	local kbBtn=Instance.new("TextButton")
	kbBtn.Text="["..Keybind.Name.."]"
	kbBtn.Size=UDim2.new(0,100,0,26)
	kbBtn.Position=UDim2.new(1,-110,0.5,-13)
	kbBtn.BackgroundColor3=Theme.Main
	kbBtn.TextColor3=Theme.Accent
	kbBtn.Font=Enum.Font.GothamBold
	kbBtn.TextSize=12
	kbBtn.AutoButtonColor=false
	kbBtn.Parent=kbF
	Corner(kbBtn,4)
	local kbListen=false
	kbBtn.MouseButton1Click:Connect(function()
		kbListen=true
		kbBtn.Text="..."
		kbBtn.TextColor3=Theme.Text
	end)
	UIS.InputBegan:Connect(function(i)
		if kbListen and i.UserInputType==Enum.UserInputType.Keyboard then
			Keybind=i.KeyCode
			kbBtn.Text="["..i.KeyCode.Name.."]"
			kbBtn.TextColor3=Theme.Accent
			kbListen=false
		end
	end)
	
	SSec("Theme Management")
	
	local function SBtn(n,cb)
		local b=Instance.new("TextButton")
		b.Size=UDim2.new(1,0,0,42)
		b.BackgroundColor3=Theme.Element
		b.AutoButtonColor=false
		b.Text=""
		b.Parent=SettingsPage
		Corner(b,6)
		Stroke(b,Theme.Stroke,1)
		local l=Instance.new("TextLabel")
		l.Text=n
		l.Size=UDim2.new(1,-20,1,0)
		l.Position=UDim2.new(0,15,0,0)
		l.BackgroundTransparency=1
		l.TextColor3=Theme.Text
		l.Font=Enum.Font.GothamSemibold
		l.TextSize=13
		l.TextXAlignment=Enum.TextXAlignment.Left
		l.Parent=b
		b.MouseEnter:Connect(function()Tween(b,{BackgroundColor3=Theme.ElementHover})end)
		b.MouseLeave:Connect(function()Tween(b,{BackgroundColor3=Theme.Element})end)
		b.MouseButton1Click:Connect(function()if cb then cb(l)end end)
		return b,l
	end
	
	local presets={}
	for k,v in pairs(ThemePresets)do table.insert(presets,v.Name)end
	local tPreset=Instance.new("Frame")
	tPreset.Size=UDim2.new(1,0,0,42)
	tPreset.BackgroundColor3=Theme.Element
	tPreset.ClipsDescendants=false
	tPreset.Parent=SettingsPage
	Corner(tPreset,6)
	Stroke(tPreset,Theme.Stroke,1)
	local tpL=Instance.new("TextLabel")
	tpL.Text="Select Theme"
	tpL.Size=UDim2.new(0,120,1,0)
	tpL.Position=UDim2.new(0,15,0,0)
	tpL.BackgroundTransparency=1
	tpL.TextColor3=Theme.Text
	tpL.Font=Enum.Font.GothamSemibold
	tpL.TextSize=13
	tpL.TextXAlignment=Enum.TextXAlignment.Left
	tpL.Parent=tPreset
	local tpBtn=Instance.new("TextButton")
	tpBtn.Text=ThemePresets.Chudjak.Name
	tpBtn.Size=UDim2.new(1,-145,0,28)
	tpBtn.Position=UDim2.new(0,130,0.5,-14)
	tpBtn.BackgroundColor3=Theme.Main
	tpBtn.TextColor3=Theme.Accent
	tpBtn.Font=Enum.Font.Gotham
	tpBtn.TextSize=12
	tpBtn.TextXAlignment=Enum.TextXAlignment.Left
	tpBtn.AutoButtonColor=false
	tpBtn.TextTruncate=Enum.TextTruncate.AtEnd
	tpBtn.Parent=tPreset
	Corner(tpBtn,4)
	Padding(tpBtn,0,10,30,0)
	local tpArr=Instance.new("ImageLabel")
	tpArr.Size=UDim2.new(0,16,0,16)
	tpArr.Position=UDim2.new(1,-22,0.5,-8)
	tpArr.BackgroundTransparency=1
	tpArr.Image=Icons.Dropdown
	tpArr.ImageColor3=Theme.TextDim
	tpArr.Rotation=0
	tpArr.Parent=tpBtn
	local tpOpts=Instance.new("ScrollingFrame")
	tpOpts.Size=UDim2.new(1,-145,0,0)
	tpOpts.Position=UDim2.new(0,130,1,5)
	tpOpts.BackgroundColor3=Theme.Element
	tpOpts.Visible=false
	tpOpts.ClipsDescendants=true
	tpOpts.BorderSizePixel=0
	tpOpts.ScrollBarThickness=3
	tpOpts.ScrollBarImageColor3=Theme.Stroke
	tpOpts.AutomaticCanvasSize=Enum.AutomaticSize.Y
	tpOpts.CanvasSize=UDim2.new(0,0,0,0)
	tpOpts.Parent=tPreset
	Corner(tpOpts,4)
	Stroke(tpOpts,Theme.Stroke,1)
	local tpL2=Instance.new("UIListLayout")
	tpL2.Padding=UDim.new(0,2)
	tpL2.Parent=tpOpts
	Padding(tpOpts,4,4,4,4)
	local tpOpen=false
	for k,v in pairs(ThemePresets)do
		local ob=Instance.new("TextButton")
		ob.Text=v.Name
		ob.Size=UDim2.new(1,0,0,28)
		ob.BackgroundColor3=Theme.Main
		ob.TextColor3=Theme.Text
		ob.Font=Enum.Font.Gotham
		ob.TextSize=12
		ob.TextXAlignment=Enum.TextXAlignment.Left
		ob.AutoButtonColor=false
		ob.Parent=tpOpts
		Corner(ob,4)
		Padding(ob,0,8,8,0)
		ob.MouseEnter:Connect(function()Tween(ob,{BackgroundColor3=Theme.ElementHover})end)
		ob.MouseLeave:Connect(function()Tween(ob,{BackgroundColor3=Theme.Main})end)
		ob.MouseButton1Click:Connect(function()
			ApplyTheme(v)
			tpBtn.Text=v.Name
			tpOpen=false
			Tween(tpOpts,{Size=UDim2.new(1,-145,0,0)},0.2)
			Tween(tpArr,{Rotation=0},0.2)
			task.wait(0.2)
			tpOpts.Visible=false
		end)
	end
	tpBtn.MouseButton1Click:Connect(function()
		tpOpen=not tpOpen
		if tpOpen then
			tpOpts.Visible=true
			local h=math.min(#presets*30+8,150)
			Tween(tpOpts,{Size=UDim2.new(1,-145,0,h)},0.2)
			Tween(tpArr,{Rotation=180},0.2)
		else
			Tween(tpOpts,{Size=UDim2.new(1,-145,0,0)},0.2)
			Tween(tpArr,{Rotation=0},0.2)
			task.wait(0.2)
			tpOpts.Visible=false
		end
	end)
	
	SBtn("Export Current Theme",function(l)
		setclipboard(ExportTheme())
		l.Text="✓ Copied!"
		task.wait(2)
		l.Text="Export Current Theme"
	end)
	
	SSec("Config Management")
	
	local cfgName=Instance.new("Frame")
	cfgName.Size=UDim2.new(1,0,0,42)
	cfgName.BackgroundColor3=Theme.Element
	cfgName.Parent=SettingsPage
	Corner(cfgName,6)
	Stroke(cfgName,Theme.Stroke,1)
	local cfgL=Instance.new("TextLabel")
	cfgL.Text="Config Name"
	cfgL.Size=UDim2.new(0,100,1,0)
	cfgL.Position=UDim2.new(0,15,0,0)
	cfgL.BackgroundTransparency=1
	cfgL.TextColor3=Theme.Text
	cfgL.Font=Enum.Font.GothamSemibold
	cfgL.TextSize=13
	cfgL.TextXAlignment=Enum.TextXAlignment.Left
	cfgL.Parent=cfgName
	local cfgBox=Instance.new("TextBox")
	cfgBox.Text=GameConfig and tostring(game.PlaceId)or"default"
	cfgBox.PlaceholderText="Enter name..."
	cfgBox.Size=UDim2.new(1,-130,0,28)
	cfgBox.Position=UDim2.new(0,120,0.5,-14)
	cfgBox.BackgroundColor3=Theme.Main
	cfgBox.TextColor3=Theme.Text
	cfgBox.PlaceholderColor3=Theme.TextDim
	cfgBox.Font=Enum.Font.Gotham
	cfgBox.TextSize=12
	cfgBox.TextXAlignment=Enum.TextXAlignment.Left
	cfgBox.ClearTextOnFocus=false
	cfgBox.Parent=cfgName
	Corner(cfgBox,4)
	Padding(cfgBox,0,10,10,0)
	
	SBtn("Save Config",function(l)
		SaveConfig(cfgBox.Text,{theme=Theme})
		l.Text="✓ Saved!"
		task.wait(2)
		l.Text="Save Config"
	end)
	
	SBtn("Load Config",function(l)
		local data=LoadConfig(cfgBox.Text)
		if data and data.theme then
			ApplyTheme(data.theme)
			l.Text="✓ Loaded!"
			task.wait(2)
			l.Text="Load Config"
		else
			l.Text="✗ Not found"
			task.wait(2)
			l.Text="Load Config"
		end
	end)
	
	SSec("Library")
	
	SBtn("Unload Hub",function()
		for _,c in pairs(Connections)do
			if c and c.Disconnect then c:Disconnect()end
		end
		Tween(Main,{Size=UDim2.new(0,0,0,0)},0.3)
		task.wait(0.3)
		SGui:Destroy()
	end)
	
	local SettingsBtn=Instance.new("TextButton")
	SettingsBtn.Name="SettingsBtn"
	SettingsBtn.Size=UDim2.new(1,-20,1,-5)
	SettingsBtn.Position=UDim2.new(0,10,0,0)
	SettingsBtn.BackgroundTransparency=1
	SettingsBtn.BackgroundColor3=Theme.Element
	SettingsBtn.AutoButtonColor=false
	SettingsBtn.Text=""
	SettingsBtn.Parent=SettingsArea
	Corner(SettingsBtn,6)
	local sIco=Instance.new("ImageLabel")
	sIco.Name="Icon"
	sIco.Size=UDim2.new(0,18,0,18)
	sIco.Position=UDim2.new(0,12,0.5,-9)
	sIco.BackgroundTransparency=1
	sIco.Image=Icons.Settings
	sIco.ImageColor3=Theme.TextDim
	sIco.Parent=SettingsBtn
	local sLbl=Instance.new("TextLabel")
	sLbl.Name="Label"
	sLbl.Text="Settings"
	sLbl.Size=UDim2.new(1,-50,1,0)
	sLbl.Position=UDim2.new(0,42,0,0)
	sLbl.BackgroundTransparency=1
	sLbl.TextColor3=Theme.TextDim
	sLbl.Font=Enum.Font.GothamMedium
	sLbl.TextSize=14
	sLbl.TextXAlignment=Enum.TextXAlignment.Left
	sLbl.Parent=SettingsBtn
	SettingsBtn.MouseEnter:Connect(function()
		if ActiveTab~="Settings"then
			Tween(SettingsBtn,{BackgroundColor3=Theme.Element,BackgroundTransparency=0.5})
		end
	end)
	SettingsBtn.MouseLeave:Connect(function()
		if ActiveTab~="Settings"then
			Tween(SettingsBtn,{BackgroundTransparency=1})
		end
	end)
	SettingsBtn.MouseButton1Click:Connect(function()
		for _,tab in pairs(TabContainer:GetChildren())do
			if tab:IsA("TextButton")then
				Tween(tab,{BackgroundTransparency=1})
				if tab:FindFirstChild("Label")then Tween(tab.Label,{TextColor3=Theme.TextDim})end
				if tab:FindFirstChild("Icon")then Tween(tab.Icon,{ImageColor3=Theme.TextDim})end
			end
		end
		for _,page in pairs(Pages:GetChildren())do
			if page:IsA("ScrollingFrame")then page.Visible=false end
		end
		SettingsPage.Visible=true
		ActiveTab="Settings"
		Tween(SettingsBtn,{BackgroundColor3=Theme.Element,BackgroundTransparency=0})
		Tween(sLbl,{TextColor3=Theme.Text})
		Tween(sIco,{ImageColor3=Theme.Accent})
	end)
	
	return Tabs
end

return Chuddy
