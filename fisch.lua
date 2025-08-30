-- VORTX HUB | RED ELEGANT LOADER v21 - Auto Destroy After 100%
-- Merah elegan + fast bar + auto destroy saat 100%
local player = game:GetService("Players").LocalPlayer
local TS = game:GetService("TweenService")

local scr = Instance.new("ScreenGui")
scr.IgnoreGuiInset = true
scr.ResetOnSpawn = false
scr.Parent = game.CoreGui

------------------------------------------------------------------
-- 1. RED ELEGANT INTRO
------------------------------------------------------------------
local intro = Instance.new("Frame")
intro.Size = UDim2.new(1,0,1,0)
intro.BackgroundColor3 = Color3.fromRGB(0,0,0)
intro.Parent = scr

local title = Instance.new("TextLabel")
title.Size = UDim2.new(.8,0,.3,0)
title.Position = UDim2.new(.1,0,.35,0)
title.Text = "VORTX"
title.Font = Enum.Font.GothamBlack
title.TextSize = 150
title.TextColor3 = Color3.fromRGB(255,0,0)
title.BackgroundTransparency = 1
title.TextStrokeColor3 = Color3.fromRGB(100,0,0)
title.TextStrokeTransparency = 0
title.TextTransparency = 1
title.Parent = intro

spawn(function()
    TS:Create(title,TweenInfo.new(1.2,Enum.EasingStyle.Elastic),{TextTransparency=0}):Play()
    wait(1.2)
    TS:Create(title,TweenInfo.new(.6),{TextTransparency=1}):Play()
    wait(0.6)
    intro:Destroy()
    showRedScreen()
end)

------------------------------------------------------------------
-- 2. RED SCREEN
------------------------------------------------------------------
function showRedScreen()
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(5,0,0)
    bg.Parent = scr

    -- red particles
    for i=1,200 do
        local p = Instance.new("Frame")
        p.Size = UDim2.new(0,math.random(1,3),0,math.random(1,3))
        p.Position = UDim2.new(math.random(),0,math.random(),0)
        p.BackgroundColor3 = Color3.fromRGB(255,0,0)
        p.BackgroundTransparency = math.random(4,9)/10
        p.BorderSizePixel = 0
        local c = Instance.new("UICorner"); c.CornerRadius=UDim.new(1,0); c.Parent=p
        p.Parent = bg
        spawn(function()
            while true do
                TS:Create(p,TweenInfo.new(math.random(5,15)),{Position=UDim2.new(p.Position.X.Scale,0,(p.Position.Y.Scale+0.02)%1,0)}):Play()
                wait(math.random(5,15))
            end
        end)
    end

    -- title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(.9,0,.1,0)
    title.Position = UDim2.new(.05,0,.05,0)
    title.Text = "VORTX HUB"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 70
    title.TextColor3 = Color3.fromRGB(255,0,0)
    title.BackgroundTransparency = 1
    title.TextStrokeColor3 = Color3.fromRGB(150,0,0)
    title.TextStrokeTransparency = 0.2
    title.Parent = bg

    -- progress bar
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(.7,0,.05,0)
    barBg.Position = UDim2.new(.15,0,.35,0)
    barBg.BackgroundColor3 = Color3.fromRGB(20,0,0)
    barBg.BorderSizePixel = 0
    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0,15)
    bCorner.Parent = barBg
    local bStroke = Instance.new("UIStroke")
    bStroke.Color = Color3.fromRGB(255,0,0)
    bStroke.Thickness = 3
    bStroke.Parent = barBg
    barBg.Parent = bg

    local barFill = Instance.new("Frame")
    barFill.Size = UDim2.new(0,0,1,0)
    barFill.BackgroundColor3 = Color3.fromRGB(255,0,0)
    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0,15)
    fCorner.Parent = barFill
    barFill.Parent = barBg

    local pct = Instance.new("TextLabel")
    pct.Size = UDim2.new(.2,0,.08,0)
    pct.Position = UDim2.new(.4,0,.42,0)
    pct.Text = "0 %"
    pct.Font = Enum.Font.GothamBlack
    pct.TextSize = 45
    pct.TextColor3 = Color3.fromRGB(255,0,0)
    pct.BackgroundTransparency = 1
    pct.Parent = bg

    ------------------------------------------------------------------
    -- SCRIPT STORAGE
    ------------------------------------------------------------------
    local scriptStorage = {
        mainScript = [[
-- VORTX Main Script
loadstring(game:HttpGet("https://raw.githubusercontent.com/VortXHub/fisch/main/vortxhub.lua"))()
]]
    }

    ------------------------------------------------------------------
    -- FAST LOADING + AUTO DESTROY
    ------------------------------------------------------------------
    local percent = 0
    spawn(function()
        while percent<100 do
            local step = math.random(10,20) -- super cepat
            percent = math.min(percent+step,100)
            TS:Create(barFill,TweenInfo.new(.15,Enum.EasingStyle.Quad),{Size=UDim2.new(percent/100,0,1,0)}):Play()
            pct.Text = percent.." %"
            wait(0.1)
        end
        
        pct.Text = "COMPLETE!"
        wait(1)
        
        -- execute script
        loadstring(scriptStorage.mainScript)()
        
        -- fade out semua
        local fadeTime = 0.8
        TS:Create(bg,TweenInfo.new(fadeTime),{BackgroundTransparency=1}):Play()
        for _,v in ipairs({title,pct,barBg,barFill}) do
            if v:IsA("TextLabel") then
                TS:Create(v,TweenInfo.new(fadeTime),{TextTransparency=1}):Play()
            else
                TS:Create(v,TweenInfo.new(fadeTime),{BackgroundTransparency=1}):Play()
            end
        end
        wait(fadeTime)
        
        -- destroy total
        scr:Destroy()
    end)
end

setclipboard("discord.gg/jxJ8HNQKjH")
