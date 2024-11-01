local script = GetCurrentResourceName()
local url = "https://raw.githubusercontent.com/MaDHouSe79/"..GetCurrentResourceName()
local version = GetResourceMetadata(GetCurrentResourceName(), "version")

CreateThread(function()
    PerformHttpRequest(url.."/master/version", function(err, text, headers)
        local error = string.gsub(err, "%s+", "")
        if error ~= '200' then
            if (text ~= nil) then
                version = string.gsub(version, "%s+", "")
                text = string.gsub(text, "%s+", "")
                if version == text then
                    print("[^6" .. GetCurrentResourceName() .. "^0] - ^2[^4Update Check^0] - Current Version: ^2 "..version.."^0 [Github Version:^2 "..text.."^0] [Status:^2Ok^0] ")
                elseif version < text then
                    print("[^6" .. GetCurrentResourceName() .. "^0] - ^2[^4Update Check^0] - Newer version of "..GetCurrentResourceName().." found [Installed:^1 "..version.."^0] [New:^2 "..text.."^0]")
                elseif version > text then
                    print("[^6" .. GetCurrentResourceName() .. "^0] - ^2[^4Update Check^0] - You somehow skipped a few versions of "..GetCurrentResourceName().." or the github went offline, if it's still online i advise you to update ( or downgrade? )")
                end
            elseif text == nil then
                print("[^6" .. GetCurrentResourceName() .. "^0] - ^2[^1FAILED^0] - ^1Unable to find the script version...")
            end
        elseif error == '200' then
            print("[^6" .. GetCurrentResourceName() .. "^0] - ^2[^1FAILED^0] - ^1Unable to find or connect to "..url .." host is offline.")
        end
    end, "GET", "", "")
end)
