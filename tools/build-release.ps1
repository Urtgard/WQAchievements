param(
    [string]$Source = (Get-Location).Path,
    [string]$Kit = $PSScriptRoot,
    [string]$Output = (Join-Path $PSScriptRoot "dist")
)

$ErrorActionPreference = "Stop"
$Version = "0.1.0-beta"
$PackageName = "WQATurbo"
$Stage = Join-Path $Output $PackageName
$Zip = Join-Path $Output "$PackageName-$Version.zip"

function Fail([string]$Message) {
    throw "WQA Turbo build failed: $Message"
}

$Source = (Resolve-Path $Source).Path
$Kit = (Resolve-Path $Kit).Path

$mainSource = $null
if (Test-Path (Join-Path $Source "WQATurbo.lua")) {
    $mainSource = "WQATurbo.lua"
}
elseif (Test-Path (Join-Path $Source "WQAchievements.lua")) {
    $mainSource = "WQAchievements.lua"
}
else {
    Fail "Neither WQATurbo.lua nor WQAchievements.lua exists in the source checkout"
}

$requiredFiles = @(
    "Achievements.lua",
    "Core.lua",
    "Locales.lua",
    "Options.lua",
    "Tooltip.lua",
    "Utilities.lua",
    "embeds.xml"
)

$requiredDirs = @(
    "Criterias",
    "DB",
    "Items",
    "Rewards",
    "Libs"
)

foreach ($file in $requiredFiles) {
    if (-not (Test-Path (Join-Path $Source $file))) {
        Fail "Missing source file: $file"
    }
}

foreach ($dir in $requiredDirs) {
    if (-not (Test-Path (Join-Path $Source $dir))) {
        Fail "Missing source directory: $dir"
    }
}

$turboFiles = @(
    "CollectionCache.lua",
    "RewardScanner.lua",
    "TurboRuntime.lua",
    "TurboDisplay.lua",
    "TurboCheck.lua",
    "Performance.lua",
    "WQATurbo.toc",
    "README.md",
    "CHANGELOG.md",
    "CREDITS.md",
    "LICENSE.md"
)

foreach ($file in $turboFiles) {
    if (-not (Test-Path (Join-Path $Kit $file))) {
        Fail "Missing release-kit file: $file"
    }
}

if (Test-Path $Stage) {
    Remove-Item -Recurse -Force $Stage
}
New-Item -ItemType Directory -Force -Path $Stage | Out-Null
New-Item -ItemType Directory -Force -Path $Output | Out-Null

foreach ($file in $requiredFiles) {
    Copy-Item (Join-Path $Source $file) (Join-Path $Stage $file)
}
foreach ($dir in $requiredDirs) {
    Copy-Item -Recurse (Join-Path $Source $dir) (Join-Path $Stage $dir)
}

Copy-Item `
    (Join-Path $Source $mainSource) `
    (Join-Path $Stage "WQATurbo.lua")

foreach ($file in $turboFiles) {
    Copy-Item -Force (Join-Path $Kit $file) (Join-Path $Stage $file)
}

# Rename the addon namespace in OUR addon code only. Never modify Libs/.
$addonLuaFiles = @()

foreach ($rootFile in @(
    "Achievements.lua",
    "Core.lua",
    "Locales.lua",
    "Options.lua",
    "Tooltip.lua",
    "Utilities.lua",
    "WQATurbo.lua",
    "CollectionCache.lua",
    "RewardScanner.lua",
    "TurboRuntime.lua",
    "TurboDisplay.lua",
    "TurboCheck.lua",
    "Performance.lua"
)) {
    $addonLuaFiles += Get-Item (Join-Path $Stage $rootFile)
}

foreach ($subdir in @("Criterias", "DB", "Items", "Rewards")) {
    $addonLuaFiles += Get-ChildItem `
        -Path (Join-Path $Stage $subdir) `
        -Recurse `
        -File `
        -Filter "*.lua"
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

foreach ($file in $addonLuaFiles) {
    $text = [System.IO.File]::ReadAllText($file.FullName)
    $text = $text -replace '\bWQAchievements\b', 'WQATurbo'
    $text = $text -replace '\bWQADB\b', 'WQATurboDB'
    [System.IO.File]::WriteAllText($file.FullName, $text, $utf8NoBom)
}

# Validation.
$tocPath = Join-Path $Stage "WQATurbo.toc"
$tocText = [System.IO.File]::ReadAllText($tocPath)

if ($tocText -notmatch '## Title: WQA Turbo') {
    Fail "TOC title validation failed"
}
if ($tocText -notmatch '## Version: 0\.1\.0-beta') {
    Fail "TOC version validation failed"
}
if ($tocText -notmatch '## SavedVariables: WQATurboDB') {
    Fail "TOC SavedVariables validation failed"
}
if ($tocText -match 'X-Curse-Project-ID|X-Wago-ID|X-WoWI-ID') {
    Fail "Old distribution project IDs are present"
}
if (-not (Test-Path (Join-Path $Stage "Libs\AceAddon-3.0"))) {
    Fail "Bundled AceAddon library is missing"
}
if (-not (Test-Path (Join-Path $Stage "Libs\LibQTip-1.0"))) {
    Fail "Bundled LibQTip library is missing"
}

$badNamespace = Select-String `
    -Path ($addonLuaFiles.FullName) `
    -Pattern '\bWQAchievements\b' `
    -AllMatches

if ($badNamespace) {
    Fail "Old WQAchievements Lua namespace remains in release source"
}

$badDb = Select-String `
    -Path ($addonLuaFiles.FullName) `
    -Pattern '\bWQADB\b' `
    -AllMatches

if ($badDb) {
    Fail "Old WQADB SavedVariables name remains in release source"
}

if (Test-Path $Zip) {
    Remove-Item -Force $Zip
}

# Zip with WQATurbo/ as the top-level addon folder.
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipTempRoot = Join-Path $Output "_ziproot"

if (Test-Path $zipTempRoot) {
    Remove-Item -Recurse -Force $zipTempRoot
}

New-Item -ItemType Directory -Force -Path $zipTempRoot | Out-Null
Copy-Item -Recurse $Stage (Join-Path $zipTempRoot $PackageName)

[System.IO.Compression.ZipFile]::CreateFromDirectory(
    $zipTempRoot,
    $Zip,
    [System.IO.Compression.CompressionLevel]::Optimal,
    $false
)

Remove-Item -Recurse -Force $zipTempRoot

Write-Host ""
Write-Host "WQA Turbo release built successfully." -ForegroundColor Green
Write-Host "Addon folder: $Stage"
Write-Host "CurseForge ZIP: $Zip"
Write-Host ""
Write-Host "Validation passed:"
Write-Host "  - independent WQATurbo namespace"
Write-Host "  - independent WQATurboDB SavedVariables"
Write-Host "  - no original distribution IDs"
Write-Host "  - bundled libraries present"
Write-Host "  - top-level ZIP folder is WQATurbo"
