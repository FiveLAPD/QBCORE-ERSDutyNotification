local QBCore = exports["qb-core"]:GetCoreObject()

local DutyStartTimes = {}

local function FormatDuration(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60

    if h > 0 then
        return ("%dh %dm %ds"):format(h, m, s)
    elseif m > 0 then
        return ("%dm %ds"):format(m, s)
    else
        return ("%ds"):format(s)
    end
end

local function SendDutyWebhook(webhookURL, embedData)
    local payload = json.encode({
        username   = Config.BotUsername,
        avatar_url = Config.BotAvatarURL ~= "" and Config.BotAvatarURL or nil,
        embeds     = { embedData },
    })

    PerformHttpRequest(webhookURL, function(statusCode, responseText, headers)
        if Config.Debug then
            print(("[ERS-DutyWebhook] HTTP %s | %s"):format(statusCode, responseText or "none"))
        end
    end, "POST", payload, { ["Content-Type"] = "application/json" })
end

local function GetPlayerDisplayName(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if Player then
        local c = Player.PlayerData.charinfo
        if c and c.firstname and c.lastname then
            return c.firstname .. " " .. c.lastname
        end
    end
    return GetPlayerName(src) or ("Player #%d"):format(src)
end

local function ResolveServiceConfig(src, serviceType)
    if serviceType == "police" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local jobName = Player.PlayerData.job.name
            local dept = Config.PoliceDepartments[jobName]
            if dept then
                if Config.Debug then
                    print(("[ERS-DutyWebhook] Job '%s' -> %s"):format(jobName, dept.label))
                end
                return dept
            end
            if Config.Debug then
                print(("[ERS-DutyWebhook] No match for job '%s', using fallback"):format(jobName))
            end
        end
        return Config.FallbackPolice
    end
    return Config.ServiceDisplay[serviceType] or Config.FallbackPolice
end

AddEventHandler("ErsIntegration::OnToggleShift", function(src, isOnShift, serviceType)
    local service     = ResolveServiceConfig(src, serviceType)
    local playerName  = GetPlayerDisplayName(src)
    local statusLabel = isOnShift and "🟢 On Duty" or "🔴 Off Duty"
    local embedColor  = isOnShift and service.color_on or service.color_off

    local fields = {
        { name = "Player",    value = playerName,   inline = true },
        { name = "Server ID", value = tostring(src), inline = true },
        { name = "Service",   value = service.label, inline = true },
        { name = "Status",    value = statusLabel,   inline = true },
    }

    if isOnShift then
        DutyStartTimes[src] = os.time()
        if Config.Debug then
            print(("[ERS-DutyWebhook] Session started for ID %d"):format(src))
        end
    else
        local startTime = DutyStartTimes[src]
        if startTime then
            local duration = FormatDuration(os.time() - startTime)
            table.insert(fields, { name = "Time On Duty", value = duration, inline = true })
            if Config.Debug then
                print(("[ERS-DutyWebhook] Session for ID %d lasted %s"):format(src, duration))
            end
            DutyStartTimes[src] = nil
        else
            table.insert(fields, { name = "Time On Duty", value = "Unknown", inline = true })
        end
    end

    local embed = {
        title       = ("%s %s — %s"):format(service.emoji, service.label, statusLabel),
        description = ("**%s** has gone **%s** for **%s**."):format(
            playerName,
            isOnShift and "On Duty" or "Off Duty",
            service.label
        ),
        color     = embedColor,
        fields    = fields,
        footer    = { text = ("%s | %s"):format(Config.FooterText, os.date("%d-%m-%Y at %H:%M:%S")) },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
    }

    if Config.Debug then
        print(("[ERS-DutyWebhook] %s (ID: %d) -> %s | %s"):format(
            playerName, src,
            isOnShift and "ON DUTY" or "OFF DUTY",
            service.label
        ))
    end

    SendDutyWebhook(service.webhook, embed)
end)

-- I added this to still stop tracking time when players timeout or forget to go off duty as a clean up. 
AddEventHandler("playerDropped", function()
    local src = source
    if DutyStartTimes[src] then
        if Config.Debug then
            print(("[ERS-DutyWebhook] ID %d dropped while on duty, clearing session"):format(src))
        end
        DutyStartTimes[src] = nil
    end
end)
