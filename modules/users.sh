#!/bin/bash
# Módulo de Usuarios

crear_usuario() {
    clear
    echo "================================================="
    echo "              CREAR USUARIO TEMPORAL             "
    echo "================================================="
    read -p "Ingresa el nombre del usuario a crear: " USERNAME

    if [ -z "$USERNAME" ]; then echo "Error: Nombre vacío."; read -p "Enter para volver..."; return; fi
    if id "$USERNAME" &>/dev/null; then echo "Error: Usuario ya existe."; read -p "Enter para volver..."; return; fi

    read -p "¿Cuántos días de acceso tendrá? (Enter: 30): " DAYS
    DAYS=${DAYS:-30}

    EXP_DATE=$(date -d "+$DAYS days" +%Y-%m-%d 2>/dev/null)
    if [ $? -ne 0 ]; then echo "Error: Fecha inválida."; read -p "Enter..."; return; fi

    read -s -p "Contraseña para $USERNAME: " PASSWORD
    echo ""

    useradd -m -s /bin/bash -e "$EXP_DATE" "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd

    echo "================================================="
    echo "   [+] Usuario creado correctamente!"
    echo "   Usuario      : $USERNAME"
    echo "   Contraseña   : $PASSWORD"
    echo "   Vencimiento  : $EXP_DATE ($DAYS días)"
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
        echo "  5) Volver"
        echo "================================================="
        read -p "Elige [1-5]: " sub_opt

        case $sub_opt in
            1)
                echo "--- USUARIOS (UID >= 1000) ---"
                awk -F':' '($3 >= 1000 && $3 != 65534 && $1 != "nobody" && $1 != "ubuntu") {print $1}' /etc/passwd | while read u; do
                    EXP=$(chage -l "$u" | grep "Account expires" | cut -d: -f2 | xargs)
                    echo " - $u | Vence: $EXP"
                done
                read -p "Enter para continuar..." ;;
            2)
                read -p "Usuario a ELIMINAR: " DEL_USER
                if id "$DEL_USER" &>/dev/null; then userdel -r "$DEL_USER" 2>/dev/null; echo "[+] Eliminado."; else echo "[-] No existe."; fi
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
                    read -s -p "Nueva clave: " NEW_PASS; echo ""; echo "$PASS_USER:$NEW_PASS" | chpasswd; echo "[+] Actualizada."
                else echo "[-] No existe."; fi
                read -p "Enter..." ;;
            5) break ;;
            *) echo "Inválido."; sleep 1 ;;
        esac
    done
}
