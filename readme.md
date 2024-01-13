# SleepyTime Release 1 for tes3mp v0.8

Gives a popup when activating a bed while sneaking, allowing you to skip time if enough players choose to do so. Time will skip to evening if it is daytime, or morning if it is nighttime. The precise hours are set in custom/config.lua under `config.nightStartHour` and `config.nightEndHour`, by default 6 AM and 8 PM.

By default, half of all players on the server must be sleeping in order to pass time. This percentage can be changed by changing the value of `scriptConfig.percentPlayersSleeping` in the `sleepyTime.lua`.

# Installation

Place this script in your server/scripts/custom folder, then add the following line to `server/scripts/customScripts.lua`:

`sleepyTime = require("custom/sleepyTime")`

Should work with all beds and bedrolls. Some mods may add beds that do not work with the plugin.

Tested on tes3mp v0.8. Should work with v0.8.1.

Developed by Justin Bostian (@jb5n on github).