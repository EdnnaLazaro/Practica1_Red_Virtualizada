#!/bin/bash

source ./ssh_functions.sh
source ./sistema_functions.sh
source ./dns_functions.sh
source ./dhcp_functions.sh

while true
do
    echo "===================================="
    echo "      MENU PRINCIPAL DE SERVICIOS"
    echo "===================================="
    echo "1. Instalar y configurar SSH"
    echo "2. Verificar estado de SSH"
    echo "3. Verificar puerto SSH"
    echo "4. Ejecutar diagnóstico del sistema"
    echo "5. Salir"
    echo "===================================="
    read -p "Seleccione una opción: " opcion

    case $opcion in
        1)
            verificar_root
            instalar_ssh
            iniciar_ssh
            habilitar_ssh
            ;;
        2)
            verificar_estado_ssh
            ;;
        3)
            verificar_puerto_ssh
            ;;
        4)
            mostrar_hostname
            mostrar_usuario
            mostrar_ip
            mostrar_disco
            ;;
        5)
            echo "Saliendo del menú..."
            exit 0
            ;;
        *)
            echo "Opción inválida."
            ;;
    esac
done
