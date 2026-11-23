[CmdletBinding()]
param(
    [string]$Servidor = 'localhost',
    [ValidateRange(1,65535)][int]$Puerto = 3306,
    [string]$Usuario = 'root',
    [string]$MySqlExe = 'C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe'
)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $MySqlExe)) { throw 'No se encontro mysql.exe. Indique -MySqlExe con su ruta.' }
Push-Location -LiteralPath $PSScriptRoot
try {
    Write-Host 'Creando laboratorio_crud, tabla, procedimientos y cinco usuarios ficticios.'
    Write-Host 'MySQL pedira la clave. No se guarda en el script ni se pasa como argumento.'
    & $MySqlExe "--host=$Servidor" "--port=$Puerto" "--user=$Usuario" '--password' '--default-character-set=utf8mb4' '--execute=source 00_instalar.sql'
    if ($LASTEXITCODE -ne 0) { throw 'MySQL no completo la instalacion. Revise el error anterior antes de continuar.' }
    Write-Host 'Base de datos preparada. Configure ahora la conexion de la aplicacion.'
} finally { Pop-Location }
