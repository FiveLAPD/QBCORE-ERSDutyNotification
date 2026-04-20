Config = {}

Config.WebhookURL   = "Create a discord webhook and then place the link here"
Config.BotUsername  = "Duty Tracker"
Config.BotAvatarURL = "Set if needed (not required)"
Config.FooterText   = "ERS Duty System"
Config.Debug        = false

-- We are using QBCORE jobs here to separate each on/off duty activity. This works because ERS is using qbcore permissions.
Config.PoliceDepartments = {
    ["lapd"] = {
        label     = "Los Angeles Police Department",
        emoji     = "🚔",
        color_on  = 3447003,
        color_off = 9807270,
        webhook   = "Create a discord webhook and then place the link here",
    },
    ["lasd"] = {
        label     = "Los Angeles County Sheriff's Office",
        emoji     = "🚔",
        color_on  = 15105570,
        color_off = 9807270,
        webhook   = "Create a discord webhook and then place the link here",
    },
    ["chp"] = {
        label     = "California Highway Patrol",
        emoji     = "🚔",
        color_on  = 10181046,
        color_off = 9807270,
        webhook   = "Create a discord webhook and then place the link here",
    },
    ["vcso"] = {
        label     = "Ventura County Sheriff's Department",
        emoji     = "🚔",
        color_on  = 1752220,
        color_off = 9807270,
        webhook   = "Create a discord webhook and then place the link here",
    },
}

-- This is used incase one of the players doesn't have a proper job and they still use ERS to go on duty. its a fallback.
Config.FallbackPolice = {
    label     = "Police Department",
    emoji     = "🚔",
    color_on  = 3447003,
    color_off = 9807270,
    webhook   = Config.WebhookURL,
}

-- Add/adjust your support services here. (Dispatch, medics, tow, fire, etc).
Config.ServiceDisplay = {
    ["fire"] = {
        label     = "Fire Department",
        emoji     = "🚒",
        color_on  = 15158332,
        color_off = 9807270,
        webhook   = "Create a discord webhook and then place the link here",
    },
    ["ambulance"] = {
        label     = "EMS / Ambulance",
        emoji     = "🚑",
        color_on  = 3066993,
        color_off = 9807270,
        webhook   = "Create a discord webhook and then place the link here",
    },
    ["tow"] = {
        label     = "Tow / Road Service",
        emoji     = "🚚",
        color_on  = 15844367,
        color_off = 9807270,
        webhook   = Config.WebhookURL,
    },
}
