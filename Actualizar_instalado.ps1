[CmdletBinding()]
param([string]$Proyecto = (Join-Path $env:USERPROFILE 'source\repos\LaboratorioCrudAspNet'))

$ErrorActionPreference = 'Stop'
$raizProyecto = [IO.Path]::GetFullPath($Proyecto)
if (-not (Test-Path -LiteralPath (Join-Path $raizProyecto 'LaboratorioCrudAspNet.sln'))) {
    throw 'No se encontro LaboratorioCrudAspNet.sln. Indique -Proyecto con la carpeta instalada.'
}
$utf8 = New-Object Text.UTF8Encoding($true, $true)
$utf8SinBom = New-Object Text.UTF8Encoding($false, $true)
$respaldo = Join-Path $raizProyecto ('Respaldos\correccion_' + (Get-Date -Format 'yyyyMMdd_HHmmss_fff'))
[void](New-Item -ItemType Directory -Path $respaldo)

function Guardar-Archivo([string]$Relativo, [string]$Texto) {
    $destino = Join-Path $raizProyecto $Relativo
    $copia = Join-Path $respaldo $Relativo
    if (Test-Path -LiteralPath $destino) {
        [void][IO.Directory]::CreateDirectory((Split-Path $copia -Parent))
        Copy-Item -LiteralPath $destino -Destination $copia
    }
    [IO.File]::WriteAllText($destino, $Texto, $utf8)
}

function Leer-Archivo([string]$Ruta) {
    try { return [IO.File]::ReadAllText($Ruta, $utf8SinBom) }
    catch [Text.DecoderFallbackException] { return [IO.File]::ReadAllText($Ruta, [Text.Encoding]::GetEncoding(1252)) }
}

$archivos = @('Diseno\Site.Master', 'Diseno\Default.aspx', 'Diseno\Pages\Index.aspx', 'Diseno\Pages\Crud.aspx', 'Diseno\Content\site.css')
foreach ($relativo in $archivos) {
    $ruta = Join-Path $raizProyecto $relativo
    if (-not (Test-Path -LiteralPath $ruta)) { continue }
    $texto = Leer-Archivo $ruta
    if ($relativo -eq 'Diseno\Site.Master') {
        $antiguo = '<span aria-hidden="true">' + [char]0x25EB + '</span>'
        $nuevo = '<svg class="nav-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" aria-hidden="true" focusable="false"><rect x="3" y="4" width="18" height="16" rx="2" /><path d="M3 9h18M9 9v11" /></svg>'
        $texto = $texto.Replace($antiguo, $nuevo)
        $texto = $texto.Replace('href="~/Content/site.css"', 'href="~/Content/site.css?v=20261123-2"')
    }
    if ($relativo -eq 'Diseno\Content\site.css' -and -not $texto.Contains('.nav-icon{')) {
        $texto += "`r`n.nav-icon{width:20px;height:20px;flex-shrink:0;fill:none;stroke:currentColor;stroke-width:1.7;stroke-linecap:round;stroke-linejoin:round}`r`n"
    }
    Guardar-Archivo $relativo $texto
}

$configRelativo = 'Diseno\Web.config'
$configRuta = Join-Path $raizProyecto $configRelativo
$config = New-Object Xml.XmlDocument
$config.PreserveWhitespace = $true
$config.Load($configRuta)
$globalizacion = $config.SelectSingleNode('/configuration/system.web/globalization')
if ($null -eq $globalizacion) { throw 'No se encontro la configuracion de globalizacion.' }
foreach ($atributo in @('fileEncoding','requestEncoding','responseEncoding')) { $globalizacion.SetAttribute($atributo, 'utf-8') }
Guardar-Archivo $configRelativo $config.OuterXml

foreach ($relativo in @('Diseno\App_Data\Conexion.ejemplo.config', 'Diseno\App_Data\Conexion.local.config')) {
    $ruta = Join-Path $raizProyecto $relativo
    if (-not (Test-Path -LiteralPath $ruta)) {
        if ($relativo -eq 'Diseno\App_Data\Conexion.local.config') {
            $ejemplo = Join-Path $raizProyecto 'Diseno\App_Data\Conexion.ejemplo.config'
            if (Test-Path -LiteralPath $ejemplo) { Guardar-Archivo $relativo (Leer-Archivo $ejemplo) }
        }
        if (-not (Test-Path -LiteralPath $ruta)) { continue }
    }
    $documento = New-Object Xml.XmlDocument
    $documento.PreserveWhitespace = $true
    $documento.Load($ruta)
    $entrada = $documento.SelectSingleNode('/connectionStrings/add[@name="conexion"]')
    if ($null -eq $entrada) { throw 'No se encontro la conexion con nombre conexion.' }
    $cadena = New-Object System.Data.Common.DbConnectionStringBuilder
    $cadena.set_ConnectionString($entrada.GetAttribute('connectionString'))
    [void]$cadena.Remove('Pwd')
    [void]$cadena.Remove('Password')
    $entrada.SetAttribute('connectionString', $cadena.get_ConnectionString())
    Guardar-Archivo $relativo $documento.OuterXml
}
foreach ($relativo in @('Diseno\Infraestructura\PaginaBase.cs', 'Diagnosticar_conexion.ps1', 'Diagnosticar_conexion.cmd')) {
    $origen = Join-Path $PSScriptRoot $relativo
    $destino = Join-Path $raizProyecto $relativo
    if ((Test-Path -LiteralPath $origen) -and ([IO.Path]::GetFullPath($origen) -ne [IO.Path]::GetFullPath($destino))) {
        Guardar-Archivo $relativo (Leer-Archivo $origen)
    }
}

$configurador = Join-Path $PSScriptRoot 'Configurar_conexion.ps1'
$configuradorDestino = Join-Path $raizProyecto 'Configurar_conexion.ps1'
if ((Test-Path -LiteralPath $configurador) -and ([IO.Path]::GetFullPath($configurador) -ne [IO.Path]::GetFullPath($configuradorDestino))) {
    Guardar-Archivo 'Configurar_conexion.ps1' (Leer-Archivo $configurador)
}
$editorconfig = Join-Path $PSScriptRoot '.editorconfig'
$editorconfigDestino = Join-Path $raizProyecto '.editorconfig'
if ((Test-Path -LiteralPath $editorconfig) -and -not (Test-Path -LiteralPath $editorconfigDestino)) {
    Guardar-Archivo '.editorconfig' (Leer-Archivo $editorconfig)
}
$gitignore = Join-Path $raizProyecto '.gitignore'
if (Test-Path -LiteralPath $gitignore) {
    $contenidoIgnore = Leer-Archivo $gitignore
    if ($contenidoIgnore -notmatch '(?m)^Respaldos/\s*$') { Guardar-Archivo '.gitignore' ($contenidoIgnore + "`r`nRespaldos/`r`n") }
}
Write-Host 'Correccion aplicada: fuentes y lectura UTF-8, icono SVG y conexion sin Pwd.'
Write-Host 'Se conservaron el servidor, la base, el usuario y el proveedor MySQL configurados.'
Write-Host 'Se agrego el diagnostico. Si faltaba la conexion local, se creo desde el ejemplo; revise su usuario.'
Write-Host "Respaldo local: $respaldo"
Write-Host 'Detenga IIS Express, recompile la solucion y abra nuevamente la pagina.'
