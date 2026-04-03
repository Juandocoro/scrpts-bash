#!/bin/bash

# Este script debe ejecutarse como root
if [ "$EUID" -ne 0 ]; then
  echo "Error: Debes ejecutar este script como root (sudo)."
  exit 1
fi

KEY_SERVER_URL="http://138.197.74.32:8080"
LICENSE_FILE=".license_verified"

clear
echo "================================================="
echo "       SISTEMA DE ASIGNACIÓN E INSTALACIÓN       "
echo "================================================="
echo ""

# Si ya está verificado localmente, omitir reconexión (aceleración opcional)
if [ -f "$LICENSE_FILE" ]; then
    echo "[!] El sistema ya cuenta con una licencia previamente autorizada."
    read -p "¿Deseas re-verificar la licencia y actualizar paquetes base? (s/n): " rev
    if [[ "$rev" != "s" && "$rev" != "S" ]]; then
        echo "Ejecuta ./main.sh para abrir el panel."
        exit 0
    fi
fi

read -p ">> Ingresa tu Key de Licencia de Acceso: " USER_KEY

if [ -z "$USER_KEY" ]; then
    echo "[-] Error: La clave no puede estar vacía."
    exit 1
fi

echo "[*] Conectando con el servidor maestro de licencias..."
# Se verifica mediante CURL extrayendo el status Code
RESPONSE=$(curl -s -w "\n%{http_code}" "$KEY_SERVER_URL/verify?key=$USER_KEY")
HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)

if [ "$HTTP_STATUS" == "200" ]; then
    echo "[+] ¡Licencia Válida! Acceso concedido."
    echo "$USER_KEY" > "$LICENSE_FILE"
else
    echo "[-] Permiso Denegado. Contacte con el administrador."
    exit 1
fi

echo ""
echo "================================================="
echo "             INSTALACIÓN DE PAQUETES             "
echo "================================================="
echo "[*] Instalando herramientas base de forma protegida..."
# Instalamos TODO de forma silenciosa para pre-venir fallos de repositorios incompletos.
apt-get update -yq &> /dev/null
apt-get install -yq curl stunnel4 openssl dropbear net-tools &> /dev/null

# Forzamos detención incondicional de los túneles que se autoinician con el apt-get
# De este modo evitamos "montar puertos en uso", respetando la máquina del cliente hasta que se use el main.sh
systemctl stop stunnel4 &>/dev/null
systemctl disable stunnel4 &>/dev/null

echo "[+] Paquetes bases instalados correctamente en modo inactivo."
echo "================================================="
echo "[+] Autorización completada. Ya puedes iniciar tu menú:"
echo "    Comando: sudo ./main.sh"
echo "================================================="

# Dar permisos a los módulos locales preventivamente
chmod +x main.sh 2>/dev/null
chmod +x modules/*.sh 2>/dev/null
chmod +x modules/installers/*.sh 2>/dev/null
