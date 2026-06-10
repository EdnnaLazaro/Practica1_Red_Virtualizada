#!/bin/bash

echo "====================================="
echo " MONITOREO DEL SERVICIO DHCP "
echo "====================================="

echo ""
echo "Estado del servicio:"
sudo systemctl status isc-dhcp-server --no-pager

echo ""
echo "Validando configuracion DHCP:"
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf

echo ""
echo "Concesiones activas:"
sudo cat /var/lib/dhcp/dhcpd.leases
