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
    echo "=== ARRANQUE AUTOMATICO ==="
    if grep -q "^menu$" /root/.bashrc; then
        echo "Estado: ACTIVADO"
        read -p "¿Desactivar arranque automático? (s/n): " resp
        if [[ "$resp" == "s" || "$resp" == "S" ]]; then
            sed -i '/^menu$/d' /root/.bashrc
            echo "[+] Desactivado."
        fi
    else
        echo "Estado: DESACTIVADO"
        read -p "¿Activar arranque automático? (s/n): " resp
        if [[ "$resp" == "s" || "$resp" == "S" ]]; then
            echo "menu" >> /root/.bashrc
            echo "[+] Activado."
        fi
    fi
    sleep 2
    show_menu
}

function users_menu() {
    while true; do
        clear
        echo "================================================="
        echo "                 MENU USUARIOS                   "
        echo "================================================="
        echo "  1) Crear Usuario"
        echo "  2) Administrar Usuarios"
        echo "  0) Volver"
        echo "================================================="
        read -p "Elige [0-2]: " op
        case $op in
            1) crear_usuario ;;
            2) administrar_usuarios ;;
            0) break ;;
            *) echo "Inválido"; sleep 1 ;;
        esac
    done
}

function update_script() {
    clear
    echo "================================================="
    echo "                  ACTUALIZAR                     "
    echo "================================================="
    echo "[*] Buscando nuevas versiones en GitHub..."
    echo ""
    
    git fetch origin main &>/dev/null
    
    LOCAL=$(git rev-parse --short HEAD 2>/dev/null)
    REMOTE=$(git rev-parse --short FETCH_HEAD 2>/dev/null)
    
    if [ -z "$LOCAL" ]; then LOCAL="Desconocida"; fi
    if [ -z "$REMOTE" ]; then REMOTE="Desconocida"; fi
    
    echo "Versión Instalada : $LOCAL"
    echo "Versión Nube      : $REMOTE"
    echo ""
    
    if [ "$LOCAL" == "$REMOTE" ]; then
        echo "[+] Tienes la última versión instalada."
        read -p "Presiona Enter para volver regresando..."
    else
        echo "[!] Nueva actualización encontrada."
        echo "[*] Descargando código y reparando permisos..."
        git reset --hard FETCH_HEAD &>/dev/null
        chmod -R +x "$DIR" 2>/dev/null
        echo "[+] Orquestador actualizado con éxito. Reiniciando..."
        sleep 2
        exec "$DIR/main.sh"
    fi
}

function sub_menu_installers() {
    while true; do
        refresh_ports
        clear
        echo "================================================="
        echo "            FÁBRICA DE TÚNELES VPN               "
        echo "================================================="
        echo " 1)  Proxy Stunnel $([ -n "$PORT_SSL" ] && echo "[ACTIVO: $PORT_SSL]" || echo "[INACTIVO]")"
        echo " 2)  UDP-Custom (BadVPN) $([ -n "$PORT_UDP" ] && echo "[ACTIVO: $PORT_UDP]" || echo "[INACTIVO]")"
        echo " 3)  Proxy Websocket $([ -n "$PORT_WS" ] && echo "[ACTIVO: $PORT_WS]" || echo "[INACTIVO]")"
        echo " 0)  Retroceder al Menú Principal"
        echo "================================================="
        read -p "Elige una opción [0-3]: " op

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
            0) break ;;
            *) echo "[-] Opción Equivocada."; sleep 1 ;;
        esac
    done
}

function show_menu() {
    clear
    echo "================================================="
    echo "             vpsservice Script BASIC             "
    echo "================================================="
    echo "                 MENU PRINCIPAL                  "
    echo "================================================="
    
    # Mostramos los puertos dinámicamente llamando a network.sh
    show_network_status
    
    echo "================================================="
    echo " 1)  Usuarios (Crear/Modificar)"
    echo " 2)  Instalaciones (SSL/UDP/WS)"
    echo " 3)  Arranque Automático"
    echo " 4)  Actualizar"
    echo " 0)  Salir"
    echo "================================================="
    read -p "Digita una acción del panel [0-4]: " opcion

    case $opcion in
        1) users_menu ;;
        2) sub_menu_installers ;;
        3) toggle_autostart ;;
        4) update_script ;;
        0) clear; echo "Saliendo... (Escribe 'menu' cuando desees volver)"; exit 0 ;;
        *) echo "Valor irreconocible"; sleep 1; show_menu ;;
    esac
}

# Lazo de vida infinito
while true; do
    show_menu
done
