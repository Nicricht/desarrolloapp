$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $root
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Instala Docker Desktop antes de continuar.' }
& docker info --format '{{.ServerVersion}}' | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Docker Engine no responde. Abre Docker Desktop, modo Linux.' }
& docker compose version | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Necesitas Docker Compose v2.' }
$envfile = Join-Path $root '.env'
if (-not (Test-Path -LiteralPath $envfile)) {
  $bytes = New-Object byte[] 24
  $random = [System.Security.Cryptography.RandomNumberGenerator]::Create()
  try { $random.GetBytes($bytes) } finally { $random.Dispose() }
  $password = [BitConverter]::ToString($bytes).Replace('-', '')
  [System.IO.File]::WriteAllText($envfile, "MONGO_USER=segurosbpo`nMONGO_PASS=$password`n", [System.Text.Encoding]::ASCII)
  Write-Host 'Archivo .env local creado con contraseña aleatoria. No se publicará en GitHub.'
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
