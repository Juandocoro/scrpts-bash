#!/bin/bash

# Verificar root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Debes ejecutar este script como root (sudo)."
  exit 1
fi

# Verificar si se instaló limpiamente la licencia
if [ ! -f ".license_verified" ]; then
    echo "[-] Error de Licencia: No se detectó ninguna autorización válida."
    echo "    Debes ejecutar ./install.sh primero para validar tu Key."
    exit 1
fi

# El script debe ser llamado desde la carpeta actual
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Cargar Módulos Lógicos
source $DIR/modules/network.sh
source $DIR/modules/users.sh
source $DIR/modules/installers/stunnel_installer.sh

while true; do
    actualizar_info_sistema
    clear
    echo "================================================="
    echo "            ⚡ VPN / TUNNEL MANAGER ⚡           "
    echo "================================================="
    echo "  🔹 IP del Servidor : $PUBLIC_IP"
    echo "  🔹 Puertos Abiertos: $ACTIVE_PORTS"
    echo "================================================="
    echo "  1) Crear nuevo usuario"
    echo "  2) Administrar usuarios existentes"
    echo "  3) Configurar y Montar Stunnel (HTTP Injector)"
    echo "  4) Salir"
    echo "================================================="
    read -p "Elige una opción [1-4]: " option

    case $option in
        1) crear_usuario ;;
        2) administrar_usuarios ;;
        3) instalar_stunnel_service ;;
        4) 
           echo "Saliendo... ¡Hasta luego!"
           sleep 1; clear; exit 0 ;;
        *) 
           echo "Opción no válida."
           sleep 1 ;;
    esac
done
