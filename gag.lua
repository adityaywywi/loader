local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Config (tetap sama)
local pastebinRaw = "https://link-target.net/1377368/FZzqV64Qjzhp"
local getKeyLink = "https://link-target.net/1377368/FZzqV64Qjzhp"
local backupKey = "716879cbb0452935fa31dd4aa"
local keyFileName = "WalvyGoldKeyData.json"
local expireTimeInSeconds = 60 * 60 * 24 * 7 -- 7 hari

-- ======================
-- UTILITAS & EFEK SUARA
-- ======================
local function playSound(soundId)
    if not pcall(function() return game.SoundService end) then return end
    local sound = Instance.new("Sound")
    sound.SoundId = soundId
    sound.Volume = 0.8
    sound.PlaybackSpeed = 1.2
    sound.Parent = game.SoundService
    sound:Play()
    task.delay(2, function() sound:Destroy() end)
end

local function createRainbowGoldGradient()
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),    -- Gold
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255, 235, 100)), -- Light gold
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(218, 165, 32)),  -- Goldenrod
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(184, 134, 11)), -- Dark goldenrod
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))      -- Gold
    })
    return gradient
end

local function createAnimatedBorder(parent)
    -- Main border frame (diperkecil dan diperjelas)
    local borderFrame = Instance.new("Frame", parent)
    borderFrame.Size = UDim2.new(1, 12, 1, 12) -- Lebih tebal
    borderFrame.Position = UDim2.new(0, -6, 0, -6)
    borderFrame.BackgroundTransparency = 1
    borderFrame.ZIndex = 0
    
    -- Border emas utama
    local border = Instance.new("Frame", borderFrame)
    border.Size = UDim2.new(1, 0, 1, 0)
    border.BackgroundTransparency = 0.3
    border.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    border.ZIndex = 1
    
    -- Gradient overlay untuk border
    local gradient = createRainbowGoldGradient()
    gradient.Parent = border
    gradient.Rotation = 0
    
    -- UIStroke untuk efek modern
    local stroke = Instance.new("UIStroke", borderFrame)
    stroke.Thickness = 4
    stroke.Color = Color3.fromRGB(255, 215, 0)
    stroke.Transparency = 0.2
    
    -- Animate gradient rotation
    task.spawn(function()
        while borderFrame.Parent do
            local tween = TweenService:Create(gradient, 
                TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1), 
                {Rotation = 360}
            )
            tween:Play()
            tween.Completed:Wait()
        end
    end)
    
    -- Animate border color pulse (diperkuat)
    task.spawn(function()
        while borderFrame.Parent do
            -- Emas terang
            local tween1 = TweenService:Create(border, TweenInfo.new(2, Enum.EasingStyle.Sine), {
                BackgroundColor3 = Color3.fromRGB(255, 235, 150)
            })
            tween1:Play()
            tween1.Completed:Wait()
            
            -- Emas standar
            local tween2 = TweenService:Create(border, TweenInfo.new(2, Enum.EasingStyle.Sine), {
                BackgroundColor3 = Color3.fromRGB(255, 215, 0)
            })
            tween2:Play()
            tween2.Completed:Wait()
            
            -- Emas gelap
            local tween3 = TweenService:Create(border, TweenInfo.new(2, Enum.EasingStyle.Sine), {
                BackgroundColor3 = Color3.fromRGB(184, 134, 11)
            })
            tween3:Play()
            tween3.Completed:Wait()
            
            -- Back to gold
            TweenService:Create(border, TweenInfo.new(2, Enum.EasingStyle.Sine), {
                BackgroundColor3 = Color3.fromRGB(255, 215, 0)
            }):Play()
            task.wait(2)
        end
    end)
    
    return borderFrame
end

local function createParticle(parent, position)
    local particle = Instance.new("ImageLabel", parent)
    particle.Size = UDim2.new(0, math.random(4, 8), 0, math.random(4, 8))
    particle.Position = position or UDim2.new(math.random(), 0, math.random(), 0)
    particle.BackgroundTransparency = 1
    particle.Image = "rbxasset://textures/particles/sparkles_main.dds"
    particle.ImageColor3 = Color3.fromRGB(255, 215, 0)
    particle.ImageTransparency = 0.3
    particle.ZIndex = 100
    
    local tweenInfo = TweenInfo.new(3 + math.random() * 2, Enum.EasingStyle.Quad)
    local tween = TweenService:Create(particle, tweenInfo, {
        Position = UDim2.new(particle.Position.X.Scale, 0, 1, 20),
        ImageTransparency = 1,
        Size = UDim2.new(0, 2, 0, 2)
    })
    tween:Play()
    
    tween.Completed:Connect(function()
        particle:Destroy()
    end)
end

-- =================
-- SISTEM KEY LOGIC (TETAP SAMA)
-- =================
local function checkKey(input)
    local s, r = pcall(function()
        return game:HttpGet(pastebinRaw)
    end)
    return s and (r == input or input == backupKey)
end

local function isKeySaved()
    if isfile and readfile and isfile(keyFileName) then
        local content = readfile(keyFileName)
        local success, data = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if success and data and data.key and data.timestamp then
            local timePassed = os.time() - data.timestamp
            local pasteKey = game:HttpGet(pastebinRaw)
            return timePassed <= expireTimeInSeconds and (data.key == pasteKey or data.key == backupKey)
        end
    end
    return false
end

local function saveKey(key)
    if writefile then
        local data = {key = key, timestamp = os.time()}
        local success, encoded = pcall(function()
            return HttpService:JSONEncode(data)
        end)
        if success then pcall(function() writefile(keyFileName, encoded) end) end
    end
end

local function getTimeLeft()
    if isfile(keyFileName) then
        local content = readfile(keyFileName)
        local success, data = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if success and data and data.timestamp then
            local remaining = expireTimeInSeconds - (os.time() - data.timestamp)
            if remaining > 0 then
                local days = math.floor(remaining / (3600 * 24))
                local hours = math.floor((remaining % (3600 * 24)) / 3600)
                local minutes = math.floor((remaining % 3600) / 60)
                return string.format("%dd %dh %dm left", days, hours, minutes)
            end
        end
    end
    return "Expired"
end

-- Skip jika key valid
if isKeySaved() then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/UNBELIEVABLE1838292/market/main/gag.lua", true))()
    return
end

-- =====================
-- GUI V5.1 SYPHER HUB
-- =====================

-- Main ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SypherHubV5"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Dark overlay background (less transparent)
local Overlay = Instance.new("Frame", ScreenGui)
Overlay.Size = UDim2.new(1, 0, 1, 0)
Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Overlay.BackgroundTransparency = 0.4 -- Sedikit lebih gelap
Overlay.ZIndex = 1

-- HAPUS BLUR EFFECT KARENA MENIMBULKAN BAYANGAN DI LUAR FRAME
-- blur:Destroy() -- Komentar karena tidak digunakan

-- Main Container (Less transparent, more modern)
local Container = Instance.new("Frame", ScreenGui)
Container.Size = UDim2.new(0, 520, 0, 420)
Container.Position = UDim2.new(0.5, -260, 0.5, -210)
Container.BackgroundTransparency = 0.1 -- Lebih solid
Container.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Container.BorderSizePixel = 0
Container.ZIndex = 10

-- Modern rounded corners
local UICorner = Instance.new("UICorner", Container)
UICorner.CornerRadius = UDim.new(0, 20)

-- Add animated golden border (diperjelas)
local animatedBorder = createAnimatedBorder(Container)
local borderCorner = Instance.new("UICorner", animatedBorder)
borderCorner.CornerRadius = UDim.new(0, 22)

-- Glass effect (diperhalus)
local glassGradient = Instance.new("UIGradient", Container)
glassGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40, 180)), -- RGBA with alpha
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 25, 35, 200)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30, 180))
})
glassGradient.Rotation = 90

-- Title "SYPHER HUB" with animation
local TitleFrame = Instance.new("Frame", Container)
TitleFrame.Size = UDim2.new(1, 0, 0, 80)
TitleFrame.BackgroundTransparency = 1
TitleFrame.ZIndex = 11

local Title = Instance.new("TextLabel", TitleFrame)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "SYPHER HUB"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.TextSize = 42
Title.TextStrokeTransparency = 0.3
Title.TextStrokeColor3 = Color3.fromRGB(255, 165, 0)
Title.ZIndex = 12

-- Subtitle
local Subtitle = Instance.new("TextLabel", TitleFrame)
Subtitle.Size = UDim2.new(1, 0, 0, 20)
Subtitle.Position = UDim2.new(0, 0, 0.7, 0)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "PREMIUM KEY SYSTEM"
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextColor3 = Color3.fromRGB(200, 180, 100)
Subtitle.TextSize = 14
Subtitle.ZIndex = 12

-- Animate title glow (diperkuat)
task.spawn(function()
    while Title.Parent do
        -- Efek kedip emas
        local tween1 = TweenService:Create(Title, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
            TextColor3 = Color3.fromRGB(255, 235, 150)
        })
        tween1:Play()
        tween1.Completed:Wait()
        
        local tween2 = TweenService:Create(Title, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
            TextColor3 = Color3.fromRGB(255, 215, 0)
        })
        tween2:Play()
        tween2.Completed:Wait()
        
        -- Efek besar kecil
        local tween3 = TweenService:Create(Title, TweenInfo.new(3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            TextSize = 44
        })
        tween3:Play()
        tween3.Completed:Wait()
        
        local tween4 = TweenService:Create(Title, TweenInfo.new(3, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            TextSize = 42
        })
        tween4:Play()
        tween4.Completed:Wait()
    end
end)

-- Input Field Container
local InputContainer = Instance.new("Frame", Container)
InputContainer.Size = UDim2.new(1, -60, 0, 60)
InputContainer.Position = UDim2.new(0, 30, 0, 120)
InputContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40) -- Lebih gelap
InputContainer.BorderSizePixel = 0
InputContainer.ZIndex = 11

local InputCorner = Instance.new("UICorner", InputContainer)
InputCorner.CornerRadius = UDim.new(0, 12)

local InputStroke = Instance.new("UIStroke", InputContainer)
InputStroke.Color = Color3.fromRGB(255, 215, 0)
InputStroke.Transparency = 0.5
InputStroke.Thickness = 2

local InputField = Instance.new("TextBox", InputContainer)
InputField.Size = UDim2.new(1, -20, 1, 0)
InputField.Position = UDim2.new(0, 10, 0, 0)
InputField.BackgroundTransparency = 1
InputField.Text = ""
InputField.PlaceholderText = "Enter your premium key..."
InputField.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
InputField.TextColor3 = Color3.fromRGB(255, 255, 255)
InputField.Font = Enum.Font.Gotham
InputField.TextSize = 18
InputField.ClearTextOnFocus = true
InputField.ZIndex = 12

-- Input animations
InputField.Focused:Connect(function()
    TweenService:Create(InputStroke, TweenInfo.new(0.3), {
        Transparency = 0.2,
        Thickness = 3
    }):Play()
    
    -- Create golden particles (lebih banyak)
    for i = 1, 15 do
        task.spawn(function()
            createParticle(Container, UDim2.new(math.random(), 0, 0.3, 0))
        end)
    end
end)

InputField.FocusLost:Connect(function()
    TweenService:Create(InputStroke, TweenInfo.new(0.3), {
        Transparency = 0.5,
        Thickness = 2
    }):Play()
end)

-- Auto-fill from clipboard
if syn and syn.clipboard and syn.clipboard ~= "" then
    InputField.Text = syn.clipboard
end

-- Status Display (dengan animasi)
local StatusFrame = Instance.new("Frame", Container)
StatusFrame.Size = UDim2.new(1, -60, 0, 50)
StatusFrame.Position = UDim2.new(0, 30, 0, 200)
StatusFrame.BackgroundTransparency = 1
StatusFrame.ZIndex = 11

local StatusText = Instance.new("TextLabel", StatusFrame)
StatusText.Size = UDim2.new(1, 0, 1, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "🔐 Ready for authentication"
StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusText.Font = Enum.Font.Gotham
StatusText.TextSize = 16
StatusText.TextWrapped = true
StatusText.ZIndex = 12

-- Animasi teks status (pulse saat berubah)
local function pulseStatus()
    local originalSize = StatusText.TextSize
    TweenService:Create(StatusText, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        TextSize = originalSize + 2
    }):Play()
    task.delay(0.5, function()
        TweenService:Create(StatusText, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
            TextSize = originalSize
        }):Play()
    end)
end

-- Progress Bar (diperbaiki)
local ProgressBar = Instance.new("Frame", StatusFrame)
ProgressBar.Size = UDim2.new(1, 0, 0, 6) -- Lebih tipis
ProgressBar.Position = UDim2.new(0, 0, 1, -8)
ProgressBar.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
ProgressBar.BorderSizePixel = 0
ProgressBar.ZIndex = 11

local ProgressBarCorner = Instance.new("UICorner", ProgressBar)
ProgressBarCorner.CornerRadius = UDim.new(0, 3)

local ProgressFill = Instance.new("Frame", ProgressBar)
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(50, 200, 255) -- Biru untuk kontras
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 12

local ProgressFillCorner = Instance.new("UICorner", ProgressFill)
ProgressFillCorner.CornerRadius = UDim.new(0, 3)

-- Modern Buttons
local ButtonContainer = Instance.new("Frame", Container)
ButtonContainer.Size = UDim2.new(1, -60, 0, 60)
ButtonContainer.Position = UDim2.new(0, 30, 0, 280)
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.ZIndex = 11

-- Get Key Button
local GetKeyButton = Instance.new("TextButton", ButtonContainer)
GetKeyButton.Size = UDim2.new(0.48, -5, 1, 0)
GetKeyButton.Position = UDim2.new(0, 0, 0, 0)
GetKeyButton.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
GetKeyButton.Text = "GET KEY"
GetKeyButton.TextColor3 = Color3.fromRGB(20, 20, 20)
GetKeyButton.Font = Enum.Font.GothamBold
GetKeyButton.TextSize = 18
GetKeyButton.AutoButtonColor = false
GetKeyButton.ZIndex = 12

local GetKeyCorner = Instance.new("UICorner", GetKeyButton)
GetKeyCorner.CornerRadius = UDim.new(0, 10)

-- Validate Button
local ValidateButton = Instance.new("TextButton", ButtonContainer)
ValidateButton.Size = UDim2.new(0.48, -5, 1, 0)
ValidateButton.Position = UDim2.new(0.52, 5, 0, 0)
ValidateButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ValidateButton.Text = "VALIDATE"
ValidateButton.TextColor3 = Color3.fromRGB(255, 215, 0)
ValidateButton.Font = Enum.Font.GothamBold
ValidateButton.TextSize = 18
ValidateButton.AutoButtonColor = false
ValidateButton.ZIndex = 12

local ValidateCorner = Instance.new("UICorner", ValidateButton)
ValidateCorner.CornerRadius = UDim.new(0, 10)

-- Button stroke effects
local GetKeyStroke = Instance.new("UIStroke", GetKeyButton)
GetKeyStroke.Color = Color3.fromRGB(255, 235, 150)
GetKeyStroke.Transparency = 0.5
GetKeyStroke.Thickness = 2

local ValidateStroke = Instance.new("UIStroke", ValidateButton)
ValidateStroke.Color = Color3.fromRGB(255, 215, 0)
ValidateStroke.Transparency = 0.5
ValidateStroke.Thickness = 2

-- Button animations
local function setupButton(button, stroke)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
            Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, 0, 65)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Transparency = 0,
            Thickness = 3
        }):Play()
        playSound("rbxassetid://5176932766")
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            Size = UDim2.new(button.Size.X.Scale, button.Size.X.Offset, 1, 0)
        }):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {
            Transparency = 0.5,
            Thickness = 2
        }):Play()
    end)
    
    button.MouseButton1Click:Connect(function()
        -- Click effect (diperbaiki)
        local clickEffect = Instance.new("Frame", button)
        clickEffect.Size = UDim2.new(0, 15, 0, 15)
        clickEffect.Position = UDim2.new(0.5, -7.5, 0.5, -7.5)
        clickEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        clickEffect.BackgroundTransparency = 0.7
        clickEffect.ZIndex = 13
        
        local effectCorner = Instance.new("UICorner", clickEffect)
        effectCorner.CornerRadius = UDim.new(0, 8)
        
        TweenService:Create(clickEffect, TweenInfo.new(0.4), {
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(0.5, -15, 0.5, -15),
            BackgroundTransparency = 1
        }):Play()
        
        task.delay(0.4, function() clickEffect:Destroy() end)
    end)
end

setupButton(GetKeyButton, GetKeyStroke)
setupButton(ValidateButton, ValidateStroke)

-- Close Button (modern)
local CloseButton = Instance.new("TextButton", Container)
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -45, 0, 10)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 24
CloseButton.AutoButtonColor = false
CloseButton.ZIndex = 13

local CloseCorner = Instance.new("UICorner", CloseButton)
CloseCorner.CornerRadius = UDim.new(0, 8)

CloseButton.MouseEnter:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 50, 50),
        Size = UDim2.new(0, 38, 0, 38)
    }):Play()
end)

CloseButton.MouseLeave:Connect(function()
    TweenService:Create(CloseButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(255, 80, 80),
        Size = UDim2.new(0, 35, 0, 35)
    }):Play()
end)

CloseButton.MouseButton1Click:Connect(function()
    playSound("rbxassetid://5176932766")
    TweenService:Create(Container, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    TweenService:Create(Overlay, TweenInfo.new(0.5), {
        BackgroundTransparency = 1
    }):Play()
    
    task.delay(0.5, function()
        ScreenGui:Destroy()
        -- Pastikan tidak ada efek tersisa
        if game.Lighting:FindFirstChild("Blur") then
            game.Lighting:FindFirstChild("Blur"):Destroy()
        end
    end)
end)

-- Drag functionality (diperhalus)
local dragging, dragInput, dragStart, startPos
local function makeDraggable(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end
makeDraggable(Container)

-- Particle generator (ditingkatkan)
task.spawn(function()
    while Container.Parent do
        -- Partikel emas acak di background
        createParticle(Container)
        
        -- Partikel khusus di dekat border
        if math.random() > 0.7 then
            createParticle(animatedBorder, UDim2.new(math.random(0,1), -10, math.random(0,1), -10))
        end
        
        task.wait(0.3)
    end
end)

-- ====================
-- BUTTON ACTIONS (dengan tambahan efek)
-- ====================

GetKeyButton.MouseButton1Click:Connect(function()
    setclipboard(getKeyLink)
    StatusText.Text = "✅ Key link copied to clipboard!"
    StatusText.TextColor3 = Color3.fromRGB(100, 255, 150)
    pulseStatus() -- Animasi pulse
    
    -- Celebration particles (lebih banyak dan warna warni)
    for i = 1, 25 do
        task.spawn(function()
            local particle = Instance.new("ImageLabel", Container)
            particle.Size = UDim2.new(0, math.random(3, 7), 0, math.random(3, 7))
            particle.Position = UDim2.new(0.5, math.random(-100,100), 0.5, math.random(-100,100))
            particle.BackgroundTransparency = 1
            particle.Image = "rbxasset://textures/particles/sparkles_main.dds"
            
            -- Warna acak emas kekuningan
            local hue = 0.15 + math.random() * 0.1
            particle.ImageColor3 = Color3.fromHSV(hue, 0.8, 1)
            
            particle.ZIndex = 100
            
            local tweenInfo = TweenInfo.new(2 + math.random() * 2, Enum.EasingStyle.Quad)
            local tween = TweenService:Create(particle, tweenInfo, {
                Position = UDim2.new(particle.Position.X.Scale, 0, 1, 20),
                ImageTransparency = 1,
                Size = UDim2.new(0, 1, 0, 1)
            })
            tween:Play()
            
            tween.Completed:Connect(function()
                particle:Destroy()
            end)
        end)
    end
    
    playSound("rbxassetid://9117929971")
end)

-- Validation logic (dengan tambahan efek)
local failedAttempts = 0
local function validateKey(inputKey)
    StatusText.Text = "🔄 Validating key..."
    StatusText.TextColor3 = Color3.fromRGB(255, 215, 0)
    pulseStatus()
    
    -- Animate progress bar
    TweenService:Create(ProgressFill, TweenInfo.new(2), {
        Size = UDim2.new(1, 0, 1, 0)
    }):Play()
    
    -- Create scanning effect
    for i = 1, 8 do
        task.spawn(function()
            local scanner = Instance.new("Frame", Container)
            scanner.Size = UDim2.new(0, 4, 0, 200)
            scanner.Position = UDim2.new(0.5, -2, 0.5, -100)
            scanner.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
            scanner.BackgroundTransparency = 0.7
            scanner.ZIndex = 20
            
            TweenService:Create(scanner, TweenInfo.new(1.5), {
                Position = UDim2.new(0.5, -2, 0.5, 100),
                BackgroundTransparency = 1
            }):Play()
            
            task.delay(1.5, function() scanner:Destroy() end)
        end)
    end
    
    task.spawn(function()
        task.wait(2)
        local isValid = checkKey(inputKey)
        
        if isValid then
            saveKey(inputKey)
            StatusText.Text = "✅ Key validated! Welcome to Sypher Hub! " .. getTimeLeft()
            StatusText.TextColor3 = Color3.fromRGB(100, 255, 150)
            pulseStatus()
            
            -- Success particles (warna warni)
            for i = 1, 40 do
                task.spawn(function()
                    local particle = Instance.new("ImageLabel", Container)
                    particle.Size = UDim2.new(0, math.random(3, 8), 0, math.random(3, 8))
                    particle.Position = UDim2.new(0.5, math.random(-120,120), 0.5, math.random(-120,120))
                    particle.BackgroundTransparency = 1
                    particle.Image = "rbxasset://textures/particles/sparkles_main.dds"
                    
                    -- Warna acak cerah
                    local hue = math.random() * 0.2
                    particle.ImageColor3 = Color3.fromHSV(hue, 0.9, 1)
                    
                    particle.ZIndex = 100
                    
                    local tweenInfo = TweenInfo.new(3 + math.random() * 2, Enum.EasingStyle.Quad)
                    local tween = TweenService:Create(particle, tweenInfo, {
                        Position = UDim2.new(particle.Position.X.Scale, 0, 1, 20),
                        ImageTransparency = 1,
                        Size = UDim2.new(0, 1, 0, 1)
                    })
                    tween:Play()
                    
                    tween.Completed:Connect(function()
                        particle:Destroy()
                    end)
                end)
            end
            
            playSound("rbxassetid://9117929971")
            
            task.delay(2, function()
                TweenService:Create(Container, TweenInfo.new(0.8, Enum.EasingStyle.Back), {
                    Size = UDim2.new(0, 0, 0, 0),
                    Position = UDim2.new(0.5, 0, 0.5, 0)
                }):Play()
                
                task.delay(0.8, function()
                    ScreenGui:Destroy()
                    if game.Lighting:FindFirstChild("Blur") then
                        game.Lighting:FindFirstChild("Blur"):Destroy()
                    end
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Walvytriplesix/fish-it/refs/heads/main/roblox", true))()
                end)
            end)
        else
            failedAttempts += 1
            StatusText.Text = "❌ Invalid key! Attempts: " .. failedAttempts .. "/3"
            StatusText.TextColor3 = Color3.fromRGB(255, 100, 100)
            pulseStatus()
            
            TweenService:Create(ProgressFill, TweenInfo.new(0.3), {
                Size = UDim2.new(0, 0, 1, 0)
            }):Play()
            
            -- Error particles (merah)
            for i = 1, 15 do
                task.spawn(function()
                    local particle = Instance.new("ImageLabel", Container)
                    particle.Size = UDim2.new(0, math.random(3, 7), 0, math.random(3, 7))
                    particle.Position = UDim2.new(0.5, math.random(-100,100), 0.7, math.random(-40,40))
                    particle.BackgroundTransparency = 1
                    particle.Image = "rbxasset://textures/particles/sparkles_main.dds"
                    
                    -- Warna merah
                    particle.ImageColor3 = Color3.fromRGB(255, 100, 100)
                    
                    particle.ZIndex = 100
                    
                    local tweenInfo = TweenInfo.new(2 + math.random() * 2, Enum.EasingStyle.Quad)
                    local tween = TweenService:Create(particle, tweenInfo, {
                        Position = UDim2.new(particle.Position.X.Scale, 0, 1, 20),
                        ImageTransparency = 1,
                        Size = UDim2.new(0, 1, 0, 1)
                    })
                    tween:Play()
                    
                    tween.Completed:Connect(function()
                        particle:Destroy()
                    end)
                end)
            end
            
            playSound("rbxassetid://5176932766")
            
            if failedAttempts >= 3 then
                StatusText.Text = "⛔ Too many attempts! Wait 10 seconds..."
                pulseStatus()
                
                -- Lockdown effect (merah)
                local lockdown = Instance.new("Frame", Container)
                lockdown.Size = UDim2.new(1, 0, 1, 0)
                lockdown.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                lockdown.BackgroundTransparency = 0.8
                lockdown.ZIndex = 15
                
                local lockdownTween = TweenService:Create(lockdown, TweenInfo.new(0.5), {
                    BackgroundTransparency = 0.6
                })
                lockdownTween:Play()
                
                GetKeyButton.Visible = false
                ValidateButton.Visible = false
                
                task.delay(10, function()
                    failedAttempts = 0
                    StatusText.Text = "🔐 Ready for authentication"
                    StatusText.TextColor3 = Color3.fromRGB(200, 200, 200)
                    pulseStatus()
                    GetKeyButton.Visible = true
                    ValidateButton.Visible = true
                    lockdown:Destroy()
                end)
            end
        end
    end)
end

ValidateButton.MouseButton1Click:Connect(function()
    validateKey(InputField.Text)
end)

InputField.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        validateKey(InputField.Text)
    end
end)

-- Entry animation (diperbaiki)
Container.Size = UDim2.new(0, 0, 0, 0)
Container.Position = UDim2.new(0.5, -260, 0.5, -210)

-- Animasi muncul dengan bounce
TweenService:Create(Container, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 520, 0, 420)
}):Play()

-- Particle intro
for i = 1, 30 do
    task.spawn(function()
        createParticle(Container)
    end)
end

playSound("rbxassetid://9117929971")
