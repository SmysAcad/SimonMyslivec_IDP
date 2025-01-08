# Crear un archivo de texto en el directorio del archivo

$scriptPath = Split-Path -Path $MyInvocation.MyCommand.Definition
$filename = "$scriptPath\escrito.txt"
"Este archivo de texto ha sido creado en PowerShell" | Out-File -FilePath $filename
Write-Host "El archivo ha sido creado en: $filename"

# Mostrar el contenido del archivo de texto

Get-Content escrito.txt

# Mostrar un mensaje en la consola

Write-Host "El archivo de texto ha sido creado con éxito!"