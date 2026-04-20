# QBCORE Nights ERS Webhook System

A FiveM server-side resource that sends Discord webhook notifications when players go on or off duty through **night_ers (Emergency Response Simulator)**. Notifications are routed to department-specific Discord channels based on the player's active QBCore job.

Please Note:
> *This resource requires QBCore. It will not work on ESX or standalone servers.*

---

## Dependencies

- [QBCore Framework](https://github.com/qbcore-framework/qb-core)
- [night_ers](https://store.nights-software.com) — must be installed and running
- A Discord server with webhook URLs configured

---

## Installation

1. Download or clone this repository into your resources folder:

```
https://github.com/FiveLAPD/QBCORE-ERSDutyNotification.git
```

2. Add the following to your `server.cfg`, ensuring it starts **after** `night_ers` and `qb-core`:

```
ensure ERSDutyNotification
```

3. Open `config.lua` and configure your department job names, labels, colors, and webhook URLs. See the **Configuration** section below.

4. This resource needs to start **AFTER** Nights_ERS in your server.cfg.  Once you have installed and edited it, you can simple start the resource.

---

## Configuration

All configuration is handled in `config.lua`.

### General Settings

```lua
Config.WebhookURL   = ""        -- Fallback webhook URL used when no department match is found
Config.BotUsername  = ""        -- Name displayed on the Discord bot message
Config.BotAvatarURL = ""        -- Avatar URL for the bot (leave empty for default)
Config.FooterText   = ""        -- Text shown in the embed footer
Config.Debug        = false     -- Set to true to print debug output to the server console
```

---

### Police Departments Setup

Each entry in `Config.PoliceDepartments` maps a **QBCore job name** to a department display config and Discord webhook URL.

The key must exactly match `Player.PlayerData.job.name` from QBCore — this is case-sensitive.

```lua
Config.PoliceDepartments = {
    ["your_qbcorejob_name"] = {
        label     = "Your Department Name",
        emoji     = "🚔",
        color_on  = 3447003,   -- Decimal color code for on duty embed
        color_off = 9807270,   -- Decimal color code for off duty embed
        webhook   = "https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN",
    },
}
```

To find your QBCore job name, check your `qb-core/shared/jobs.lua` file or your database `jobs` table. We use multiple departments in QBCORE, and each department is its own "qbcore job".

To convert a hex color to decimal for Discord embeds, use any hex-to-decimal converter. For example, `#3498DB` (blue) = `3447003`.

---

### Fallback

If a player goes on duty as police but their QBCore job does not match any entry in `Config.PoliceDepartments`, the fallback config is used:

```lua
Config.FallbackPolice = {
    label     = "Police Department",
    emoji     = "🚔",
    color_on  = 3447003,
    color_off = 9807270,
    webhook   = Config.WebhookURL,
}
```

---

### Non-Police Services

Fire, EMS, and tow services are configured separately under `Config.ServiceDisplay`:

```lua
Config.ServiceDisplay = {
    ["fire"] = {
        label     = "Fire Department",
        emoji     = "🚒",
        color_on  = 15158332,
        color_off = 9807270,
        webhook   = "https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN",
    },
    ["ambulance"] = { ... },
    ["tow"]       = { ... },
}
```

The keys `fire`, `ambulance`, and `tow` are fixed — they are the service type strings sent by `night_ers` and should not be changed.

---

### Webhook Routing Options

You are not required to create a separate webhook for each department. All entries can share the same URL if you prefer all notifications in one channel, or you can mix and match per department.

To create a webhook in Discord:
**Channel Settings → Integrations → Webhooks → New Webhook → Copy Webhook URL**

---

## Notes

- The `Time On Duty` field only appears on off duty notifications, showing how long the session lasted.
- If a player disconnects while on duty, their session is cleared automatically. No off duty notification is sent on disconnect.
- If a player's job does not match any configured department and no fallback is hit, the notification will still fire using `Config.FallbackPolice`.
- Set `Config.Debug = true` temporarily to confirm job names are resolving correctly. Disable it in production.

## Here is an example of what the webhook output looks like. You can see the inital "on duty" notification, then the "off duty" notification below it, and the "Time On Duty" Section showing you how many minutes/seconds the player was onduty in ERS. 
<img width="483" height="442" alt="Screenshot 2026-04-20 123407" src="https://github.com/user-attachments/assets/061dcff7-d69e-44c2-a6cf-b4dc0f98d3cc" />
