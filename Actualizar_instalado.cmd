@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Actualizar_instalado.ps1"
if errorlevel 1 (
    echo No se pudo aplicar la correccion.
)
pause
