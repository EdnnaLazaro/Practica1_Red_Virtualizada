#!/bin/bash

DOMINIO="reprobados.com"
IP_SERVIDOR="10.0.2.15"
ARCHIVO_ZONA="/etc/bind/db.reprobados.com"
ARCHIVO_LOCAL="/etc/bind/named.conf.local"

echo "==============================="
echo " CONFIGURACION DE DNS EN LINUX "
echo "==============================="

echo ""
echo "[1] Verificando privilegios..."
if [ "$EUID" -ne 0 ]; then
    echo "Este script debe ejecutarse con sudo."
    exit 1
fi

echo ""
echo "[2] Verificando si BIND9 esta instalado..."
if dpkg -s bind9 >/dev/null 2>&1; then
    echo "BIND9 ya esta instalado."
else
    echo "BIND9 no esta instalado. Instalando..."
    apt update
    apt install -y bind9 bind9utils bind9-doc dnsutils
fi

echo ""
echo "[3] Verificando servicio bind9..."
systemctl enable bind9 >/dev/null 2>&1
systemctl start bind9

echo ""
echo "[4] Verificando si la zona ya existe..."
if grep -q 'zone "reprobados.com"' "$ARCHIVO_LOCAL"; then
    echo "La zona $DOMINIO ya existe en $ARCHIVO_LOCAL"
else
    echo "Agregando zona $DOMINIO..."
    cat <<EOF >> "$ARCHIVO_LOCAL"

zone "$DOMINIO" {
    type master;
    file "$ARCHIVO_ZONA";
};
EOF
fi

echo ""
echo "[5] Creando archivo de zona..."
cat <<EOF > "$ARCHIVO_ZONA"
\$TTL 604800
@   IN  SOA ns1.reprobados.com. admin.reprobados.com. (
        3
        604800
        86400
        2419200
        604800
)
@       IN  NS      ns1.reprobados.com.
ns1     IN  A       $IP_SERVIDOR
@       IN  A       $IP_SERVIDOR
www     IN  A       $IP_SERVIDOR
EOF

echo ""
echo "[6] Validando configuracion general..."
named-checkconf
if [ $? -eq 0 ]; then
    echo "Configuracion general correcta."
else
    echo "Error en la configuracion general."
    exit 1
fi

echo ""
echo "[7] Validando zona..."
named-checkzone "$DOMINIO" "$ARCHIVO_ZONA"
if [ $? -eq 0 ]; then
    echo "Zona validada correctamente."
else
    echo "Error en la zona DNS."
    exit 1
fi

echo ""
echo "[8] Reiniciando bind9..."
systemctl restart bind9

echo ""
echo "[9] Probando resolucion DNS contra el servidor local..."
nslookup reprobados.com "$IP_SERVIDOR"
nslookup www.reprobados.com "$IP_SERVIDOR"

echo ""
echo "Proceso finalizado correctamente."
