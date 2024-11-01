local script = GetCurrentResourceName()
local url = "https://raw.githubusercontent.com" .. "/MaDHouSe79/" .. script .. "/master/version"
local version = GetResourceMetadata(script, "version")

CreateThread(function()
    PerformHttpRequest(url, function(err, text, headers)
        if (text ~= nil) then
            version = string.gsub(version, "%s+", "")
            text = string.gsub(text, "%s+", "")
            if version == text then
                print("^0[^2" .. script .. "^0] - [^3Update Check^0] - [Installed Version: ^2"..version.."^0] [Github Version:^2 "..text.."^0] [Status:^2Ok^0]")
            elseif version < text then
                print("^0[^2" .. script .. "^0] - [^3Update Check^0] - Newer version found [Installed Version: ^2"..version.."^0] [Github Version:^2 "..text.."^0] [Status:^1Outdated^0]")
            elseif version > text then
                print("^0[^2" .. script .. "^0] - [^3Update Check^0] - You somehow skipped a few versions or the github went offline, if it's still online i advise you to update ( or downgrade? )^0")
            end
        else
            print("^0[^2" .. script .. "^0] - [^1FAILED^0] - ^1Unable to connect to^0 ^3"..url .."^0, somehow the host is ^1offline^0.")
        end
    end, "GET", "", "")
end)
