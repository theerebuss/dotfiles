#Requires -RunAsAdministrator
# Windows debloat and configuration script
# Run in an elevated PowerShell: powershell -ExecutionPolicy Bypass -File setup_windows.ps1

Write-Host "Starting Windows setup..." -ForegroundColor Cyan

# ============================================================
# Privacy & Search
# ============================================================

Write-Host "Disabling web search in Start Menu..."
$searchPath = "HKCU:\Software\Policies\Microsoft\Windows\Explorer"
if (-not (Test-Path $searchPath)) { New-Item -Path $searchPath -Force | Out-Null }
Set-ItemProperty -Path $searchPath -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord

Write-Host "Disabling Bing search integration..."
$bingSearchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
Set-ItemProperty -Path $bingSearchPath -Name "BingSearchEnabled" -Value 0 -Type DWord

Write-Host "Disabling search highlights (trending searches)..."
Set-ItemProperty -Path $bingSearchPath -Name "SearchboxTaskbarMode" -Value 1 -Type DWord

# ============================================================
# Start Menu & Taskbar
# ============================================================

# Write-Host "Disabling Start Menu recommendations/suggestions..."
# $startPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
# Set-ItemProperty -Path $startPath -Name "Start_IrisRecommendations" -Value 0 -Type DWord

# Write-Host "Disabling recently added apps in Start Menu..."
# Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "HideRecentlyAddedApps" -Value 1 -Type DWord

Write-Host "Hiding taskbar search..."
Set-ItemProperty -Path $bingSearchPath -Name "SearchboxTaskbarMode" -Value 0 -Type DWord

Write-Host "Hiding Task View button..."
Set-ItemProperty -Path $startPath -Name "ShowTaskViewButton" -Value 0 -Type DWord

# Write-Host "Hiding Widgets..."
# $widgetsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
# Set-ItemProperty -Path $widgetsPath -Name "TaskbarDa" -Value 0 -Type DWord

Write-Host "Hiding Copilot button..."
$copilotPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $copilotPath -Name "ShowCopilotButton" -Value 0 -Type DWord

Write-Host "Hiding Chat/Teams button..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarMn" -Value 0 -Type DWord

# ============================================================
# Telemetry & Diagnostics
# ============================================================

Write-Host "Setting telemetry to minimum..."
$telemetryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (-not (Test-Path $telemetryPath)) { New-Item -Path $telemetryPath -Force | Out-Null }
Set-ItemProperty -Path $telemetryPath -Name "AllowTelemetry" -Value 0 -Type DWord

Write-Host "Disabling diagnostic data..."
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "ShowedToastAtLevel" -Value 1 -Type DWord -ErrorAction SilentlyContinue

Write-Host "Disabling feedback requests..."
$siufPath = "HKCU:\Software\Microsoft\Siuf\Rules"
if (-not (Test-Path $siufPath)) { New-Item -Path $siufPath -Force | Out-Null }
Set-ItemProperty -Path $siufPath -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord

Write-Host "Disabling advertising ID..."
$adPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
if (-not (Test-Path $adPath)) { New-Item -Path $adPath -Force | Out-Null }
Set-ItemProperty -Path $adPath -Name "Enabled" -Value 0 -Type DWord

# ============================================================
# Performance
# ============================================================

Write-Host "Disabling Startup Apps delay..."
$startupPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize"
if (-not (Test-Path $startupPath)) { New-Item -Path $startupPath -Force | Out-Null }
Set-ItemProperty -Path $startupPath -Name "StartupDelayInMSec" -Value 0 -Type DWord

Write-Host "Disabling background apps..."
$bgAppsPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
Set-ItemProperty -Path $bgAppsPath -Name "GlobalUserDisabled" -Value 1 -Type DWord

Write-Host "Disabling app launch tracking..."
Set-ItemProperty -Path $startPath -Name "Start_TrackProgs" -Value 0 -Type DWord

# ============================================================
# Bloatware Removal
# ============================================================

Write-Host "Removing bloatware apps..." -ForegroundColor Yellow
$bloatApps = @(
    "Microsoft.BingNews"
    "Microsoft.BingWeather"
    "Microsoft.BingFinance"
    "Microsoft.BingSports"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.People"
    "Microsoft.PowerAutomateDesktop"
    "Microsoft.Todos"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "MicrosoftTeams"
    "Microsoft.549981C3F5F10"  # Cortana
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.WindowsCommunicationsApps"  # Mail & Calendar
    "Microsoft.YourPhone"
)

foreach ($app in $bloatApps) {
    Write-Host "  Removing $app..."
    Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
        Where-Object DisplayName -eq $app |
        Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

# ============================================================
# Disable Unnecessary Services
# ============================================================

Write-Host "Disabling unnecessary services..."
$servicesToDisable = @(
    "DiagTrack"       # Connected User Experiences and Telemetry
    "SysMain"         # Superfetch - can cause high disk usage
    "WSearch"         # Windows Search indexer - heavy on disk
)

foreach ($svc in $servicesToDisable) {
    Write-Host "  Disabling $svc..."
    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
    Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
}

# ============================================================
# Explorer & UI
# ============================================================

Write-Host "Configuring file extensions to always be shown..."
Set-ItemProperty -Path $startPath -Name "HideFileExt" -Value 0 -Type DWord

Write-Host "Setting Explorer to open 'This PC' instead of Quick Access..."
Set-ItemProperty -Path $startPath -Name "LaunchTo" -Value 1 -Type DWord

Write-Host "Disabling snap assist flyout..."
Set-ItemProperty -Path $startPath -Name "SnapAssist" -Value 0 -Type DWord

# ============================================================
# Restart Explorer
# ============================================================

Write-Host "Restarting Explorer to apply changes..."
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Start-Process explorer

Write-Host "`nDone! Some changes may require a reboot to fully take effect." -ForegroundColor Green
