# upload-latest.ps1
param(
    [string]$Port = "",
    [switch]$Beta,
    [switch]$Monitor
)

# Color functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }

# Set firmware path
if ($Beta) {
    $FirmwarePath = "..\..\pumperpal-ota\beta\firmware.bin"
    $VersionPath = "..\..\pumperpal-ota\beta\version.txt"
} else {
    $FirmwarePath = "..\..\pumperpal-ota\firmware.bin"
    $VersionPath = "..\..\pumperpal-ota\version.txt"
}

# Check firmware exists
if (-not (Test-Path $FirmwarePath)) {
    Write-Error "Firmware not found at: $FirmwarePath"
    exit 1
}

# Get version
$Version = "Unknown"
if (Test-Path $VersionPath) {
    $Version = Get-Content $VersionPath -Raw
}
Write-Success "Firmware version: $Version"

# Get available ports
$ports = [System.IO.Ports.SerialPort]::getportnames()
Write-Warning "Available COM ports:"
foreach ($p in $ports) {
    Write-Host "  - $p"
}

# Auto-detect or use specified port
if (-not $Port) {
    if ($ports.Count -eq 1) {
        $Port = $ports[0]
        Write-Success "Using port: $Port"
    } else {
        Write-Error "Please specify port with -Port COM3"
        exit 1
    }
}

Write-Success "Uploading firmware to $Port..."

# Build the esptool command
$cmd = "python -m esptool --port $Port --baud 921600 --chip esp8266 write_flash --flash_mode dio --flash_size 4MB 0x00000 "
$cmd += '"' + $FirmwarePath + '"'

# Execute upload
Invoke-Expression $cmd

# Check result
if ($LASTEXITCODE -eq 0) {
    Write-Success "Upload successful!"
    
    if ($Monitor) {
        Write-Success "Opening serial monitor..."
        Start-Sleep -Seconds 2
        pio device monitor -p $Port -b 115200
    }
} else {
    Write-Error "Upload failed!"
    Write-Host "Try holding BOOT button while uploading"
}