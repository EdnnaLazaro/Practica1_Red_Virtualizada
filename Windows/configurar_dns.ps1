function Validar-IP {
    param([string]$ip)

    return [System.Net.IPAddress]::TryParse(
        $ip,
        [ref]([System.Net.IPAddress]$null)
    )
}

Write-Host "================================="
Write-Host " CONFIGURACION DNS"
Write-Host "================================="

$dominio = Read-Host "Dominio DNS"

$ipServidor = Read-Host "IP del servidor DNS"
while (!(Validar-IP $ipServidor)) {
    $ipServidor = Read-Host "IP invalida. Ingrese nuevamente"
}

$ipDestino = Read-Host "IP destino"
while (!(Validar-IP $ipDestino)) {
    $ipDestino = Read-Host "IP invalida. Ingrese nuevamente"
}

Write-Host ""
Write-Host "Resumen de configuracion:"
Write-Host "Dominio: $dominio"
Write-Host "Servidor DNS: $ipServidor"
Write-Host "Registro A: $ipDestino"
Write-Host ""
Write-Host "Configuracion validada correctamente."