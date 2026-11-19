$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $root
$checks = @(
 @{Nombre='Roles'; Url='http://localhost:8081/api/roles'},
 @{Nombre='Usuarios'; Url='http://localhost:8082/api/usuarios'},
 @{Nombre='Catálogos'; Url='http://localhost:8083/api/companias'},
 @{Nombre='Siniestros'; Url='http://localhost:8084/api/siniestros?sinAsignar=true'}
)
$failures = 0
foreach ($check in $checks) {
 try {
   $r = Invoke-WebRequest -UseBasicParsing -Uri $check.Url -TimeoutSec 15
   if ($r.StatusCode -ne 200) { throw "HTTP $($r.StatusCode)" }
   Write-Host "OK: $($check.Nombre) $($check.Url)" -ForegroundColor Green
 } catch {
   Write-Warning "ERROR: $($check.Nombre): $($_.Exception.Message)"
   $failures++
 }
}
if ($failures -gt 0) {
 & docker compose ps
 & docker compose logs --tail=80
 exit 1
}
Write-Host 'Los cuatro endpoints REST respondieron. La integración Android requiere pruebas aparte.'
