#!/bin/bash

# Este script debe ejecutarse como root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Debes ejecutar este script como root (sudo)."
  exit 1
fi

# ========================================================
# RUTA ABSOLUTA PARA EVITAR BUGS DE EJECUCIÓN EXTERNA
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"
# ========================================================

KEY_SERVER_URL="http://138.197.74.32:8080" # Tu servidor Produccion
LICENSE_FILE="$DIR/.license_verified"

clear
echo "================================================="
echo "       SISTEMA DE ASIGNACIÓN E INSTALACIÓN       "
echo "================================================="
echo ""

# Evitar Bug de Bucle: Si el archivo real ya existe en el la carpeta del proyecto, saltar.
if [ -f "$LICENSE_FILE" ]; then
    echo "[!] Máquina Autenticada Previamente."
    read -p "¿Deseas re-verificar la licencia y forzar instalación? (s/n): " rev
    if [[ "$rev" != "s" && "$rev" != "S" ]]; then
        # Instalamos atajo menú de seguridad por si lo borraron
        cat << EOF > /usr/local/bin/menu
#!/bin/bash
cd "$DIR" && sudo ./main.sh
EOF
        chmod +x /usr/local/bin/menu
        
        echo "Validación conservada. Abriendo orquestador..."
        sleep 1
        ./main.sh
        exit 0
    fi
fi

# Si no existe archivo de licencia, pedir la Llave:
read -p ">> Ingresa tu Key de Licencia de Acceso: " USER_KEY

if [ -z "$USER_KEY" ]; then
    echo "[-] Error: La clave no puede estar vacía."
    exit 1
fi

echo "[*] Conectando con el Servidor Maestro..."
RESPONSE=$(curl -s -w "\n%{http_code}" "$KEY_SERVER_URL/verify?key=$USER_KEY")
HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
MESSAGE=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_STATUS" == "200" ]; then
    echo "[+] ¡Licencia Válida! Acceso concedido a tu Servidor."
    # Escribir usando el PATH ABSOLUTO para que MAIN.SH lo encuentre
    echo "$USER_KEY" > "$LICENSE_FILE"
else
    echo "[-] Permiso Denegado. Clave Rechazada o Agotada."
    echo "Detalle API: $MESSAGE"
    exit 1
fi

echo ""
echo "================================================="
echo "             INSTALACIÓN DE PAQUETES             "
echo "================================================="
echo "[*] Instalando herramientas base de forma protegida (Puede tardar 2 min)..."

# Actualizar repositorios e instalar todas las dependencias troncales (Stunnel, SSL, UDP, Python Socket)
apt-get update -yq &> /dev/null
apt-get install -yq curl stunnel4 openssl dropbear net-tools cmake build-essential python3 python3-pip &> /dev/null

# Forzamos detención incondicional
systemctl stop stunnel4 &>/dev/null
systemctl disable stunnel4 &>/dev/null

echo "[+] Instlación de Dependencias limpia, ningún puerto bloqueado."

# REPARAR PERMISOS CHMOD de TODO
echo "[*] Impartiendo permisos universales..."
chmod -R +x "$DIR/modules/" 2>/dev/null
chmod +x "$DIR/main.sh" 2>/dev/null

# CREAR APODO ATAJO GLOBAL DEFINITIVO:
echo "[*] Construyendo variables del entorno global..."
cat << EOF > /usr/local/bin/menu
#!/bin/bash
cd "$DIR" && sudo ./main.sh
EOF
chmod +x /usr/local/bin/menu

echo "================================================="
echo "[+] Configuración Finalizada Exitosamente."
echo "================================================="
echo "  [IMPORTANTE]: De ahora en adelante, puedes escribir"
echo "  simplemente 'menu' en tu consola para administrar tus VPN"
echo "================================================="

read -p "Presiona Enter para lanzar tu panel ahora mismo..."
menu
