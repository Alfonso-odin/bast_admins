# Verifica si se ejecuta como administrador
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "âŒ Este script debe ejecutarse como administrador."
    Pause
    Exit
}

Write-Host "`n💻 Script ejecutando Creado por ODIN."

# 1. Cambiar nombre del usuario local
$currentUser = $env:USERNAME
Write-Host "`nUsuario actual: $currentUser"

$newUsername = Read-Host "1. Nuevo nombre de la cuenta (usuario local)"
if (Get-LocalUser -Name $newUsername -ErrorAction SilentlyContinue) {
    Write-Host "âŒ El usuario '$newUsername' ya existe. Cancelando."
    exit
}

Rename-LocalUser -Name $currentUser -NewName $newUsername

# 2. Cambiar nombre completo del usuario
$fullName = Read-Host "2. Nombre completo para mostrar del usuario"
Set-LocalUser -Name $newUsername -FullName $fullName

# 3. Cambiar descripciÃ³n del usuario
$userDescription = Read-Host "3. DescripciÃ³n del usuario"
Set-LocalUser -Name $newUsername -Description $userDescription

# 4. Establecer contraseÃ±a con validaciÃ³n
$password1 = Read-Host "4. Nueva contraseÃ±a para '$newUsername'" -AsSecureString
$password2 = Read-Host "Confirma la nueva contraseÃ±a" -AsSecureString

$p1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password1))
$p2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password2))

if ($p1 -ne $p2) {
    Write-Host "âŒ Las contraseÃ±as no coinciden. Cancelando."
    exit
}

Set-LocalUser -Name $newUsername -Password $password1

# 5. Cambiar nombre del equipo
$newPCName = Read-Host "5. Nuevo nombre del equipo (mÃ¡x 15 caracteres, letras/nÃºmeros/guiones)"
if ($newPCName.Length -gt 15 -or $newPCName -match '[^a-zA-Z0-9\-]') {
    Write-Host "âŒ Nombre de equipo invÃ¡lido. Cancelando."
    exit
}
Rename-Computer -NewName $newPCName -Force

# 6. Cambiar descripciÃ³n del equipo
$description = Read-Host "6. DescripciÃ³n del equipo"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name srvcomment -Value $description

# 7. Cambiar grupo de trabajo
$workgroup = Read-Host "7. Nuevo grupo de trabajo"
Add-Computer -WorkGroupName $workgroup -Force



# 8. Ejecutar Autologon
$rutasAutologon = @(
    "C:\SW ADMIN\SOFT\Autologon.exe",
    "C:\SW SCN\GENERAL\Autologon.exe"
)

$autologonEjecutado = $false

foreach ($ruta in $rutasAutologon) {
    if (Test-Path $ruta) {
        Start-Process -FilePath $ruta -Wait
        Write-Host "`n🔐 Autologon ejecutado desde: $ruta"
        $autologonEjecutado = $true
        break
    }
}

if (-not $autologonEjecutado) {
    Write-Host "⚠️ No se encontró Autologon en ninguna de las rutas especificadas."
}


# 9. Cambios aplicados
Write-Host "`nâœ… Todos los cambios fueron aplicados correctamente."



# 10. Preguntar si desea reiniciar
$restart = Read-Host "`n¿Deseas reiniciar el sistema ahora? (si/no)"
if ($restart.ToLower() -eq "si") {
    Write-Host "`n🔄 Reiniciando el sistema..."
    Restart-Computer -Force
} else {
    Write-Host "`n⚠️ Reinicio cancelado. Algunos cambios requerirán reinicio para aplicar completamente."
    Pause
}

Pause
