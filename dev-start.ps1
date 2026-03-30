$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$backendDir = Join-Path $root "digital-twin-ai-backend"
$frontendDir = Join-Path $root "digital-twin-ai-frontend"

if (!(Test-Path $backendDir)) {
  throw "Missing folder: $backendDir"
}

if (!(Test-Path $frontendDir)) {
  throw "Missing folder: $frontendDir"
}

Write-Host "Starting backend in a new PowerShell window..."
Start-Process powershell -ArgumentList @(
  "-NoExit",
  "-Command",
  "Set-Location '$backendDir'; ./mvnw spring-boot:run"
)

Write-Host "Starting frontend in a new PowerShell window..."
Start-Process powershell -ArgumentList @(
  "-NoExit",
  "-Command",
  "Set-Location '$frontendDir'; npm start"
)

Write-Host "Both services launched."
