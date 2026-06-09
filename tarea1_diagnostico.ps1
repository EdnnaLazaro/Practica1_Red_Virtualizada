Write-Host "===================================="
Write-Host " DIAGNOSTICO DEL SISTEMA"
Write-Host "===================================="

Write-Host ""
Write-Host "Nombre del equipo:"
hostname

Write-Host ""
Write-Host "Direccion IP:"
(Get-NetIPAddress -AddressFamily IPv4).IPAddress

Write-Host ""
Write-Host "Espacio en disco:"
Get-PSDrive -PSProvider FileSystem