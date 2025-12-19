# CHUDDY HUB | ULTIMATE DOCUMENTATION
### The most based UI library for certified chads

---

## 📖 Table of Contents
- [Introduction](#introduction)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Window Configuration](#window-configuration)
- [Creating Tabs](#creating-tabs)
- [UI Elements](#ui-elements)
- [Theme System](#theme-system)
- [Config System](#config-system)
- [Built-in Player Features](#built-in-player-features)
- [Advanced Usage](#advanced-usage)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [Credits](#credits)

---

## 🎯 Introduction

Chuddy Hub is a next-generation UI library designed for Roblox executors. Built with performance, aesthetics, and functionality in mind, it provides everything you need to create professional-looking script GUIs with minimal effort.

### Features
- ✅ **Blazing Fast** - Optimized code that won't lag your game
- ✅ **Beautiful Themes** - 5+ pre-built themes + full customization
- ✅ **Config System** - Save/load settings per game
- ✅ **Built-in Player Tab** - Common exploit features included
- ✅ **Fully Customizable** - Change everything from colors to keybinds
- ✅ **Drag & Resize** - Fully functional window management
- ✅ **Minimize System** - Clean minimize with maximize button
- ✅ **No Dependencies** - Pure Lua, works everywhere

---

## 🚀 Installation

### Method 1: Loadstring (Recommended)
```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ChuddyUILib/main/source.lua"))()
```

### Method 2: Local File
1. Download `ChuddyUILib_Ultimate.lua`
2. Load it with your executor's file system
```lua
local Library = loadfile("ChuddyUILib_Ultimate.lua")()
```

### Requirements
- Any modern executor (Synapse, Script-Ware, KRNL, etc.)
- File functions: `writefile`, `readfile`, `isfile`, `makefolder` (for config system)
- Optional: `gethui` (for better protection)

---

## ⚡ Quick Start

### Basic Example
```lua
local Chuddy = loadstring(game:HttpGet("YOUR_URL"))()

-- Create window
local Window = Chuddy:CreateWindow({
	Name = "My Hub",
	Keybind = Enum.KeyCode.RightControl
})

-- Create tab
local Main = Window:CreateTab("Main", "rbxassetid://10723356880")

-- Add section
Main:CreateSection("Features")

-- Add toggle
Main:CreateToggle({
	Name = "Speed Hack",
	Default = false,
	Callback = function(State)
		if State then
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
		else
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
		end
	end
})

-- Add slider
Main:CreateSlider({
	Name = "FOV",
	Min = 70,
	Max = 120,
	Default = 90,
	Callback = function(Value)
		workspace.CurrentCamera.FieldOfView = Value
	end
})
```

---

## 🪟 Window Configuration

### CreateWindow Options

```lua
local Window = Chuddy:CreateWindow({
	Name = "Hub Name",              -- Window title (shows in header)
	Keybind = Enum.KeyCode.RightControl,  -- Key to toggle GUI
	AutoLoad = true,                -- Auto-load last config on startup
	GameConfig = true,              -- Use game-specific config names
	PlayerTab = true                -- Include built-in player features
})
```

### Configuration Details

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `Name` | string | "Chuddy Hub" | Window title displayed in header |
| `Keybind` | KeyCode | RightControl | Key to show/hide the GUI |
| `AutoLoad` | boolean | true | Automatically load last config |
| `GameConfig` | boolean | true | Append game PlaceId to config names |
| `PlayerTab` | boolean | true | Create built-in Player tab with common features |

### Window Methods

The window automatically handles:
- **Dragging** - Click and drag header or sidebar
- **Resizing** - Drag bottom-right corner
- **Minimizing** - Click minimize button (shows maximize button when minimized)
- **Closing** - Click close button (destroys GUI)

---

## 📑 Creating Tabs

### Basic Tab Creation

```lua
local Tab = Window:CreateTab("Tab Name", "rbxassetid://ICON_ID")
```

### Tab Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| Name | string | Yes | Tab name shown in sidebar |
| Icon | string | No | Roblox asset ID for tab icon |

### Example with Multiple Tabs

```lua
-- Combat tab
local Combat = Window:CreateTab("Combat", "rbxassetid://10723356880")

-- Visuals tab
local Visuals = Window:CreateTab("Visuals", "rbxassetid://10723346959")

-- Movement tab
local Movement = Window:CreateTab("Movement", "rbxassetid://10723407389")

-- Misc tab
local Misc = Window:CreateTab("Misc", "rbxassetid://10723415903")
```

### Good Icon Asset IDs

Here are some reliable Roblox asset IDs you can use:
- Combat/Sword: `rbxassetid://10723356880`
- Eye/Visuals: `rbxassetid://10723346959`
- Running/Movement: `rbxassetid://10723407389`
- Settings/Misc: `rbxassetid://10723415903`
- Star: `rbxassetid://10723434711`
- Shield: `rbxassetid://10723424234`

---

## 🎨 UI Elements

### CreateSection
Creates a labeled divider to organize your elements.

```lua
Tab:CreateSection("Section Name")
```

**Visual:** Displays uppercase text in accent color with spacing.

---

### CreateLabel
Displays informational text.

```lua
local label = Tab:CreateLabel({
	Text = "This is a label"
})

-- Update text later
label:SetText("New text!")
```

**Methods:**
- `SetText(text)` - Update label text

---

### CreateButton
Clickable button that executes a callback.

```lua
Tab:CreateButton({
	Name = "Button Name",
	Callback = function()
		print("Button clicked!")
	end
})
```

**Parameters:**
- `Name` (string) - Button text
- `Callback` (function) - Function to execute on click

---

### CreateToggle
On/off switch with visual state.

```lua
local toggle = Tab:CreateToggle({
	Name = "Feature Toggle",
	Default = false,
	Callback = function(State)
		print("Toggle state:", State)
	end
})

-- Control programmatically
toggle:SetState(true)
```

**Parameters:**
- `Name` (string) - Toggle label
- `Default` (boolean) - Starting state
- `Callback` (function) - Called with state on toggle

**Methods:**
- `SetState(bool)` - Set toggle state programmatically

---

### CreateSlider
Draggable value slider.

```lua
local slider = Tab:CreateSlider({
	Name = "Value Slider",
	Min = 0,
	Max = 100,
	Default = 50,
	Callback = function(Value)
		print("Slider value:", Value)
	end
})

-- Set value programmatically
slider:SetValue(75)
```

**Parameters:**
- `Name` (string) - Slider label
- `Min` (number) - Minimum value
- `Max` (number) - Maximum value
- `Default` (number) - Starting value
- `Callback` (function) - Called with value on change

**Methods:**
- `SetValue(number)` - Set slider value programmatically

---

### CreateKeybind
Key binding selector.

```lua
local keybind = Tab:CreateKeybind({
	Name = "Activation Key",
	Default = Enum.KeyCode.E,
	Callback = function(Key)
		print("Key set to:", Key.Name)
	end
})

-- Change key programmatically
keybind:SetKey(Enum.KeyCode.F)
```

**Parameters:**
- `Name` (string) - Keybind label
- `Default` (KeyCode) - Starting key
- `Callback` (function) - Called with KeyCode on change

**Methods:**
- `SetKey(KeyCode)` - Set keybind programmatically

**Usage:** Click button, then press any key to bind it.

---

### CreateInput
Text input box.

```lua
local input = Tab:CreateInput({
	Name = "Text Input",
	Placeholder = "Enter text...",
	Default = "",
	Callback = function(Text, EnterPressed)
		print("Input:", Text)
		print("Enter pressed:", EnterPressed)
	end
})

-- Get/set text
input:SetText("New text")
local currentText = input:GetText()
```

**Parameters:**
- `Name` (string) - Input label
- `Placeholder` (string) - Placeholder text
- `Default` (string) - Starting text
- `Callback` (function) - Called with (text, enterPressed) on focus lost

**Methods:**
- `SetText(string)` - Set input text
- `GetText()` - Get current text

---

### CreateDropdown
Dropdown selection menu.

```lua
local dropdown = Tab:CreateDropdown({
	Name = "Mode Select",
	Options = {"Option 1", "Option 2", "Option 3"},
	Default = "Option 1",
	Callback = function(Value)
		print("Selected:", Value)
	end
})

-- Control programmatically
dropdown:SetValue("Option 2")
local current = dropdown:GetValue()

-- Update options
dropdown:UpdateOptions({"New", "Options", "List"})
```

**Parameters:**
- `Name` (string) - Dropdown label
- `Options` (table) - Array of option strings
- `Default` (string) - Starting selection
- `Callback` (function) - Called with selected value

**Methods:**
- `SetValue(string)` - Select an option
- `GetValue()` - Get current selection
- `UpdateOptions(table)` - Replace options array

---

## 🎨 Theme System

### Built-in Themes

Chuddy Hub comes with 5 pre-built themes:

1. **Chudjak Classic** (Default) - Purple/blue discord-style theme
2. **Gigachad Gold** - Luxurious gold accents
3. **Soyjak Soy** - Green nature theme
4. **Midnight Purple** - Deep purple aesthetic
5. **Ocean Breeze** - Blue ocean vibes

### Changing Themes

Themes can be changed in the Settings page (accessible via sidebar).

### Theme Structure

```lua
{
	Name = "Theme Name",
	Main = Color3.fromRGB(18, 18, 20),        -- Main background
	Sidebar = Color3.fromRGB(24, 24, 26),     -- Sidebar background
	Element = Color3.fromRGB(30, 30, 33),     -- Button/element background
	ElementHover = Color3.fromRGB(38, 38, 41), -- Hover state
	Text = Color3.fromRGB(240, 240, 240),     -- Primary text
	TextDim = Color3.fromRGB(140, 140, 140),  -- Secondary text
	Accent = Color3.fromRGB(114, 137, 218),   -- Accent color (main brand)
	Stroke = Color3.fromRGB(45, 45, 48),      -- Border color
	Divider = Color3.fromRGB(35, 35, 38)      -- Separator lines
}
```

### Exporting/Importing Themes

**Export:**
1. Go to Settings tab
2. Click "Export Theme to Clipboard"
3. Paste the JSON somewhere safe

**Import:**
1. Copy theme JSON
2. In Lua, use: `ImportTheme(jsonString)`
3. Theme will be applied immediately

**Code Example:**
```lua
-- Export
local themeJson = ExportTheme()
setclipboard(themeJson)

-- Import
local success = ImportTheme(themeJson)
if success then
	print("Theme imported!")
end
```

### Creating Custom Themes

```lua
-- Define your theme
local MyTheme = {
	Name = "My Custom Theme",
	Main = Color3.fromRGB(20, 20, 25),
	Sidebar = Color3.fromRGB(25, 25, 30),
	Element = Color3.fromRGB(35, 35, 40),
	ElementHover = Color3.fromRGB(45, 45, 50),
	Text = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(150, 150, 150),
	Accent = Color3.fromRGB(255, 100, 100), -- Custom red accent
	Stroke = Color3.fromRGB(50, 50, 55),
	Divider = Color3.fromRGB(40, 40, 45)
}

-- Apply it
ApplyTheme(MyTheme)

-- Save it
SaveTheme("MyTheme", MyTheme)
```

---

## 💾 Config System

### How Configs Work

Chuddy Hub saves configs to the `ChuddyHub/` folder in your executor's workspace directory.

**File Structure:**
```
ChuddyHub/
├── default.json
├── 123456789.json    (game-specific)
├── theme_custom.json
└── ...
```

### Auto-Config Per Game

When `GameConfig = true` (default), configs are automatically saved with the game's PlaceId:
```lua
-- Playing game with PlaceId 123456789
-- Config name becomes: "123456789"
```

This means your settings auto-load when you join the same game!

### Saving Configs

**In Settings UI:**
1. Go to Settings tab
2. Enter config name in "Config Name" field
3. Click "Save Config"

**In Code:**
```lua
SaveConfig("myconfig", {
	theme = Theme,
	settings = {
		speed = 100,
		jump = 200
	}
})
```

### Loading Configs

**In Settings UI:**
1. Go to Settings tab
2. Enter config name in "Config Name" field
3. Click "Load Config"

**In Code:**
```lua
local config = LoadConfig("myconfig")
if config then
	ApplyTheme(config.theme)
	-- Apply other settings
end
```

### Getting Available Configs

```lua
local configs = GetConfigs()
for _, name in ipairs(configs) do
	print("Config:", name)
end
```

### Best Practices

1. **Use game-specific configs** - Let `GameConfig = true` handle it automatically
2. **Save regularly** - Don't lose your settings!
3. **Backup important configs** - Copy the `.json` files elsewhere
4. **Share configs** - Send `.json` files to friends

### Syncing Theme + Config

**Step 1:** Save your theme
```lua
SaveTheme("mytheme", Theme)
```

**Step 2:** Save your config with theme reference
```lua
SaveConfig("myconfig", {
	theme = LoadTheme("mytheme"),
	settings = { --[[ your settings ]] }
})
```

**Step 3:** Load everything together
```lua
local config = LoadConfig("myconfig")
if config then
	ApplyTheme(config.theme)
	-- Apply settings
end
```

---

## 👤 Built-in Player Features

When `PlayerTab = true` (default), a "Player" tab is automatically created with common exploit features.

### Movement Features

**Custom WalkSpeed**
- Toggle + Slider (16-500)
- Continuously applies speed (anti-anti-cheat)

**Custom JumpPower**
- Toggle + Slider (50-500)
- Works with JumpPower mode

**Custom Gravity**
- Toggle + Slider (0-196.2)
- Changes workspace.Gravity

### Character Features

**Reset Character**
- Instantly kills your character
- Useful for bypassing some anti-cheats

**God Mode (Method 1)**
- Humanoid replacement method
- Works on most games
- No damage taken

### Teleportation

**TP Methods:**
1. **CFrame** - Instant teleport (most common)
2. **Position** - Direct position set
3. **Velocity** - Movement-based TP
4. **Tween** - Smooth animated movement

**TP to Player:**
- Enter username (partial matches work)
- Press Enter to teleport
- Uses selected TP method

### How It Works

The Player tab uses optimized RunService connections that:
- Only run when features are enabled
- Clean up properly when disabled
- Continuously reapply values (anti-reset)

### Example: Custom Speed

```lua
-- Toggle Custom WalkSpeed ON
-- Set slider to 100
-- Your character now moves at 100 speed
-- Even if game tries to reset it, it stays at 100!

-- Toggle OFF
-- Speed returns to normal (16)
```

### Disabling Player Tab

If you want to create your own player features:

```lua
local Window = Chuddy:CreateWindow({
	Name = "My Hub",
	PlayerTab = false  -- Don't create built-in tab
})

-- Now create your own
local Player = Window:CreateTab("Player", "icon")
-- Add your custom elements
```

---

## 🔧 Advanced Usage

### Programmatic Control

All elements return control objects:

```lua
-- Create elements
local speedToggle = Tab:CreateToggle({Name = "Speed", Callback = function(s) end})
local speedSlider = Tab:CreateSlider({Name = "Value", Min = 16, Max = 500, Callback = function(v) end})
local modeDropdown = Tab:CreateDropdown({Name = "Mode", Options = {"A", "B"}, Callback = function(v) end})

-- Control them later
speedToggle:SetState(true)
speedSlider:SetValue(100)
modeDropdown:SetValue("B")
```

### Dynamic UI Updates

```lua
-- Start with loading options
local dropdown = Tab:CreateDropdown({
	Name = "Players",
	Options = {"Loading..."},
	Callback = function(v) end
})

-- Update when ready
task.spawn(function()
	task.wait(2)
	local players = {}
	for _, p in ipairs(game.Players:GetPlayers()) do
		table.insert(players, p.Name)
	end
	dropdown:UpdateOptions(players)
end)
```

### Complex Callbacks

```lua
Tab:CreateToggle({
	Name = "Auto Farm",
	Callback = function(State)
		if State then
			-- Start farming loop
			getgenv().FarmLoop = game:GetService("RunService").Heartbeat:Connect(function()
				-- Farming logic
			end)
		else
			-- Stop farming
			if getgenv().FarmLoop then
				getgenv().FarmLoop:Disconnect()
				getgenv().FarmLoop = nil
			end
		end
	end
})
```

### Error Handling

```lua
Tab:CreateButton({
	Name = "Risky Operation",
	Callback = function()
		local success, error = pcall(function()
			-- Potentially failing code
			game.ReplicatedStorage.RemoteEvent:FireServer()
		end)
		
		if not success then
			warn("Operation failed:", error)
		end
	end
})
```

### State Management

```lua
-- Global state table
local State = {
	SpeedEnabled = false,
	SpeedValue = 16,
	ESPEnabled = false
}

-- Create UI elements that update state
local speedToggle = Tab:CreateToggle({
	Name = "Speed",
	Callback = function(s)
		State.SpeedEnabled = s
		-- Apply
	end
})

local speedSlider = Tab:CreateSlider({
	Name = "Speed Value",
	Min = 16,
	Max = 500,
	Callback = function(v)
		State.SpeedValue = v
		if State.SpeedEnabled then
			-- Apply
		end
	end
})

-- Load from config
local config = LoadConfig("myconfig")
if config and config.state then
	State = config.state
	speedToggle:SetState(State.SpeedEnabled)
	speedSlider:SetValue(State.SpeedValue)
end
```

---

## 💡 Best Practices

### 1. Organization

```lua
-- Good: Organized with sections
Tab:CreateSection("Combat")
Tab:CreateToggle({...})
Tab:CreateToggle({...})

Tab:CreateSection("Visuals")
Tab:CreateToggle({...})
Tab:CreateToggle({...})

-- Bad: Everything in one blob
Tab:CreateToggle({...})
Tab:CreateToggle({...})
Tab:CreateSlider({...})
Tab:CreateToggle({...})
```

### 2. Naming

```lua
-- Good: Clear descriptive names
Tab:CreateToggle({Name = "Silent Aim"})
Tab:CreateSlider({Name = "Aimbot FOV"})

-- Bad: Vague names
Tab:CreateToggle({Name = "Toggle 1"})
Tab:CreateSlider({Name = "Value"})
```

### 3. Callbacks

```lua
-- Good: Use task.spawn for heavy operations
Callback = function(value)
	task.spawn(function()
		-- Heavy computation
		for i = 1, 1000 do
			-- Stuff
		end
	end)
end

-- Good: Error handling
Callback = function(value)
	pcall(function()
		-- Risky operation
	end)
end

-- Bad: Blocking the UI thread
Callback = function(value)
	for i = 1, 1000000 do
		-- This will freeze the UI!
	end
end
```

### 4. Performance

```lua
-- Good: Debounced slider
local lastUpdate = 0
Tab:CreateSlider({
	Callback = function(v)
		if tick() - lastUpdate < 0.1 then return end
		lastUpdate = tick()
		-- Update logic
	end
})

-- Good: Clean up connections
local farmConnection
Tab:CreateToggle({
	Callback = function(s)
		if s then
			farmConnection = game:GetService("RunService").Heartbeat:Connect(function()
				-- Farm
			end)
		else
			if farmConnection then
				farmConnection:Disconnect()
				farmConnection = nil
			end
		end
	end
})
```

### 5. User Experience

```lua
-- Good: Provide feedback
Tab:CreateButton({
	Name = "Execute Script",
	Callback = function()
		-- Show feedback
		local label = Tab:CreateLabel({Text = "Executing..."})
		
		task.spawn(function()
			-- Do work
			task.wait(2)
			label:SetText("✓ Complete!")
			task.wait(2)
			-- Remove label or update again
		end)
	end
})

-- Good: Clear instructions
Tab:CreateLabel({Text = "Press E to activate fly mode"})
Tab:CreateKeybind({Name = "Fly Toggle", Default = Enum.KeyCode.E})
```

---

## 🐛 Troubleshooting

### Issue: UI doesn't appear

**Solutions:**
1. Check if executor has required functions
2. Try Method 2 (local file) instead of loadstring
3. Make sure no errors in console
4. Check if game blocks GUIs

### Issue: Elements not showing up

**Solutions:**
1. Make sure you're adding elements to the correct tab
2. Check if AutomaticCanvasSize is working (should be automatic in Ultimate version)
3. Scroll down - page might just be long
4. Recreate the window from scratch

### Issue: Keybind not working

**Solutions:**
1. Make sure no other scripts use the same key
2. Try a different key
3. Check if game captures all keyboard input
4. Use `RightControl` as it's rarely used by games

### Issue: Config not saving

**Solutions:**
1. Check if executor supports file functions:
   ```lua
   print("writefile:", writefile)
   print("readfile:", readfile)
   print("makefolder:", makefolder)
   ```
2. Make sure folder permissions allow writing
3. Try saving with a different name
4. Some executors require explicit folder creation

### Issue: Theme not applying

**Solutions:**
1. Make sure theme format is correct
2. Try using a pre-built theme first
3. Check if all required color fields are present
4. Restart the GUI after applying

### Issue: Player features not working

**Solutions:**
1. Some games have strong anti-cheat
2. Try different methods (e.g., TP method)
3. God mode method might be patched - try others
4. Make sure your character is spawned

### Issue: Minimize button doesn't show maximize

**Fixed in Ultimate version!** The minimize system now properly shows a maximize button when minimized.

### Issue: Can't drag when minimized

**Fixed in Ultimate version!** The minimized bar is now fully draggable.

---

## 📝 Complete Example

Here's a full script showcasing most features:

```lua
local Chuddy = loadstring(game:HttpGet("YOUR_URL"))()

local Window = Chuddy:CreateWindow({
	Name = "Ultimate Hub v1.0",
	Keybind = Enum.KeyCode.RightControl,
	GameConfig = true,
	PlayerTab = true
})

-- Combat Tab
local Combat = Window:CreateTab("Combat", "rbxassetid://10723356880")

Combat:CreateSection("Aimbot")

local aimbotEnabled = false
local aimbotFOV = 90

Combat:CreateToggle({
	Name = "Enable Aimbot",
	Default = false,
	Callback = function(State)
		aimbotEnabled = State
		print("Aimbot:", State)
	end
})

Combat:CreateSlider({
	Name = "FOV",
	Min = 0,
	Max = 360,
	Default = 90,
	Callback = function(Value)
		aimbotFOV = Value
	end
})

Combat:CreateKeybind({
	Name = "Aimbot Key",
	Default = Enum.KeyCode.E,
	Callback = function(Key)
		print("Aimbot key:", Key.Name)
	end
})

Combat:CreateSection("Settings")

Combat:CreateDropdown({
	Name = "Target Mode",
	Options = {"Closest", "Lowest Health", "Highest Threat"},
	Default = "Closest",
	Callback = function(Value)
		print("Target mode:", Value)
	end
})

-- Visuals Tab
local Visuals = Window:CreateTab("Visuals", "rbxassetid://10723346959")

Visuals:CreateSection("ESP")

Visuals:CreateToggle({
	Name = "Box ESP",
	Default = true,
	Callback = function(State)
		print("Box ESP:", State)
	end
})

Visuals:CreateToggle({
	Name = "Name ESP",
	Default = true,
	Callback = function(State)
		print("Name ESP:", State)
	end
})

Visuals:CreateSection("World")

Visuals:CreateSlider({
	Name = "Clock Time",
	Min = 0,
	Max = 24,
	Default = 14,
	Callback = function(Value)
		game.Lighting.ClockTime = Value
	end
})

Visuals:CreateToggle({
	Name = "Fullbright",
	Callback = function(State)
		if State then
			game.Lighting.Brightness = 2
			game.Lighting.Ambient = Color3.new(1, 1, 1)
		else
			game.Lighting.Brightness = 1
			game.Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
		end
	end
})

-- Misc Tab
local Misc = Window:CreateTab("Misc", "rbxassetid://10723415903")

Misc:CreateSection("Info")

Misc:CreateLabel({
	Text = "Made by @YourName | v1.0"
})

Misc:CreateLabel({
	Text = "Press RightControl to toggle menu"
})

Misc:CreateSection("Utilities")

Misc:CreateButton({
	Name = "Rejoin Server",
	Callback = function()
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
	end
})

Misc:CreateButton({
	Name = "Copy Discord Link",
	Callback = function()
		setclipboard("https://discord.gg/yourserver")
		print("Copied!")
	end
})

Misc:CreateInput({
	Name = "Chat Message",
	Placeholder = "Enter message...",
	Callback = function(Text, Enter)
		if Enter and Text ~= "" then
			game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Text, "All")
		end
	end
})

print("✓ Hub loaded! Press RightControl to open")
```

---

## 🏆 Credits

**Created by:** Chuddy & Enhanced by Claude (Anthropic)

**Special Thanks:**
- Infinite Yield (inspiration for player features)
- Discord (theme inspiration)
- The Roblox exploiting community

**Version:** Ultimate Edition v1.0  
**Release Date:** December 2025  
**License:** MIT

---

## 📞 Support

**Need help?**
- GitHub Issues: [Your Repo]/issues
- Discord: [Your Server]
- Documentation: This file!

**Found a bug?**
- Report it on GitHub with:
  - Executor used
  - Game PlaceId
  - Steps to reproduce
  - Error messages (if any)

---

**Made with ❤️ by chads, for chads**
