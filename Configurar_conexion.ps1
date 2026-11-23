[CmdletBinding()]
param(
    [string]$Servidor = 'localhost',
    [ValidateRange(1,65535)][int]$Puerto = 3306,
    [string]$Usuario = 'crud_app',
    [string]$BaseDatos = 'laboratorio_crud',
    [switch]$Sobrescribir,
    [switch]$SolicitarContrasena
)
$ErrorActionPreference = 'Stop'
$destinoConexion = Join-Path $PSScriptRoot 'Diseno\App_Data\Conexion.local.config'
if ((Test-Path -LiteralPath $destinoConexion) -and -not $Sobrescribir) {
    throw 'Ya existe Conexion.local.config. Use -Sobrescribir solo si desea reemplazar esa configuracion.'
}
$punteroClave = [IntPtr]::Zero
try {
    $cadena = New-Object System.Data.Common.DbConnectionStringBuilder
    $cadena['Server'] = $Servidor
    $cadena['Port'] = $Puerto
    $cadena['Database'] = $BaseDatos
    $cadena['Uid'] = $Usuario
    if ($SolicitarContrasena) {
        $claveSegura = Read-Host 'Contrasena de MySQL (no se mostrara)' -AsSecureString
        $punteroClave = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($claveSegura)
        $claveTexto = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($punteroClave)
        if (-not [string]::IsNullOrEmpty($claveTexto)) { $cadena['Pwd'] = $claveTexto }
        $claveTexto = $null
    }
    $cadena['CharSet'] = 'utf8mb4'
    $documento = New-Object System.Xml.XmlDocument
    $raiz = $documento.CreateElement('connectionStrings')
    [void]$documento.AppendChild($raiz)
    [void]$raiz.AppendChild($documento.CreateElement('clear'))
    $entrada = $documento.CreateElement('add')
    $entrada.SetAttribute('name', 'conexion')
    $entrada.SetAttribute('providerName', 'MySql.Data.MySqlClient')
    $entrada.SetAttribute('connectionString', $cadena.get_ConnectionString())
    [void]$raiz.AppendChild($entrada)
    $documento.Save($destinoConexion)
    Write-Host 'Conexion local guardada. Este archivo esta excluido de Git y protegido por App_Data.'
} finally {
    if ($punteroClave -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($punteroClave) }
    $cadena = $null
}
