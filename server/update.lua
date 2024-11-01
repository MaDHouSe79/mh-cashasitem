local script = GetCurrentResourceName()
local url = "https://raw.githubusercontent.com/MaDHouSe79/"..script.."/master/version"
local version = GetResourceMetadata(script, "version")

CreateThread(function()
    PerformHttpRequest(url, function(err, text, headers)
        local error = string.gsub(err, "%s+", "")
        if error ~= '200' then
            if (text ~= nil) then
                version = string.gsub(version, "%s+", "")
                text = string.gsub(text, "%s+", "")
                if version == text then
                    print("^2[^4Update Check^0: ^4"..script.."^0] - Current Version: ^2 "..version.."^0] [Github Version:^2 "..text.."^0] [Status:^2Ok^0] ")
                elseif version < text then
                    print("^2[^4Update Check^0: ^4"..script.."^0] - Newer version of "..script.." found [Installed:^1 "..version.."^0] [New:^2 "..text.."^0]")
                elseif version > text then
                    print("^2[^4Update Check^0: ^4"..script.."^0] - You somehow skipped a few versions of "..script.." or the github went offline, if it's still online i advise you to update ( or downgrade? )")
                end
            elseif text == nil then
                print("[^6" .. script .. "^0] Unable to find the version, Error: ".. error)
            end
        elseif error == '200' then
            print("[^6" .. script .. "^0] ^1FAILED^0, we are unable to find the github host.".. error)
        end
    end, "GET", "", "")
end)
