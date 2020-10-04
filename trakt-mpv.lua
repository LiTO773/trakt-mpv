-- HELPER FUNCTIONS:

-- Calls the Python file
local function evoque_python(flag)
    -- Find the path
    local location

    if os.getenv("HOME") == nil then
        -- If you are using Windows, it will assume you are using mpv.net
        location = os.getenv("APPDATA") .. "/mpv.net/Scripts/trakt-mpv/main.py"
    else
        -- If you are using Linux, it will assume you are using mpv
        location = os.getenv("HOME") .. "/.config/mpv/scripts/trakt-mpv/main.py"
    end

    -- Call the file
    local r = mp.command_native({
        name = "subprocess",
        capture_stdout = true,
        args = { "python", location, flag },
    })

    return r.status, r.stdout
end

-- Sends a message
local function send_message(msg, color, time)
    local ass_start = mp.get_property_osd("osd-ass-cc/0")
    local ass_stop = mp.get_property_osd("osd-ass-cc/1")
    mp.osd_message(ass_start .. "{\\1c&H" .. color .. "&}" .. msg .. ass_stop, time)
end

local function on_file_start(event)
    local status = evoque_python("--hello")

    -- Check status and act accordingly
    if status == 10 then
        -- Plugin is yet to be configured
        send_message("[trakt-mpv] Please add your client_id and client_secret to config.json!", "0000FF", 4)
        return
    elseif status == 11 then
        -- Plugin has to authenticate
        send_message("[trakt-mpv] Press X to authenticate with Trakt.tv", "FF8800", 4)
    elseif status == 0 then
        -- Plugin is setup, start the checkin
        send_message("[trakt-mpv] Hello :)", "00FF00", 2)
    end
end

mp.register_event("file-loaded", on_file_start)