$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $root
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Instala Docker Desktop antes de continuar.' }
& docker info --format '{{.ServerVersion}}' | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Docker Engine no responde. Abre Docker Desktop, modo Linux.' }
& docker compose version | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Necesitas Docker Compose v2.' }
if (-not (Test-Path -LiteralPath (Join-Path $root '.env'))) {
  Write-Host 'Modo de demostracion local: Compose utiliza credenciales de desarrollo predeterminadas.'
  Write-Host 'Para personalizarlas, crea .env antes de iniciar el proyecto.'
}
& docker compose config --quiet
if ($LASTEXITCODE -ne 0) { throw 'compose.yaml o .env no son válidos.' }
& docker compose up --build -d --wait --wait-timeout 420
if ($LASTEXITCODE -ne 0) {
  & docker compose ps
  & docker compose logs --tail=80
  throw 'Falló el arranque. Revisar mensajes de error anteriores.'
}
& docker compose ps
Write-Host 'Los cuatro servicios y MongoDB están iniciados. Ejecuta scripts/probar-duoc.ps1.'
