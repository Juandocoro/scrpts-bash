#!/bin/bash

# Este módulo se encarga de instalar el núcleo "badvpn-udpgw"
# Habilita conexiones nativas de retransmisión de paquetes UDP (Fundamental para Streaming y Videojuegos mediante VPN).

if [ "$EUID" -ne 0 ]; then
  echo "Error: Debes ejecutar este módulo de instalación como root."
  exit 1
fi

clear
echo "================================================="
echo "        INSTALADOR DE UDP-CUSTOM (BADVPN)        "
echo "================================================="
echo "Este componente instalará un retransmisor asíncrono"
echo "para encapsular los paquetes UDP críticos."
echo "================================================="

read -p "¿Deseas instalar (o reinstalar) el componente UDP en tu sistema? (s/n): " auth
if [[ "$auth" != "s" && "$auth" != "S" ]]; then
    exit 0
fi

echo "[*] Preparando el compilador de código (CMake & GCC)..."
apt-get install -y cmake build-essential gcc &>/dev/null

echo "[*] Descargando el código fuente seguro de BadVPN-UDPGW..."
cd /tmp
rm -rf badvpn
git clone https://github.com/ambrop72/badvpn.git &>/dev/null

echo "[*] Construyendo y Compilando el Motor Binario..."
cd badvpn
mkdir build
cd build
cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 &>/dev/null
make install &>/dev/null

if [ ! -f "/usr/local/bin/badvpn-udpgw" ]; then
    echo "[-] Fallo crítico al compilar núcleo UDP."
    sleep 3
    exit 1
fi

echo "[*] Núcleo construido perfectamente y anclado al Sistema."

read -p "¿Qué PUERTO deseas asignarle al UDPGW (Por defecto 7300): " udp_port
if [ -z "$udp_port" ]; then
    udp_port=7300
fi

echo "[*] Creando Demonio y configurando Servicio..."

# Crear un servicio autorrancable de SystemD para que viva oculto permanentemente y soporte caídas
cat << EOF > /etc/systemd/system/badvpn.service
[Unit]
Description=Protocolo Core UDP-Custom BadVPN (Túneles)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root
ExecStart=/usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:$udp_port --max-clients 500 --max-connections-for-client 10 --client-socket-sndbuf 10000 --client-socket-rcvbuf 10000
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable badvpn &>/dev/null
systemctl restart badvpn &>/dev/null

echo ""
echo "================================================="
echo "[+] Protocolo instalado con Éxito."
echo "    Badvpn se encuentra corriendo bajo 127.0.0.1:$udp_port"
echo "================================================="
sleep 2
