param(
    [string]$WowRetail = "C:\Program Files (x86)\World of Warcraft\_retail_"
)

$ErrorActionPreference = "Stop"

$wtf = Join-Path $WowRetail "WTF\Account"

if (-not (Test-Path $wtf)) {
    throw "Could not find WTF Account directory: $wtf"
}

$sourceFiles = Get-ChildItem `
    -Path $wtf `
    -Recurse `
    -File `
    -Filter "WQAchievements.lua" |
    Where-Object { $_.DirectoryName -match '\\SavedVariables$' }

if (-not $sourceFiles) {
    Write-Host "No WQAchievements SavedVariables files found."
    exit 0
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

foreach ($source in $sourceFiles) {
    $destination = Join-Path $source.DirectoryName "WQATurbo.lua"

    if (Test-Path $destination) {
        $backup = "$destination.pre-migration-backup"
        Copy-Item -Force $destination $backup
        Write-Host "Backed up existing WQATurbo settings to:"
        Write-Host "  $backup"
    }

    $text = [System.IO.File]::ReadAllText($source.FullName)
    $text = $text -replace '\bWQADB\b', 'WQATurboDB'

    [System.IO.File]::WriteAllText($destination, $text, $utf8NoBom)

    Write-Host "Migrated:"
    Write-Host "  $($source.FullName)"
    Write-Host "-> $destination"
}

Write-Host ""
Write-Host "Settings migration complete." -ForegroundColor Green
Write-Host "Do this only while World of Warcraft is CLOSED."
