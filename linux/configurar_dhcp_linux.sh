#!/bin/bash

validar_ip() {
    local ip=$1
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

echo "====================================="
echo " CONFIGURACION AUTOMATIZADA DHCP "
echo "====================================="

echo ""
echo "Verificando instalacion de isc-dhcp-server..."

if dpkg -l | grep -q isc-dhcp-server; then
    echo "El servicio isc-dhcp-server ya se encuentra instalado."
else
    echo "El servicio no esta instalado. Iniciando instalacion..."
    sudo apt-get update
    sudo apt-get install isc-dhcp-server -y
fi

echo ""
read -p "Nombre descriptivo del ambito DHCP: " scope_name

read -p "Red DHCP, ejemplo 192.168.100.0: " network
while ! validar_ip "$network"; do
    read -p "IP invalida. Ingresa nuevamente la red DHCP: " network
done

read -p "Mascara de subred, ejemplo 255.255.255.0: " netmask
while ! validar_ip "$netmask"; do
    read -p "Mascara invalida. Ingresa nuevamente la mascara: " netmask
done

read -p "Rango inicial, ejemplo 192.168.100.50: " range_start
while ! validar_ip "$range_start"; do
    read -p "IP invalida. Ingresa nuevamente el rango inicial: " range_start
done

read -p "Rango final, ejemplo 192.168.100.150: " range_end
while ! validar_ip "$range_end"; do
    read -p "IP invalida. Ingresa nuevamente el rango final: " range_end
done

read -p "Gateway, ejemplo 192.168.100.1: " gateway
while ! validar_ip "$gateway"; do
    read -p "IP invalida. Ingresa nuevamente el gateway: " gateway
done

read -p "DNS, ejemplo 192.168.100.1: " dns
while ! validar_ip "$dns"; do
    read -p "IP invalida. Ingresa nuevamente el DNS: " dns
done

read -p "Tiempo de concesion en segundos, ejemplo 600: " lease_time

echo ""
echo "Generando configuracion DHCP..."

sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak

sudo bash -c "cat > /etc/dhcp/dhcpd.conf" <<EOF
authoritative;

# Ambito: $scope_name
subnet $network netmask $netmask {
    range $range_start $range_end;
    option routers $gateway;
    option domain-name-servers $dns;
    default-lease-time $lease_time;
    max-lease-time 7200;
}
EOF

echo ""
echo "Validando sintaxis del archivo DHCP..."
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf

echo ""
echo "Reiniciando servicio DHCP..."
sudo systemctl restart isc-dhcp-server

echo ""
echo "Estado del servicio:"
sudo systemctl status isc-dhcp-server --no-pager

echo ""
echo "Concesiones activas:"
sudo cat /var/lib/dhcp/dhcpd.leases
Ejecución
nano configurar_dhcp_linux.sh
chmod +x configurar_dhcp_linux.sh
./configurar_dhcp_linux.sh
