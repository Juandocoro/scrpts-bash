#!/bin/bash

# Este es tu Dropper Inicial (Script Único)
# Su finalidad es limpiar, clonar en limpio, y rebotarte al instalador central.

if [ "$EUID" -ne 0 ]; then 
    echo "[-] Error de Permisos: Debes correrlo como root (comando: sudo ./setup.sh)"
    exit 1
fi

echo "================================================="
echo "   🛡️ INICIANDO GESTOR DE DESPLIEGUE STEALTH 🛡️   "
echo "================================================="

# 1. Comprobar si existe la carpeta con historial viejo
if [ -d "scrpts-bash" ] || [ -f "scrpts-bash" ]; then
    echo "[*] Limpieza automática de rastro..."
    echo "[*] Se detectó una versión antigua. Purgando componentes de tu camino..."
    rm -rf scrpts-bash
fi

# 2. Requerir o verificar clonación
echo "[*] Enganchando al repositorio privado..."
git clone git@github.com:Juandocoro/scrpts-bash.git

# Verificar que git no haya rebotado el comando (pasa si el servidor remoto no tiene SSH access targeteado).
if [ ! -d "scrpts-bash" ]; then
    echo "[-] Falla Crítica en Clonación: Revisa si tu VPS permite descargas desde Git o si el repositorio es estrictamente público vía keys."
    exit 1
fi

echo "[+] Entorno del proyecto inyectado con éxito en la memoria."

# 3. Acceder, conceder derechos universales de lectura al kernel y empalmar
cd scrpts-bash || exit 1
chmod +x install.sh main.sh

echo "[*] Enrutando al validador de seguridad oficial..."
sleep 1

# Pasando la antorcha al instalador
sudo ./install.sh
