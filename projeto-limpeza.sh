#!/bin/bash
# menu.sh - Sistema de Limpeza e Automação (tudo num só ficheiro)
# Guarda em projeto-limpeza/menu.sh

# --- Configuração inicial ---------------------------------------------------
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="$PROJECT_DIR/logs"
DOWNLOADS="$HOME/Downloads"

mkdir -p "$LOGS_DIR"
touch "$LOGS_DIR/relatorio.txt"

# --- Funções ---------------------------------------------------------------
limpar_temporarios() {
    echo ""
    echo "A limpar ficheiros temporários..."
    echo "===== $(date) - Limpeza temporários =====" >> "$LOGS_DIR/relatorio.txt"

    # Lista antes do que vai ser apagado (se existir /tmp)
    if [ -d /tmp ]; then
        find /tmp -type f -maxdepth 3 -print >> "$LOGS_DIR/relatorio.txt" 2>/dev/null
        find /tmp -type f -maxdepth 3 -delete 2>/dev/null
    else
        echo "/tmp não encontrado. A procurar ficheiros temporários alternativos..." >> "$LOGS_DIR/relatorio.txt"
    fi

    # Limpa ficheiros .tmp e .log em /tmp do Git Bash (opcional)
    find "$HOME" -type f \( -iname "*.tmp" -o -iname "*.log" \) -mtime +30 -print >> "$LOGS_DIR/relatorio.txt" 2>/dev/null

    echo "[OK] Temporários (onde aplicável) limpos!" | tee -a "$LOGS_DIR/relatorio.txt"
    read -p "Pressiona ENTER para voltar ao menu..."
}

organizar_downloads() {
    echo ""
    echo "A organizar a pasta Downloads..."
    echo "===== $(date) - Organização Downloads =====" >> "$LOGS_DIR/relatorio.txt"

    mkdir -p "$DOWNLOADS"/{imagens,documentos,arquivos,videos,outros} 2>/dev/null

    shopt -s nullglob
    for file in "$DOWNLOADS"/*; do
        if [[ -f "$file" ]]; then
            case "${file,,}" in
                *.jpg|*.jpeg|*.png|*.gif|*.bmp) mv -n "$file" "$DOWNLOADS/imagens/" ;;
                *.pdf|*.txt|*.doc|*.docx|*.odt) mv -n "$file" "$DOWNLOADS/documentos/" ;;
                *.zip|*.rar|*.7z|*.tar|*.gz) mv -n "$file" "$DOWNLOADS/arquivos/" ;;
                *.mp4|*.mkv|*.avi|*.mov) mv -n "$file" "$DOWNLOADS/videos/" ;;
                *) mv -n "$file" "$DOWNLOADS/outros/" ;;
            esac
            echo "Movido: $file" >> "$LOGS_DIR/relatorio.txt"
        fi
    done
    shopt -u nullglob

    echo "[OK] Downloads organizados!" | tee -a "$LOGS_DIR/relatorio.txt"
    read -p "Pressiona ENTER para voltar ao menu..."
}

procurar_duplicados() {
    echo ""
    echo "A procurar ficheiros duplicados em $DOWNLOADS ..."
    echo "===== $(date) - Procura duplicados =====" >> "$LOGS_DIR/relatorio.txt"

    # Verifica se existe sha256sum, fallback para md5sum
    if command -v sha256sum >/dev/null 2>&1; then
        HASHCMD="sha256sum"
    elif command -v md5sum >/dev/null 2>&1; then
        HASHCMD="md5sum"
    else
        echo "Aviso: nenhuma ferramenta de hash encontrada (sha256sum/md5sum)." | tee -a "$LOGS_DIR/relatorio.txt"
        read -p "Pressiona ENTER para voltar ao menu..."
        return
    fi

    tmpfile="$(mktemp)"
    find "$DOWNLOADS" -type f -print0 2>/dev/null | xargs -0 $HASHCMD 2>/dev/null | sort > "$tmpfile"

    # Extrai ficheiros que têm hashes duplicados (imprime o segundo e seguintes)
    awk '{ if (seen[$1]++) print $2 }' "$tmpfile" > "$PROJECT_DIR/duplicados.txt"

    if [[ -s "$PROJECT_DIR/duplicados.txt" ]]; then
        echo "Foram encontrados ficheiros duplicados (lista):"
        nl -ba "$PROJECT_DIR/duplicados.txt"
        echo "A lista foi guardada em $PROJECT_DIR/duplicados.txt"
        echo "----- Lista de duplicados -----" >> "$LOGS_DIR/relatorio.txt"
        cat "$PROJECT_DIR/duplicados.txt" >> "$LOGS_DIR/relatorio.txt"

        read -p "Queres apagar automaticamente os duplicados listados? (s/n): " escolha
        if [[ "$escolha" == "s" || "$escolha" == "S" ]]; then
            xargs -d '\n' -r rm -f < "$PROJECT_DIR/duplicados.txt"
            echo "[OK] Ficheiros duplicados apagados." | tee -a "$LOGS_DIR/relatorio.txt"
            rm -f "$PROJECT_DIR/duplicados.txt"
        else
            echo "Nenhum ficheiro foi apagado." | tee -a "$LOGS_DIR/relatorio.txt"
        fi
    else
        echo "Sem duplicados encontrados."
    fi

    rm -f "$tmpfile"
    read -p "Pressiona ENTER para voltar ao menu..."
}

estado_sistema() {
    echo ""
    echo "===== ESTADO DO SISTEMA ====="
    echo "===== $(date) - Estado do sistema =====" >> "$LOGS_DIR/relatorio.txt"

    echo ""
    echo "Espaço em disco:"
    df -h | tee -a "$LOGS_DIR/relatorio.txt"

    echo ""
    echo "Memória (se disponível):"
    if command -v free >/dev/null 2>&1; then
        free -h | tee -a "$LOGS_DIR/relatorio.txt"
    else
        echo "free não disponível neste ambiente." | tee -a "$LOGS_DIR/relatorio.txt"
    fi

    echo ""
    echo "Processos mais pesados (por memória):"
    if ps aux >/dev/null 2>&1; then
        ps aux --sort=-%mem | head -n 12 | tee -a "$LOGS_DIR/relatorio.txt"
    else
        echo "ps não disponível." | tee -a "$LOGS_DIR/relatorio.txt"
    fi

    echo ""
    echo "Uptime:"
    uptime | tee -a "$LOGS_DIR/relatorio.txt"

    read -p "Pressiona ENTER para voltar ao menu..."
}

gerar_relatorio() {
    echo ""
    echo "Relatório atualizado em $LOGS_DIR/relatorio.txt"
    echo "===== $(date) - Relatório pedido manual =====" >> "$LOGS_DIR/relatorio.txt"
    tail -n 200 "$LOGS_DIR/relatorio.txt" | sed -n '1,200p' >/dev/null 2>&1
    read -p "Pressiona ENTER para voltar ao menu..."
}

# --- Menu principal --------------------------------------------------------
while true; do
    clear
    echo "====================================="
    echo "     SISTEMA DE LIMPEZA - TSA"
    echo "====================================="
    echo "1 - Limpar ficheiros temporários"
    echo "2 - Organizar pasta Downloads"
    echo "3 - Apagar ficheiros duplicados"
    echo "4 - Mostrar estado do sistema"
    echo "5 - Gerar relatório"
    echo "0 - Sair"
    echo "====================================="
    read -p "Escolha uma opção: " opcao

    case $opcao in
        1) limpar_temporarios ;;
        2) organizar_downloads ;;
        3) procurar_duplicados ;;
        4) estado_sistema ;;
        5) gerar_relatorio ;;
        0) echo "A sair..."; exit 0 ;;
        *) echo "Opção inválida"; sleep 1 ;;
    esac
done

