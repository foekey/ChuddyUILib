# SETUP GUIDE

Complete guide for setting up and deploying Chuddy Hub Ultimate Edition.

---

## 📋 Table of Contents
- [For Users](#for-users)
- [For Developers](#for-developers)
- [GitHub Setup](#github-setup)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)

---

## 👥 For Users

### Installation Steps

1. **Choose Your Executor**
   - Synapse X ✅
   - Script-Ware ✅
   - KRNL ✅
   - Fluxus ✅
   - Delta ✅
   - Any modern executor

2. **Load the Script**
   ```lua
   loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ChuddyUILib/main/source.lua"))()
   ```

3. **First Time Setup**
   - UI will appear in the center of your screen
   - Default keybind: `RightControl`
   - Built-in Player tab is auto-created

4. **Customize Settings**
   - Click "Settings" button in sidebar
   - Change theme from dropdown
   - Set your preferred keybind
   - Save your config!

### Quick Tips

**Using Configs:**
- Configs auto-save per game (when `GameConfig = true`)
- Manual save: Go to Settings → Enter name → Click "Save Config"
- Load saved config: Enter name → Click "Load Config"

**Using Themes:**
- Change theme in Settings → "Theme Preset" dropdown
- Export your theme: Settings → "Export Theme to Clipboard"
- Share JSON with friends!

**Using Player Tab:**
- Toggle features ON before adjusting values
- Values persist even if game tries to reset them
- Turn OFF to restore defaults

---

## 👨‍💻 For Developers

### Prerequisites

- Text editor (VS Code, Sublime, etc.)
- GitHub account (for hosting)
- Basic Lua knowledge
- Roblox executor for testing

### Local Development

1. **Clone/Download**
   ```bash
   git clone https://github.com/YOUR_USERNAME/ChuddyUILib.git
   cd ChuddyUILib
   ```

2. **File Structure**
   ```
   ChuddyUILib/
   ├── source.lua              # Main library
   ├── test_ultimate.lua       # Test script
   ├── DOCUMENTATION.md        # Full docs
   ├── README.md              # GitHub readme
   ├── SETUP.md               # This file
   ├── CHANGELOG_V2.md        # Version history
   └── LICENSE                # MIT license
   ```

3. **Testing Locally**
   ```lua
   -- In your executor
   local Library = loadfile("path/to/ChuddyUILib_Ultimate.lua")()
   
   local Window = Library:CreateWindow({
       Name = "Test Hub",
       Keybind = Enum.KeyCode.RightControl
   })
   ```

### Creating Your Hub

1. **Start with Template**
   ```lua
   local Chuddy = loadstring(game:HttpGet("YOUR_URL"))()
   
   local Window = Chuddy:CreateWindow({
       Name = "Your Hub Name",
       Keybind = Enum.KeyCode.RightControl,
       PlayerTab = true  -- or false if making custom
   })
   ```

2. **Add Tabs**
   ```lua
   local Main = Window:CreateTab("Main", "rbxassetid://ICON")
   local Settings = Window:CreateTab("Settings", "rbxassetid://ICON")
   ```

3. **Add Elements**
   ```lua
   Main:CreateSection("Features")
   Main:CreateToggle({Name = "Feature", Callback = function(s) end})
   Main:CreateSlider({Name = "Value", Min = 0, Max = 100, Callback = function(v) end})
   ```

4. **Test Thoroughly**
   - Test each element
   - Test minimizing/maximizing
   - Test dragging/resizing
   - Test theme changes
   - Test config save/load
   - Test in multiple games

---

## 🌐 GitHub Setup

### Creating Repository

1. **Create New Repo**
   - Go to GitHub.com
   - Click "New Repository"
   - Name: `ChuddyUILib` (or your preference)
   - Public/Private: Your choice
   - Initialize with README: No (we have one)

2. **Upload Files**
   ```bash
   git init
   git add .
   git commit -m "Initial commit - Chuddy Hub Ultimate"
   git branch -M main
   git remote add origin https://github.com/YOUR_USERNAME/ChuddyUILib.git
   git push -u origin main
   ```

3. **Verify Upload**
   - Check all files are present
   - Test raw URL works
   - Verify `source.lua` is accessible

### Raw URL

Your loadstring URL will be:
```
https://raw.githubusercontent.com/YOUR_USERNAME/ChuddyUILib/main/source.lua
```

**Important:** 
- Replace `YOUR_USERNAME` with your GitHub username
- Replace `source.lua` with actual filename if different

---

## 🚀 Deployment

### Method 1: Direct Load (Recommended)

**Users load directly from GitHub:**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/ChuddyUILib/main/source.lua"))()
```

**Pros:**
- Always up to date
- Easy to update (just push to GitHub)
- Users don't need to redownload

**Cons:**
- Requires internet
- GitHub must be accessible

### Method 2: Pastebin

1. **Create Pastebin**
   - Go to pastebin.com
   - Paste `ChuddyUILib_Ultimate.lua` content
   - Save as "Unlisted" or "Public"
   - Get raw link

2. **Loadstring**
   ```lua
   loadstring(game:HttpGet("https://pastebin.com/raw/PASTE_ID"))()
   ```

**Pros:**
- Backup if GitHub is down
- Some executors prefer Pastebin

**Cons:**
- Must update manually
- Pastebin has size limits

### Method 3: Multi-Source

**Best practice: Support multiple sources**
```lua
local success, Library = pcall(function()
    return loadstring(game:HttpGet("PRIMARY_URL"))()
end)

if not success then
    Library = loadstring(game:HttpGet("BACKUP_URL"))()
end
```

### Version Control

**Tag Releases:**
```bash
git tag -a v1.0.0 -m "Ultimate Edition Release"
git push origin v1.0.0
```

**Branch Strategy:**
- `main` - Stable releases
- `dev` - Development/testing
- `feature/X` - New features

---

## 🔧 Troubleshooting

### Common Issues

**Issue: "loadstring" not found**
```lua
-- Solution: Executor doesn't support loadstring
-- Try: Load from file instead
local Library = loadfile("path/to/file.lua")()
```

**Issue: "attempt to index nil"**
```lua
-- Solution: Library didn't load properly
-- Check: Internet connection, URL correctness
-- Debug: print(game:HttpGet("YOUR_URL"))
```

**Issue: Config not saving**
```lua
-- Solution: Executor doesn't support file functions
-- Check: print(writefile, readfile, makefolder)
-- Workaround: Use themes without configs
```

**Issue: Player features not working**
```lua
-- Solution: Game has strong anti-cheat
-- Try: Different TP method, different executor
-- Note: Some games patch god mode
```

**Issue: Theme not loading**
```lua
-- Solution: Theme JSON might be corrupted
-- Fix: Re-export theme or use built-in preset
-- Check: JSON format is valid
```

### Debug Mode

**Add debug prints:**
```lua
-- At top of script
local DEBUG = true

local function log(...)
    if DEBUG then
        print("[CHUDDY]", ...)
    end
end

-- Use throughout code
log("Creating window...")
log("Tab created:", tabName)
log("Config loaded:", configName)
```

### Performance Issues

**If UI is laggy:**
1. Reduce number of elements
2. Disable unused features
3. Use sections to organize
4. Check for infinite loops in callbacks
5. Make sure RunService connections are cleaned up

**Memory Check:**
```lua
-- Before loading
local mem1 = collectgarbage("count")

-- After loading
local mem2 = collectgarbage("count")
print("Memory used:", mem2 - mem1, "KB")
```

---

## 📝 Best Practices

### For Hub Developers

1. **Test Everything**
   - Test in multiple games
   - Test with different executors
   - Test all features work together
   - Test edge cases

2. **Organize Your Code**
   - Use sections liberally
   - Group related features
   - Comment complex logic
   - Keep callbacks simple

3. **Error Handling**
   ```lua
   Callback = function(value)
       pcall(function()
           -- Your code here
       end)
   end
   ```

4. **User Experience**
   - Clear element names
   - Helpful labels
   - Sensible defaults
   - Immediate feedback

5. **Performance**
   - Debounce slider callbacks
   - Clean up connections
   - Use task.spawn for heavy work
   - Profile your code

### For Theme Creators

1. **Color Contrast**
   - Text should be readable
   - Buttons should stand out
   - Accent color should pop
   - Test on different monitors

2. **Consistency**
   - Similar elements use similar colors
   - Maintain hierarchy (text > textdim)
   - Keep stroke subtle

3. **Accessibility**
   - Don't rely only on color
   - Test colorblind modes
   - Ensure good contrast ratios

### For Config Creators

1. **Naming**
   - Use descriptive names
   - Include version in name
   - Use game names for game-specific

2. **Organization**
   ```lua
   {
       theme = {...},
       settings = {
           combat = {...},
           visuals = {...},
           misc = {...}
       }
   }
   ```

3. **Sharing**
   - Test before sharing
   - Include instructions
   - Note any game-specific features
   - Version number

---

## 🎓 Advanced Topics

### Custom Themes

**Create complete custom theme:**
```lua
local MyTheme = {
    Name = "Custom Theme",
    Main = Color3.fromRGB(20, 20, 25),
    Sidebar = Color3.fromRGB(25, 25, 30),
    Element = Color3.fromRGB(35, 35, 40),
    ElementHover = Color3.fromRGB(45, 45, 50),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(100, 200, 255),
    Stroke = Color3.fromRGB(50, 50, 55),
    Divider = Color3.fromRGB(40, 40, 45)
}

ApplyTheme(MyTheme)
SaveTheme("mytheme", MyTheme)
```

### Custom Player Features

**Disable built-in, create your own:**
```lua
local Window = Chuddy:CreateWindow({
    Name = "Hub",
    PlayerTab = false  -- Disable built-in
})

local Player = Window:CreateTab("Player", "icon")

-- Your custom implementation
Player:CreateSection("Custom Features")
-- Add your elements...
```

### Game-Specific Hubs

**Auto-detect game and load appropriate config:**
```lua
local PlaceId = game.PlaceId
local GameConfigs = {
    [123456] = "game1_config",
    [789012] = "game2_config"
}

local configName = GameConfigs[PlaceId] or "default"
local config = LoadConfig(configName)

if config then
    ApplyTheme(config.theme)
    -- Load other settings
end
```

---

## 📧 Support

**Need Help?**
- 📖 Read [DOCUMENTATION.md](DOCUMENTATION.md)
- 🐛 Report bugs on GitHub Issues
- 💬 Join Discord server
- 📧 Email: support@chuddy.hub

---

**Made with ❤️ by chads, for chads**
