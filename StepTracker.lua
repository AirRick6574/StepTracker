--Base Run: 7 Yards/Sec
--WOW 1 yard=0.9144 Real World Meter
--A yard is defined exactly as 36 inches, and an inch is defined exactly as 2.54 cm.
--So 1 yard = 36 inches × 2.54 cm = 91.44 cm = 0.9144m.
--Human travels in 0.7-0.8 in a step

--Calculations:
--5.30 Seconds = ~ 0.91 traveled on x axis
--0.91/5.3 = ~0.1717x/Second
--Base Run Speed is 7 Yards/Sec which is equals to 0.1717 change in x/second
--1.0 in x = 7/0.1717 = ~40.8 yards per full x unit
--Equivalently, 1 yard = 1 / 40.8 ≈ 0.0245 in x units.

--Goals
--Have System update every frame if chracter has changed position from previous position
--If character has chaged position, compared previous position to new position to determine change.
--For X Determine if 


--Variable Info 
local StepTracker = {
    unitsPerStepWalking = 0.840456,
    unitsPerStepRunningBackwards = 1.365441,
    unitsPerStepRunningForward = 2.779353, --wow character takes big steps
    newPosX = 0,
    newPosY = 0,
    oldPosX = 0,
    oldPosY = 0,
    totalDistance = 0,
    stepsCurrently = 0,
    stepsTotal = 0,
    currentDistance = 0,
    isNoChange = false,
    isTrackable = true
}

--REMEMBER FOR THE SYSTEM TO FIND THE COMMAND LINE, YOU HAVE TO BIND IT TO ITS VARIABLE NAME, NOT ITS VALUE
SLASH_POS1 = "/getPOS" --command name 
SLASH_DISPLAYPOS1 = "/getDistance" --command name 
SLASH_DISPLAYSTEPS1 = "/getSteps"
SLASH_CALIBRATE1 = "/calibrate40" --command name 
SLASH_CALCULATE1 = "/calculate" --command name 
SLASH_RESET1 = "/reset" --command name 

--Local Function to collect current Pos
local function getCurrentPos()
    local x1, y1 = UnitPosition("player")
    return x1, y1
    --can only return on variable, if tries two at once, will still only return first
    --wrappting a statement in partenthess collapses the position GET XY to only one variable. Function will drop y
end

local function updatePOS() 
    StepTracker.oldPosX = StepTracker.newPosX 
    StepTracker.oldPosY = StepTracker.newPosY 
    StepTracker.newPosX, StepTracker.newPosY = getCurrentPos()

    --Checks if update is trackable
    if StepTracker.newPosX == nil then 
        return false -- couldn’t update (like in dungeons)
    end
    return true
end

--[[
local function printCurrentAndOldPos()
    updatePOS()
end 
]]

--Local function to determine distance 
local function determineDistance()
   --Determine difference from old to new
    local xPosDifference = StepTracker.oldPosX - StepTracker.newPosX
    local yPosDifference = StepTracker.oldPosY - StepTracker.newPosY

    --Determine Distance from old pos to new pos using Euclidean Distance
    StepTracker.currentDistance = math.sqrt((xPosDifference^2) + (yPosDifference^2))
end

local function determineSteps()
    StepTracker.stepsCurrently = StepTracker.currentDistance / StepTracker.unitsPerStepRunningForward
    StepTracker.stepsTotal = StepTracker.stepsTotal + StepTracker.stepsCurrently 
end

--call other methods to get steps and output 
local function calculateSteps()
    --getCurrentPos()
    --Checks if not in overworld, will not track if in dungeon
    if not updatePOS() then
        return
    end
    determineDistance()

    --Check if Player is Flying
    if not UnitOnTaxi("player") then
        --Check if player is dead, will not calculate if player is dead or ghost
        if not UnitIsDeadOrGhost("player") then
            if not IsSwimming() then
                determineSteps()
                --Update Steps to Session. 
                MyAddonData.totalSteps = MyAddonData.totalSteps + StepTracker.stepsCurrently
            end
        end   
    end
    
    
end

local function printSteps()
    calculateSteps()

    print("POSITION: " .. StepTracker.newPosX .. ", " .. StepTracker.newPosY)
    print("old POSITION: " .. StepTracker.oldPosX .. ", " .. StepTracker.oldPosY)
    print("distance" .. StepTracker.currentDistance)

    print()

    print("Steps in distance: " .. math.floor(StepTracker.stepsCurrently)) --rounds dowm
    print("TotalSteps in Session: " .. math.floor(StepTracker.stepsTotal)) --rounds dowm
end


local function resetSteps()
    StepTracker.stepsCurrently = 0
    StepTracker.stepsTotal = 0
    MyAddonData.totalSteps = 0
end

-- Calibration: Determines distance for 40 yards 
local function calibrate40()
    --Raw Coords gathered for testing, 40 yards apart
    local x1 = -3762.800488281
    local y1 = -724.20001220703

    local x2 = -3761.4001464844
    local y2 = -767.20001220703

    local distanceAverage = 42.022796

    --Find Differenece 
    local dx = x2 - x1
    local dy = y2 - y1

    --Find Distance  
    local distUnits = math.sqrt(dx*dx + dy*dy)
    print(string.format("Map units traveled: %.6f", distUnits))

    -- unitsPerYard = map units ÷ yards traveled
    local unitsPerYard = distanceAverage / 40
    print(("unitsPerYard = %.8f"):format(unitsPerYard))

    -- YardsPerUnit
    local yardsPerUnit = 40 / distanceAverage
    print(("yardsPerUnit = %.8f"):format(yardsPerUnit))

    local stepYards    = 0.8 --walking
    local stepYardsRunning = 1.3
    local stepUnits    = stepYards / yardsPerUnit
    print(string.format("stepUnits = %.6f (map units per step)", stepUnits))

    local stepUnitsRunning    = stepYardsRunning / yardsPerUnit
    print(string.format("stepUnits = %.6f (map units per step)", stepUnitsRunning))
    
end


SlashCmdList["POS"] = updatePOS
SlashCmdList["DISPLAYPOS"] = determineDistance
SlashCmdList["DISPLAYSTEPS"] = determineSteps
SlashCmdList["CALIBRATE"] = calibrate40
SlashCmdList["CALCULATE"] = printSteps
SlashCmdList["RESET"] = resetSteps

--diplays Hello PlayerName 
--will not run until character is spawned in and program is intilized

-- Frames, in the context of World of Warcraft addon development, are essentially structures 
--(if you're all that familiar with Lua, they are custom tables) which allow for the detection 
--of certain game events and the creation of windows and a bunch of other cool stuff.
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD") --tells frame to watch for event (event is player entering world)

f:SetScript("OnEvent", function(self, event, ...) --similar to contents in functions, will run script once event has passed
    if event == "PLAYER_ENTERING_WORLD" then
        updatePOS()
        StepTracker.oldPosX = StepTracker.newPosX 
        StepTracker.oldPosY = StepTracker.newPosY  
    end

    -- Access the saved variable
    if not MyAddonData then
        MyAddonData = {}
    end

    if not MyAddonData.totalSteps then
        MyAddonData.totalSteps = 0
    end

    self:UnregisterEvent("ADDON_LOADED") -- only need it once
end)

--DISPLAY FRAME
local infoDisplay = CreateFrame("Frame", "infoDisplay", UIParent, "BackdropTemplate")
infoDisplay:SetSize(160, 60) 
infoDisplay:SetPoint("CENTER")        -- position on screen
infoDisplay:EnableMouse(true)
infoDisplay:SetMovable(true)
infoDisplay:SetClampedToScreen(true)

--Display Moveable Script
infoDisplay:SetScript("OnMouseDown", function(self, button)
	self:StartMoving()
end)
infoDisplay:SetScript("OnMouseUp", function(self, button)
	self:StopMovingOrSizing()
end)


--array containing background info.
local backdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", 
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
    tile = true, tileSize = 32, edgeSize = 16, 
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
}

infoDisplay:SetBackdrop(backdrop)
infoDisplay:SetBackdropBorderColor(1, 1, 1, 1)  -- pure white

--CreateText
local SessiontextFrame = infoDisplay:CreateFontString(nil, "Overlay", "GameFontNormal")
SessiontextFrame:SetPoint("CENTER", infoDisplay, "CENTER", 0, 10)  -- anchor near the top
SessiontextFrame:SetText("Penis!")

local FiletextFrame = infoDisplay:CreateFontString(nil, "Overlay", "GameFontNormal")
FiletextFrame:SetPoint("CENTER", infoDisplay, "CENTER", 0, -10)  -- anchor near the top
FiletextFrame:SetText("Penis!")

--Determine Distance every 0.2 of a second
C_Timer.NewTicker(0.2, function() 
    --in function, if no change in distance has occured, skip display step section
    --and reset check.. Otherwise, display steps.
    calculateSteps()
    if not StepTracker.isNoChange then
        if StepTracker.newPosX ~= nil then
            SessiontextFrame:SetText("Session Steps: " .. math.floor(StepTracker.stepsTotal))
        else 
            SessiontextFrame:SetText("Cannot Track here")
        end
        FiletextFrame:SetText("Total Steps: " .. math.floor(MyAddonData.totalSteps))
        --print("Session Steps: " .. math.floor(StepTracker.stepsTotal)) 
        
    end
end)

--[[
-- Give it a visible background by creating new frame attached to Parent Frame
local background = infoDisplay:CreateTexture(nil, "BACKGROUND")
background:SetAllPoints(true)
--background:SetColorTexture(0, 0, 0, 0.5)   -- RGBA, semi-transparent blue
--infoDisplay:Hide()
]]

--Doing this will create errors since position:GetXY() returns two numbers (x and y), not a single string/number.
--print("POSITION " .. position:GetXY())
--This will error out since Lua thinks y is a second argument, not part of the string


--[[
--Example of parentheses issues with lua 

function twoVals()
    return 1, 2
end

local a, b = twoVals()     -- a=1, b=2
local c, d = (twoVals())   -- c=1, d=nil


--Local funciton can be called upon 
local function HelloWorldHandler(name) --local fuction name(parameters)
    local userAddedName = string.len(name) > 0 --returns true if player name is more than zero 
    --name === paul
    --Hello, {name}!
    if(userAddedName) then --if userAddedName is true
        showGreeting(name) --calls parameter with name to use
    else
        local playerName = UnitName("player") --https://wowwiki-archive.fandom.com/wiki/API_UnitName 
        
        showGreeting(playerName) --calls function with parameter name to use
    end
end --same as function end in java }



-- local is operator for private variable, only accessible in file. 
local name = UnitName("player") --https://wowwiki-archive.fandom.com/wiki/API_UnitName  

if not MyAddonData then
    MyAddonData = {}  -- create it if it doesn't exist yet
end
]]