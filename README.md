# WQA Turbo

**WQA Turbo** is a performance-focused continuation of **WQAchievements**.

It alerts you when active World Quests are useful for achievements, mounts,
pets, toys, custom tracking, currencies, gear and other configured rewards.

## Why WQA Turbo?

The original WQAchievements reward path can repeatedly rescan every enabled
World Quest map while Blizzard asynchronously populates reward data. On a
large account this can produce noticeable frame-time spikes.

WQA Turbo changes that architecture:

- frame-budgeted incremental World Quest scanning;
- no global rescan because one quest's reward data is pending;
- ready World Quests appear immediately;
- dynamic reward information enriches quietly in the background;
- pending quest/link readiness is handled per World Quest;
- the minimap popup and `/wqat` use cached results instead of starting a scan;
- an open popup updates when additional relevant World Quests become ready;
- mount and pet journals are indexed once per refresh instead of repeatedly
  rescanned for every expansion.

## Commands

- `/wqat` — show current cached results immediately
- `/wqat refresh` — rebuild and rescan
- `/wqat new` — refresh and announce newly discovered tasks
- `/wqat popup` — open the cached popup
- `/wqat perf` — performance diagnostics
- `/wqat scan` — background scanner diagnostics
- `/wqat cache` — collection-cache diagnostics
- `/wqat reset` — reset diagnostic counters

The legacy `/wqa` command is retained as a compatibility alias for now.

## Performance

During development, the original addon produced repeated execution spikes in
the ~200–300 ms range on a heavily progressed character. The Turbo architecture
reduced the tested user-facing peak into the low tens of milliseconds, while
the reward scanner itself ran in small frame-budgeted slices.

Actual timings depend on character state, active World Quests, hardware,
Blizzard API cache state, and other addons.

## Credits

WQA Turbo is derived from WQAchievements by Urtgard and its contributors.
The original project is distributed as Public Domain.

See `CREDITS.md` and `LICENSE.md`.
