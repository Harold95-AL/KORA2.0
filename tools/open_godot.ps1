param([switch]$Play, [switch]$Campaign, [switch]$Check, [string]$Scene)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$pathFile = Join-Path $projectRoot '.local\godot-path.txt'
$enginePath = $env:GODOT_PATH
if (-not $enginePath -and (Test-Path -LiteralPath $pathFile)) {
    $enginePath = (Get-Content -LiteralPath $pathFile -Raw).Trim()
}
if (-not $enginePath -or -not (Test-Path -LiteralPath $enginePath)) {
    $godotCommand = Get-Command godot, godot4 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($godotCommand) { $enginePath = $godotCommand.Source }
}
if (-not $enginePath -or -not (Test-Path -LiteralPath $enginePath)) {
    throw 'No se encuentra Godot. Importa project.godot desde el editor o define GODOT_PATH con la ruta del ejecutable.'
}
if ($Check) {
    $consolePath = $enginePath -replace '\.exe$', '_console.exe'
    if (Test-Path -LiteralPath $consolePath) { $enginePath = $consolePath }
    & $enginePath --headless --path $projectRoot --editor --import
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $enginePath --headless --path $projectRoot --fixed-fps 60 --script res://tests/smoke_test.gd
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $enginePath --headless --path $projectRoot --fixed-fps 60 --script res://tests/campaign_test.gd
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $enginePath --headless --path $projectRoot --fixed-fps 60 --script res://tests/traversal_test.gd
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $enginePath --headless --path $projectRoot --script res://tests/lab_parity_test.gd
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $enginePath --headless --path $projectRoot --script res://tests/lab_integration_test.gd
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    & $enginePath --headless --path $projectRoot --fixed-fps 60 --script res://tests/challenge_combat_test.gd
    exit $LASTEXITCODE
}
$arguments = @('--path', ('"' + $projectRoot + '"'))
if ($Scene) { $arguments += $Scene }
elseif (-not $Play -and -not $Campaign) { $arguments += '--editor' }
if ($Play) { $arguments += 'res://scenes/lab/reference_lab.tscn' }
# Ventana interactiva solicitada al usar los accesos de este proyecto.
Start-Process -FilePath $enginePath -ArgumentList $arguments -WorkingDirectory $projectRoot
