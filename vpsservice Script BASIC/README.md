# 🌍 vpsservice Script BASIC

Este repositorio conforma la suite "BASIC" del Ecosistema de Administración y Despliegue de Redes Túneles tipo VPN para Máquinas VPS y Proveedores.

## Características

*   **Instalación Modular:** Gestores dinámicos integrados separados para OpenSSH, Sub-Stunnel, BadVPN y WebSocket.
*   **Austeridad de Interfaz:** Operado enteramente por menús bash corporativos minimalistas.
*   **Rastreo por Hardware:** Extracción nativa de RAM, Consumos Root de Disco, y Uptime de CPU.
*   **Contador Biométrico:** Sistema persistente libre-de-BD de rastreo de contraseñas de usuarios por Texto Plano y Monitoreo de Túneles/Límite de Red simultáneo.
*   **Actualizaciones Aéreas OTA:** Puedes forzar los "pulls" al código desde adentro utilizando la Opción de Menú (Conectando contra los commits encriptados en Git).

---

## ⚙️ Instalación Rápida (Para la Máquina Host VPS)

Para desplegar este ambiente temporalmente en un servidor Ubuntu limpio, simplemente colócate en la raíz, clona este repositorio oficial y ejecuta el "setup":

```bash
# 1. Clonar el repositorio
git clone https://github.com/Juandocoro/Vpsservice-Bash-Basic.git 

# 2. Entrar a la suite básica
cd Vpsservice-Bash-Basic

# 3. Dar permisos al Dropper
chmod +x setup.sh

# 4. Iniciar Instalación y Autenticación con Llave
sudo ./setup.sh
```

El asistente se encargará automáticamente de validar la llave de licencia (Key Temporal) con tu Panel Maestro en Py y compilará la base fundamental del menú. Al terminar, si cerraste el modo arranque, se abrirá perpetuamente solo digitando el comando global:
`menu`
