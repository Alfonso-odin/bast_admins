@echo off
set SCRIPT_PATH=C:\usuarios1\cambiar-config-avanzado.ps1

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Este script necesita ejecutarse como administrador.
    pause
    exit /b
)

if not exist "%SCRIPT_PATH%" (
    echo ❌ No se encontró el archivo PowerShell en: %SCRIPT_PATH%
    pause
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"
pause
