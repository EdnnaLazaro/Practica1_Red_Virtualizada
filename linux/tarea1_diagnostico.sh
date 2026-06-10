#!/bin/bash

echo "===================================="
echo " DIAGNOSTICO DEL SISTEMA"
echo "===================================="

echo "Nombre del equipo:"
hostname

echo ""
echo "Direccion IP:"
hostname -I

echo ""
echo "Espacio en disco:"
df -h /

echo ""
echo "Diagnostico completado."
