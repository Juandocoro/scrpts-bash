#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
    echo "[-] Error de Permisos: Debe ejecutarse como root (sudo ./setup.sh)"
    exit 1
fi

echo "================================================="
echo "        vpsservice Script BASIC - SETUP          "
echo "================================================="

if [ -d "Vpsservice-Bash-Basic" ] || [ -f "Vpsservice-Bash-Basic" ]; then
    echo "[*] Limpieza automática de rastros..."
    rm -rf Vpsservice-Bash-Basic
fi

echo "[*] Conectando a servidor remoto (Clonando)..."
git clone https://github.com/Juandocoro/Vpsservice-Bash-Basic.git

if [ ! -d "Vpsservice-Bash-Basic" ]; then
    echo "[-] Falla en Clonación. Revise acceso Git."
    exit 1
fi

cd Vpsservice-Bash-Basic || exit 1
chmod +x install.sh main.sh

echo "[*] Enrutando al validador oficial..."
sleep 1

sudo ./install.sh
