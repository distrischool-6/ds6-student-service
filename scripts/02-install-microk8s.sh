#!/bin/bash
#
# Script 02: Instala o MicroK8s
# Idempotente: Verifica se o comando/grupo já existe.
#

set -e

echo "--- [Script 02] Iniciando instalação/verificação do MicroK8s ---"
echo "(Este script pode ser executado várias vezes sem problemas)"

echo ""
echo "--> Etapa 1/2: Verificando/Instalando MicroK8s..."
if ! command -v microk8s &> /dev/null; then
    echo "   Instalando MicroK8s via snap..."
    # --classic permite que o snap acesse mais recursos do sistema
    sudo snap install microk8s --classic
    echo "   Aguardando MicroK8s ficar pronto pela primeira vez (pode levar alguns minutos)..."
    sudo microk8s status --wait-ready
    echo "   ✅ MicroK8s instalado."
else
    echo "   ✅ MicroK8s já está instalado. (Passei reto)"
    echo "   Garantindo que o MicroK8s está rodando..."
    sudo microk8s status --wait-ready # Garante que está pronto mesmo se já instalado
fi

echo ""
echo "--> Etapa 2/2: Verificando/Adicionando usuário ao grupo 'microk8s'..."
# Verifica se o usuário atual já pertence ao grupo microk8s
# \b é word boundary para garantir que não pegue um grupo como 'microk8s-admin'
if groups $USER | grep -q '\bmicrok8s\b'; then
    echo "   ✅ Usuário '$USER' já pertence ao grupo 'microk8s'. (Passei reto)"
else
    echo "   Adicionando usuário '$USER' ao grupo 'microk8s'..."
    sudo usermod -a -G microk8s $USER
    echo "   ✅ Usuário adicionado. !!! IMPORTANTE: Saia e logue novamente ou use 'newgrp microk8s' para aplicar !!!"
fi

echo ""
echo "--- [Script 02] MicroK8s verificado/instalado e pronto! ---"