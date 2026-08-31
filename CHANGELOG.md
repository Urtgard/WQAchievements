# Changelog

## 0.1.0-beta

Initial WQA Turbo beta.

### Performance architecture
- Replaced repeated synchronous full-map reward scans with a frame-budgeted
  incremental scanner.
- Missing reward data no longer restarts the entire global scan.
- Dynamic item/currency/profession rewards load in the background.
- Changed task readiness from global to per-World-Quest, so one unresolved WQ
  no longer delays other ready results.
- Added progressive publication of newly available relevant WQs.
- Reduced repeated Mount Journal and Pet Journal scans with indexed snapshots.

### User interface
- Minimap popup reads the current cache and does not trigger a full refresh.
- Open popup refreshes when background enrichment discovers new useful WQs.
- `/wqat` shows current results immediately.
- Added explicit `/wqat refresh`.
- Added `/wqat perf`, `/wqat scan`, and `/wqat cache` diagnostics.

### Project cleanup
- Rebranded as WQA Turbo.
- Uses independent `WQATurbo` addon namespace.
- Uses independent `WQATurboDB` SavedVariables database.
- Removed original CurseForge/Wago/WoWI project IDs.
- Updated Retail interface metadata for 12.1.
