#!/bin/bash

DOMINIO="reprobados.com"
IP_SERVIDOR="10.0.2.15"

echo "Verificando si BIND9 está instalado..."

if ! command -v named &> /dev/null
then
    echo "BIND9 no está instalado. Instalando..."
    sudo apt update
    sudo apt install bind9 bind9utils bind9-doc dnsutils -y
else
    echo "BIND9 ya está instalado."
fi

echo "Configurando zona DNS..."

ZONA="/etc/bind/named.conf.local"
ARCHIVO_ZONA="/etc/bind/db.reprobados.com"

if grep -q "$DOMINIO" $ZONA; then
    echo "La zona ya existe."
else
    echo "Agregando zona DNS..."
    sudo bash -c "cat >> $ZONA <<EOF

zone \"$DOMINIO\" {
    type master;
    file \"/etc/bind/db.reprobados.com\";
};
EOF"
fi

echo "Creando archivo de zona..."

sudo bash -c "cat > $ARCHIVO_ZONA <<EOF
\$TTL 604800
@   IN  SOA ns1.reprobados.com. admin.reprobados.com. (
        2
        604800
        86400
        2419200
        604800 )

@       IN  NS      ns1.reprobados.com.

ns1     IN  A       $IP_SERVIDOR
@       IN  A       $IP_SERVIDOR
www     IN  A       $IP_SERVIDOR
EOF"

echo "Validando configuración..."

sudo named-checkconf
sudo named-checkzone $DOMINIO $ARCHIVO_ZONA

echo "Reiniciando BIND9..."

sudo systemctl restart bind9

echo "Probando resolución DNS..."

nslookup reprobados.com
nslookup www.reprobados.com

echo "Configuración finalizada."
