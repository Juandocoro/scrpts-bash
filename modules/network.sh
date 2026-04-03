#!/bin/bash

# Este módulo se encarga de extraer la información de estado en la máquina

function extract_port() {
    # Busca una firma especifica en ss o netstat ignorando mayusculas
    local service=$1
    # ss -tlpn arroja: LISTEN 0 128 0.0.0.0:22 0.0.0.0:* users:(("sshd",pid=123,fd=3))
    # Extraemos el numero de puerto
    ss -tlpn | grep -i "$service" | awk '{print $4}' | awk -F':' '{print $NF}' | sort -u | head -n1 2>/dev/null
}

function show_network_status() {
    IP_PUBLICA=$(curl -s ifconfig.me)
    if [ -z "$IP_PUBLICA" ]; then
        IP_PUBLICA="Desconocida (Sin conexión a internet)"
    fi

    # Analizamos la salud de cada servicio
    PORT_SSH=$(extract_port "sshd\|dropbear")
    PORT_SSL=$(extract_port "stunnel")
    PORT_UDP=$(extract_port "badvpn")
    PORT_WS=$(extract_port "python3.*proxy.py")

    # Si python no nos da proxy.py por estar empaquetado, intentemos buscar por socket especifico o puerto normal comun
    if [ -z "$PORT_WS" ]; then
        PORT_WS=$(ss -tlpn | grep "python3" | awk '{print $4}' | awk -F':' '{print $NF}' | sort -u | head -n1 2>/dev/null)
    fi

    echo " 📡 IPv4 Local: $IP_PUBLICA"
    echo ""
    echo "            [ SALUD DE TÚNELES TRAS TRASPASO DIRECTO ]"
    echo "----------------------------------------------------------------"
    
    if [ -n "$PORT_SSH" ]; then
        echo -e " \033[32m[ ON ]\033[0m Conexión Base SSH   -> Operando en puerto: $PORT_SSH"
    else
        echo -e " \033[31m[OFF ]\033[0m Conexión Base SSH   -> ¡Caída o Inactiva!"
    fi

    if [ -n "$PORT_SSL" ]; then
        echo -e " \033[32m[ ON ]\033[0m Proxy SSL (Stunnel)-> Enrutando puerto: $PORT_SSL"
    else
        echo -e " \033[31m[OFF ]\033[0m Proxy SSL (Stunnel)-> Apagado o por Configurar"
    fi

    if [ -n "$PORT_UDP" ]; then
        echo -e " \033[32m[ ON ]\033[0m UDP-Custom Avanzado -> Acelerando puerto: $PORT_UDP"
    else
        echo -e " \033[31m[OFF ]\033[0m UDP-Custom Avanzado -> Apagado o por Configurar"
    fi

    if [ -n "$PORT_WS" ]; then
        echo -e " \033[32m[ ON ]\033[0m Socket TCP (Python) -> Puenteando puerto: $PORT_WS"
    else
        echo -e " \033[31m[OFF ]\033[0m Socket TCP (Python) -> Apagado o por Configurar"
    fi
}
