# Mostrar los discos disponibles
Write-Host "Discos disponibles:"
Get-Disk | ForEach-Object {
    Write-Host "Número de Disco: $($_.Number) - Tamaño: $([math]::Round($_.Size / 1GB, 2)) GB - Estado: $($_.OperationalStatus)"
}

# Introducir número del disco
$diskNumber = [int](Read-Host "Introduce el número del disco a limpiar: ")

# Obtener información del disco elegido
try {
    $disk = Get-Disk -Number $diskNumber -ErrorAction Stop
} catch {
    Write-Host "El número de disco ingresado no es válido. Abortando..."
    exit
}

# Devolver tamaño en GB
$sizeGB = [math]::Round($disk.Size / 1GB, 2)
Write-Host "El disco seleccionado tiene un tamaño de $sizeGB GB."

# Confirmar
$confirmation = Read-Host "¿Desea limpiar el disco y realizar la creación de particiones de 1GB? (Escriba 'y' para confirmar)"
if ($confirmation -ne "y") {
    Write-Host "Cancelado."
    exit
}

# Crear el archivo de comandos para Diskpart
try {
    $tempFile = New-TemporaryFile
    Add-Content -Path $tempFile @"
select disk $diskNumber
clean
convert gpt
"@
    # Ejecutar Diskpart para limpiar el disco
    diskpart /s $tempFile
} finally {
    if (Test-Path $tempFile) { Remove-Item $tempFile }
}

# Crear particiones de 1GB hasta ocupar todo el disco
$restSize = $sizeGB
while ($restSize -ge 1) {
    try {
        $tempFile = New-TemporaryFile
        Add-Content -Path $tempFile @"
select disk $diskNumber
create partition primary size=1024
format fs=ntfs quick
assign
"@
        diskpart /s $tempFile
    } finally {
        if (Test-Path $tempFile) { Remove-Item $tempFile }
    }
    # Restar 1 GB del espacio restante
    $restSize -= 1
}

# Crear una última partición con el espacio restante
if ($restSize -gt 0) {
    try {
        $tempFile = New-TemporaryFile
        Add-Content -Path $tempFile @"
select disk $diskNumber
create partition primary
format fs=ntfs quick
assign
"@
        diskpart /s $tempFile
    } finally {
        if (Test-Path $tempFile) { Remove-Item $tempFile }
    }
}

Write-Host "El disco se ha limpiado, y las particiones de 1GB se han creado con éxito!"