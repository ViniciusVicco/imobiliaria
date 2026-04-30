param(
  [string]$Action = ""
)

$ErrorActionPreference = "Stop"

function Invoke-Step {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Title,
    [Parameter(Mandatory = $true)]
    [scriptblock]$Command
  )

  Write-Host ""
  Write-Host "==> $Title" -ForegroundColor Cyan
  & $Command
}

function Invoke-Flutter {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments,
    [string]$Path = "."
  )

  Push-Location $Path
  try {
    & flutter @Arguments
  } finally {
    Pop-Location
  }
}

function Invoke-Dart {
  param(
    [Parameter(Mandatory = $true)]
    [string[]]$Arguments,
    [string]$Path = "."
  )

  Push-Location $Path
  try {
    & dart @Arguments
  } finally {
    Pop-Location
  }
}

function Invoke-PubGetAll {
  Invoke-Step "pub get: app" { Invoke-Flutter -Arguments @("pub", "get") }
  Invoke-Step "pub get: packages/core" { Invoke-Flutter -Arguments @("pub", "get") -Path "packages/core" }
  Invoke-Step "pub get: packages/design_system" { Invoke-Flutter -Arguments @("pub", "get") -Path "packages/design_system" }
}

function Invoke-AnalyzeAll {
  Invoke-Step "analyze: app" { Invoke-Flutter -Arguments @("analyze") }
  Invoke-Step "analyze: packages/core" { Invoke-Dart -Arguments @("analyze") -Path "packages/core" }
  Invoke-Step "analyze: packages/design_system" { Invoke-Flutter -Arguments @("analyze") -Path "packages/design_system" }
}

function Invoke-FormatCheck {
  Invoke-Step "format check" { Invoke-Dart -Arguments @("format", "--output=none", "--set-exit-if-changed", ".") }
}

function Invoke-FixDryRun {
  Invoke-Step "dart fix dry-run" { Invoke-Dart -Arguments @("fix", "--dry-run") }
}

function Invoke-Tests {
  Invoke-Step "test: app" { Invoke-Flutter -Arguments @("test") }
}

function Invoke-Verify {
  Invoke-PubGetAll
  Invoke-FormatCheck
  Invoke-AnalyzeAll
  Invoke-Tests
}

function Invoke-BuildWeb {
  Invoke-Step "build web" { Invoke-Flutter -Arguments @("build", "web") }
}

function Invoke-RunChrome {
  Invoke-Step "run chrome" { Invoke-Flutter -Arguments @("run", "-d", "chrome") }
}

function Invoke-RunWindows {
  Invoke-Step "run windows" { Invoke-Flutter -Arguments @("run", "-d", "windows") }
}

$Actions = [ordered]@{
  "1" = @{ Name = "Run app on Chrome"; Command = { Invoke-RunChrome } }
  "2" = @{ Name = "Run app on Windows"; Command = { Invoke-RunWindows } }
  "3" = @{ Name = "Pub get all packages"; Command = { Invoke-PubGetAll } }
  "4" = @{ Name = "Analyze all packages"; Command = { Invoke-AnalyzeAll } }
  "5" = @{ Name = "Format check"; Command = { Invoke-FormatCheck } }
  "6" = @{ Name = "Tests"; Command = { Invoke-Tests } }
  "7" = @{ Name = "Build web"; Command = { Invoke-BuildWeb } }
  "8" = @{ Name = "Verify all"; Command = { Invoke-Verify } }
  "9" = @{ Name = "Dart fix dry-run"; Command = { Invoke-FixDryRun } }
}

$Aliases = @{
  "run-chrome" = "1"
  "run-windows" = "2"
  "pub-get-all" = "3"
  "analyze-all" = "4"
  "format-check" = "5"
  "test" = "6"
  "build-web" = "7"
  "verify" = "8"
  "fix-dry-run" = "9"
}

if ([string]::IsNullOrWhiteSpace($Action)) {
  Write-Host ""
  Write-Host "VS Code task launcher" -ForegroundColor Green
  Write-Host "Select an action:"
  foreach ($Key in $Actions.Keys) {
    Write-Host "  $Key. $($Actions[$Key].Name)"
  }
  Write-Host ""
  $Action = Read-Host "Action"
}

if ($Aliases.ContainsKey($Action)) {
  $Action = $Aliases[$Action]
}

if (-not $Actions.Contains($Action)) {
  Write-Host "Unknown action: $Action" -ForegroundColor Red
  exit 1
}

& $Actions[$Action].Command
