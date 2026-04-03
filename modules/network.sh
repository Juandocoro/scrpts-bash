#!/bin/bash
# Módulo de Red para extraer datos

PUBLIC_IP=""
ACTIVE_PORTS=""

actualizar_info_sistema() {
    # Busca la IP recursivamente
    PUBLIC_IP=$(curl -s ifconfig.me || curl -s icanhazip.com || hostname -I | awk '{print $1}')
    
    # Extrae todos los puertos TCP locales que estén en escucha y sean numéricos
    if command -v ss &>/dev/null; then
        ACTIVE_PORTS=$(ss -tln | grep -v 'Local' | awk '{print $4}' | rev | cut -d: -f1 | rev | grep -E '^[0-9]+$' | sort -nu | tr '\n' ', ' | sed 's/, $//')
    elif command -v netstat &>/dev/null; then
        ACTIVE_PORTS=$(netstat -tln | grep '^tcp' | awk '{print $4}' | rev | cut -d: -f1 | rev | sort -nu | tr '\n' ', ' | sed 's/, $//')
    else
        ACTIVE_PORTS="Desconocido"
    fi
}
