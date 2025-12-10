#!/bin/bash

source funcoes/limpeza.sh
source funcoes/organizacao.sh
source funcoes/duplicados.sh
source funcoes/sistema.sh

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
1    read -p "Escolha uma opção: " opcao

    case $opcao in
        1) limpar_temporarios ;;
        2) organizar_downloads ;;
        3) procurar_duplicados ;;
        4) estado_sistema ;;
        5) gerar_relatorio ;;
        0) echo "A sair..."; exit ;;
        *) echo "Opção inválida"; sleep 1 ;;
    esac
done
