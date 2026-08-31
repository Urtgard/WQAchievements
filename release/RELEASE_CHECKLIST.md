# WQA Turbo 0.1.0-beta release checklist

## Build
- [ ] Current WQAchievements development checkout contains the tested Turbo files
- [ ] `Libs/` exists in the checkout
- [ ] Run `build-release.ps1`
- [ ] Builder reports all validation checks passed

## Local clean-install test
- [ ] Exit WoW completely
- [ ] Disable/remove the development `WQAchievements` addon folder
- [ ] Extract `dist/WQATurbo-0.1.0-beta.zip` into `_retail_/Interface/AddOns`
- [ ] Verify resulting path is `AddOns/WQATurbo/WQATurbo.toc`
- [ ] Launch WoW
- [ ] No Lua errors on login
- [ ] Addon appears as `WQA Turbo`
- [ ] `/wqat` works
- [ ] Minimap icon works
- [ ] Options page opens
- [ ] Initial ready WQs appear quickly
- [ ] A later reward-only WQ appears progressively if its data was initially pending

## Correctness
- [ ] Compare active results with the final development build
- [ ] Achievement WQs match
- [ ] Mount/pet/toy/custom tracking matches
- [ ] Dynamic reward WQs eventually appear
- [ ] `/wqat refresh` works
- [ ] Popup updates while open

## Performance
- [ ] `/wqat perf` shows no suspicious long functions
- [ ] `/wqat scan` finishes without timeouts in normal conditions
- [ ] Blizzard addon profiler shows 0 executions >50ms in the normal test
- [ ] No periodic frame-drop behavior returns

## Settings migration (optional for your account)
- [ ] WoW is closed
- [ ] Run `migrate-settings.ps1`
- [ ] Launch WQA Turbo and verify previous options/profile

## GitHub
- [ ] Commit the release source
- [ ] Rename repository to `WQATurbo` (recommended)
- [ ] Push `release/wqa-turbo-0.1.0` branch
- [ ] Tag `v0.1.0-beta`

## CurseForge
- [ ] Create project `WQA Turbo`
- [ ] Select World of Warcraft -> Addons
- [ ] Categories: Achievements; Quests & Leveling
- [ ] License: Public Domain
- [ ] Paste `CURSEFORGE_DESCRIPTION.md`
- [ ] Upload `WQATurbo-0.1.0-beta.zip`
- [ ] Release type: Beta
- [ ] Game version: current Retail / 12.1
- [ ] Do not reuse WQAchievements' old project ID
