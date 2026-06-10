#!/bin/bash

validar_ip() {
    local ip=$1
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        return 0
    else
        return 1
    fi
}

echo "=========================================="
echo " CONFIGURACION AUTOMATIZADA DNS - BIND9"
echo "=========================================="
echo ""

echo "Verificando instalacion de BIND9..."

if dpkg -l | grep -q "^ii  bind9 "; then
    echo "BIND9 ya se encuentra instalado."
else
    echo "BIND9 no esta instalado. Instalando paquetes..."
    sudo apt-get update
    sudo apt-get install bind9 bind9utils bind9-doc -y
fi

echo ""
read -p "Dominio DNS, ejemplo reprobados.com: " dominio

read -p "IP del servidor DNS, ejemplo 192.168.100.52: " ip_servidor
while ! validar_ip "$ip_servidor"; do
    read -p "IP invalida. Ingresa nuevamente la IP del servidor DNS: " ip_servidor
done

read -p "IP destino de los registros, ejemplo 192.168.100.51: " ip_destino
while ! validar_ip "$ip_destino"; do
    read -p "IP invalida. Ingresa nuevamente la IP destino: " ip_destino
done

read -p "Nombre del servidor DNS, ejemplo ns1: " ns_name

echo ""
echo "Verificando que el servidor tenga configurada la IP $ip_servidor..."

if ip a | grep -q "$ip_servidor"; then
    echo "La IP $ip_servidor se encuentra configurada en el servidor."
else
    echo "ADVERTENCIA: La IP $ip_servidor no aparece configurada actualmente."
    echo "Verifica la configuracion de red antes de continuar."
fi

echo ""
echo "Respaldando configuracion actual..."
sudo cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bak

echo ""
echo "Configurando zona DNS..."

if grep -q "zone \"$dominio\"" /etc/bind/named.conf.local; then
    echo "La zona $dominio ya existe. No se agregara duplicada."
else
    sudo bash -c "cat >> /etc/bind/named.conf.local" <<EOF

zone "$dominio" {
    type master;
    file "/var/cache/bind/db.$dominio";
};
EOF
    echo "Zona $dominio agregada correctamente."
fi

echo ""
echo "Generando archivo de zona /var/cache/bind/db.$dominio..."

sudo bash -c "cat > /var/cache/bind/db.$dominio" <<EOF
\$TTL 604800
@   IN  SOA $ns_name.$dominio. admin.$dominio. (
        2026061001
        604800
        86400
        2419200
        604800 )

@       IN  NS      $ns_name.$dominio.
$ns_name IN  A       $ip_servidor

@       IN  A       $ip_destino
www     IN  A       $ip_destino
EOF

echo ""
echo "Validando configuracion general de BIND9..."
sudo named-checkconf

if [ $? -eq 0 ]; then
    echo "Configuracion general correcta."
else
    echo "Error en named-checkconf. Revisa la configuracion."
    exit 1
fi

echo ""
echo "Validando zona $dominio..."
sudo named-checkzone "$dominio" "/var/cache/bind/db.$dominio"

if [ $? -eq 0 ]; then
    echo "Zona $dominio validada correctamente."
else
    echo "Error en la zona DNS. Revisa el archivo de zona."
    exit 1
fi

echo ""
echo "Reiniciando servicio BIND9..."
sudo systemctl restart bind9

echo ""
echo "Estado del servicio BIND9:"
sudo systemctl status bind9 --no-pager

echo ""
echo "Prueba local de resolucion DNS:"
nslookup "$dominio" 127.0.0.1
nslookup "www.$dominio" 127.0.0.1

echo ""
echo "Proceso finalizado."
