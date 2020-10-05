-- GLOBAL VARS:
Current_action = ""

-- HELPER FUNCTIONS:
-- Joins two tables
local function merge_tables(t1, t2)
    for k,v in ipairs(t2) do
        table.insert(t1, v)
    end 
  
    return t1
end


-- Calls the Python file
local function evoque_python(flags)
    -- Find the path
    local location

    if os.getenv("HOME") == nil then
        -- If you are using Windows, it will assume you are using mpv.net
        location = os.getenv("APPDATA") .. "/mpv.net/Scripts/trakt-mpv/main.py"
    else
        -- If you are using Linux, it will assume you are using mpv
        location = os.getenv("HOME") .. "/.config/mpv/scripts/trakt-mpv/main.py"
    end

    -- Add the flags
    local args = merge_tables({ "python", location }, flags)

    -- Call the file
    local r = mp.command_native({
        name = "subprocess",
        capture_stdout = true,
        args = args,
    })

    return r.status, r.stdout
end

-- Sends a message
local function send_message(msg, color, time)
    local ass_start = mp.get_property_osd("osd-ass-cc/0")
    local ass_stop = mp.get_property_osd("osd-ass-cc/1")
    mp.osd_message(ass_start .. "{\\1c&H" .. color .. "&}" .. msg .. ass_stop, time)
end

-- Activate Function
local function activated()
    local status, output = evoque_python({"--auth"})

    if status == 0 then
        send_message("It's done. Enjoy!", "00FF00", 3)
        mp.remove_key_binding("auth-trakt")
    else
        send_message("Damn, there was an error in Python :/ Check the console for more info.", "0000FF", 4)
    end
end

local function activation()
    send_message("Querying trakt.tv... Hold tight", "FFFFFF", 10)
    local status, output = evoque_python({"--code"})

    if status == 0 then
        send_message("Open https://trakt.tv/activate and type: " .. output .. "\nPress x when done", "FF8800", 50)
        mp.remove_key_binding("auth-trakt")
        mp.add_forced_key_binding("x", "auth-trakt", activated)
    else
        send_message("Damn, there was an error in Python :/ Check the console for more info.", "0000FF", 4)
    end
end

-- Checkin Function
local function checkin()
    local status, output = evoque_python({"--query", mp.get_property('filename')})

    if status == 0 then
        send_message("Scrobbing " .. output, "00FF00", 2)
    elseif status == 14 then
        send_message("You are already scrobbing!", "00FF00", 2)
    else
        send_message("Unable to scrobble " .. output, "0000FF", 2)
    end
end

-- MAIN FUNCTION

local function on_file_start(event)
    local status = evoque_python({"--hello"})

    -- Check status and act accordingly
    if status == 10 then
        -- Plugin is yet to be configured
        send_message("[trakt-mpv] Please add your client_id and client_secret to config.json!", "0000FF", 4)
        return
    elseif status == 11 then
        -- Plugin has to authenticate
        send_message("[trakt-mpv] Press X to authenticate with Trakt.tv", "FF8800", 4)
        mp.add_forced_key_binding("x", "auth-trakt", activation)
    elseif status == 0 then
        -- Plugin is setup, start the checkin
        checkin()
    end
end

mp.register_event("file-loaded", on_file_start)