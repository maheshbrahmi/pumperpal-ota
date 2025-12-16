# build-release.ps1
# Build and release new Pumperpal firmware

param(
    [Parameter(Mandatory=$true)]
    [string]$Version,
    
    [Parameter(Mandatory=$true)]
    [string]$Changelog,
    
    [Parameter(Mandatory=$false)]
    [string]$Type = "stable"
)

# Color functions for output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }

# Check if no arguments provided (for usage display)
if (-not $Version) {
    Write-Host "Usage: .\build-release.ps1 -Version <version> -Changelog <changelog> [-Type beta]"
    Write-Host "Example: .\build-release.ps1 -Version '2.1.0' -Changelog 'Fixed voltage scaling, added solar optimization'"
    Write-Host "Example: .\build-release.ps1 -Version '2.2.0-beta' -Changelog 'Testing new sensor logic' -Type beta"
    exit 1
}

$IsBeta = $Type -eq "beta"

Write-Success "Building Pumperpal firmware v$Version..."

# Build firmware with PlatformIO
Push-Location ..\..\PumperpalFW\Main\  # Adjust path to your main project
Get-Location
pio run -e huzzah

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed!"
    Pop-Location
    exit 1
}

Write-Success "Build successful!"

# Set target directory
if ($IsBeta) {
    $TargetDir = "..\..\pumperpal-ota\beta"
} else {
    $TargetDir = "..\..\pumperpal-ota"
}

# Copy firmware
Copy-Item ".pio\build\huzzah\firmware.bin" "$TargetDir\firmware.bin" -Force

# Calculate MD5
$MD5 = (Get-FileHash "$TargetDir\firmware.bin" -Algorithm MD5).Hash.ToLower()

# Get file size
$Size = (Get-Item "$TargetDir\firmware.bin").Length

# Get current date
$Date = Get-Date -Format "yyyy-MM-dd"

Write-Warning "Firmware Details:"
Write-Host "  Version: $Version"
Write-Host "  Size: $Size bytes"
Write-Host "  MD5: $MD5"
Write-Host "  Date: $Date"

# Update version.txt (just the version number)
Set-Content -Path "$TargetDir\version.txt" -Value $Version -NoNewline
Write-Success "✓ Updated version.txt"

# Update version.json
if ($IsBeta) {
    $Url = "https://raw.githubusercontent.com/maheshbrahmi/pumperpal-ota/main/beta/firmware.bin"
} else {
    $Url = "https://raw.githubusercontent.com/maheshbrahmi/pumperpal-ota/main/firmware.bin"
}

$VersionJson = @{
    version = $Version
    mandatory = $false
    min_battery_mv = 3700
    changelog = $Changelog
    url = $Url
    size = $Size
    md5 = $MD5
    release_date = $Date
    rollout_percentage = 100
} | ConvertTo-Json -Depth 10

Set-Content -Path "$TargetDir\version.json" -Value $VersionJson
Write-Success "✓ Updated version.json"

Write-Host "PWD"
Get-Location

# Archive current version (if stable)
if (-not $IsBeta) {
    Write-Success "Archiving version $Version..."
    $ArchiveDir = "..\..\pumperpal-ota\archive\v$Version"
    
    # Create directory if it doesn't exist
    if (-not (Test-Path $ArchiveDir)) {
        New-Item -ItemType Directory -Path $ArchiveDir -Force | Out-Null
    }
    
    Copy-Item "$TargetDir\firmware.bin" "$ArchiveDir\" -Force
    Copy-Item "$TargetDir\version.json" "$ArchiveDir\" -Force
    Copy-Item "$TargetDir\version.txt" "$ArchiveDir\" -Force
}

# Git operations
Push-Location ..\..\pumperpal-ota
git add .
git commit -m "Release v$Version`: $Changelog"
git push

Write-Success "✓ Firmware v$Version released successfully!"
Write-Warning "Devices will receive update within 96 hours."

# Optional: Wait and verify (commented out like in original)
# Write-Warning "`nWaiting for GitHub Pages to update..."
# Start-Sleep -Seconds 60
#
# Write-Host "Testing GitHub Pages deployment..."
# $DeployedVersion = (Invoke-WebRequest -Uri "https://maheshbrahmi.github.io/pumperpal-ota/version.txt" -UseBasicParsing).Content
# if ($DeployedVersion -eq $Version) {
#     Write-Success "✓ Version $Version is now live on GitHub Pages!"
# } else {
#     Write-Warning "⚠ GitHub Pages not updated yet. It may take a few more minutes."
# }

Pop-Location