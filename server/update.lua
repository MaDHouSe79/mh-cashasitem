if GetResourceState("mh-core") ~= 'missing' then 
    exports['mh-core']:SendRequest(GetCurrentResourceName(), LoadResourceFile(GetCurrentResourceName(), "version"))
else
    local function checkVersion(err, github, headers)
        local script = GetCurrentResourceName()
        local insversion, gitversion, cur_inst_version, cur_git_version = '0.0.0', '0.0.0', '0.0.0', '0.0.0'
        local notes = ""
        local installed = LoadResourceFile(script, "version")
        if err == 200 then
            if github ~= nil then

                if string.find(github, "{") and string.find(github, "}") then
                    github = json.decode(github)
                    cur_git_version = github.version
                    gitversion = string.gsub(cur_git_version, '%.', '')
                    if github.message ~= nil then notes = "[Release Notes:^2" .. tostring(github.message) .. "^0]" end
                else
                    cur_git_version = github
                    gitversion = string.gsub(github, "%s+", "")
                end

                if string.find(installed, "{") and string.find(installed, "}") then
                    installed = json.decode(installed)
                    cur_inst_version = installed.version
                    insversion = string.gsub(cur_inst_version,'%.', '')
                else
                    cur_inst_version = installed
                    insversion = string.gsub(installed, "%s+", "")
                end

                cur_inst_version = string.gsub(cur_inst_version, "%s+", "")
                cur_git_version = string.gsub(cur_git_version, "%s+", "")
                if insversion == gitversion then
                    print("^0[^2" .. script:upper() .. "^0] - ^0[^4UPDATE CHECK^0] - [^3Installed^0:^2"..cur_inst_version.."^0] [^3Github^0:^2"..cur_git_version.."^0] [Status:^2Success^0]")
                elseif insversion < gitversion then
                    print("^0[^2" .. script:upper() .. "^0] - ^0[^4UPDATE CHECK^0] - [^3Installed^0:^2"..cur_inst_version.."^0] [^3Github^0:^2"..cur_git_version.."^0] [Status:^1Outdated^0]")
                elseif insversion > gitversion then
                    print("^0[^2" .. script:upper() .. "^0] - ^0[^4UPDATE CHECK^0] - [^3Installed^0:^2"..cur_inst_version.."^0] [^3Github^0:^2"..cur_git_version.."^0] [Status:^1Failed^0]")
                end

            elseif github == nil then
                print("^0[^2" .. script:upper() .. "^0] - ^0[^4UPDATE CHECK^0] - [^3Installed^0:^2" .. cur_inst_version .. "^0] - ^0Unable to connect to ^3Github^0 host. ^0[STATUS:^1OFFLINE^0]")
            end
        elseif err == 404 then
            print("^0[^2" .. script:upper() .. "^0] - ^0[^4UPDATE CHECK^0] - [^3Installed^0:^2" .. cur_inst_version .. "^0] - ^0Unable to connect to ^3Github^0 host. ^0[STATUS:^1OFFLINE^0]")
        end
    end

    AddEventHandler('onResourceStart', function(resource)
        if resource == GetCurrentResourceName() then
            Wait(3000)
            PerformHttpRequest("https://raw.githubusercontent.com/MaDHouSe79/" .. resource .. "/master/version", checkVersion, "GET")
        end
    end)
end
