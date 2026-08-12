<#
.SYNOPSIS
    Limpia archivos temporales y logs antiguos en un sistema Windows.
.DESCRIPTION
    Elimina archivos de las carpetas temporales del sistema y del usuario,
    vacia la papelera de reciclaje y genera un reporte de espacio liberado.
.PARAMETER DaysOld
    Antiguedad minima en dias de los archivos a eliminar. Por defecto 7.
.EXAMPLE
    .\Cleanup-TempFiles.ps1 -DaysOld 14
.NOTES
    Autor: Wilfrido Perez Romero
    Ejecutar como Administrador para limpiar rutas del sistema.
#>

param(
    [int]$DaysOld = 7
)

$cutoffDate = (Get-Date).AddDays(-$DaysOld)
$pathsToClean = @(
    "$env:TEMP",
    "$env:WINDIR\Temp",
    "$env:LOCALAPPDATA\Temp"
)

Write-Output "====================================="
Write-Output " Limpieza de archivos temporales"
Write-Output " Fecha: $(Get-Date)"
Write-Output " Eliminando archivos con mas de $DaysOld dias"
Write-Output "====================================="

$totalFreedBytes = 0
$totalDeletedFiles = 0

foreach ($path in $pathsToClean) {
    if (Test-Path $path) {
        Write-Output "`nProcesando: $path"
        $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt $cutoffDate }

        foreach ($file in $files) {
            try {
                $totalFreedBytes += $file.Length
                Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                $totalDeletedFiles++
            } catch {
                Write-Output "No se pudo eliminar: $($file.FullName)"
            }
        }
        Write-Output "Archivos eliminados en esta ruta: $($files.Count)"
    } else {
        Write-Output "`nRuta no encontrada, se omite: $path"
    }
}

# Vaciar la papelera de reciclaje
Write-Output "`nVaciando la papelera de reciclaje..."
try {
    Clear-RecycleBin -Force -ErrorAction Stop
    Write-Output "Papelera de reciclaje vaciada correctamente."
} catch {
    Write-Output "No se pudo vaciar la papelera de reciclaje: $_"
}

$totalFreedMB = [math]::Round($totalFreedBytes / 1MB, 2)

Write-Output "`n====================================="
Write-Output " Limpieza completada."
Write-Output " Archivos eliminados: $totalDeletedFiles"
Write-Output " Espacio liberado: $totalFreedMB MB"
Write-Output "====================================="
