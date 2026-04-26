#!/bin/bash

# Este módulo se encarga de extraer la información de estado en la máquina

function extract_port() {
    # Busca una firma especifica en ss o netstat ignorando mayusculas
    local service=$1
    # ss -tlpn arroja: LISTEN 0 128 0.0.0.0:22 0.0.0.0:* users:(("sshd",pid=123,fd=3))
    # Extraemos el numero de puerto
    ss -tlpn | grep -i "$service" | awk '{print $4}' | awk -F':' '{print $NF}' | sort -u | head -n1 2>/dev/null
}

function refresh_ports() {
    # Analizamos la salud de cada servicio
    PORT_SSH=$(extract_port "sshd\|dropbear")
    PORT_SSL=$(extract_port "stunnel")
    PORT_UDP=$(extract_port "badvpn")
    PORT_WS=$(extract_port "python3.*proxy.py")

    # Si python no nos da proxy.py, busquemos puerto genérico python3
    if [ -z "$PORT_WS" ]; then
        PORT_WS=$(ss -tlpn | grep "python3" | awk '{print $4}' | awk -F':' '{print $NF}' | sort -u | head -n1 2>/dev/null)
    fi

    # === AUTO FIREWALL DRILLER ===
    # Forzamos la apertura de puertos mapeados para rebasar UFW/IPTABLES
    if command -v ufw &>/dev/null; then
        [ -n "$PORT_SSH" ] && ufw allow "$PORT_SSH"/tcp &>/dev/null
        [ -n "$PORT_SSL" ] && ufw allow "$PORT_SSL"/tcp &>/dev/null
        [ -n "$PORT_UDP" ] && ufw allow "$PORT_UDP"/udp &>/dev/null
        [ -n "$PORT_WS"  ] && ufw allow "$PORT_WS"/tcp  &>/dev/null
    fi
}

function show_network_status() {
    IP_PUBLICA=$(curl -s ifconfig.me)
    if [ -z "$IP_PUBLICA" ]; then
        IP_PUBLICA="Null"
    fi

    refresh_ports

    # Calculos de Hardware
    RAM_U=$(free -m | awk '/Mem:/ {print $3}')
    RAM_T=$(free -m | awk '/Mem:/ {print $2}')
    BUFF=$(free -m | awk '/Mem:/ {print $6}')
    DISK_U=$(df -h / | awk 'NR==2 {print $3}')
    DISK_T=$(df -h / | awk 'NR==2 {print $2}')
    CPU_U=$(grep -o "^cpu \+.*" /proc/stat | awk '{print int(100 - ($5 * 100 / ($2+$3+$4+$5+$6+$7+$8)))"%"}')

    echo "IP: $IP_PUBLICA"
    echo ""
    echo "[ ESTADO DE MAQUINA ]"
    echo " RAM: ${RAM_U}MB / ${RAM_T}MB   |   Disco: $DISK_U / $DISK_T"
    echo " Buffer libre: ${BUFF}MB      |   Consumo CPU: $CPU_U"
    echo ""
    echo "[ ESTADO DE PUERTOS ]"
    echo "-------------------------------------------------"
    
    if [ -n "$PORT_SSH" ]; then
        echo -e " \033[32m[ ON ]\033[0m SSH   -> $PORT_SSH"
    fi

    if [ -n "$PORT_SSL" ]; then
        echo -e " \033[32m[ ON ]\033[0m SSL -> $PORT_SSL"
    fi

    if [ -n "$PORT_UDP" ]; then
        echo -e " \033[32m[ ON ]\033[0m UDP-Custom -> $PORT_UDP"
    
    fi

    if [ -n "$PORT_WS" ]; then
        echo -e " \033[32m[ ON ]\033[0m Socket TCP -> $PORT_WS"
    else
       
    fi
}
