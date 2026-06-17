param(
  [string]$GoogleMapsApiKey = ""
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot + "\.."

Write-Host "Kotabi Web ビルドを開始..." -ForegroundColor Cyan

$defineArgs = @()
if ($GoogleMapsApiKey) {
  $defineArgs += "--dart-define=GOOGLE_MAPS_API_KEY=$GoogleMapsApiKey"
}

flutter pub get
flutter build web --release @defineArgs

if ($GoogleMapsApiKey) {
  $indexPath = Join-Path "build\web" "index.html"
  (Get-Content $indexPath -Raw) -replace 'YOUR_API_KEY', $GoogleMapsApiKey | Set-Content $indexPath -NoNewline
  Write-Host "index.html に API キーを反映しました" -ForegroundColor Green
}

Write-Host ""
Write-Host "ビルド完了: build\web" -ForegroundColor Green
Write-Host ""
Write-Host "オンライン公開:" -ForegroundColor Yellow
Write-Host "  1. GitHub に push → GitHub Pages（.github/workflows/deploy-web.yml）"
Write-Host "  2. firebase deploy --only hosting（Firebase Hosting）"
Write-Host "  詳細: DEPLOY.md を参照"
