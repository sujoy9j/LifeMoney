$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter is not installed or not in PATH. Install Flutter, restart PowerShell, then rerun this script."
}

Write-Host "Flutter detected:" -ForegroundColor Green
flutter --version

if (-not (Test-Path "android") -or -not (Test-Path "ios")) {
    $temp = Join-Path $env:TEMP ("lifemoney_mobile_" + [guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path $temp | Out-Null
    Copy-Item "pubspec.yaml" $temp
    Copy-Item "lib" $temp -Recurse

    flutter create --project-name lifemoney_app --platforms=android,ios .

    Copy-Item (Join-Path $temp "pubspec.yaml") "pubspec.yaml" -Force
    Remove-Item "lib" -Recurse -Force
    Copy-Item (Join-Path $temp "lib") "lib" -Recurse
    Remove-Item $temp -Recurse -Force
}

flutter pub get
Write-Host "" 
Write-Host "LifeMoney mobile project is ready." -ForegroundColor Green
Write-Host "Run against the cloud API with:" -ForegroundColor Cyan
Write-Host 'flutter run --dart-define=API_BASE_URL=https://YOUR-API-DOMAIN' -ForegroundColor Yellow
