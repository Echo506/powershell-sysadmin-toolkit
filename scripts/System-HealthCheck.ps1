<#
.SYNOPSIS
    Genera un reporte de salud del sistema Windows.
.DESCRIPTION
    Recolecta informacion de CPU, memoria, disco, procesos con mayor consumo,
    servicios detenidos criticos y eventos recientes del sistema.
.EXAMPLE
    .\System-HealthCheck.ps1
.NOTES
    Autor: Wilfrido Perez Romero
#>

$computerName = $env:COMPUTERNAME
$date = Get-Date

Write-Output "====================================="
Write-Output " Reporte de salud del sistema"
Write-Output " Host: $computerName"
Write-Output " Fecha: $date"
Write-Output "====================================="

# 1. Tiempo activo del sistema
Write-Output "`n[1] Tiempo activo del sistema:"
$os = Get-CimInstance Win32_OperatingSystem
$uptime = (Get-Date) - $os.LastBootUpTime
Write-Output ("Ultimo arranque: {0} | Tiempo activo: {1} dias, {2} horas" -f $os.LastBootUpTime, $uptime.Days, $uptime.Hours)

# 2. Uso de CPU
Write-Output "`n[2] Top 5 procesos por uso de CPU:"
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, CPU, Id |
    Format-Table -AutoSize | Out-String | Write-Output

# 3. Uso de memoria
Write-Output "`n[3] Uso de memoria RAM:"
$totalMemGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
$freeMemGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
$usedMemGB = [math]::Round($totalMemGB - $freeMemGB, 2)
Write-Output ("Total: {0} GB | Usada: {1} GB | Libre: {2} GB" -f $totalMemGB, $usedMemGB, $freeMemGB)

# 4. Uso de disco
Write-Output "`n[4] Uso de disco por unidad:"
Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
    $sizeGB = [math]::Round($_.Size / 1GB, 2)
    $freeGB = [math]::Round($_.FreeSpace / 1GB, 2)
    $usedPct = [math]::Round((($_.Size - $_.FreeSpace) / $_.Size) * 100, 1)
    Write-Output ("Unidad {0}: {1} GB total | {2} GB libre | {3}% usado" -f $_.DeviceID, $sizeGB, $freeGB, $usedPct)
}

# 5. Top procesos por uso de memoria
Write-Output "`n[5] Top 5 procesos por uso de memoria:"
Get-Process | Sort-Object WS -Descending | Select-Object -First 5 Name, @{Name="MemoriaMB";Expression={[math]::Round($_.WS/1MB,2)}}, Id |
    Format-Table -AutoSize | Out-String | Write-Output

# 6. Servicios detenidos con inicio automatico
Write-Output "`n[6] Servicios con inicio automatico que estan detenidos:"
Get-Service | Where-Object { $_.StartType -eq "Automatic" -and $_.Status -ne "Running" } |
    Select-Object Name, DisplayName, Status | Format-Table -AutoSize | Out-String | Write-Output

# 7. Ultimos eventos de error en el visor de eventos
Write-Output "`n[7] Ultimos 10 eventos de error del sistema:"
try {
    Get-WinEvent -LogName System -MaxEvents 50 -ErrorAction Stop |
        Where-Object { $_.LevelDisplayName -eq "Error" } |
        Select-Object -First 10 TimeCreated, Id, Message |
        Format-Table -AutoSize | Out-String | Write-Output
} catch {
    Write-Output "No se pudieron obtener eventos del sistema: $_"
}

Write-Output "`n====================================="
Write-Output " Reporte finalizado."
Write-Output "====================================="
