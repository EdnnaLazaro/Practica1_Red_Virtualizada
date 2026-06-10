function Validar-IP {
    param(
        [string]$ip
    )

    return [System.Net.IPAddress]::TryParse($ip, [ref]([System.Net.IPAddress]$null))
}

Write-Host "======================================"
Write-Host " CONFIGURACION DHCP CON VBOXMANAGE"
Write-Host "======================================"
Write-Host ""

$VBoxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

if (!(Test-Path $VBoxManage)) {
    Write-Host "No se encontro VBoxManage en la ruta configurada."
    Write-Host "Verifica la instalacion de VirtualBox."
    exit
}

$network = Read-Host "Nombre de la red interna"
$scopeName = Read-Host "Nombre descriptivo del ambito DHCP"

$serverIp = Read-Host "IP del servidor DHCP, ejemplo 192.168.100.1"
while (!(Validar-IP $serverIp)) {
    $serverIp = Read-Host "IP invalida. Ingresa nuevamente la IP del servidor"
}

$lowerIp = Read-Host "Rango inicial, ejemplo 192.168.100.50"
while (!(Validar-IP $lowerIp)) {
    $lowerIp = Read-Host "IP invalida. Ingresa nuevamente el rango inicial"
}

$upperIp = Read-Host "Rango final, ejemplo 192.168.100.150"
while (!(Validar-IP $upperIp)) {
    $upperIp = Read-Host "IP invalida. Ingresa nuevamente el rango final"
}

$netmask = Read-Host "Mascara de red, ejemplo 255.255.255.0"
while (!(Validar-IP $netmask)) {
    $netmask = Read-Host "Mascara invalida. Ingresa nuevamente la mascara"
}

$leaseTime = Read-Host "Tiempo de concesion en segundos, ejemplo 600"

Write-Host ""
Write-Host "Verificando servidores DHCP existentes..."
$dhcpServers = & $VBoxManage list dhcpservers

if ($dhcpServers -match $network) {
    Write-Host "El servidor DHCP para la red $network ya existe."
    Write-Host "Aplicando modificacion de configuracion..."

    & $VBoxManage dhcpserver modify `
        --network=$network `
        --server-ip=$serverIp `
        --lower-ip=$lowerIp `
        --upper-ip=$upperIp `
        --netmask=$netmask `
        --enable
} else {
    Write-Host "El servidor DHCP no existe. Creando nueva configuracion..."

    & $VBoxManage dhcpserver add `
        --network=$network `
        --server-ip=$serverIp `
        --lower-ip=$lowerIp `
        --upper-ip=$upperIp `
        --netmask=$netmask `
        --enable
}

Write-Host ""
Write-Host "Configuracion aplicada para el ambito: $scopeName"
Write-Host ""
Write-Host "Estado actual de los servidores DHCP:"
& $VBoxManage list dhcpservers

