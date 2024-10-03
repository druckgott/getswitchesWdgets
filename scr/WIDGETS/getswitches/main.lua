local path = "/WIDGETS/getswitches/"
local ver, radio, maj, minor, rev, osname = getVersion()
local radioCfg
local cachedgetCustomFunction = {}
local lastToggleTime = 0  -- Speichert den letzten Umschaltzeitpunkt
local config_availible = 0
local last_model= nil
--local toggleInterval = 100  -- 2 Sekunden in EdgeTX-Zeit (1/100 Sekunden)

-- Create a table with default options
-- Options can be changed by the user from the Widget Settings menu
-- Notice that each line is a table inside { }
local defaultOptions = {
  { "aktive_color", COLOR, COLOR_THEME_FOCUS },
  { "toggleInterval", VALUE, 100, 50, 1000},
}

local customFunctionNames = {
    [0]  = "OVERRIDE_CHANNEL",        -- Override channel output
    [1]  = "TRAINER",                 -- Trainer function
    [2]  = "INSTANT_TRIM",            -- Instant trim function
    [3]  = "RESET",                   -- Reset function (e.g. reset timers, telemetry)
    [4]  = "SET_TIMER",               -- Set a specific timer value
    [5]  = "ADJUST_GVAR",             -- Adjust a global variable (GVAR)
    [6]  = "VOLUME",                  -- Adjust the volume
    [7]  = "SET_FAILSAFE",            -- Set failsafe
    [8]  = "RANGECHECK",              -- Range check function
    [9]  = "BIND",                    -- Bind receiver
    [10] = "PLAY_SOUND",              -- Play sound function
    [11] = "PLAY_TRACK",              -- Play a specific track
    [12] = "PLAY_VALUE",              -- Play telemetry or other values
    [13] = "PLAY_SCRIPT",             -- Play Lua script
    [14] = "RESERVE5",                -- Reserved function (unused)
    [15] = "BACKGND_MUSIC",           -- Play background music
    [16] = "BACKGND_MUSIC_PAUSE",     -- Pause background music
    [17] = "VARIO",                   -- Vario sound function
    [18] = "HAPTIC",                  -- Haptic feedback
    [19] = "LOGS",                    -- Logs function (e.g. start/stop logs)
    [20] = "BACKLIGHT",               -- Adjust backlight settings
    [21] = "SCREENSHOT",              -- Take a screenshot
    [22] = "RACING_MODE",             -- Enable racing mode
    [23] = "DISABLE_TOUCH"            -- Disable touchscreen
}

-- Hilfsfunktion, um zu prüfen, ob ein Name in der Tabelle vorhanden ist
local function tableContains(t, element)
    for _, value in pairs(t) do
        if value == element then
            return true
        end
    end
    return false
end

-- Hilfsfunktion, um eine Tabelle in einen lesbaren String zu konvertieren
local function tableToString(t)
    local result = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            local subt = {}
            for _, subname in ipairs(v) do
                table.insert(subt, subname)
            end
            result[#result + 1] = k .. ": {" .. table.concat(subt, ", ") .. "}"
        else
            result[#result + 1] = k .. ": " .. tostring(v)
        end
    end
    return table.concat(result, ",\t\t\t")
end

local function cacheCustomFunctions()
    local nameCount = {}
    -- leer machen, damit wenn bei einem Modellwechsel die Tabelle wieder leer ist
    cachedgetCustomFunction = {}
    --local f = io.open(path .. "log.txt", "w")

    for i = 0, 63 do
        local mySF = model.getCustomFunction(i)

        if mySF and mySF.switch ~= 0 then

            -- Zähle die Anzahl der Vorkommen des Schalternamens
            if nameCount[mySF.switch] then
                nameCount[mySF.switch] = nameCount[mySF.switch] + 1
            else
                nameCount[mySF.switch] = 1
            end

            -- Wenn der switch bereits in der Tabelle existiert
            if cachedgetCustomFunction[mySF.switch] then
                -- Wenn der Name noch nicht in der Liste für diesen Schalter vorhanden ist, füge ihn hinzu
                if not cachedgetCustomFunction[mySF.switch].sound_name_tab then
                    cachedgetCustomFunction[mySF.switch].sound_name_tab = {cachedgetCustomFunction[mySF.switch].sound_name}
                end
                -- Überprüfen, ob der Name bereits in sound_name_tab existiert, um Duplikate zu vermeiden
                if not tableContains(cachedgetCustomFunction[mySF.switch].sound_name_tab, mySF.name) then
                    table.insert(cachedgetCustomFunction[mySF.switch].sound_name_tab, mySF.name)
                    table.insert(cachedgetCustomFunction[mySF.switch].sound_name_tab_aktive, 0)
                end
            else
                -- Initialisiere die Tabelle für diesen switchname
                cachedgetCustomFunction[mySF.switch] = {
                    index = i or nil,
                    switch = mySF.switch or nil,
                    func = mySF.func or nil,
                    sound_name = mySF.name or nil,
                    value = mySF.value or nil,
                    mode = mySF.mode or nil,
                    param = mySF.param or nil,
                    active = mySF.active or nil,
                    switchname = getSwitchName(mySF.switch) or nil,
                    count = 0 or nil,
                    max_c = nameCount[mySF.switch] or nil,  -- Füge die Zählvariable hinzu
                    sound_name_tab = {mySF.name},  -- Neue Tabelle für sound_names
                    sound_name_tab_aktive = {1}
                }
            end
        end

    end

    -- Schleife durch die Tabelle mit pairs
    --for key, eintrag in pairs(cachedgetCustomFunction) do
    --    io.write(f, tableToString(cachedgetCustomFunction[key]) .. "\r\n")
    --end
        
    --io.close(f)
end


--[[
==================================================
FUNCTION: create
Called by OpenTX to create the widget
==================================================
--]]
-- Runs one time when the widget instance is registered
-- Store zone and options in the widget table for later use
local function createWidget(zone, options)
  
  local chunk = loadfile(path .. "radio/" .. string.gsub(radio, "-simu", "") .. ".lua")
  if chunk ~= nil then --get switches from config file
    radioCfg = chunk()
    config_availible = 1
    cacheCustomFunctions()
  end
    
  return { zone=zone, options=options}
end

--[[
==================================================
FUNCTION: update
Called by OpenTX on registration and at
change of settings
==================================================
--]]
-- Runs if options are changed from the Widget Settings menu
local function updateWidget(widgetToUpdate, newOptions)
  widgetToUpdate.options = newOptions
end

--[[
==================================================
FUNCTION: background
Periodically called by OpenTX
==================================================
--]]
-- Runs periodically only when widget instance is not visible
local function backgroundProcessWidget(widgetToProcessInBackground)
end

local function loadBMap (img)
  local bm;
  if img == "" or img == nil then 
    bm=nil 
  else 
    bm = Bitmap.open(path .. "img/" .. img .. ".png")
    if Bitmap.getSize(bm) == 0 then
      bm = nil
    end  
  end
  return bm
end
-- Drawing function for rounded rectangle
local function drawRoundedRectangle(x, y, width, height, r, color, shadowOffset, shadowColor)
    -- Check if shadow parameters are provided
    if shadowOffset and shadowColor then
        -- Draw shadow (slightly offset to the top right)
        lcd.drawFilledRectangle(x - shadowOffset, y + r - shadowOffset, width, height - 2 * r, shadowColor)
        lcd.drawFilledRectangle(x + r - shadowOffset, y - shadowOffset, width - 2 * r, height, shadowColor)
        lcd.drawFilledCircle(x + r - shadowOffset, y + r - shadowOffset, r, shadowColor)
        lcd.drawFilledCircle(x + width - r - 1 - shadowOffset, y + r - shadowOffset, r, shadowColor)
        lcd.drawFilledCircle(x + r - shadowOffset, y + height - r - 1 - shadowOffset, r, shadowColor)
        lcd.drawFilledCircle(x + width - r - 1 - shadowOffset, y + height - r - 1 - shadowOffset, r, shadowColor)
    end
    
    -- Draw the main rectangle
    lcd.drawFilledRectangle(x, y + r, width, height - 2 * r, color)
    lcd.drawFilledRectangle(x + r, y, width - 2 * r, height, color)
    lcd.drawFilledCircle(x + r, y + r, r, color)
    lcd.drawFilledCircle(x + width - r - 1, y + r, r, color)
    lcd.drawFilledCircle(x + r, y + height - r - 1, r, color)
    lcd.drawFilledCircle(x + width - r - 1, y + height - r - 1, r, color)
end

local function display_SF(customFunc, switchinputname)
    --if not customFunc or customFunc.switch == 0 then
    --    return nil
    --end
    -- prueft ob es ein Play Track ist und zusaetzlich ob die schalterid aus der Configtabelle zu der schalterid passt der in der Inputtabelle enthalten ist
    if customFunctionNames[customFunc.func] == "PLAY_TRACK" and customFunc.switch == getSwitchIndex(switchinputname) then
    --if customFunctionNames[customFunc.func] == "PLAY_TRACK" and getSwitchName(customFunc.switch) == switchinputname then
        -- Überprüfe, ob sound_name_tab und sound_name_tab_aktive existieren
        if customFunc.sound_name_tab and customFunc.sound_name_tab_aktive then
            -- Durchlaufe die sound_name_tab_aktive Tabelle und finde den aktuellen aktiven Wert
            for i = 1, #customFunc.sound_name_tab_aktive do
                if customFunc.sound_name_tab_aktive[i] == 1 then
                    -- Gib den zugehörigen Namen in sound_name_tab zurück
                    return customFunc.sound_name_tab[i]
                end
            end
        end
    end
    return nil
end

-- Hilfsfunktion zum Umschalten der aktiven sound_name_tab_aktive
local function toggleSoundNameTab(toggleInterval, customFunc)
    -- Überprüfen, ob die Zeit zum Umschalten gekommen ist
    local currentTime = getTime()

    if customFunc.sound_name_tab_aktive and #customFunc.sound_name_tab_aktive > 1 and (currentTime - lastToggleTime) > toggleInterval then
        -- Finde den aktuellen aktiven Index
        local currentIndex = 1
        for i = 1, #customFunc.sound_name_tab_aktive do
            if customFunc.sound_name_tab_aktive[i] == 1 then
                currentIndex = i
                break
            end
        end

        -- Setze den aktuellen Index auf 0 und den nächsten auf 1
        customFunc.sound_name_tab_aktive[currentIndex] = 0
        local nextIndex = currentIndex % #customFunc.sound_name_tab_aktive + 1
        customFunc.sound_name_tab_aktive[nextIndex] = 1

        -- Aktualisiere den letzten Umschaltzeitpunkt
        lastToggleTime = currentTime
    end
end


-- Funktion zum Erstellen des Schalternamens und Zeichnen des Textes
local function processSwitch(widget, switch, customFunc, switchcfgname, switch_value, switchType, variable, offsetY)
    
    if not customFunc or customFunc.switch == 0 or customFunc.active == 0 then
        return nil
    end

    local switchPos = switch[switchType]

        local playtrackSwitchname = switchPos and display_SF(customFunc, switchcfgname .. switchPos) or nil
        --local playtrackSwitchname = switchPos and display_SF(variable, switchcfgname .. switchPos) or nil

        if playtrackSwitchname then
        -- Schalte die Anzeige um, wenn mehrere Namen vorhanden sind
        toggleSoundNameTab(widget.options.toggleInterval, customFunc)
            local textOptions = SMLSIZE  -- Standardgröße

            if (switchType == "u" and switch_value < 0) or 
               (switchType == "m" and switch_value == 0) or 
               (switchType == "d" and switch_value > 0) then
               if widget.options.aktive_color then
                    textOptions = SMLSIZE + widget.options.aktive_color
               else
                    textOptions = SMLSIZE + COLOR_THEME_FOCUS
               end
            end
        
            -- Entfernen der ersten zwei Zeichen von switchcfgname
            switchcfgname = string.sub(switchcfgname, 3)

            -- Bestimme das Zeichen basierend auf switchType
            local switchChar = ""
            if switchType == "u" then
                switchChar = CHAR_UP
            elseif switchType == "m" then
                switchChar = "-"  -- Strich für die mittlere Position
            elseif switchType == "d" then
                switchChar = CHAR_DOWN
            end

            -- Erstelle den Text
            local text = switchcfgname .. " " .. switchChar .. playtrackSwitchname
            local w_text, h_text = lcd.sizeText(text, textOptions)
            -- Zeichne den Text
            lcd.drawText(switch.switchcfgpos_x + (radioCfg.switch_box_size_x - w_text) / 2, switch.switchcfgpos_y + offsetY, text, textOptions)
            
        end
end


-- Funktion zum Erstellen des Schalternamens und Zeichnen des Textes
local function processPush(widget, switch, customFunc, switchcfgname, switch_value, switchType, variable, offsetY)
    if not customFunc or customFunc.switch == 0 or customFunc.active == 0 then
        return nil
    end

    local switchPos = switch[switchType]

    local playtrackSwitchname = switchPos and display_SF(customFunc, switchcfgname .. switchPos) or nil
    --local playtrackSwitchname = switchPos and display_SF(variable, switchcfgname .. switchPos) or nil
    if playtrackSwitchname then
    -- Schalte die Anzeige um, wenn mehrere Namen vorhanden sind
    toggleSoundNameTab(widget.options.toggleInterval, customFunc)
    
        local textOptions = SMLSIZE  -- Standardgröße

        if (switchType == "u" and switch_value) or 
           (switchType == "d" and switch_value) then
           if widget.options.aktive_color then
                textOptions = SMLSIZE + widget.options.aktive_color
           else
                textOptions = SMLSIZE + COLOR_THEME_FOCUS
           end
        end
    
        -- Entfernen der ersten zwei Zeichen von switchcfgname
        switchcfgname = string.sub(switchcfgname, 4)

        -- Bestimme das Zeichen basierend auf switchType
        local switchChar = ""
        if switchType == "u" then
            switchChar = CHAR_UP
        elseif switchType == "d" then
            switchChar = CHAR_DOWN
        end
        
        -- Erstelle den Text
        local text = switchcfgname .. " " .. switchChar .. playtrackSwitchname
        local w_text, h_text = lcd.sizeText(text, textOptions)
        -- Zeichne den Text
        lcd.drawText(switch.switchcfgpos_x + (radioCfg.switch_push_size_x - w_text) / 2, switch.switchcfgpos_y + offsetY, text, textOptions)
    end
end

--[[
==================================================
FUNCTION: refresh
Called by OpenTX when the Widget is being displayed
==================================================
--]]

local function refreshWidget(widgetToRefresh)
local offset_counter = 1

--- bei einem Modellwechsel, muss die Special Function Liste neu gelesen werden
if last_model ~= model.getInfo().name then
    --print("Model switched:" .. model.getInfo().name)
    cacheCustomFunctions()
    last_model = model.getInfo().name
    return
end

    if config_availible > 0 then
        for _, switch in ipairs(radioCfg.sw) do
            
            if string.sub(switch.switchcfgname, 1, 2) ~= "SW" then
                drawRoundedRectangle(switch.switchcfgpos_x, switch.switchcfgpos_y, radioCfg.switch_box_size_x, radioCfg.switch_box_size_y, radioCfg.switch_box_size_radius, COLOR_THEME_SECONDARY3, 3, COLOR_THEME_SECONDARY2)
                w_text, h_text = lcd.sizeText(switch.switchcfgname , SMLSIZE + INVERS)
                lcd.drawText(switch.switchcfgpos_x+3 , switch.switchcfgpos_y+(radioCfg.switch_box_size_y-h_text)/2 , switch.switchcfgname, SMLSIZE + INVERS)
            else
                w_text, h_text = lcd.sizeText(string.sub(switch.switchcfgname, 3, 3), SMLSIZE + INVERS)
                drawRoundedRectangle(switch.switchcfgpos_x, switch.switchcfgpos_y, radioCfg.switch_push_size_x, radioCfg.switch_push_size_y, radioCfg.switch_push_size_radius, COLOR_THEME_SECONDARY3, 3, COLOR_THEME_SECONDARY2)
                lcd.drawText(switch.switchcfgpos_x+3 , switch.switchcfgpos_y+(radioCfg.switch_push_size_y-h_text)/2 , string.sub(switch.switchcfgname, 3, 3), SMLSIZE + INVERS)
            end
                
                for variable = 0, 63 do
                    local customFunc = cachedgetCustomFunction[variable]
                    
                    if customFunc then
                       
                        -- Ursprünglicher Code mit Auslagerung in die Funktion
                        local switchcfgname = switch.switchcfgname
                        local switch_value = getValue(switchcfgname)

                        if string.sub(switch.switchcfgname, 1, 2) ~= "SW" then
                            -- Zeichne den Text für die verschiedenen Schalterpositionen
                                processSwitch(widgetToRefresh, switch, customFunc, switchcfgname, switch_value, "u", variable, radioCfg.pos_switch_offset_up)
                                processSwitch(widgetToRefresh, switch, customFunc, switchcfgname, switch_value, "m", variable, radioCfg.pos_switch_offset_center)
                                processSwitch(widgetToRefresh, switch, customFunc, switchcfgname, switch_value, "d", variable, radioCfg.pos_switch_offset_down)
                        else
                            local switch_aktiv = getSwitchValue(customFunc.switch)
                            if switch_aktiv then 
                                processPush(widgetToRefresh, switch, customFunc, switchcfgname, switch_aktiv, "u", variable, 0)
                            end
                            --- nur anzeigen wenn switch nicht gedrueckt ist
                            if switch_aktiv then 
                                processPush(widgetToRefresh, switch, customFunc, switchcfgname, switch_aktiv, "d", variable, 0)
                            end
                        end
                        
                    end
                end
        end

        lcd.drawRectangle(0, 0, radioCfg.widget_area_x, radioCfg.widget_area_y, RED)
    else
        lcd.drawText(10 , 10 , "no config found, please generate one with name: ", SMLSIZE + INVERS)
        lcd.drawText(10 , 40 , path .. "radio/" .. string.gsub(radio, "-simu", "") .. ".lua", SMLSIZE + INVERS)
    end
end

return { name="SwitchOver", options=defaultOptions, create=createWidget, update=updateWidget, refresh=refreshWidget, background=backgroundProcessWidget }