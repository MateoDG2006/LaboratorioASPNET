[CmdletBinding()]
param([string]$Proyecto)
$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($Proyecto)) {
    if (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'Diseno\bin\LaboratorioCrud.Web.dll')) { $Proyecto = $PSScriptRoot }
    else { $Proyecto = Join-Path $env:USERPROFILE 'source\repos\LaboratorioCrudAspNet' }
}
$raiz = [IO.Path]::GetFullPath($Proyecto)
$bin = Join-Path $raiz 'Diseno\bin'
$resolver = $null
$conexion = $null
try {
    Write-Host "Proyecto revisado: $raiz"
    $configRuta = Join-Path $raiz 'Diseno\Web.config'
    if (-not (Test-Path -LiteralPath $configRuta)) { throw 'No se encontro Diseno/Web.config. Indique -Proyecto con la carpeta de la solucion que ejecuta en Visual Studio.' }
    $config = New-Object Xml.XmlDocument
    $config.Load($configRuta)
    $seccion = $config.SelectSingleNode('/configuration/connectionStrings')
    if ($null -eq $seccion) { throw 'Web.config no contiene la seccion connectionStrings.' }
    if ($seccion.HasAttribute('configSource')) {
        $ruta = Join-Path (Split-Path $configRuta -Parent) $seccion.GetAttribute('configSource')
        if (-not (Test-Path -LiteralPath $ruta)) { throw "Falta el archivo de conexion: $ruta. Ejecute Configurar_conexion.ps1 con el usuario que utiliza en Workbench." }
        $configConexion = New-Object Xml.XmlDocument
        $configConexion.Load($ruta)
        $seccion = $configConexion.DocumentElement
    }
    $entrada = $seccion.SelectSingleNode('add[@name="conexion"]')
    if ($null -eq $entrada) { throw 'No existe la entrada llamada conexion.' }
    if ($entrada.GetAttribute('providerName') -ne 'MySql.Data.MySqlClient') { throw 'Esta aplicacion usa MySQL. El proveedor debe ser MySql.Data.MySqlClient.' }
    $cadena = $entrada.GetAttribute('connectionString')
    $datos = New-Object System.Data.Common.DbConnectionStringBuilder
    $datos.set_ConnectionString($cadena)
    foreach ($clave in @('Server','Host','Port','Database','Initial Catalog','Uid','User ID','User','Username','Integrated Security')) {
        if ($datos.ContainsKey($clave)) { Write-Host ($clave + ': ' + $datos[$clave]) }
    }
    Write-Host 'La contrasena y la cadena completa no se muestran.'
    foreach ($clave in @('Pwd','Password')) {
        if ($datos.ContainsKey($clave) -and $datos[$clave] -eq 'CONFIGURAR_LOCALMENTE') { throw 'La conexion todavia tiene la contrasena ficticia CONFIGURAR_LOCALMENTE.' }
    }
    $driver = Join-Path $bin 'MySql.Data.dll'
    if (-not (Test-Path -LiteralPath $driver)) { throw 'Falta Diseno/bin/MySql.Data.dll. Restaure NuGet y recompile la solucion en Visual Studio antes de diagnosticar.' }
    $resolver = [ResolveEventHandler] {
        param($sender, $evento)
        $nombre = (New-Object Reflection.AssemblyName($evento.Name)).Name + '.dll'
        $dependencia = Join-Path $bin $nombre
        if (Test-Path -LiteralPath $dependencia) { return [Reflection.Assembly]::LoadFrom($dependencia) }
        return $null
    }
    [AppDomain]::CurrentDomain.add_AssemblyResolve($resolver)
    [void][Reflection.Assembly]::LoadFrom($driver)
    $conexion = New-Object MySql.Data.MySqlClient.MySqlConnection($cadena)
    $conexion.Open()
    Write-Host 'CONEXION: OK'
    $cmd = $conexion.CreateCommand()
    try {
        $cmd.CommandText = 'sp_load'
        $cmd.CommandType = [Data.CommandType]::StoredProcedure
        [void]$cmd.Parameters.AddWithValue('_busqueda', '')
        [void]$cmd.Parameters.AddWithValue('_incluirAnulados', $false)
        $lector = $cmd.ExecuteReader()
        try {
            $registros = 0
            while ($lector.Read()) { $registros++ }
            Write-Host "LISTADO: OK. Usuarios activos: $registros"
        } finally { $lector.Dispose() }
    } finally { $cmd.Dispose() }
    Write-Host 'El acceso a MySQL y el procedimiento de listado funcionan. Si la pagina falla, confirme que Visual Studio esta ejecutando esta misma carpeta.'
} catch {
    $errorActual = $_.Exception
    while ($null -ne $errorActual.InnerException -and $errorActual.GetType().FullName -ne 'MySql.Data.MySqlClient.MySqlException') { $errorActual = $errorActual.InnerException }
    if ($errorActual.GetType().FullName -eq 'MySql.Data.MySqlClient.MySqlException') {
        Write-Host ('ERROR MYSQL ' + $errorActual.Number + ': ' + $errorActual.Message)
        if ($errorActual.Number -eq 1045) { Write-Host 'La base y el usuario son objetos diferentes. crud_app solo existe si se creo expresamente. Use la cuenta de Workbench y su autenticacion real.' }
    } else { Write-Host ('ERROR: ' + $errorActual.Message) }
    exit 1
} finally {
    if ($null -ne $conexion) { $conexion.Dispose() }
    if ($null -ne $resolver) { [AppDomain]::CurrentDomain.remove_AssemblyResolve($resolver) }
}
