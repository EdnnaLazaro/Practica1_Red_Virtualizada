#!/bin/bash

verificar_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Este script debe ejecutarse con privilegios de administrador."
        exit 1
    fi
}

instalar_ssh() {
    echo "Instalando OpenSSH Server..."
    apt update
    apt install openssh-server -y
}

habilitar_ssh() {
    echo "Habilitando inicio automático del servicio SSH..."
    systemctl enable ssh
}

iniciar_ssh() {
    echo "Iniciando servicio SSH..."
    systemctl start ssh
}

verificar_estado_ssh() {
    systemctl status ssh
}

verificar_puerto_ssh() {
    ss -tulpn | grep :22
}
