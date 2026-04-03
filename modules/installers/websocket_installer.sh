#!/bin/bash

# Este script emula una respuesta Websocket permitiendo pasar las peticiones TCP sobre
# un puerto y texto HTTP estándar para disfrazar la operadora.

if [ "$EUID" -ne 0 ]; then
  echo "Error: Debes ejecutar este módulo como root."
  exit 1
fi

clear
echo "================================================="
echo "        INSTALADOR DE WEBSOCKET (PROXY TCP)      "
echo "================================================="
echo "Esto colocará un micro-servidor en Python capaz de"
echo "transformar el tráfico TCP de OpenSSH puro bajo"
echo "una careta inofensiva de peticiones web HTTP y WS."
echo "================================================="

read -p "¿Deseas habilitar un Proxy Local WebSocket? (s/n): " auth
if [[ "$auth" != "s" && "$auth" != "S" ]]; then
    exit 0
fi

read -p "¿Qué Puerto Local escucha tu SSH o Dropbear internamente? (Ej: 22): " s_port
if [ -z "$s_port" ]; then
    s_port=22
fi

read -p "¿En qué PUERTO PÚBLICO atenderá Python al mundo? (Ej: 80): " p_port
if [ -z "$p_port" ]; then
    p_port=80
fi

echo "[*] Codificando la inteligencia del Socket Python..."

# Directorio interno donde guardaremos su lógica base
mkdir -p /etc/websocket
cat << 'EOF' > /etc/websocket/proxy.py
#!/usr/bin/python3
import socket, threading, sys, os

# Variables de entorno extraidas del bash
LISTEN_PORT = int(os.environ.get('WS_PORT', 80))
SSH_PORT = int(os.environ.get('SSH_PORT', 22))

def handle_client(client_socket):
    try:
        req = client_socket.recv(8192)
        # Disfrazando la respuesta de aceptacion del protocolo websocket
        res = "HTTP/1.1 101 Switching Protocols\r\n" \
              "Upgrade: websocket\r\n" \
              "Connection: Upgrade\r\n\r\n"
        client_socket.sendall(res.encode('utf-8'))
        
        # Enlazamiento a SSH Interno
        ssh_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        ssh_socket.connect(('127.0.0.1', SSH_PORT))
        
        def forward(src, dst):
            try:
                while True:
                    data = src.recv(4096)
                    if not data: break
                    dst.sendall(data)
            except: pass
            
        threading.Thread(target=forward, args=(client_socket, ssh_socket)).start()
        threading.Thread(target=forward, args=(ssh_socket, client_socket)).start()
    except Exception as e:
        client_socket.close()

def main():
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('0.0.0.0', LISTEN_PORT))
    server.listen(100)
    print(f"[*] Escuchando disfraces Websocket en {LISTEN_PORT} -> Redireccionando a {SSH_PORT}...")
    while True:
        client_socket, addr = server.accept()
        threading.Thread(target=handle_client, args=(client_socket,)).start()

if __name__ == '__main__':
    main()
EOF

chmod +x /etc/websocket/proxy.py

echo "[*] Encapsulando en un Servicio Inteligente Linux..."

cat << EOF > /etc/systemd/system/websocket_proxy.service
[Unit]
Description=Ecosistema Web Socket Proxy Oculto
After=network.target

[Service]
Type=simple
User=root
# Inyectando los datos definidos del bash
Environment=WS_PORT=$p_port
Environment=SSH_PORT=$s_port
ExecStart=/usr/bin/python3 /etc/websocket/proxy.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable websocket_proxy &>/dev/null
systemctl restart websocket_proxy &>/dev/null

echo ""
echo "================================================="
echo "[+] Puente WebSocket Montado de forma Transparente."
echo "    Las peticiones que recibas al puerto de camuflaje ($p_port)"
echo "    serán derivadas en secreto al puerto SSH ($s_port) de tu máquina."
echo "================================================="
sleep 3
