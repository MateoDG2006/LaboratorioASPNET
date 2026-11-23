[CmdletBinding()]
param([string]$DirectorioRepos = (Join-Path $env:USERPROFILE 'source\repos'), [switch]$Abrir)
$ErrorActionPreference = 'Stop'
$origenProyecto = [IO.Path]::GetFullPath($PSScriptRoot)
$rutaRepos = [IO.Path]::GetFullPath($DirectorioRepos)
$destinoProyecto = Join-Path $rutaRepos 'LaboratorioCrudAspNet'
if (Test-Path -LiteralPath $destinoProyecto) { throw "La carpeta destino ya existe: $destinoProyecto. No se sobrescribio ningun archivo." }
if (-not (Test-Path -LiteralPath $rutaRepos)) { [void](New-Item -ItemType Directory -Path $rutaRepos) }
[void](New-Item -ItemType Directory -Path $destinoProyecto)
Get-ChildItem -LiteralPath $origenProyecto -Force | Where-Object { $_.Name -notin @('.git','.vs') } | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $destinoProyecto -Recurse -ErrorAction Stop
}
Write-Host "Proyecto instalado en $destinoProyecto"
Write-Host 'Abra README.md para preparar MySQL y la conexion local.'
if ($Abrir) { Start-Process -FilePath (Join-Path $destinoProyecto 'LaboratorioCrudAspNet.sln') -WindowStyle Normal }
