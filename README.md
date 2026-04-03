# 🌍 VPS Stealth VPN Manager

## 📖 ¿Qué hace exactamente este sistema?
Es una robusta herramienta de automatización y administración para servidores Linux. Este sistema te permitirá convertir cualquier VPS Virgen en un Proxy/VPN privado súper blindado. 

El objetivo principal del script es brindar capas conmutables y métodos de tunelización potentes para **ocultar tu verdadera ubicación, encriptar la telemetría de tu tráfico y evadir firewalls gubernamentales**.

Todo funciona bajo los hilos de un orquestador interactivo que borra la complejidad del camino: la herramienta asume la carga de ajustar los certificados técnicos, manipular o asesinar puertos bloqueadores de internet, y estabilizar rutinas en Unix sin que pierdas ni una gota de tiempo.

## ✨ Funcionalidades Principales
- **Conexiones Stealth Indetectables:** Usa configuraciones sigilosas listas para hacer tu túnel irreconocible a ojos de entidades como operadoras.
- **Micro-Control Absoluto:** Todo está fragmentado modularmente, si pides prender solo un servicio de SSL, la máquina dejará dormir los demás hilos de servicio para que la saturación de RAM no se perciba.
- **Multi-Usuario a Destajo:** Crea las cuentas que quieras e injértales Fechas de Expiración. Cuentas controladas automáticamente por el Kernel evitan que prestes túneles en perpetuidad.
- **Licenciamiento Obligatorio:** Nada arranca sin consentimiento. La Máquina comprobará vía API Web remota si se depositó un Serial/Key lícito válido o denegará acceso reventando la instalación por seguridad.

---

## 🛠️ Iniciar Tu Despliegue Automatizado

¡La experiencia es "One Click"! No le pidas al usuario que ejecute purgas de carpetas o instale líneas inmensas de Git manuales, diseñamos **un Script Dropper Integrado** que hace el trabajo sucio. 

El operador solo necesita obtener el archivo único `setup.sh` (ya sea por USB, un Pastebin o wget), y tirarle este único bloque corto a su consola terminal (`root`):

```bash
chmod +x setup.sh && sudo ./setup.sh
```

### ¿Qué hace silenciosamente en el fondo tras disparar ese comando?
1. Detecta como sabueso si el servidor acoge sub-carpetas obsoletas llamadas `scrpts-bash`. **Aplastará todo rastro histórico para evitar incompatibilidades**, dejándolo limpio.
2. Tirará automáticamente usando Git el comando inteligente `git clone git@github.com:Juandocoro/scrpts-bash...`.
3. Entrará sigilosamente a tu directorio y les dará derechos y privilegios de Super Uso (Chmod +X) a todos los micro módulos descargados.
4. Auto-ejecutará finalmente el esclavo oficial `install.sh` y te pedirá tu LLAVE (Key) ante tus ojos.

### Operando el Sistema a Diario
Cumplida maravillosamente tu pre-instalación inicial validando tu Licencia, deberás administrar las cuentas diariamente pidiendo que despierte la consola base, siempre con este formato:

```bash
cd scrpts-bash
sudo ./main.sh
```
