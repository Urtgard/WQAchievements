# WQA Turbo

WQA Turbo is a performance-focused continuation of **WQAchievements** for
Retail World of Warcraft.

It alerts you when active World Quests are useful for achievements, mounts,
pets, toys, custom goals, currencies, equipment and other configured rewards.

## What makes Turbo different?

WQAchievements can repeatedly perform broad World Quest/reward scans while the
game is still populating reward data. WQA Turbo replaces that path with
progressive, frame-budgeted processing.

**Ready World Quests are shown immediately.** If another relevant WQ is still
waiting for Blizzard reward/link data, that individual WQ appears later when
its data becomes available instead of delaying everything else.

Highlights:

* Incremental, frame-budgeted World Quest scanning
* No repeated global scan because a single reward is pending
* Progressive results while reward information loads in the background
* Cached minimap popup and `/wqat` display
* Open popup updates automatically when new relevant WQs become available
* Indexed mount/pet collection lookups
* Performance diagnostics with `/wqat perf` and `/wqat scan`

## Commands

`/wqat` — show current results instantly
`/wqat refresh` — explicitly refresh/rescan
`/wqat popup` — open the popup
`/wqat perf` — performance diagnostics
`/wqat scan` — scanner status

## Beta

This is the first public beta. Please report missing/incorrect World Quest
results, Lua errors, or performance regressions together with `/wqat perf` and
`/wqat scan` output when possible.

## Credits

WQA Turbo is derived from the Public Domain **WQAchievements** addon by Urtgard
and contributors.
