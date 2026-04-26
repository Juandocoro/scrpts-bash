#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Error: Ejecutar como root (sudo)."
  exit 1
fi

# Variables de Sistema
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$DIR"

KEY_SERVER_URL="http://138.197.74.32:8080"
LICENSE_FILE="$DIR/.license_verified"

clear
echo "================================================="
echo "      vpsservice Script BASIC - VALIDACION       "
echo "================================================="
echo ""

if [ -f "$LICENSE_FILE" ]; then
    echo "[!] Máquina Autenticada Previamente."
    read -p "¿Forzar instalación? (s/n): " rev
    if [[ "$rev" != "s" && "$rev" != "S" ]]; then
        cat << EOF > /usr/local/bin/menu
#!/bin/bash
cd "$DIR" && sudo ./main.sh
EOF
        chmod +x /usr/local/bin/menu
        
        echo "Cargando menú..."
        sleep 1
        ./main.sh
        exit 0
    fi
fi

read -p ">> Ingresa tu Key de Acceso: " USER_KEY

if [ -z "$USER_KEY" ]; then
    echo "[-] Error: La clave está vacía."
    exit 1
fi

echo "[*] Conectando..."
RESPONSE=$(curl -s -w "\n%{http_code}" "$KEY_SERVER_URL/verify?key=$USER_KEY")
HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
MESSAGE=$(echo "$RESPONSE" | head -n -1)

if [ "$HTTP_STATUS" == "200" ]; then
    echo "[+] Acceso concedido."
    echo "$USER_KEY" > "$LICENSE_FILE"
else
    echo "[-] Permiso Denegado."
    echo "Detalle API: $MESSAGE"
    exit 1
fi

echo ""
echo "================================================="
echo "                  INSTALANDO                     "
echo "================================================="
echo "[*] Instalando dependencias..."

apt-get update -yq &> /dev/null
apt-get install -yq curl stunnel4 openssl dropbear net-tools cmake build-essential python3 python3-pip &> /dev/null

systemctl stop stunnel4 &>/dev/null
systemctl disable stunnel4 &>/dev/null

echo "[*] Aplicando permisos y variables..."
chmod -R +x "$DIR/modules/" 2>/dev/null
chmod +x "$DIR/main.sh" 2>/dev/null

echo "[*] Sembrando demonio centinela (Auto-Killer)..."
if ! crontab -l 2>/dev/null | grep -q "killer.sh"; then
    (crontab -l 2>/dev/null; echo "* * * * * $DIR/modules/killer.sh") | crontab -
fi

cat << EOF > /usr/local/bin/menu
#!/bin/bash
cd "$DIR" && sudo ./main.sh
EOF
chmod +x /usr/local/bin/menu

echo "================================================="
echo "[+] Instalación Completada."
echo "================================================="
echo " Comando rápido activado: menu"
echo "================================================="

read -p "Presiona Enter para lanzar tu panel..."
menu
