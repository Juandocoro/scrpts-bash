#!/bin/bash
# Módulo de Usuarios

DB_FILE="/root/.vps_users"

crear_usuario() {
    clear
    echo "================================================="
    echo "                 CREAR USUARIO                   "
    echo "================================================="
    read -p "NOMBRE: " USERNAME
    if [ -z "$USERNAME" ]; then echo "[-] Error: Nombre vacío."; sleep 1; return; fi
    if id "$USERNAME" &>/dev/null; then echo "[-] Error: Ya existe."; sleep 1; return; fi

    read -s -p "CONTRASEÑA: " PASSWORD
    echo ""
    if [ -z "$PASSWORD" ]; then echo "[-] Error: Contraseña vacía."; sleep 1; return; fi

    read -p "TIEMPO (Dias): " DAYS
    if [[ ! "$DAYS" =~ ^[0-9]+$ ]]; then echo "[-] Error: Formato numérico requerido."; sleep 1; return; fi

    read -p "LIMITE CONEXIONES: " LIMIT
    if [[ ! "$LIMIT" =~ ^[0-9]+$ ]]; then echo "[-] Error: Formato numérico requerido."; sleep 1; return; fi

    EXP_DATE=$(date -d "+$DAYS days" +%Y-%m-%d 2>/dev/null)

    # Crear usuario y su contraseña Shadow
    useradd -m -s /bin/bash -e "$EXP_DATE" -c "$LIMIT" "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd

    # Guardar en Log Plano bloqueado para el administrador
    touch "$DB_FILE"
    chmod 600 "$DB_FILE"
    sed -i "/^$USERNAME:/d" "$DB_FILE" 2>/dev/null
    echo "$USERNAME:$PASSWORD" >> "$DB_FILE"

    echo "================================================="
    echo "   [+] Usuario activado!"
    echo "   Nombre : $USERNAME"
    echo "   Pass   : $PASSWORD"
    echo "   Vence  : $EXP_DATE ($DAYS d)"
    echo "   Tope   : $LIMIT Dispositivo(s)"
    echo "================================================="
    read -p "Presiona Enter para volver..."
}

administrar_usuarios() {
    while true; do
        clear
        echo "================================================="
        echo "            ADMINISTRAR USUARIOS                 "
        echo "================================================="
        echo "  1) Listar usuarios"
        echo "  2) Eliminar usuario"
        echo "  3) Modificar expiración"
        echo "  4) Cambiar contraseña"
        echo "  0) Volver"
        echo "================================================="
        read -p "Elige [0-4]: " sub_opt

        case $sub_opt in
            1)
                echo "--- USUARIOS (UID >= 1000) ---"
                awk -F':' '($3 >= 1000 && $3 != 65534 && $1 != "nobody" && $1 != "ubuntu") {print $1}' /etc/passwd | while read u; do
                    EXP=$(chage -l "$u" | grep "Account expires" | cut -d: -f2 | xargs)
                    
                    LIMITE=$(getent passwd "$u" | cut -d: -f5)
                    if [ -z "$LIMITE" ]; then LIMITE="1"; fi
                    
                    CONEX=$(ps -u "$u" -o comm= 2>/dev/null | grep -E "^(sshd|dropbear)$" | wc -l)
                    
                    # Extraer del registro de texto plano
                    PASS=$(grep "^$u:" "$DB_FILE" 2>/dev/null | cut -d: -f2)
                    if [ -z "$PASS" ]; then PASS="? (no_log)"; fi
                    
                    echo " - $u | Pass: $PASS | Vence: $EXP | Conex: $CONEX/$LIMITE"
                done
                read -p "Enter para continuar..." ;;
            2)
                read -p "Usuario a ELIMINAR: " DEL_USER
                if id "$DEL_USER" &>/dev/null; then 
                    userdel -r "$DEL_USER" 2>/dev/null
                    sed -i "/^$DEL_USER:/d" "$DB_FILE" 2>/dev/null
                    echo "[+] Eliminado."
                else 
                    echo "[-] No existe."
                fi
                read -p "Enter..." ;;
            3)
                read -p "Usuario a modificar: " MOD_USER
                if id "$MOD_USER" &>/dev/null; then
                    read -p "Nuevos días (desde hoy): " NEW_DAYS
                    if [[ "$NEW_DAYS" =~ ^[0-9]+$ ]]; then
                        NEW_EXP=$(date -d "+$NEW_DAYS days" +%Y-%m-%d)
                        usermod -e "$NEW_EXP" "$MOD_USER"; echo "[+] Vencimiento a $NEW_EXP."
                    else echo "[-] Inválido."; fi
                else echo "[-] No existe."; fi
                read -p "Enter..." ;;
            4)
                read -p "Usuario: " PASS_USER
                if id "$PASS_USER" &>/dev/null; then
                    read -s -p "Nueva clave: " NEW_PASS; echo ""
                    echo "$PASS_USER:$NEW_PASS" | chpasswd
                    
                    # Actualizar nuestra base plana
                    sed -i "/^$PASS_USER:/d" "$DB_FILE" 2>/dev/null
                    echo "$PASS_USER:$NEW_PASS" >> "$DB_FILE"
                    
                    echo "[+] Actualizada."
                else 
                    echo "[-] No existe."
                fi
                read -p "Enter..." ;;
            0) break ;;
            *) echo "Inválido."; sleep 1 ;;
        esac
    done
}
