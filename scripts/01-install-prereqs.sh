#!/bin/bash
#
# Script 01: Instala Pré-requisitos (snapd, docker-ce-cli)
# Idempotente: Verifica se os comandos/configurações já existem antes de agir.
#

set -e # Sai se qualquer comando falhar

echo "--- [Script 01] Iniciando instalação/verificação de pré-requisitos ---"
echo "(Este script pode ser executado várias vezes sem problemas)"

echo ""
echo "--> Etapa 1/3: Atualizando lista de pacotes apt..."
sudo apt-get update -y

# Instala snapd (gerenciador de pacotes snap)
echo ""
echo "--> Etapa 2/3: Verificando/Instalando snapd..."
if ! command -v snap &> /dev/null; then
    echo "   Instalando snapd..."
    sudo apt-get install snapd -y
    echo "   ✅ snapd instalado."
else
    echo "   ✅ snapd já está instalado. (Passei reto)"
fi

# Instala docker-ce-cli (apenas o cliente Docker, sem conflitos)
echo ""
echo "--> Etapa 3/3: Verificando/Instalando docker-ce-cli (cliente Docker)..."
if ! command -v docker &> /dev/null; then
    echo "   Configurando repositório Docker (se necessário)..."
    # Adiciona o repositório oficial do Docker (se não existir)
    if [ ! -f /etc/apt/keyrings/docker.asc ]; then
        sudo apt-get install ca-certificates curl -y
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        echo "   Atualizando apt após adicionar repo Docker..."
        sudo apt-get update -y
        echo "   ✅ Repositório Docker configurado."
    else
        echo "   ✅ Repositório Docker já configurado."
    fi
    echo "   Instalando docker-ce-cli..."
    sudo apt-get install docker-ce-cli -y
    echo "   ✅ docker-ce-cli instalado."
else
    echo "   ✅ Comando 'docker' (docker-ce-cli) já está instalado. (Passei reto)"
fi

echo ""
echo "--- [Script 01] Pré-requisitos verificados/instalados com sucesso! ---"