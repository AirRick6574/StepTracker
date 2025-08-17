SLASH_HELLO1 = "/helloworld" --command name 
SLASH_HELLO2 = "/hellow"

--Local function to gather name
local function showGreeting(name)
    local greeting = "Hello " .. name .. "!"
    message(greeting)
end

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

SlashCmdList["HELLO"] = HelloWorldHandler

-- local is operator for private variable, only accessible in file. 
local name = UnitName("player") --https://wowwiki-archive.fandom.com/wiki/API_UnitName  

--diplays Hello PlayerName
message("Hello " .. name .. "!")