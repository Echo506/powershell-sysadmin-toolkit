# PowerShell Sysadmin Toolkit

Coleccion de scripts en PowerShell orientados a soporte tecnico, administracion de sistemas Windows y diagnostico de redes. Complementa el enfoque multiplataforma de mis herramientas de automatizacion, cubriendo entornos Windows tipicos en soporte empresarial.

## Scripts incluidos

### 1. `Network-Diagnostic.ps1`
Diagnostico de conectividad de red: interfaces, gateway, DNS, ping, traceroute y resolucion de nombres. Genera un log con marca de tiempo.

```powershell
.\scripts\Network-Diagnostic.ps1 -TargetHost 8.8.8.8
```

### 2. `System-HealthCheck.ps1`
Reporte de salud del sistema: tiempo activo, uso de CPU y memoria, espacio en disco, procesos con mayor consumo, servicios automaticos detenidos y ultimos eventos de error del sistema.

```powershell
.\scripts\System-HealthCheck.ps1
```

### 3. `Cleanup-TempFiles.ps1`
Limpia archivos temporales del sistema y del usuario con una antiguedad configurable, vacia la papelera de reciclaje y reporta el espacio liberado.

```powershell
.\scripts\Cleanup-TempFiles.ps1 -DaysOld 14
```

## Requisitos

- Windows 10/11 o Windows Server con PowerShell 5.1 o superior (compatible con PowerShell 7+).
- Algunos scripts requieren permisos de Administrador (por ejemplo, limpieza de rutas del sistema).
- Politica de ejecucion que permita scripts locales:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## Instalacion

```powershell
git clone https://github.com/Echo506/powershell-sysadmin-toolkit.git
cd powershell-sysadmin-toolkit
```

## Buenas practicas aplicadas

- Uso de bloques de ayuda (`.SYNOPSIS`, `.DESCRIPTION`, `.EXAMPLE`) para documentacion inline.
- Parametros con valores por defecto para facilitar el uso rapido.
- Manejo de errores con `try/catch` y `-ErrorAction` en operaciones criticas.
- Generacion de logs y reportes legibles para soporte y auditoria.

## Posibles mejoras futuras

- Integracion con el Programador de tareas de Windows para ejecucion automatica.
- Exportacion de resultados a CSV o JSON.
- Envio de reportes por correo electronico.
- Modulo PowerShell empaquetado para reutilizacion sencilla.

## Autor

Wilfrido Perez Romero - Tecnico de soporte en telecomunicaciones y redes, estudiante de ciberseguridad y administracion de sistemas.
