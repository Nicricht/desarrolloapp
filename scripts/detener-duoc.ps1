$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $root
& docker compose down --remove-orphans
if ($LASTEXITCODE -ne 0) { throw 'No se pudo detener Docker Compose.' }
Write-Host 'Servicios detenidos. Los datos MongoDB, avatares y evidencias se conservan.'
