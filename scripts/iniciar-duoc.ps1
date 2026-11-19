param([switch]$ConfigOnly, [string]$AtlasZip = '')

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $root

if (-not $ConfigOnly) {
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw 'Falta Docker Desktop.' }
& docker info --format '{{.ServerVersion}}' | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Docker Engine no responde. Abre Docker Desktop (contenedores Linux).' }
& docker compose version | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Necesitas Docker Compose v2.' }

}

$envfile = Join-Path $root '.env'
$keys = @('ATLAS_ROLES_URI', 'ATLAS_USUARIOS_URI', 'ATLAS_CATALOGOS_URI', 'ATLAS_SINIESTROS_URI')

function Test-AtlasConfiguration([string]$path) {
  if (-not (Test-Path -LiteralPath $path)) { return $false }
  $text = [System.IO.File]::ReadAllText($path)
  foreach ($key in $keys) {
    $pattern = '(?m)^' + [regex]::Escape($key) + '\s*=\s*.*mongodb\+srv://'
    if (-not [regex]::IsMatch($text, $pattern)) { return $false }
  }
  return $true
}

function Read-AtlasFromZip([string]$path) {
  Add-Type -AssemblyName System.IO.Compression -ErrorAction SilentlyContinue
  Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
  $archive = [System.IO.Compression.ZipFile]::OpenRead($path)
  try {
    $result = @{}
    $services = [ordered]@{
      'ATLAS_ROLES_URI' = 'roles-service'
      'ATLAS_USUARIOS_URI' = 'usuarios-service'
      'ATLAS_CATALOGOS_URI' = 'catalogos-service'
      'ATLAS_SINIESTROS_URI' = 'siniestros-service'
    }
    foreach ($key in $services.Keys) {
      $service = $services[$key]
      $entry = @($archive.Entries | Where-Object {
        $_.FullName.Replace('\','/') -like "*/$service/src/main/resources/application.properties"
      })
      if ($entry.Count -ne 1) { throw "El ZIP no contiene exactamente un application.properties para $service." }
      $reader = New-Object System.IO.StreamReader($entry[0].Open())
      try { $content = $reader.ReadToEnd() } finally { $reader.Dispose() }
      $match = [regex]::Match($content, '(?m)^\s*spring\.mongodb\.uri\s*=\s*(mongodb\+srv://[^\r\n]+)\s*$')
      if (-not $match.Success) { throw "No hay conexion original MongoDB Atlas para $service." }
      $uri = $match.Groups[1].Value.Trim()
      if ($uri -notmatch "/segurosbpo_$($service.Split('-')[0])(?:\?|$)") {
        throw "La base de datos Atlas no coincide con el servicio $service."
      }
      if ($uri.Contains("'")) { throw 'La URI contiene un caracter no admitido para el archivo .env.' }
      $result[$key] = $uri
    }
    return $result
  } finally {
    $archive.Dispose()
  }
}

if (-not (Test-AtlasConfiguration $envfile)) {
  $found = $false
  if ($AtlasZip) {
    if (-not (Test-Path -LiteralPath $AtlasZip -PathType Leaf)) { throw 'No existe la ruta del ZIP original.' }
    $values = Read-AtlasFromZip $AtlasZip
    $found = $true
  }

  $folders = @($root, (Join-Path $HOME 'Downloads'), (Join-Path $HOME 'Descargas'))
  $candidates = @()
  foreach ($folder in $folders) {
    if (Test-Path -LiteralPath $folder) {
      $candidates += @(Get-ChildItem -LiteralPath $folder -File -Filter 'backend-seguros-bpo-main*.zip' -ErrorAction SilentlyContinue)
    }
  }
  $candidates = @($candidates | Sort-Object LastWriteTime -Descending -Unique)
  if (-not $found) { foreach ($candidate in $candidates) {
    try {
      $values = Read-AtlasFromZip $candidate.FullName
      $found = $true
      break
    } catch {
      # Seguir buscando un ZIP original valido.
    }
  }
  }
  if (-not $found) {
    $zipPath = Read-Host 'Ruta completa al ZIP original backend-seguros-bpo-main.zip (con la configuracion Atlas)'
    if (-not (Test-Path -LiteralPath $zipPath -PathType Leaf)) {
      throw 'No encontre el ZIP original. No se modifico Atlas ni se inicio ninguna BD local.'
    }
    $values = Read-AtlasFromZip $zipPath
  }
  if (Test-Path -LiteralPath $envfile) {
    $backup = Join-Path $root ('.env.backup-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
    Copy-Item -LiteralPath $envfile -Destination $backup -ErrorAction Stop
  }
  $lines = @('# Configuracion privada Atlas original; NO SUBIR A GITHUB')
  foreach ($key in $keys) { $lines += ($key + "='" + $values[$key] + "'") }
  [System.IO.File]::WriteAllText($envfile, ($lines -join "`n") + "`n", [System.Text.Encoding]::UTF8)
  Write-Host 'Configuracion Atlas original importada al .env privado. No se han cambiado contrasenas ni bases de datos.'
}

if ($ConfigOnly) { return }

& docker compose config --quiet
if ($LASTEXITCODE -ne 0) { throw 'Error de configuracion de Docker Compose.' }
& docker compose up --build -d --wait --wait-timeout 420 --remove-orphans
if ($LASTEXITCODE -ne 0) {
  & docker compose ps
  & docker compose logs --tail=65
  throw 'No se pudo completar el arranque. Revisa la conexion Atlas y los permisos de red del equipo.'
}
& docker compose ps
Write-Host 'Backend iniciado con Atlas original. Comprueba los endpoints con scripts/probar-duoc.ps1.'
