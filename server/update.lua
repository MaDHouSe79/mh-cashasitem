local script = GetCurrentResourceName()
local url = "https://raw.githubusercontent.com" .. "/MaDHouSe79/" .. script .. "/master/version"
local version = GetResourceMetadata(script, "version")

CreateThread(function()
    PerformHttpRequest(url, function(err, text, headers)
        if (text ~= nil) then
            version = string.gsub(version, "%s+", "")
            text = string.gsub(text, "%s+", "")
            if version == text then
                print("^0[^4Update Check^0: ^1"..script.."^0] - [Installed Version:^2 "..version.."^0] [Github Version:^2 "..text.."^0] [Status:^2Ok^0] ")
            else
                print("^0[^4Update Check^0: ^1"..script.."^0] - Newer version of "..script.." found [Old:^1 "..version.."^0] [New:^2 "..text.."^0]")      
            end
        else
            print("[^6" .. script .. "^0] Check for script update ^1FAILED^0, unable to find the host.")
        end
    end, "GET", "", "")
end)
