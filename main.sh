#!/bin/bash

# ========================================================
# REPARACIÓN DE RUTAS ABSOLUTAS GLOBALES
# (Esto resuelve el bug de archivos ocultos y comandos desde otras carpetas)
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"
# ========================================================

LICENSE_FILE="$DIR/.license_verified"

if [ ! -f "$LICENSE_FILE" ]; then
    echo "[-] Error de Licenciamiento."
    echo "    No se detectó el archivo validador en: $LICENSE_FILE"
    echo "    Recuerda que debes ejecutar ./setup.sh para vincular tu Máquina Maestra."
    exit 1
fi

# Referencias Modulares
source "$DIR/modules/network.sh"
source "$DIR/modules/users.sh"

function toggle_autostart() {
    clear
    echo "=== AUTO-EJECUCIÓN AL INICIAR SESIÓN ==="
    # Checamos de forma segura si la palabra menu esta en el shell de root
    if grep -q "^menu$" /root/.bashrc; then
        echo "[!] El arranque automático está: ACTIVADO."
        echo "La consola levanta tu panel apenas abres sesión SSH."
        echo ""
        read -p "¿Deseas DESACTIVAR el salto automático? (s/n): " resp
        if [[ "$resp" == "s" || "$resp" == "S" ]]; then
            sed -i '/^menu$/d' /root/.bashrc
            echo "[+] Desactivado Correctamente."
        fi
    else
        echo "[!] El arranque automático está: DESACTIVADO."
        echo ""
        read -p "¿Deseas ACTIVARLO para lanzar tu consola sin esfuerzo? (s/n): " resp
        if [[ "$resp" == "s" || "$resp" == "S" ]]; then
            echo "menu" >> /root/.bashrc
            echo "[+] Activado Correctamente en el núcleo de Bash."
        fi
    fi
    sleep 2
    show_menu
}

function sub_menu_installers() {
    while true; do
        clear
        echo "================================================="
        echo "            🔌 FÁBRICA DE TÚNELES VPN            "
        echo "================================================="
        echo " 1) 🟢 Montar Proxy Stunnel (Túnel SSL sobre SSH)"
        echo " 2) 🟣 Montar Base UDP-Custom (BadVPN-UDPGW)"
        echo " 3) 🟡 Montar Proxy Websocket (TCP por Puerto HTTP)"
        echo " 4) ⬅️ Retroceder al Menú Principal"
        echo "================================================="
        read -p "Elige de la biblioteca de armaduras [1-4]: " op

        case $op in
            1) 
                if [ -x "$DIR/modules/installers/stunnel_installer.sh" ]; then
                    sudo "$DIR/modules/installers/stunnel_installer.sh"
                else
                    echo "[-] Archivo stunnel_installer.sh extraviado o sin permiso +x"
                fi
                sleep 2
                ;;
            2)
                if [ -x "$DIR/modules/installers/udp_installer.sh" ]; then
                    sudo "$DIR/modules/installers/udp_installer.sh"
                else
                    echo "[-] Archivo udp_installer.sh extraviado o sin permiso +x"
                fi
                sleep 2
                ;;
            3)
                if [ -x "$DIR/modules/installers/websocket_installer.sh" ]; then
                    sudo "$DIR/modules/installers/websocket_installer.sh"
                else
                    echo "[-] Archivo websocket_installer.sh extraviado o sin permiso +x"
                fi
                sleep 2
                ;;
            4) break ;;
            *) echo "[-] Opción Equivocada."; sleep 1 ;;
        esac
    done
}

function show_menu() {
    clear
    echo "================================================="
    echo "     🛡️ MÁQUINA VPN SATÉLITE - MENU PRINCIPAL    "
    echo "================================================="
    
    # Mostramos los puertos dinámicamente llamando a network.sh
    show_network_status
    
    echo "================================================="
    echo " 1) 👥 Menú de Usuarios Temporales (Crear/Modificar)"
    echo " 2) 🔌 Orquestador de Túneles (Instalaciones SSL/UDP/WS)"
    echo " 3) ⚙️ Alternar Arranque Automático del Menú"
    echo " 4) ❌ Suspender Panel e ir a Línea de Comandos"
    echo "================================================="
    read -p "Digita una acción del panel [1-4]: " opcion

    case $opcion in
        1) users_menu ;;
        2) sub_menu_installers ;;
        3) toggle_autostart ;;
        4) clear; echo "Saliendo... (Escribe 'menu' cuando desees volver)"; exit 0 ;;
        *) echo "Valor irreconocible"; sleep 1; show_menu ;;
    esac
}

# Lazo de vida infinito
while true; do
    show_menu
done
