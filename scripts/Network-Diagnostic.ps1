<#
.SYNOPSIS
    Diagnostico rapido de conectividad de red para soporte tecnico.
.DESCRIPTION
    Verifica interfaces de red, gateway, DNS, conectividad (ping),
    ruta de red (traceroute) y resolucion de nombres hacia un host objetivo.
.PARAMETER TargetHost
    Host o IP a diagnosticar. Por defecto usa 8.8.8.8.
.EXAMPLE
    .\Network-Diagnostic.ps1 -TargetHost 8.8.8.8
.NOTES
    Autor: Wilfrido Perez Romero
#>

param(
    [string]$TargetHost = "8.8.8.8"
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = "network_diagnostic_$timestamp.log"

function Write-Log {
    param([string]$Message)
    Write-Output $Message
    Add-Content -Path $logFile -Value $Message
}

Write-Log "====================================="
Write-Log " Diagnostico de Red"
Write-Log " Fecha: $(Get-Date)"
Write-Log "====================================="

# 1. Interfaces de red
Write-Log "`n[1] Interfaces de red:"
Get-NetIPConfiguration | ForEach-Object {
    Write-Log ("Interfaz: {0} | IPv4: {1}" -f $_.InterfaceAlias, $_.IPv4Address.IPAddress)
}

# 2. Gateway predeterminado
Write-Log "`n[2] Puerta de enlace predeterminada:"
Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue |
    ForEach-Object { Write-Log ("Gateway: {0} via {1}" -f $_.NextHop, $_.InterfaceAlias) }

# 3. Servidores DNS configurados
Write-Log "`n[3] Servidores DNS configurados:"
Get-DnsClientServerAddress -AddressFamily IPv4 | ForEach-Object {
    if ($_.ServerAddresses.Count -gt 0) {
        Write-Log ("Interfaz: {0} | DNS: {1}" -f $_.InterfaceAlias, ($_.ServerAddresses -join ", "))
    }
}

# 4. Prueba de conectividad (ping)
Write-Log "`n[4] Prueba de conectividad (ping a $TargetHost):"
$pingResult = Test-Connection -ComputerName $TargetHost -Count 4 -ErrorAction SilentlyContinue
if ($pingResult) {
    $pingResult | ForEach-Object {
        Write-Log ("Respuesta de {0}: tiempo={1}ms" -f $_.Address, $_.ResponseTime)
    }
    Write-Log "Conectividad OK"
} else {
    Write-Log "ADVERTENCIA: sin respuesta de $TargetHost"
}

# 5. Ruta de red (traceroute)
Write-Log "`n[5] Ruta de red hacia $TargetHost:"
try {
    Test-NetConnection -ComputerName $TargetHost -TraceRoute -ErrorAction Stop |
        Select-Object -ExpandProperty TraceRoute | ForEach-Object { Write-Log $_ }
} catch {
    Write-Log "No se pudo completar el traceroute: $_"
}

# 6. Resolucion DNS
Write-Log "`n[6] Resolucion DNS de $TargetHost:"
try {
    Resolve-DnsName -Name $TargetHost -ErrorAction Stop | ForEach-Object {
        Write-Log ("{0} -> {1}" -f $_.Name, $_.IPAddress)
    }
} catch {
    Write-Log "No se pudo resolver $TargetHost : $_"
}

Write-Log "`n====================================="
Write-Log " Diagnostico completado."
Write-Log " Log guardado en: $logFile"
Write-Log "====================================="
