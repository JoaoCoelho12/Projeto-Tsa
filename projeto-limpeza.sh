#!/bin/bash
# menu.sh - Sistema de Limpeza e Automação (versão super simples)

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="$PROJECT_DIR/logs"
DOWNLOADS="$HOME/Downloads"

mkdir -p "$LOGS_DIR"
touch "$LOGS_DIR/relatorio.txt"

# --- Funções simples -------------------------------------------------------
limpar_temporarios() {
    echo "A limpar temporários..."
    echo "===== $(date) - Limpeza temporários =====" >> "$LOGS_DIR/relatorio.txt"
    [ -d /tmp ] && find /tmp -type f -delete 2>/dev/null
    echo "Temporários limpos." | tee -a "$LOGS_DIR/relatorio.txt"
    read -p "ENTER para continuar..."
}

organizar_downloads() {
    echo "A organizar Downloads..."
    echo "===== $(date) - Organização Downloads =====" >> "$LOGS_DIR/relatorio.txt"
    mkdir -p "$DOWNLOADS"/{imagens,documentos,arquivos,videos,outros}
    for file in "$DOWNLOADS"/*; do
        [ -f "$file" ] || continue
        case "${file,,}" in
            *.jpg|*.jpeg|*.png|*.gif) mv "$file" "$DOWNLOADS/imagens/" 2>/dev/null ;;
            *.pdf|*.doc|*.docx|*.txt) mv "$file" "$DOWNLOADS/documentos/" 2>/dev/null ;;
            *.zip|*.rar|*.7z) mv "$file" "$DOWNLOADS/arquivos/" 2>/dev/null ;;
            *.mp4|*.mkv|*.avi) mv "$file" "$DOWNLOADS/videos/" 2>/dev/null ;;
            *) mv "$file" "$DOWNLOADS/outros/" 2>/dev/null ;;
        esac
    done
    echo "Downloads organizados." | tee -a "$LOGS_DIR/relatorio.txt"
    read -p "ENTER para continuar..."
}

procurar_duplicados() {
    echo "A procurar duplicados em Downloads..."
    echo "===== $(date) - Procura duplicados =====" >> "$LOGS_DIR/relatorio.txt"
    if ! command -v md5sum >/dev/null && ! command -v sha256sum >/dev/null; then
        echo "Não há md5sum nem sha256sum. Não posso procurar duplicados."
        read -p "ENTER para continuar..."
        return
    fi
    hashcmd="md5sum"
    command -v sha256sum >/dev/null && hashcmd="sha256sum"
    find "$DOWNLOADS" -type f -exec $hashcmd {} + 2>/dev/null | sort | \
        awk '{if (seen[$1]++) print $2}' > "$PROJECT_DIR/duplicados.txt"
    if [ -s "$PROJECT_DIR/duplicados.txt" ]; then
        echo "Duplicados encontrados:"
        cat "$PROJECT_DIR/duplicados.txt"
        read -p "Apagar estes duplicados? (s/n): " resp
        [ "$resp" = "s" ] && rm -f $(cat "$PROJECT_DIR/duplicados.txt")
        rm -f "$PROJECT_DIR/duplicados.txt"
    else
        echo "Nenhum duplicado encontrado."
    fi
    read -p "ENTER para continuar..."
}

estado_sistema() {
    echo "===== ESTADO DO SISTEMA ====="
    echo "===== $(date) =====" >> "$LOGS_DIR/relatorio.txt"
    df -h | tee -a "$LOGS_DIR/relatorio.txt"
    uptime | tee -a "$LOGS_DIR/relatorio.txt"
    read -p "ENTER para continuar..."
}

# --- Menu -----------------------------------------------------------------
while true; do
    clear
    echo "====================================="
    echo "     SISTEMA DE LIMPEZA SIMPLES"
    echo "====================================="
    echo "1 - Limpar temporários"
    echo "2 - Organizar Downloads"
    echo "3 - Apagar duplicados"
    echo "4 - Estado do sistema"
    echo "0 - Sair"
    echo "====================================="
    read -p "Opção: " op
    case $op in
        1) limpar_temporarios ;;
        2) organizar_downloads ;;
        3) procurar_duplicados ;;
        4) estado_sistema ;;
        0) echo "Até à próxima!"; exit 0 ;;
        *) echo "Opção errada." ; sleep 1 ;;
    esac
done
